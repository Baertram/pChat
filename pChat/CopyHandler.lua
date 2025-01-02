local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

local EM = EVENT_MANAGER

local ChatSys = CONSTANTS.CHAT_SYSTEM


local tos = tostring
local strfin = string.find
local strsub = string.sub
local strlow = string.lower
local strlen = string.len
local strbyt = string.byte
local tins = table.insert


--Editbox max characters possible - 20000
local editBoxMaxCharacters = 20000

-- pChat Chat Copy Options OBJECT
pChat.ChatCopyOptions = nil
local mapChatChannelToPChatChannel = pChat.mapChatChannelToPChatChannel
local mapPChatChannelToChatChannel = pChat.mapPChatChannelToChatChannel


local chatChannelLangToLangStr = CONSTANTS.chatChannelLangToLangStr
local chatChannel2Name = CONSTANTS.chatChannel2Name

--Search UI
local pChat_searchUIMasterList = {}

--Functions
local isMonsterChatChannel = pChat.IsMonsterChatChannel
local sendMailToPlayer = pChat.SendMailToPlayer
local checkDisplayName
local getPortTypeFromName

-------------------------------------------------------------
-- Helper functions --
-------------------------------------------------------------
-- Split text, courtesy of LibOrangUtils, modified to handle multibyte characters
local function str_lensplit(text, maxChars)

    local ret                   = {}
    local text_len              = strlen(text)
    local UTFAditionalBytes = 0
    local fromWithUTFShift  = 0
    local doCut                 = true

    if(text_len <= maxChars) then
        ret[#ret+1] = text
    else

        local splittedStart = 0
        local splittedEnd = splittedStart + maxChars - 1

        local splittedString
        while doCut do

            if UTFAditionalBytes > 0 then
                fromWithUTFShift = UTFAditionalBytes
            else
                fromWithUTFShift = 0
            end

            UTFAditionalBytes = 0

            splittedEnd = splittedStart + maxChars - 1

            if(splittedEnd >= text_len) then
                splittedEnd = text_len
                doCut = false
            elseif (strbyt(text, splittedEnd, splittedEnd)) > 128 then
                UTFAditionalBytes = 1

                local lastByte = splittedString and strbyt(splittedString, -1) or 0
                local beforeLastByte = splittedString and strbyt(splittedString, -2, -2) or 0

                if (lastByte < 128) then
                    --
                elseif lastByte >= 128 and lastByte < 192 then

                    if beforeLastByte >= 192 and beforeLastByte < 224 then
                        --
                    elseif beforeLastByte >= 128 and beforeLastByte < 192 then
                        --
                    elseif beforeLastByte >= 224 and beforeLastByte < 240 then
                        UTFAditionalBytes = 1
                    end

                    splittedEnd = splittedEnd + UTFAditionalBytes
                    splittedString = text:sub(splittedStart, splittedEnd)

                elseif lastByte >= 192 and lastByte < 224 then
                    UTFAditionalBytes = 1
                    splittedEnd = splittedEnd + UTFAditionalBytes
                elseif lastByte >= 224 and lastByte < 240 then
                    UTFAditionalBytes = 2
                    splittedEnd = splittedEnd + UTFAditionalBytes
                end

            end

            --ret = ret+1
            ret[#ret+1] = strsub(text, splittedStart, splittedEnd)

            splittedStart = splittedEnd + 1

        end
    end
    return ret
end

-- Set copied text into text entry, if possible
local function CopyToTextEntry(message)

    -- Max of inputbox is 350 chars
    if strlen(message) <= CONSTANTS.maxChatCharCount then
        if ChatSys.textEntry:GetText() == "" then
            ChatSys.textEntry:Open(message)
            ZO_ChatWindowTextEntryEditBox:SelectAll()
        end
    end

end

--local DISPLAY_NAME_PREFIX_BYTE = 64
local function IsDisplayName(str, offset)
    --offset = offset or 1
    --return str:byte(offset) == DISPLAY_NAME_PREFIX_BYTE
    return IsDecoratedDisplayName(str)
end
pChat.IsDisplayName = IsDisplayName


-- Get the @Account and charatcerName from the actual right clicked line
local function GetAccountAndCharacterNameFromLine(numLine, chatChannel)
    local db = pChat.db
    checkDisplayName = checkDisplayName or pChat.checkDisplayName

    local characterLevel
    local showCharacterLevelInContextMenuAtChat = db.showCharacterLevelInContextMenuAtChat
    local guildId
    local guildIndex
    local isOnline = false
    local zoneNameOfPlayer

    if not numLine or not db.LineStrings then return end
    local lineData = db.LineStrings[numLine]
    if not lineData then return end

    local rawFrom = lineData.rawFrom
    local accountName, accountNameGuildOrFriend
    local characterName --db.LineStrings[numLine].rawLine -- rawLine may contain "[20:45:49] Dead Shot x: vrg 2t  4dd link achive", or "[20:45:38] [FTS] @Baerkloppt/Gammal Björn: Is any crafter available depending on your pChat settings :-(

    if rawFrom ~= nil and rawFrom ~= "" then
        --rawFrom is an @accountName
        if not IsDisplayName(rawFrom) then
            characterName = rawFrom
        else
            accountName = rawFrom
        end
    end
--d(">RAWFROM: " .. tostring(rawFrom) .. ", characterName: " ..tostring(characterName) ..", accountName: " ..tostring(accountName))

--------------------------------------------------------------------------------------------------------------------
--- Get the @account and character name from caht line (respecting ESO and pChat settings - how is it currently setup at that chat channel)
    local accountAndMaybeCharName
    --rawValue contains the link for the displayName, guild etc., depending on the chatChannel
    --e.g. could be |H0:display:@Baerkloppt|h, or "|c8F8F8F[20:46:09] |r|cb99e5a|H0:character:Bubamara O^Mx|h or "|c8F8F8F[20:46:30] |r|cb99e5a|H0:character:grey'ar^Fx|hGrey'ar|h: |r|cbeae82|H1:guild:732024|hCadwell's Gefolge|h etc.
    local rawValue = lineData.rawValue
    if rawValue ~= nil then
        local characterPosStart, characterPosEnd = strfin(rawValue, "%|H%d%:character%:.*%|h.*%|h%:")
--d(">CHAR characterPosStart: " .. tostring(characterPosStart) .. ", characterPosEnd: " ..tostring(characterPosEnd) ..", rawValue: " ..tostring(rawValue))
        if characterPosStart ~= nil and characterPosEnd ~= nil then
            local startPos = characterPosStart + 12 -- after the :character:
            local startPosCharNameReal = string.find(rawValue, "%|h", startPos)
            if startPosCharNameReal ~= nil then
                local endPos = characterPosEnd - 3 --before the |h:
                accountAndMaybeCharName = string.sub(rawValue, startPosCharNameReal + 2, endPos)
--d(">CHARACTER startPos: " .. tostring(startPos) .. ", endPos: " ..tostring(endPos) ..", accountAndMaybeCharName: " ..tostring(accountAndMaybeCharName))
            end
       end

        if accountAndMaybeCharName == nil then
            local accountPosStart, accountPosEnd = strfin(rawValue, "%|H%d%:display%:%@.*%|h%@.*%|h%:")
--d(">ACCOUNT accountPosStart: " .. tostring(accountPosStart) .. ", accountPosEnd: " ..tostring(accountPosEnd) ..", rawValue: " ..tostring(rawValue))
            if accountPosStart ~= nil and accountPosEnd ~= nil then
                local startPos = strfin(rawValue, "%|h%@", accountPosStart + 12) -- after the :display:
                local endPos = accountPosEnd - 3 --before the |h:
                accountAndMaybeCharName = strsub(rawValue, startPos + 2, endPos)
                --d(">ACCOUNT startPos: " .. tostring(startPos) .. ", endPos: " ..tostring(endPos) ..", accountAndMaybeCharName: " ..tostring(accountAndMaybeCharName))
            else
                --Charactername@AccountName
                --"|H0:display:@Baertram|hZaubärbuch@Baertram|h: |r|cc3f0c2test6|r"
                accountPosStart, accountPosEnd = strfin(rawValue, "%|H%d%:display%:%@.*%|h.*%@.*%|h%:")
--d(">ACCOUNT accountPosStart2: " .. tostring(accountPosStart) .. ", accountPosEnd2: " ..tostring(accountPosEnd) ..", rawValue: " ..tostring(rawValue))
                if accountPosStart ~= nil and accountPosEnd ~= nil then
                    local startPos = strfin(rawValue, "%|h.*%@.*%|h%:", accountPosStart + 12) -- after the :display:
                    --local subString = strsub(rawValue, startPos)
                    local endPos = strfin(rawValue, "%|h%:", startPos) --find the |h:
                    accountAndMaybeCharName = strsub(rawValue, startPos + 2, endPos - 1)
--d(">ACCOUNT startPos2: " .. tostring(startPos) .. ", endPos2: " ..tostring(endPos) ..", accountAndMaybeCharName: " ..tostring(accountAndMaybeCharName))
                end
            end
        end

        if accountAndMaybeCharName ~= nil and accountAndMaybeCharName ~= "" then
            --Check if the chatChannel's settings contain the @displayName/charName or charName/@displayName etc. and
            --get the values from the accountAndMaybeCharName
            --[[
                db.formatguild[guildId]
                db.groupNames
                db.geoChannelsFormat
            ]]
            local chatChannelToFormatNameVar = {
                --Group
                [CHAT_CHANNEL_PARTY] = "groupNames",
                --Guilds
                [CHAT_CHANNEL_GUILD_1] = "formatguild", --[guildId]
                [CHAT_CHANNEL_GUILD_2] = "formatguild", --[guildId]
                [CHAT_CHANNEL_GUILD_3] = "formatguild", --[guildId]
                [CHAT_CHANNEL_GUILD_4] = "formatguild", --[guildId]
                [CHAT_CHANNEL_GUILD_5] = "formatguild", --[guildId]
                [CHAT_CHANNEL_OFFICER_1] = "formatguild", --[guildId]
                [CHAT_CHANNEL_OFFICER_2] = "formatguild", --[guildId]
                [CHAT_CHANNEL_OFFICER_3] = "formatguild", --[guildId]
                [CHAT_CHANNEL_OFFICER_4] = "formatguild", --[guildId]
                [CHAT_CHANNEL_OFFICER_5] = "formatguild", --[guildId]
                --All others
                --"geoChannelsFormat"
            }
            local chatChannelGuildToGuildIndex = {
                [CHAT_CHANNEL_GUILD_1] = 1,
                [CHAT_CHANNEL_GUILD_2] = 2,
                [CHAT_CHANNEL_GUILD_3] = 3,
                [CHAT_CHANNEL_GUILD_4] = 4,
                [CHAT_CHANNEL_GUILD_5] = 5,
                [CHAT_CHANNEL_OFFICER_1] = 1,
                [CHAT_CHANNEL_OFFICER_2] = 2,
                [CHAT_CHANNEL_OFFICER_3] = 3,
                [CHAT_CHANNEL_OFFICER_4] = 4,
                [CHAT_CHANNEL_OFFICER_5] = 5,
            }

            local dbFormatNameVar = chatChannelToFormatNameVar[chatChannel]
            dbFormatNameVar = dbFormatNameVar or "geoChannelsFormat"
            local isGuildChatChannel = dbFormatNameVar == "formatguild"
            local currentSettingOfFormatNameVar
            if not isGuildChatChannel then
                currentSettingOfFormatNameVar = db[dbFormatNameVar]
            else
                --Get the guildId by help of the chat channel
                local l_guildIndex = chatChannelGuildToGuildIndex[chatChannel]
                if l_guildIndex ~= nil and l_guildIndex >= 1 and l_guildIndex <= MAX_GUILDS then
                    guildId = GetGuildId(l_guildIndex)
                    if guildId ~= 0 then
                        guildIndex = l_guildIndex
                        currentSettingOfFormatNameVar = db[dbFormatNameVar][guildId]
                    end
                end
            end
--d(">>>currentSettingOfFormatNameVar: " ..tostring(currentSettingOfFormatNameVar))
            if currentSettingOfFormatNameVar ~= nil then
                --[[
                --currentSettingOfFormatNameVar contains 1, 2, 3, 4 -> pointing to the formatetr strings in PCHAT_FORMATCHOICE1 to 4 then
                --which basically define the ordr of @account<seperator>character or character<separator>@account etc.
                local formatNameChoices       =  { GetString(PCHAT_FORMATCHOICE1), GetString(PCHAT_FORMATCHOICE2), GetString(PCHAT_FORMATCHOICE3), GetString(PCHAT_FORMATCHOICE4)}
                local formatNameChoicesValues =  { 1, 2, 3, 4}
                ]]
                local separatorChar, accountNamePart, characterNamePart
                --PCHAT_FORMATCHOICE1 = "@UserID",
                if currentSettingOfFormatNameVar == 1 then
                    accountNamePart = accountAndMaybeCharName
                    --PCHAT_FORMATCHOICE2 = "Character Name",
                elseif currentSettingOfFormatNameVar == 2 then
                    characterNamePart = accountAndMaybeCharName
                    --PCHAT_FORMATCHOICE3 = "Character Name@UserID",
                elseif currentSettingOfFormatNameVar == 3 then
                    separatorChar = "@"
                    --PCHAT_FORMATCHOICE4 = "@UserID/Character Name",
                elseif currentSettingOfFormatNameVar == 4 then
                    separatorChar = "/"
                end
--d(">>>separatorChar: " ..tostring(separatorChar) ..", accountNamePart: " ..tostring(accountNamePart) .. ", characterNamePart: " ..tostring(characterNamePart))

                if separatorChar ~= nil then
                    local separatorPos = strfin(accountAndMaybeCharName, separatorChar)
--d(">>>separatorPos: " ..tostring(separatorPos))
                    if separatorPos ~= nil then
                        --PCHAT_FORMATCHOICE3 = "Character Name@UserID",
                        if currentSettingOfFormatNameVar == 3 then
                            characterNamePart = strsub(accountAndMaybeCharName, 1, separatorPos - 1)
                            accountNamePart = strsub(accountAndMaybeCharName, separatorPos)

                            --PCHAT_FORMATCHOICE4 = "@UserID/Character Name",
                        elseif currentSettingOfFormatNameVar == 4 then
                            accountNamePart = strsub(accountAndMaybeCharName, 1, separatorPos - 1)
                            characterNamePart = strsub(accountAndMaybeCharName, separatorPos + 1)
                        end
                    end
                end
--d(">>>characterNamePart: " ..tostring(characterNamePart) .. "; accountNamePart: " ..tostring(accountNamePart))

                if accountName == nil and accountNamePart ~= nil then
                    accountName = accountNamePart
                end
                if characterName == nil and characterNamePart ~= nil then
                    characterName = characterNamePart
                end
            end
        end
    end

    local characterNameOrig = characterName
    local accountNameOrig = accountName

    --Account and character are the account (e.g. at whisper messages)
    local charNameIsAccountName = false
    if accountNameOrig == characterNameOrig and characterName == characterNameOrig and IsDecoratedDisplayName(characterNameOrig) then
        charNameIsAccountName = true
    end

--------------------------------------------------------------------------------------------------------------------
--- Get the character level / CPs, zoneName etc.
--d(">accountNameOrig: " ..tos(accountNameOrig) ..", characterNameOrig: " ..tos(characterNameOrig) .. ", accountName: " .. tos(accountName) .. ", characterName: " ..tos(characterName) .. ", charNameIsAccountName: " ..tos(charNameIsAccountName))

    local accountAndCharName = ""
    if accountName ~= nil and accountName ~= "" then
        accountAndCharName = accountName
    end
    if accountName ~= nil or characterName ~= nil then
        if characterName ~= nil then characterName = zo_strformat(SI_UNIT_NAME, characterName) end

        if showCharacterLevelInContextMenuAtChat == true then

            --Group
            if characterLevel == nil and IsUnitGrouped("player") == true and characterNameOrig ~= nil and IsPlayerInGroup(characterNameOrig) == true then
                local groupSize = GetGroupSize()
                local groupMemberUnitTagOfChar
                --d(">>groupSize: " ..tos(groupSize))
                for i=1, groupSize, 1 do
                    if groupMemberUnitTagOfChar == nil then
                        local groupMemberUnitTag = GetGroupUnitTagByIndex(i)
                        if groupMemberUnitTag ~= nil then
                            local characterNameRaw = GetUnitName(groupMemberUnitTag)
                            local characterNameNonRaw = zo_strformat(SI_UNIT_NAME, characterNameRaw)
                            --d(">>>groupMemberUnitTag: " ..tos(groupMemberUnitTag) .. ", characterNameRaw: " .. tos(characterNameRaw))
                            if characterNameRaw ~= nil and (characterNameRaw == characterNameOrig or characterNameNonRaw == characterName) then
                                groupMemberUnitTagOfChar = groupMemberUnitTag
                                local zoneName = GetUnitZone(groupMemberUnitTagOfChar)
                                if zoneName then
                                    zoneNameOfPlayer = zo_strformat(SI_UNIT_NAME, zoneName)
                                    isOnline = true
                                end
                                break
                            end
                        end
                    end
                end

                if groupMemberUnitTagOfChar ~= nil then
                    --d(">>>>found character at group")
                    local level = GetUnitLevel(groupMemberUnitTagOfChar)
                    local championRank = GetUnitEffectiveChampionPoints(groupMemberUnitTagOfChar)
                    --d(">>>>level: " ..tos(level) .. ", cp: " ..tos(championRank))
                    if championRank > 0 or level >= GetMaxLevel() then
                        characterLevel = "CP" .. tos(championRank)
                    else
                        characterLevel = level
                    end
                end
            end


            --Guild was determined?
            accountNameGuildOrFriend = nil
            if characterLevel == nil then
                --d(">>guildId: " ..tos(guildId) .. ", accountName: " .. tos(accountName))
                if guildId == nil then
                    if (accountName == nil or guildIndex == nil) and characterName ~= nil then
                        accountNameGuildOrFriend, guildIndex, isOnline = checkDisplayName(characterName, "guild", guildIndex)
                        if accountNameGuildOrFriend ~= nil then
                            accountName = accountNameGuildOrFriend
                        end
                    end
                    if guildIndex == nil then
                        accountNameGuildOrFriend, guildIndex, isOnline = checkDisplayName(accountName, "guild", guildIndex)
                        if accountNameGuildOrFriend ~= nil then
                            accountName = accountNameGuildOrFriend
                        end
                    end
                    if guildIndex ~= nil then
                        guildId = GetGuildId(guildIndex)
                        --d(">found account name via charname: " ..tos(accountName) .. ", guildId: " ..tos(guildId))
                    end
                end
                local memberIndex
                if accountName ~= nil and guildId ~= nil then
                    --Get guildMemberData from guildRoster, compare account and get it's level then
                    memberIndex = GetGuildMemberIndexFromDisplayName(guildId, accountName)
                end
                if memberIndex ~= nil then
                    local hasCharacter, charName, _zoneName, _classType, _alliance, level, championRank = GetGuildMemberCharacterInfo(guildId, memberIndex)
                    if not isOnline then
                        local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, memberIndex)
                        if playerStatus ~= PLAYER_STATUS_OFFLINE then
                            isOnline = true
                        end
                    end
                    --d(">>>hasCharacter: " .. tos(hasCharacter) .. ", memberIndex: " ..tos(memberIndex) .. ", charName: " ..tos(charName) .. "/characterName: " ..tos(characterName) .. "/characterNameOrig:" .. tos(characterNameOrig) .. ", level: " ..tos(level) .. ", cp: " ..tos(championRank).. ", isOnline: " ..tos(isOnline))
                    local charNameClean = zo_strformat(SI_UNIT_NAME, charName)
                    zoneNameOfPlayer = zo_strformat(SI_UNIT_NAME, _zoneName)

                    --Charactername logged in is different at the moment (compared to the chat message char name): So show the new "last logged in" one
                    local charNameMatches = (charNameClean == characterName or charNameClean == characterNameOrig or charName == characterName or charName == characterNameOrig and true) or false
                    if hasCharacter == true and charNameMatches then
                        --d(">>>>found matching character at guild")
                        if championRank > 0 or level >= GetMaxLevel() then
                            characterLevel = "CP" .. tos(championRank)
                        else
                            characterLevel = level
                        end
                    elseif hasCharacter == true and not charNameMatches then
                        --d(">>>>found another logged in character at guild: " ..tos(charNameClean))
                        characterName = charNameClean

                        if championRank > 0 or level >= GetMaxLevel() then
                            characterLevel = "CP" .. tos(championRank)
                        else
                            characterLevel = level
                        end
                    end
                end
            end

            --Friendslist
            accountNameGuildOrFriend = nil
            if characterLevel == nil then
                local friendIndex
                if accountNameOrig ~= nil then
                    accountNameGuildOrFriend, friendIndex, isOnline = checkDisplayName(accountNameOrig, "friend")
                    if accountNameGuildOrFriend ~= nil then
                        accountName = accountNameGuildOrFriend
                    end
                end
                if (accountNameGuildOrFriend == nil or friendIndex == nil) and characterName ~= nil then
                    accountNameGuildOrFriend, friendIndex, isOnline = checkDisplayName(characterName, "friend")
                    if accountNameGuildOrFriend ~= nil then
                        accountName = accountNameGuildOrFriend
                    end
                end
                --d(">>friendsDisplayName: " ..tos(friendsDisplayName) .. ", friendIndex: " .. tos(friendIndex))
                if accountNameGuildOrFriend ~= nil and friendIndex ~= nil then
                    local hasCharacter, charName, _zoneName, _classType, _alliance, level, championRank = GetFriendCharacterInfo(friendIndex)
                    if not isOnline then
                        local name, note, rankIndex, playerStatus, secsSinceLogoff = GetFriendInfo(friendIndex)
                        if playerStatus ~= PLAYER_STATUS_OFFLINE then
                            isOnline = true
                        end
                    end
                    --d(">>>friendIndex: " ..tos(friendIndex) .. ", charName: " ..tos(charName) .. "/characterName: " ..tos(characterName) .. "/characterNameOrig:" .. tos(characterNameOrig) .. ", level: " ..tos(level) .. ", cp: " ..tos(championRank))
                    local charNameClean = zo_strformat(SI_UNIT_NAME, charName)
                    zoneNameOfPlayer = zo_strformat(SI_UNIT_NAME, _zoneName)
                    --Charactername logged in is different at the moment (compared to the chat message char name): So show the new "last logged in" one
                    local charNameMatches = (charNameClean == characterName or charNameClean == characterNameOrig or charName == characterName or charName == characterNameOrig and true) or false
                    if hasCharacter == true and charNameMatches then
                        --d(">>>>found character at friendslist")
                        if championRank > 0 or level >= GetMaxLevel() then
                            characterLevel = "CP" .. tos(championRank)
                        else
                            characterLevel = level
                        end
                    elseif hasCharacter == true and not charNameMatches then
                        --d(">>>>found another logged in character at friendslist: " ..tos(charNameClean))
                        characterName = charNameClean

                        if championRank > 0 or level >= GetMaxLevel() then
                            characterLevel = "CP" .. tos(championRank)
                        else
                            characterLevel = level
                        end
                    end
                end
            end
        end

        --d("<<<accountAndCharName: " ..tos(accountAndCharName) .. ", rawFrom: " .. tos(rawFrom) ..", accountName: " .. tos(accountName) ..", characterName: " .. tos(characterName) ..", characterLevel: " ..tos(characterLevel) .. ", zoneName: " .. tos(zoneNameOfPlayer) .. ", isOnline: " ..tos(isOnline))

        if characterName ~= accountName then
            accountAndCharName = accountAndCharName or ""
            if accountAndCharName == "" then
                accountAndCharName = characterName
            else
                if characterName ~= nil then
                    accountAndCharName = accountAndCharName .. " / " .. characterName
                end
            end
            accountAndCharName = accountAndCharName or ""
        end
    end
--d("<<<2 characterLevel: " ..tos(characterLevel))
    return accountAndCharName, rawFrom, accountName, characterName, characterLevel, zoneNameOfPlayer, isOnline
end

-- Copy message (only message)
local function CopyMessage(numLine)
    local db = pChat.db
    if not numLine or not db.LineStrings or not db.LineStrings[numLine] then return end
    -- Args are passed as string trought LinkHandlerSystem
    CopyToTextEntry(db.LineStrings[numLine].rawMessage)
end

--Copy line (including timestamp, from, channel, message, etc)
local function CopyLine(numLine)
    local db = pChat.db
    if not numLine or not db.LineStrings or not db.LineStrings[numLine] then return end
    -- Args are passed as string trought LinkHandlerSystem
    CopyToTextEntry(db.LineStrings[numLine].rawLine)
end

-- Copy discussion
-- It will copy all text mark with the same chanCode
-- Todo : Whispers by person
local function CopyDiscussion(chanNumber, numLine)
    local db = pChat.db
    if not numLine or not chanNumber or not db.LineStrings or not db.LineStrings[numLine] then return end

    -- Args are passed as string trought LinkHandlerSystem
    local numChanCode = tonumber(chanNumber)
    -- Whispers sent and received together
    if numChanCode == CHAT_CHANNEL_WHISPER_SENT then
        numChanCode = CHAT_CHANNEL_WHISPER
    elseif numChanCode == CONSTANTS.PCHAT_URL_CHAN then
        numChanCode = db.LineStrings[numLine].channel
    --CHAT_CHANNEL_SAY = 0, does not work properly in tables so pChat internally uses an alternative value 98 for it!
    else
        numChanCode = mapChatChannelToPChatChannel(numChanCode)
    end

    ZO_ClearTable(pChat_searchUIMasterList)

    local stringToCopy = ""
    for k, lineData in ipairs(db.LineStrings) do
        --local lineData = db.LineStrings[k]
        local textToCopy = lineData.rawLine
        if textToCopy ~= nil then
            local wasAdded = false
            if numChanCode == CHAT_CHANNEL_WHISPER then -- or numChanCode == CHAT_CHANNEL_WHISPER_SENT then
                if lineData.channel == CHAT_CHANNEL_WHISPER or lineData.channel == CHAT_CHANNEL_WHISPER_SENT then
                    if stringToCopy == "" then
                        stringToCopy = tostring(textToCopy)
                    else
                        stringToCopy = stringToCopy .. "\r\n" .. tostring(textToCopy)
                    end
                    wasAdded = true
                end
            elseif lineData.channel == numChanCode then
                if stringToCopy == "" then
                    stringToCopy = tostring(textToCopy)
                else
                    stringToCopy = stringToCopy .. "\r\n" .. tostring(textToCopy)
                end
                wasAdded = true
            end
            if wasAdded == true then
                --Build the masterList for the search UI ZO_SortFilterList -> Based on the text to copy (all lines!)
                pChat_searchUIMasterList[#pChat_searchUIMasterList + 1] = lineData
            end
        end
    end

--pChat._debugSearchUIMasterList = pChat_searchUIMasterList

--d(">stringToCopy: " ..tostring(stringToCopy))
    pChat_ShowCopyDialog(stringToCopy, numChanCode)
end

--Check if a chat category (of a chat channel) is enabled in any chat tab's settings
local chatCatgoriesEnabledTable = {}
local function isChatCategoryEnabledInAnyChatTab(chatChannel)
    local isChatCategoryEnabledAtAnyChatTabCheck = false
    if chatChannel and chatChannel ~= "" then
        local actualTab = 1
        local numTabs = #ChatSys.primaryContainer.windows
        local chatCategory = GetChannelCategoryFromChannel(chatChannel)
        if chatCategory then
            if chatCatgoriesEnabledTable[chatCategory] == true then return true end
            while actualTab <= numTabs do
                if IsChatContainerTabCategoryEnabled(1, actualTab, chatCategory) then
                    isChatCategoryEnabledAtAnyChatTabCheck = true
                    chatCatgoriesEnabledTable[chatCategory] = true
                end
                actualTab = actualTab + 1
            end
        end
    end
    return isChatCategoryEnabledAtAnyChatTabCheck
end

-- Copy Whole chat (not tab)
-- Filter it by the channelIds from the pchat copy options dialog
--> Special treatment for CHAT_CHANNEL_SAY (0) -> Is stored internally with CONSTANTS.PCHAT_CHANNEL_SAY (98), so needs
--> to be read from there in the lines!
local function CopyWholeChat(updateShownDialog)
--d("[pChat]CopyWholeChat-updateShownDialog: " ..tostring(updateShownDialog))
    updateShownDialog = updateShownDialog or false
    local db = pChat.db
    chatCatgoriesEnabledTable = {}
    local filteredStringCopy = ""
    local pChatData = pChat.pChatData
    local chatChannelsToFilter = pChatData.chatChannelsToFilter

    ZO_ClearTable(pChat_searchUIMasterList)

    for k, data in ipairs(db.LineStrings) do
        local doAddLine = (updateShownDialog == true or isChatCategoryEnabledInAnyChatTab(data.channel)) or false
        local lineData = db.LineStrings[k]
        if updateShownDialog == true and chatChannelsToFilter then
            doAddLine = false
            local lineDataChannel = lineData.channel
--d(">lineDataChannel: " ..tostring(lineDataChannel))
            for chatChannelToFilter, isActive in pairs(chatChannelsToFilter) do
                if chatChannelToFilter == lineDataChannel and isActive == true then
                    doAddLine = true
                    break
                end
            end
        end
        if doAddLine == true then
            local textToCopy = lineData.rawLine
            if textToCopy ~= nil then
                if filteredStringCopy == "" then
                    filteredStringCopy = tostring(textToCopy)
                else
                    filteredStringCopy = filteredStringCopy .. "\r\n" .. tostring(textToCopy)
                end
                --Build the masterList for the search UI ZO_SortFilterList -> Based on the text to copy (all lines!)
                pChat_searchUIMasterList[#pChat_searchUIMasterList + 1] = lineData
            end
        end
    end
pChat._debugSearchUIMasterList = pChat_searchUIMasterList
    if filteredStringCopy then
        if updateShownDialog == true then
            return filteredStringCopy
        else
            if filteredStringCopy ~= "" then
                pChat_ShowCopyDialog(filteredStringCopy)
            end
        end
    end
end


--------------------------------------------------
-- pChat ChatCopy Options CLASS
--------------------------------------------------
local FILTERS_PER_ROW = 2
local GUILDS_PER_ROW = 2

--defines channels to be combined under one button
local COMBINED_CHANNELS = CONSTANTS.COMBINED_CHANNELS
-- defines channels to skip when building the filter (non guild) section
local SKIP_CHANNELS = CONSTANTS.SKIP_CHANNELS

-- defines the ordering of the filter categories
local CHANNEL_ORDERING_WEIGHT = {
    [CHAT_CATEGORY_SAY] = 10,
    [CHAT_CATEGORY_YELL] = 20,

    [CHAT_CATEGORY_WHISPER_INCOMING] = 30,
    [CHAT_CATEGORY_PARTY] = 40,

    [CHAT_CATEGORY_EMOTE] = 50,
    [CHAT_CATEGORY_MONSTER_SAY] = 60,

    [CHAT_CATEGORY_ZONE] = 80,

    [CHAT_CATEGORY_ZONE_ENGLISH] = 90,
    [CHAT_CATEGORY_ZONE_FRENCH] = 100,
    [CHAT_CATEGORY_ZONE_GERMAN] = 110,
    [CHAT_CATEGORY_ZONE_JAPANESE] = 120,
    [CHAT_CATEGORY_ZONE_RUSSIAN] = 130,
    [CHAT_CATEGORY_ZONE_SPANISH] = 140,
    [CHAT_CATEGORY_ZONE_CHINESE_S] = 150,
}


local chatChannelsToMap = {
    CHAT_CHANNEL_SAY,
    CHAT_CHANNEL_YELL,
    CHAT_CHANNEL_ZONE,
    CHAT_CHANNEL_ZONE_LANGUAGE_1,
    CHAT_CHANNEL_ZONE_LANGUAGE_2,
    CHAT_CHANNEL_ZONE_LANGUAGE_3,
    CHAT_CHANNEL_ZONE_LANGUAGE_4,
    CHAT_CHANNEL_ZONE_LANGUAGE_5,
    CHAT_CHANNEL_ZONE_LANGUAGE_6,
    CHAT_CHANNEL_ZONE_LANGUAGE_7,
    CHAT_CHANNEL_WHISPER,
    CHAT_CHANNEL_WHISPER_SENT,
    CHAT_CHANNEL_PARTY,
    CHAT_CHANNEL_EMOTE,
    CHAT_CHANNEL_SYSTEM,
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
    CHAT_CHANNEL_MONSTER_SAY,
    CHAT_CHANNEL_MONSTER_YELL,
    CHAT_CHANNEL_MONSTER_WHISPER,
    CHAT_CHANNEL_MONSTER_EMOTE,
}

local ChatCategory2ChatChannel = {}
for _, chatChannelId in pairs(chatChannelsToMap) do
    local chatCat = GetChannelCategoryFromChannel(chatChannelId)
    if chatCat then
        ChatCategory2ChatChannel[chatCat] = chatChannelId
    end
end
pChat.ChatCategory2ChatChannel = ChatCategory2ChatChannel



--______________________________________________________________________________________________________________________
--______________________________________________________________________________________________________________________
--______________________________________________________________________________________________________________________
--[[ pChat_SearchUI_List Class ]]--
--______________________________________________________________________________________________________________________
--______________________________________________________________________________________________________________________
--______________________________________________________________________________________________________________________

------------------------------------------------------------------------------------------------------------------------
--SearchUI -  ZO_SortFilterList
------------------------------------------------------------------------------------------------------------------------
local searchUIScrollListSearchTypeDefault = 1
local searchUIScrollListDataTypeDefault = 1
local searchUIScrollListDataTypeXMLVirtualTemplate = "pChatSearchUIRow"
local searchUIScrollListDataTypeXMLVirtualTemplateRowHeight = 90 --this will enable scrollList.mode = SCROLL_LIST_NON_UNIFORM

local searchUIThrottledSearchHistoryHandlerName = "pChatSearchUI_SearchHistoryHandlerName"
local searchUIThrottledSearchHandlerName = "pChatSearchUI_SearchHandlerName"
local searchUIThrottledDelay = 1500             --Start text editbox search after 1,5seconds

local maxSearchHistoryEntries = 10

local SEARCH_TYPE_MESSAGE = CONSTANTS.SEARCH_TYPE_MESSAGE
local SEARCH_TYPE_FROM =    CONSTANTS.SEARCH_TYPE_FROM

--- ZO_SortFilterList
local pChat_SearchUI_List = ZO_SortFilterList:Subclass()

--Called from editbox filters -> OnTextChanged
local function refreshSearchFilters(selfVar, editBoxControl)
    --Start the search now
    selfVar:StartSearch()
end

local function clearSearchHistory(searchType)
    --d("Clear search history, type: " ..tos(searchType))
    local searchHistory = pChat.db.chatSearchHistory
    if ZO_IsTableEmpty(searchHistory[searchType]) then return end
    pChat.db.chatSearchHistory[searchType] = {}
end

local function updateSearchHistory(searchType, searchValue)
    local searchHistory = pChat.db.chatSearchHistory
    searchHistory[searchType] = searchHistory[searchType] or {}
    local searchHistoryOfSearchType = searchHistory[searchType]
    local toSearch = strlow(searchValue)
    if not ZO_IsElementInNumericallyIndexedTable(searchHistoryOfSearchType, toSearch) then
        --Only keep the last 10 search entries
        tins(searchHistory[searchType], 1, searchValue)
        local countEntries = #searchHistory[searchType]
        if countEntries > maxSearchHistoryEntries then
            for i=maxSearchHistoryEntries+1, countEntries, 1 do
                searchHistory[searchType][i] = nil
            end
        end
    end
end

local function updateSearchHistoryDelayed(searchType, searchValue)
    EM:UnregisterForUpdate(searchUIThrottledSearchHistoryHandlerName)
    EM:RegisterForUpdate(searchUIThrottledSearchHistoryHandlerName, 1500, function()
        EM:UnregisterForUpdate(searchUIThrottledSearchHistoryHandlerName)
        updateSearchHistory(searchType, searchValue)
    end)
end

-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()

function pChat_SearchUI_List:New(listParentControl, parentObject)
	local listObject = ZO_SortFilterList.New(self, listParentControl)
    listObject._parentObject = parentObject --Points to e.g. LIBSETS_SEARCH_UI_KEYBOARD object (of class LibSets_SearchUI_Keyboard)
	listObject:Setup()
	return listObject
end

--Setup the scroll list
function pChat_SearchUI_List:Setup( )
	--Scroll UI
	ZO_ScrollList_AddDataType(self.list, searchUIScrollListDataTypeDefault, searchUIScrollListDataTypeXMLVirtualTemplate, searchUIScrollListDataTypeXMLVirtualTemplateRowHeight, function(control, data)
        self:SetupItemRow(control, data)
    end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

    self:SetEmptyText("\n"..GetString(SI_TRADINGHOUSESEARCHOUTCOME2) .. "\n") --No items found, which match your filters and text

	self.masterList = { }

    --Build the sortkeys depending on the settings
    --self:BuildSortKeys() --> Will be called internally in "self.sortHeaderGroup:SelectAndResetSortForKey"
	self.currentSortKey = "rawTimestamp"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey) -- Will call "SortScrollList" internally
	--The sort function
    self.sortFunction = function( listEntry1, listEntry2 )
        if     self.currentSortKey == nil or self.sortKeys[self.currentSortKey] == nil
            or listEntry1.data == nil or listEntry1.data[self.currentSortKey] == nil
            or listEntry2.data == nil or listEntry2.data[self.currentSortKey] == nil then
            return nil
        end
        return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.sortKeys, self.currentSortOrder)
	end

    --Sort headers
	self.headers =                  self.control:GetNamedChild("Headers")
    self.headerTime =               self.headers:GetNamedChild("Time")
    self.headerFrom =               self.headers:GetNamedChild("From")
    self.headerMessage =            self.headers:GetNamedChild("Message")

    --Build initial masterlist via self:BuildMasterList() --> Do not automatically here but only as the searchUI is shown!
    --self:RefreshData()
end

--[[
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()
function pChat_SearchUI_List:CommitScrollList( )
end
]]

--Get the data of the masterlist entries and add it to the list columns
function pChat_SearchUI_List:SetupItemRow(control, data)
    --local clientLang = WL.clientLang or WL.fallbackSetLang
    --d(">>>      [pChat_SearchUI_List:SetupItemRow] " ..tos(data.names[clientLang]))
    control.data = data

    local lastColumn

    local timeColumn       = control:GetNamedChild("Time")
    timeColumn.normalColor = ZO_DEFAULT_TEXT
    timeColumn:ClearAnchors()
    timeColumn:SetAnchor(LEFT, control, nil, 0, 0)
    local dateText = data.date or ""
    timeColumn:SetText(dateText)
    timeColumn:SetHidden(false)

    local fromColumn       = control:GetNamedChild("From")
    fromColumn.normalColor = ZO_DEFAULT_TEXT
    fromColumn:ClearAnchors()
    fromColumn:SetAnchor(LEFT, timeColumn, RIGHT, 0, 0)
    fromColumn:SetText(data.from)
    fromColumn:SetHidden(false)

    local chatChannelColumn = control:GetNamedChild("ChatChannel")
    chatChannelColumn.normalColor = ZO_DEFAULT_TEXT
    chatChannelColumn:ClearAnchors()
    chatChannelColumn:SetAnchor(LEFT, fromColumn, RIGHT, 0, 0)
    chatChannelColumn:SetText(data.chatChannel)
    chatChannelColumn:SetHidden(false)

    local messageColumn = control:GetNamedChild("Message")
    messageColumn:ClearAnchors()
    messageColumn:SetAnchor(LEFT, chatChannelColumn, RIGHT, 0, 0)
    messageColumn:SetText(data.rawMessage or "")
    messageColumn:SetHidden(false)

    --Anchor the last column's right edge to the right edge of the row
    lastColumn = messageColumn
    lastColumn:SetAnchor(RIGHT, control, RIGHT, -10, 0)

    --Set the row to the list now
    ZO_SortFilterList.SetupRow(self, control, data)
end

function pChat_SearchUI_List:CreateEntryForChatMessage(messageId, messageData)
    --local parentObject = self._parentObject -- Get the SearchUI object

    --The row's data table of each item/entry in the ZO_ScrollFilterList
    local itemData = {
        type = searchUIScrollListSearchTypeDefault     -- for the search function -> Processor. !!!Needs to match -> See function self.stringSearch:AddProcessor(searchUIScrollListSearchTypeDefault...)
    }

    --todo: Pass in whole table of message info (for debugging!)
    itemData._pChat_messageData    = messageData

    --Mix in the missing data
    zo_mixin(itemData, messageData)

    itemData.messageId = messageId
    local timeStamp = messageData.rawTimestamp
    local dateTimeStr = ""
    if timeStamp ~= nil and timeStamp >= 0 then
        dateTimeStr = os.date("%c", timeStamp)
    end
    itemData.date = dateTimeStr
    itemData.from = ZO_CachedStrFormat(SI_UNIT_NAME, messageData.rawFrom) or ""
    local chatChannel = mapPChatChannelToChatChannel(messageData.channel)
    itemData.chatChannel = chatChannel2Name[chatChannel] or ""

    itemData.message = messageData.rawMessage or ""

    --Table entry for the ZO_ScrollList data
	return itemData
end

--Build the masterlist based of the sets searched/filtered
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
function pChat_SearchUI_List:BuildMasterList()
--d("[pChat_SearchUI_List:BuildMasterList]")
    self.masterList = {}

    if pChat_searchUIMasterList == nil or ZO_IsTableEmpty(pChat_searchUIMasterList) then return end

    for messageId, messageData in pairs(pChat_searchUIMasterList) do
        table.insert(self.masterList, self:CreateEntryForChatMessage(messageId, messageData))
    end
end

--Filter the scroll list by fiter data
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
function pChat_SearchUI_List:FilterScrollList()
--d("[pChat_SearchUI_List:FilterScrollList]")
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

    --Check the search text of both edit boxes
    local searchInputMessage = self._parentObject.searchMessageEditBoxControl:GetText()
    local searchInputFrom = self._parentObject.searchFromEditBoxControl:GetText()
    local searchIsEmpty = (searchInputMessage == "" and searchInputFrom == "" and true) or false

    for i = 1, #self.masterList do
        --Get the data of each set item
        local data = self.masterList[i]

        local addItemToList = false

        --Search for name/ID text, set bonuses text
        if searchIsEmpty == true or self._parentObject:CheckForMatch(data, searchInputMessage, searchInputFrom) then
            addItemToList = true
        end
        if addItemToList == true then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(searchUIScrollListDataTypeDefault, data))
        end
    end

    --Update the counter
    self:UpdateCounter(scrollData)
end

--The sort keys for the sort headers of the list
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()
function pChat_SearchUI_List:SortScrollList( )
    --Build the sortkeys depending on the settings
    self:BuildSortKeys()
    --Get the current sort header's key and direction
    self.currentSortKey = self.sortHeaderGroup:GetCurrentSortKey()
    self.currentSortOrder = self.sortHeaderGroup:GetSortDirection()
--d("[pChat_SearchUI_List:SortScrollList] sortKey: " .. tos(self.currentSortKey) .. ", sortOrder: " ..tos(self.currentSortOrder))
	if self.currentSortKey ~= nil and self.currentSortOrder ~= nil then
        --Update the scroll list and re-sort it -> Calls "SetupItemRow" internally!
		local scrollData = ZO_ScrollList_GetDataList(self.list)
        if scrollData and #scrollData > 0 then
            table.sort(scrollData, self.sortFunction)
            self:RefreshVisible()
        end
	end
end


--The sort keys for the sort headers of the list
function pChat_SearchUI_List:BuildSortKeys()
    --Get the tiebraker for the 2nd sort after the selected column
    self.sortKeys = {
        --["timestamp"]                  = { isId64          = true, tiebreaker = "name"  }, --isNumeric = true
        --["knownInSetItemCollectionBook"] = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        --["gearId"]                     = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        ["rawTimestamp"]                = { isNumber = true,                  }, --tiebreaker = "message" },
        ["rawFrom"]                     = { caseInsensitive = true,         },
        ["chatChannel"]                 = { caseInsensitive = true,         },
        ["rawMessage"]                  = { caseInsensitive = true          },
    }
