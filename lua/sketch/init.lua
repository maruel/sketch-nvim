-- sketch-nvim: A Neovim plugin for sketch.dev
-- Author: Marc-Antoine Ruel <maruel@gmail.com>
-- License: Apache 2.0
--
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

function M.setup(opts)
end

local function append_text_to_buffer(buf, text)
	if text then
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		local new_lines = vim.split(text, '\n')
		vim.api.nvim_buf_set_lines(buf, #lines, -1, false, lines)
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, new_lines)
		--vim.api.nvim_buf_set_lines(buf, 3, -1, false, data)
		-- vim.api.nvim_buf_set_lines(buf, -1, -1, true, { data })
	end
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

	-- Create a buffer for the output
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
	vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
	vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
	vim.api.nvim_buf_set_name(buf, 'sketch-output')

	-- Display the buffer in a new split window
	vim.cmd('split')
	vim.api.nvim_win_set_buf(0, buf)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'Running sketch with prompt: ' .. prompt, '', 'Please wait...' })
	local cmd = { "sketch", "-open=false", "-one-shot", "-prompt", prompt, }
	vim.system(cmd, {
			stdout = vim.schedule_wrap(function(_, data)
				append_text_to_buffer(buf, data)
			end),
			stderr = vim.schedule_wrap(function(_, data)
				append_text_to_buffer(buf, data)
			end),
		},
		vim.schedule_wrap(function(out)
			local status = out.code == 0 and 'SUCCESS' or 'FAILED (exit code: ' .. out.code .. ')'
			append_text_to_buffer(buf, 'Sketch execution ' .. status)
		end))
end

return M
