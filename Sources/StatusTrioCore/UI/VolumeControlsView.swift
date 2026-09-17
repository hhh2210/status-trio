import SwiftUI

struct VolumeControlsView: View {
    @EnvironmentObject private var localization: Localization
    @ObservedObject var settings: SettingsStore
    let scrollTargets: PopoverScrollTargets
    let volume: VolumeStatus
    let isEnabled: Bool
    let onVolumeChange: (Double) -> Void
    let onToggleMute: () -> Void
    let onSelectOutputDevice: (AudioOutputDevice) -> Void
    let onOpenSoundSettings: () -> Void

    @State private var draftVolume = 0.0
    @State private var isAdjusting = false
    @State private var isOutputExpanded: Bool

    init(
        settings: SettingsStore,
        scrollTargets: PopoverScrollTargets,
        volume: VolumeStatus,
        isEnabled: Bool,
        onVolumeChange: @escaping (Double) -> Void,
        onToggleMute: @escaping () -> Void,
        onSelectOutputDevice: @escaping (AudioOutputDevice) -> Void,
        onOpenSoundSettings: @escaping () -> Void,
        initiallyExpandsOutput: Bool = false
    ) {
        self.settings = settings
        self.scrollTargets = scrollTargets
        self.volume = volume
        self.isEnabled = isEnabled
        self.onVolumeChange = onVolumeChange
        self.onToggleMute = onToggleMute
        self.onSelectOutputDevice = onSelectOutputDevice
        self.onOpenSoundSettings = onOpenSoundSettings
        _isOutputExpanded = State(initialValue: initiallyExpandsOutput)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VolumeOutputSummaryView(
                volume: volume,
                isEnabled: isEnabled,
                onToggleMute: onToggleMute,
                onOpenSoundSettings: onOpenSoundSettings
            )

            Slider(
                value: $draftVolume,
                in: 0...1,
                onEditingChanged: handleVolumeEditing
            )
            .tint(volume.isMuted ? Color.secondary : Color.accentColor)
            .disabled(!isEnabled)
            .accessibilityLabel(localization.string(.volumeAccessibilityLabel))
            .accessibilityValue(percentageText)
            .padding(.horizontal, 2)
            // Only the slider is a scroll target; the output device list
            // below stays a normal list.
            .background(VolumeControlScrollTarget(targets: scrollTargets))

            if volume.outputDevices.count > 1 {
                Divider()
                    .padding(.top, 2)

                AudioOutputPickerView(
                    settings: settings,
                    devices: volume.outputDevices,
                    onSelect: onSelectOutputDevice,
                    isExpanded: $isOutputExpanded
                )
            }
        }
        .onAppear(perform: synchronizeVolume)
        .onChange(of: draftVolume) { _, newValue in
            updateVolume(newValue)
        }
        .onChange(of: volume.scalar) { _, _ in
            guard !isAdjusting else { return }
            synchronizeVolume()
        }
    }

    private var percentageText: String {
        guard draftVolume.isFinite else { return "—" }
        return min(1, max(0, draftVolume)).formatted(
            .percent.precision(.fractionLength(0))
                .locale(localization.resolvedLanguage.locale)
        )
    }

    private func handleVolumeEditing(_ isEditing: Bool) {
        isAdjusting = isEditing
    }

    private func updateVolume(_ newValue: Double) {
        let scalar = volume.scalar ?? -1
        guard scalar.isFinite,
              abs(newValue - min(1, max(0, scalar))) >= 0.0005 else {
            return
        }
        onVolumeChange(newValue)
    }

    private func synchronizeVolume() {
        guard let scalar = volume.scalar, scalar.isFinite else {
            draftVolume = 0
            return
        }
        draftVolume = min(1, max(0, scalar))
    }
}