end

function pChat_SearchUI_List:UpdateCounter(scrollData)
    --Update the counter (found by search/total) at the bottom right of the scroll list
    local listCountAndTotal = ""
    if self.masterList == nil or (self.masterList ~= nil and #self.masterList == 0) then
        listCountAndTotal = "0 / 0"
    else
        listCountAndTotal = string.format("%d / %d", #scrollData, #self.masterList)
    end
    self._parentObject.searchUICounterControl:SetText(listCountAndTotal)
end



--______________________________________________________________________________________________________________________
--______________________________________________________________________________________________________________________
--______________________________________________________________________________________________________________________
--[[ ChatCopyOptions Class ]]--
--______________________________________________________________________________________________________________________
--______________________________________________________________________________________________________________________
--______________________________________________________________________________________________________________________
local ChatCopyOptions = ZO_Object:Subclass()

function ChatCopyOptions:New(...)
    local options = ZO_Object.New(self)
    return options
end

--Run a function throttled (check if it should run already and overwrite the old call then with a new one to
--prevent running it multiple times in a short time)
function ChatCopyOptions:ThrottledCall(callbackName, timer, callback, ...)
    if not callbackName or callbackName == "" or not callback then return end
    EM:UnregisterForUpdate(callbackName)
    local args = {...}
    local function Update()
        EM:UnregisterForUpdate(callbackName)
        callback(unpack(args))
    end
    EM:RegisterForUpdate(callbackName, timer, Update)
end

local function SetupChatCopyOptionsDialog(control)
    ZO_Dialogs_RegisterCustomDialog("PCHAT_CHAT_COPY_DIALOG",
            {
                customControl = control,
                title =
                {
                    text = PCHAT_COPYXMLTITLE,
                },
                setup = function(self)
                    pChat.ChatCopyOptions:Initialize(control)
                end,
                buttons =
                {
                    --[[
                    --Using the button here will always close the dialog :-(
                    {

                        control =   GetControl(control, "ApplyFilter"),
                        text =      PCHAT_COPYXMLAPPLY,
                        keybind =   "DIALOG_PRIMARY",
                        callback =  function(dialog)
                                        pChat_ChatCopyOptions_OnCommitClicked(control)
                                    end,
                    },
                    ]]
                    {
                        control =   GetControl(control, "Close"),
                        text =      SI_DIALOG_EXIT,
                        keybind =   "DIALOG_NEGATIVE",
                    },
                },
                --[[
                finishedCallback = function()
                end,
                ]]
            })
end

function ChatCopyOptions:UpdateSearchUI()
    --Refresh the ZO_SortFilterList's masterlist data and populate the entries
    if self.isSearchUIShown == true then
        self.searchUIList:RefreshData()
    end
end

function ChatCopyOptions:UpdateEditAndButtons()
    local control = self.control
    local pChatData = pChat.pChatData
    local message = self.message
    if not message then return end

    -- editbox is 20000 chars max
    local maxChars      = editBoxMaxCharacters --change to 10000, for debugging "pages"
    local label     = GetControl(control, "Label")
    local notePrev  = GetControl(control, "NotePrev")
    local noteNext  = GetControl(control, "NoteNext")
    local noteEdit  = GetControl(control, "NoteEdit")

--d("pChat ChatCopyOptions:UpdateEditAndButtons, message: " ..tostring(message))

    if strlen(message) < maxChars then
--d(">1")
        label:SetText(GetString(PCHAT_COPYXMLLABEL))
        noteEdit:SetText(message)
        noteNext:SetHidden(true)
        notePrev:SetHidden(true)
        --DO not use or the scenes with HUDUI and hud will stay switched after closing the dialog
        --control:SetHidden(false)

        noteEdit:SetEditEnabled(false)
        noteEdit:SelectAll()


    else
--d(">2")
        label:SetText(GetString(PCHAT_COPYXMLTOOLONG))
        pChatData.messageTableId = 1
        pChatData.messageTable = str_lensplit(message, maxChars)
        notePrev:SetText(GetString(PCHAT_COPYXMLPREV))
        noteNext:SetText(GetString(PCHAT_COPYXMLNEXT) .. " ( " .. pChatData.messageTableId .. " / " .. #pChatData.messageTable .. " )")
        noteEdit:SetText(pChatData.messageTable[pChatData.messageTableId])
        noteEdit:SetEditEnabled(false)
        noteEdit:SelectAll()

        --DO not use or the scenes with HUDUI and hud will stay switched after closing the dialog
        --control:SetHidden(false)

        noteNext:SetHidden(false)
        notePrev:SetHidden(true)
        noteEdit:TakeFocus()
    end
end

function ChatCopyOptions:Initialize(control)
    if not self.initialized then
        self.control = control
        control.owner = self
        self.filterSection = control:GetNamedChild("FilterSection")
        self.guildSection = control:GetNamedChild("GuildSection")

        local function Reset(p_control)
            p_control:SetHidden(true)
        end

        local function FilterFactory(pool)
            return ZO_ObjectPool_CreateControl("pChat_ChatCopyOptionsFilterEntry", pool, self.filterSection)
        end

        local function GuildFactory(pool)
            return ZO_ObjectPool_CreateControl("pChat_ChatCopyOptionsGuildFilters", pool, self.guildSection)
        end

        self.filterPool = ZO_ObjectPool:New(FilterFactory, Reset)
        self.guildPool = ZO_ObjectPool:New(GuildFactory, Reset)

        self.filterButtons = {}
        self.guildNameLabels = {}
        self:InitializeFilterButtons(control)
        self:InitializeGuildFilters(control)
        self.filteredChannels = {}

        self:InitializeSearchUI(control)

        self.initialized = true
    end

    --[Always run this code as dialog's setup function is called]

    --Get the message
    local message = self.message
    if not message or message == "" then return end
    --Get the selected chatChannel (via ShowDiscussion)
    local chatChannel = self.chatChannel
    --ShowDiscussion (a specific chat channel only) was called?
    local isShowDiscussion = chatChannel ~= nil
--d("[pChat]ChatCopyOptions:Initialize - chatChannel: " ..tostring(chatChannel))
    --Uncheck all checkboxes and enable them again
    self:ResetFilterCheckBoxes()

    --Update the chat tab names and indices
    pChat.getTabNames()
    --Check each chat tab in the chat container and update the checkboxes of the filters:
    --Mark those where any chat channel matching to the enabled chat container chat channels applies
    if pChat.tabIndices and #pChat.tabIndices > 0 then
        local chatContainer = ChatSys.primaryContainer
        if chatContainer then
            if isShowDiscussion == true then
                local pChatData = pChat.pChatData
                local activeTab = pChatData.activeTab
                self:SetCurrentChannelSelections(chatContainer, activeTab, chatChannel, isShowDiscussion)
            else
                for chatTabIndex, _ in ipairs(pChat.tabIndices) do
                    self:SetCurrentChannelSelections(chatContainer, chatTabIndex, chatChannel, isShowDiscussion)
                end
            end
        end
        --Update the button checked state and enabled state to true for the filtered ones.
        --All non-filtered were disabled via self:ResetFilterCheckBoxes()
        for button, isFilterEnabled in pairs(self.filteredChannels) do
            if isFilterEnabled == true then
                --Update their checked state
                button:SetEnabled(isFilterEnabled)
                button:SetMouseEnabled(isFilterEnabled)
                local label = GetControl(button, "Label")
                if label then
                    label:SetMouseEnabled(isFilterEnabled)
                end
                ZO_CheckButton_SetCheckState(button, isFilterEnabled)
            end
        end
    end
    --Update the guild names
    self:UpdateGuildNames()

    --Do not allow more filters if we only show one chatChannel
    local applyFilter = GetControl(control, "ApplyFilter")
    applyFilter:SetText(GetString(PCHAT_COPYXMLAPPLY))
    applyFilter:SetEnabled(not isShowDiscussion)
    applyFilter:SetMouseEnabled(not isShowDiscussion)
    applyFilter:SetHidden(isShowDiscussion)

    --Update the edit box and the buttons + labels
    self:UpdateEditAndButtons()
end

local function FilterComparator(left, right)
    local leftPrimaryCategory = left.channels[1]
    local rightPrimaryCategory = right.channels[1]

    local leftWeight = CHANNEL_ORDERING_WEIGHT[leftPrimaryCategory]
    local rightWeight = CHANNEL_ORDERING_WEIGHT[rightPrimaryCategory]

    if leftWeight and rightWeight then
        return leftWeight < rightWeight
    elseif not leftWeight and not rightWeight then
        return false
    elseif leftWeight then
        return true
    end

    return false
end

do
    local FILTER_PAD_X = 90
    local FILTER_PAD_Y = 0
    local FILTER_WIDTH = 150
    local FILTER_HEIGHT = 27
    local INITIAL_XOFFS = 0
    local INITIAL_YOFFS = 0

    function ChatCopyOptions:InitializeFilterButtons(dialogControl)
        --generate a table of entry data from the chat category header information
        --The checkbox's channel subtable will be the chatCategory! So we need to map it to the chatChannels later on
        local entryData = {}
        local lastEntry = CHAT_CATEGORY_HEADER_COMBAT - 1

        for i = CHAT_CATEGORY_HEADER_CHANNELS, lastEntry do
            if(SKIP_CHANNELS[i] == nil and GetString("SI_CHATCHANNELCATEGORIES", i) ~= "") then
                if(COMBINED_CHANNELS[i] == nil) then
                    entryData[i] =
                    {
                        channels = { i },
                        name = GetString("SI_CHATCHANNELCATEGORIES", i),
                    }
                else
                    --create the entry for those with combined channels just once
                    local parentChannel = COMBINED_CHANNELS[i].parentChannel

                    if(not entryData[parentChannel]) then
                        entryData[parentChannel] =
                        {
                            channels = { },
                            name = GetString(COMBINED_CHANNELS[i].name),
                        }
                    end

                    table.insert(entryData[parentChannel].channels, i)
                end
            end
        end

        --now generate and anchor buttons
        local filterAnchor = ZO_Anchor:New(TOPLEFT, self.filterSection, TOPLEFT, 0, 0)
        local count = 0

        local sortedEntries = {}
        for _, entry in pairs(entryData) do
            sortedEntries[#sortedEntries + 1] = entry
        end

        table.sort(sortedEntries, FilterComparator)

        for _, entry in ipairs(sortedEntries) do
            local filter, key = self.filterPool:AcquireObject()
            filter.key = key

            local button = filter:GetNamedChild("Check")
            ZO_CheckButton_SetLabelText(button, entry.name)
            button.channels = entry.channels
            table.insert(self.filterButtons, button)

            ZO_Anchor_BoxLayout(filterAnchor, filter, count, FILTERS_PER_ROW, FILTER_PAD_X, FILTER_PAD_Y, FILTER_WIDTH, FILTER_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
            count = count + 1
        end
    end

    local GUILD_PAD_X = 90
    local GUILD_PAD_Y = 0
    local GUILD_WIDTH = 150
    local GUILD_HEIGHT = 70

    function ChatCopyOptions:InitializeGuildFilters(dialogControl)
        local guildAnchor = ZO_Anchor:New(TOPLEFT, self.guildSection, TOPLEFT, 0, 0)
        local count = 0

        -- setup and anchor the guild sections
        local maxGuild = CHAT_CATEGORY_HEADER_GUILDS + MAX_GUILDS - 1
        for k = CHAT_CATEGORY_HEADER_GUILDS, maxGuild do
            local guild, key = self.guildPool:AcquireObject()
            guild.key = key

            --local guildFilter = guild:GetNamedChild("Guild")
            --local guildButton = guild:GetNamedChild("Check")
            local guildButton = guild:GetNamedChild("Guild")
            ZO_CheckButton_SetLabelText(guildButton, GetString("SI_CHATCHANNELCATEGORIES", k))
            guildButton.channels = {k}
            table.insert(self.filterButtons, guildButton)

            --local officerFilter = guild:GetNamedChild("Officer")
            --local officerButton = officerFilter:GetNamedChild("Check")
            local officerButton = guild:GetNamedChild("Officer")
            local officerChannel = k + MAX_GUILDS
            ZO_CheckButton_SetLabelText(officerButton, GetString("SI_CHATCHANNELCATEGORIES", officerChannel))
            officerButton.channels = {officerChannel}
            table.insert(self.filterButtons, officerButton)

            local nameLabel = guild:GetNamedChild("GuildName")
            table.insert(self.guildNameLabels, nameLabel)

            ZO_Anchor_BoxLayout(guildAnchor, guild, count, GUILDS_PER_ROW, GUILD_PAD_X, GUILD_PAD_Y, GUILD_WIDTH, GUILD_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
            count = count + 1
        end
    end

    function ChatCopyOptions:InitializeSearchUI(dialogControl)
        local selfVar = self
        self.isSearchUIShown = false
        self.openedSearchUICount = 0

        local searchUIToggleButton = dialogControl:GetNamedChild("ToggleSearch")
        searchUIToggleButton:SetText(GetString(PCHAT_TOGGLE_SEARCH_UI_ON))
        self.searchUIToggleButton = searchUIToggleButton

        local searchUI = dialogControl:GetNamedChild("SearchUI")
        searchUI:SetHidden(true)
        searchUI:SetWidth(0)
        self.searchUI = searchUI

        --ZO_StringSearch - For string comparison of
        self.stringSearch = ZO_StringSearch:New()
        self.stringSearch:AddProcessor(searchUIScrollListSearchTypeDefault, function(stringSearch, data, searchTerm, cache)
            return self:ProcessItemEntry(stringSearch, data, searchTerm, cache)
        end)

        self.searchMessageEditBoxControl = searchUI:GetNamedChild("MessageSearchBox")
        self.searchMessageEditBoxControl:SetDefaultText(GetString(PCHAT_SEARCHUI_MESSAGE_SEARCH_DEFAULT_TEXT))
        --[[
        self.searchMessageEditBoxControl:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, self.searchMessageEditBoxControl, BOTTOM, 0, -10)
            SetTooltipText(InformationTooltip, getLocalizedText("nameTextSearchTT"))
        end)
        self.searchMessageEditBoxControl:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip)  end)
        ]]
        self.searchMessageEditBoxControl:SetHandler("OnTextChanged", function(editBoxCtrl)
            selfVar:ThrottledCall(searchUIThrottledSearchHandlerName, searchUIThrottledDelay, refreshSearchFilters, selfVar, selfVar.searchMessageEditBoxControl)
            selfVar:UpdateSearchHistory(editBoxCtrl)
        end)
        self.searchMessageEditBoxControl:SetHandler("OnMouseUp", function(editBoxCtrl, mouseButton, upInside, shift, ctrl, alt, command)
            if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                selfVar:OnSearchEditBoxContextMenu(editBoxCtrl, shift, ctrl, alt, command)
            end
        end)

        self.searchFromEditBoxControl = searchUI:GetNamedChild("FromSearchBox")
        self.searchFromEditBoxControl:SetDefaultText(GetString(PCHAT_SEARCHUI_FROM_SEARCH_DEFAULT_TEXT))
        --[[
        self.searchFromEditBoxControl:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, self.searchFromEditBoxControl, BOTTOM, 0, -10)
            SetTooltipText(InformationTooltip, getLocalizedText("nameTextSearchTT"))
        end)
        self.searchFromEditBoxControl:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip)  end)
        ]]
        self.searchFromEditBoxControl:SetHandler("OnTextChanged", function(editBoxCtrl)
            selfVar:ThrottledCall(searchUIThrottledSearchHandlerName, searchUIThrottledDelay, refreshSearchFilters, selfVar, selfVar.searchFromEditBoxControl)
            selfVar:UpdateSearchHistory(editBoxCtrl)
        end)
        self.searchFromEditBoxControl:SetHandler("OnMouseUp", function(editBoxCtrl, mouseButton, upInside, shift, ctrl, alt, command)
            if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                selfVar:OnSearchEditBoxContextMenu(editBoxCtrl, shift, ctrl, alt, command)
            end
        end)

        --Results list -> ZO_SortFilterList
        searchUI.counterControl = searchUI:GetNamedChild("Counter")
        self.searchUICounterControl = searchUI.counterControl
        self.searchUIListControl = searchUI:GetNamedChild("List")
        searchUI.list = self.searchUIListControl
        self.searchUIList = pChat_SearchUI_List:New(searchUI, self) --pass in the parent control of "Headers" and "List" -> "SearchUI"

        --ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
        --Do not refresh the data here now, but as the SearchUI shows!
        --self.searchUIList:RefreshData()
    end
