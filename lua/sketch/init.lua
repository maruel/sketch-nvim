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
		-- Append the output at the end of the buffer.
		-- TODO: If the buffer doesn't end with a new line, the last line is updated.
		local new_lines = vim.split(text, '\n')
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, new_lines)
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
	local cmd = "sketch"
	local args = { "-open=false", "-one-shot", "-prompt", prompt }

	-- Create stdio handles
	local stdout = vim.uv.new_pipe(false)
	local stderr = vim.uv.new_pipe(false)
	local handle
	handle = vim.uv.spawn(cmd, {
		args = args,
		stdio = { nil, stdout, stderr }
	}, vim.schedule_wrap(function(code, signal)
		stdout:close()
		stderr:close()
		if handle then
			handle:close()
		end
		local status = code == 0 and 'SUCCESS' or 'FAILED (exit code: ' .. code .. ')'
		append_text_to_buffer(buf, 'Sketch execution ' .. status)
	end))
	stdout:read_start(vim.schedule_wrap(function(err, data)
		if err then
			append_text_to_buffer(buf, 'Error reading stdout: ' .. err)
		else
			if data then
				append_text_to_buffer(buf, data)
			end
		end
	end))
	stderr:read_start(vim.schedule_wrap(function(err, data)
		if err then
			append_text_to_buffer(buf, 'Error reading stderr: ' .. err)
		else
			if data then
				append_text_to_buffer(buf, data)
			end
		end
	end))
end

return M
