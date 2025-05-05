# sketch-nvim

Neovim LUA plugin to integrate [sketch.dev](https://sketch.dev).

The plugin provides the command `:Sketch <your_prompt>` which calls `sketch -open=false -one-shot -prompt <your_prompt>`

## Installation

### Requirements

- Neovim 0.5.0 or newer
- [sketch.dev](http://sketch.dev) CLI tool installed

### Using LazyVim

```lua
return {
  "maruel/sketch-nvim",
  cmd = "Sketch",
  config = true,
}
```

### Manual Installation

Clone the repository into your Neovim plugins directory:

```bash
git clone https://github.com/maruel/sketch-nvim.git ~/.local/share/nvim/site/pack/plugins/start/sketch-nvim
```

## Usage

```vim
:Sketch Write a function that calculates the Fibonacci sequence
```

This will execute the sketch command and display the results in a new buffer. A new local git branch starting
with `sketch/` will contain the result.

## License

Apache License, Version 2.0
