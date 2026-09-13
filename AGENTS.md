# Agent Operational Rules

Provide direct, extremely short, and accurate responses. Apply the Minto Pyramid Principle and ASD-STE100 rules to all outputs.

## Brevity Mandate

- Keep total response length as short as possible.
- Use concise bullet points.
- Do not provide unnecessary explanations or background context.
- Limit outputs to core answers and direct action items.

## Structure: Minto Pyramid Principle

- State the core conclusion or answer first.
- Group supporting points logically below the main answer.
- Provide low-level details only when asked.

## Language: ASD-STE100

- Keep sentences short (maximum 20 words).
- Use simple words with one clear meaning.
- Use active voice and imperative forms for commands.
- Do not use filler words, conversational pleasantries, or idioms.
- Eliminate ambiguity.

## Execution Standard

- Verify code and facts before responding.
- Deliver direct and actionable solutions.
- Do not make assumptions on unclear requirements; ask for clarification.

## Knowledge Assumptions

- Assume zero knowledge of music theory, instruments, or audio engineering.
- Do not use real-world musical metaphors or analogies.
- Explain all audio mechanics strictly through code variables, functions, and state.
- Define any required audio terms in simple programming concepts.

# Ultracite Code Standards

Enforces code quality through automated formatting and linting (Oxlint + Oxfmt).

- Format: `npm exec -- ultracite fix`
- Lint: `npm exec -- ultracite check`

## Core Principles

Follow these principles consistently when writing or reviewing code. Prioritize clarity, type safety, maintainability, and modern JavaScript/TypeScript practices.

### Type Safety & Explicitness

- Use explicit types for function parameters and return values when helpful.
- Prefer `unknown` over `any`.
- Use `as const` for immutable values and literal types.
- Use type narrowing instead of type assertions.
- Extract descriptive constants instead of magic numbers.

### Modern JavaScript & TypeScript

- Use arrow functions for callbacks and short functions.
- Prefer `for...of` loops over `.forEach()` and indexed `for` loops.
- Use optional chaining (`?.`) and nullish coalescing (`??`).
- Use template literals over string concatenation.
- Use object and array destructuring.
- Use `const` by default; use `let` only for reassignment. Never use `var`.

### Async & Promises

- Always `await` promises in async functions and use return values.
- Use `async/await` syntax instead of promise chains.
- Handle async errors with `try-catch` blocks.
- Do not use async functions as `Promise` executors.

### React & JSX

- Use function components over class components.
- React 19+: Use `ref` as a prop instead of `React.forwardRef`.
- Call hooks at the top level only, never conditionally.
- Specify all hook dependencies accurately.
- Use unique `key` props for iterable elements (avoid array indices).
- Nest children between tags instead of passing as props.
- Do not define components inside other components.
- Use semantic HTML (`<button>`, `<nav>`) instead of generic elements with roles.
- Provide descriptive `alt` text for images and labels for form inputs.
- Include keyboard event handlers alongside mouse events.

### Error Handling & Debugging

- Remove `console.log`, `debugger`, and `alert` statements from production code.
- Throw `Error` objects with descriptive messages, not strings or raw values.
- Do not catch errors solely to rethrow them.
- Prefer early returns over nested conditionals.

### Code Organization

- Keep functions focused and limit cognitive complexity.
- Extract complex conditions into named boolean variables.
- Prefer simple conditionals over nested ternary operators.
- Group related code together and separate concerns.

### Security

- Add `rel="noopener"` when using `target="_blank"` on links.
- Avoid `dangerouslySetInnerHTML`.
- Do not use `eval()` or assign directly to `document.cookie`.
- Validate and sanitize user input.

### Performance

- Avoid spread syntax in loop accumulators.
- Define regex literals at the top level instead of in loops.
- Prefer specific imports over namespace imports.
- Avoid barrel files.
