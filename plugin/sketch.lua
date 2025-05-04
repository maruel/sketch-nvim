-- sketch-nvim: A Neovim plugin for sketch.dev
-- Author: Marc-Antoine Ruel <maruel@gmail.com>
-- License: Apache 2.0

if vim.g.loaded_sketch_nvim == 1 then
  return
end
vim.g.loaded_sketch_nvim = 1

-- Define the Sketch command
vim.api.nvim_create_user_command('Sketch', function(opts)
  local sketch = require('sketch')
  sketch.run_sketch(opts.args)
end, { nargs = '+', desc = 'Run sketch with the given prompt' })
