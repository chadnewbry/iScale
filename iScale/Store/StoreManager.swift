import StoreKit
import Observation

@Observable
final class StoreManager {
    static let shared = StoreManager()

    private(set) var isProUser: Bool = false
    private(set) var removeAdsProduct: Product?
    private var updateListenerTask: Task<Void, Error>?

    private let productID = "com.chadnewbry.iScale.removeAds"
    private let proUserKey = "isProUser"

    private init() {
        isProUser = UserDefaults.standard.bool(forKey: proUserKey)
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await verifyEntitlements() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            await MainActor.run {
                removeAdsProduct = products.first
            }
        } catch {
            // Product load failed; will retry later
        }
    }

    // MARK: - Purchase

    func purchase() async throws {
        guard let product = removeAdsProduct else { return }
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await setProUser(true)
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        try? await AppStore.sync()
        await verifyEntitlements()
    }

    // MARK: - Entitlements

    private func verifyEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID,
               transaction.revocationDate == nil {
                await setProUser(true)
                return
            }
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == self.productID && transaction.revocationDate == nil {
                        await self.setProUser(true)
                    }
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }

    @MainActor
    private func setProUser(_ value: Bool) {
        isProUser = value
        UserDefaults.standard.set(value, forKey: proUserKey)
    }
}

enum StoreError: LocalizedError {
    case failedVerification
    var errorDescription: String? { "Transaction verification failed." }
}
