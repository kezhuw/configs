local M = {}

function chain_on_attach(...)
  local callbacks = {...}
  return function(client, bufnr)
    for _, cb in ipairs(callbacks) do
      cb(client, bufnr)
    end
  end
end

function on_attach(client, bufnr)
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

function calculateJdtlsDir(root_dir)
  local hash = vim.api.nvim_call_function('sha256', {root_dir})
  local dirName = vim.api.nvim_call_function('fnamemodify', {root_dir, ":t"})
  local cacheDir = vim.api.nvim_call_function('stdpath', {'cache'})
  local dirs = {cacheDir, "jdtls", dirName .. "_" .. hash}
  return table.concat(dirs, "/")
end

function before_init(params, config)
  print('before init: ', params, config)
  on_new_config(config, config.root_dir)
end

function on_new_config(new_config, root_dir)
  local jdtlsDir = calculateJdtlsDir(root_dir)
  local cmd = new_config.cmd
  for i, v in ipairs(cmd) do
    if v == "-data" then
      cmd[i+1] = jdtlsDir
      break
    elseif i == #cmd then
      table.insert(cmd, "-data")
      table.insert(cmd, jdtlsDir)
      break
    end
  end
  -- for i, v in ipairs(cmd) do
  --   if v == "-jar" then
  --     table.insert(cmd, i, "-javaagent:" .. vim.env.JDTLS_HOME .. "plugins/lombok.jar")
  --     break
  --   end
  -- end
  -- new_config.init_options = {
  --   workspace = jdtlsDir,
  --   -- jvm_args = {},
  --   jvm_args = {"-javaagent:" .. vim.env.JDTLS_HOME .. "plugins/lombok.jar"},
  --   os_config = nil,
  -- }
end

function M.start_java()
  -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
  local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {
      vim.env.HOME .. '/.jenv/versions/11/bin/java',
      -- 💀
      -- 'java', -- or '/path/to/java11_or_newer/bin/java'
              -- depends on if `java` is in your $PATH env variable and if it points to the right version.

      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xms1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens', 'java.base/java.util=ALL-UNNAMED',
      '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

      -- 💀
      '-javaagent:'.. vim.env.JDTLS_HOME .. '/plugins/lombok.jar',
      '-jar', vim.env.JDTLS_HOME .. '/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
      -- '-jar', '/path/to/jdtls_install_location/plugins/org.eclipse.equinox.launcher_VERSION_NUMBER.jar',
           -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
           -- Must point to the                                                     Change this to
           -- eclipse.jdt.ls installation                                           the actual version


      -- 💀
      '-configuration', vim.env.JDTLS_HOME .. '/config_mac',
      -- '-configuration', '/path/to/jdtls_install_location/config_SYSTEM',
                      -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
                      -- Must point to the                      Change to one of `linux`, `win` or `mac`
                      -- eclipse.jdt.ls installation            Depending on your system.


      -- 💀
      -- See `data directory configuration` section in the README
      '-data', calculateJdtlsDir(vim.fn.getcwd()),
    },
    -- cmd = {'jdtls'},

    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir
    root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),

    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
      java = {
        import = {
          gradle = {
            enabled = true
          },
          maven = {
            enabled = true
          },
          exclusions = {
              -- "**/node_modules/**",
              -- "**/.metadata/**",
              -- "**/archetype-resources/**",
              -- "**/META-INF/maven/**",
              -- "/**/test/**"
          },
        },
        configuration = {
          runtimes = {
            {
              name = "JavaSE-11",
              path = vim.env.HOME .. "/.jenv/versions/11/",
              default = true,
            },
          }
        };
      }
    },

    on_attach = chain_on_attach(on_attach, require'jdtls.setup'.add_commands),
    capabilities = require'coq'.lsp_ensure_capabilities({}),
    -- filetypes = {'java'},
    -- autostart = true,

    -- before_init = before_init,
  }
  require('jdtls').start_or_attach(config)
end

function install_filetype_hook()
  vim.cmd [[
    augroup java_lsp
      autocmd!
      autocmd FileType java lua require'plugins/lsp'.start_java()
    augroup end
  ]]
end


function M.java(options)
  return {
    'mfussenegger/nvim-jdtls',
    config = install_filetype_hook,
  }
end

return M
