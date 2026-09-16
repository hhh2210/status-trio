import Foundation

@MainActor
enum WiFiSummaryPresentation {
    static func measurements(
        _ wifi: WiFiStatus,
        connection: NetworkConnection,
        localization: Localization
    ) -> String? {
        guard connection != .ethernet,
              wifi.state == .connected || wifi.state == .hotspot else { return nil }
        let band = wifi.band.map {
            localization.format(.wifiSummaryBand, $0.gigahertz.formatted(
                .number.locale(Locale(identifier: localization.resolvedLanguage.rawValue))
            ))
        }
        let signal = wifi.rssi.flatMap { rssi in
            rssi < 0 ? localization.format(.wifiSummarySignal, rssi) : nil
        }
        if let band, let signal {
            return localization.format(.wifiSummaryBandAndSignal, band, signal)
        }
        return band ?? signal
    }
}
