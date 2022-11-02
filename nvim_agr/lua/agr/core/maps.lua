local utils = require 'agr.core.utils'
local map = vim.keymap.set
local opts = {
  noremap = true,
  silent = true,
}
local term_opts = { silent = true }
local all = {
  '',
  '!',
  't',
}

local desc_opts = function (desc)
  local result = { desc = desc }

  for key, val in pairs(opts) do
    result[key] = val
  end

  return result
end

map('', 'Q', '<Nop>', opts)

-- Remap space as leader
map('', '<Space>', '<Nop>', opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- map('', '', '', desc_opts(''))

-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

-- Better window navigation
map('n', '<C-h>', '<C-w>h', desc_opts('Move to left window'))
map('n', '<C-j>', '<C-w>j', desc_opts('Move to right window'))
map('n', '<C-k>', '<C-w>k', desc_opts('Move to upper window'))
map('n', '<C-l>', '<C-w>l', desc_opts('Move to lower window'))

-- Resize with arrows
map('n', '<C-Up>', ':resize -2<CR>', desc_opts('Resize window up'))
map('n', '<C-Down>', ':resize +2<CR>', desc_opts('Resize window down'))
map('n', '<C-Left>', ':vertical resize -2<CR>', desc_opts('Resize window left'))
map('n', '<C-Right>', ':vertical resize +2<CR>', desc_opts('Resize window right'))

-- Navigate buffers
map('n', '<M-l>', ':BufferLineCycleNext<CR>', desc_opts('Go to next buffer'))
map('n', '<M-h>', ':BufferLineCyclePrev<CR>', desc_opts('Go to previous buffer'))
map('n', '<leader>>', ':BufferLineMoveNext<CR>', desc_opts('Move buffer right'))
map('n', '<leader><', ':BufferLineMovePrev<CR>', desc_opts('Move buffer left'))

-- File actions
map('n', '\\c', ':Bdelete<CR>', desc_opts('Close current buffer'))
map('n', '\\C', ':Bdelete!<CR>', desc_opts('Close w/force current buffer'))
map('n', '\\w', ':w!<CR>', desc_opts('Save current file'))
map('n', '\\q', ':q<CR>', desc_opts('Quit'))
map('n', '\\Q', ':q!<CR>', desc_opts('Quit w/force'))

-- Netrw file tree
-- map('n', '<leader>e', ':Lex 30<cr>', desc_opts('Toggle Netrw file tree'))

-- Escapes
map('i', 'jk', '<ESC>', desc_opts('Escape'))
map('i', 'jj', '<ESC>', desc_opts('Escape'))
map(all, '<M-o>', '<ESC>', desc_opts('Escape'))

-- Black hole deletes
map({ 'n', 'v' }, '<leader>d', '"_d', desc_opts('Black hole delete'))
map({ 'n', 'v' }, '<leader>c', '"_c', desc_opts('Black hole change'))
map({ 'n', 'v' }, '<leader>x', '"_x', desc_opts('Black hole remove'))
map({ 'n', 'v' }, '<leader>r', '"_r', desc_opts('Black hole replace'))
map({ 'n', 'v' }, '<leader>D', '"_D', desc_opts('Black hole Delete'))
map({ 'n', 'v' }, '<leader>C', '"_C', desc_opts('Black hole Change'))
map({ 'n', 'v' }, '<leader>X', '"_X', desc_opts('Black hole Remove'))
map({ 'n', 'v' }, '<leader>R', '"_R', desc_opts('Black hole Replace'))
map('v', 'p', '"_dP', desc_opts('Paste without replace in visual'))

-- Center search
map('n', 'n', 'nzz', desc_opts('Center search'))
map('n', 'N', 'Nzz', desc_opts('Center Search'))

-- Better indents
map('v', '<', '<gv', desc_opts('Indent left'))
map('v', '>', '>gv', desc_opts('Indent right'))
map('n', '<', 'v<', desc_opts('Indent left'))
map('n', '>', 'v>', desc_opts('Indent right'))

-- Cancel search highlight
map('n', '<leader>n', ':nohlsearch<Bar>:echo<CR>', desc_opts('Clear search hightlight'))
map('n', '<ESC>', ':nohlsearch<Bar>:echo<CR>', desc_opts('Clear search hightlight'))

-- Move lines
map('x', '<M-k>', ":m '<-2<CR>gv-gv", desc_opts('Move lines up'))
map('x', '<M-j>', ":m '>+1<CR>gv-gv", desc_opts('Move lines down'))
map('n', '<M-k>', ":m-2<CR>==", desc_opts('Move line up'))
map('n', '<M-j>', ":m+1<CR>==", desc_opts('Move line down'))

-- Sort lines
map('v', '<leader>o', ':sort<CR>', desc_opts('Sort lines'))

-- Better terminal navigation
map('t', '<C-h>', '<C-\\><C-N><C-w>h', term_opts)
map('t', '<C-j>', '<C-\\><C-N><C-w>j', term_opts)
map('t', '<C-k>', '<C-\\><C-N><C-w>k', term_opts)
map('t', '<C-l>', '<C-\\><C-N><C-w>l', term_opts)

-- File tree
map('n', '<leader>e', ':Neotree toggle<CR>', desc_opts('Open file tree explorer'))
map('n', '<leader>o', ':Neotree focus<CR>', desc_opts('Focus file tree explorer'))

-- Fuzzy finder
local telescope_status, _ = pcall(require, 'telescope')
if telescope_status then
  local builtins = require 'telescope.builtin'
  -- map('n', '<leader>f', function () builtins. end, desc_opts(''))
  map('n', '<leader>fw', builtins.live_grep, desc_opts('Search words'))
  map('n', '<leader>fW', function () builtins.live_grep({
    additional_args = function (args)
      return vim.list_extend(args, {
        '--hidden',
        '--no-ignore',
      })
    end,
  }) end, desc_opts('Search words in all files'))
  map('n', '<leader>ff', builtins.find_files, desc_opts('Search files'))
  map('n', '<leader>fF', function () builtins.find_files { no_ignore = true, } end, desc_opts('Search all files'))
  map('n', '<leader>fb', builtins.buffers, desc_opts('Search buffers'))
  map('n', '<leader>fh', builtins.help_tags, desc_opts('Search help'))
  map('n', '<leader>fo', builtins.oldfiles, desc_opts('Search file history'))
  map('n', '<leader>fc', builtins.grep_string, desc_opts('Search word under cursor'))
  map('n', '<leader>fr', builtins.registers, desc_opts('Search registers'))
  map('n', '<leader>fk', builtins.keymaps, desc_opts('Search keymaps'))
  map('n', '<leader>fm', builtins.commands, desc_opts('Search commands'))
  if utils.has_plugin 'aerial' then
    map('n', '<leader>ls', '<CMD>Telescope aerial<CR>', desc_opts('Search symbols'))
  end
  if utils.has_plugin 'notify' then
    map('n', '<leader>fn', '<CMD>Telescope notify<CR>', desc_opts('Search messages'))
  end
  map('n', '<leader>lG', builtins.lsp_workspace_symbols, desc_opts('Search workspace symbols'))
  map('n', '<leader>lR', builtins.lsp_references, desc_opts('Search references'))
  map('n', '<leader>lD', builtins.diagnostics, desc_opts('Search diagnostics'))
end

-- Packer
map('n', '\\ps', ':PackerSync<CR>', desc_opts('Packer sync'))
map('n', '\\pS', ':PackerStatus<CR>', desc_opts('Packer status'))
map('n', '\\pu', ':PackerUpdate<CR>', desc_opts('Packer update'))

-- Gitsigns
if utils.has_plugin 'gitsigns' then
  local blame_line = '<CMD>lua require "agr.core.utils".fix_float_ui("Gitsigns blame_line")<CR>'
  local preview_hunk = '<CMD>lua require "agr.core.utils".fix_float_ui("Gitsigns preview_hunk")<CR>'

  map('n', '<leader>gk', '<CMD>Gitsigns prev_hunk<CR>', desc_opts('Git prev hunk'))
  map('n', '<leader>gj', '<CMD>Gitsigns next_hunk<CR>', desc_opts('Git next hunk'))
  map('n', '<leader>gl', blame_line, desc_opts('Git blame line'))
  map('n', '<leader>gp', preview_hunk, desc_opts('Git preview hunk'))
  map('n', '<leader>ghr', '<CMD>Gitsigns reset_hunk<CR>', desc_opts('Git reset hunk'))
  map('n', '<leader>gbr', '<CMD>Gitsigns reset_buffer<CR>', desc_opts('Git reset buffer'))
  map('n', '<leader>ghs', '<CMD>Gitsigns stage_hunk<CR>', desc_opts('Git stage hunk'))
  map('n', '<leader>ghu', '<CMD>Gitsigns undo_stage_hunk<CR>', desc_opts('Git unstage hunk'))
  map('n', '<leader>Gd', '<CMD>Gitsigns diffthis<CR>', desc_opts('Git view diff'))
end

-- Dash
map('n', '<leader>a', ':Alpha<CR>', desc_opts('Show dashboard'))

-- LSP Installer
map('n', '\\pI', ':Mason<CR>', desc_opts('Mason installer'))
map('n', '\\pU', ':MasonToolsUpdate<CR>', desc_opts('Mason update'))
map('n', '<leader>li', ':LspInfo<CR>', desc_opts('LSP info'))

-- Symbols outline
map('n', '<leader>lS', ':AerialToggle<CR>', desc_opts('Symbols outline'))

