local function get_filetype()
  local filetype = vim.bo.filetype
  return (filetype and filetype ~= "") and filetype or nil
end

local function show_output_in_floatwin(output)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
end

local function run_deepshell(opts, use_code)
  local start_line, end_line = opts.line1, opts.line2
  local snippet = ""

  -- Ensure a real selection is made
  local has_selection = start_line and end_line and start_line ~= end_line
  if has_selection then
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    snippet = table.concat(lines, "\n")
  end

  if not opts.args or opts.args == "" then
    print("Error: Please provide a user request argument.")
    return
  end

  -- Detect file type
  local lang = get_filetype()
  local lang_prefix = lang and ("Language: " .. lang .. "\n") or ""

  -- Format input for deepshell
  local combined_prompt = snippet ~= ""
    and (lang_prefix .. "Code snippet:\n" .. snippet .. "\nUser prompt: " .. opts.args)
    or (lang_prefix .. opts.args)

  -- Build command
  local cmd = "deepshell"
  local args = use_code and { "--code", combined_prompt } or { combined_prompt }

  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)

  local handle
  handle = vim.loop.spawn(cmd, { args = args, stdio = { nil, stdout, stderr } }, function(code, _)
    vim.schedule(function()
      stdout:close()
      stderr:close()
      if code ~= 0 then print("Error: deepshell command failed with exit code " .. code) end
    end)
  end)

  if stdout then
    stdout:read_start(function(err, data)
      if err then
        print("Error reading output:", err)
        return
      end
      if data then
        vim.schedule(function()
          local output_lines = vim.split(data, "\n")
          if use_code then
            if has_selection then
              vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, output_lines)
            else
              vim.api.nvim_put(output_lines, "l", true, true)
            end
          else
            show_output_in_floatwin(table.concat(output_lines, "\n"))
          end
        end)
      end
    end)
  end

  if stderr then
    stderr:read_start(function(err, data)
      if err then
        print("Error reading stderr:", err)
        return
      end
      if data then
        vim.schedule(function()
          print("DeepShell Error:", data)
        end)
      end
    end)
  end
end

vim.api.nvim_create_user_command("DeepShell", function(opts)
  run_deepshell(opts, true)
end, { range = true, nargs = 1 })

vim.api.nvim_create_user_command("AskDeepShell", function(opts)
  run_deepshell(opts, false)
end, { range = true, nargs = 1 })
