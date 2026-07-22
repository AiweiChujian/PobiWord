# Prototype Instructions

Run the local server yourself and open the preview in the browser available to this environment. Do not give the user server-start instructions when you can run it.

Before making substantial visual changes, use the Product Design plugin's `get-context` skill when the visual source is unclear or no longer matches the current goal. When the user gives durable prototype-specific design feedback, preferences, or decisions, record them in `AGENTS.md`.

When implementing from a selected generated mock, treat that image as the source of truth for layout, component anatomy, density, spacing, color, typography, visible content, and hierarchy.

## Selected direction

- The locked H-03A source of truth is `qa-artifacts/h-03a-visual-direction-final.png`.
- For H-02, H-03A, and H-03B, the content order is: compact plan dashboard, primary entry Section, then Activity when the state has learning records.
- The plan dashboard is a single rounded secondary-background Section: a wide circular progress ring on the left and three compact tertiary-background items on the right in an upper-two/lower-one layout.
- H-03A uses a diagonal blue-violet-magenta review gradient and the vocabulary-card review icon.
- H-02 and H-03B use a vivid diagonal green-yellow learning gradient and a dedicated learning icon in the same circular icon-container system.
- H-02 and H-03B use white foreground text and white learning-icon strokes on the learning-gradient Section, matching H-03A's foreground treatment; helper copy may use 88% white.
- H-02 and H-03B use the same white-filled primary-button treatment as H-03A, with green label text for the learning theme; do not use a black or dark primary-button fill.
- H-02 has no Activity Section and no optional practice action.
- H-03A and H-03B use the same 12-column by 5-row Activity Section with four local learning states.
- Preserve the four homepage variants plus the plan menu and Profile/settings drawer.
- H-01 uses the same dark app background and navigation treatment as H-02/H-03, but its empty-state content sits directly on the app background without a Section, secondary background, border, or eyebrow label. It keeps the shared green-yellow learning symbol and a white primary button with green label text.
- All product data is local; do not add loading, failure, or completion states.
- The locked learning symbol is the prototype composition `BookOpenText` (Regular) + `Sparkle` (Fill). Use a 96 × 96 circle in H-01 and an 88 × 88 translucent glass circle in H-02/H-03B; never allow the symbol container to hug into an ellipse.
- The locked review symbol is a Pobi-specific composition of stacked vocabulary cards plus clockwise cycle arrows, placed in the same 88 × 88 translucent glass circle used by the learning entry.
- The plan-dashboard progress ring is 104 × 104 with a 15 px ring width. Keep the current value centered and reduce its font size when longer values require more inner clearance.
- The plan-dashboard progress arc must share the track's 104 × 104 bounds and use the same 15 px INSIDE stroke alignment, so it never exceeds or gets clipped by the ring container. Keep round caps at both ends and a green-at-start to yellow-at-end gradient. The three metric-item icon frames are fixed at 14 × 14; the Pending icon's internal vector aspect-fits within 12 × 12 and is centered, leaving about 1 px visual inset.
- In Figma deliverables, use a Simplified-Chinese-capable sans font such as Noto Sans SC for Chinese copy. SF Pro does not contain the required CJK glyphs and can produce inconsistent fallback rendering for words such as “复习”.
