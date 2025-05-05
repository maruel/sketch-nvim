-- sketch-nvim: A Neovim plugin for sketch.dev
-- Author: Marc-Antoine Ruel <maruel@gmail.com>
-- License: Apache 2.0

if vim.g.loaded_sketch_nvim == 1 then
	return
end
vim.g.loaded_sketch_nvim = 1

local M = {}

-- Check if the sketch CLI is installed
local function is_sketch_installed()
	local handle = io.popen('which sketch 2>/dev/null')
	if not handle then
		return false
	end
	local result = handle:read('*a')
	handle:close()
	return result ~= ''
end

-- Execute sketch with the given prompt
function M.run_sketch(prompt)
	if not is_sketch_installed() then
		vim.notify('Error: sketch CLI not found. Please install it from https://sketch.dev')
		return
	end
	if not prompt or prompt == '' then
		vim.notify('Error: prompt is required')
		return
	end

	local cmd = string.format('sketch -open=false -one-shot -prompt %q', prompt)

	-- Create a buffer for the output
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
	vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
	vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
	vim.api.nvim_buf_set_name(buf, 'sketch-output')

	-- Display the buffer in a new split window
	vim.cmd('split')
	vim.api.nvim_win_set_buf(0, buf)

	-- Inform user that sketch is running
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'Running sketch with prompt: ' .. prompt, '', 'Please wait...' })

	-- Run the command and capture output
	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(buf, 3, -1, false, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(buf, 3, -1, false, data)
			end
		end,
		on_exit = function(_, code)
			local status = code == 0 and 'SUCCESS' or 'FAILED (exit code: ' .. code .. ')'
			vim.api.nvim_buf_set_lines(buf, 0, 2, false, { 'Sketch execution ' .. status, '', 'Prompt: ' .. prompt })
		end,
	})
end

-- Define the Sketch command
vim.api.nvim_create_user_command('Sketch', function(opts)
	M.run_sketch(opts.args)
end, { nargs = '+', desc = 'Run sketch with the given prompt' })
