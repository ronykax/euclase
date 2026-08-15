# Style

Keep replies suepr short, clear, digestible, straightforward, and simple.

Same for code: prefer the simplest form that still does the job. Skip intermediates, wrappers, and ceremony unless they earn their keep.

## Pattern: don't stage a value you only use once

If a name exists only to call one method (or pass through once), drop it and compose directly.

```swift
// skip — bind then use once
let x = Foo.shared
x.run()

let y = items.filter { $0.isReady }
return y

// prefer — use it where it is
Foo.shared.run()

return items.filter { $0.isReady }
```

This is the pattern, not the API. Apply it anywhere: chaining, one-shot locals, extra lets/vars, pointless wrappers.

## Design

- Background → `.ultraThinMaterial` / HUD vibrancy, not a custom color
- Text/icons → `.primary`, `.secondary`, `.accentColor`, not custom hex
- Spacing → standard 8pt grid (4 / 8 / 16 / 24)
- Type → system font at standard sizes (`.title3`, `.body`, `.caption`)

## Code Style

- Keep the code extremely simple, straightforward, and clear. As a compelte beginner, I should be able to understand every single like that you're writing.
- Prefer writing comments here and there. Keep them lowercase, super short, and to the point.