end

function ChatCopyOptions:SetSearchEditBoxValue(editBoxControl, searchTerm)
    if editBoxControl and editBoxControl.SetText then
        editBoxControl:SetText(searchTerm)
    end
end

function ChatCopyOptions:OnSearchEditBoxContextMenu(editBoxControl, shift, ctrl, alt, command)
    if LibCustomMenu == nil then return end
    local selfVar = self
    local searchHistory = pChat.db.chatSearchHistory
    local doShowMenu = false

    ClearMenu()
    if editBoxControl:GetText() ~= "" then
        AddCustomMenuItem(GetString(SI_MAIL_SEND_CLEAR), function()
            selfVar:SetSearchEditBoxValue(editBoxControl, "")
            ClearMenu()
        end)
        AddCustomMenuItem("-", function() end)
        doShowMenu = true
    end

    if editBoxControl == selfVar.searchMessageEditBoxControl then
        local searchType = SEARCH_TYPE_MESSAGE
        local searchHistoryOfSearchMode = searchHistory[searchType]
        if searchHistoryOfSearchMode ~= nil and #searchHistoryOfSearchMode > 0 then
            for _, searchTerm in ipairs(searchHistoryOfSearchMode) do
                AddCustomMenuItem(searchTerm, function()
                    selfVar:SetSearchEditBoxValue(editBoxControl, searchTerm)
                    ClearMenu()
                end)
            end
            AddCustomMenuItem("-", function() end)
            AddCustomMenuItem(GetString(PCHAT_SEARCHUI_CLEAR_SEARCH_HISTORY), function()
                clearSearchHistory(searchType)
                ClearMenu()
            end)
            doShowMenu = true
        end
    elseif editBoxControl == selfVar.searchFromEditBoxControl then
        local searchType = SEARCH_TYPE_FROM
        local searchHistoryOfSearchMode = searchHistory[searchType]
        if searchHistoryOfSearchMode ~= nil and #searchHistoryOfSearchMode > 0 then
            for _, searchTerm in ipairs(searchHistoryOfSearchMode) do
                AddCustomMenuItem(searchTerm, function()
                    selfVar:SetSearchEditBoxValue(editBoxControl, searchTerm)
                    ClearMenu()
                end)
            end
            AddCustomMenuItem("-", function() end)
            AddCustomMenuItem(GetString(PCHAT_SEARCHUI_CLEAR_SEARCH_HISTORY), function()
                clearSearchHistory(searchType)
                ClearMenu()
            end)
            doShowMenu = true
        end
    end
    --Show the context menu now?
    if doShowMenu == true then
        ShowMenu(editBoxControl)
    end
