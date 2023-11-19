local CONSTANTS = pChat.CONSTANTS
local apiVersion = CONSTANTS.API_VERSION

local chatChannelLangToLangStr = CONSTANTS.chatChannelLangToLangStr

do
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

    pChat.getCharactersOfAccount = getCharactersOfAccount
end

do
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

    -- Substract XX from a color (darker)
    local function DarkenRGBColor(r, g, b, value, divisorPercent)
        if not value or value <= 0 then return r,g,b end
        divisorPercent = divisorPercent or 30
        if divisorPercent < 10 then divisorPercent = 10 end
        if divisorPercent > 90 then divisorPercent = 90 end
        local divisor = divisorPercent * 10
        -- Scale is from 0-100 so divide per 300 will maximise difference at 0.33 (*2)
        r = math.max(r - (value / divisor),0)
        g = math.max(g - (value / divisor),0)
        b = math.max(b - (value / divisor),0)
        return r,g,b
    end

     -- Add XX to a color (brighter)
    local function LightenRGBColor(r, g, b, value, divisorPercent)
        if not value or value <= 0 then return r,g,b end
        divisorPercent = divisorPercent or 75
        if divisorPercent < 10 then divisorPercent = 10 end
        if divisorPercent > 90 then divisorPercent = 90 end
        local divisor = divisorPercent * 10
        r = math.min(r + (value / divisor),1)
        g = math.min(g + (value / divisor),1)
        b = math.min(b + (value / divisor),1)
        return r,g,b
    end

    local function GetChannelColors(channel, from)
        local db = pChat.db

        --Use ESO standard colors?
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
            --elseif db.allZonesSameColour and (channel >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channel <= CHAT_CHANNEL_ZONE_LANGUAGE_5) then
            elseif db.allZonesSameColour and chatChannelLangToLangStr[channel] ~= nil then
                rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_ZONE_LANGUAGE_1)
            elseif channel == CHAT_CHANNEL_PARTY and from and db.groupLeader and zo_strformat(SI_UNIT_NAME, from) == GetUnitName(GetGroupLeaderUnitTag()) then
                rESO, gESO, bESO = ConvertHexToRGBA(db.colours["groupleader"])
            else
                rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(channel)
            end

            -- Set right colour to left colour - cause ESO colors are rewritten, if one color is not rewritten
            if db.oneColour == true then
            pChat.lcol = ConvertRGBToHex(rESO, gESO, bESO)
            pChat.rcol = pChat.lcol
            else
            --Change name and text brightness?
            pChat.lcol = ConvertRGBToHex(DarkenRGBColor(rESO,gESO,bESO, db.diffforESOcolors, 100-db.diffChatColorsDarkenValue))
            pChat.rcol = ConvertRGBToHex(LightenRGBColor(rESO,gESO,bESO, db.diffforESOcolors, 100-db.diffChatColorsLightenValue))
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
            --elseif db.allZonesSameColour and (channel >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channel <= CHAT_CHANNEL_ZONE_LANGUAGE_5) then
            elseif db.allZonesSameColour and chatChannelLangToLangStr[channel] ~= nil then
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
            if db.oneColour == true then
                pChat.rcol = pChat.lcol
            else
                --Change name and text brightness?
                local lR, lG, lB, lA = ConvertHexToRGBA(pChat.lcol)
                local rR, rG, rB, rA = ConvertHexToRGBA(pChat.rcol)
                pChat.lcol = ConvertRGBToHex(DarkenRGBColor(lR,lG,lB, db.diffforESOcolors, 100-db.diffChatColorsDarkenValue))
                pChat.rcol = ConvertRGBToHex(LightenRGBColor(rR,rG,rB, db.diffforESOcolors, 100-db.diffChatColorsLightenValue))
            end

        end

        return pChat.lcol, pChat.rcol

    end

    pChat.ConvertRGBToHex = ConvertRGBToHex
    pChat.ConvertHexToRGBA = ConvertHexToRGBA
    pChat.GetChannelColors = GetChannelColors
    pChat.DarkenRGBColor = DarkenRGBColor
    pChat.LightenRGBColor = LightenRGBColor
    -- For compatibility. Called by others addons.
    pChat_GetChannelColors = GetChannelColors
end

do
    -- Return a formatted time
    local function CreateTimestamp(timeStr, formatStr)
        formatStr = formatStr or pChat.db.timestampFormat

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

    pChat.CreateTimestamp = CreateTimestamp
