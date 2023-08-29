local T = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  cmd = { 'TSUpdateSync' },
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
    'nvim-treesitter/playground',
    'hiphish/rainbow-delimiters.nvim',
    'windwp/nvim-ts-autotag',
  },
  event = {
    'BufNewFile',
    'BufReadPost',
  },
  version = false,
}

T.config = function ()
  local treesitter = require 'nvim-treesitter.configs'

  treesitter.setup {
    auto_install = { 'true' },
    autopairs = { enable = true },
    autotag = { enable = true },
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
    ensure_installed = {
      'bash',
      'css',
      'html',
      'javascript',
      'json',
      'lua',
      'markdown',
      'markdown_inline',
      'tsx',
      'typescript',
      'vim',
    },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = { enable = true },
    playground = {
      enable = true,
      keybindings = {
        focus_language = 'f',
        goto_node = '<CR>',
        show_help = '?',
        toggle_anonymous_nodes = 'a',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_language_display = 'I',
        toggle_query_editor = 'o',
        unfocus_language = 'F',
        update = 'R',
      },
      persist_queries = false, -- Whether the query persists across vim sessions
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    },
  }

  -- Add mdx highlight
  vim.treesitter.language.register('markdown', 'mdx')

  local rainbow = require('rainbow-delimiters')

  vim.g.rainbow_delimiters = {
    query = {
      [''] = 'rainbow-delimiters',
      lua = 'rainbow-blocks',
    },
    strategy = {
      [''] = rainbow.strategy['global'],
      html = rainbow.strategy['local'],
    },
  }
end

return T
