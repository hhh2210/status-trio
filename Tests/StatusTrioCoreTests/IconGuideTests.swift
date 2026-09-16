import AppKit
import SwiftUI
import XCTest
@testable import StatusTrioCore

@MainActor
final class IconGuideTests: XCTestCase {
    func testFirstUseChoicePersistsWithoutChangingIconOptions() {
        let name = "IconGuideTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let settings = SettingsStore(defaults: defaults)
        settings.volumeDisplayStyle = .arc
        settings.showsBatteryPercentage = false
        XCTAssertFalse(settings.hasSeenIconGuide)

        settings.hasSeenIconGuide = true

        let restored = SettingsStore(defaults: defaults)
        XCTAssertTrue(restored.hasSeenIconGuide)
        XCTAssertEqual(restored.volumeDisplayStyle, .arc)
        XCTAssertFalse(restored.showsBatteryPercentage)
    }

    func testDismissalSurvivesRetainedPopoverReopenAndNewController() {
        let name = "IconGuideTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let settings = SettingsStore(defaults: defaults)
        let presentation = IconGuidePresentation()
        XCTAssertFalse(presentation.isPresented, "App launch does not present the guide")

        presentation.presentIfNeeded(settings: settings)
        XCTAssertTrue(presentation.isPresented)
        XCTAssertTrue(settings.hasSeenIconGuide)
        presentation.dismiss()
        presentation.presentIfNeeded(settings: settings)
        XCTAssertFalse(presentation.isPresented, "A retained popover must not repeat the invitation")

        let recreated = IconGuidePresentation()
        recreated.presentIfNeeded(settings: SettingsStore(defaults: defaults))
        XCTAssertFalse(recreated.isPresented, "Recreating the controller or restarting must not repeat it")
    }

    func testVolumeExplanationFollowsConfiguredStyle() {
        XCTAssertEqual(IconGuidePart.volume.explanationKey(volumeStyle: .dots), .guideVolumeDots)
        XCTAssertEqual(IconGuidePart.volume.explanationKey(volumeStyle: .arc), .guideVolumeArc)
    }
}
