import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: \ScanRecord.timestamp, order: .reverse) private var records: [ScanRecord]
    @State private var selectedResult: AnalysisResult?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "No measurements yet",
                        systemImage: "clock",
                        description: Text("Scan an object to see your history here.")
                    )
                } else {
                    List {
                        ForEach(records) { record in
                            Button {
                                selectedResult = record.toAnalysisResult()
                                showDetail = true
                            } label: {
                                HistoryRowView(record: record)
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .sheet(isPresented: $showDetail) {
                if let result = selectedResult {
                    ResultsSheet(result: result) {
                        showDetail = false
                        selectedResult = nil
                    }
                }
            }
        }
    }
}

// MARK: - Row View

private struct HistoryRowView: View {
    let record: ScanRecord

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let img = record.thumbnail {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: record.mode.icon)
                            .foregroundStyle(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: record.mode.icon)
                        .font(.caption)
                        .foregroundStyle(record.mode.color)
                    Text(record.mode.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(record.summary)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Text(record.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
