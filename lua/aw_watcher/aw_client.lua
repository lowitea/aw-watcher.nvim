local utils = require("aw_watcher.utils")

local ERR_NOTIFY_INTERVAL_MS = 60 * 1000 -- milliseconds
local HEARTBEAT_MIN_INTERVAL_MS = 8 * 1000 -- milliseconds

---@class Client
local Client = {}

local function make_base_url(ssl_enable, aw_host, aw_port)
    local protocol = ssl_enable and "https://" or "http://"
    return protocol .. aw_host .. ":" .. aw_port .. "/api/0"
end

---@param bucket_conf BucketConfig
---@param client_conf AWClientConfig
function Client.new(bucket_conf, client_conf)
    local base_url = make_base_url(client_conf.ssl_enable, client_conf.host, client_conf.port)
    local bucket_name = bucket_conf.name or ("aw-watcher-neovim_" .. bucket_conf.hostname)
    local bucket_url = base_url .. "/buckets/" .. bucket_name
    local heartbeat_url = bucket_url .. "/heartbeat?pulsetime=" .. client_conf.pulsetime

    ---@class Client
    local self = {
        connected = false,
        last_error_notify = nil,
        last_heartbeat = 0,
        hostname = bucket_conf.hostname,
        base_url = base_url,
        bucket_name = bucket_name,
        bucket_url = bucket_url,
        heartbeat_url = heartbeat_url,
    }
    setmetatable(self, { __index = Client })
    return self
end

---@param url string
---@param data table
function Client.__post(self, url, data)
    assert(self)
    assert(type(url) == "string")
    assert(type(data) == "table")

    local body = vim.fn.json_encode(data)

    local args = { "-s", "-f", "-X", "POST", url, "-H", "Content-Type: application/json", "--data-raw", body }

    local handle
    ---@diagnostic disable-next-line: missing-fields
    handle = vim.loop.spawn("curl", { args = args, verbatim = false }, function(code)
        self.connected = code == 0

        if handle and not handle:is_closing() then
            handle:close()
        end
    end)
end

function Client.create_bucket(self)
    assert(self)

    local body = {
        name = self.bucket_name,
        hostname = self.hostname,
        client = "neovim-watcher",
        type = "app.editor.activity",
    }
    self:__post(self.bucket_url, body)
end

function Client.heartbeat(self)
    assert(self)

    local now = vim.uv.now()

    if not self.connected then
        if not self.last_error_notify or (now - self.last_error_notify > ERR_NOTIFY_INTERVAL_MS) then
            utils.notify("Not connected. Use :AWStart to try again.", vim.log.levels.WARN)
            self.last_error_notify = now
        end
        return
    end

    if now - self.last_heartbeat < HEARTBEAT_MIN_INTERVAL_MS then
        return
    end

    self.last_heartbeat = now

    local body = {
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        duration = 0,
        data = {
            file = utils.get_filename(),
            project = vim.b.project_name,
            branch = vim.b.branch_name,
            language = utils.get_filetype(),
        },
    }

    self:__post(self.heartbeat_url, body)
end

return {
    new = Client.new,
}
