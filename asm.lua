if not _G.ffxiv then
  require("ffxiv.main")
end

_G.ffxiv.asm = {}

---@param addr number
---@param instruction_count number
function ffxiv.asm.pad_nop(addr, instruction_count)
  if not instruction_count then
    instruction_count = 1
  end

  local pos = addr
  for _ = 1, instruction_count do
    local pos_str = ffxiv.addr.addr_to_ce(pos)
    local size = ffxiv.ce.get_instruction_size(pos_str)

    if not _G.ffxiv.cache.asm[pos_str] then
      local bytes = ffxiv.ce.read_bytes(pos_str, size)
      _G.ffxiv.cache.asm[pos_str] = bytes
    end

    local tbl = {}
    for x = 1, size do
      tbl[x] = 0x90
    end

    ffxiv.ce.write_bytes(pos_str, tbl)
    pos = pos + size
  end

  print("wrote " .. pos - addr .. " NOPs at " .. ffxiv.addr.addr_to_ce(addr))
  ffxiv.save_cache()
end

---@param addr number
---@param instruction_count number
function ffxiv.asm.restore_backup(addr, instruction_count)
  if not instruction_count then
    instruction_count = 1
  end

  local pos = addr
  for x = 1, instruction_count do
    local pos_str = ffxiv.addr.addr_to_ce(pos)
    local bytes = _G.ffxiv.cache.asm[pos_str]
    if bytes then
      ffxiv.ce.write_bytes(pos_str, bytes)
      pos = pos + #bytes
    else
      print("no backup found for " .. pos_str)
      break
    end
  end

  print("restored " .. pos - addr .. " bytes at " .. ffxiv.addr.addr_to_ce(addr))
end

return _G.ffxiv.asm
