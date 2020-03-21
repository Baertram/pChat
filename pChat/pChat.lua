--=======================================================================================================================================
--Known problems/bugs:
--Last updated: 2020-02-28
--Total number: 2
------------------------------------------------------------------------------------------------------------------------
--#2	2020-02-28 Baetram, bug: New selection for @accountName/character chat prefix will only show /charactername (@accountName is missing) during whispers,
--		if clicked on a character in the chat to whisper him/her
------------------------------------------------------------------------------------------------------------------------
--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn info
--======================================================================================================================
-- Common
local ADDON_NAME	= "pChat"

--======================================================================================================================
--pChat Variables--
--======================================================================================================================
pChat.tabNames = {}

-- pChatData will receive variables and objects.
local pChatData = {}
-- Logged in char name
pChatData.localPlayer = GetUnitName("player")

--LibDebugLogger objects
local logger
local subloggerVerbose

--======================================================================================================================
--Constants
--======================================================================================================================
--Chat Tab template names
local constTabNameTemplate = "ZO_ChatWindowTabTemplate"

-- Used for pChat LinkHandling
local PCHAT_LINK = "p"
local PCHAT_URL_CHAN = 97
local PCHAT_CHANNEL_SAY = 98
local PCHAT_CHANNEL_NONE = 99

--[[
PCHAT_LINK format : ZO_LinkHandler_CreateLink(message, nil, PCHAT_LINK, data)
message = message to display, nil (ignored by ZO_LinkHandler_CreateLink), PCHAT_LINK : declaration
data : strings separated by ":"
1st arg is chancode like CHAT_CHANNEL_GUILD_1
]]--

pChatData.chatCategories = {
	CHAT_CATEGORY_SAY,
	CHAT_CATEGORY_YELL,
	CHAT_CATEGORY_WHISPER_INCOMING,
	CHAT_CATEGORY_WHISPER_OUTGOING,
	CHAT_CATEGORY_ZONE,
	CHAT_CATEGORY_PARTY,
	CHAT_CATEGORY_EMOTE,
	CHAT_CATEGORY_SYSTEM,
	CHAT_CATEGORY_GUILD_1,
	CHAT_CATEGORY_GUILD_2,
	CHAT_CATEGORY_GUILD_3,
	CHAT_CATEGORY_GUILD_4,
	CHAT_CATEGORY_GUILD_5,
	CHAT_CATEGORY_OFFICER_1,
	CHAT_CATEGORY_OFFICER_2,
	CHAT_CATEGORY_OFFICER_3,
	CHAT_CATEGORY_OFFICER_4,
	CHAT_CATEGORY_OFFICER_5,
	CHAT_CATEGORY_ZONE_ENGLISH,
	CHAT_CATEGORY_ZONE_FRENCH,
	CHAT_CATEGORY_ZONE_GERMAN,
	CHAT_CATEGORY_ZONE_JAPANESE,
	CHAT_CATEGORY_MONSTER_SAY,
	CHAT_CATEGORY_MONSTER_YELL,
	CHAT_CATEGORY_MONSTER_WHISPER,
	CHAT_CATEGORY_MONSTER_EMOTE,
}

pChatData.guildCategories = {
	CHAT_CATEGORY_GUILD_1,
	CHAT_CATEGORY_GUILD_2,
	CHAT_CATEGORY_GUILD_3,
	CHAT_CATEGORY_GUILD_4,
	CHAT_CATEGORY_GUILD_5,
	CHAT_CATEGORY_OFFICER_1,
	CHAT_CATEGORY_OFFICER_2,
	CHAT_CATEGORY_OFFICER_3,
	CHAT_CATEGORY_OFFICER_4,
	CHAT_CATEGORY_OFFICER_5,
}

pChatData.defaultChannels = {
	PCHAT_CHANNEL_NONE,
	CHAT_CHANNEL_ZONE,
	CHAT_CHANNEL_SAY,
	CHAT_CHANNEL_GUILD_1,
	CHAT_CHANNEL_GUILD_2,
	CHAT_CHANNEL_GUILD_3,
	CHAT_CHANNEL_GUILD_4,
	CHAT_CHANNEL_GUILD_5,
	CHAT_CHANNEL_OFFICER_1,
	CHAT_CHANNEL_OFFICER_2,
	CHAT_CHANNEL_OFFICER_3,
	CHAT_CHANNEL_OFFICER_4,
	CHAT_CHANNEL_OFFICER_5,
}

--======================================================================================================================
-- Local Variables
--======================================================================================================================
local db
local targetToWhisp

-- Init
local isAddonLoaded			= false -- OnAddonLoaded() -> true
local isAddonInitialized	= false -- OnPlayerActivated() -> true

-- Preventer
local eventPlayerActivatedCheckRunning = false
local eventPlayerActivatedChecksDone = 0

--ZOs chat channels table
local ChannelInfo = ZO_ChatSystem_GetChannelInfo()
--ZOs chat switches table
local g_switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable()

--======================================================================================================================
--Load the libraries
--======================================================================================================================
local function LoadLibraries()
	--LibDebugLogger
	if not pChat.logger and LibDebugLogger then
		pChat.logger = LibDebugLogger(ADDON_NAME)
		logger = pChat.logger
		logger:Debug("AddOn loaded")
		subloggerVerbose = logger:Create("Verbose")
		subloggerVerbose:SetEnabled(false)
		pChat.verbose = subloggerVerbose
	end
	--LibChatMessage
	--[[
	if not pChat.LCM and LibChatMessage then
		pChat.LCM = LibChatMessage(ADDON_NAME, "pC")
		if logger then logger:Debug("Library 'LibChatMessage' detected") end
	end
	]]
end
--Early try to load libs (done again in EVENT_ADD_ON_LOADED)
LoadLibraries()

--======================================================================================================================
-- Helper functions
--======================================================================================================================
local AddCustomChannelSwitches, RemoveCustomChannelSwitches

--Initialize some tbales of the addon
local function InitTables()
	-- Used for CopySystem
	if not db.lineNumber then
		db.lineNumber = 1
	elseif type(db.lineNumber) ~= "number" then
		db.lineNumber = 1
		db.LineStrings = {}
	elseif db.lineNumber > 5000 then
		StripLinesFromLineStrings(0)
	end

	if not db.chatTabChannel then db.chatTabChannel = {} end
	if not db.LineStrings then db.LineStrings = {} end
	if not pChat.tabNames then pChat.tabNames = {} end
end

--Get the class's icon texture
local function getClassIcon(classId)
    --* GetClassInfo(*luaindex* _index_)
    -- @return defId integer,lore string,normalIconKeyboard textureName,pressedIconKeyboard textureName,mouseoverIconKeyboard textureName,isSelectable bool,ingameIconKeyboard textureName,ingameIconGamepad textureName,normalIconGamepad textureName,pressedIconGamepad textureName
    local classLuaIndex = GetClassIndexById(classId)
    local _, _, textureName, _, _, _, ingameIconKeyboard, _, _, _= GetClassInfo(classLuaIndex)
    return ingameIconKeyboard or textureName or ""
end

--Decorate a character name with colour and icon of the class
local function decorateCharName(charName, classId, decorate)
    if not charName or charName == "" then return "" end
    if not classId then return charName end
    decorate = decorate or false
    if not decorate then return charName end
    local charNameDecorated
    --Get the class color
    local charColorDef = GetClassColor(classId)
    --Apply the class color to the charname
    if nil ~= charColorDef then charNameDecorated = charColorDef:Colorize(charName) end
    --Apply the class textures to the charname
    charNameDecorated = zo_iconTextFormatNoSpace(getClassIcon(classId), 20, 20, charNameDecorated)
    return charNameDecorated
end

