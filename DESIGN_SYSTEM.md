# FirstPay Mobile Design System

## Direction

FirstPay uses Material 3 but has an original premium corporate banking identity: trustworthy, minimal, spacious, and practical. Avoid glassmorphism, neon, excessive gradients, oversized rounded cards, crypto styling, copied bank branding, and unnecessary animation.

Tagline: **Smart Digital Collections for Cooperative Credit Societies**

## Tokens

| Token | Value | Use |
|---|---|---|
| Primary navy | `#0B3D91` | primary actions/navigation |
| Success green | `#00A86B` | positive status and `PAY` logo text |
| Background | `#F8FAFC` | app canvas |
| Main text | `#0F172A` | headings/body |
| Secondary text | `#64748B` | metadata/helper text |
| Border | `#E2E8F0` | fields/dividers |
| Warning | `#F59E0B` | suspended/warning states |
| Error | `#DC2626` | errors/destructive actions |
| White | `#FFFFFF` | surfaces |

Use an 8-point spacing system, approximately 10–12 logical pixel radius, subtle borders/shadows, and at least 48 logical pixel touch targets. Inter is preferred through a standard acceptable package; otherwise use a clean platform sans-serif until approved.

The text logo displays `FIRST` in navy and `PAY` in green. It uses no bank asset or complex illustration.

## Navigation and layout

Primary destinations use a role-aware bottom navigation bar. Settings and Profile use a drawer or profile menu. Screens respect safe areas, keyboard insets, Android system back behavior, one-handed use, and narrow widths. Long records use mobile cards rather than desktop tables. Tablet/iOS layouts remain adaptive without making web the primary target.

## Components

- FirstPay logo, app bar, bottom navigation, drawer/profile menu
- Page heading and KPI card
- Mobile record card and status chip
- Search field and filter bottom sheet
- Accessible Material form fields
- Primary, secondary, and destructive buttons
- Loading skeleton, empty state, error/retry state, and offline state
- Confirmation dialog and snackbar
- Pull-to-refresh plus server pagination/load-more for page sizes 20/50/100

## Interaction rules

Forms remain visible above the keyboard, prevent duplicate submission, preserve safe input after recoverable errors, and display inline help. Destructive dialogs name the record and consequence. Status is never conveyed by color alone. Async updates have clear progress and accessible announcements. Motion respects reduced-motion settings. Visible English strings are centralized for later Marathi localization.

## Accessibility review

Verify WCAG AA-equivalent contrast, semantic labels, logical focus order, screen-reader output, text scaling, minimum targets, dark-system setting behavior even if Phase 1 ships a light theme, back navigation, and error recovery on representative Android sizes.