end

function ChatCopyOptions:UpdateSearchHistory(editBoxCtrl)
    --Get the editbox text and the searchType
    local searchValue = editBoxCtrl:GetText()
    local isEmptySearch = (searchValue == nil or searchValue == "" and true) or false
    if isEmptySearch then return end
    local searchType = (editBoxCtrl == self.searchMessageEditBoxControl and SEARCH_TYPE_MESSAGE) or SEARCH_TYPE_FROM
    updateSearchHistoryDelayed(searchType, searchValue)
end
--ZO_SortFilterList filter functions
function ChatCopyOptions:CheckForMatch(data, searchInputMessage, searchInputFrom)
    local stringSearch = self.stringSearch
    stringSearch._searchType = nil

    local isMatch = false

    local searchInputNumber = tonumber(searchInputMessage)
    if searchInputNumber ~= nil then
        local searchValueType = type(searchInputNumber)
        if searchValueType == "number" then
            isMatch = searchInputNumber == data.messageId or false
            if isMatch == true and searchInputFrom ~= nil and searchInputFrom ~= "" then
                stringSearch._searchType = SEARCH_TYPE_FROM
                --Will call self.stringSearch:ProcessItemEntry
                isMatch = stringSearch:IsMatch(searchInputFrom, data)
            end
        end
    else
        --Will call self.stringSearch:ProcessItemEntry
        --Check message comparison first
        if isMatch == false and searchInputMessage ~= nil and searchInputMessage ~= "" then
            stringSearch._searchType = SEARCH_TYPE_MESSAGE
            isMatch = stringSearch:IsMatch(searchInputMessage, data)
        end
        --Afterwards check from comparison
        if (isMatch == true or (stringSearch._searchType == nil and isMatch == false)) and searchInputFrom ~= nil and searchInputFrom ~= "" then
            stringSearch._searchType = SEARCH_TYPE_FROM
            isMatch = stringSearch:IsMatch(searchInputFrom, data)
        end
    end
    return isMatch