--Build the table of all characters of the account
local function getCharactersOfAccount(keyIsCharName, decorate)
    decorate = decorate or false
    keyIsCharName = keyIsCharName or false
    local charactersOfAccount
    --Check all the characters of the account
    for i = 1, GetNumCharacters() do
        --GetCharacterInfo() -> *string* _name_, *[Gender|#Gender]* _gender_, *integer* _level_, *integer* _classId_, *integer* _raceId_, *[Alliance|#Alliance]* _alliance_, *string* _id_, *integer* _locationId_
        local name, gender, level, classId, raceId, alliance, characterId, location = GetCharacterInfo(i)
        local charName = zo_strformat(SI_UNIT_NAME, name)
        if characterId ~= nil and charName ~= "" then
            if charactersOfAccount == nil then charactersOfAccount = {} end
            charName = decorateCharName(charName, classId, decorate)
            if keyIsCharName then
                charactersOfAccount[charName]   = characterId
            else
                charactersOfAccount[characterId]= charName
            end
        end
    end
    return charactersOfAccount
end

--======================================================================================================================
-- pChat functions
--======================================================================================================================

--Prepare some needed addon variables
local function PrepareVars()
	--Build the character name to unique ID mapping tables and vice-versa
	--The character names are decorated with the color and icon of the class!
	pChat.characterName2Id = {}
	pChat.characterId2Name = {}
	pChat.characterNameRaw2Id = {}
	pChat.characterId2NameRaw = {}
	--Tables with character charname as key
	pChat.characterName2Id = getCharactersOfAccount(true, true)
	pChat.characterNameRaw2Id = getCharactersOfAccount(true, false)
	--Tables with character ID as key
	pChat.characterId2Name = getCharactersOfAccount(false, true)
	pChat.characterId2NameRaw = getCharactersOfAccount(false, false)
end

-- Turn a ([0,1])^3 RGB colour to "|cABCDEF" form. We could use ZO_ColorDef, but we have so many colors so we don't do it.
local function ConvertRGBToHex(r, g, b)
	return string.format("|c%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

-- Convert a colour from "|cABCDEF" form to [0,1] RGB form.
local function ConvertHexToRGBA(colourString)
	local r=tonumber(string.sub(colourString, 3, 4), 16) or 255
	local g=tonumber(string.sub(colourString, 5, 6), 16) or 255
	local b=tonumber(string.sub(colourString, 7, 8), 16) or 255
	return r/255, g/255, b/255, 1
end

-- Return a formatted time
local function CreateTimestamp(timeStr, formatStr)
	formatStr = formatStr or db.timestampFormat

	-- split up default timestamp
	local hours, minutes, seconds = timeStr:match("([^%:]+):([^%:]+):([^%:]+)")
	local hoursNoLead = tonumber(hours) -- hours without leading zero
	local hours12NoLead = (hoursNoLead - 1)%12 + 1
	local hours12
	if (hours12NoLead < 10) then
		hours12 = "0" .. hours12NoLead
	else
		hours12 = hours12NoLead
	end
	local pUp = "AM"
	local pLow = "am"
	if (hoursNoLead >= 12) then
		pUp = "PM"
		pLow = "pm"
	end

	-- create new one
	local timestamp = formatStr
	timestamp = timestamp:gsub("HH", hours)
	timestamp = timestamp:gsub("H", hoursNoLead)
	timestamp = timestamp:gsub("hh", hours12)
	timestamp = timestamp:gsub("h", hours12NoLead)
	timestamp = timestamp:gsub("m", minutes)
	timestamp = timestamp:gsub("s", seconds)
	timestamp = timestamp:gsub("A", pUp)
	timestamp = timestamp:gsub("a", pLow)
	return timestamp
end

local function UndockTextEntry()
	local charId = GetCurrentCharacterId()
	-- Unfinshed
	if not db.chatConfSync[charId].TextEntryPoint then
		db.chatConfSync[charId].TextEntryPoint = CENTER
		db.chatConfSync[charId].TextEntryRelPoint = CENTER
		db.chatConfSync[charId].TextEntryX = 0
		db.chatConfSync[charId].TextEntryY = -300
		db.chatConfSync[charId].TextEntryWidth = 200
	end

	ZO_ChatWindowTextEntry:ClearAnchors()
	ZO_ChatWindowTextEntry:SetAnchor(db.chatConfSync[charId].TextEntryPoint, GuiRoot, db.chatConfSync[charId].TextEntryRelPoint, db.chatConfSync[charId].TextEntryX, 300)
	ZO_ChatWindowTextEntry:SetDimensions(400, 27)
	ZO_ChatWindowTextEntry:SetMovable(false)

	local undockedTexture = WINDOW_MANAGER:CreateControl("UndockedBackground", ZO_ChatWindowTextEntry, CT_TEXTURE)
	undockedTexture:SetTexture("EsoUI/Art/Performance/StatusMeterMunge.dds")
	undockedTexture:SetAnchor(CENTER, ZO_ChatWindowTextEntry, CENTER, 0, 0)
	undockedTexture:SetDimensions(800, 250)
end

--[[
local function RedockTextEntry()
	-- Unfinished
	ZO_ChatWindowTextEntry:ClearAnchors()
	ZO_ChatWindowTextEntry:SetAnchor(BOTTOMLEFT, ZO_ChatWindowMinimize, BOTTOMRIGHT, -6, -13)
	ZO_ChatWindowTextEntry:SetAnchor(BOTTOMRIGHT, ZO_ChatWindow, BOTTOMRIGHT, -23, -13)
	ZO_ChatWindowTextEntry:SetMovable(false)
end
]]

-- **************************************************************************
-- Chat Tab Functions
-- **************************************************************************
local function getTabNames()
    local totalTabs = CHAT_SYSTEM.tabPool.m_Active
    if totalTabs ~= nil and #totalTabs >= 1 then
        pChat.tabNames = {}
        for idx, tmpTab in pairs(totalTabs) do
            local tabLabel = tmpTab:GetNamedChild("Text")
            local tmpTabName = tabLabel:GetText()
            if tmpTabName ~= nil and tmpTabName ~= "" then
                pChat.tabNames[idx] = tmpTabName
            end
        end
    end
end

local function getTabIdx (tabName)
	local tabIdx = 0
	local totalTabs = CHAT_SYSTEM.tabPool.m_Active
	for i = 1, #totalTabs do
		if pChat.tabNames[i] == tabName then
			tabIdx = i
		end
	end
	return tabIdx
end

-- Rewrite of a core function
do
    local parts = {}
    local chatSystem = CHAT_SYSTEM
    local originalAddCommandHistory = chatSystem.textEntry.AddCommandHistory
    function chatSystem.textEntry:AddCommandHistory(text)
        -- Don't add the switch when chat is restored
        if db.addChannelAndTargetToHistory and isAddonInitialized then
            local currentChannel = chatSystem.currentChannel
            local currentTarget = chatSystem.currentTarget
            local switch = chatSystem.switchLookup[currentChannel]
            if switch ~= nil then
                parts[1] = switch
                if currentTarget then
                    parts[2] = currentTarget
                    parts[3] = text
                else
                    parts[2] = text
                    parts[3] = nil
                end
                text = table.concat(parts, " ")
            end
        end

        originalAddCommandHistory(self, text)
    end
end

-- Change ChatWindow Darkness by modifying its <Center> & <Edge>. Originally defined in virtual object ZO_ChatContainerTemplate in sharedchatsystem.xml
local function ChangeChatWindowDarkness()
	--New dynamic code
	local chatWindowDarknesssSetting = db.windowDarkness
	if chatWindowDarknesssSetting == 0 then
		ZO_ChatWindowBg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
		ZO_ChatWindowBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
	elseif chatWindowDarknesssSetting == 1 then
		ZO_ChatWindowBg:SetCenterColor(0, 0, 0, 0)
		ZO_ChatWindowBg:SetEdgeColor(0, 0, 0, 0)
	elseif chatWindowDarknesssSetting > 1 then
		ZO_ChatWindowBg:SetCenterColor(0, 0, 0, 1)
		ZO_ChatWindowBg:SetEdgeColor(0, 0, 0, 1)
		local textureStringMultiValue = tonumber((chatWindowDarknesssSetting - 1) * 10)
		if textureStringMultiValue == nil or textureStringMultiValue > 100 then return end
		local texturePathCenterDependingOnWindowDarknessTemplate = "pChat/dds/chat_bg_center_%d.dds"
		local texturePathCenterDependingOnWindowDarkness = string.format(texturePathCenterDependingOnWindowDarknessTemplate, textureStringMultiValue)
		local texturePathEdgeDependingOnWindowDarknessTemplate = "pChat/dds/chat_bg_edge_%d.dds"
		local texturePathEdgeDependingOnWindowDarkness = string.format(texturePathEdgeDependingOnWindowDarknessTemplate, textureStringMultiValue)
		ZO_ChatWindowBg:SetCenterTexture(texturePathCenterDependingOnWindowDarkness)
		ZO_ChatWindowBg:SetEdgeTexture(texturePathEdgeDependingOnWindowDarkness, 256, 256, 32)
	end
end

-- Needed to bind Shift+Tab in SetSwitchToNextBinding
function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
	return true
end

local function SetSwitchToNextBinding()

	-- get SwitchTab Keybind params
	local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName("PCHAT_SWITCH_TAB")
	--If exists
	if layerIndex and categoryIndex and actionIndex then
		local key = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, 1)
		if key == KEY_INVALID then
			-- Unbind it
			if IsProtectedFunction("UnbindAllKeysFromAction") then
				CallSecureProtected("UnbindAllKeysFromAction", layerIndex, categoryIndex, actionIndex)
			else
				UnbindAllKeysFromAction(layerIndex, categoryIndex, actionIndex)
			end

			-- Set it to its default value
			if IsProtectedFunction("BindKeyToAction") then
				CallSecureProtected("BindKeyToAction", layerIndex, categoryIndex, actionIndex, 1, KEY_TAB, 0, 0, KEY_SHIFT, 0)
			else
				BindKeyToAction(layerIndex, categoryIndex, actionIndex, 1, KEY_TAB , 0, 0, KEY_SHIFT, 0)
			end
		end
	end
end

-- Can be called by Bindings
function pChat_SwitchToNextTab()

	local hasSwitched

	local PRESSED = 1
	local UNPRESSED = 2
	local numTabs = #CHAT_SYSTEM.primaryContainer.windows
	local activeTab = pChatData.activeTab

	if numTabs > 1 then
		for numTab, container in ipairs (CHAT_SYSTEM.primaryContainer.windows) do

			if (not hasSwitched) then
				if activeTab + 1 == numTab then
					CHAT_SYSTEM.primaryContainer:HandleTabClick(container.tab)

					local tabText = GetControl(constTabNameTemplate .. numTab .. "Text")
					tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
					tabText:GetParent().state = PRESSED
					local oldTabText = GetControl(constTabNameTemplate .. activeTab .. "Text")
					oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
					oldTabText:GetParent().state = UNPRESSED

					hasSwitched = true
				end
			end

		end

		if (not hasSwitched) then
			CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[1].tab)
			local tabText = GetControl(constTabNameTemplate .. "1Text")
			tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
			tabText:GetParent().state = PRESSED
			local oldTabText = GetControl(constTabNameTemplate .. tostring(#CHAT_SYSTEM.primaryContainer.windows) .. "Text")
			oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
			oldTabText:GetParent().state = UNPRESSED
		end
	end

end
--**** Issue
local function SetDefaultTab(tabToSet)
	if not CHAT_SYSTEM or not CHAT_SYSTEM.primaryContainer or not CHAT_SYSTEM.primaryContainer.windows then return end
	-- Search in all tabs the good name
	for numTab in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
		-- Not this one, try the next one, if tab is not found (newly added, removed), pChat_SwitchToNextTab() will go back to tab 1
		if tonumber(tabToSet) ~= numTab then
			pChat_SwitchToNextTab()
		else
			-- Found it, stop
			return
		end
	end
end

function pChat_ChangeTab(tabToSet)
	if type(tabToSet)~="number" then return end
	local container=CHAT_SYSTEM.primaryContainer if not container then return end
	if tabToSet<1 or tabToSet>#container.windows then return end
	if container.windows[tabToSet].tab==nil then return end
	container.tabGroup:SetClickedButton(container.windows[tabToSet].tab)
	if CHAT_SYSTEM:IsMinimized() then CHAT_SYSTEM:Maximize() end
	local container=CHAT_SYSTEM.primaryContainer
	if not container then return end
	local tabToSet=container.currentBuffer:GetParent().tab.tabToSet

end

local function StripLinesFromLineStrings(typeOfExit)

	local k = 1
	-- First loop is time based. If message is older than our limit, it will be stripped.
	while k <= #db.LineStrings do

		if db.LineStrings[k] then
			local channel = db.LineStrings[k].channel
			if channel == CHAT_CHANNEL_SYSTEM and (not db.restoreSystem) then
				table.remove(db.LineStrings, k)
				db.lineNumber = db.lineNumber - 1
				k = k-1
			elseif channel ~= CHAT_CHANNEL_SYSTEM and db.restoreSystemOnly then
				table.remove(db.LineStrings, k)
				db.lineNumber = db.lineNumber - 1
				k = k-1
			elseif (channel == CHAT_CHANNEL_WHISPER or channel == CHAT_CHANNEL_WHISPER_SENT) and (not db.restoreWhisps) then
				table.remove(db.LineStrings, k)
				db.lineNumber = db.lineNumber - 1
				k = k-1
			elseif typeOfExit ~= 1 then
				if db.LineStrings[k].rawTimestamp then
					if (GetTimeStamp() - db.LineStrings[k].rawTimestamp) > (db.timeBeforeRestore * 60 * 60) then
						table.remove(db.LineStrings, k)
						db.lineNumber = db.lineNumber - 1
						k = k-1
					elseif db.LineStrings[k].rawTimestamp > GetTimeStamp() then -- System clock of users computer badly set and msg received meanwhile.
						table.remove(db.LineStrings, k)
						db.lineNumber = db.lineNumber - 1
						k = k-1
					end
				end
			end
		end

		k = k + 1

	end

	-- 2nd loop is size based. If dump is too big, just delete old ones
	if k > 5000 then
		local linesToDelete = k - 5000
		for l=1, linesToDelete do

			if db.LineStrings[l] then
				table.remove(db.LineStrings, l)
				db.lineNumber = db.lineNumber - 1
			end

		end
	end

end

local function SaveChatHistory(typeOf)

	db.history = {}

	if (db.restoreOnReloadUI == true and typeOf == 1) or (db.restoreOnLogOut == true and typeOf == 2) or (db.restoreOnAFK == true) or (db.restoreOnQuit == true and typeOf == 3) then

		if typeOf == 1 then

			db.lastWasReloadUI = true
			db.lastWasLogOut = false
			db.lastWasQuit = false
			db.lastWasAFK = false

			--Save actual channel
			db.history.currentChannel = CHAT_SYSTEM.currentChannel
			db.history.currentTarget = CHAT_SYSTEM.currentTarget

		elseif typeOf == 2 then
			db.lastWasReloadUI = false
			db.lastWasLogOut = true
			db.lastWasQuit = false
			db.lastWasAFK = false
		elseif typeOf == 3 then
			db.lastWasReloadUI = false
			db.lastWasLogOut = false
			db.lastWasQuit = true
			db.lastWasAFK = false
		end

		db.history.currentTab = pChatData.activeTab

		-- Save Chat History isn't needed, because it's saved in realtime, but we can strip some lines from the array to avoid big dumps
		StripLinesFromLineStrings(typeOf)

		--Save TextEntry history
		db.history.textEntry = {}
		if CHAT_SYSTEM.textEntry.commandHistory.entries then
			db.history.textEntry.entries = CHAT_SYSTEM.textEntry.commandHistory.entries
			db.history.textEntry.numEntries = CHAT_SYSTEM.textEntry.commandHistory.index
		else
			db.history.textEntry.entries = {}
			db.history.textEntry.numEntries = 0
		end
	else
		db.LineStrings = {}
		db.lineNumber = 1
	end

end

local function CreateNewChatTabPostHook()
	if not CHAT_SYSTEM or not CHAT_SYSTEM.primaryContainer or not CHAT_SYSTEM.primaryContainer.windows then return end
	--For each chat tab do
	for tabIndex, tabObject in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
		--Set the maximum lines in the chat tab to 1000 instead of 200
		if db.augmentHistoryBuffer then
			tabObject.buffer:SetMaxHistoryLines(1000) -- 1000 = max of control
		end
		--If the chat fade out is disabled: Set the fade timeout to 3600 milliseconds
		if db.alwaysShowChat then
			--New values for fadeOut taken from file:
			--https://github.com/esoui/esoui/blob/360dee5f494a444c2418a4e20fab8237e29f641b/esoui/ingame/chatsystem/console/gamepadchatsystem.lua
			local NEVER_FADE = 0
			--container.windows[tabIndex].buffer:SetLineFade(NEVER_FADE, NEVER_FADE)
			tabObject.buffer:SetLineFade(NEVER_FADE, NEVER_FADE) --old values: 3600, 2
		end
	end

end

local function ShowFadedLines()
	--[[
	local origChatSystemCreateNewChatTab = CHAT_SYSTEM.CreateNewChatTab
	CHAT_SYSTEM.CreateNewChatTab = function(self, ...)
		origChatSystemCreateNewChatTab(self, ...)
		CreateNewChatTabPostHook()
	end
	]]
	SecurePostHook(CHAT_SYSTEM, "CreateNewChatTab", function()
		CreateNewChatTabPostHook()
	end)

end

local function OnReticleTargetChanged()
	if IsUnitPlayer("reticleover") then
		targetToWhisp = GetUnitName("reticleover")
	end
end

-- Change font of chat
local function ChangeChatFont(change)

	local fontSize = GetChatFontSize()

	if db.fonts == "ESO Standard Font" or db.fonts == "Univers 57" then
		return
	else

		local fontPath = LibMediaProvider:Fetch("font", db.fonts)

		-- Entry Box
		ZoFontEditChat:SetFont(fontPath .. "|".. fontSize .. "|shadow")

		-- Chat window
		ZoFontChat:SetFont(fontPath .. "|" .. fontSize .. "|soft-shadow-thin")

	end

end

do
    -- we want to return pChat colors when the setting for eso colors is not enabled
    -- TODO investigate how we can use SetChatCategoryColor, so GetChatCategoryColor returns the value directly
    local originalZO_ChatSystem_GetCategoryColorFromChannel = ZO_ChatSystem_GetCategoryColorFromChannel
    function ZO_ChatSystem_GetCategoryColorFromChannel(channelId)
        if isAddonLoaded and not db.useESOcolors then
            local pChatColor
            if db.allGuildsSameColour and (channelId >= CHAT_CHANNEL_GUILD_1 and channelId <= CHAT_CHANNEL_GUILD_5) then
                pChatColor = db.colours[2 * CHAT_CHANNEL_GUILD_1]
            elseif db.allGuildsSameColour and (channelId >= CHAT_CHANNEL_OFFICER_1 and channelId <= CHAT_CHANNEL_OFFICER_5) then
                pChatColor = db.colours[2 * CHAT_CHANNEL_OFFICER_1]
            elseif db.allZonesSameColour and (channelId >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channelId <= CHAT_CHANNEL_ZONE_LANGUAGE_4) then
                pChatColor = db.colours[2 * CHAT_CHANNEL_ZONE]
            else
                pChatColor = db.colours[2 * channelId]
            end

            if not pChatColor then
                return 1, 1, 1, 1
            else
                return ConvertHexToRGBA(pChatColor)
            end
        end
        return originalZO_ChatSystem_GetCategoryColorFromChannel(channelId)
    end

    -- store all built-in switches so we can prevent accidents
    local isBuiltIn = {}
    for channelId, data in pairs(ChannelInfo) do
        if data.switches then
            for switchArg in data.switches:gmatch("%S+") do
                isBuiltIn[switchArg:lower()] = true
            end
        end
    end
		--local guildId = GetGuildId(i)
		--local guildName = GetGuildName(guildId)
    function AddCustomChannelSwitches(channelId, switchesToAdd)
		logger:Debug("AddCustomChannelSwitches-channelId: ", tostring(channelId) .. "; switchesToAdd: " ..tostring(switchesToAdd))
        local data = ChannelInfo[channelId]
        if not data or not switchesToAdd or switchesToAdd == "" then
            logger:Warn("Invalid arguments passed to 'AddCustomChannelSwitches'")
            return
        end

        local switches = {}
        if data.switches then
            for switchArg in data.switches:gmatch("%S+") do
                switches[#switches + 1] = switchArg
            end
        end
        for switchArg in switchesToAdd:gmatch("%S+") do
            switchArg = switchArg:lower()
            if isBuiltIn[switchArg] then
                local message = string.format(GetString(PCHAT_BUILT_IN_CHANNEL_SWITCH_WARNING), switchArg)
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, message)
            elseif g_switchLookup[switchArg] then
                local message = string.format(GetString(PCHAT_DUPLICATE_CHANNEL_SWITCH_WARNING), switchArg)
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, message)
            else
                switches[#switches + 1] = switchArg
                g_switchLookup[switchArg] = data
            end
        end

        if #switches > 0 then
            data.switches = table.concat(switches, " ")
        else
            data.switches = nil
        end
    end

    function RemoveCustomChannelSwitches(channelId, switchesToRemove)
		logger:Debug("RemoveCustomChannelSwitches-channelId: ", tostring(channelId) .. "; switchesToRemove: " ..tostring(switchesToRemove))
        local data = ChannelInfo[channelId]
        if not data or not switchesToRemove or switchesToRemove == "" then
            logger:Warn("Invalid arguments passed to RemoveCustomChannelSwitches")
            return
        end
        if not data.switches then
            logger:Warn("'RemoveCustomChannelSwitches', channel %d has no switches to remove", channelId)
            return
        end
        local shouldRemove = {}
        for switchArg in switchesToRemove:gmatch("%S+") do
            switchArg = switchArg:lower()
            if not isBuiltIn[switchArg] then
                shouldRemove[switchArg] = true
            end
        end

        local switches = {}
        for switchArg in data.switches:gmatch("%S+") do
            if shouldRemove[switchArg] then
                g_switchLookup[switchArg] = nil
            else
                switches[#switches + 1] = switchArg
            end
        end

        if #switches > 0 then
            data.switches = table.concat(switches, " ")
        else
            data.switches = nil
        end
    end
end

-- Change guild channel names in entry box
local function UpdateCharCorrespondanceTableChannelNames()
	logger:Debug("UpdateCharCorrespondanceTableChannelNames-Create the guild short names")
	-- Each guild: Update the table from ZO_ChatSystem_GetChannelInfo()
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		if db.showTagInEntry then
			-- Get saved string
			local tag = db.guildTags[guildId]
			-- No SavedVar
			if not tag then
				tag = guildName
			-- SavedVar, but no tag
			elseif tag == "" then
				tag = guildName
			end

			-- Get saved string
			local officertag = db.officertag[guildId]
			-- No SavedVar
			if not officertag then
				officertag = tag
			-- SavedVar, but no tag
			elseif officertag == "" then
				officertag = tag
			end

			-- CHAT_CHANNEL_GUILD_1 /g1 is 12 /g5 is 16, /o1=17, etc
			ChannelInfo[CHAT_CHANNEL_GUILD_1 - 1 + i].name = tag
			ChannelInfo[CHAT_CHANNEL_OFFICER_1 - 1 + i].name = officertag
			logger:Debug(">Set guild/officer tags to: %s/%s for guild #%d", tag, officertag, i)
			--Disabling dynamic chat channel names (see function GetDynamicChatChannelName(channelInfo.id))
			ChannelInfo[CHAT_CHANNEL_GUILD_1 - 1 + i].dynamicName = false
			ChannelInfo[CHAT_CHANNEL_OFFICER_1 - 1 + i].dynamicName = false

		else
			ChannelInfo[CHAT_CHANNEL_GUILD_1 - 1 + i].name = guildName
			ChannelInfo[CHAT_CHANNEL_OFFICER_1 - 1 + i].name = guildName
			--Enabling dynamic chat channel names (see function GetDynamicChatChannelName(channelInfo.id))
			ChannelInfo[CHAT_CHANNEL_GUILD_1 - 1 + i].dynamicName = true
			ChannelInfo[CHAT_CHANNEL_OFFICER_1 - 1 + i].dynamicName = true
		end
	end
end

local function UpdateGuildCorrespondanceTableSwitches()
	-- Update custom guild switches
	logger:Debug("UpdateGuildCorrespondanceTableSwitches-Create the guild chat switches")
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)

		local guildSwitches = db.switchFor[guildId]
		if(guildSwitches and guildSwitches ~= "") then
			AddCustomChannelSwitches(CHAT_CHANNEL_GUILD_1 - 1 + i, guildSwitches)
		end

		local officerSwitches = db.officerSwitchFor[guildId]
		if(officerSwitches and officerSwitches ~= "") then
			AddCustomChannelSwitches(CHAT_CHANNEL_OFFICER_1 - 1 + i, officerSwitches)
		end
	end
end


-- Can cause infinite loads (why?)
local function RestoreChatMessagesFromHistory(wasReloadUI)
	pChatData.preventWhisperNotificationsFromHistory = false

	-- Restore Chat
	local lastInsertionWas = 0
	local restoredPrefix = GetString(PCHAT_RESTORED_PREFIX)

	if db.LineStrings then

		local historyIndex = 1
		local categories = ZO_ChatSystem_GetEventCategoryMappings()

		while historyIndex <= #db.LineStrings do
			if db.LineStrings[historyIndex] then
				local channelToRestore = db.LineStrings[historyIndex].channel
				if channelToRestore == PCHAT_CHANNEL_SAY then channelToRestore = 0 end

				if channelToRestore == CHAT_CHANNEL_SYSTEM and not db.restoreSystem then
					table.remove(db.LineStrings, historyIndex)
					db.lineNumber = db.lineNumber - 1
					historyIndex = historyIndex - 1
				elseif channelToRestore ~= CHAT_CHANNEL_SYSTEM and db.restoreSystemOnly then
					table.remove(db.LineStrings, historyIndex)
					db.lineNumber = db.lineNumber - 1
					historyIndex = historyIndex - 1
				elseif (channelToRestore == CHAT_CHANNEL_WHISPER or channelToRestore == CHAT_CHANNEL_WHISPER_SENT) and not db.restoreWhisps then
					table.remove(db.LineStrings, historyIndex)
					db.lineNumber = db.lineNumber - 1
					historyIndex = historyIndex - 1
				else

					local category = categories[EVENT_CHAT_MESSAGE_CHANNEL][channelToRestore]
					local charId = GetCurrentCharacterId()

					--Prevent the whisper notifications because of history restored messages
					if db.notifyIM and db.doNotNotifyOnRestoredWhisperFromHistory == true and (channelToRestore == CHAT_CHANNEL_WHISPER or channelToRestore == CHAT_CHANNEL_WHISPER_SENT) then
						pChatData.preventWhisperNotificationsFromHistory = true
					end

					local timeStamp = GetTimeStamp()
					if db.LineStrings[historyIndex] and db.LineStrings[historyIndex].rawTimestamp and timeStamp - db.LineStrings[historyIndex].rawTimestamp < db.timeBeforeRestore * 60 * 60 and db.LineStrings[historyIndex].rawTimestamp < timeStamp then
						lastInsertionWas = math.max(lastInsertionWas, db.LineStrings[historyIndex].rawTimestamp)
						for containerIndex=1, #CHAT_SYSTEM.containers do
							for tabIndex=1, #CHAT_SYSTEM.containers[containerIndex].windows do
								if IsChatContainerTabCategoryEnabled(CHAT_SYSTEM.containers[containerIndex].id, tabIndex, category) then
									if not db.chatConfSync[charId].tabs[tabIndex].notBefore or db.LineStrings[historyIndex].rawTimestamp > db.chatConfSync[charId].tabs[tabIndex].notBefore then
										local restoredChatRawText = db.LineStrings[historyIndex].rawValue
										if restoredChatRawText and restoredChatRawText ~= "" then
											if db.addHistoryRestoredPrefix == true then
												--If the message was restored from history then add a prefix [H] )for history) to it!
												restoredChatRawText = restoredPrefix .. restoredChatRawText
											end
											CHAT_SYSTEM.containers[containerIndex]:AddEventMessageToWindow(CHAT_SYSTEM.containers[containerIndex].windows[tabIndex], AddLinkHandler(restoredChatRawText, channelToRestore, historyIndex), category)
									--[[
										else
											--DEBUG: Add SavedVariables entries for erroneous history entries (without rawValue text etc.)
											local restoreError = ""
											if restoredChatRawText and restoredChatRawText == "" then
												--logger:Warn("restoredChatRawText is missing! HistoryIndex:", historyIndex)
												restoreError = "rawText was missing"
											else
												--logger:Warn("restoredChatRawText is empty! HistoryIndex:", historyIndex)
												restoreError = "rawText was empty"
											end
											db.wrongRestoredHistoryIndices = db.wrongRestoredHistoryIndices or {}
											db.wrongRestoredHistoryIndices[historyIndex] = db.LineStrings[historyIndex]
											db.wrongRestoredHistoryIndices[historyIndex].restoreError = restoreError
									]]
										end
									end
								end
							end
						end
					else
						table.remove(db.LineStrings, historyIndex)
						db.lineNumber = db.lineNumber - 1
						historyIndex = historyIndex - 1
					end

				end
			end
			historyIndex = historyIndex + 1
		end

		local PRESSED = 1
		local UNPRESSED = 2
		local numTabs = #CHAT_SYSTEM.primaryContainer.windows

		for numTab, container in ipairs (CHAT_SYSTEM.primaryContainer.windows) do
			if numTab > 1 then
				CHAT_SYSTEM.primaryContainer:HandleTabClick(container.tab)
				local tabText = GetControl(constTabNameTemplate .. numTab .. "Text")
				tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
				tabText:GetParent().state = PRESSED
				local oldTabText = GetControl(constTabNameTemplate .. (numTab - 1) .. "Text")
				oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
				oldTabText:GetParent().state = UNPRESSED
			end
		end

		if numTabs > 1 then
			CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[1].tab)
			local tabText = GetControl(constTabNameTemplate.."1Text")
			tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
			tabText:GetParent().state = PRESSED
			local oldTabText = GetControl(constTabNameTemplate .. #CHAT_SYSTEM.primaryContainer.windows .. "Text")
			oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
			oldTabText:GetParent().state = UNPRESSED
		end

	end

	-- Restore TextEntry History
	if (wasReloadUI or db.restoreTextEntryHistoryAtLogOutQuit) and db.history.textEntry then

		if db.history.textEntry.entries then

			if lastInsertionWas and ((GetTimeStamp() - lastInsertionWas) < (db.timeBeforeRestore * 60 * 60)) then
				for _, text in ipairs(db.history.textEntry.entries) do
					CHAT_SYSTEM.textEntry:AddCommandHistory(text)
				end

				CHAT_SYSTEM.textEntry.commandHistory.index = db.history.textEntry.numEntries
			end

		end

	end
	pChatData.preventWhisperNotificationsFromHistory = false
end

-- Restore History from SavedVars
local function RestoreChatHistory()

	-- Set default tab at login
	SetDefaultTab(db.defaultTab)
	-- Restore History
	if db.history then

		if db.lastWasReloadUI and db.restoreOnReloadUI then

			-- RestoreChannel
			if db.defaultchannel ~= PCHAT_CHANNEL_NONE then
				CHAT_SYSTEM:SetChannel(db.history.currentChannel, db.history.currentTarget)
			end

			-- restore TextEntry and Chat
			RestoreChatMessagesFromHistory(true)

			-- Restore tab when ReloadUI
			--** blocking for now
			--SetDefaultTab(db.history.currentTab)

		elseif (db.lastWasLogOut and db.restoreOnLogOut) or (db.lastWasAFK and db.restoreOnAFK) or (db.lastWasQuit and db.restoreOnQuit) then
			-- restore TextEntry and Chat
			RestoreChatMessagesFromHistory(false)
		end

		pChatData.messagesHaveBeenRestorated = true

		--Prevent the whisper notifications because of history restored messages
		pChatData.preventWhisperNotificationsFromHistory = false

		db.lastWasReloadUI = false
		db.lastWasLogOut = false
		db.lastWasQuit = false
		db.lastWasAFK = true
	else
		pChatData.messagesHaveBeenRestorated = true
	end

end

-- Store line number
-- Create an array for the copy functions, spam functions and revert history functions
-- WARNING : See FormatSysMessage()
local function StorelineNumber(rawTimestamp, rawFrom, text, chanCode, originalFrom)
	subloggerVerbose:Debug(string.format("StoreLineNumber-Channel %s: [%s]%s(%s) %s", tostring(chanCode), tostring(rawTimestamp), tostring(originalFrom), tostring(rawFrom), tostring(text)))
	-- Strip DDS tag from Copy text
	local function StripDDStags(text)
		return text:gsub("|t(.-)|t", "")
	end

	local formattedMessage = ""
	local rawText = text

	-- SysMessages does not have a from
	if chanCode ~= CHAT_CHANNEL_SYSTEM then

		-- Timestamp cannot be nil anymore with SpamFilter, so use the option itself
		if db.showTimestamp then
			-- Format for Copy
			formattedMessage = "[" .. CreateTimestamp(GetTimeString()) .. "] "
		end

		-- Strip DDS tags for GM
		rawFrom = StripDDStags(rawFrom)

		-- Needed for SpamFilter
		db.LineStrings[db.lineNumber].rawFrom = originalFrom

		-- formattedMessage is only rawFrom for now
		formattedMessage = formattedMessage .. rawFrom

		if db.carriageReturn then
			formattedMessage = formattedMessage .. "\n"
		end

	end

	-- Needed for SpamFilter & Restoration, UNIX timestamp
	db.LineStrings[db.lineNumber].rawTimestamp = rawTimestamp

	-- Store CopyMessage / Used for SpamFiltering. Due to lua 0 == nil in arrays, set value to 98
	if chanCode == CHAT_CHANNEL_SAY then
		db.LineStrings[db.lineNumber].channel = PCHAT_CHANNEL_SAY
	else
		db.LineStrings[db.lineNumber].channel = chanCode
	end

	-- Store CopyMessage
	db.LineStrings[db.lineNumber].rawText = rawText

	-- Store CopyMessage
	--db.LineStrings[db.lineNumber].rawValue = text

	-- Strip DDS tags
	rawText = StripDDStags(rawText)

	-- Used to translate LinkHandlers
	rawText = FormatRawText(rawText)

	-- Store CopyMessage
	db.LineStrings[db.lineNumber].rawMessage = rawText

	-- Store CopyLine
	db.LineStrings[db.lineNumber].rawLine = formattedMessage .. rawText

	--Increment at each message handled
	db.lineNumber = db.lineNumber + 1

end

local function GetChannelColors(channel, from)

	 -- Substract XX to a color (darker)
	local function FirstColorFromESOSettings(r, g, b)
		-- Scale is from 0-100 so divide per 300 will maximise difference at 0.33 (*2)
		r = math.max(r - (db.diffforESOcolors / 300 ),0)
		g = math.max(g - (db.diffforESOcolors / 300 ),0)
		b = math.max(b - (db.diffforESOcolors / 300 ),0)
		return r,g,b
	end

	 -- Add XX to a color (brighter)
	local function SecondColorFromESOSettings(r, g, b)
		r = math.min(r + (db.diffforESOcolors / 300 ),1)
		g = math.min(g + (db.diffforESOcolors / 300 ),1)
		b = math.min(b + (db.diffforESOcolors / 300 ),1)
		return r,g,b
	end

	if db.useESOcolors then

		-- ESO actual color, return r,g,b
		local rESO, gESO, bESO
		-- Handle the same-colour options.
		if db.allNPCSameColour and (channel == CHAT_CHANNEL_MONSTER_SAY or channel == CHAT_CHANNEL_MONSTER_YELL or channel == CHAT_CHANNEL_MONSTER_WHISPER) then
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_MONSTER_SAY)
		elseif db.allGuildsSameColour and (channel >= CHAT_CHANNEL_GUILD_1 and channel <= CHAT_CHANNEL_GUILD_5) then
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_GUILD_1)
		elseif db.allGuildsSameColour and (channel >= CHAT_CHANNEL_OFFICER_1 and channel <= CHAT_CHANNEL_OFFICER_5) then
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_OFFICER_1)
		elseif db.allZonesSameColour and (channel >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channel <= CHAT_CHANNEL_ZONE_LANGUAGE_4) then
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_ZONE_LANGUAGE_1)
		elseif channel == CHAT_CHANNEL_PARTY and from and db.groupLeader and zo_strformat(SI_UNIT_NAME, from) == GetUnitName(GetGroupLeaderUnitTag()) then
			rESO, gESO, bESO = ConvertHexToRGBA(db.colours["groupleader"])
		else
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(channel)
		end

		-- Set right colour to left colour - cause ESO colors are rewrited, if onecolor, no rewriting
		if db.oneColour then
			pChat.lcol = ConvertRGBToHex(rESO, gESO, bESO)
			pChat.rcol = pChat.lcol
		else
			pChat.lcol = ConvertRGBToHex(FirstColorFromESOSettings(rESO,gESO,bESO))
			pChat.rcol = ConvertRGBToHex(SecondColorFromESOSettings(rESO,gESO,bESO))
		end

	else
		-- pChat Colors
		-- Handle the same-colour options.
		if db.allNPCSameColour and (channel == CHAT_CHANNEL_MONSTER_SAY or channel == CHAT_CHANNEL_MONSTER_YELL or channel == CHAT_CHANNEL_MONSTER_WHISPER) then
			pChat.lcol = db.colours[2*CHAT_CHANNEL_MONSTER_SAY]
			pChat.rcol = db.colours[2*CHAT_CHANNEL_MONSTER_SAY + 1]
		elseif db.allGuildsSameColour and (channel >= CHAT_CHANNEL_GUILD_1 and channel <= CHAT_CHANNEL_GUILD_5) then
			pChat.lcol = db.colours[2*CHAT_CHANNEL_GUILD_1]
			pChat.rcol = db.colours[2*CHAT_CHANNEL_GUILD_1 + 1]
		elseif db.allGuildsSameColour and (channel >= CHAT_CHANNEL_OFFICER_1 and channel <= CHAT_CHANNEL_OFFICER_5) then
			pChat.lcol = db.colours[2*CHAT_CHANNEL_OFFICER_1]
			pChat.rcol = db.colours[2*CHAT_CHANNEL_OFFICER_1 + 1]
		elseif db.allZonesSameColour and (channel >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channel <= CHAT_CHANNEL_ZONE_LANGUAGE_4) then
			pChat.lcol = db.colours[2*CHAT_CHANNEL_ZONE]
			pChat.rcol = db.colours[2*CHAT_CHANNEL_ZONE + 1]
		elseif channel == CHAT_CHANNEL_PARTY and from and db.groupLeader and zo_strformat(SI_UNIT_NAME, from) == GetUnitName(GetGroupLeaderUnitTag()) then
			pChat.lcol = db.colours["groupleader"]
			pChat.rcol = db.colours["groupleader1"]
		else
			pChat.lcol = db.colours[2*channel]
			pChat.rcol = db.colours[2*channel + 1]
		end

		-- Set right colour to left colour
		if db.oneColour then
			pChat.rcol = pChat.lcol
		end

	end

	return pChat.lcol, pChat.rcol

