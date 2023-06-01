if not _G.ffxiv then
  require("ffxiv.main")
end

_G.ffxiv.ce = {}

---@return string
function ffxiv.ce.get_cache_file()
  return getCheatEngineDir() .. "lua/ffxiv/cache.json"
end

---@param addr string A Cheat Engine style address
---@return number
function ffxiv.ce.get_instruction_size(addr)
  return getInstructionSize(addr)
end

---@param addr string | number
---@param size number
---@return number[]
function ffxiv.ce.read_bytes(addr, size)
  return readBytes(addr, size, true)
end

---@param addr string A Cheat Engine style address
---@param bytes number[]
function ffxiv.ce.write_bytes(addr, bytes)
  writeBytes(addr, bytes)
end

---@param module string
---@return number
function ffxiv.ce.get_module_size(module)
  return getModuleSize(module)
end

---@param addr string A Cheat Engine style address
function ffxiv.ce.get_name_from_address(addr)
  return getNameFromAddress(addr)
end

---@return number
function ffxiv.ce.get_opened_process_id()
  return getOpenedProcessID()
end

---@param pid number
---@return table[]
function ffxiv.ce.enum_modules(pid)
  return enumModules(pid)
end

---@param pattern string
---@return number
function ffxiv.ce.aob_scan(pattern)
  return AOBScan(pattern)
end

return _G.ffxiv.ce
