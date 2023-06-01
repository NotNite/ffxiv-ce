local io = require("io")

---@class RxiJson
---@field encode fun(tbl: table): string
---@field decode fun(str: string): table

---@class FFXIV
---@field image_base number
---@field executable string
---@field rev number
---@field cache_file string
---@field json RxiJson

if not _G.ffxiv then
  ---@type FFXIV
  _G.ffxiv = {}
end

_G.ffxiv.image_base = 0x140000000
_G.ffxiv.executable = "ffxiv_dx11.exe"
_G.ffxiv.json = require("ffxiv.json")

function ffxiv.load_cache()
  local fallback = {
    asm = {},
    sig_text = {},
    rev = _G.ffxiv.rev,
  }

  if not _G.ffxiv.cache then
    _G.ffxiv.cache = fallback
  end

  local f = io.open(_G.ffxiv.cache_file, "r")
  if not f then
    -- Reset cache
    _G.ffxiv.cache = fallback
    local f = io.open(_G.ffxiv.cache_file, "w")
    if f ~= nil then
      f:write(ffxiv.json.encode(_G.ffxiv.cache))
      f:close()
    end
  else
    -- Parse the JSON and use that
    local contents = f:read("*all")
    _G.ffxiv.cache = ffxiv.json.decode(contents)
    f:close()

    -- If the rev is different, reset the cache
    if _G.ffxiv.cache.rev ~= _G.ffxiv.rev then
      _G.ffxiv.cache = fallback
      ffxiv.save_cache()
    end
  end
end

function ffxiv.save_cache()
  if not _G.ffxiv.cache then
    ffxiv.load_cache()
  end

  local contents = ffxiv.json.encode(_G.ffxiv.cache)
  local f = io.open(_G.ffxiv.cache_file, "w")
  if f ~= nil then
    f:write(contents)
    f:close()
  end
end

function ffxiv.reset_cache()
  _G.ffxiv.cache = nil
  ffxiv.load_cache()
end

function ffxiv.init()
  _G.ffxiv.rev = ffxiv.utils.get_rev()
  _G.ffxiv.cache_file = ffxiv.ce.get_cache_file()
end

return _G.ffxiv