end

-- Append system category to chat filters
do
    local FILTERS_PER_ROW = 2
    local FILTER_PAD_X = 90
    local FILTER_PAD_Y = 0
    local FILTER_WIDTH = 150
    local FILTER_HEIGHT = 27
    local INITIAL_XOFFS = 0
    local INITIAL_YOFFS = 0

    SecurePostHook(CHAT_OPTIONS, "InitializeFilterButtons", function(self)
        local filterAnchor = ZO_Anchor:New(TOPLEFT, self.filterSection, TOPLEFT, 0, 0)
        local count = self.filterPool:GetActiveObjectCount()

        local filter, key = self.filterPool:AcquireObject()
        filter.key = key

        local button = filter:GetNamedChild("Check")
        ZO_CheckButton_SetLabelText(button, GetString("SI_CHATCHANNELCATEGORIES", CHAT_CATEGORY_SYSTEM))
        button.channels = { CHAT_CATEGORY_SYSTEM }
        table.insert(self.filterButtons, button)

        ZO_Anchor_BoxLayout(filterAnchor, filter, count, FILTERS_PER_ROW, FILTER_PAD_X, FILTER_PAD_Y, FILTER_WIDTH, FILTER_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
    end)
end

-- Rewrite of core function
do
    -- we try to set the alert color for the tab buttons, but as TAB_ALERT_TEXT_COLOR is local we have to intercept the call to ZO_TabButton_Text_SetTextColor
    -- this is obviously not ideal, but until ZOS adds a way to set the alert color it's the easiest way
    local originalZO_TabButton_Text_SetTextColor = ZO_TabButton_Text_SetTextColor
    local lastColor, cachedColor
    function ZO_TabButton_Text_SetTextColor(self, color)
        if(self:GetOwningWindow() == ZO_ChatWindow) then
            if(db.colours.tabwarning ~= lastColor) then
                lastColor = db.colours.tabwarning
                cachedColor = ZO_ColorDef:New(ConvertHexToRGBA(lastColor))
            end
            originalZO_TabButton_Text_SetTextColor(self, cachedColor)
        else
            originalZO_TabButton_Text_SetTextColor(self, color)
        end
    end
end

-- Rewrite of core data
do
    -- TODO this isn't currently used in FormatMessage, but may come in handy once we refactor that
    ChannelInfo[CHAT_CHANNEL_SAY].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_YELL].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_1].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_2].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_3].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_4].channelLinkable = true
