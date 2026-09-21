# Design

## Context

Retroactive: the code exists; this records why. Builds on the archived `add-design-system-package` and `add-golden-tests-and-atom-fixes`. Source: Figma node `0:4204` ("Bottom-controls"), whose children are named Tertiary and Primary, both 44px high. Only these two variants exist in the file.

## Goals / Non-Goals

**Goals:**
- One button component covering the Figma variants, with no call-site change for existing primary buttons.

**Non-Goals:**
- A secondary variant, larger tap target, other button shapes.

## Decisions

**1. Enum, not named constructors.**
`ScalapayButtonVariant { primary, tertiary }` and a `variant` parameter defaulting to `primary`. The variants share every parameter (`label`, `onPressed`) and differ only in style, so one constructor and one exhaustive `switch` are enough, and the variant can be chosen at runtime. Alternative: `ScalapayButton.primary(...)` / `.tertiary(...)`; no extra type safety with identical parameters and each new variant adds a constructor. Chosen with the user.

**2. Remove the text button.**
It was the tertiary variant under another name. No feature consumed it, so the removal breaks nothing here. Alternative: keep it as a deprecated alias; rejected for lack of consumers.

**3. Height 44.**
Figma sets both buttons at 44px. Chosen with the user over Material's 48px minimum tap target.

**4. Tertiary is a transparent Material, not a transparent color.**
The atoms test forbids hardcoded colors (`Color(0x...)`, `Colors.*`); `MaterialType.transparency` gives no fill without one.

### Contracts

- `enum ScalapayButtonVariant { primary, tertiary }`
- `ScalapayButton({required String label, VoidCallback? onPressed, ScalapayButtonVariant variant = ScalapayButtonVariant.primary})`
- Removed: `ScalapayTextButton`.
- Primary: fill `primary` (disabled: `border`), label `onPrimary` (disabled: `textDisabled`), horizontal padding `spacing.s * 1.5`.
- Tertiary: no fill, label `primary` (disabled: `textDisabled`), horizontal padding `spacing.xs`.

## Risks / Trade-offs

- [44px is below Material's 48px tap-target guideline] -> If accessibility requires it, widen the hit area without changing the drawn size; not done now.
- [Figma variables were not re-read for the tertiary node (tool limit reached)] -> Its label color and typography follow the existing button tokens; confirm against Figma when access allows.

## Migration Plan

Replace `ScalapayTextButton(...)` with `ScalapayButton(variant: ScalapayButtonVariant.tertiary, ...)`. Existing `ScalapayButton` calls are unchanged.
