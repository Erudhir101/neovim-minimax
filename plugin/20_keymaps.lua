-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
--
-- This file contains definitions of custom general and Leader mappings.

-- General mappings ===========================================================

-- Use this section to add custom general mappings. See `:h vim.keymap.set()`.

-- An example helper to create a Normal mode mapping
local nmap = function(lhs, rhs, desc)
  -- See `:h vim.keymap.set()`
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

nmap("<C-d>", "<C-d>zz", 'Half page down')
nmap("<C-u>", "<C-u>zz", 'Half page up')
nmap("n", "nzzzv", "Next search result(centered)")
nmap("N", "Nzzzv", "Previous search result(centered)")

-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
-- nmap('[p', '<Cmd>exe "put! " . v:register<CR>', 'Paste Above')
-- nmap(']p', '<Cmd>exe "put "  . v:register<CR>', 'Paste Below')

-- Many general mappings are created by 'mini.basics'. See 'plugin/30_mini.lua'

-- stylua: ignore start
-- The next part (until `-- stylua: ignore end`) is aligned manually for easier
-- reading. Consider preserving this or remove `-- stylua` lines to autoformat.

-- Leader mappings ============================================================

-- Neovim has the concept of a Leader key (see `:h <Leader>`). It is a configurable
-- key that is primarily used for "workflow" mappings (opposed to text editing).
-- Like "open file explorer", "create scratch buffer", "pick from buffers".
--
-- In 'plugin/10_options.lua' <Leader> is set to <Space>, i.e. press <Space>
-- whenever there is a suggestion to press <Leader>.
--
-- This config uses a "two key Leader mappings" approach: first key describes
-- semantic group, second key executes an action. Both keys are usually chosen
-- to create some kind of mnemonic.
-- Example: `<Leader>f` groups "find" type of actions; `<Leader>ff` - find files.
-- Use this section to add Leader mappings in a structural manner.
--
-- Usually if there are global and local kinds of actions, lowercase second key
-- denotes global and uppercase - local.
-- Example: `<Leader>fs` / `<Leader>fS` - find workspace/document LSP symbols.
--
-- Many of the mappings use 'mini.nvim' modules set up in 'plugin/30_mini.lua'.

-- Create a global table with information about Leader groups in certain modes.
-- This is used to provide 'mini.clue' with extra clues.
-- Add an entry if you create a new group.
_G.Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
  { mode = 'n', keys = '<Leader>E', desc = '+Explore/Edit' },
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>l', desc = '+Language' },
  { mode = 'n', keys = '<Leader>o', desc = '+Other' },
  { mode = 'n', keys = '<Leader>s', desc = '+Session' },

  { mode = 'x', keys = '<Leader>l', desc = '+Language' },
}

-- Helpers for a more concise `<Leader>` mappings.
-- Most of the mappings use `<Cmd>...<CR>` string as a right hand side (RHS) in
-- an attempt to be more concise yet descriptive. See `:h <Cmd>`.
-- This approach also doesn't require the underlying commands/functions to exist
-- during mapping creation: a "lazy loading" approach to improve startup time.
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end
-- e is for 'Explore' and 'Edit'. Common usage:
-- - `<Leader>ed` - open explorer at current working directory
-- - `<Leader>ef` - open directory of current file (needs to be present on disk)
-- - `<Leader>ei` - edit 'init.lua'
-- - All mappings that use `edit_plugin_file` - edit 'plugin/' config files
-- local edit_plugin_file = function(filename)
--   return string.format('<Cmd>edit %s/plugin/%s<CR>', vim.fn.stdpath('config'), filename)
-- end
local explore_at_file = '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>'
local explore_quickfix = function()
  for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.fn.getwininfo(win_id)[1].quickfix == 1 then return vim.cmd('cclose') end
  end
  vim.cmd('copen')
end