end

-- Save chat configuration
local function SaveChatConfig()

	if not pChatData.tabNotBefore then
		pChatData.tabNotBefore = {} -- Init here or in SyncChatConfig depending if the "Clear Tab" has been used
	end

	if isAddonLoaded and CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer then -- Some addons calls SetCVar before
		local charId = GetCurrentCharacterId()

		-- Rewrite the whole char tab
		db.chatConfSync[charId] = {}

		-- Save Chat positions
		db.chatConfSync[charId].relPoint = CHAT_SYSTEM.primaryContainer.settings.relPoint
		db.chatConfSync[charId].x = CHAT_SYSTEM.primaryContainer.settings.x
		db.chatConfSync[charId].y = CHAT_SYSTEM.primaryContainer.settings.y
		db.chatConfSync[charId].height = CHAT_SYSTEM.primaryContainer.settings.height
		db.chatConfSync[charId].width = CHAT_SYSTEM.primaryContainer.settings.width
		db.chatConfSync[charId].point = CHAT_SYSTEM.primaryContainer.settings.point

		--db.chatConfSync[charId].textEntryDocked = true

		-- Don't overflow screen, remove 10px.
		if CHAT_SYSTEM.primaryContainer.settings.height >= ( CHAT_SYSTEM.maxContainerHeight - 15 ) then
			db.chatConfSync[charId].height = ( CHAT_SYSTEM.maxContainerHeight - 15 )
		else
			db.chatConfSync[charId].height = CHAT_SYSTEM.primaryContainer.settings.height
		end

		-- Same
		if CHAT_SYSTEM.primaryContainer.settings.width >= ( CHAT_SYSTEM.maxContainerWidth - 15 ) then
			db.chatConfSync[charId].width = ( CHAT_SYSTEM.maxContainerWidth - 15 )
		else
			db.chatConfSync[charId].width = CHAT_SYSTEM.primaryContainer.settings.width
		end

		-- Save Colors
		db.chatConfSync[charId].colors = {}

		for _, category in ipairs (pChatData.chatCategories) do
			local r, g, b = GetChatCategoryColor(category)
			db.chatConfSync[charId].colors[category] = { red = r, green = g, blue = b }
		end

		-- Save Font Size
		db.chatConfSync[charId].fontSize = GetChatFontSize()

		-- Save Tabs
		db.chatConfSync[charId].tabs = {}

		-- GetNumChatContainerTabs(1) don't refresh its number before a ReloadUI
		-- for numTab = 1, GetNumChatContainerTabs(1) do
		for numTab in ipairs (CHAT_SYSTEM.primaryContainer.windows) do

			db.chatConfSync[charId].tabs[numTab] = {}

			-- Save "Clear Tab" flag
			if pChatData.tabNotBefore[numTab] then
				db.chatConfSync[charId].tabs[numTab].notBefore = pChatData.tabNotBefore[numTab]
			end

			-- No.. need a ReloadUI		local name, isLocked, isInteractable, isCombatLog, areTimestampsEnabled = GetChatContainerTabInfo(1, numTab)
			-- IsLocked
			if CHAT_SYSTEM.primaryContainer:IsLocked(numTab) then
				db.chatConfSync[charId].tabs[numTab].isLocked = true
			else
				db.chatConfSync[charId].tabs[numTab].isLocked = false
			end

			-- IsInteractive
			if CHAT_SYSTEM.primaryContainer:IsInteractive(numTab) then
				db.chatConfSync[charId].tabs[numTab].isInteractable = true
			else
				db.chatConfSync[charId].tabs[numTab].isInteractable = false
			end

			-- IsCombatLog
			if CHAT_SYSTEM.primaryContainer:IsCombatLog(numTab) then
				db.chatConfSync[charId].tabs[numTab].isCombatLog = true
				-- AreTimestampsEnabled
				if CHAT_SYSTEM.primaryContainer:AreTimestampsEnabled(numTab) then
					db.chatConfSync[charId].tabs[numTab].areTimestampsEnabled = true
				else
					db.chatConfSync[charId].tabs[numTab].areTimestampsEnabled = false
				end
			else
				db.chatConfSync[charId].tabs[numTab].isCombatLog = false
				db.chatConfSync[charId].tabs[numTab].areTimestampsEnabled = false
			end

			-- GetTabName
			db.chatConfSync[charId].tabs[numTab].name = CHAT_SYSTEM.primaryContainer:GetTabName(numTab)

			-- Enabled categories
			db.chatConfSync[charId].tabs[numTab].enabledCategories = {}

			for _, category in ipairs (pChatData.chatCategories) do
				local isEnabled = IsChatContainerTabCategoryEnabled(1, numTab, category)
				db.chatConfSync[charId].tabs[numTab].enabledCategories[category] = isEnabled
			end

		end

		db.chatConfSync.lastChar = db.chatConfSync[charId]

	end

