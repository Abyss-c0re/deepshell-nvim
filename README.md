# DeepShell.nvim

A Neovim plugin that integrates with [DeepShell](https://github.com/Abyss-c0re/deepshell), allowing users to process code snippets and commands via DeepShell directly from Neovim.

## Installation

### Prerequisites
Ensure that **DeepShell** is installed and accessible from your shell. If it's installed in `~/.local/bin`, you may need to update your `PATH`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Add this line to your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.) to make it persistent.

### Local Installation

#### Save the Plugin File
Place your Lua file (e.g., `deep_shell.lua`) in your Neovim configuration directory. For example, create a folder and place the file there:

```sh
mkdir -p ~/.config/nvim/lua/deepshell/
cp deep_shell.lua ~/.config/nvim/lua/deepshell/
```

#### Load the Plugin
In your `init.lua` or equivalent configuration file, require the module to ensure it loads on startup:

```lua
require("deepshell.deep_shell")
```

Restart Neovim to apply the changes.

## Usage

### DeepShell (Process and Replace Code)
Processes a selected code snippet along with a user request using DeepShell in `CODE_MODE` and replaces the selection with the output.

#### Example Usage
- **Visual Mode:** Select text and run:
  ```vim
  :'<,'>DeepShell "Add a docstring to this function"
  ```

- **Command Mode:** Without selection, it will generate the code from the user prompt.
    ```vim
  :DeepShell "Generate a Python function for validating user input"
  ```

### AskDeepShell (Send User Request, Show Output)
Sends user input (and optionally selected code) to DeepShell in `DEFAULT_MODE` and displays the output in popup window **without modifying the file**.

#### Example Usage
- **Visual Mode:** Select text and run:
  ```vim
  :'<,'>AskDeepShell "Explain this function"
  ```

- **Command Mode:** Without selection, it sends only the user request:
  ```vim
  :AskDeepShell "Explain recursion"
  ```

## Debugging & Troubleshooting

### Check if DeepShell is Installed
Run this in your terminal:
```sh
deepShell --help
```
If the command is not found, make sure DeepShell is installed and its binary is in your `PATH`.

### Check if Plugin is Loaded
Run in Neovim:
```vim
:echo exists(':DeepShell')
```
If it returns `0`, the plugin is not loaded. Ensure your plugin manager has installed it.


## License
MIT License. See [LICENSE](LICENSE) for details.

