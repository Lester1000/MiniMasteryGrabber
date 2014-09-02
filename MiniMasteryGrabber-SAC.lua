local version = 2.0
_OwnEnv = GetCurrentEnv().FILE_NAME:gsub(".lua", "")
AddLoadCallback(
	function()
		TCPU = TCPUpdater()
		TCPU:AddScript(_OwnEnv, "Script", "raw.githubusercontent.com","/germansk8ter/MiniMasteryGrabber/master/MiniMasteryGrabber.lua","/germansk8ter/MiniMasteryGrabber/master/MiniMasteryGrabber.version", "local version =")
		GetMasteries()
	end)


local menuList = {}
local initiated = false

_G.scriptConfigEx = _G.scriptConfig
_G.scriptConfig = 
	function(header, name, parent)
		local menu = _G.scriptConfigEx(header, name, parent)
		if (menu ~= nil) then
			table.insert(menuList, menu)
		end
		return menu
	end

local initiated = 
{
	[4114] = false,
	[4154] = false,
	[4162] = false,
	[4111] = false,
	[4152] = false
}
AddTickCallback(
	function()
		local fullyInitiated =
			function()
				if (_G.MMA_Loaded) then
					return (initiated[4114] and initiated[4154] and initiated[4162])
				end
				return (initiated[4114] and initiated[4154] and initiated[4162] and initiated[4111] and initiated[4152])
			end
		if (not fullyInitiated() and _G.MasteriesDone) then
			if (_G.Masteries ~= nil and _G.Masteries[myHero.hash]) then
				for _, c in ipairs(menuList) do
					for _, v in ipairs(c._param) do
						if (v.var == "ButcherOn" or v.var == "Butcher" or v.var == "butcherMastery") then
							--4114
							c[v.var] = _G.Masteries[myHero.hash][4114]
							initiated[4114] = true
						elseif (v.var == "ArcaneBladeOn" or v.var == "ArcaneBlade" or v.var == "arcaneBladeMastery") then
							--4154
							c[v.var] = _G.Masteries[myHero.hash][4154]
							initiated[4154] = true
						elseif (v.var == "HavocOn" or v.var == "Havoc" or v.var == "havocMastery") then
							--4162
							c[v.var] = _G.Masteries[myHero.hash][4162]
							initiated[4162] = true
						elseif (v.var == "DEdgedSwordOn" or v.var == "DoubleEdgedSword") then
							--4111
							c[v.var] = _G.Masteries[myHero.hash][4111]
							initiated[4111] = true
						elseif (v.var == "DevastatingStrikes" or v.var == "DevastatingStrike") then
							--4152
							c[v.var] = _G.Masteries[myHero.hash][4152]
							initiated[4152] = true
						end
					end
				end
			end
		end
	end)