end

-- Save Chat Tabs config when user changes it
local function SaveTabsCategories()
	local charId = GetCurrentCharacterId()

	for numTab in ipairs (CHAT_SYSTEM.primaryContainer.windows) do

		for _, category in ipairs (pChatData.guildCategories) do
			local isEnabled = IsChatContainerTabCategoryEnabled(1, numTab, category)
			if db.chatConfSync[charId].tabs[numTab] then
				db.chatConfSync[charId].tabs[numTab].enabledCategories[category] = isEnabled
			else
				SaveChatConfig()
			end
		end

	end

end

-- Function for Minimizing chat at launch
local function MinimizeChatAtLaunch()
	if db.chatMinimizedAtLaunch then
		CHAT_SYSTEM:Minimize()
	end
end

local function MinimizeChatInMenus()

	-- RegisterCallback for Maximize/Minimize chat when entering/leaving scenes
	-- "hud" is base scene (with "hudui")
	local hudScene = SCENE_MANAGER:GetScene("hud")
	hudScene:RegisterCallback("StateChange", function(oldState, newState)

		if db.chatMinimizedInMenus then
			if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
				CHAT_SYSTEM:Minimize()
			end
		end

		if db.chatMaximizedAfterMenus then
			if newState == SCENE_SHOWING then
				CHAT_SYSTEM:Maximize()
			end
		end

	end)

