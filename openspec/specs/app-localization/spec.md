# app-localization Specification

## Purpose

Keeps every word the app shows out of its widgets and in translation files, so the product can ship in more than one language, and makes the active language the single thing that decides how text and money are rendered.

## Requirements

### Requirement: Supported languages
The app SHALL ship Italian and English translations and SHALL start in the language of the device when it is one of them, falling back to Italian otherwise. Every user-visible string SHALL come from the translations; no screen SHALL contain a hardcoded user-visible literal.

#### Scenario: Device language is supported
- **WHEN** the app is launched on a device set to English
- **THEN** the interface is in English

#### Scenario: Device language is not supported
- **WHEN** the app is launched on a device set to a language the app does not ship
- **THEN** the interface is in Italian

#### Scenario: Both languages are complete
- **WHEN** the translation files are compared
- **THEN** they define the same set of keys, and none is empty

#### Scenario: No literals in screens
- **WHEN** a screen is built
- **THEN** every string it shows was resolved through the translations

### Requirement: Missing translation is visible, not silent
A string requested for a key that no translation file defines SHALL render in a way that makes the gap obvious during development rather than showing an empty space.

#### Scenario: Unknown key
- **WHEN** a screen asks for a key that is not in the translations
- **THEN** what is rendered identifies the missing key rather than being blank

### Requirement: The active locale formats money
Amounts of money SHALL be formatted with the number conventions of the active app locale and the euro symbol, so switching language switches the separators and the symbol placement without any change at the call sites.

#### Scenario: Italian formatting
- **WHEN** the app is in Italian and shows a price of 85
- **THEN** the amount uses a comma as the decimal separator and shows two decimals

#### Scenario: English formatting
- **WHEN** the app is in English and shows a price of 85
- **THEN** the amount uses a period as the decimal separator and shows two decimals

### Requirement: Strings carrying a value come from a translated pattern
A string that embeds a number or another value SHALL come from one translated pattern per language with the value filled in, rather than from fragments joined in screen code. The instalments line is the exception the design system already fixes: it is composed as the count, a translated connector and the amount, in that order, which reads correctly in both shipped languages. A language that needs a different word order there is out of scope for this change.

#### Scenario: No-results message
- **WHEN** no product matches "zzzqqq"
- **THEN** the message comes from one translated pattern per language with "zzzqqq" filled into it

#### Scenario: Instalments connector
- **WHEN** the instalments line is shown for 3 instalments of 28.33 euro
- **THEN** the only translated part is the connector between the count and the amount, and it differs between Italian and English
