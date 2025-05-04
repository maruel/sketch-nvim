-- Test file for sketch-nvim
-- This can be run with :luafile lua/sketch/test.lua from Neovim

local sketch = require('sketch')

-- Mock functions for testing without running actual commands
local original_jobstart = vim.fn.jobstart
local original_nvim_err_writeln = vim.api.nvim_err_writeln

local function setup_test()
  -- Mock jobstart
  vim.fn.jobstart = function(cmd, opts)
    print("Would execute: " .. cmd)
    if opts and opts.on_exit then
      opts.on_exit(0, 0)  -- Call with success exit code
    end
    return 1
  end
  
  -- Mock error output
  vim.api.nvim_err_writeln = function(msg)
    print("Error: " .. msg)
  end
end

local function teardown_test()
  -- Restore original functions
  vim.fn.jobstart = original_jobstart
  vim.api.nvim_err_writeln = original_nvim_err_writeln
end

local function test_sketch()
  setup_test()
  
  print("\nTest 1: Running with valid prompt")
  sketch.run_sketch("Test prompt")
  
  print("\nTest 2: Running with empty prompt")
  sketch.run_sketch("")
  
  teardown_test()
  
  print("\nTests completed")
end

-- Run tests
test_sketch()
