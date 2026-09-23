# design-atoms Specification

## Purpose

Provides the atomic UI widgets of the design (buttons, chip, inputs, radio, divider, icons), styled only from the design tokens, so screens are assembled from consistent, reusable building blocks.

## Requirements

### Requirement: Atoms take all visual values from tokens
Every atomic widget SHALL derive colors, text styles, spacing and radius from the design tokens and SHALL NOT hardcode visual values.

#### Scenario: Token change propagates
- **WHEN** a token value in the theme is changed
- **THEN** every atom using that token reflects the new value without code changes in the atom

### Requirement: Buttons
The design system SHALL provide a single button component with two variants: a primary variant (filled lilac background, white label) and a tertiary variant (lilac label, no background). The primary variant SHALL be the default, and both variants SHALL support enabled and disabled states and a tap callback. A variant of the button SHALL NOT be provided as a separate component. A button SHALL size itself to its content (minimum height 44) and SHALL NOT grow to fill the vertical space its parent offers. Both variants SHALL pad their label by 16 logical pixels on each side, as the Figma button components do.

#### Scenario: Enabled tap
- **WHEN** the user taps an enabled button of either variant
- **THEN** its callback is invoked once

#### Scenario: Disabled tap
- **WHEN** a button has no callback
- **THEN** it renders as disabled and tapping does nothing

#### Scenario: Default variant
- **WHEN** a button is created without choosing a variant
- **THEN** it renders as the primary variant

#### Scenario: Tertiary has no fill
- **WHEN** a tertiary button is enabled
- **THEN** it has no background and its label uses the primary color

#### Scenario: Disabled tertiary label
- **WHEN** a tertiary button has no callback
- **THEN** its label uses the disabled text color and it still has no background

#### Scenario: Height does not depend on available space
- **WHEN** a button of either variant is placed in a parent that allows an arbitrarily large height (for example a centered container as tall as the screen)
- **THEN** the button is 44 logical pixels tall

#### Scenario: Horizontal padding
- **WHEN** a button of either variant is laid out at its intrinsic width
- **THEN** its width is the label width plus 32 logical pixels (unless the 48 minimum width applies)

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

### Requirement: Text field with floating label
The design system SHALL provide a text field whose label floats above the value once the field has content or focus, with an optional error message. The field SHALL be 56 logical pixels tall (without the error message) and its value text SHALL use the field value color token. Once floated, the label SHALL appear on screen at the P5 size (11 logical pixels), as in Figma, whatever scaling the platform applies to floating labels. The caller MAY restrict what the field accepts through input formatters, and text that a formatter rejects SHALL leave the field unchanged.

#### Scenario: Label floats
- **WHEN** the field receives text
- **THEN** the label is shown in its floated position

#### Scenario: Error state
- **WHEN** an error message is provided
- **THEN** the message is shown and the field uses the error styling

#### Scenario: Restricted input
- **WHEN** a formatter that accepts only digits is given and the user types a letter
- **THEN** the field keeps its text unchanged

#### Scenario: Unrestricted by default
- **WHEN** no formatter is given
- **THEN** the field accepts any typed text

#### Scenario: Field height
- **WHEN** a field without an error message is laid out, empty or with a value
- **THEN** it is 56 logical pixels tall

#### Scenario: Value color
- **WHEN** the field shows a value
- **THEN** the value text uses the field value color (`#3A4045`)

#### Scenario: Floated label size
- **WHEN** the field has a value and its label is floated
- **THEN** the label is rendered 11 logical pixels tall in font size (P5), not smaller

### Requirement: Radio
The design system SHALL provide a radio option with a label that shows selected and unselected states and reports selection. The radio glyph SHALL be a 20px ring centered in a 24px box, followed by a 10px gap and the label in the P2 Medium style. The selected ring and its dot SHALL use the primary color; the unselected ring SHALL use the muted primary color.

#### Scenario: Select
- **WHEN** the user taps an unselected option
- **THEN** the selection callback is invoked with that option's value

#### Scenario: Unselected color
- **WHEN** an option is not selected
- **THEN** its ring uses the muted primary color (`#CACCF2`)

#### Scenario: Label position and style
- **WHEN** an option is laid out
- **THEN** its label starts 34 logical pixels from the option's left edge and uses the P2 Medium style

### Requirement: Divider and icons
The design system SHALL provide a divider using the border token and the icons used by the design (filter, order, search, close), rendered at a configurable size and color.

#### Scenario: Icon color
- **WHEN** an icon is given a color
- **THEN** it renders in that color

### Requirement: Golden tests cover every component state
Every UI component in the design system package SHALL have a golden test with one image per visual state it defines (for example enabled, disabled, error, selected, filled). Goldens SHALL render the component with the design system theme and the bundled Poppins font, at its intrinsic size.

#### Scenario: Every atom has goldens
- **WHEN** the design system tests run
- **THEN** each atom has at least one golden image, and each state defined for it has its own image

#### Scenario: Visual regression is detected
- **WHEN** a component's rendering changes without its golden being regenerated
- **THEN** the golden test fails

#### Scenario: Goldens use the design font
- **WHEN** a golden is rendered
- **THEN** its text is drawn in Poppins, not the test fallback font

### Requirement: Icon assets are exposed as constants
The design system SHALL expose the path of every icon asset as a named constant, together with the package that owns the assets and the list of all icon paths, so an icon can be loaded without repeating asset path strings.

#### Scenario: Constants match files
- **WHEN** an icon constant is read
- **THEN** it points to an existing asset file

#### Scenario: Constants match the icon set
- **WHEN** the list of all icon paths is read
- **THEN** it contains exactly the assets of the icon set, in the same order as the icon enumeration

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
