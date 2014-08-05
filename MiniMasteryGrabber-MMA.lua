local masteryGrabberVersion = 1.31

local METHOD = 1 -- 0 = extragoz, 1 = superx321
local SummonerInfo = {}
_OwnEnv = GetCurrentEnv().FILE_NAME:gsub(".lua", "")

AddLoadCallback(function()
	print("<font color=\"#FF0F0F\">Loaded MiniMasteryGrabber version " .. masteryGrabberVersion .. ".</font>")
	TCPU = TCPUpdater()
	TCPU:AddScript(_OwnEnv, "Script", "raw.githubusercontent.com","/germansk8ter/MiniMasteryGrabber/master/MiniMasteryGrabber-MMA.lua","/germansk8ter/MiniMasteryGrabber/master/MiniMasteryGrabber-MMA.version", "local masteryGrabberVersion =")
	if (METHOD == 1) then
		if (_G.MMA_Loaded) then
			SummonerInfo[myHero.name] = nil
			SxDownloadString('http://www.lolskill.net/game/'..GetRegion()..'/'..myHero.name, function(data) ParseLolSkill(data) end)
		else
			DelayAction(function() 
				if (_G.MMA_Loaded) then
					SummonerInfo[myHero.name] = nil
					SxDownloadString('http://www.lolskill.net/game/'..GetRegion()..'/'..myHero.name, function(data) ParseLolSkill(data) end)
				end
			end, 0.5)
		end
	end
end)

_G.scriptConfig.addParamEx = _G.scriptConfig.addParam

_G.scriptConfig.addParam = function(self, pVar, pText, pType, defaultValue, a, b, c)
	if (_G.MMA_Loaded) then
		if (pVar == "butcherMastery" or pVar == "arcaneBladeMastery" or pVar == "havocMastery") then
			DelayAction(function(menu, pVar) OnMenuLoaded(menu, pVar) end, 1.0, {self, pVar})
		end
	end
	return self:addParamEx(pVar, pText, pType, defaultValue, a, b, c)
end

function OnMenuLoaded(menu, pVar)
	if (METHOD == 0) then
		if (MasteriesLoaded()) then
			local Masteries = GetMasteries()
			if (pVar == "butcherMastery") then
				local mastery = tonumber(Masteries[myHero.name][4])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.butcherMastery = mastery
			elseif (pVar == "arcaneBladeMastery") then
				local mastery = tonumber(SummonerInfo[myHero.name][19])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.arcaneBladeMastery = mastery
			elseif (pVar == "havocMastery") then
				local mastery = tonumber(SummonerInfo[myHero.name][20])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.havocMastery = mastery
			end
		else
			DelayAction(function(menu, pVar) OnMenuLoaded(menu, pVar) end, 0.5, {menu, pVar})
		end
	elseif (METHOD == 1) then
		if (SummonerInfo[myHero.name] ~= nil and SummonerInfo[myHero.name]["Masteries"] ~= nil and type(SummonerInfo[myHero.name]["Masteries"]) == "table") then
			if (pVar == "butcherMastery") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][4])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.butcherMastery = mastery
			elseif (pVar == "arcaneBladeMastery") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][19])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.arcaneBladeMastery = mastery
			elseif (pVar == "havocMastery") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][20])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.havocMastery = mastery
			end
		else
			DelayAction(function(menu, pVar) OnMenuLoaded(menu, pVar) end, 0.5, {menu, pVar})
		end
	end
end

function SxDownloadString(source, callback, working, OldLenght)
	if not working then
		if FileExist(LIB_PATH.."SxDownloadString") then os.remove(LIB_PATH.."SxDownloadString") end
		os.executePowerShellAsync([[$webClient = New-Object System.Net.WebClient;$webClient.DownloadFile(']]..source..[[', ']]..LIB_PATH.."SxDownloadString"..[[');exit;]])
		DelayAction(function() SxDownloadString(source, callback, true, 0) end)
	else
		if FileExist(LIB_PATH.."SxDownloadString") then
			FileOpen = io.open(LIB_PATH.."SxDownloadString", "r")
			FileString = FileOpen:read("*a")
			FileOpen:close()
			if #FileString > 0 and #FileString == OldLenght then
				os.remove(LIB_PATH.."SxDownloadString")
				callback(FileString)
			else
				DelayAction(function() SxDownloadString(source, callback, true, #FileString) end, 0.2)
			end
		else
			DelayAction(function() SxDownloadString(source, callback, true, 0) end)
		end
	end
end

function ParseLolSkill(data)
	SummonerInfo = {}
	for i=1,10 do
		FindSummonerStart = string.find(data, '<div class="summonername">')
		if FindSummonerStart then
			SummonerStartCut = string.sub(data,FindSummonerStart+2)
			NextSummoner = string.find(SummonerStartCut, '<div class="summonername">')
			if NextSummoner then
				SummonerSub = string.sub(SummonerStartCut, 0, NextSummoner)
				data = string.sub(data,NextSummoner-10)
			else
				SummonerSub = SummonerStartCut
			end
			NameStart = string.find(SummonerSub, '<a href=\"summoner/')
			NameEnd = string.find(SummonerSub, '</a></div>\n')
			NameRaw = string.sub(SummonerSub, NameStart, NameEnd-1)
			_,SummonerName = string.match(NameRaw, '(\">)(.*)')
			SummonerInfo[SummonerName] = {}
			SummonerInfo[SummonerName]["Masteries"] = {}
			for _,Points in string.gmatch(SummonerSub, '(<div class="rank">)(%d)(/)(%d)(</div>)') do
				table.insert(SummonerInfo[SummonerName]["Masteries"], Points)
			end
		else
			break
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