end

-- Set the chat config from pChat settings
local function SyncChatConfig(shouldSync, whichCharId)

	if shouldSync then
		if db.chatConfSync and db.chatConfSync[whichCharId] and CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer then
			local chatConfSyncForCharId = db.chatConfSync[whichCharId]
			if CHAT_SYSTEM.control then
				-- Position and width/height
				CHAT_SYSTEM.control:SetAnchor(chatConfSyncForCharId.point, GuiRoot, chatConfSyncForCharId.relPoint, chatConfSyncForCharId.x, chatConfSyncForCharId.y)
				-- Height / Width
				CHAT_SYSTEM.control:SetDimensions(chatConfSyncForCharId.width, chatConfSyncForCharId.height)
			end

			-- Save settings immediatly (to check, maybe call function which do this)
			if CHAT_SYSTEM.primaryContainer.settings then
				CHAT_SYSTEM.primaryContainer.settings.height = chatConfSyncForCharId.height
				CHAT_SYSTEM.primaryContainer.settings.point = chatConfSyncForCharId.point
				CHAT_SYSTEM.primaryContainer.settings.relPoint = chatConfSyncForCharId.relPoint
				CHAT_SYSTEM.primaryContainer.settings.width = chatConfSyncForCharId.width
				CHAT_SYSTEM.primaryContainer.settings.x = chatConfSyncForCharId.x
				CHAT_SYSTEM.primaryContainer.settings.y = chatConfSyncForCharId.y
			end

				--[[
				-- Don't overflow screen, remove 15px.
				if chatConfSyncForCharId.height >= (CHAT_SYSTEM.maxContainerHeight - 15 ) then
					CHAT_SYSTEM.control:SetHeight((CHAT_SYSTEM.maxContainerHeight - 15 ))
					logger:Debug("Overflow height %d -+- %d",  chatConfSyncForCharId.height, (CHAT_SYSTEM.maxContainerHeight - 15))
					logger:Debug(CHAT_SYSTEM.control:GetHeight())
				else
					-- Don't set good values ?! SetHeight(674) = GetHeight(524) ? same with Width and resizing is buggy
					--CHAT_SYSTEM.control:SetHeight(chatConfSyncForCharId.height)
					CHAT_SYSTEM.control:SetDimensions(settings.width, settings.height)
					logger:Debug("height %d -+- %d", chatConfSyncForCharId.height, CHAT_SYSTEM.control:GetHeight())
				end

				-- Same
				if chatConfSyncForCharId.width >= (CHAT_SYSTEM.maxContainerWidth - 15 ) then
					CHAT_SYSTEM.control:SetWidth((CHAT_SYSTEM.maxContainerWidth - 15 ))
					logger:Debug("Overflow width %d -+- %d", chatConfSyncForCharId.width, (CHAT_SYSTEM.maxContainerWidth - 15))
					logger:Debug(CHAT_SYSTEM.control:GetWidth())
				else
					CHAT_SYSTEM.control:SetHeight(chatConfSyncForCharId.width)
					logger:Debug("width %d -+- %d", chatConfSyncForCharId.width, CHAT_SYSTEM.control:GetWidth())
				end
				]]--

			-- Colors
			if GetChatCategoryColor and SetChatCategoryColor then
				for _, category in ipairs (pChatData.chatCategories) do
					if not chatConfSyncForCharId.colors[category] then
						local r, g, b = GetChatCategoryColor(category)
						chatConfSyncForCharId.colors[category] = { red = r, green = g, blue = b }
					end
					SetChatCategoryColor(category, chatConfSyncForCharId.colors[category].red, chatConfSyncForCharId.colors[category].green, chatConfSyncForCharId.colors[category].blue)
				end
			end

			-- Font Size
			-- Not in Realtime SetChatFontSize(chatConfSyncForCharId.fontSize), need to add CHAT_SYSTEM:SetFontSize for Realtimed

			-- ?!? Need to go by a local?..
			if CHAT_SYSTEM.SetFontSize and SetChatFontSize then
				local fontSize = chatConfSyncForCharId.fontSize
				CHAT_SYSTEM:SetFontSize(fontSize)
				SetChatFontSize(chatConfSyncForCharId.fontSize)
			end

			local chatSyncNumTab = 1
			if chatConfSyncForCharId.tabs then
				for numTab in ipairs(chatConfSyncForCharId.tabs) do

					--Create a Tab if nessesary
					if (GetNumChatContainerTabs(1) < numTab) then
						-- AddChatContainerTab(1, , chatConfSyncForCharId.tabs[numTab].isCombatLog) No ! Require a ReloadUI
						CHAT_SYSTEM.primaryContainer:AddWindow(chatConfSyncForCharId.tabs[numTab].name)
					end

					if chatConfSyncForCharId.tabs[numTab] and chatConfSyncForCharId.tabs[numTab].notBefore then

						if not pChatData.tabNotBefore then
							pChatData.tabNotBefore = {} -- Used for tab restoration, init here.
						end

						pChatData.tabNotBefore[numTab] = chatConfSyncForCharId.tabs[numTab].notBefore

					end

					-- Set Tab options
					-- Not in realtime : SetChatContainerTabInfo(1, numTab, chatConfSyncForCharId.tabs[numTab].name, chatConfSyncForCharId.tabs[numTab].isLocked, chatConfSyncForCharId.tabs[numTab].isInteractable, chatConfSyncForCharId.tabs[numTab].areTimestampsEnabled)

					CHAT_SYSTEM.primaryContainer:SetTabName(numTab, chatConfSyncForCharId.tabs[numTab].name)
					CHAT_SYSTEM.primaryContainer:SetLocked(numTab, chatConfSyncForCharId.tabs[numTab].isLocked)
					CHAT_SYSTEM.primaryContainer:SetInteractivity(numTab, chatConfSyncForCharId.tabs[numTab].isInteractable)
					CHAT_SYSTEM.primaryContainer:SetTimestampsEnabled(numTab, chatConfSyncForCharId.tabs[numTab].areTimestampsEnabled)

					-- Set Channel per tab configuration
					for _, category in ipairs (pChatData.chatCategories) do
						if chatConfSyncForCharId.tabs[numTab].enabledCategories[category] == nil then -- Cal be false
							chatConfSyncForCharId.tabs[numTab].enabledCategories[category] = IsChatContainerTabCategoryEnabled(1, numTab, category)
						end
						SetChatContainerTabCategoryEnabled(1, numTab, category, chatConfSyncForCharId.tabs[numTab].enabledCategories[category])
					end

					chatSyncNumTab = numTab

				end
			end

			-- If they're was too many tabs before, drop them
			local removeTabs = true
			while removeTabs do
				-- Too many tabs, deleting one
				if GetNumChatContainerTabs(1) > chatSyncNumTab then
					-- Not in realtime : RemoveChatContainerTab(1, chatSyncNumTab + 1)
					CHAT_SYSTEM.primaryContainer:RemoveWindow(chatSyncNumTab + 1, nil)
				else
					removeTabs = false
				end
			end
		end
	end

end

-- When creating a char, try to import settings
local function AutoSyncSettingsForNewPlayer()

	-- New chars get automaticaly last char config
	if GetIsNewCharacter() then
		SyncChatConfig(true, "lastChar")
	end

end

-- Set channel to the default one
local function SetToDefaultChannel()
	if db.defaultchannel ~= PCHAT_CHANNEL_NONE then
		CHAT_SYSTEM:SetChannel(db.defaultchannel)
	end
end

local function SaveGuildIndexes()
	pChatData.guildIndexes = {}
	--For each guild get the unique serverGuildId
	for guildNum = 1, GetNumGuilds() do
		-- Guildname
		local guildId = GetGuildId(guildNum)
		local guildName = GetGuildName(guildId)
		-- Occurs sometimes
		if(not guildName or (guildName):len() < 1) then
			guildName = "Guild " .. guildNum
		end
		pChatData.guildIndexes[guildId] = {
			num		= guildNum,
			id 		= guildId,
			name 	= guildName,
		}
	end
end


-- Triggered by EVENT_GUILD_SELF_JOINED_GUILD
local function OnSelfJoinedGuild(_, guildServerId, characterName, guildId)

	-- It will rebuild optionsTable and recreate tables if user didn't went in this section before
	BuildLAMPanel()

	-- If recently added to a new guild and never go in menu db.formatguild[guildName] won't exist, it won't create the value if joining an known guild
	if not db.formatguild[guildServerId] then
		-- 2 is default value
		db.formatguild[guildServerId] = 2
	end

	-- Save Guild indexes for guild reorganization
	SaveGuildIndexes()

end

