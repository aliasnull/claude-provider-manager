# Claude Provider Manager

**A CLI Provider Manager by AliasNull**

Claude Provider Manager is a lightweight Python CLI tool for managing multiple Anthropic-compatible API providers and using them with the official Claude Code CLI.

It keeps provider credentials in a private local configuration directory and launches Claude Code with the selected provider's environment and model-picker settings.

> **Project status:** Version 1.0.0
> **Author:** AliasNull

## Features

- Add, edit, list, select, and remove API providers.
- Store provider credentials locally with restrictive file permissions.
- Test provider authentication and inspect the available model catalog.
- Discover models using four configurable modes:
  - `all`: include every model returned by the provider.
  - `suffix`: include model IDs ending with a chosen suffix, such as `:free`.
  - `prefix`: include model IDs beginning with a chosen prefix.
  - `manual`: include only model IDs selected by you.
- Generate a provider-specific Claude Code model-picker settings file.
- Sync one provider or all configured providers.
- Launch Claude Code with a selected provider.
- Keep provider credentials out of command-line arguments.

## Requirements

- Python 3.8 or newer.
- The official Claude Code CLI installed and available in `PATH`.
- An API provider that exposes an Anthropic-compatible interface and a model catalog endpoint.

The manager uses Python's standard library. No third-party Python packages are required.

## Installation

Install and configure Claude Code separately, following its official installation instructions:

<https://code.claude.com/docs/en/overview>

Clone this repository:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/claude-provider-manager.git
cd claude-provider-manager
```

Make the script executable:

```bash
chmod +x claude-provider
```

Run it directly:

```bash
./claude-provider --help
```

To run it as a command from anywhere, place it in a directory on your `PATH`, for example:

```bash
mkdir -p ~/.local/bin
cp claude-provider ~/.local/bin/claude-provider
chmod 700 ~/.local/bin/claude-provider
```

Make sure `~/.local/bin` is included in your `PATH`.

## Quick start

### 1. Add a provider

```bash
claude-provider add myprovider
```

The manager prompts for:

- Base URL
- API key or authentication token
- Default model ID
- Optional Sonnet, Opus, and Haiku model IDs
- Model discovery mode and its filter or selected model IDs

The API key is entered through a hidden prompt rather than being echoed to the terminal.

### 2. Test the provider

```bash
claude-provider test myprovider
```

This checks the provider's model catalog endpoint and reports the HTTP status, authentication result, total models, and number of model IDs ending in `:free`.

### 3. Sync its models

```bash
claude-provider sync myprovider
```

This fetches the provider's model catalog, applies the configured discovery mode, and writes a model-picker settings file for that provider.

### 4. Select and launch the provider

```bash
claude-provider use myprovider
claude-provider launch
```

You can also launch a provider without changing the active provider:

```bash
claude-provider launch myprovider
```

Pass additional Claude Code arguments after `--`:

```bash
claude-provider launch myprovider -- --version
```

## Commands

| Command | Description |
|---|---|
| `claude-provider add NAME` | Add a provider |
| `claude-provider edit NAME` | Edit an existing provider |
| `claude-provider list` | List configured providers |
| `claude-provider use NAME` | Set the active provider |
| `claude-provider current` | Show active provider details (API key is masked) |
| `claude-provider remove NAME` | Remove a provider and its local sidecar files |
| `claude-provider test [NAME]` | Test a provider; defaults to the active provider |
| `claude-provider sync [NAME]` | Sync models for a provider; defaults to the active provider |
| `claude-provider sync --all` | Sync all configured providers |
| `claude-provider models [NAME]` | Show synced models; defaults to the active provider |
| `claude-provider launch [NAME] [-- ARGS]` | Launch Claude Code using a provider |
| `claude-provider donate` | Show the project support link |
| `claude-provider --help` | Show help |
| `claude-provider --version` | Show version |

## Model discovery modes

Choose a discovery mode when adding or editing a provider.

### All models

Includes every valid model ID returned by the provider's model catalog.

### Suffix filter

Includes model IDs that end with the configured text.

Example filter:

```text
:free
```

### Prefix filter

Includes model IDs that begin with the configured text.

Example filter:

```text
deepseek-
```

### Manual selection

Enter a comma-separated list of model IDs. IDs that are not present in the provider's current catalog are skipped during sync.

The discovery preference is saved separately for each provider. A new provider defaults to `all`.

## Local configuration and security

The manager stores its runtime data under:

```text
~/.claude-provider/
```

Provider files are stored in:

```text
~/.claude-provider/providers/
```

The manager applies restrictive permissions to its configuration directory and provider files:

- Directories: `0700`
- Provider and settings files: `0600`

Provider API keys are stored locally in provider configuration files. Keep this directory private. Do not commit provider files, API keys, generated settings, or personal configuration to Git.

The manager is a local provider manager. It is **not** an API proxy, gateway, or model router. Claude Code communicates directly with the configured provider endpoint.

## Compatibility notes

- Providers must expose an API compatible with the interface expected by Claude Code.
- Model synchronization expects a JSON model catalog containing a `data` array with model objects that have string `id` fields.
- The manager requests `/v1/models`, or `/models` when the configured base URL already ends in `/v1`.
- A successful catalog test does not guarantee that every listed model supports every Claude Code feature.
- Claude Code may display an unrecognized-model warning for third-party model IDs even when inference works. Context-window behavior and supported features depend on Claude Code and the provider/model.

## Troubleshooting

**Claude Code executable not found**

Make sure Claude Code is installed and its executable is available in `PATH`.

**Provider API returns an error**

Check the provider base URL, API token, account permissions, and whether the provider supports the expected model catalog endpoint.

**No models matched the discovery mode**

Check the selected discovery mode and filter. For manual mode, confirm that the selected IDs appear in the provider's current model catalog.

**No model catalog synced**

Run:

```bash
claude-provider sync NAME
```

before launching that provider.

## Support the project

If this project is useful to you, you can support its development:

<https://ko-fi.com/aliasnull>

## Author

**AliasNull**

*A CLI Provider Manager by AliasNull.*
