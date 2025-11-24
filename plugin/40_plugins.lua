-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add, later, now = MiniDeps.add, MiniDeps.later, MiniDeps.now
local now_if_args = _G.Config.now_if_args

-- folke ================================================================

later(function()
	add({ source = "ibhagwan/fzf-lua" })
	local fzf = require("fzf-lua")
	fzf.setup()
end)

-- grug-far ================================================================

later(function()
	add({ source = "MagicDuck/grug-far.nvim" })
	local grug = require("grug-far")

	grug.setup({})

	vim.keymap.set("n", "<Leader>os", function()
		grug.open()
	end, { desc = "grug-far open" })
end)

-- flash ================================================================
later(function()
	add({ source = "folke/flash.nvim" })
	local flash = require("flash")

	flash.setup({
		search = {
			mode = "search",
		},
		char = {
			enabled = false,
		},
	})

	vim.keymap.set({ "n", "x", "o" }, ";f", function()
		flash.jump()
	end, { desc = "flash Jump" })
	vim.keymap.set({ "n", "x", "o" }, ";s", function()
		flash.treesitter()
	end, { desc = "flash Treesitter" })
end)

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- Use `main` branch since `master` branch is frozen, yet still default
		checkout = "main",
		-- Update tree-sitter parser after plugin is updated
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
	add({
		source = "nvim-treesitter/nvim-treesitter-textobjects",
		-- Same logic as for 'nvim-treesitter'
		checkout = "main",
	})

	-- Define languages which will have parsers installed and auto enabled
	local languages = {
		-- These are already pre-installed with Neovim. Used as an example.
		"bash",
		"c",
		"cpp",
		"css",
		"dockerfile",
		"gitignore",
		"go",
		"html",
		"java",
		"javascript",
		"json",
		"lua",
		"markdown",
		"markdown_inline",
		"prisma",
		"python",
		"rust",
		"svelte",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"yaml",
		-- Add here more languages with which you want to use tree-sitter
		-- To see available languages:
		-- - Execute `:=require('nvim-treesitter').get_available()`
		-- - Visit 'SUPPORTED_LANGUAGES.md' file at
		--   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
	}
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Enable tree-sitter after opening a file for a target language
	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	_G.Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

-- Completion ===========================================================

local function build_blink(params)
	vim.notify("Building blink.cmp", vim.log.levels.INFO)
	local obj = vim.system({ "cargo", "build", "--release" }, { cwd = params.path }):wait()
	if obj.code == 0 then
		vim.notify("Building blink.cmp done", vim.log.levels.INFO)
	else
		vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
	end
end

now(function()
	add({
		source = "saghen/blink.cmp",
		depends = { "rafamadriz/friendly-snippets", "echasnovski/mini.icons" },
		-- checkout = "1.6.0",
		hooks = {
			post_install = build_blink,
			post_checkout = build_blink,
		},
	})
	local border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
	require("blink.cmp").setup({
		keymap = { preset = "default", ["<C-y>"] = { "accept", "fallback" } },
		appearance = {
			nerd_font_variant = "mono",
		},
		fuzzy = { implementation = "lua" },
		completion = {
			keyword = { range = "full" },
			menu = {
				auto_show = true,
				border = border,
				draw = {
					columns = {
						{ "kind_icon", "kind", gap = 1 },
						{ "label", "label_description", gap = 1 },
					},
					components = {
						kind_icon = {
							text = function(ctx)
								local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
								return kind_icon
							end,
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						kind = {
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
					},
				},
			},
			documentation = {
				window = {
					border = border,
				},
				auto_show = true,
			},
			trigger = {
				show_on_keyword = true,
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
	})

	local on_attach = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
	end
	_G.Config.new_autocmd("LspAttach", nil, on_attach, "Set 'omnifunc'")

	vim.lsp.config("*", require("blink.cmp").get_lsp_capabilities())
end)
-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
	add("neovim/nvim-lspconfig")

	vim.lsp.enable({
		"lua_ls",
		"prettierd",
		"stylua",
		"svelte",
		"tailwindcss",
		"vtsls",
		"eslint_d",
	})
	vim.diagnostic.config({ virtual_lines = false })
	vim.lsp.config("eslint_d", {})
	vim.lsp.config("prettierd", {})
	vim.lsp.config("vtsls", {})
	vim.lsp.config("tailwindcss", {})
	-- Use `:h vim.lsp.enable()` to automatically enable language server based on
	-- the rules provided by 'nvim-lspconfig'.
	-- Use `:h vim.lsp.config()` or 'ftplugin/lsp/' directory to configure servers.
	-- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
	-- vim.lsp.enable({
	--   -- For example, if `lua-language-server` is installed, use `'lua_ls'` entry
	-- })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
	add("stevearc/conform.nvim")
	local conform = require("conform")

	-- See also:
	-- - `:h Conform`
	-- - `:h conform-options`
	-- - `:h conform-formatters`
	local prettier = {
		"prettierd",
		"prettier",
		stop_after_first = true,
	}
	conform.setup({
		formatters_by_ft = {
			javascript = prettier,
			typescript = prettier,
			javascriptreact = prettier,
			typescriptreact = prettier,
			svelte = prettier,
			css = prettier,
			html = prettier,
			json = prettier,
			jsonc = prettier,
			yaml = prettier,
			markdown = prettier,
			graphql = prettier,
			-- sql = { "sql-formatter" },
			lua = { "stylua" },
			-- c = { "clang-format" },
			-- rust = { "ast_grep" },
			-- python = { "isort", "black" },
			-- bash = { "shfmt" },
			-- shell = { "shfmt" },
		},
		format_on_save = {
			lsp_fallback = true,
			async = false,
			timeout_ms = 1001,
		},
		formatters = {
			astyle = {
				command = "astyle",
				prepend_args = { "-s3", "-c", "-J", "-n", "-q", "-z2", "-xC80" },
			},
			["clang-format"] = {
				command = "clang-format",
				prepend_args = { "--style=file", "-i" },
			},
			["cmake-format"] = {
				command = "cmake-format",
				prepend_args = { "-i" },
			},
			prettier = {
				command = "prettier",
				prepend_args = { "-w" },
			},
			prettierd = {
				command = "prettierd",
				prepend_args = { "-w" },
			},
			["sql-formatter"] = {
				command = "sql-formatter",
				prepend_args = {
					"--language=postgresql",
				},
			},
		},
	})
end)
-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function()
	add("rafamadriz/friendly-snippets")
end)

-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
later(function()
	add("mason-org/mason.nvim")
	require("mason").setup()
end)

now(function()
	add({ source = "mfussenegger/nvim-lint" })

	local lint = require("lint")

	local eslint = { "eslint_d" }

	lint.linters_by_ft = {
		javascript = eslint,
		typescript = eslint,
		javascriptreact = eslint,
		typescriptreact = eslint,
		svelte = eslint,
		-- python = { "pylint" },
		-- rust = { "ast_grep" },
		-- c = { "ast_grep" },
	}

	local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
		group = lint_augroup,
		callback = function()
			lint.try_lint()
		end,
	})

	vim.keymap.set("n", "<leader>ll", function()
		lint.try_lint()
	end, { desc = "Trigger linting for current file" })
end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
-- MiniDeps.now(function()
--   -- Install only those that you need
-- add('sainnhe/everforest')
-- add('Shatur/neovim-ayu')
-- add('ellisonleao/gruvbox.nvim')
add("folke/tokyonight.nvim")
--
--   -- Enable only one
vim.cmd("color tokyonight")
-- end)
