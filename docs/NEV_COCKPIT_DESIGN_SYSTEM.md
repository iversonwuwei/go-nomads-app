# Go Nomads App UI/UX Redesign System

## 1. Requirement Frame

### Goal
- Rebuild the visible Go Nomads mobile experience around a unified design system derived from three sources.
- Apple Human Interface Guidelines: clarity, hierarchy, harmony, consistency, system-native behavior, accessibility.
- Material 3 guidance for mobile apps: semantic color roles, type roles, adaptive layout, clear state communication, and token-driven implementation.
- The provided Nomad UI Kit references under `~/Downloads/go-nomads/UIs/APP`, especially `big-4_1570701680180.png` and `big-5_1570701677106.png`.

### Product Intent
- The app should feel like a premium travel decision product, not a dashboard or internal tool.
- The Explore experience must prioritize scanning, destination inspiration, quick comparison, and fast action.
- Navigation, spacing, typography, and component states must reduce cognitive load and improve one-handed mobile use.

### Scope Of This Phase
- Global light-theme tokens and Material theme entry.
- Home / Explore first-screen redesign.
- Shared visual rules for cards, search, tabs, surfaces, spacing, hierarchy, and touch affordances.

### Constraints
- Continue using Flutter + GetX + AppLocalizations.
- Keep current routes and data contracts intact.
- Prefer token-based changes over scattered widget-level hardcoded styles.

## 2. Source Principles Synthesis

### Apple HIG Principles Applied
- Clarity: content hierarchy must be immediately legible; decorative effects can never compete with content.
- Hierarchy: primary action, hero content, utilities, and secondary lists must be visually distinct.
- Harmony: interface shapes, shadows, spacing, and transitions should feel coherent and restrained.
- Consistency: repeated patterns such as search, cards, chips, and tab affordances must behave identically across pages.
- Feedback: states must be visible through emphasis, motion, and semantic color rather than raw text alone.
- Touch ergonomics: major actions use generous touch targets and low-friction scanning.

### Material 3 Principles Applied
- Token-driven design: color, type, shape, spacing, and elevation are centralized.
- Semantic color roles: primary, surface, on-surface, tertiary utility accents, and state colors have clear meaning.
- Role-based typography: display, headline, title, body, and label styles map to interface intent.
- Surface system: cards and grouped content use tone contrast, not random decoration.
- Component consistency: chips, segmented tabs, cards, and buttons use predictable roles.
- Accessibility: contrast and state emphasis must remain readable without relying only on color.

### Nomad UI Kit Traits To Keep
- Light mode default with cool neutral background.
- Large rounded travel cards with strong image-led storytelling.
- Search-first Explore screen.
- Small utility widgets adjacent to hero content.
- Bottom navigation with soft elevation and clear active state.
- Airy spacing and calm visual rhythm.

## 3. Go Nomads Design Rules

### Visual Direction
- Default to light mode for primary product flows.
- Use a soft neutral background instead of flat white.
- Use white elevated surfaces with subtle shadow and large radius.
- Let destination imagery carry emotional weight; surrounding UI should be calm and restrained.

### Color Roles
- Background: cool neutral app canvas.
- Surface: white or near-white elevated card.
- Surface muted: search bars, inactive tabs, grouped secondary regions.
- Primary: coral-red for selected state and product identity.
- Secondary accents: sky blue, mint green, warm amber only as utility highlights.
- Text primary: deep graphite, never pure black.
- Text secondary: subdued gray for support copy.

### Typography Rules
- Hero and section anchors use strong headline weight with compact line height.
- Support copy stays short and lighter in visual weight.
- Labels and pills use compact high-legibility sizes.
- Avoid oversized all-caps or decorative typography.

### Shape And Spacing
- Input, search, and tabs use medium-large radii.
- Content cards use large radii.
- Hero image cards use extra-large radii.
- Spacing rhythm prefers 8 / 12 / 16 / 24 / 32.

### Interaction Rules
- Search should be immediately discoverable near the top.
- Filtering is progressive and lightweight; do not overload the first viewport.
- Primary cards should open details with direct tap on the whole surface.
- Utility actions should be grouped and scannable, not stacked as dashboard widgets.
- Empty, loading, and failure states must preserve layout continuity.
- Bottom drawers used for structured editing must provide visible section grouping, field helper text, validation feedback, and a non-destructive cancel path.
- Date-like fields should prefer a picker or constrained selection flow over raw freeform input; when text fallback is retained, the expected format must stay visible in the field shell.
- Save actions must be stateful: disable duplicate submission, keep the surface open on validation or network failure, and only dismiss after confirmed success.

## 4. Component Mapping For Go Nomads

### Home / Explore
- Top bar: simple title, location context, compact profile affordance.
- Search: persistent, visually obvious, separated from list content.
- Tabs: compact segmented-style filters with a single prominent active state.
- Hero card: one featured destination card with strong image dominance and two or three concise metrics.
- Utility widgets: map, weather, migration, budget, visa, inbox condensed into compact actionable cards.
- Destination feed: image-led cards with minimal overlay and fast-scan metadata.

### Cards
- Do not mix heavy glassmorphism with list cards in light mode.
- Use one dominant image, one title, one secondary line, and a restrained metric row.
- Support actions should never obscure the main content.

### Theme Entry
- `ThemeData` must use explicit semantic colors instead of default generated purple seeds.
- Buttons, input fields, chips, and surfaces must align to the same shape language.

## 5. Implementation Strategy

### Phase 1
- Replace legacy cockpit visual language in global tokens.
- Align Flutter `ThemeData` with semantic color and type roles.
- Rework Explore home viewport to the Nomad UI Kit structure.

### Phase 2
- Extend the same system to list pages, city detail, coworking detail, and bottom navigation.
- Normalize empty, loading, and error states.

### Phase 3
- Add motion polish, accessibility review, and interaction refinement.

## 6. Validation
- Run `flutter analyze` on changed files at minimum.
- Manually verify Home on mobile-width layout first.
- Confirm contrast, tapability, and loading or empty state stability.

## 7. Delivery Notes
- This document supersedes the previous cockpit-centric visual guidance.
- All new UI work should reference this system before adding page-level styling.