end


function ChatCopyOptions:ProcessItemEntry(stringSearch, data, searchTerm, cache)
    --cache should be data.cache if ZO_StringSearch:GetFromCache was used to build that -> Cleared bvia ZO_StringSearch:ClearCache()
    local searchType = stringSearch._searchType
    if searchType == nil then return end
--d("[pChat]ChatCopyOptions:ProcessItemEntry-type: " ..tos(searchType))

    if searchType == SEARCH_TYPE_MESSAGE then
        if zo_plainstrfind(strlow(data.rawMessage), strlow(searchTerm)) then
            return true
        end
    elseif searchType == SEARCH_TYPE_FROM then
        if zo_plainstrfind(strlow(data.rawFrom), strlow(searchTerm)) then
            return true
        end
    end
    return false
end

function ChatCopyOptions:StartSearch()
    --Update the results list now
    if self.searchUIList ~= nil then
        --At "BuildMasterList" the self.searchParams will be pre-filtered, and at FilterScrollList the text search filters will be added
        self.searchUIList:RefreshData() --> -- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
        return true
    end
    return false
end

function ChatCopyOptions:UpdateGuildNames()
    for i,label in ipairs(self.guildNameLabels) do
        local guildID = GetGuildId(i)
        local guildName = GetGuildName(guildID)
        local alliance = GetGuildAlliance(guildID)

        if(guildName ~= "") then
            local r,g,b = GetAllianceColor(alliance):UnpackRGB()
            label:SetText(guildName)
            label:SetColor(r, g, b, 1)
        else
            label:SetText(zo_strformat(SI_EMPTY_GUILD_CHANNEL_NAME, i))
        end
    end
