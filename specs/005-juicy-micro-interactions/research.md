# Research: Juicy Micro-Interactions

## Interaction Architecture

### Decision
Implement a universal `JuicyFeedback` wrapper widget and update the `KioskTheme` to utilize it for primary buttons.

### Rationale
- **Flutter Limitations**: Flutter's `ThemeData` does not natively support multi-phase scale animations (1.0 -> 1.05 -> 1.0) or haptic triggers inside `ButtonStyle`.
- **Flexibility**: A wrapper widget can be applied to `ElevatedButton`, `IconButton`, and `GestureDetector` (list items) without modifying their internal logic.
- **Immediate Response**: Using `Listener` / `onPointerDown` allows for the haptic feedback to trigger faster than `onTap`, fulfilling the "immediate tactile feel" requirement.

### Alternatives Considered
- **Global Theme Overlay**: Wrapping the entire app in a `Listener` to detect hits. *Rejected* as it would trigger on non-interactive areas and is difficult to filter correctly.
- **Custom Button Library**: Replacing all buttons with a new custom class. *Rejected* as it requires more intrusive changes than a simple wrapper.

## Animation Strategy

### Decision
Use `AnimatedScale` with `Curves.elasticOut` and a duration of 300ms.

### Rationale
- `AnimatedScale` provides a high-performance way to scale widgets on the GPU.
- `Curves.elasticOut` creates the "juicy/bubble" bounce requested by the user.

## Haptic Feedback

### Decision
Use `HapticFeedback.lightImpact()` from the core Flutter `services` library.

### Rationale
- `lightImpact` is the standard for subtle, non-distracting confirmation vibrations on both iOS and Android.
- No external packages are required, keeping the dependency tree slim.

## Impact on Existing Code
- **KioskTheme**: Add a `wrapJuicy` helper.
- **KioskProductSheet**: Wrap variants and action buttons.
- **CartPage**: Wrap removal/update actions.
