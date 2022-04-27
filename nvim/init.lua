local fn = vim.fn
local api = vim.api
local g = vim.g
local options = vim.opt

-- vim.fn.stdpath('data'): "~/.local/share/nvim"
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

g.mapleader = ' '
g.maplocalleader = ','

g.python_host_prog = '~/.pyenv/versions/py2nvim/bin/python'
g.python3_host_prog = '~/.pyenv/versions/py3nvim/bin/python'

options.termguicolors = true
options.number = true
options.relativenumber = true
options.updatetime = 100
options.timeoutlen = 500

options.background = 'dark'
-- vim.cmd 'colorscheme sonokai'
vim.cmd 'colorscheme dracula'

options.expandtab = true
options.tabstop = 2
options.shiftwidth = 2

function build_lsp_options()
  return {
    on_attach = function(client, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
      buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

      -- Mappings.
      local opts = { noremap=true, silent=true }
      buf_set_keymap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_set_keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      buf_set_keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
      buf_set_keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
      buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
      buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
      buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
      buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
      buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

      require "lsp_signature".on_attach({
        bind = true,
        handler_opts = {
          border = "none",
          timer_interval = 100,
        },
      }, bufnr)
    end
  }
end

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'editorconfig/editorconfig-vim'

  use {
    'akinsho/bufferline.nvim',
    -- requires = 'ryanoasis/vim-devicons',
    requires = 'kyazdani42/nvim-web-devicons',
  }
  -- use {
  --   'glepnir/galaxyline.nvim',
  --   branch = 'main',
  --   -- your statusline
  --   config = function() require 'plugins/spaceline' end,
  --   -- some optional icons
  --   requires = {'kyazdani42/nvim-web-devicons'}
  -- }
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  }

  use 'mhinz/vim-signify'

  use {
    'ciaranm/detectindent',
    'tpope/vim-sleuth',
  }

  use {
    'ms-jpq/coq_nvim',
    branch = 'coq',
  }

  use "ray-x/lsp_signature.nvim"
  use {
    'neovim/nvim-lspconfig',
    config = function()
      local lsp = require "lspconfig"
      local coq = require "coq"
      lsp.gopls.setup(coq.lsp_ensure_capabilities(build_lsp_options()))

      -- local jdtlsOptions = coq.lsp_ensure_capabilities(build_lsp_options())
      -- -- jdtlsOptions.cmd = {"jdtls"}
      -- jdtlsOptions.on_new_config = function(new_config, root_dir)
      --   local hash = vim.api.nvim_call_function('sha256', {root_dir})
      --   local dirName = vim.api.nvim_call_function('fnamemodify', {root_dir, ":t"})
      --   local cacheDir = vim.api.nvim_call_function('stdpath', {'cache'})
      --   local dirs = {cacheDir, "jdtls", dirName .. "_" .. hash}
      --   local jdtlsDir = table.concat(dirs, "/")
      --   local cmd = new_config.cmd
      --   for i, v in ipairs(cmd) do
      --     if v == "-data" then
      --       cmd[i+1] = jdtlsDir
      --       break
      --     end
      --   end
      --   for i, v in ipairs(cmd) do
      --     if v == "-jar" then
      --       table.insert(cmd, i, "-javaagent:" .. vim.env.JDTLS_HOME .. "plugins/lombok.jar")
      --       break
      --     end
      --   end
      --   new_config.init_options = {
      --     workspace = jdtlsDir,
      --     -- jvm_args = {},
      --     jvm_args = {"-javaagent:" .. vim.env.JDTLS_HOME .. "plugins/lombok.jar"},
      --     os_config = nil,
      --   }
      -- end
      -- require'lspconfig'.jdtls.setup(jdtlsOptions)

      require("rust-tools").setup({
        server = coq.lsp_ensure_capabilities(build_lsp_options()),
      })
    end,
    requires = {
      'simrat39/rust-tools.nvim',
    },
  }

  use 'tmux-plugins/vim-tmux'
  use {
    'christoomey/vim-tmux-navigator',
    config = function()
      vim.cmd [[
        " Use vim-mappings and preserve CTRL-l to clear screen.
        let g:tmux_navigator_no_mappings = 1

        nnoremap <silent> <c-w>h :TmuxNavigateLeft<cr>
        nnoremap <silent> <c-w><c-h> :TmuxNavigateLeft<cr>
        nnoremap <silent> <c-w>j :TmuxNavigateDown<cr>
        nnoremap <silent> <c-w><c-j> :TmuxNavigateDown<cr>
        nnoremap <silent> <c-w>k :TmuxNavigateUp<cr>
        nnoremap <silent> <c-w><c-k> :TmuxNavigateUp<cr>
        nnoremap <silent> <c-w>l :TmuxNavigateRight<cr>
        nnoremap <silent> <c-w><c-l> :TmuxNavigateRight<cr>
        nnoremap <silent> <c-w>p :TmuxNavigatePrevious<cr>
        nnoremap <silent> <c-w><c-p> :TmuxNavigatePrevious<cr>
      ]]
    end,
  }

  use {
    'sakshamgupta05/vim-todo-highlight',
    config = function()
      vim.g.todo_highlight_config = {
        XXX = {},
      }
    end,
    event = {'BufNewFile', 'BufRead'},
  }

  use(require'plugins.lsp'.java{})

  -- use {
  --   'hrsh7th/nvim-cmp',
  --   config = function()
  --     local cmp = require('cmp')
  --     local lspkind = require('lspkind')
  --     cmp.setup({
  --       mapping = {
  --         ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
  --         ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
  --         ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
  --         ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
  --         ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  --         ['<C-f>'] = cmp.mapping.scroll_docs(4),
  --         ['<C-Space>'] = cmp.mapping.complete(),
  --         ['<C-e>'] = cmp.mapping.close(),
  --         ['<CR>'] = cmp.mapping.confirm({
  --           behavior = cmp.ConfirmBehavior.Replace,
  --           select = true,
  --         })
  --       },
  --       formatting = {
  --         format = lspkind.cmp_format({
  --           with_text = true,
  --           maxwidth = 50,
  --           menu = ({
  --             buffer = "[Buffer]",
  --             nvim_lsp = "[LSP]",
  --             luasnip = "[LuaSnip]",
  --             nvim_lua = "[Lua]",
  --             latex_symbols = "[Latex]",
  --          })
  --         })
  --       },
  --       sources = cmp.config.sources({
  --         {name = "nvim_lsp"},
  --         {name = "buffer"},
  --         {name = "path"},
  --       })
  --     })
  --   end,
  --   requires = {
  --     'onsails/lspkind-nvim',
  --     'hrsh7th/cmp-nvim-lsp',
  --     'hrsh7th/cmp-buffer',
  --     'hrsh7th/cmp-path',
  --     'hrsh7th/cmp-cmdline'
  --   },
  -- }

  use {
    'rhysd/accelerated-jk',
    config = function()
      vim.api.nvim_set_keymap('n', 'j', '<Plug>(accelerated_jk_gj)', {})
      vim.api.nvim_set_keymap('n', 'k', '<Plug>(accelerated_jk_gk)', {})
    end,
  }

  use {
    'tpope/vim-fugitive',
    cmd = {
      'Ggrep',
      'Glgrep',
      'Gclog',
      'Gllog',
      'Gcd',
      'Glcd',
      'Gedit',
      'Gsplit',
      'Gvsplit',
      'Gtabedit',
      'Gpedit',
      'Git',
      'Gread',
      'Gwrite',
      'Gwq',
      'Gdiffsplit',
      'Gvdiffsplit',
      'Ghdiffsplit',
      'GMove',
      'GRename',
      'GDelete',
      'GRemove',
      'GBrowse',
    },
  }

  use {
    'hrsh7th/vim-eft',
    config = function()
      vim.api.nvim_set_keymap('n', ';', '<Plug>(eft-repeat)', {})
      vim.api.nvim_set_keymap('x', ';', '<Plug>(eft-repeat)', {})

      -- vim.api.nvim_set_keymap('n', 'f', '<Plug>(eft-f)', {})
      -- vim.api.nvim_set_keymap('x', 'f', '<Plug>(eft-f)', {})
      -- vim.api.nvim_set_keymap('o', 'f', '<Plug>(eft-f)', {})

      vim.api.nvim_set_keymap('n', 'F', '<Plug>(eft-F)', {})
      vim.api.nvim_set_keymap('x', 'F', '<Plug>(eft-F)', {})
      vim.api.nvim_set_keymap('o', 'F', '<Plug>(eft-F)', {})

      vim.api.nvim_set_keymap('n', 't', '<Plug>(eft-t)', {})
      vim.api.nvim_set_keymap('x', 't', '<Plug>(eft-t)', {})
      vim.api.nvim_set_keymap('o', 't', '<Plug>(eft-t)', {})

      vim.api.nvim_set_keymap('n', 'T', '<Plug>(eft-T)', {})
      vim.api.nvim_set_keymap('x', 'T', '<Plug>(eft-T)', {})
      vim.api.nvim_set_keymap('o', 'T', '<Plug>(eft-T)', {})
    end,
  }

  -- use 'psliwka/vim-smoothie'

  use {
    'dhruvasagar/vim-prosession',
    config = function()
        vim.g.prosession_dir = '~/.cache/vim/session'
        vim.g.prosession_tmux_title = 1
        vim.g.prosession_default_session = 0
    end,
    requires = 'tpope/vim-obsession',
  }

  use(require('plugins/leaderf'))

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'all',
        ignore_install = {'haskell'},
        -- ensure_installed = {'go', 'rust', 'c', 'cpp', 'css', 'dart', 'bash', 'gomod', 'java', 'lua', 'toml', 'rst', 'vim', 'vue', 'yaml', 'python', 'json', 'json5'},
        matchup = {
          enable = true,
        },
        highlight = {
          enable = true,
        }
      }
    end,
  }
  use {
    'nvim-telescope/telescope.nvim',
    config = function()
      vim.cmd [[
        " Find files using Telescope command-line sugar.
        " nnoremap <leader>ff <cmd>Telescope find_files<cr>
        " nnoremap <leader>fF <cmd>Telescope live_grep<cr>
        " Find cursor string
        nnoremap <leader>fcF <cmd>Telescope grep_string<cr>
        " Find in open files(e.g. buffers)
        nnoremap <leader>fo <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        " File navigator
        nnoremap <leader>fn <cmd>Telescope file_browser<cr>
        " Find colorscheme
        nnoremap <leader>fs <cmd>lua require('telescope.builtin').colorscheme()<cr>
        " Find in current buffer
        nnoremap <leader>fb <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>
      ]]
      require'telescope'.setup{
        defaults = {
          -- layout_strategy = 'bottom_pane',
          layout_config = {
            horizontal = {
              width = 0.999,
              preview_width = 0.35,
              prompt_position = 'bottom',
            },
            bottom_pane = {
              height = 0.7,
              width = 0.8,
              prompt_position = 'top',
            },
          },
        },
      }
    end,
    requires = {
      {'nvim-lua/plenary.nvim'},
    }
  }

  use 'mfussenegger/nvim-dap'

  use 'jiangmiao/auto-pairs'

  use 'tpope/vim-commentary'
  -- use 'tomtom/tcomment_vim'

  use {
    'andymass/vim-matchup',
  }

  use {
    'vim-scripts/vim-auto-save',
    setup = function()
      vim.g.auto_save_silent = true
    end,
    config = function()
      vim.cmd [[
        autocmd FileType markdown let g:auto_save = 1
      ]]
    end,
  }

  use 'wuelnerdotexe/vim-enfocado'


  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
      }
    end
  }

  -- colorscheme {{{
  use {
    'wbthomason/vim-nazgul',
    'sainnhe/edge',
    'sainnhe/everforest',
    'sainnhe/sonokai',
    'sainnhe/gruvbox-material',
    'flazz/vim-colorschemes',
    'rakr/vim-one',
    'joshdick/onedark.vim',
    'crusoexia/vim-monokai',
    'ajmwagar/vim-deus',
    'liuchengxu/space-vim-theme',
    'lifepillar/vim-solarized8',
    'felixhummel/setcolors.vim',
    'dracula/vim',
  }
  -- }}}

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
