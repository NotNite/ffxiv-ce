# ffxiv-ce

Helper library for writing Cheat Engine Lua scripts for FFXIV.

## Installation

- Open a terminal in your Cheat Engine installation folder
- `cd lua`
- `git clone https://github.com/NotNite/ffxiv-ce.git ffxiv`

## Usage

From the Lua Engine (in Memory Viewer, press Ctrl+L or navigate to Tools > Lua Engine), add this to the beginning of your scripts:

```lua
local ffxiv = require("ffxiv")()
```

You can then access `ffxiv` or `_G.ffxiv` (variable assignment not required, as it is populated into the global table).

If you wish to override some properties on load, you can pass a table to the load function (all parameters optional):

```lua
local ffxiv = require("ffxiv")({
  image_base = 42069,
  executable = "ffxiv.exe",
  rev = 42069,
  cache_file = "D:\\ffxiv-ce.json"
})
```

## Documentation

See [DOCS.md](DOCS.md).

## Known issues

- Loading the library may fail or produce weird results when not attached to FFXIV. You may want to set up Cheat Engine to auto attach to FFXIV (Edit > Settings > General Settings > Automatically attach to processes named).
- Signature scanning is incredibly slow when the cache isn't populated.

## Internals

To get easy hot reloading, `require("ffxiv")()` requires `init.lua`, which then returns a function that gets immediately called. This function clears the entries from `package.loaded`, requires all of the modules, and then calls `ffxiv.init()` when everything is loaded. Overrides are then processed (for e.g. changing cache file), and then the cache is loaded.

To be performant, some values (signature results, original ASM bytes) are stored in a cache file, marked with the current game revision to allow invalidation on game updates. This cache is stored in `<cheat engine dir>/lua/ffxiv/cache.json`.

For better typing, Cheat Engine functions are wrapped in `ce.lua`.

## Contributing

- Write in `snake_case`.
- Use [StyLua](https://github.com/JohnnyMorganz/StyLua) for formatting (Lua 5.3).
- Use [lua-language-server](https://github.com/LuaLS/lua-language-server) for type hints.
- Wrap Cheat Engine functions in `ce.lua` for type hinting.
- When adding new modules, please follow this format, so modules can be required separately if needed:

```lua
if not _G.ffxiv then
  require("ffxiv.main")
end

_G.ffxiv.module_name = {}

-- do stuff with your module here

return _G.ffxiv.module_name
```
