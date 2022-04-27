local g = vim.g
local env = vim.env

mappings = {
  ff = "LeaderfFile",
  fF = "Leaderf rg",
  -- fb = "LeaderfBuffer",
  fr = "LeaderfMruCwd",
  fR = "LeaderfMru",
  fm = "LeaderfFunction!",
  fM = "LeaderfFunctionAll!",
  ft = "LeaderfBufTag",
  fT = "LeaderfBufTagAll",
  -- fs = "LeaderfLine",
  -- fS = "LeaderfLineAll",
  -- fh = "LeaderfHelp",
  fc = "LeaderfHistoryCmd",
  -- fs = "LeaderfColorscheme",
}

function config(param)
  vim.g.Lf_UseCache = 0
  vim.g.Lf_CacheDirectory = vim.env.HOME .. '/.cache'
  vim.g.Lf_ShortcutF = '<leader>ff'
  vim.g.Lf_ShortcutB = '<leader>fb'
  vim.g.Lf_WindowPosition = 'popup'
  vim.g.Lf_AndDelimiter = ' '
  vim.g.Lf_PopupPosition = {2, 0}
  vim.g.Lf_PopupWidth = 0.8
  vim.g.Lf_PopupHeight = 0.6
  vim.g.Lf_AutoResize = 1
  vim.g.Lf_PreviewInPopup = 1
  vim.g.Lf_PopupPreviewPosition = 'bottom'
  vim.g.Lf_PreviewHorizontalPosition = 'cursor'
  vim.g.Lf_PreviewResult = {Colorscheme = 0}
  vim.g.Lf_WildIgnore = {
    dir = {'.svn','.git','.hg'},
    file = {'*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]', '*.jar'},
  }
  vim.g.Lf_HideHelp = 1
  vim.g.Lf_CursorBlink = 1

  for k, v in pairs(mappings) do
    vim.api.nvim_set_keymap('n', '<leader>' .. k, ":" .. v .. "<CR>", {silent = true})
  end
end

function build_binding_keys()
  local keys = {}
  for k, v in pairs(mappings) do
    table.insert(keys, {'n', '<leader>' .. k})
  end
  return keys
end

return {
  'Yggdroot/LeaderF',
  keys = build_binding_keys(),
  config = config,
}
