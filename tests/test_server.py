"""Run: python -m pip install lupa && python tests/test_server.py"""
from pathlib import Path
from lupa.lua54 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
for path in ROOT.rglob("*.lua"):
    lua.execute("assert(load(...))", path.read_text(), str(path))

lua.execute('''
local vector = {}
vector.__sub = function(a, b) return setmetatable({x=a.x-b.x,y=a.y-b.y,z=a.z-b.z}, vector) end
vector.__len = function(a) return math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z) end
function vec3(x,y,z) return setmetatable({x=x,y=y,z=z}, vector) end
callbacks, events = {}, {}
lib = { callback = { register = function(name, fn) callbacks[name] = fn end } }
function RegisterNetEvent(name, fn) events[name] = fn end
function AddEventHandler(name, fn) events[name] = fn end
clock, health, bucket, inventory, balance, payMode = 1000, 100, 0, 10, 0, "ok"
player = {
 getAccount = function() return accountMissing ~= true and {} or nil end,
 addAccountMoney = function(account, value)
   if payMode == "false" then return false end
   if payMode == "error" then error("payment unavailable") end
   balance = balance + value
   if payMode == "nil" then return nil end
   return true
 end
}
exports = {
 es_extended = { getSharedObject = function() return {GetPlayerFromId=function() return player end} end },
 ox_inventory = {
  GetItemCount = function(_,src,item) return item == "empty_bottle_beer" and inventory or 0 end,
  RemoveItem = function(_,src,item,count) if inventory < count then return false end inventory=inventory-count return true end,
  AddItem = function(_,src,item,count) inventory=inventory+count return true end
 }
}
function GetGameTimer() return clock end
function GetPlayerPed() return 1 end
function GetEntityHealth() return health end
function GetEntityCoords() return position end
function GetPlayerRoutingBucket() return bucket end
''')
lua.execute((ROOT / "config.lua").read_text())
lua.execute("position = Config.Locations[1].coords")
lua.execute((ROOT / "server/server.lua").read_text())
lua.execute('''
local begin = callbacks["bos_recycling:begin"]
local finish = callbacks["bos_recycling:finish"]
local function ticket()
 clock = clock + 1000
 local t = begin(1,1)
 assert(t.ok)
 return t
end
local t = ticket()
clock = clock + Config.Duration
assert(finish(1,t.token).ok)
assert(inventory == 9 and math.abs(balance - 0.08) < 0.000001)
assert(not finish(1,t.token).ok and inventory == 9) -- replay
local t = ticket()
assert(not finish(1,t.token).ok) -- too early
clock = clock + Config.Duration
assert(not finish(1,t.token).ok) -- early attempt consumed
local t = ticket()
clock = clock + Config.Duration
position = vec3(0,0,0)
assert(not finish(1,t.token).ok)
clock = clock + 1000
assert(not begin(1,1).ok) -- distant begin
position = Config.Locations[1].coords
local t = ticket()
clock = clock + Config.Duration
bucket = 1
assert(not finish(1,t.token).ok)
bucket = 0
for _, mode in ipairs({"false", "error"}) do
 local t = ticket()
 clock = clock + Config.Duration
 payMode = mode
 assert(not finish(1,t.token).ok and inventory == 9)
end
payMode = "nil" -- legacy ESX void success
local t = ticket()
clock = clock + Config.Duration
assert(finish(1,t.token).ok and inventory == 8)
assert(math.abs(balance - 0.16) < 0.000001)
payMode = "ok"
local t = ticket()
clock = clock + Config.Duration
inventory = 0
assert(not finish(1,t.token).ok and math.abs(balance - 0.16) < 0.000001)
clock = clock + 1000
assert(begin(1,1).code == "empty")
inventory = 5
local t = ticket()
source = 1
events["bos_recycling:cancel"](t.token)
clock = clock + Config.Duration
assert(not finish(1,t.token).ok)
local t = ticket()
clock = clock + Config.Duration + 30001
assert(not finish(1,t.token).ok)
local t = ticket()
clock = clock + Config.Duration
health = 0
assert(not finish(1,t.token).ok)
health = 100
local t = ticket()
clock = clock + Config.Duration
accountMissing = true
assert(not finish(1,t.token).ok and inventory == 5)
accountMissing = false
local t = ticket()
events["playerDropped"]()
clock = clock + Config.Duration
assert(not finish(1,t.token).ok)
clock = clock + 1000
assert(not begin(1,"1").ok)
clock = clock + 1000
assert(not begin(1,999).ok)
assert(events["bos_recycling:server:recycleEinzeln"] == nil)
''')
print("PASS: Lua syntax, cents payout, replay, timing, distance, bucket, refunds, legacy ESX, inventory, cancel, expiry, death, account, disconnect, input validation")
lua.execute('''
for _, cents in ipairs({8,25,15}) do
 Config.RecycleItems[1].reward = cents
 clock = clock + 1000
 inventory = 1
 local before = balance
 local t = callbacks["bos_recycling:begin"](1,1)
 clock = clock + Config.Duration
 assert(callbacks["bos_recycling:finish"](1,t.token).ok)
 assert(math.abs(balance - before - cents / 100) < 0.000001)
end
''')
version_source = (ROOT / "server/version.lua").read_text()
for remote, expected in [("1.0.0", "no newer"), ("0.9.9", "no newer"), ("1.0.1", "Update available"), ("1.10.0", "Update available"), ("bad", "Invalid")]:
    runtime = LuaRuntime(unpack_returned_tuples=True)
    runtime.globals().remote = remote
    runtime.execute('''
    Config = { CheckForUpdates = true }
    function CreateThread(fn) fn() end
    function Wait() end
    function GetCurrentResourceName() return "bos_bottlerecycler" end
    function GetResourceMetadata() return "1.0.0" end
    json = { decode = function() return {version = remote} end }
    function PerformHttpRequest(url, cb) cb(200, "response") end
    function print(value) output = value end
    ''')
    runtime.execute(version_source)
    assert expected in runtime.globals().output
print("PASS: all three original cent amounts and numeric version comparison")
