# Data Model: Juicy Micro-Interactions

## Core Components

### `JuicyFeedback` Widget
A stateless wrapper that encapsulates the haptic and animation logic.

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `child` | `Widget` | (Required) | The interactive widget to wrap. |
| `onPressed` | `VoidCallback?` | null | Optional callback to execute on tap (triggers after press). |
| `scale` | `double` | 1.05 | The peak expansion scale for the "Pop" effect. |
| `duration` | `Duration` | 300ms | Total round-trip animation time. |

## Interaction State

The interactive state is managed locally within a `StatefulWidget` (inside `JuicyFeedback`) to track:
- `isPressed`: Boolean to drive the `AnimatedScale`.

## Interaction Parameters (Global)

Defined in `KioskTheme` for unified adjustment:
- `kHapticEnabled`: `bool` (Default: `true`)
- `kJuicyScale`: `double` (Default: `1.05`)
- `kJuicyDuration`: `Duration` (Default: `const Duration(milliseconds: 300)`)
- `kJuicyCurve`: `Curve` (Default: `Curves.elasticOut`)
