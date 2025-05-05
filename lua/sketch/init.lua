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
		vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, new_lines)
		vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
		local line_count = vim.api.nvim_buf_line_count(buf)
		for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
			-- Move cursor to the end and center the view
			vim.api.nvim_win_set_cursor(win, { line_count, 0 })
		end
	end
end

-- Find a buffer by name if it exists
local function find_buffer_by_name(name)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf) == name then
			return buf
		end
	end
	return nil
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

	-- Find existing sketch-output buffer or create a new one
	local buf = find_buffer_by_name('sketch-output')
	if not buf then
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
		vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
		vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
		vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
		vim.api.nvim_buf_set_name(buf, 'sketch-output')
	else
		vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
		vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
	end

	-- Display the buffer in a split window if not already visible
	local found_window = false
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			found_window = true
			-- Focus the window
			vim.api.nvim_set_current_win(win)
			break
		end
	end
	if not found_window then
		vim.cmd('split')
		vim.api.nvim_win_set_buf(0, buf)
	end

	vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'Running sketch with prompt: ' .. prompt, '', 'Please wait...' })
	vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
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
