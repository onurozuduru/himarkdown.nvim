---@tag himarkdown.nvim
---@config { ["name"] = "INTRODUCTION" }

---@brief [[
--- Himarkdown.nvim is a plugin to decorate headers, dash, code block and quote on markdown file.
--- It adds highlights and changes markings on buffer. It depends on 'nvim-treesitter/nvim-treesitter'.
---
--- The plugin logic is as simple as possible. The 'query' and 'captures' are two keys in config that has strong relation.
--- The 'query' is a treesitter query that captures needed parts. Names of captures in the query should match with
--- the keys of 'captures'.
--- Basically this plugin goes through 'captures' then creates highlight groups named with prefix the "Himarkdown"
--- followed by the each keys of 'captures'. Afterwards it links captured elements by from 'query' to related
--- highlight definition under each key of 'captures'. If 'mark' exists then it places the mark and if 'repeat_mark' is provided,
--- it repeats the 'mark' that many times.
---@brief ]]

local M = {}

local vim_ts = require "vim.treesitter"

local prefix = "Himarkdown"
local filetype = "markdown"
local language = vim_ts.language.get_lang(filetype)
local parsed_query = nil
local augroup = vim.api.nvim_create_augroup(prefix .. "Augroup", {})

M.namespace = vim.api.nvim_create_namespace(prefix .. "Namespace")

M.enabled = true

M.config = {
  query = [[
        (atx_heading [
            (atx_h1_marker)
            (atx_h2_marker)
            (atx_h3_marker)
            (atx_h4_marker)
            (atx_h5_marker)
            (atx_h6_marker)
        ] @title)
        (thematic_break) @dash
        (fenced_code_block) @codeblock
        (block_quote_marker) @quote
        (block_quote (paragraph (inline (block_continuation) @quote)))
        (block_quote (paragraph (block_continuation) @quote))
        (block_quote (block_continuation) @quote)
    ]],
  captures = {
    title = {
      highlight = { link = "ColorColumn" },
      mark = "*",
    },
    dash = {
      highlight = { link = "LineNr" },
      mark = "-",
      repeat_mark = vim.api.nvim_win_get_width(0),
    },
    codeblock = {
      highlight = { link = "ColorColumn" },
    },
    quote = {
      highlight = { link = "LineNr" },
      mark = "|",
    },
  },
  enabled = true,
}

local parse_query = function(query)
  if language and query and query ~= "" then
    -- Query might not be proper since it is configurable
    local is_ok, parsed = pcall(vim_ts.query.parse, language, query)
    if is_ok then return parsed end
  end
  return nil
end

local register = function(buffer)
  vim.api.nvim_clear_autocmds { group = augroup, buffer = buffer }
  -- Do not register autocmds if redraw fails
  if not pcall(M.redraw) then return end

  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    buffer = buffer,
    group = augroup,
    callback = function() M.redraw() end,
  })
  vim.api.nvim_create_autocmd("InsertEnter", {
    buffer = buffer,
    group = augroup,
    callback = function() M.clear() end,
  })
end

--- Setup function to be run by user. Adds autocmd and sets up highlight groups.
---@param config table: Configuration.
---@field query string: Query to be parsed.
---@field captures table: Keys: highlight, mark, repeat_mark. Each key defines what highlight options and mark to use for the matching capture.
---@field enabled boolean: Defines if himarkdown should be enabled by default.
M.setup = function(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})
  parsed_query = parse_query(M.config.query)
  vim.api.nvim_clear_autocmds { group = augroup }
  vim.api.nvim_create_autocmd({ "FileType", "Syntax" }, {
    pattern = filetype,
    group = augroup,
    callback = function(args) register(args.buf) end,
  })

  for capture, capture_config in pairs(M.config.captures) do
    vim.api.nvim_set_hl(M.namespace, prefix .. capture, capture_config.highlight)
  end
end

--- Clear namespace.
M.clear = function()
  if not M.enabled then return end
  vim.api.nvim_buf_clear_namespace(0, M.namespace, 0, -1)
end

--- Disable or enable highlights and marks.
--- It first clears then based on enable status redraws.
M.toggle = function()
  M.clear()
  M.enabled = not M.enabled
  M.redraw()
end

--- Check and set highlights and marks on buffer by setting extmarks.
M.redraw = function()
  if not M.enabled then return end
  if not parsed_query then return end

  M.clear()
  vim.api.nvim_set_hl_ns(M.namespace)

  local is_ok, parser = pcall(vim_ts.get_parser, 0, language)
  if not is_ok then return end

  local tree = parser:parse()
  for _, match, metadata in parsed_query:iter_matches(tree[1]:root(), 0) do
    for id, node in pairs(match) do
      local capture = parsed_query.captures[id]

      local start_row, _, end_row, end_column =
        unpack(vim.tbl_extend("force", { node:range() }, (metadata[id] or {}).range or {}))

      local capture_config = M.config.captures[capture]
      local hl_group = prefix .. capture
      local opts = {
        end_col = 0,
        end_row = end_row,
        hl_group = hl_group,
        hl_eol = true,
        hl_mode = "combine",
      }

      if capture_config.mark then
        if capture_config.repeat_mark then
          opts.virt_text = { { string.rep(capture_config.mark, capture_config.repeat_mark), hl_group } }
        else
          opts.virt_text = { { string.rep(" ", end_column - 1) .. capture_config.mark, hl_group } }
        end
        opts.virt_text_pos = "overlay"
      end
      vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, 0, opts)
    end
  end
end

return M
