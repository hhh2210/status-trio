import SwiftUI

struct AudioOutputPickerView: View {
    @EnvironmentObject private var localization: Localization
    @ObservedObject var settings: SettingsStore
    let devices: [AudioOutputDevice]
    let onSelect: (AudioOutputDevice) -> Void
    @Binding var isExpanded: Bool

    var body: some View {
        if settings.alwaysShowsAllOutputDevices {
            AudioOutputPickerContent(
                settings: settings, devices: devices,
                onSelect: onSelect
            )
        } else {
            DisclosureGroup(isExpanded: $isExpanded) {
                AudioOutputPickerContent(
                    settings: settings, devices: devices,
                    onSelect: onSelect
                )
                .padding(.top, 4)
            } label: {
                Text(localization.string(.volumeOutputChoose))
                    .font(.callout)
                    .frame(minHeight: 24)
            }
        }
    }
}

private struct AudioOutputPickerContent: View {
    @ObservedObject var settings: SettingsStore
    let devices: [AudioOutputDevice]
    let onSelect: (AudioOutputDevice) -> Void

    var body: some View {
        OutputDeviceList(settings: settings, devices: devices, onSelect: onSelect)
    }
}
