--=======================================================================================================================================
--Known problems/bugs:
--Last updated: 2020-02-28
--Total number: 2
------------------------------------------------------------------------------------------------------------------------
--#2    2020-02-28 Baetram, bug: New selection for @accountName/character chat prefix will only show /charactername (@accountName is missing) during whispers,
--      if clicked on a character in the chat to whisper him/her
------------------------------------------------------------------------------------------------------------------------
--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn info
--======================================================================================================================
-- Common
local ADDON_NAME    = "pChat"

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

--PCHAT_LINK format : ZO_LinkHandler_CreateLink(message, nil, PCHAT_LINK, data)
--message = message to display, nil (ignored by ZO_LinkHandler_CreateLink), PCHAT_LINK : declaration
--data : strings separated by ":"
--1st arg is chancode like CHAT_CHANNEL_GUILD_1

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
    --  if not pChat.LCM and LibChatMessage then
    --      pChat.LCM = LibChatMessage(ADDON_NAME, "pC")
    --      if logger then logger:Debug("Library 'LibChatMessage' detected") end
    --  end
end
--Early try to load libs (done again in EVENT_ADD_ON_LOADED)
LoadLibraries()

--======================================================================================================================
-- Helper functions
--======================================================================================================================
local AddCustomChannelSwitches, RemoveCustomChannelSwitches

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


-- Rewrite of a core function
do
    local parts = {}
    local chatSystem = CHAT_SYSTEM
    local originalAddCommandHistory = chatSystem.textEntry.AddCommandHistory
    function chatSystem.textEntry:AddCommandHistory(text)
        -- Don't add the switch when chat is restored
        if db.addChannelAndTargetToHistory and pChatData.isAddonInitialized then
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

local function OnReticleTargetChanged()
    if IsUnitPlayer("reticleover") then
        targetToWhisp = GetUnitName("reticleover")
    end
end

do
    -- we want to return pChat colors when the setting for eso colors is not enabled
    -- TODO investigate how we can use SetChatCategoryColor, so GetChatCategoryColor returns the value directly
    local originalZO_ChatSystem_GetCategoryColorFromChannel = ZO_ChatSystem_GetCategoryColorFromChannel
    function ZO_ChatSystem_GetCategoryColorFromChannel(channelId)
        if pChatData.isAddonLoaded and not db.useESOcolors then
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


-- Rewrite of core function
do
    -- we try to set the alert color for the tab buttons, but as TAB_ALERT_TEXT_COLOR is local we have to intercept the call to ZO_TabButton_Text_SetTextColor
    -- this is obviously not ideal, but until ZOS adds a way to set the alert color it's the easiest way
    local originalZO_TabButton_Text_SetTextColor = ZO_TabButton_Text_SetTextColor
    local lastColor, cachedColor
    function ZO_TabButton_Text_SetTextColor(button, color)
        if(button:GetOwningWindow() == ZO_ChatWindow) then
            if(db.colours.tabwarning ~= lastColor) then
                lastColor = db.colours.tabwarning
                cachedColor = ZO_ColorDef:New(ConvertHexToRGBA(lastColor))
            end
            originalZO_TabButton_Text_SetTextColor(button, cachedColor)
        else
            originalZO_TabButton_Text_SetTextColor(button, color)
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
            num     = guildNum,
            id      = guildId,
            name    = guildName,
        }
    end
end


-- Triggered by EVENT_GUILD_SELF_JOINED_GUILD
local function OnSelfJoinedGuild(_, guildServerId, characterName, guildId)

    -- It will rebuild optionsTable and recreate tables if user didn't went in this section before
    pChat.BuildLAMPanel()

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
    if pChatData.isAddonLoaded and not eventPlayerActivatedCheckRunning then
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

        if pChatData.isAddonLoaded then
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

            -- Rebuild Lam Panel
            pChat.BuildLAMPanel()

            -- Chat Tab setup
            pChat.SetupChatTabs(db)

            -- Chat Config setup
            pChat.ApplyChatConfig()

            --Update the guilds custom tags (next to entry box): Add them to the chat channels of table ChannelInfo
            UpdateCharCorrespondanceTableChannelNames()

            --Update teh guild's custom channel switches: Add them to the chat switches of table ZO_ChatSystem_GetChannelSwitchLookupTable
            UpdateGuildCorrespondanceTableSwitches()

            -- Save all category colors
            SaveGuildIndexes()

            -- Handle Copy text
            pChat.InitializeCopyHandler(pChatData, db, PCHAT_URL_CHAN, PCHAT_LINK)

            -- Restore History if needed
            pChat.RestoreChatHistory()

            pChatData.isAddonInitialized = true

            EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
            logger:Debug("EVENT_PLAYER_ACTIVATED - End: Addon was initialized")
        end
    end
end


-- Runs whenever "me" left a guild (or get kicked)
local function OnSelfLeftGuild(_, guildServerId, characterName, guildId)

    -- It will rebuild optionsTable and recreate tables if user didn't went in this section before
    pChat.BuildLAMPanel()

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
                pChat.SetToDefaultChannel()
            end
        end
    end

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
        pChat.SaveChatHistory(1)
        pChat.SaveChatConfig()
    end)

    ZO_PreHook("SetCVar", function()
        pChat.SaveChatHistory(1)
        pChat.SaveChatConfig()
    end)

    ZO_PreHook("Logout", function()
        pChat.SaveChatHistory(2)
        pChat.SaveChatConfig()
    end)

    ZO_PreHook("Quit", function()
        pChat.SaveChatHistory(3)
        pChat.SaveChatConfig()
    end)


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

        -- prepare chat tab functions
        pChat.InitializeChatTabs(pChatData, constTabNameTemplate)

        --Load the SV and LAM panel
        db = pChat.InitializeSettings(pChatData, ADDON_NAME, PCHAT_CHANNEL_NONE, UpdateCharCorrespondanceTableChannelNames, ConvertHexToRGBA, ConvertRGBToHex, AddCustomChannelSwitches, RemoveCustomChannelSwitches, logger)

        -- set up channel names
        UpdateCharCorrespondanceTableChannelNames()

        -- prepare chat history functionality
        pChat.InitializeChatHistory(pChatData, db, PCHAT_CHANNEL_SAY, PCHAT_CHANNEL_NONE, constTabNameTemplate, CreateTimestamp, subloggerVerbose)


        -- Automated messages
        pChat.InitializeAutomatedMessages(pChatData, db, ADDON_NAME)

        --Load some hookds
        LoadHooks()

        -- Initialize Chat Config features
        pChat.InitializeChatConfig(pChatData, db, PCHAT_CHANNEL_NONE)

        local SpamFilter = pChat.InitializeSpamFilter(pChatData, db, PCHAT_CHANNEL_SAY, subloggerVerbose)
        local FormatMessage, FormatSysMessage = pChat.InitializeMessageFormatters(pChatData, db, PCHAT_LINK, PCHAT_URL_CHAN, SpamFilter, GetChannelColors, CreateTimestamp, logger, subloggerVerbose)

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
        pChatData.isAddonLoaded = true
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
