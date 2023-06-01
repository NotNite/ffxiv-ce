if not _G.ffxiv then
  require("ffxiv.main")
end

_G.ffxiv.utils = {}

---@return number
function ffxiv.utils.get_alloc_base()
  local addr = getAddress(ffxiv.executable)
  return addr
end

---@return number
function ffxiv.utils.get_rev()
  -- /*****ff14******
  local search = "2F2A2A2A2A2A666631342A2A2A2A2A2A"
  local search_start = ffxiv.utils.get_alloc_base()
  local search_end = search_start + getModuleSize(ffxiv.executable)

  local scan = createMemScan()
  local foundlist = createFoundList(scan)

  scan.firstScan(
    soExactValue,
    vtByteArray,
    rtTruncated,
    search,
    nil,
    search_start,
    search_end,
    nil,
    fsmNotAligned,
    "0",
    true,
    false,
    false,
    true
  )
  scan.waitTillDone()
  foundlist.initialize()

  for i = 0, foundlist.Count do
    local addr = foundlist.getAddress(i)
    local revstr = readString(addr, 256)

    -- search for "rev"
    if string.find(revstr, "rev") then
      -- cut after the search
      local len = string.len(search) / 2
      -- and cut before the underscore
      local underscore = string.find(revstr, "_")
      local rev = string.sub(revstr, len + 1 + 3, underscore - 1)
      return tonumber(rev) or 0
    end
  end

  -- This shouldn't ever happen?
  return 0
end

return _G.ffxiv.utils
