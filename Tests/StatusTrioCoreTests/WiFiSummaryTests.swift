import Combine
import CoreWLAN
import XCTest
@testable import StatusTrioCore

@MainActor
final class WiFiSummaryTests: XCTestCase {
    func testKnownFrequencyBandsAndUnknownChannel() {
        XCTAssertEqual(WiFiFrequencyBand(coreWLANBand: .band2GHz), .twoPointFourGHz)
        XCTAssertEqual(WiFiFrequencyBand(coreWLANBand: .band5GHz), .fiveGHz)
        XCTAssertEqual(WiFiFrequencyBand(coreWLANBand: .band6GHz), .sixGHz)
        XCTAssertNil(WiFiFrequencyBand(coreWLANBand: .bandUnknown))
    }

    func testMeasurementsKeepMissingValuesUnknownAndRespectConnectionState() {
        let name = "WiFiSummaryTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let localization = Localization(defaults: defaults, preferredLanguages: ["en"])
        func summary(_ wifi: WiFiStatus, connection: NetworkConnection = .wifi) -> String? {
            WiFiSummaryPresentation.measurements(wifi, connection: connection, localization: localization)
        }
        XCTAssertEqual(summary(WiFiStatus(state: .connected, rssi: -58, band: .fiveGHz)), "5 GHz · -58 dBm")
        XCTAssertEqual(summary(WiFiStatus(state: .connected, rssi: nil, band: .twoPointFourGHz)), "2.4 GHz")
        XCTAssertEqual(summary(WiFiStatus(state: .connected, rssi: -58)), "-58 dBm")
        XCTAssertNil(summary(WiFiStatus(state: .connected, rssi: 0)))
        XCTAssertNil(summary(WiFiStatus(state: .connected, rssi: nil)))
        XCTAssertNil(summary(WiFiStatus(state: .connected, rssi: -58, band: .fiveGHz), connection: .ethernet))
        for state in [WiFiState.off, .unavailable, .notAssociated, .noInternet, .shared, .temporary] {
            XCTAssertNil(summary(WiFiStatus(state: state, rssi: -58, band: .fiveGHz)))
        }
        localization.setPreference(.language(.german))
        XCTAssertEqual(summary(WiFiStatus(state: .connected, rssi: nil, band: .twoPointFourGHz)), "2,4 GHz")
    }

    func testBandChangesDoNotInvalidateEitherIconOrItsSubscription() {
        func snapshot(_ band: WiFiFrequencyBand?) -> StatusSnapshot {
            StatusSnapshot(battery: .placeholder,
                           wifi: WiFiStatus(state: .connected, rssi: -58, band: band),
                           connection: .wifi, volume: .placeholder)
        }
        let first = snapshot(.fiveGHz)
        let second = snapshot(.sixGHz)
        XCTAssertNotEqual(first, second)
        let firstIcon = MenuBarStatus(snapshot: first)
        let secondIcon = MenuBarStatus(snapshot: second)
        XCTAssertEqual(firstIcon, secondIcon)
        XCTAssertNil(firstIcon.wifi.band)

        let source = PassthroughSubject<StatusSnapshot, Never>()
        var updates = 0
        let subscription = source.map { MenuBarStatus(snapshot: $0) }.removeDuplicates()
            .sink { _ in updates += 1 }
        source.send(first)
        source.send(second)
        source.send(snapshot(nil))
        XCTAssertEqual(updates, 1)
        subscription.cancel()

        XCTAssertEqual(
            StatusBarRenderKey(status: firstIcon, iconSize: 28, options: .standard,
                               connectionOptions: .standard, appearanceName: "aqua"),
            StatusBarRenderKey(status: secondIcon, iconSize: 28, options: .standard,
                               connectionOptions: .standard, appearanceName: "aqua")
        )
        XCTAssertEqual(
            DockIconRenderKey(status: firstIcon, options: .standard, connectionOptions: .standard, backgroundStyle: .dark),
            DockIconRenderKey(status: secondIcon, options: .standard, connectionOptions: .standard, backgroundStyle: .dark)
        )
    }
}
