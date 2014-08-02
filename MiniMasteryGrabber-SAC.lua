local METHOD = 1 -- 0 = extragoz, 1 = superx321
local SummonerInfo = {}

AddLoadCallback(function()
	if (METHOD == 1) then
		if (_G.AutoCarry) then
			SummonerInfo[myHero.name] = nil
			SxDownloadString('http://www.lolskill.net/game/'..GetRegion()..'/'..myHero.name, function(data) ParseLolSkill(data) end)
		else
			DelayAction(function() 
			if (_G.AutoCarry) then
				SummonerInfo[myHero.name] = nil
				SxDownloadString('http://www.lolskill.net/game/'..GetRegion()..'/'..myHero.name, function(data) ParseLolSkill(data) end)
			end, 0.5)
		end
	end
end)

_G.scriptConfig.addParamEx = _G.scriptConfig.addParam

_G.scriptConfig.addParam = function(self, pVar, pText, pType, defaultValue, a, b, c)
	if (_G.AutoCarry) then
		if (pVar == "Butcher" or pVar == "ArcaneBlade" or pVar == "Havoc" or pVar == "DoubleEdgedSword" or pVar == "DevastatingStrikes") then
			DelayAction(function(menu, pVar) OnMenuLoaded(menu, pVar) end, 1.0, {self, pVar})
		end
	end
	return self:addParamEx(pVar, pText, pType, defaultValue, a, b, c)
end

function OnMenuLoaded(menu, pVar)
	if (METHOD == 0) then
		if (MasteriesLoaded()) then
			local Masteries = GetMasteries()
			if (pVar == "Butcher") then
				local mastery = tonumber(Masteries[myHero.name][4])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.Butcher = mastery
			elseif (pVar == "ArcaneBlade") then
				local mastery = tonumber(SummonerInfo[myHero.name][19])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.ArcaneBlade = mastery
			elseif (pVar == "Havoc") then
				local mastery = tonumber(SummonerInfo[myHero.name][20])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.Havoc = mastery
			elseif (pVar == "DoubleEdgedSword") then
				local mastery = tonumber(SummonerInfo[myHero.name][1])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.DoubleEdgedSword = mastery
			elseif (pvar == "DevastatingStrikes") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][18])
				menu.DevastatingStrikes = mastery
			end
		else
			DelayAction(function(menu, pVar) OnMenuLoaded(menu, pVar) end, 0.5, {menu, pVar})
		end
	elseif (METHOD == 1) then
		if (SummonerInfo[myHero.name] ~= nil and SummonerInfo[myHero.name]["Masteries"] ~= nil and type(SummonerInfo[myHero.name]["Masteries"]) == "table") then
			if (pVar == "Butcher") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][4])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.Butcher = mastery
			elseif (pVar == "ArcaneBlade") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][19])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.ArcaneBlade = mastery
			elseif (pVar == "Havoc") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][20])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.Havoc = mastery
			elseif (pVar == "DoubleEdgedSword") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][1])
				if (mastery == 0) then
					mastery = false
				else
					mastery = true
				end
				menu.DoubleEdgedSword = mastery
			elseif (pVar == "DevastatingStrikes") then
				local mastery = tonumber(SummonerInfo[myHero.name]["Masteries"][18])
				menu.DevastatingStrikes = mastery
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