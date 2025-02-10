local aw_client = require("aw_watcher.aw_client")
local utils = require("aw_watcher.utils")
local config = require("aw_watcher.config")

local START_HEARTBEAT_DELAY_MS = 1000

local aw -- initialized aw client

local function heartbeat()
    if not aw then
        utils.notify("Wasn't initialized. Check your spec or run setup() function.", vim.log.levels.WARN)
        return
    end
    aw:heartbeat()
end

local function bucket_start()
    if not aw then
        utils.notify("Wasn't initialized. Check your spec or run setup() function.", vim.log.levels.WARN)
        return
    end
    aw:create_bucket()
end

local function connect_status()
    if not aw then
        utils.notify("Wasn't initialized. Check your spec or run setup() function.", vim.log.levels.WARN)
        return
    end
    utils.notify(aw.connected and "Connected" or "Disconnected", vim.log.levels.INFO)
end

local function create_autocommands()
    local augroup = vim.api.nvim_create_augroup("AcitivityWatch", { clear = true })

    local function make_heartbeat_cmd()
        vim.api.nvim_create_autocmd(
            { "CursorMoved", "BufLeave", "BufEnter", "CursorMovedI", "CmdlineEnter", "CmdlineChanged" },
            { group = augroup, callback = heartbeat }
        )
    end

    vim.defer_fn(make_heartbeat_cmd, START_HEARTBEAT_DELAY_MS)

    vim.api.nvim_create_autocmd("VimEnter", { group = augroup, callback = bucket_start })

    vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "FocusGained" }, {
        group = augroup,
        callback = function()
            utils.set_branch_name()
            utils.set_project_name()
        end,
    })
end

local function setup(opts)
    local cfg = config.new(opts)

    aw = aw_client.new(cfg.bucket, cfg.aw_server)
    aw:create_bucket()

    create_autocommands()
end

return {
    setup = setup,

    -- API
    heartbeat = heartbeat,
    bucket_start = bucket_start,
    connect_status = connect_status,
}
