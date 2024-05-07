# himarkdown.nvim

Simple markdown highlight additions on top of TreeSitter.

This plugin is inspired by [lukas-reineke/headlines.nvim](https://github.com/lukas-reineke/headlines.nvim).

## Install

## Default Configuration

```lua
{
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
```

## TODOs

- [ ] Add documentation
- [ ] Add install section to `README.md`
- [ ] Add screenshot to `README.md`
- [ ] Clean up code
- [ ] Add version check for Neovim 9.5
- [ ] Add tests
- [ ] Add Github actions to run tests
- [ ] Add Github actions to auto format