-- Revert category settings
local function RevertCategories(guildId)

	-- Old GuildId
	local oldIndex = pChatData.guildIndexes[guildId].num
	-- old Total Guilds
	local totGuilds = GetNumGuilds() + 1

	if oldIndex and oldIndex < totGuilds then
		local charId = GetCurrentCharacterId()

		-- If our guild was not the last one, need to revert colors
		--logger:Debug("pChat will revert starting from %d to %d", oldIndex, totGuilds)

		-- Does not need to reset chat settings for first guild if the 2nd has been left, same for 1-2/3 and 1-2-3/4
		for iGuilds=oldIndex, (totGuilds - 1) do

			-- If default channel was g1, keep it g1
			if not (db.defaultchannel == CHAT_CATEGORY_GUILD_1 or db.defaultchannel == CHAT_CATEGORY_OFFICER_1) then

				if db.defaultchannel == (CHAT_CATEGORY_GUILD_1 + iGuilds) then
					db.defaultchannel = (CHAT_CATEGORY_GUILD_1 + iGuilds - 1)
				elseif db.defaultchannel == (CHAT_CATEGORY_OFFICER_1 + iGuilds) then
					db.defaultchannel = (CHAT_CATEGORY_OFFICER_1 + iGuilds - 1)
				end

			end

			-- New Guild color for Guild #X is the old #X+1
			SetChatCategoryColor(CHAT_CATEGORY_GUILD_1 + iGuilds - 1, db.chatConfSync[charId].colors[CHAT_CATEGORY_GUILD_1 + iGuilds].red, db.chatConfSync[charId].colors[CHAT_CATEGORY_GUILD_1 + iGuilds].green, db.chatConfSync[charId].colors[CHAT_CATEGORY_GUILD_1 + iGuilds].blue)
			-- New Officer color for Guild #X is the old #X+1
			SetChatCategoryColor(CHAT_CATEGORY_OFFICER_1 + iGuilds - 1, db.chatConfSync[charId].colors[CHAT_CATEGORY_OFFICER_1 + iGuilds].red, db.chatConfSync[charId].colors[CHAT_CATEGORY_OFFICER_1 + iGuilds].green, db.chatConfSync[charId].colors[CHAT_CATEGORY_OFFICER_1 + iGuilds].blue)

			-- Restore tab config previously set.
			for numTab in ipairs (CHAT_SYSTEM.primaryContainer.windows) do
				if db.chatConfSync[charId].tabs[numTab] then
					SetChatContainerTabCategoryEnabled(1, numTab, (CHAT_CATEGORY_GUILD_1 + iGuilds - 1), db.chatConfSync[charId].tabs[numTab].enabledCategories[CHAT_CATEGORY_GUILD_1 + iGuilds])
					SetChatContainerTabCategoryEnabled(1, numTab, (CHAT_CATEGORY_OFFICER_1 + iGuilds - 1), db.chatConfSync[charId].tabs[numTab].enabledCategories[CHAT_CATEGORY_OFFICER_1 + iGuilds])
				end
			end

		end
	end

end

-- Registers the formatMessage function.
-- Unregisters itself from the player activation event with the event manager.
local function OnPlayerActivated()
	logger:Debug("EVENT_PLAYER_ACTIVATED - Start")
	--Addon was loaded via EVENT_ADD_ON_LOADED and we are not already doing some EVENT_PLAYER_ACTIVATED tasks
	if isAddonLoaded and not eventPlayerActivatedCheckRunning then
		pChatData.sceneFirst = false

        pChat.InitializeChatHandlers(pChat.FormatMessage, pChat.formatSysMessage, logger)
	end

	--Test if the chat_system containers are given already or wait until they are.
	--Only test 3 seconds, then do the event_player_activated tasks!
	if eventPlayerActivatedChecksDone <= 12 and (CHAT_SYSTEM == nil or CHAT_SYSTEM.primaryContainer == nil) then
		logger:Debug("EVENT_PLAYER_ACTIVATED: CHAT_SYSTEM.primaryContainer is missing!")
		if not eventPlayerActivatedCheckRunning then
			EVENT_MANAGER:RegisterForUpdate("pChatDebug_Event_Player_Activated", 250, function()
				eventPlayerActivatedChecksDone = eventPlayerActivatedChecksDone + 1
				eventPlayerActivatedCheckRunning = true
				OnPlayerActivated()
			end)
		end
	else
		logger:Debug("EVENT_PLAYER_ACTIVATED: Found CHAT_SYSTEM.primaryContainer!")
		eventPlayerActivatedCheckRunning = false
		EVENT_MANAGER:UnregisterForUpdate("pChatDebug_Event_Player_Activated")

		if isAddonLoaded then
			pChatData.activeTab = 1

			--Get a reference to the chat channelData (CHAT_SYSTEM.channelData)
			--ChannelInfo = ZO_ChatSystem_GetChannelInfo()

			if CHAT_SYSTEM.ValidateChatChannel then
				ZO_PreHook(CHAT_SYSTEM, "ValidateChatChannel", function(self)
					if (db.enableChatTabChannel  == true) and (self.currentChannel ~= CHAT_CHANNEL_WHISPER) then
						local tabIndex = self.primaryContainer.currentBuffer:GetParent().tab.index
						db.chatTabChannel[tabIndex] = db.chatTabChannel[tabIndex] or {}
						db.chatTabChannel[tabIndex].channel = self.currentChannel
						db.chatTabChannel[tabIndex].target  = self.currentTarget
					end
				end)
			end

			if CHAT_SYSTEM.primaryContainer.HandleTabClick then
				ZO_PreHook(CHAT_SYSTEM.primaryContainer, "HandleTabClick", function(self, tab)
					pChatData.activeTab = tab.index
					if (db.enableChatTabChannel == true) then
						local tabIndex = tab.index
						if db.chatTabChannel[tabIndex] then
							CHAT_SYSTEM:SetChannel(db.chatTabChannel[tabIndex].channel, db.chatTabChannel[tabIndex].target)
						end
					end
					--ZO_TabButton_Text_RestoreDefaultColors(tab)
				end)
			end

			if CHAT_SYSTEM.Maximize then
				-- Visual Notification PreHook
				ZO_PreHook(CHAT_SYSTEM, "Maximize", function(self)
					CHAT_SYSTEM.IMLabelMin:SetHidden(true)
				end)
			end

			--local fontPath = ZoFontChat:GetFontInfo()
			--chat:Print(fontPath)
			--chat:Print("|C3AF24BLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.|r")
			--chat:Print("Characters below should be well displayed :")
			--chat:Print("!\"#$%&'()*+,-./0123456789:;<=>?@ ABCDEFGHIJKLMNOPQRSTUVWXYZ [\]^_`abcdefghijklmnopqrstuvwxyz{|} ~¡£¤¥¦§©«-®°²³´µ¶·»½¿ ÀÁÂÄÆÇÈÉÊËÌÍÎÏÑÒÓÔÖ×ÙÚÛÜßàáâäæçèéêëìíîïñòóôöùúûüÿŸŒœ")

			-- AntiSpam
			pChatData.spamLookingForEnabled = true
			pChatData.spamWantToEnabled = true
			pChatData.spamGuildRecruitEnabled = true

			-- Show 1000 lines instead of 200 & Change fade delay
			ShowFadedLines()
			-- Get Chat Tab Names stored in chatTabNames {}
			getTabNames()
			-- Rebuild Lam Panel
			BuildLAMPanel()
			-- Create the chat tab's PostHook
			CreateNewChatTabPostHook()

			-- Should we minimize ?
			MinimizeChatAtLaunch()

			-- Message for new chars
			AutoSyncSettingsForNewPlayer()

			-- Chat Config synchronization
			SyncChatConfig(db.chatSyncConfig, "lastChar")
			SaveChatConfig()

			--Update the guilds custom tags (next to entry box): Add them to the chat channels of table ChannelInfo
			UpdateCharCorrespondanceTableChannelNames()

			--Update teh guild's custom channel switches: Add them to the chat switches of table ZO_ChatSystem_GetChannelSwitchLookupTable
			UpdateGuildCorrespondanceTableSwitches()

			-- Set default channel at login
			SetToDefaultChannel()

			-- Save all category colors
			SaveGuildIndexes()

			-- Handle Copy text
			pChat.InitializeCopyHandler(pChatData, db, PCHAT_URL_CHAN, PCHAT_LINK)

			-- Restore History if needed
			RestoreChatHistory()
			-- Default Tab
			SetDefaultTab(db.defaultTab)
			-- Change Window apparence
			ChangeChatWindowDarkness()

			isAddonInitialized = true

			EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
			logger:Debug("EVENT_PLAYER_ACTIVATED - End: Addon was initialized")
		end
	end
end


-- Runs whenever "me" left a guild (or get kicked)
local function OnSelfLeftGuild(_, guildServerId, characterName, guildId)

	-- It will rebuild optionsTable and recreate tables if user didn't went in this section before
	BuildLAMPanel()

	-- Revert category colors & options
	RevertCategories(guildServerId)

end

local function SwitchToParty(characterName)

	zo_callLater(function(characterName) -- characterName = avoid ZOS bug
		-- If "me" join group
		if(GetRawUnitName("player") == characterName) then

			-- Switch to party channel when joining a group
			if db.enablepartyswitch then
				CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)
			end

		else

			-- Someone else joined group
			-- If GetGroupSize() == 2 : Means "me" just created a group and "someone" just joining
			 if GetGroupSize() == 2 then
				-- Switch to party channel when joinin a group
				if db.enablepartyswitch then
					CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)
				end
			 end

		end
	end, 200)

end

-- Triggers when EVENT_GROUP_MEMBER_JOINED
local function OnGroupMemberJoined(_, characterName)
	SwitchToParty(characterName)
end

-- triggers when EVENT_GROUP_MEMBER_LEFT
local function OnGroupMemberLeft(_, characterName, reason, wasMeWhoLeft)

	-- Go back to default channel
	if GetGroupSize() <= 1 then
		-- Go back to default channel when leaving a group
		if db.enablepartyswitch then
			-- Only if we was on party
			if CHAT_SYSTEM.currentChannel == CHAT_CHANNEL_PARTY and db.defaultchannel ~= PCHAT_CHANNEL_NONE then
				SetToDefaultChannel()
			end
		end
	end

end

-- Save a category color for guild chat, set by ChatSystem at launch + when user change manually
local function SaveChatCategoriesColors(category, r, g, b)
	local charId = GetCurrentCharacterId()
	if db.chatConfSync[charId] then
		if db.chatConfSync[charId].colors[category] == nil then
			db.chatConfSync[charId].colors[category] = {}
		end
		db.chatConfSync[charId].colors[category] = { red = r, green = g, blue = b }
	end
end

