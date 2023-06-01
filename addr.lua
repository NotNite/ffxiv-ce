if not _G.ffxiv then
  require("ffxiv.main")
end

_G.ffxiv.addr = {}

---@param addr number
---@return string
function ffxiv.addr.addr_to_ce(addr)
  local ffxiv_addr = ffxiv.utils.get_alloc_base()
  local size = ffxiv.ce.get_module_size(ffxiv.executable)
  local unk = 0x100000000

  -- If we're below the module size, it's likely we're using a shorthand
  if addr < size then
    return "ffxiv_dx11.exe+" .. string.format("%X", addr)
  end

  -- Handle base
  if addr - ffxiv.image_base < size then
    return "ffxiv_dx11.exe+" .. string.format("%X", addr - ffxiv.image_base)
  end

  -- Try scanning FFXIV
  if addr >= ffxiv_addr + unk and addr <= ffxiv_addr + size + unk then
    -- We got it
    return "ffxiv_dx11.exe+" .. string.format("%X", addr - ffxiv_addr - unk)
  end

  -- Try scanning all modules
  local modules = ffxiv.addr.get_modules()
  for name, module in pairs(modules) do
    if ffxiv.addr.resides_in_range(addr, module.base, module.size) then
      return name .. "+" .. string.format("%X", addr - module.base)
    end
  end

  -- Finally, try the (worse) CE function
  return ffxiv.ce.get_name_from_address(string.format("%X", addr))
end

---@param ce_addr string
---@return number | nil
function ffxiv.addr.ce_to_addr(ce_addr)
  local addr = tonumber(string.match(ce_addr, "%+(%x+)"), 16)
  if addr then
    return addr + ffxiv.image_base
  end

  return nil
end

---@class Module
---@field name string
---@field base number
---@field size number
---@return Module[]
function ffxiv.addr.get_modules()
  local pid = ffxiv.ce.get_opened_process_id()
  local ce_modules = ffxiv.ce.enum_modules(pid)
  local modules = {}

  for i = 1, #ce_modules do
    local ce_module = ce_modules[i]
    local module = {
      name = ce_module.Name,
      base = ce_module.Address,
      size = ffxiv.ce.get_module_size(ce_module.Name) or 0,
    }
    modules[ce_module.Name] = module
  end

  return modules
end

---@param name string
---@return Module | nil
function ffxiv.addr.get_module_by_name(name)
  local modules = ffxiv.addr.get_modules()

  for module_name, module in pairs(modules) do
    if module_name == name then
      return module
    end
  end

  return nil
end

---@param addr number
---@param start number
---@param size number
---@return boolean
function ffxiv.addr.resides_in_range(addr, start, size)
  return addr >= start and addr <= start + size
end

---@param addr number
---@return number
local function handle_jmp_call(addr)
  local target = ffxiv.ce.read_bytes(addr + 1, 4)

  -- Compose the table into an int32
  local target_addr = 0
  for i = 1, 4 do
    target_addr = target_addr + target[i] * (256 ^ (i - 1))
  end

  return addr + 5 + target_addr
end

---@param sig string
---@param matches number[]
---@param cache_name string
---@return number | nil
local function handle_sig_result(sig, matches, cache_name)
  if #matches == 0 then
    print("warning: no matches for sig: '" .. sig .. "'")
    return nil
  end
  if #matches > 1 then
    print("warning: multiple matches for sig: '" .. sig .. "'")
  end

  table.sort(matches)
  local match = matches[1]

  local first_byte = ffxiv.ce.read_bytes(match, 1)[1]
  if first_byte == 0xE8 or first_byte == 0xE9 then
    match = handle_jmp_call(match)
  end

  _G.ffxiv.cache[cache_name][sig] = ffxiv.addr.addr_to_ce(match)
  ffxiv.save_cache()
  return match
end

---@param sig string
---@return number | nil
function ffxiv.addr.scan_text(sig)
  if _G.ffxiv.cache.sig_text[sig] then
    local cached = _G.ffxiv.cache.sig_text[sig]
    return ffxiv.addr.ce_to_addr(cached)
  end

  local ffxiv_module = ffxiv.addr.get_module_by_name(ffxiv.executable)
  ---@cast ffxiv_module table

  -- AOBScan returns a Stringlist, so we turn it into an array of addrs
  local addr = ffxiv.ce.aob_scan(sig)
  local count = addr.Count
  local matches = {}
  for i = 1, count do
    local addr_str = addr.String[i - 1]
    local addr_num = tonumber(addr_str, 16)

    -- We're only scanning .text
    if ffxiv.addr.resides_in_range(addr_num, ffxiv_module.base, ffxiv_module.size) then
      table.insert(matches, addr_num)
    end
  end

  return handle_sig_result(sig, matches, "sig_text")
end

return _G.ffxiv.addr