class "GetMasteries"
function GetMasteries:__init(AllChamps)
	if not _G.Masteries then
		self.ChampTable = {}
		for z = 1, heroManager.iCount, 1 do
			local hero = heroManager:getHero(z)
			if not hero.isAI then
				table.insert(self.ChampTable, hero)
			end
		end
		self.LuaSocket = require("socket")
		self.MasterySocket = self.LuaSocket.connect("www.sx-bol.eu", 80)
		self.RandomChamp = self.ChampTable[math.random(#self.ChampTable)]
		if AllChamps then self.AllChamps = '/1' else self.AllChamps = '/0' end
		self.MasterySocket:send("GET /BoL/GetMastery/"..GetRegion().."/"..self:url_encode(myHero.name).."/"..self:url_encode(self.RandomChamp.name)..self.AllChamps.." HTTP/1.0\r\n\r\n")
		self.MasterySocket:settimeout(0, 'b')
		self.MasterySocket:settimeout(99999999, 't')
		self.MasterySocket:setoption('keepalive', true)
		_G.Masteries = {}
		AddTickCallback(function() self:Collect() end)
	end
end

function GetMasteries:url_encode(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w %-%_%.%~])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
  return str
end

function GetMasteries:Collect()
	self.MasteryReceive, self.MasteryStatus = self.MasterySocket:receive('*a')
	if self.MasteryStatus ~= 'timeout' and self.MasteryReceive ~= nil and not _G.MasteriesDone then
		self.MasteryRaw = string.match(self.MasteryReceive, '<pre>(.*)</pre>')
		if self.MasteryRaw then
			self.MasteriesRaw = JSON:decode(self.MasteryRaw)
			if self.AllChamps == '/1' and #self.ChampTable > 1 then
				for _,MasteryTable in pairs(self.MasteriesRaw) do
					for z = 1, #self.ChampTable, 1 do
						local hero = self.ChampTable[z]
						if hero.name == MasteryTable['name'] then
							_G.Masteries[hero.hash] = {}
							for index, info in pairs(MasteryTable) do
								if info.sli and info.r then
									_G.Masteries[hero.hash][info.sli] = info.r
								else
									_G.Masteries[hero.hash][index] = info
								end
							end
							break
						end
					end
				end
				_G.MasteriesDone = true
			else
				_G.Masteries[myHero.hash] = {}
				for _,MasteryTable in pairs(self.MasteriesRaw) do
					if MasteryTable.sli and MasteryTable.r then
						_G.Masteries[myHero.hash][MasteryTable.sli] = MasteryTable.r
					else
						_G.Masteries[myHero.hash][_] = MasteryTable
					end
				end
				_G.MasteriesDone = true
			end
		else
			_G.MasteriesDone = true
		end
	end
end


------------------------
------ TCPUpdater ------
------------------------
class "TCPUpdater"
function TCPUpdater:__init()
	_G.TCPUpdates = {}
	_G.TCPUpdaterLoaded = true
	self.AutoUpdates = {}
	self.LuaSocket = require("socket")
	AddTickCallback(function() self:TCPUpdate() end)
end

function TCPUpdater:TCPUpdate()
	for i=1,#self.AutoUpdates do
		if not self.AutoUpdates[i]["ScriptPath"] then
			self.AutoUpdates[i]["ScriptPath"] = self:GetScriptPath(self.AutoUpdates[i])
		end

		if self.AutoUpdates[i]["ScriptPath"] and not self.AutoUpdates[i]["LocalVersion"] then
			self.AutoUpdates[i]["LocalVersion"] = self:GetLocalVersion(self.AutoUpdates[i])
		end
		if not self.AutoUpdates[i]["ServerVersion"] and self.AutoUpdates[i]["ScriptPath"] and self.AutoUpdates[i]["LocalVersion"] then
			self.AutoUpdates[i]["ServerVersion"] = self:GetOnlineVersion(self.AutoUpdates[i])
		end

		if self.AutoUpdates[i]["ServerVersion"] and self.AutoUpdates[i]["LocalVersion"] and self.AutoUpdates[i]["ScriptPath"] and not _G.TCPUpdates[self.AutoUpdates[i]["Name"]] then
			if self.AutoUpdates[i]["ServerVersion"] > self.AutoUpdates[i]["LocalVersion"] then
				print("<font color=\"#F0Ff8d\"><b>" .. self.AutoUpdates[i]["Name"] .. ":</b></font> <font color=\"#FF0F0F\">Updating ".. self.AutoUpdates[i]["Name"].." to Version "..self.AutoUpdates[i]["ServerVersion"].."</font>")
				self:DownloadUpdate(self.AutoUpdates[i])
			else
				self:LoadScript(self.AutoUpdates[i])
			end
		end
	end
end

function TCPUpdater:LoadScript(TCPScript)
	if TCPScript["ScriptRequire"] then
		if TCPScript["ScriptRequire"] == "VIP" then
			if VIP_USER then
				loadfile(TCPScript["ScriptPath"])()
			end
		else
			loadfile(TCPScript["ScriptPath"])()
		end
	end
	_G.TCPUpdates[TCPScript["Name"]] = true
end

function TCPUpdater:GetScriptPath(TCPScript)
	if TCPScript["Type"] == "Lib" then
		return LIB_PATH..TCPScript["Name"]..".lua"
	else
		return SCRIPT_PATH..TCPScript["Name"]..".lua"
	end
end

function TCPUpdater:GetOnlineVersion(TCPScript)
	if not TCPScript["VersionSocket"] then
		TCPScript["VersionSocket"] = self.LuaSocket.connect("sx-bol.eu", 80)
		TCPScript["VersionSocket"]:send("GET /BoL/TCPUpdater/GetScript.php?script="..TCPScript["Host"]..TCPScript["VersionLink"].."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
	end

	if TCPScript["VersionSocket"] then
		TCPScript["VersionSocket"]:settimeout(0)
		TCPScript["VersionReceive"], TCPScript["VersionStatus"] = TCPScript["VersionSocket"]:receive('*a')
	end

	if TCPScript["VersionSocket"] and TCPScript["VersionStatus"] ~= 'timeout' then
		if TCPScript["VersionReceive"] == nil then
			return 0
		else
			return tonumber(string.sub(TCPScript["VersionReceive"], string.find(TCPScript["VersionReceive"], "<bols".."cript>")+11, string.find(TCPScript["VersionReceive"], "</bols".."cript>")-1))
		end
	end
end

function TCPUpdater:GetLocalVersion(TCPScript)
	if FileExist(TCPScript["ScriptPath"]) then
		self.FileOpen = io.open(TCPScript["ScriptPath"], "r")
		self.FileString = self.FileOpen:read("*a")
		self.FileOpen:close()
		VersionPos = self.FileString:find(TCPScript["VersionSearchString"])
		if VersionPos ~= nil then
			self.VersionString = string.sub(self.FileString, VersionPos + string.len(TCPScript["VersionSearchString"]) + 1, VersionPos + string.len(TCPScript["VersionSearchString"]) + 11)
			self.VersionSave = tonumber(string.match(self.VersionString, "%d *.*%d"))
		end
		if self.VersionSave == 2.431 then self.VersionSave = math.huge end -- VPred 2.431
		if self.VersionSave == nil then self.VersionSave = 0 end
	else
		self.VersionSave = 0
	end
	return self.VersionSave
end

function TCPUpdater:DownloadUpdate(TCPScript)
	if not TCPScript["ScriptSocket"] then
		TCPScript["ScriptSocket"] = self.LuaSocket.connect("sx-bol.eu", 80)
		TCPScript["ScriptSocket"]:send("GET /BoL/TCPUpdater/GetScript.php?script="..TCPScript["Host"]..TCPScript["ScriptLink"].."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
	end

	if TCPScript["ScriptSocket"] then
		TCPScript["ScriptReceive"], TCPScript["ScriptStatus"] = TCPScript["ScriptSocket"]:receive('*a')
	end

	if TCPScript["ScriptSocket"] and TCPScript["ScriptStatus"] ~= 'timeout' then
		if TCPScript["ScriptReceive"] == nil then
			print("Error in Loading Module: "..TCPScript["Name"])
		else
			self.FileOpen = io.open(TCPScript["ScriptPath"], "w+")
			self.FileOpen:write(string.sub(TCPScript["ScriptReceive"], string.find(TCPScript["ScriptReceive"], "<bols".."cript>")+11, string.find(TCPScript["ScriptReceive"], "</bols".."cript>")-1))
			self.FileOpen:close()
			print("<font color=\"#FF0F0F\">Updated script. Please double F9.</font>")
			self:LoadScript(TCPScript)
		end
	end
end

function TCPUpdater:AddScript(Name, Type, Host, ScriptLink, VersionLink, VersionSearchString, ScriptRequire, ServerVersion)
	table.insert(self.AutoUpdates, {["Name"] = Name, ["Type"] = Type, ["Host"] = Host, ["ScriptLink"] = ScriptLink, ["VersionLink"] = VersionLink, ["VersionSearchString"] = VersionSearchString, ["ScriptRequire"] = ScriptRequire, ["ServerVersion"] = ServerVersion})
	_G.TCPUpdates[Name] = false
end