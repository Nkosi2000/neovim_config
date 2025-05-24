local gitsigns_loaded, gitsigns = pcall(require, 'gitsigns')
local popup = require("plenary.popup")


-- Initialize gitsigns with unified configuration
if gitsigns_loaded then
  gitsigns.setup({
    signs = {
      add          = { hl = 'GitSignsAdd', text = '' },
      change       = { hl = 'GitSignsChange', text = '' },
      delete       = { hl = 'GitSignsDelete', text = '' },
      topdelete    = { hl = 'GitSignsDelete', text = '' },
      changedelete = { hl = 'GitSignsChange', text = '' },
      untracked    = { text = '┆' }
    },
    watch_gitdir = { interval = 1000 },
    current_line_blame = false,
  })
end

local input = vim.ui and vim.ui.input or function(_, on_confirm) on_confirm(nil) end

-- Function to prompt for commit message
local function git_commit()
  input({prompt = "Enter commit message: "}, function(msg)
    if msg and msg ~= '' then
      vim.cmd('!git commit -m "' .. vim.fn.escape(msg, '"') .. '"')
    else
      print("⚠️ Commit message cannot be empty!")
    end
  end)
end

-- Function to prompt user for which files to add
local function git_add()
    -- Capture changed files
    local handle = io.popen("git status --short")
    if not handle then return end
    local result = handle:read("*a")
    handle:close()

    -- Process file list
    local files = {}
    for line in result:gmatch("[^\r\n]+") do
        local status, file = line:match("^(.)(.+)$")
        if status and file then
            -- Assign icons based on status
            local icon = ""  -- Default icon for changes
            if status == "M" then icon = "" end  -- Modified
            if status == "A" then icon = "" end  -- Added
            if status == "?" then icon = "" end  -- Untracked

            table.insert(files, string.format("%s %s", icon, file))
        end
    end

    if #files == 0 then
        print("🚀 No changes to stage!")
        return
    end

    -- Open interactive file selection menu
    vim.ui.select(files, { prompt = "📂 Select files to stage:" }, function(choice)
        if not choice then
            print("⚠️ No file selected!")
            return
        end

        -- Extract filename from formatted list and add file
        local filename = choice:match("%S+ (.+)")
        if filename then
            local cmd = "git add " .. filename
            vim.fn.system(cmd)
            print("✅ Added: " .. filename)
        end
    end)
end

function GitPushWithAuthCheck()
    -- Get the remote repository URL dynamically
    local repo_url = vim.fn.system("git config --get remote.origin.url"):gsub("%s+", "")

    -- Check if Git can access the remote repository
    local auth_test = vim.fn.system("git ls-remote " .. repo_url)

    -- Authentication failed: Prompt user for credentials
    if string.find(auth_test, "could not read Username") then
        print("⚠️ GitHub authentication failed. Configuring credentials...")

        -- Prompt for GitHub Username
        local username = vim.fn.input("🔑 Enter GitHub Username: ")
        vim.fn.system("git config --global user.name " .. username)

        -- Prompt for GitHub Email
        local email = vim.fn.input("📧 Enter GitHub Email: ")
        vim.fn.system("git config --global user.email " .. email)

        -- Check if user wants to use HTTPS or SSH
        local auth_type = vim.fn.input("💡 Use HTTPS or SSH? (type 'https' or 'ssh'): ")

        if auth_type == "https" then
            -- Use stored credentials for HTTPS
            vim.fn.system("git config --global credential.helper store")
            print("🔒 Credentials stored permanently.")
        elseif auth_type == "ssh" then
            -- Ensure SSH key is added to the agent
            vim.fn.system("ssh-add ~/.ssh/id_rsa")
            print("🔑 SSH key added. Make sure it's linked to GitHub.")
        else
            print("❌ Invalid choice. Defaulting to HTTPS authentication.")
            vim.fn.system("git config --global credential.helper store")
        end

        -- Retry push after setting credentials
        print("✅ Credentials updated. Attempting push...")
        vim.fn.system("git push")
    else
        print("✅ Authentication verified. Pushing changes...")
        vim.fn.system("git push")
    end
end

-- Key mappings
vim.keymap.set('n', '<leader>hs', ':Gitsigns stage_hunk<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>hu', ':Gitsigns undo_stage_hunk<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>hr', ':Gitsigns reset_hunk<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>hp', ':Gitsigns preview_hunk<CR>', { noremap = true, silent = true })

-- Git Keybindings
vim.keymap.set('n', '<M-i>', ':!git init<CR>', {noremap = true, silent = true}) -- (git init) Alt + i
vim.keymap.set('n', '<M-c>', ':!git clone<CR>', {noremap = true, silent = true}) -- (git clone) Alt + c

vim.keymap.set('n', '<M-s>', ':!git status<CR>', {noremap = true, silent = true}) -- (git status) Alt + s
vim.keymap.set({'n','c'}, '<C-a>', git_add, { noremap = true, silent = true }) -- (git add) Ctrl + a [ Stages Changes to commit ]
vim.keymap.set('n', '<C-c>', git_commit, { noremap = true, silent = true }) -- (git commit) Ctrl + c [ Saves Changes with a descriptive message ]

