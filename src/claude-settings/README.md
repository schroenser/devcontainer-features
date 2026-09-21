
# Opinionated settings for Claude Code (claude-settings)

Adds opinionated settings for Claude Code.

## Example Usage

```json
"features": {
    "ghcr.io/schroenser/devcontainer-features/claude-settings:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| weakerNestedSandbox | Set sandbox.enableWeakerNestedSandbox to true. Needed in unprivileged containers, where bubblewrap cannot mount a fresh /proc. Reduces sandbox strength, so only enable it when the container itself is the isolation boundary you rely on. | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/schroenser/devcontainer-features/blob/main/src/claude-settings/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
