local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then return end

local snip_status_ok, luasnip = pcall(require, 'luasnip')
if not snip_status_ok then return end

-- local lspkind_status, lspkind = pcall(require, 'lspkind')
-- if not lspkind_status then return end

require 'luasnip/loaders/from_vscode'.lazy_load()

-- local check_backspace = function ()
--   -- lunarvim style
--   local col = vim.fn.col '.' - 1
--   return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s'
--
--   -- astronvim style
--   -- local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
--   -- return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
-- end

local has_words_before = function ()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end


---when inside a snippet, seeks to the nearest luasnip field if possible, and checks if it is jumpable
---@param dir number 1 for forward, -1 for backward; defaults to 1
---@return boolean true if a jumpable luasnip field is found while inside a snippet
local function jumpable(dir)
  if not snip_status_ok then return false end

  local win_get_cursor = vim.api.nvim_win_get_cursor
  local get_current_buf = vim.api.nvim_get_current_buf

  ---sets the current buffer's luasnip to the one nearest the cursor
  ---@return boolean true if a node is found, false otherwise
  local function seek_luasnip_cursor_node()
    -- TODO(kylo252): upstream this
    -- for outdated versions of luasnip
    if not luasnip.session.current_nodes then
      return false
    end

    local node = luasnip.session.current_nodes[get_current_buf()]
    if not node then
      return false
    end

    local snippet = node.parent.snippet
    local exit_node = snippet.insert_nodes[0]

    local pos = win_get_cursor(0)
    pos[1] = pos[1] - 1

    -- exit early if we're past the exit node
    if exit_node then
      local exit_pos_end = exit_node.mark:pos_end()
      if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    node = snippet.inner_first:jump_into(1, true)
    while node ~= nil and node.next ~= nil and node ~= snippet do
      local n_next = node.next
      local next_pos = n_next and n_next.mark:pos_begin()
      local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
        or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

      -- Past unmarked exit node, exit early
      if n_next == nil or n_next == snippet.next then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end

      if candidate then
        luasnip.session.current_nodes[get_current_buf()] = node
        return true
      end

      local ok
      ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
      if not ok then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    -- No candidate, but have an exit node
    if exit_node then
      -- to jump to the exit node, seek to snippet
      luasnip.session.current_nodes[get_current_buf()] = snippet
      return true
    end

    -- No exit node, exit from snippet
    snippet:remove_from_jumplist()
    luasnip.session.current_nodes[get_current_buf()] = nil
    return false
  end

  if dir == -1 then
    return luasnip.in_snippet() and luasnip.jumpable(-1)
  else
    return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
  end
end

--   פּ ﯟ   some other good icons
local kind_icons = {
  Class = '',
  Color = '',
  Constant = '',
  Constructor = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = '',
  File = '',
  Folder = '',
  Function = '',
  Interface = '',
  Keyword = '',
  Method = 'm',
  Module = '',
  Operator = '',
  Property = '',
  Reference = '',
  Snippet = '',
  Struct = '',
  Text = '',
  TypeParameter = '',
  Unit = '',
  Value = '',
  Variable = '',
}

cmp.setup {
  cmdline = {
    view = {
      entries = {
        name = 'wildmenu',
        separator = '|',
      },
    },
  },
  completion = {
    keyword_length = 1,
  },
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  enabled = function ()
    if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
      return false
    end

    return true
  end,
  experimental = {
    ghost_text = true,
    native_menu = false,
  },
  formatting = {
    -- format = lspkind.cmp_format({
    --   ellipsis_char = '...',
    --   maxwidth = 50,
    -- }),
    duplicates = {
      buffer = 1,
      luasnip = 1,
      nvim_lsp = 0,
      path = 1,
    },
    duplicates_default = 0,
    fields = { 'abbr', 'kind', 'menu' },
    format = function (entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format('%s', kind_icons[vim_item.kind])
      -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      vim_item.menu = ({
        nvim_lsp = '(LSP)',
        luasnip = '(Snippet)',
        buffer = '(Buffer)',
        path = '(Path)',
      })[entry.source.name]
      return vim_item
    end,
    max_width = 0,
  },
  mapping = {
    ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-2), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(2), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.mapping {
      i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
      c = function(fallback)
        if cmp.visible() then
          cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
        else
          fallback()
        end
      end,
    },
    ['<C-e>'] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping(function (fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      elseif jumpable(1) then
        luasnip.jump(1)
      elseif has_words_before() then
        fallback()
      else
        fallback()
      end
    end, { 'i', 's', }),
    ['<S-Tab>'] = cmp.mapping(function (fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's', }),
  },
  snippet = {
    expand = function (args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  sources = {
    {
      name = 'nvim_lsp',
      entry_filter = function(entry, ctx)
        local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
        if kind == 'Snippet' and ctx.prev_context.filetype == 'java' then
          return false
        end
        if kind == 'Text' then
          return false
        end
        return true
      end,
    },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
}