end

function ChatCopyOptions:ResetFilterCheckBoxes()
--d("[pChat]ResetFilterCheckBoxes")
    if not self.filterButtons then return end
    for _, button in ipairs(self.filterButtons) do
        ZO_CheckButton_SetCheckState(button, false)
        button:SetEnabled(false)
        button:SetMouseEnabled(false)
        button:SetHidden(false)
        local label = GetControl(button, "Label")
        if label then
            label:SetMouseEnabled(false)
        end
    end
    self.filteredChannels = {}
end

function ChatCopyOptions:SetCurrentChannelSelections(container, chatTabIndex, chatChannel, isShowDiscussion)
    if not self.filterButtons then return end
    isShowDiscussion = isShowDiscussion or false
    -- Iterate each button's channel list and check just the first entry in each as they are all toggled together
    -- e.g. NPC got more than 1 chatChannel below the NPC checkBox
    --Attention: button.channels are the chatCategories not the chatChannels!
    --> As multiple chat tabs are checked: Keep the already checked checkboxes enabled!
    -- If a chatChannel is given as 3rd parameter, only use this one but check all channels assigned to the buttons instead of only the first
--d("pChat SetCurrentChannelSelections-chatTabIndex: " ..tostring(chatTabIndex) ..", chatChannel: " ..tostring(chatChannel) .. ", isShowDiscussion: " ..tostring(isShowDiscussion))
    for _, button in ipairs(self.filterButtons) do
--d(">button: " ..tostring(button:GetName()))
        if not ZO_CheckButton_IsChecked(button) then
            if chatChannel == nil then
                local chatChannelIsEnabeldAtChatTab = IsChatContainerTabCategoryEnabled(container.id, chatTabIndex, button.channels[1]) or false