-- PreHook of ZO_ChatSystem_ShowOptions() and ZO_ChatWindow_OpenContextMenu(control.index)
local function ChatSystemShowOptions(tabIndex)
	local self = CHAT_SYSTEM.primaryContainer
	tabIndex = tabIndex or (self.currentBuffer and self.currentBuffer:GetParent() and self.currentBuffer:GetParent().tab and self.currentBuffer:GetParent().tab.index)
	local window = self.windows[tabIndex]
	if window then
		ClearMenu()

		if not ZO_Dialogs_IsShowingDialog() then
			AddCustomMenuItem(GetString(SI_CHAT_CONFIG_CREATE_NEW), function() self.system:CreateNewChatTab(self) end)
			if not window.combatLog and (not self:IsPrimary() or tabIndex ~= 1) then
				AddCustomMenuItem(GetString(SI_CHAT_CONFIG_REMOVE), function() self:ShowRemoveTabDialog(tabIndex) end)
			end
			AddCustomMenuItem(GetString(SI_CHAT_CONFIG_OPTIONS), function() self:ShowOptions(tabIndex) end)
			AddCustomMenuItem(GetString(PCHAT_CLEARBUFFER), function()
				pChatData.tabNotBefore[tabIndex] = GetTimeStamp()
				self.windows[tabIndex].buffer:Clear()
				self:SyncScrollToBuffer()
			end)
		end

		if self:IsPrimary() and tabIndex == 1 then
			if self:IsLocked(tabIndex) then
				AddCustomMenuItem(GetString(SI_CHAT_CONFIG_UNLOCK), function() self:SetLocked(tabIndex, false) end)
			else
				AddCustomMenuItem(GetString(SI_CHAT_CONFIG_LOCK), function() self:SetLocked(tabIndex, true) end)
			end
		end

		if window.combatLog then
			if self:AreTimestampsEnabled(tabIndex) then
				AddCustomMenuItem(GetString(SI_CHAT_CONFIG_HIDE_TIMESTAMP), function() self:SetTimestampsEnabled(tabIndex, false) end)
			else
				AddCustomMenuItem(GetString(SI_CHAT_CONFIG_SHOW_TIMESTAMP), function() self:SetTimestampsEnabled(tabIndex, true) end)
			end
		end

		--[[
		local charId = GetCurrentCharacterId()
		if db.chatConfSync[charId].textEntryDocked then
			AddCustomMenuItem(GetString(PCHAT_UNDOCKTEXTENTRY), function() UndockTextEntry() end)
		else
			AddCustomMenuItem(GetString(PCHAT_REDOCKTEXTENTRY), function() RedockTextEntry() end)
		end
		]]

		ShowMenu(window.tab)
	end
	--Do not call original ZO_ChatSystem_ShowOptions() or ZO_ChatWindow_OpenContextMenu()
	return true
end


--Load some early hooks
local function LoadEarlyHooks()
	-- Resize, must be loaded before CHAT_SYSTEM is set
	local orgCalculateConstraints = SharedChatContainer.CalculateConstraints
	function SharedChatContainer.CalculateConstraints(...)
		local self = ...
		local w, h = GuiRoot:GetDimensions()
		self.system.maxContainerWidth, self.system.maxContainerHeight = w * 0.95, h * 0.95
		return orgCalculateConstraints(...)
	end
end

--Load some hooks
local function LoadHooks()
	-- PreHook ReloadUI, SetCVar, LogOut & Quit to handle Chat Import/Export
	ZO_PreHook("ReloadUI", function()
		SaveChatHistory(1)
		SaveChatConfig()
	end)

	ZO_PreHook("SetCVar", function()
		SaveChatHistory(1)
		SaveChatConfig()
	end)

	ZO_PreHook("Logout", function()
		SaveChatHistory(2)
		SaveChatConfig()
	end)

	ZO_PreHook("Quit", function()
		SaveChatHistory(3)
		SaveChatConfig()
	end)

	-- Social option change color
	ZO_PreHook("SetChatCategoryColor", SaveChatCategoriesColors)
	-- Chat option change categories filters, add a callLater because settings are set after this function triggers.
	ZO_PreHook("ZO_ChatOptions_ToggleChannel", function() zo_callLater(SaveTabsCategories, 100) end)

	-- Right click on a tab name
	ZO_PreHook("ZO_ChatSystem_ShowOptions", function(control) return ChatSystemShowOptions() end)
	ZO_PreHook("ZO_ChatWindow_OpenContextMenu", function(control) return ChatSystemShowOptions(control.index) end)

	--Scroll to bottom in Chat: Secure post hook to hide the Whisper Notifications
	SecurePostHook("ZO_ChatSystem_ScrollToBottom", function()
		pChat_RemoveIMNotification()
	end)

end

--Load the string IDs for keybindings e.g.
local function LoadStringIds()
	-- Bindings
	ZO_CreateStringId("PCHAT_AUTOMSG_NAME_DEFAULT_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_NAME_DEFAULT_TEXT))
	ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT))
	ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT))
	ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT))
	ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT))
	ZO_CreateStringId("PCHAT_AUTOMSG_NAME_HEADER", GetString(PCHAT_PCHAT_AUTOMSG_NAME_HEADER))
	ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_HEADER", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_HEADER))
	ZO_CreateStringId("PCHAT_AUTOMSG_ADD_TITLE_HEADER", GetString(PCHAT_PCHAT_AUTOMSG_ADD_TITLE_HEADER))
	ZO_CreateStringId("PCHAT_AUTOMSG_EDIT_TITLE_HEADER", GetString(PCHAT_PCHAT_AUTOMSG_EDIT_TITLE_HEADER))
	ZO_CreateStringId("PCHAT_AUTOMSG_ADD_AUTO_MSG", GetString(PCHAT_PCHAT_AUTOMSG_ADD_AUTO_MSG))
	ZO_CreateStringId("PCHAT_AUTOMSG_EDIT_AUTO_MSG", GetString(PCHAT_PCHAT_AUTOMSG_EDIT_AUTO_MSG))
	ZO_CreateStringId("SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG", GetString(PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG))
	ZO_CreateStringId("PCHAT_AUTOMSG_REMOVE_AUTO_MSG", GetString(PCHAT_PCHAT_AUTOMSG_REMOVE_AUTO_MSG))

	ZO_CreateStringId("SI_BINDING_NAME_PCHAT_SWITCH_TAB", GetString(PCHAT_SWITCHTONEXTTABBINDING))
	ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TOGGLE_CHAT_WINDOW", GetString(PCHAT_TOGGLECHATBINDING))
	ZO_CreateStringId("SI_BINDING_NAME_PCHAT_WHISPER_MY_TARGET", GetString(PCHAT_WHISPMYTARGETBINDING))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_1", GetString(PCHAT_Tab1))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_2", GetString(PCHAT_Tab2))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_3", GetString(PCHAT_Tab3))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_4", GetString(PCHAT_Tab4))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_5", GetString(PCHAT_Tab5))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_6", GetString(PCHAT_Tab6))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_7", GetString(PCHAT_Tab7))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_8", GetString(PCHAT_Tab8))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_9", GetString(PCHAT_Tab9))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_10", GetString(PCHAT_Tab10))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_11", GetString(PCHAT_Tab11))
	ZO_CreateStringId("SI_BINDING_NAME_TAB_12", GetString(PCHAT_Tab12))
end

--Load the slash commands
local function LoadSlashCommands()
	-- Register Slash commands
	SLASH_COMMANDS["/msg"] = pChat_ShowAutoMsg
end

-- Please note that some things are delayed in OnPlayerActivated() because Chat isn't ready when this function triggers
local function OnAddonLoaded(_, addonName)
	--Protect
	if addonName == ADDON_NAME then
		eventPlayerActivatedChecksDone = 0

		--Prepare variables
		PrepareVars()

		--Load early hooks before chat system is ready e.g.
		LoadEarlyHooks()

		--Load the libraries (again)
		LoadLibraries()

		--Load keybinding and other text IDs
		LoadStringIds()

		--Load slash commands
		LoadSlashCommands()

		--Load the SV and LAM panel
		db = pChat.InitializeSettings(pChatData, ADDON_NAME, PCHAT_CHANNEL_NONE, getTabNames, UpdateCharCorrespondanceTableChannelNames, ConvertHexToRGBA, ConvertRGBToHex, SyncChatConfig, ChangeChatWindowDarkness, ChangeChatFont, AddCustomChannelSwitches, RemoveCustomChannelSwitches, logger)

		--Init some tables of the addon
		InitTables()

		-- Will set Keybind for "switch to next tab" if needed
		SetSwitchToNextBinding()

		-- Will change font if needed
		ChangeChatFont()

		-- Automated messages
        pChat.InitializeAutomatedMessages(pChatData, db, ADDON_NAME)

		-- Minimize Chat in Menus
		MinimizeChatInMenus()

		--Load some hookds
		LoadHooks()

        local SpamFilter = pChat.InitializeSpamFilter(pChatData, db, PCHAT_CHANNEL_SAY, subloggerVerbose)
        local FormatMessage, FormatSysMessage = pChat.InitializeMessageFormatters(pChatData, db, PCHAT_LINK, PCHAT_URL_CHAN, SpamFilter, GetChannelColors, CreateTimestamp, StorelineNumber, OnIMReceived, logger, subloggerVerbose)

        -- For compatibility. Called by others addons.
        pChat.FormatMessage = FormatMessage
        pChat.formatSysMessage = FormatSysMessage
        pChat_FormatSysMessage = FormatSysMessage

		-- Because ChatSystem is loaded after EVENT_ADDON_LOADED triggers, we use 1st EVENT_PLAYER_ACTIVATED wich is run bit after
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

		-- Register OnSelfJoinedGuild with EVENT_GUILD_SELF_JOINED_GUILD
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_SELF_JOINED_GUILD, OnSelfJoinedGuild)
		-- Register OnSelfLeftGuild with EVENT_GUILD_SELF_LEFT_GUILD
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_SELF_LEFT_GUILD, OnSelfLeftGuild)

		-- Whisp my target
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)

		-- Party switches
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)

		-- Unregisters
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

		--Pointers to pChatData and SavedVariables
		pChat.pChatData = pChatData
		pChat.db = db

		--IM Features
		pChat.InitializeIncomingMessages(pChatData, db, constTabNameTemplate, subloggerVerbose)

		--Set variable that addon was laoded
		isAddonLoaded = true
	end
	
end

--Handled by keybind
function pChat_ToggleChat()
	
	if CHAT_SYSTEM:IsMinimized() then
		CHAT_SYSTEM:Maximize()
	else
		CHAT_SYSTEM:Minimize()
	end
	
end

-- Called by bindings
function pChat_WhispMyTarget()
	if targetToWhisp then
		CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, targetToWhisp)
	end
end


-- For compatibility. Called by others addons.
function pChat_GetChannelColors(channel, from)
	return GetChannelColors(channel, from)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
