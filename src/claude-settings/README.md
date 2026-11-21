
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
| gitHubCliTokenMasking | Mask GH_TOKEN in the sandbox instead of denying it. Sandboxed commands see a placeholder, and the sandbox proxy injects the real token only into requests to api.github.com. Also allows api.github.com and enables TLS termination in the sandbox network proxy, which the injection requires. For `gh run view --log`, also allows results-receiver.actions.githubusercontent.com, where api.github.com redirects log downloads, and allows sandbox writes to gh's cache directory, ~/.cache/gh (also readable) or /.jbdevcontainer/gh in JetBrains dev containers, where gh stores downloaded logs. | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/schroenser/devcontainer-features/blob/main/src/claude-settings/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