--d(">chatTabIndex: " ..tostring(chatTabIndex) .. ", chatChannel1AtTab: " ..tostring(button.channels[1]) .."->" ..tostring(chatChannelIsEnabeldAtChatTab))
                self.filteredChannels[button] = self.filteredChannels[button] or chatChannelIsEnabeldAtChatTab
            else
                local chatCategoryToCheck = GetChannelCategoryFromChannel(chatChannel)
                if not chatCategoryToCheck then return end
                for _, chatCategoryAtCheckbox in ipairs(button.channels) do
                    local chatChannelCategoryIsEnabledAtChatTab = false
                    if chatCategoryToCheck == chatCategoryAtCheckbox then
                        chatChannelCategoryIsEnabledAtChatTab = IsChatContainerTabCategoryEnabled(container.id, chatTabIndex, chatCategoryToCheck) or false
--d(">category equals cboxCategory ->" ..tostring(chatChannelCategoryIsEnabledAtChatTab))
                    end
--d(">category: toCompare/WithCheckBox: " ..tostring(chatCategoryToCheck) .. "/" ..tostring(chatCategoryAtCheckbox) .."->" ..tostring(chatChannelCategoryIsEnabledAtChatTab))
                    self.filteredChannels[button] = self.filteredChannels[button] or chatChannelCategoryIsEnabledAtChatTab
                end
            end
        end
    end
end

function ChatCopyOptions:ApplyFilters()
--d("[pChat]CopyDialog-ApplyFilters")
    pChat.pChatData.chatChannelsToFilter = nil
    --Filter the entries in the list now according to selected checkboxes!
    --Get the selected checkboxes
    if not self.filterButtons then return end
    local chatChannelsToFilter = {}
    local chatChannelsToFilterAdded = false
    local oneCheckBoxWasChecked = false
    for _, button in ipairs(self.filterButtons) do
        if ZO_CheckButton_IsChecked(button) then
            oneCheckBoxWasChecked = true
            --Get their chatCategories
            for _, chatCat in pairs(button.channels) do
                --Get the relating chatChannels of the categories
                local chatChannel = ChatCategory2ChatChannel[chatCat]
                if chatChannel then
                    --pChat internally uses CONSTANTS.PCHAT_CHANNEL_SAY (98) instead of CHAT_CHANNEL_SAY (0)
                    chatChannel = mapChatChannelToPChatChannel(chatChannel)

                    chatChannelsToFilter[chatChannel] = true
                    chatChannelsToFilterAdded = true
                end
            end
        end
    end
    if chatChannelsToFilter and (chatChannelsToFilterAdded == true or oneCheckBoxWasChecked == false) then
        pChat.pChatData.chatChannelsToFilter = chatChannelsToFilter
        --Filter the text with the given chat channels
        self.message = CopyWholeChat(true)
        --Reset the buttons "prev"/"next" etc.
        self:UpdateEditAndButtons()

        if self.openedSearchUICount > 1 then
            self:UpdateSearchUI()
        end
    end
end

function ChatCopyOptions:ChangeFiltersState(doEnable, filterType)
    if not self.filterButtons then return end

    if filterType == nil then
        for _, button in ipairs(self.filterButtons) do
            if doEnable == true then
                if ZO_CheckButton_IsChecked(button) == false then
                    ZO_CheckButton_SetChecked(button)
                end
            else
                if ZO_CheckButton_IsChecked(button) == true then
                    ZO_CheckButton_SetUnchecked(button)
                end
            end

        end
    else
        if filterType == "filter" then
        for _, button in ipairs(self.filterButtons) do
            if button:GetParent():GetParent() == pChatCopyOptionsDialogFilterSection then
                if doEnable == true then
                    if ZO_CheckButton_IsChecked(button) == false then
                        ZO_CheckButton_SetChecked(button)
                    end
                else
                    if ZO_CheckButton_IsChecked(button) == true then
                        ZO_CheckButton_SetUnchecked(button)
                    end
                end
            end
        end

        elseif filterType == "guild" then
            for _, button in ipairs(self.filterButtons) do
                if button:GetParent():GetParent() == pChatCopyOptionsDialogGuildSection then
                    if doEnable == true then
                        if ZO_CheckButton_IsChecked(button) == false then
                            ZO_CheckButton_SetChecked(button)
                        end
                    else
                        if ZO_CheckButton_IsChecked(button) == true then
                            ZO_CheckButton_SetUnchecked(button)
                        end
                    end
                end
            end
        end
    end
end

function ChatCopyOptions:ShowSearchUI()
    self.isSearchUIShown = true
    self.openedSearchUICount = self.openedSearchUICount + 1

    self.searchUIToggleButton:SetText(GetString(PCHAT_TOGGLE_SEARCH_UI_OFF))
    --d("[pChat]ChatCopyOptions-SearchUI - SHOWN")
    self.control:ClearAnchors()
    self.control:SetAnchor(RIGHT, GuiRoot, CENTER, 0, 0)

    self.searchUI:ClearAnchors()
    self.searchUI:SetAnchor(TOPLEFT, self.control, TOPRIGHT, -1, 0)
    self.searchUI:SetAnchor(BOTTOMLEFT, self.control, BOTTOMRIGHT, -1, 0)
    self.searchUI:SetWidth(900)
    self.searchUI:SetHidden(false)

    --Prepare the ZO_SortFilterList's masterList table and add the relevant date, from and message information
    --> Will be done at function CopyWholeChat if param "updateShownDialog" is true -> table pChat_searchUIMasterList will be filled with relevant db.lineStrings
    if self.openedSearchUICount > 1 then
        --Apply the filter buttons, if changed
        self:ApplyFilters()
    else
        --On first open just refresh the scroll list
        self:UpdateSearchUI()
    end
end

function ChatCopyOptions:ClearSearchUIInternalData()
    ZO_ClearTable(pChat_searchUIMasterList)
end

function ChatCopyOptions:HideSearchUI()
    self:ClearSearchUIInternalData()

    self.isSearchUIShown = false
    self.searchUIToggleButton:SetText(GetString(PCHAT_TOGGLE_SEARCH_UI_ON))
--d("[pChat]ChatCopyOptions-SearchUI - HIDDEN")

    self.control:ClearAnchors()
    self.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    self.searchUI:SetWidth(0)
    self.searchUI:SetHidden(true)
end


--Toggle the search UI controls and fill the ZO_SortFilterScrollList with the text lines of the prefiltered chat
function ChatCopyOptions:ToggleSearchUI()
    if self.isSearchUIShown == false then
        self:ShowSearchUI()
    else
        self:HideSearchUI()
    end
end

function ChatCopyOptions:Show()
--d("[pChat]ChatCopyOptions:Show()")
    ZO_Dialogs_ShowDialog("PCHAT_CHAT_COPY_DIALOG")
    local dialogControl = self.control
    dialogControl:SetMouseEnabled(true)
    dialogControl:SetMovable(true)
    dialogControl:GetNamedChild("ModalUnderlay"):SetHidden(true)
end

function ChatCopyOptions:Hide()
--d("[pChat]ChatCopyOptions:Hide")
    local dialogControl = self.control
    --dialogControl:SetMouseEnabled(true)
    dialogControl:SetMovable(false)
    dialogControl:GetNamedChild("ModalUnderlay"):SetHidden(false)

    --Unset the messageText and chatChannel variables in the dialog object
    self.message = nil
    self.chatChannel = nil

    self:HideSearchUI()
end

--[[ XML Handlers ]]--
function pChat_ChatCopyOptions_OnInitialized(dialogControl)
    SetupChatCopyOptionsDialog(dialogControl)
	pChat.ChatCopyOptions = ChatCopyOptions:New(dialogControl)
end

function pChat_ChatCopyOptions_OnCommitClicked()
	pChat.ChatCopyOptions:ApplyFilters()
end

function pChat_ChatCopyOptions_ToggleSearchUI()
	pChat.ChatCopyOptions:ToggleSearchUI()
end

function pChat_ChatCopyOptions_OnHide()
--d("pChat_ChatCopyOptions_OnHide")
    ZO_Dialogs_ReleaseDialog("PCHAT_CHAT_COPY_DIALOG")
    pChat.ChatCopyOptions:Hide()
end

function pChat_ChatCopyOptions_EnableAllFilters(filterType)
    --d("[pChat]Enable all filters")
    pChat.ChatCopyOptions:ChangeFiltersState(true, filterType)
end

function pChat_ChatCopyOptions_DisableAllFilters(filterType)
--d("[pChat]Disable all filters")
    pChat.ChatCopyOptions:ChangeFiltersState(false, filterType)
end

function pChat_SearchUI_Shared_SortHeaderTooltip(sortHeaderColumn)
    if sortHeaderColumn == nil or sortHeaderColumn.name == nil or sortHeaderColumn.name == "" then return end
    local nameLabel = sortHeaderColumn:GetNamedChild("Name")
    if nameLabel ~= nil and nameLabel:WasTruncated() then
        InitializeTooltip(InformationTooltip, sortHeaderColumn, BOTTOM, 0, -10, TOP)
        SetTooltipText(InformationTooltip, sortHeaderColumn.name)
    end
end

function pChat_SearchUI_Shared_Row_OnMouseEnter(rowControl)

end

function pChat_SearchUI_Shared_Row_OnMouseExit(rowControl)

end

function pChat_SearchUI_Shared_Row_OnMouseUp(rowControl, mouseButton, upInside, shift, alt, ctrl, command)
    if upInside and mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
        local doShowMenu = false
        ClearMenu()
--pChat._debugRowControlSearchUI = rowControl
        local data = rowControl.dataEntry.data
        if data == nil then return end
        if data.rawMessage ~= "" then
            AddCustomMenuItem(GetString(PCHAT_COPYMESSAGECT), function()
                ChatSys.textEntry:SetText("")
                CopyMessage(data.messageId)
            end)
            AddCustomMenuItem(GetString(PCHAT_COPYLINECT), function()
                ChatSys.textEntry:SetText("")
                CopyLine(data.messageId)
            end)
            doShowMenu = true
        end

        --Show the context menu now?
        if doShowMenu == true then
            ShowMenu(rowControl)
        end
    end
end

--[[
function pChat_ChatCopyOptionsOnCheckboxToggled(buttonControl, checked)
    if not buttonControl then return end
    d("pChat, changed checkbox: " ..tostring(buttonControl:GetName() .. ", state: " ..tostring(checked)))
    local channels = buttonControl.channels
    d(">ChatChannels related to checkbox: ")
    for i,channel in ipairs(channels) do
        d(">>"..tostring(channel))
    end
end
]]
----------------------------------------------------------------------------------------------

--Keybidning function
function pChat_CopyWholeChat()
    CopyWholeChat(false)
end

-- Create the controls and the dialog
-- & transfer the message to the dialog (for the setup function)
-- then show the dialog
function pChat_ShowCopyDialog(messageText, chatChannel)
    if not messageText or messageText == "" then return end
    local pChatChatCopyOptions = pChat.ChatCopyOptions
    if pChatChatCopyOptions ~= nil and pChatChatCopyOptions.Show then
        pChatChatCopyOptions.message = messageText
        pChatChatCopyOptions.chatChannel = chatChannel
        --Show the dialog now
        pChatChatCopyOptions:Show()
    end
end

