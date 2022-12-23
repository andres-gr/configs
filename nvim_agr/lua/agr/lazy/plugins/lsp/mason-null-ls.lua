local M = {
  'jayp0521/mason-null-ls.nvim',
}

M.config = function ()
  local mason_nls = require 'mason-null-ls'

  mason_nls.setup {}

  mason_nls.setup_handlers {
    function (server)
      require 'agr.core.utils'.null_ls_register(server)
    end,
  }
end

return M
