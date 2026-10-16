local here = arg[0]:match("^(.*)/[^/]*$") or "."
local Stub = dofile(here .. "/wowstub.lua")
local ns = Stub.loadAddon(here .. "/../Goldbook")
Stub.fire("ADDON_LOADED", "Goldbook")
Stub.fire("PLAYER_LOGIN")
Stub.fire("AUCTION_HOUSE_SHOW")
local AH, rows, complete = C_AuctionHouse, {}, false
AH.HasFullItemSearchResults = function() return complete end
AH.GetNumItemSearchResults = function() return #rows end
AH.GetItemSearchResultInfo = function(_, i) return rows[i] end
AH.HasFullCommoditySearchResults = function() return complete end
AH.GetNumCommoditySearchResults = function() return #rows end
AH.GetCommoditySearchResultInfo = function(_, i) return rows[i] end
local key = { itemID = 2589, itemSuffix = 0 }
local function search()
  Stub.fire("ITEM_SEARCH_RESULTS_UPDATED", key)
  Stub.advance(1.1)
end
rows = {
  { quantity = 60, buyoutAmount = 6000, owners = { "Alice" }, totalNumberOfOwners = 1 },
  { quantity = 10, buyoutAmount = 1200, owners = { "Bob" }, totalNumberOfOwners = 1 },
  { quantity = 20, buyoutAmount = 2600, owners = { "Alice", "Carol" }, totalNumberOfOwners = 2 },
  { quantity = 10, buyoutAmount = 1400, owners = {}, totalNumberOfOwners = 2 },
  { quantity = 4, buyoutAmount = 0, owners = { "BidOnly" }, totalNumberOfOwners = 1 },
}
search()
assert(next(ns.db.sellerScans) == nil, "partial search must not replace a complete market snapshot")
complete = true
search()
local saved = ns.db.sellerScans["Faramon|Horde|2589"]
assert(#saved.offers == 4 and saved.offers[1].unitPrice == 100, "only buyout stock is recorded at per-unit prices")
assert(saved.offers[3].totalOwners == 2 and #saved.offers[4].owners == 0, "shared and unknown ownership must be preserved")
search()
assert(#ns.db.sellerScans["Faramon|Horde|2589"].offers == 4, "repeated events replace stock rather than add it")
rows = { { quantity = 8, unitPrice = 300, owners = { "player" }, totalNumberOfOwners = 1 } }
Stub.fire("COMMODITY_SEARCH_RESULTS_UPDATED", 7070)
Stub.advance(1.1)
assert(ns.db.sellerScans["Faramon|Horde|7070"].offers[1].owners[1] == "Sultan-Faramon", "own stock must use the character name")
rows, key = {}, { itemID = 9999 }
search()
assert(#ns.db.sellerScans["Faramon|Horde|9999"].offers == 0, "an empty complete search clears old stock")
rows, key = { { quantity = 1, buyoutAmount = 25, owners = { "SuffixSeller" }, totalNumberOfOwners = 1 } }, { itemID = 9775, itemSuffix = 584 }
search()
assert(ns.db.sellerScans["Faramon|Horde|9775:584"], "random suffix variants must stay separate")
Stub.fire("AUCTION_HOUSE_CLOSED")
rows = {}
search()
assert(#ns.db.sellerScans["Faramon|Horde|9775:584"].offers == 1, "late events after closing must be ignored")

local function serialize(value)
  if type(value) == "string" then return string.format("%q", value) end
  if type(value) ~= "table" then return tostring(value) end
  local out = { "{" }
  for _, v in ipairs(value) do
    out[#out + 1] = serialize(v) .. ","
  end
  for k, v in pairs(value) do
    if type(k) ~= "number" then
      out[#out + 1] = "[" .. serialize(k) .. "]=" .. serialize(v) .. ","
    end
  end
  out[#out + 1] = "}"
  return table.concat(out)
end
if arg[1] then
  local out = assert(io.open(arg[1], "w"))
  out:write("GoldbookDB = ", serialize({ items = {}, scans = {}, sellerScans = ns.db.sellerScans }), "\n")
  out:close()
end
io.write("Seller capture passed: complete searches, per-unit prices, shared owners, own stock, empty results and suffixes.\n")
