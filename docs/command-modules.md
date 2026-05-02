# Euclase Command Module Contract

Command metadata is declared in `manifest.json`.
Command scripts in `commands/*.js` are executed as top-level JavaScript files using JavaScriptCore.

## Manifest Format

`manifest.json` must include a `commands` list with entries:

```json
{
  "name": "Example Extension",
  "version": "1.0.0",
  "description": "Sample extension",
  "commands": [
    {
      "id": "print-date-time",
      "description": "Print the current date and time"
    }
  ]
}
```

`id` must match the script filename (without `.js`) in the extension `commands/` folder.

## Rules

- Every command script in `commands/*.js` must have matching metadata in `manifest.json`.
- Every manifest command entry must have a matching script file.
- Duplicate command IDs in `manifest.json` are invalid.
- `description` must be non-empty.

## Runtime

- Euclase evaluates each selected command script with JavaScriptCore.
- Scripts run at top level when invoked.
- A global `Print("message")` bridge is available for script output.

## Extension Folder Layout

```text
~/Library/Application Support/Euclase/extensions/<extension-name>/
  manifest.json
  commands/
    print-date-time.js
```