local function changeCopyDialogPage(p_control, newIndex)
    local pChatData = pChat.pChatData
    if not p_control then return end
    if not newIndex or newIndex == 0 or newIndex > 1 or newIndex < -1 then return end
    local oldIndex = pChatData.messageTableId
    local numPages = tostring(#pChatData.messageTable)
--d("[pChat]changeCopyDialogPage-newIndex: " ..tos(newIndex) .. ", oldIndex: " ..tos(pChatData.messageTableId) .. "; numPages: " ..tos(numPages))
    pChatData.messageTableId = oldIndex + newIndex
    local messageTableId = pChatData.messageTableId

--d(">oldIndex: " ..tos(oldIndex) ..", messageTableId new: " ..tos(messageTableId))


    if pChatData.messageTable[messageTableId] ~= nil then
        -- Build button
        local notePrev = GetControl(p_control, "NotePrev")
        local noteNext = GetControl(p_control, "NoteNext")
        local noteEdit = GetControl(p_control, "NoteEdit")
        local prevButtonText, nextButtonText
        --Next button pressed
        if newIndex == 1 then
            prevButtonText = tostring(oldIndex) .. " / " .. numPages
            nextButtonText = tostring(messageTableId) .. " / " .. numPages
        --prev button pressed
        else
            prevButtonText = tostring(messageTableId) .. " / " .. numPages
            nextButtonText = tostring(oldIndex) .. " / " .. numPages
        end
        notePrev:SetText(GetString(PCHAT_COPYXMLPREV) .. " ( " ..  prevButtonText .. " )")
        noteNext:SetText(GetString(PCHAT_COPYXMLNEXT) .. " ( " ..  nextButtonText .. " )")
        noteEdit:SetText(pChatData.messageTable[messageTableId])
        noteEdit:SetEditEnabled(false)
        noteEdit:SelectAll()

        -- Don't show prev button if its the first
        if not pChatData.messageTable[messageTableId - 1] then
            notePrev:SetHidden(true)
        else
            notePrev:SetHidden(false)
        end
        -- Don't show next button if its the last
        if not pChatData.messageTable[messageTableId + 1] then
            noteNext:SetHidden(true)
        else
            noteNext:SetHidden(false)
        end
        noteEdit:TakeFocus()
    end
end

-- Called by XML
function pChat_ShowCopyDialogPrev(p_control)
    changeCopyDialogPage(p_control, -1)
end

function pChat_ShowCopyDialogNext(p_control)
    changeCopyDialogPage(p_control, 1)
end

function pChat.InitializeCopyHandler(control)
    local db = pChat.db

    --Initialize the chat copy options dialog
    -->Will be done via the XML's OnInitialized at TLC "pChatCopyOptionsDialog" as the dialog is shown
    --[[
    if pChatCopyOptionsDialog then
        pChat_ChatCopyOptions_OnInitialized(pChatCopyOptionsDialog)
    end
    ]]

    local portTypeToText = {
        ["friend"] =        GetString(PCHAT_CHATCONTEXTMENUTPFRIEND),
        ["group"] =         GetString(PCHAT_CHATCONTEXTMENUTPGROUP),
        ["groupLeader"] =   GetString(PCHAT_CHATCONTEXTMENUTPGROUPLEADER),
        ["guild"] =         GetString(PCHAT_CHATCONTEXTMENUTPGUILD),
    }

    -- Show contextualMenu when clicking on a pChatLink
    local function ShowContextMenuOnHandlers(numLine, chanNumber)
--d("pChat ShowContextMenuOnHandlers, chanNumber: "..tostring(chanNumber))
        db = pChat.db
        ClearMenu()

        if not ZO_Dialogs_IsShowingDialog() then
            local sendMailContextMenuAtChat = db.sendMailContextMenuAtChat
            local teleportContextMenuAtChat = db.teleportContextMenuAtChat
            local whereIsPlayerContextMenuAtChat= db.whereIsPlayerContextMenuAtChat
            local showAccountAndCharAtContextMenu = db.showAccountAndCharAtContextMenu
            local showIgnoredInfoInContextMenuAtChat = db.showIgnoredInfoInContextMenuAtChat
            local characterNameRaw2Id = pChat.characterNameRaw2Id

            local accountAndCharacterName, rawFrom, accountName, characterName, characterLevel, playerName, playerNameStr, zoneNameOfPlayer
            local isOnline = false

            if showAccountAndCharAtContextMenu == true or sendMailContextMenuAtChat == true or showIgnoredInfoInContextMenuAtChat or teleportContextMenuAtChat == true then
                --accountAndCharName, rawFrom, accountName, characterName, characterLevel, zoneNameOfPlayer, isOnline
                accountAndCharacterName, rawFrom, accountName, characterName, characterLevel, zoneNameOfPlayer, isOnline = GetAccountAndCharacterNameFromLine(numLine, chanNumber)
--d(">>accountAndCharacterName: " ..tos(accountAndCharacterName) ..", accountName: " .. tos(accountName) .. ", charName: " ..tos(characterName) .. ", characterLevel: " ..tos(characterLevel))
                if accountName ~= nil and pChat.IsDisplayName(accountName) == false then
                    accountName = "@" .. accountName
                end
                playerName = (accountName ~= nil and accountName) or characterName
                playerNameStr = tostring(playerName)
            end

            local playerNameIsValid = (playerName ~= nil and playerName ~= "" and playerName ~= "nil" and true) or false
            local isAccountOrCharNameOwnPlayer = (playerNameIsValid == true and ((accountName ~= nil and accountName == GetDisplayName()) or characterNameRaw2Id[playerName] ~= nil) and true) or false


            --@Account and character name headline at context menu entry
            if showAccountAndCharAtContextMenu == true then
                local charLevelStr = ""
                if db.showCharacterLevelInContextMenuAtChat == true and characterLevel ~= nil then
                    charLevelStr = " (" .. GetString(SI_FRIENDS_LIST_PANEL_TOOLTIP_LEVEL) .. ": " .. tos(characterLevel) ..")"
                end
                if accountAndCharacterName ~= nil and accountAndCharacterName ~= "" then
--d(">add menu item: account/charName - charLevelStr: " ..tos(charLevelStr))
                    AddCustomMenuItem(accountAndCharacterName .. charLevelStr, function() end, MENU_ADD_OPTION_HEADER) --@AccountName / Character name (optional: Level: <levelOfChar>)
                end
            end


            --Copy message text context menu entries
            AddCustomMenuItem(GetString(PCHAT_COPYMESSAGECT), function() CopyMessage(numLine) end)
            AddCustomMenuItem(GetString(PCHAT_COPYLINECT), function() CopyLine(numLine) end)
            AddCustomMenuItem(GetString(PCHAT_COPYDISCUSSIONCT), function() CopyDiscussion(chanNumber, numLine) end)
            AddCustomMenuItem(GetString(PCHAT_ALLCT), CopyWholeChat)


            --Ignored information context menu entry
            -->Only accounts for history messages as new messages of ignored players won't reach you!
            if isAccountOrCharNameOwnPlayer == false and showIgnoredInfoInContextMenuAtChat == true and playerNameIsValid == true then
--d("[1]IsIgnored check")
                if IsIgnored(playerName) then
                    AddCustomMenuItem(GetString(PCHAT_CHATCONTEXTMENUWARNIGNORE), function()  end)
                end
            end


            --Send email context menu entry
            if isAccountOrCharNameOwnPlayer == false and sendMailContextMenuAtChat == true and playerNameIsValid == true then
--d("[3]Mail to check - playerName: " ..tos(playerName))
                if isMonsterChatChannel(chanNumber, numLine) == false then
                    AddCustomMenuItem(GetString(SI_SOCIAL_MENU_SEND_MAIL) .. " \'" .. playerNameStr .."\'" , function()
                        sendMailToPlayer(playerName)
                    end)
                end
            end


            --Teleport to features
            if isAccountOrCharNameOwnPlayer == false and teleportContextMenuAtChat == true and playerNameIsValid == true and isOnline == true then
--d("[2]Teleport to check")
                getPortTypeFromName = getPortTypeFromName or pChat.GetPortTypeFromName
                local portType, playerTypeStr, guildIndexFound = getPortTypeFromName(playerName, rawFrom)
--d(">portType: " ..tos(portType) .. "; playerTypeStr: " ..tos(playerTypeStr))
                if portType ~= nil then
                    AddCustomMenuItem(GetString(PCHAT_CHATCONTEXTMENUTPTO), function() end, MENU_ADD_OPTION_HEADER)

                    local portTypeTextTemplate = portTypeToText[portType]
                    if portTypeTextTemplate ~= nil then
                        local portTypeText = ""
                        if portType == "guild" and guildIndexFound ~= nil then
                            portTypeText = string.format(portTypeTextTemplate, tostring(guildIndexFound), tostring(playerNameStr))
                        else
                            portTypeText = string.format(portTypeTextTemplate, tostring(playerNameStr))
                        end
                        AddCustomMenuItem(portTypeText, function()
                            pChat.PortToDisplayname(playerName, portType, guildIndexFound)
                        end, MENU_ADD_OPTION_LABEL)
                    end

                    if whereIsPlayerContextMenuAtChat == true and zoneNameOfPlayer ~= nil then
                        AddCustomMenuItem("> " .. zoneNameOfPlayer, function()
                            pChat.PortToDisplayname(playerName, portType, guildIndexFound)
                        end, MENU_ADD_OPTION_LABEL)
                    end
                end
            end

    --d(">got here: ShowMenu")
            ShowMenu()
        end
    end

    -- Triggers when right clicking on a LinkHandler
    local function OnLinkClicked(rawLink, mouseButton, linkText, color, linkType, lineNumber, chanCode)
--d("[pChat]OnLinkClicked-mouseButton: " ..tos(mouseButton) .. ", linkText: " ..tos(linkText) ..", linkType: " .. tos(linkType) .. ", lineNumber: " .. tos(lineNumber) .. ", chanCode: " ..tos(chanCode))
        -- Only executed on LinkType = CONSTANTS.PCHAT_LINK
        if linkType == CONSTANTS.PCHAT_LINK then
--d(">linktype matches: " ..tos(CONSTANTS.PCHAT_LINK))
            local chanNumber = tonumber(chanCode)
            local numLine = tonumber(lineNumber)
            -- CONSTANTS.PCHAT_LINK also handle a linkable channel feature for linkable channels

            -- Context Menu
            if chanCode ~= nil and mouseButton == MOUSE_BUTTON_INDEX_LEFT then

                -- Only Linkable channel - TODO use .channelLinkable
                if chanNumber == CHAT_CHANNEL_SAY
                        or chanNumber == CHAT_CHANNEL_YELL
                        or chanNumber == CHAT_CHANNEL_PARTY
                        or chanNumber == CHAT_CHANNEL_ZONE
                        --[[
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_1
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_2
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_3
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_4
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_5
                        ]]
                        or chatChannelLangToLangStr[chanNumber] ~= nil
                        or (chanNumber >= CHAT_CHANNEL_GUILD_1 and chanNumber <= CHAT_CHANNEL_GUILD_5)
                        or (chanNumber >= CHAT_CHANNEL_OFFICER_1 and chanNumber <= CHAT_CHANNEL_OFFICER_5)
                then
                    IgnoreMouseDownEditFocusLoss()
                    --ChatSys:StartTextEntry(nil, chanNumber)
                    StartChatInput(nil, chanNumber, nil)
                elseif chanNumber == CHAT_CHANNEL_WHISPER then
                    local target = zo_strformat(SI_UNIT_NAME, db.LineStrings[numLine].rawFrom)
                    IgnoreMouseDownEditFocusLoss()
                    --ChatSys:StartTextEntry(nil, chanNumber, target)
                    StartChatInput(nil, chanNumber, target)
                elseif chanNumber == CONSTANTS.PCHAT_URL_CHAN then
                    RequestOpenUnsafeURL(linkText)
                end

            elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
                -- Right click, copy System
                ShowContextMenuOnHandlers(numLine, chanNumber)
            end

            -- Don't execute original LinkHandler code
            return true
        end

    end


    if db.enablecopy then
--d("=== [pChat]LinkHandlers LINK_CLICKED_EVENT and LINK_MOUSE_UP_EVENT registered ===")
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, OnLinkClicked)
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)
    end
end