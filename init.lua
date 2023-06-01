---@class FFXIVOverrides
---@field image_base number
---@field executable string
---@field rev number
---@field cache_file string

---@param overrides FFXIVOverrides | nil
return function(overrides)
  local modules = {
    "ffxiv.main",
    "ffxiv.utils",
    "ffxiv.addr",
    "ffxiv.asm",
    "ffxiv.ce",
  }

  -- Clear the modules out of the cache
  package.loaded["ffxiv"] = nil
  for _, module in pairs(modules) do
    package.loaded[module] = nil
  end

  -- Load all modules
  for _, module in pairs(modules) do
    require(module)
  end

  -- Init needs to be called after all the modules are loaded
  ffxiv.init()

  -- Process overrides
  if overrides ~= nil then
    _G.ffxiv.image_base = overrides.image_base or _G.ffxiv.image_base
    _G.ffxiv.executable = overrides.executable or _G.ffxiv.executable
    _G.ffxiv.rev = overrides.rev or _G.ffxiv.rev
    _G.ffxiv.cache_file = overrides.cache_file or _G.ffxiv.cache_file
  end

  -- Initialize the cache *after* overrides are processed
  ffxiv.load_cache()

  return _G.ffxiv
end