nmap_leader('e', '<Cmd>lua if not MiniFiles.close() then MiniFiles.open() end<CR>', 'Directory')
nmap_leader('Ef', explore_at_file, 'File directory')
nmap_leader('Ei', '<Cmd>edit $MYVIMRC<CR>', 'init.lua')
nmap_leader('En', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notifications')

-- f is for 'Fuzzy Find'. Common usage:
-- - `<Leader>ff` - find files; for best performance requires `ripgrep`
-- - `<Leader>fg` - find inside files; requires `ripgrep`
-- - `<Leader>fh` - find help tag
-- - `<Leader>fr` - resume latest picker
-- - `<Leader>fv` - all visited paths; requires 'mini.visits'
--
-- All these use 'mini.pick'. See `:h MiniPick-overview` for an overview.
-- local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'

nmap_leader('ff', '<Cmd>FzfLua files<CR>', 'Files')
nmap_leader('fg', '<Cmd>FzfLua live_grep<CR>', 'Grep')
nmap_leader('fG', '<Cmd>FzfLua grep_cword<CR>', 'Grep current word')
nmap_leader('fh', '<Cmd>FzfLua helptags<CR>', 'Help')
nmap_leader('fH', '<Cmd>FzfLua manpages<CR>', 'all Manuals')
nmap_leader('fb', '<Cmd>FzfLua buffers<CR>', 'Buffers')
nmap_leader('f:', '<Cmd>FzfLua command_history<CR>', 'Command History')
nmap_leader('f/', '<Cmd>FzfLua search_history<CR>', 'Search History')
nmap_leader('fd', '<Cmd>FzfLua diagnostics_document<CR>', 'Diagnostics')
nmap_leader('fD', '<Cmd>FzfLua diagnostics_workspace<CR>', 'Buffer Diagnostics')
nmap_leader('fs', '<Cmd>FzfLua lsp_document_symbols<CR>', 'Document Symbols')
nmap_leader('fS', '<Cmd>FzfLua lsp_workspace_symbols<CR>', 'Workspace Symbols')
nmap_leader('fk', '<Cmd>FzfLua keymaps<CR>', 'Keymaps')
nmap_leader('fm', '<Cmd>FzfLua marks<CR>', 'Marks')
nmap_leader('fj', '<Cmd>FzfLua jumps<CR>', 'Jumps')
nmap_leader('fr', '<Cmd>FzfLua resume<CR>', 'Resume')
nmap_leader('fZ', '<Cmd>FzfLua spellcheck<CR>', 'Spelling')
nmap_leader('fz', '<Cmd>FzfLua spell_suggest<CR>', 'Spell Suggest')

nmap_leader('fq', explore_quickfix, 'Quickfix')

-- l is for 'Language'. Common usage:
-- - `<Leader>ld` - show more diagnostic details in a floating window
-- - `<Leader>lr` - perform rename via LSP
-- - `<Leader>ls` - navigate to source definition of symbol under cursor
--
-- NOTE: most LSP mappings represent a more structured way of replacing built-in
-- LSP mappings (like `:h gra` and others). This is needed because `gr` is mapped
-- by an "replace" operator in 'mini.operators' (which is more commonly used).
local formatting_cmd = '<Cmd>lua require("conform").format({lsp_fallback = true, async = true, timeout_ms = 1000})<CR>'

nmap_leader('la', '<Cmd>lua vim.lsp.buf.code_action()<CR>', 'Actions')
nmap_leader('ld', '<Cmd>lua vim.diagnostic.open_float()<CR>', 'Diagnostic popup')
vim.keymap.set({ "n", "v" }, '<leader>lf', formatting_cmd, { desc = "Format" })
nmap_leader('li', '<Cmd>lua vim.lsp.buf.implementation()<CR>', 'Implementation')
nmap_leader('K', '<Cmd>lua vim.lsp.buf.hover()<CR>', 'Hover')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>', 'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>', 'References')
nmap_leader('ls', '<Cmd>lua vim.lsp.buf.definition()<CR>', 'Source definition')
nmap_leader('lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type definition')
nmap_leader('lh', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  vim.notify(vim.lsp.inlay_hint.is_enabled() and "Inlay Hints enabled" or "Inlay Hints disabled")
end, 'Inlay hint toggle')

-- o is for 'Other'. Common usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>', 'Trim trailspace')
-- nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>',          'Zoom toggle')

-- s is for 'Session'. Common usage:
-- - `<Leader>sn` - start new session
-- - `<Leader>sr` - read previously started session
-- - `<Leader>sd` - delete previously started session
local session_new = 'MiniSessions.write(vim.fn.input("Session name: "))'

nmap_leader('sd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Delete')
nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>', 'New')
nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>', 'Read')
nmap_leader('sw', '<Cmd>lua MiniSessions.write()<CR>', 'Write current')

-- v is for 'Visits'. Common usage:
-- - `<Leader>vv` - add    "core" label to current file.
-- - `<Leader>vV` - remove "core" label to current file.
-- - `<Leader>vc` - pick among all files with "core" label.
-- local make_pick_core = function(cwd, desc)
--   return function()
--     local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
--     local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
--     MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
--   end
-- end

-- nmap_leader('vc', make_pick_core('',  'Core visits (all)'),       'Core visits (all)')
-- nmap_leader('vC', make_pick_core(nil, 'Core visits (cwd)'),       'Core visits (cwd)')
-- nmap_leader('vv', '<Cmd>lua MiniVisits.add_label("core")<CR>',    'Add "core" label')
-- nmap_leader('vV', '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
-- nmap_leader('vl', '<Cmd>lua MiniVisits.add_label()<CR>',          'Add label')
-- nmap_leader('vL', '<Cmd>lua MiniVisits.remove_label()<CR>',       'Remove label')
-- stylua: ignore end
