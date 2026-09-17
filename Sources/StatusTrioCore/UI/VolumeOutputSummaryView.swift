import SwiftUI

/// Keeps the active output visible even when it falls outside the user's list limit.
struct VolumeOutputSummaryView: View {
    @EnvironmentObject private var localization: Localization
    let volume: VolumeStatus
    let isEnabled: Bool
    let onToggleMute: () -> Void
    let onOpenSoundSettings: () -> Void

    init(
        volume: VolumeStatus,
        isEnabled: Bool = true,
        onToggleMute: @escaping () -> Void = {},
        onOpenSoundSettings: @escaping () -> Void = {}
    ) {
        self.volume = volume
        self.isEnabled = isEnabled
        self.onToggleMute = onToggleMute
        self.onOpenSoundSettings = onOpenSoundSettings
    }

    // Volume readings are live; device metadata may be cached between device events.
    var displayDeviceName: String? {
        volume.deviceName ?? currentDevice?.name
    }

    private var currentDevice: AudioOutputDevice? {
        volume.outputDevices.first(where: \.isCurrent)
    }

    var body: some View {
        let name = displayDeviceName ?? localization.string(.volumeNoDefaultDevice)
        HStack(alignment: .top, spacing: 10) {
            Button(action: onToggleMute) {
                Image(systemName: volumeSymbolName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(volume.isMuted ? Color.red : Color.secondary)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .help(volume.isMuted ? localization.string(.volumeUnmuted) : localization.string(.volumeMuted))
            .accessibilityLabel(volume.isMuted ? localization.string(.volumeUnmuted) : localization.string(.volumeMuted))

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .help(name)

                Text(volume.isMuted
                     ? localization.string(.volumeMuted)
                     : StatusPresentation.volumeTitle(volume, localization: localization))
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(
                localization.string(.volumeActionOpenSettings),
                systemImage: "gearshape",
                action: onOpenSoundSettings
            )
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help(localization.string(.volumeActionOpenSettings))
            .accessibilityLabel(localization.string(.volumeActionOpenSettings))
            .frame(width: 24, height: 24)
        }
    }

    private var volumeSymbolName: String {
        if volume.isMuted {
            return "speaker.slash.fill"
        }
        guard let scalar = volume.scalar, scalar > 0 else {
            return "speaker.fill"
        }
        if scalar < 0.33 {
            return "speaker.wave.1.fill"
        } else if scalar < 0.66 {
            return "speaker.wave.2.fill"
        } else {
            return "speaker.wave.3.fill"
        }
    }
}
