# sketch-nvim

Neovim LUA plugin to integrate [sketch.dev](https://sketch.dev).

The plugin provides the command `:Sketch <your_prompt>` which calls `sketch -open=false -one-shot -prompt <your_prompt>`

## Installation

### Requirements

- [Neovim](https://neovim.io) 0.10.0 or newer
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

`:Sketch Implement a code base according to the design and goals specified in README.md. Think about having a
good UX, security and performance as appropriate for the project. Include unit test. At the end, update
README.md with what the project does and a TODO.md file with what next steps could be.`

This will execute the sketch command and display the results in a new buffer. A new local git branch starting
with `sketch/` will contain the result.

## License

Apache License, Version 2.0