vim.keymap.set('n', '<C-b>', function()
  vim.ui.input({ prompt = "Enter new branch name: " }, function(branch)
    if branch and branch ~= "" then
      vim.cmd(':!git checkout -b ' .. branch .. ' && git push --set-upstream origin ' .. branch)
    end
  end)
end, { noremap = true, silent = true }) -- (git checkout -< branch >) Ctrl + b [ Create new branch ]

vim.keymap.set('n', '<C-x>', ':!git branch -a<CR>', {noremap = true, silent = false})
vim.keymap.set('n', '<C-s>', function()
  vim.ui.input({ prompt = "Enter branch name to switch to: " }, function(branch)
    if branch and branch ~= "" then
      vim.cmd(':!git checkout ' .. branch)
    end
  end)
end, { noremap = true, silent = true })

vim.keymap.set('n', '<C-l>', ':!git pull<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-p>', ':lua GitPushWithAuthCheck()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-f>', ':!git fetch<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-r>', ':!git fetch && git pull --rebase && git push<CR>', { noremap = true, silent = true })



-- Lualine configuration
require('lualine').setup {
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {
      {
        'diff',
        symbols = {added = ' ', modified = ' ', removed = ' '},
        source = function()
          local status = gitsigns.status_dict or { added = 0, changed = 0, removed = 0 }
          local unstaged = ((status.untracked or 0) + (status.changed or 0) + (status.removed or 0)) or 0
          local staged = status.added or 0
          return string.format("📊  %d  %d  %d  | 🔴 Unstaged: %d 🟢 Staged: %d",
            status.added or 0, status.changed or 0, status.removed or 0, unstaged, staged)
        end
      }
    },
    lualine_x = {
      function()
        local branch_list = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD 2>/dev/null") or {}
        local branch = (#branch_list > 0 and vim.trim(branch_list[1])) or "No Repo"
        return string.format("🌿 Branch: %s | 📥 Pull | 📤 Push | ✏️ Commit | 🏗 New Branch | 🔎 Fetch | 🔄 Sync",
          (branch ~= '' and branch or 'No Repo'))
      end
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  options = {
    theme = 'rose-pine',
    section_separators = '',
    component_separators = ''
  }
}

-- Git Status Popup Window
local function get_current_theme()
  return vim.g.colors_name or "Unknown"
end

local function get_untracked_count()
  local handle = io.popen("git status --porcelain 2>/dev/null | grep -E '^\\?\\?' | wc -l")
  if not handle then return 0 end
  local result = handle:read("*a")
  handle:close()
  return tonumber(result:match("%d+")) or 0
end

local popup_windows = {} -- Track all active popup windows
local last_press_time = 0
local press_delay = 300 -- Time window between presses in milliseconds

local function close_all_popups()
  for _, win_id in ipairs(popup_windows) do
    if vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, true)
    end
  end
  popup_windows = {}
end

local function create_auto_closing_popup(content, is_error)
  local lines = type(content) == "table" and content or { content }
  
  local ok, win_id = pcall(popup.create, lines, {
    border = is_error and "single" or { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    highlight = is_error and "ErrorMsg" or "NormalFloat",
    padding = { 1, 2, 1, 2 },
    title = is_error and "⚠ Warning" or "󱄅 Git Status",
    borderchars = is_error and nil or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    minwidth = is_error and 30 or 40,
    maxwidth = is_error and 50 or 60,
    line = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - (is_error and 30 or 40)) / 2)
  })

  if ok and win_id then
    table.insert(popup_windows, win_id)
    vim.api.nvim_win_set_option(win_id, "winblend", is_error and 10 or 15)
    
    -- Auto-close timer
    local timer = vim.loop.new_timer()
    timer:start(3000, 0, vim.schedule_wrap(function()
      timer:stop()
      timer:close()
      if vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
        -- Remove from tracking
        for i, id in ipairs(popup_windows) do
          if id == win_id then
            table.remove(popup_windows, i)
            break
          end
        end
      end
    end))
  end
end

local function git_status_popup() 

  -- Check for double press (manual close)
  local current_time = vim.loop.now()
  if current_time - last_press_time < press_delay then
    close_all_popups()
    last_press_time = 0 -- Reset after handling double press
    return
  end
  last_press_time = current_time

  if not gitsigns_loaded then
    create_auto_closing_popup("Gitsigns plugin not available!", true)
    return
  end

  local inside_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree 2>/dev/null")[1] == "true"

  if inside_git_repo then
    local status = gitsigns.get_status_dict() or {}
    
    create_auto_closing_popup({
      "󰊢  Theme: " .. get_current_theme() .. " | 📂 Git Status",
      "────────────────────────────",
      "✅ Staged: " .. (status.added or 0),
      "🔄 Modified: " .. (status.changed or 0),
      "🗑 Removed: " .. (status.removed or 0),
      "📄 Untracked: " .. get_untracked_count(),
      "────────────────────────────"
    })
  else
    create_auto_closing_popup("🚫 No Git repository detected!", true)
  end
end

vim.keymap.set('n', '<C-x>', git_status_popup, { noremap = true, silent = true, desc = "Show git status (double press to close)" })

-- Auto-refresh when git actions occur
if gitsigns_loaded then
  vim.api.nvim_create_autocmd("User", {
    pattern = "GitSignsUpdate",
    callback = function()
      if vim.fn.exists(":GitStatusPopup") > 0 then
        vim.schedule(git_status_popup)
      end
    end
  })
end