end


do
    local logger = pChat.logger
    local ChannelInfo = ZO_ChatSystem_GetChannelInfo()
    local g_switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable()

    if GetDisplayName() == "@Baertram" then
        pChat._ChannelInfo = ChannelInfo
        pChat._g_switchLookup = g_switchLookup
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

    local function AddCustomChannelSwitches(channelId, switchesToAdd)
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

    local function RemoveCustomChannelSwitches(channelId, switchesToRemove)
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

    pChat.AddCustomChannelSwitches = AddCustomChannelSwitches
    pChat.RemoveCustomChannelSwitches = RemoveCustomChannelSwitches
end

do
    --Chat Tab template names
    local CONTROL_NAME_TEMPLATE = "ZO_ChatWindowTabTemplate%dText"

    local function GetTabTextControl(tabIndex)
        return GetControl(CONTROL_NAME_TEMPLATE:format(tabIndex))
    end

    pChat.GetTabTextControl = GetTabTextControl
end

do
    --pChat internally uses some chat_channel codes differently from ZOs standard codes,
    --e.g.instead of CHAT_CHANNEL_SAY (0) -> CONSTANTS.PCHAT_CHANNEL_SAY (98) -> maybe because of 0 based table indices?
    local function mapChatChannelToPChatChannel(chatChannel)
        if chatChannel == CHAT_CHANNEL_SAY then
            return CONSTANTS.PCHAT_CHANNEL_SAY
        end
        return chatChannel
    end
    pChat.mapChatChannelToPChatChannel = mapChatChannelToPChatChannel

    local function mapPChatChannelToChatChannel(pChatChannel)
        if pChatChannel == CONSTANTS.PCHAT_CHANNEL_SAY then
            return CHAT_CHANNEL_SAY
        end
        return pChatChannel
    end
    pChat.mapPChatChannelToChatChannel = mapPChatChannelToChatChannel
end

--Baertram, 2021-06-06
do
    local function showBackupReminder()
        local doShowReminderDialog = false
        local settings = pChat.db

        if settings.backupYourSavedVariablesReminder == true then
            local lastSevenDaysInMs = 604800000 --last 7 days in MS: 7 * 24 * 60 * 60 * 1000

            local backupSvRemindersDoneTable = settings.backupYourSavedVariablesReminderDone[apiVersion]
            if backupSvRemindersDoneTable ~= nil then
                if not backupSvRemindersDoneTable.reminded then
                    --Show the backup your SavedVariables reminder dialog now!
                    doShowReminderDialog = true
                else
                    --Check if the last reminder was 1 week in the past
                    if not backupSvRemindersDoneTable.timestamp then
                        doShowReminderDialog = true
                    else
                        local nowMs = pChat.lastBackupReminderDateTime
                        if nowMs == nil then nowMs = GetTimeStamp() end
                        local lastApiReminder = backupSvRemindersDoneTable.timestamp
                        if (nowMs - lastApiReminder) >= lastSevenDaysInMs then
                            doShowReminderDialog = true
                        end
                    end
                end
            else
                --APIversion was not reminded yet: Remind now
                doShowReminderDialog = true
            end

            if doShowReminderDialog == true then
                local lastBackupReminderDateTime = GetTimeStamp()
                pChat.lastBackupReminderDateTime = lastBackupReminderDateTime
			    pChat.lastBackupReminderDoneStr = os.date("%c", lastBackupReminderDateTime)
--d("[pchat]Reminding you to backup your SavedVariables now! Last reminder done: " .. pChat.lastBackupReminderDoneStr)

                --Update the settings "last reminded for APIversion"
                pChat.db.backupYourSavedVariablesReminderDone[apiVersion] = {
                    reminded = true,
                    timestamp = lastBackupReminderDateTime,
                }
                ZO_Dialogs_ShowDialog("PCHAT_BACKUP_SV_REMINDER", nil, nil, nil)
            end
		end
    end
    pChat.ShowBackupReminder = showBackupReminder
end

do
    --local diceRollTemplateStr = GetString(SI_RANDOM_ROLL_RANGE_RESULT)
    local RANDOM_ROLL_TEXTURE = zo_iconFormat("EsoUI/Art/Miscellaneous/roll_dice.dds")
    function pChat.IsDiceRollSystemMessage(messageTxt)
        if string.find(messageTxt, RANDOM_ROLL_TEXTURE, 1, true) ~= nil then
            return true
        end
        return false
    end
end