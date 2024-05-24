# himarkdown.nvim

Simple markdown highlight additions on top of TreeSitter.

Himarkdown.nvim is a plugin to decorate headers, dash, code block and quote on markdown file.
It changes markings and adds highlights on buffer.

![himarkdown](https://github.com/onurozuduru/himarkdown.nvim/assets/2547436/e9db423a-cfce-4095-9f71-e69671545088)

## Requirements

- [Neovim 0.9.5](https://github.com/neovim/neovim/releases/tag/v0.9.5) or higher.
- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter).
- Be sure `markdown` and `markdown_inline` are installed:
```
:TSInstall markdown markdown_inline
```

## Install
Call `setup` function.

```lua
require('himarkdown').setup()
```

OR with configuration (below is the default configuration):

```lua
require('himarkdown').setup({
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
})
```

### Lazy

```lua
{
  "onurozuduru/himarkdown.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = true
}
```

#### Example with opts

```lua
{
  "onurozuduru/himarkdown.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  opts = {
    captures = {
      title = { mark = "*" },
      quote = { mark = "|" },
      dash = { mark = "-" },
    },
  },
}
```

#### Example keymap

```lua
{
  "onurozuduru/himarkdown.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  lazy = false,
  keys = {
    { "<Leader>m", function() require("himarkdown").toggle() end, desc = "Toggle HiMarkdown" },
  },
}
```

## TODOs

- [x] Add documentation
- [x] Add install section to `README.md`
- [x] Add screenshot to `README.md`
- [x] Clean up code
- [x] Add version check for Neovim 0.9.5
- [ ] Add tests
- [ ] Add Github actions to run tests
- [ ] Add Github actions to auto format

## Similar Projects

- [lukas-reineke/headlines.nvim](https://github.com/lukas-reineke/headlines.nvim): More complete plugin and supports other filetypes in addition to markdown.
