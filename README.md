# ⌛ ActivityWatch NeoVim Watcher

![ActivityWatch](aw_banner.png)

A neovim watcher for [ActivityWatch](https://activitywatch.net/) time tracker. Fully configurable and written entirely in lua. Compatible with modern package managers.

## ✨ Tracks

- 🪵 Selected git branch
- 📝 Edited files
- 💻 Programming language of a file
- 💼 Your projects

## 🔥 Status

The project is ready to be used and actively maintained.

## ⚡️ Requirements

- Neovim >= 0.9.0
- curl

## 📦 Installation

Install the plugin with your preferred package manager.

Example for [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- lazy.nvim
{
    "lowitea/aw-watcher.nvim",
    opts = {  -- required, but can be empty table: {}
        -- add any options here
        -- for example:
        aw_server = {
            host = "127.0.0.1",
            port = 5600,
        },
    },
}
```

Example for [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
-- packer_init.lua
    use { "lowitea/aw-watcher.nvim",
      config = function()
        require("aw_watcher").setup({
            -- required, but can be empty table: {}
            -- add any options here
            -- for example:
            aw_server = {
                host = "127.0.0.1",
                port = 5600,
            },
        })
      end,
    }

```

## ⚙️ Configuration

**aw-watcher.nvim** comes with the following defaults:

```lua
{
    bucket = {
        hostname = nil, -- by default hostname of computer
        name = nil, -- by default "aw-watcher-neovim_" .. bucket.hostname
    },
    aw_server = {
        host = "127.0.0.1",
        port = 5600,
        ssl_enable = false,
        pulsetime = 30,
    },
}
```

## 📖 Analogues

- [aw-watcher-vim](https://github.com/ActivityWatch/aw-watcher-vim) - a plugin for Vim that helped me a lot.
