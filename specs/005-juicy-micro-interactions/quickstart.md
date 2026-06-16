# Quickstart: Juicy Micro-Interactions

## How to use `JuicyFeedback`

To add the "Juicy" feel to any widget, simply wrap it in the `JuicyFeedback` widget.

### 1. Wrapping a standard Button

```dart
JuicyFeedback(
  onPressed: () => print("Button Tapped!"),
  child: ElevatedButton(
    onPressed: null, // Let JuicyFeedback handle the press
    child: Text("Add to Cart"),
  ),
)
```

### 2. Wrapping a List Item or Card

```dart
JuicyFeedback(
  onPressed: () => print("Category Selected!"),
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text("🍔 Burgers"),
  ),
)
```

## Global Configuration

The settings are centralized in `KioskTheme`:

- **Scale**: Target `1.05x` for a noticeable but elegant pop.
- **Haptics**: Triggers on `PointerDown` for immediate response.
- **Curve**: `Curves.elasticOut` provides the natural spring feel.

## Verification

1. **Visual**: Tapping an element causes it to instantly grow and smoothly bounce back.
2. **Haptic**: A subtle vibration occurs simultaneously with the touch start.
3. **Consistency**: All primary buttons and categories behave identically.
