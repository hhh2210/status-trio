import Combine

/// Owned by the popover controller so closing a retained hosting view dismisses
/// the invitation as reliably as destroying it. Settings only stores the seen bit.
@MainActor
final class IconGuidePresentation: ObservableObject {
    @Published private(set) var isPresented = false

    func presentIfNeeded(settings: SettingsStore) {
        guard !settings.hasSeenIconGuide else { return }
        settings.hasSeenIconGuide = true
        isPresented = true
    }

    func dismiss() {
        isPresented = false
    }
}
