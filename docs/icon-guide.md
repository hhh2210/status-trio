# Optional icon guide

On the first menu-bar or Dock popover opening, a one-line invitation explains
that the combined icon can be learned. Expanding it is optional. Selecting a
part (or focusing its button with the keyboard) explains the battery arc,
network center, or volume indicator. The volume explanation follows the current
dots/arc setting. The labeled example uses the production renderer and current
icon options, not a separately drawn imitation or live measurements.

Dismissal, completing the guide, opening Settings, or closing the popover hides
the invitation. A persisted seen bit prevents repeated invitations, including
when the controller reuses its hosting view for 60 seconds. Settings → App Icon
always offers the guide again in a disclosure group. The first-use Customize
action opens the existing Settings window; Audio settings own volume style.

The guide never launches a window by itself, requests permissions, changes icon
settings, polls, or animates. It uses standard buttons, localized labels and
VoiceOver hints and a selected trait; all 12 supported languages are included.
The collapsed invitation adds a single row, and its dismissal removes the row
from layout entirely. The settings guide remains optional even if the first
invitation was skipped.

This follows Apple's [Onboarding guidance](https://developer.apple.com/design/human-interface-guidelines/onboarding): keep onboarding optional and contextual,
let people learn through interaction, and provide another way to revisit it.
