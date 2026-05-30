return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- 1. Mason（インストーラー）を先にセットアップ
			require("mason").setup()

			-- 使用するサーバーリスト（rust_analyzerはMason管理外にする）
			local servers = {
				"lua_ls",
				"pyright",
				"ts_ls",
				"html",
				"cssls",
				"bashls",
				"texlab",
				"yamlls",
				"taplo",
				"astro",
				"tailwindcss",
				"jsonls",
				"mdx_analyzer",
				"marksman",
			}

			-- 共通の capabilities
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- rust_analyzer はnvim組み込みAPI(vim.lsp.config)で設定（Mason版はnightly/edition2024非対応のため）
			-- cargo.target を Linux に固定: nix の ptrace API など Linux 限定 API を Mac でも解析させるため
			vim.lsp.config("rust_analyzer", {
				cmd = { "rustup", "run", "nightly", "rust-analyzer" },
				root_markers = { "Cargo.toml", "rust-project.json" },
				capabilities = capabilities,
				filetypes = { "rust" },
				settings = {
					["rust-analyzer"] = {
						cargo = {
							target = "x86_64-unknown-linux-gnu",
						},
					},
				},
			})
			vim.lsp.enable("rust_analyzer")

			-- mdx_analyzer もvim.lsp.configで設定（lspconfig経由だとNeovim 0.12でアタッチされない）
			-- mdx_analyzer は内部で TypeScript Language Service を使うため、
			-- ワークスペースの node_modules/typescript を tsdk として明示しないと補完を返さない
			vim.lsp.config("mdx_analyzer", {
				cmd = { "mdx-language-server", "--stdio" },
				root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
				capabilities = capabilities,
				filetypes = { "mdx" },
				before_init = function(_, config)
					local root = config.root_dir or vim.fn.getcwd()
					config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
						typescript = {
							tsdk = root .. "/node_modules/typescript/lib",
						},
					})
				end,
			})
			vim.lsp.enable("mdx_analyzer")

			-- marksman: Markdown構文（見出し・リンク・参照など）の補完用
			-- mdx_analyzer はJSX/TS寄りなので、Markdown部分はmarksmanで補う
			vim.lsp.config("marksman", {
				cmd = { "marksman", "server" },
				root_markers = { ".marksman.toml", ".git" },
				capabilities = capabilities,
				filetypes = { "markdown", "mdx" },
			})
			vim.lsp.enable("marksman")

			-- 2. Mason-LSPConfig で一括設定（handlers使用）
			require("mason-lspconfig").setup({
				ensure_installed = servers,
				automatic_installation = true,

				handlers = {
					-- (A) 普通のサーバー用の設定
					function(server_name)
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end,

					-- rust_analyzer, mdx_analyzer, marksman はMason版handlersを使わない（上でvim.lsp.configで設定済み）
					["rust_analyzer"] = function() end,
					["mdx_analyzer"] = function() end,
					["marksman"] = function() end,

					-- (B) TexLab (LaTeX) 専用の設定
					["texlab"] = function()
						require("lspconfig").texlab.setup({
							capabilities = capabilities,
							single_file_support = true,
							settings = {
								texlab = {
									build = {
										onSave = false,
										forwardSearchAfter = false,
									},
									chktex = {
										onOpenAndSave = true,
										onEdit = false,
									},
									formatterLineLength = 80,
								},
							},
						})
					end,
				},
			})
		end,
	},
}
