# Spec Delta

## MODIFIED Requirements

### Requirement: Filter chip
The design system SHALL provide a chip with a leading icon and a label that reports taps. The chip's visible pill SHALL be 32 logical pixels tall and SHALL lay out each icon as the Figma chips do: with the filter icon, a 20px icon, a 2px gap before the label and padding of 8 on the left and 10 on the right; with the order icon, a 24px icon, no gap and padding of 4 on the left and 8 on the right. Any other icon SHALL use the filter layout. The area that responds to taps SHALL be at least 44 logical pixels tall, extending evenly above and below the pill, so the chip meets the minimum tap target size without changing how it looks.

#### Scenario: Chip tap
- **WHEN** the user taps the chip
- **THEN** its callback is invoked

#### Scenario: Filter chip layout
- **WHEN** a chip is shown with the filter icon
- **THEN** its icon is 20px, 8px from the left edge, and its width is the label width plus 40 logical pixels

#### Scenario: Order chip layout
- **WHEN** a chip is shown with the order icon
- **THEN** its icon is 24px, 4px from the left edge, and its width is the label width plus 36 logical pixels

#### Scenario: Tap target taller than the pill
- **WHEN** the user taps 5 logical pixels above the visible pill of an enabled chip
- **THEN** its callback is invoked, and the visible pill is still 32 logical pixels tall

### Requirement: Search field
The design system SHALL provide a search field with a text input and a round primary action button that submits the current text. The action button SHALL be announced to assistive technology as a button with a label. The label SHALL be supplied by the caller when given, and otherwise SHALL be the platform's localized word for "search" in the app's locale, so the design system never shows a hardcoded language.

#### Scenario: Submit
- **WHEN** the user taps the action button with text "Nike"
- **THEN** the submit callback receives "Nike"

#### Scenario: Caller-supplied action label
- **WHEN** the search field is created with the action label "Avvia ricerca"
- **THEN** its action button is announced as a button labeled "Avvia ricerca"

#### Scenario: Localized default action label
- **WHEN** the search field is created without an action label in an app whose locale is Italian
- **THEN** its action button is announced with the Italian localized search label, not "Search"

## ADDED Requirements

### Requirement: Interactive atoms are operable with assistive technology
Every interactive atom (button of either variant, filter chip, radio, search action button) SHALL be exposed to assistive technology as a single element with its label, its role (button, or radio in a mutually exclusive group) and its state (enabled or disabled; checked or unchecked). When the atom is enabled and would react to a tap, that element SHALL also offer the tap action, so activating it from a screen reader (for example a double tap with TalkBack or VoiceOver) invokes the same callback as a touch. A disabled atom, and a radio that is already selected, SHALL NOT offer the tap action.

#### Scenario: Enabled button activated by a screen reader
- **WHEN** a screen reader performs the tap action on an enabled button labeled "Riprova"
- **THEN** the button's callback is invoked once

#### Scenario: Enabled chip exposes its action
- **WHEN** a chip labeled "Filtri" with a callback is shown
- **THEN** it is exposed as one enabled button labeled "Filtri" that offers the tap action

#### Scenario: Unselected radio activated by a screen reader
- **WHEN** a screen reader performs the tap action on an unselected radio
- **THEN** its change callback receives that radio's value

#### Scenario: Disabled button has no action
- **WHEN** a button has no callback
- **THEN** it is exposed as a disabled button without the tap action

### Requirement: Interactive atoms meet the minimum tap target
Every interactive atom SHALL respond to taps over an area at least 44 by 44 logical pixels, and every element offering a tap action SHALL have a label, as checked by Flutter's labeled tap target and iOS tap target guidelines.

#### Scenario: Guidelines pass for every atom
- **WHEN** each interactive atom is shown enabled at the default text scale
- **THEN** it meets the labeled tap target guideline and the 44 by 44 tap target guideline
