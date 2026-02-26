import Testing
@testable import iScale

@Test func appSettingsDefaults() {
    #expect(AppSettings.Defaults.unitSystem == "imperial")
    #expect(AppSettings.Defaults.hapticFeedback == true)
    #expect(AppSettings.Defaults.onboardingComplete == false)
}
