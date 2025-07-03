local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME


local EM = EVENT_MANAGER
local tos = tostring
local strf = string.find
local strlow = string.lower
local zostrf = zo_strformat

local playerTag = "player"
local ownDisplayName = GetDisplayName()
local ownDisplayNameLower = strlow(ownDisplayName)

local parseSlashCommands = pChat.ParseSlashCommands

local LCM = LibCustomMenu

local isDisplayName = pChat.IsDisplayName
local isMonsterChatChannel = pChat.IsMonsterChatChannel
local sendMailToPlayer = pChat.SendMailToPlayer


--pChat - Teleport functions
function pChat.CanTeleport()
    local canTeleportNow = (not IsUnitDead(playerTag) and CanLeaveCurrentLocationViaTeleport()) or false
--("[pChat]CanTeleport: " ..tos(canTeleportNow))
    return canTeleportNow
end
local canTeleport = pChat.CanTeleport

local portToDisplayname
local wasUnmounted = false
local function onMountStateChangedTeleport(mounted, displayName, portType, guildIndex)
--d("[pChat]onMountStateChangedTeleport-mounted: " ..tos(mounted) ..", displayName: " ..tos(displayName) .. ", portType: " ..tos(portType) .. ", guildIndex: " ..tos(guildIndex))
    EM:UnregisterForEvent("pChat_EVENT_MOUNTED_STATE_CHANGED_teleport", EVENT_MOUNTED_STATE_CHANGED)
    if mounted == false then
--d(">porting now after unmounting")
        portToDisplayname = portToDisplayname or pChat.PortToDisplayname
        wasUnmounted = true
        portToDisplayname(displayName, portType, guildIndex)
    end
end

local function jumpToDisplayNameByPortTypeNow(displayName, portType)
    if portType == "groupLeader" then
        JumpToGroupLeader()
    elseif portType == "group" then
        JumpToGroupMember(displayName)
    elseif portType == "friend" then
        JumpToFriend(displayName)
    elseif portType == "guild" then
        JumpToGuildMember(displayName)
    end
end

function pChat.PortToDisplayname(displayName, portType, guildIndex)
    local isCurrentlyMounted = IsMounted()
    --d("[pChat]PortToDisplayname-displayName: " ..tos(displayName) .. ", portType: " ..tos(portType) .. ", guildIndex: " ..tos(guildIndex) ..", isMounted: " ..tos(isCurrentlyMounted))
    portToDisplayname = portToDisplayname or pChat.PortToDisplayname
    if displayName == nil or displayName == "" or strlow(displayName) == ownDisplayNameLower then return end
    if not canTeleport() then return end

    CancelCast()

    --Start the teleporting now
    if wasUnmounted == true or isCurrentlyMounted == false then
        wasUnmounted = false
        local teleportToName = (
                (portType == "groupLeader" and tos(displayName) .. " (" .. GetString(SI_GROUP_LIST_PANEL_LEADER_TOOLTIP) .. ")")
                        or (portType == "group" and tos(displayName) .. " (" .. GetString(SI_CHATCHANNELCATEGORIES7) ..")")
                        or (portType == "friend" and tos(displayName) .. " (" .. GetString(PCHAT_CHATCONTEXTMENUTYPEFRIEND) ..")")
                        or (portType == "guild" and ((guildIndex ~= nil and tos(displayName) .. " (" .. GetString(SI_GAMEPAD_GUILD_BANK_GUILD_FOOTER_LABEL) .." #" .. tos(guildIndex)..")") or (tos(displayName) .. " (" .. GetString(SI_GAMEPAD_GUILD_BANK_GUILD_FOOTER_LABEL) ..")")))
        )
                or tos(displayName)
        d("["..ADDON_NAME.."]" .. GetString(PCHAT_TELEPORTINGTO) .. teleportToName)

        jumpToDisplayNameByPortTypeNow(displayName, portType)

        return true
    else
        --Player get's unmounted on first call, so repeat the port again with a delay
        --zo_callLater(function() portToDisplayname(displayName, portType) end, 1250)
        -->No delay here, use mount state changed event and recall the teleport then
        EM:RegisterForEvent("pChat_EVENT_MOUNTED_STATE_CHANGED_teleport", EVENT_MOUNTED_STATE_CHANGED, function(eventId, mounted)
            onMountStateChangedTeleport(mounted, displayName, portType, guildIndex)
        end)

        jumpToDisplayNameByPortTypeNow(displayName, portType)
        CancelCast()

        return false
    end
end
portToDisplayname = pChat.PortToDisplayname

local currentlySelectedGuildData = {}
local function resetGuildToOldData()
    --EM:UnregisterForEvent("pChat_EVENT_GUILD_DATA_LOADED", EVENT_GUILD_DATA_LOADED)
--d("[pChat]resetGuildToOldData: " ..tos(currentlySelectedGuildData.guildIndex))
    if ZO_IsTableEmpty(currentlySelectedGuildData) then return end
    if currentlySelectedGuildData.guildIndex ~= nil then
        GUILD_SELECTOR:SelectGuildByIndex(currentlySelectedGuildData.guildIndex)
        currentlySelectedGuildData = {}
    end
end

local repeatListCheck = false

local function checkGuildIndex(displayName)
    local numGuilds = GetNumGuilds()
--d("[pChat]checkGuildIndex-displayName: " .. tos(displayName) .. ", numGuilds: " .. tos(numGuilds))
    if numGuilds == 0 then return nil, nil end
    local args = parseSlashCommands(displayName, false)
    if ZO_IsTableEmpty(args) or #args < 2 then return nil, nil end
    local possibleGuildIndex = tonumber(args[1])
--d(">possibleGuildIndex: " ..tos(possibleGuildIndex))
    if type(possibleGuildIndex) == "number" and possibleGuildIndex >= 1 and possibleGuildIndex <= MAX_GUILDS then
        return possibleGuildIndex
    end
    return nil, nil
end

local function checkInputParamsSearchStringAndGuildIndexAreSwitched(displayName, guildIndex)
    --Check if 1st param is a number 1 to 5, then it is the guild number to search
    local wasGuildIndexInDisplayName = false
    local realGuildIndex = checkGuildIndex(displayName)
    if type(realGuildIndex) == "number" then
        --guildIndex was in the displayName! and guildIndex is most likely empty then -> coming from SlashCommands
        wasGuildIndexInDisplayName = true
        guildIndex = realGuildIndex
    end
    return displayName, guildIndex, wasGuildIndexInDisplayName
end


-- Guild member cache to avoid repeated expensive lookups
local guildMemberCache = {}
pChat.guildMemberCache = guildMemberCache --for debugging 20250511

-- Helper to build or refresh the cache for a given guild
local function buildGuildMemberCache(guildIndex)
--d("[pChat]buildGuildMemberCache - guildIndex: " ..tos(guildIndex))
    local guildId = GetGuildId(guildIndex)
    if not guildId or guildId == 0 then return end
    guildMemberCache[guildIndex] = {}
    local guildMemberCacheOfIndex = guildMemberCache[guildIndex]
    local numMembers = GetNumGuildMembers(guildId)
    for memberIndex = 1, numMembers do
        local displayName = GetGuildMemberInfo(guildId, memberIndex)
        if displayName then
            local name = select(1, displayName)
            if name then
                guildMemberCacheOfIndex[strlow(name)] = memberIndex
            end
            -- Also cache character name if available
            local hasChar, charName = GetGuildMemberCharacterInfo(guildId, memberIndex)
            if hasChar and charName and charName ~= "" then
                guildMemberCacheOfIndex[strlow(charName)] = memberIndex
            end
        end
    end
    pChat.guildMemberCache = guildMemberCache
end

local function updateGuildMemberDataForGuildId(guildId)
    if guildId == nil then return end
    for i = 1, GetNumGuilds() do
        if guildId == -1 or GetGuildId(i) == guildId then
            buildGuildMemberCache(i)
            if guildId ~= -1 then return true end
        end
    end
    return false
end

local function removeGuildMemberCache(guildId)
    if guildId == nil then return end
    for i = 1, GetNumGuilds() do
        if GetGuildId(i) == guildId then
            guildMemberCache[i] = {}
            return true
        end
    end
    return false
end

-- Refresh all guild caches (call on login, guild join/leave, etc.)
local function refreshAllGuildCaches()
    if IsPlayerActivated() then
        updateGuildMemberDataForGuildId(-1)
    end
end

local function OnGuildMemberAdded(eventId, guildId, displayName)
    updateGuildMemberDataForGuildId(guildId)
end

local function OnGuildMemberRemoved(eventId, guildId, displayName, characterName)
    updateGuildMemberDataForGuildId(guildId)
end

local function OnGuildSelfJoined(eventId, guildServerId, characterName, guildId)
    zo_callLater(function() updateGuildMemberDataForGuildId(guildId) end, 1000)
end

local function OnGuildSelfLeft(eventId, guildServerId, characterName, guildId)
    removeGuildMemberCache(guildId)
end

local function OnPlayerActivated(eventId, initial)
    refreshAllGuildCaches()
end

local function isPlayerInAnyOfYourGuilds(displayName, possibleDisplayNameNormal, possibleDisplayName, p_guildIndex, p_guildIndexIteratorStart, fromSlashCommand)
    fromSlashCommand = fromSlashCommand or false
    --d("[pChat]isPlayerInAnyOfYourGuilds - displayName: " ..tos(displayName) ..", possibleDisplayNameNormal: " ..tos(possibleDisplayNameNormal) .. ", possibleDisplayName: " ..tos(possibleDisplayName) .. ", p_guildIndex: " .. tos(p_guildIndex) .. ", p_guildIndexIteratorStart: " .. tos(p_guildIndexIteratorStart) .. "; fromSlashCommand: " .. tos(fromSlashCommand))
    local numGuilds = GetNumGuilds()
    if numGuilds == 0 then return nil, nil, nil, nil end

    -- Build cache if missing
    if ZO_IsTableEmpty(guildMemberCache) then
        --d(">guildMemberCache is empty")
        refreshAllGuildCaches()
        if ZO_IsTableEmpty(guildMemberCache) then
            d("[" .. ADDON_NAME .."]ERROR - GuildMemberCache could not be created")
            return nil, nil, nil, nil
        end
    else
        --Less cache data than guild? Update them
        if #guildMemberCache < numGuilds then
            --d(">#guildMemberCache: " .. tos(#guildMemberCache)  .." < numGuilds #"..tos(numGuilds) .." -> Update")
            refreshAllGuildCaches()
        else
            if p_guildIndex ~= nil then
                --d(">guildMemberCache[" ..tos(p_guildIndex).."] is empty")
                if ZO_IsTableEmpty(guildMemberCache[p_guildIndex]) then
                    buildGuildMemberCache(p_guildIndex)
                    if ZO_IsTableEmpty(guildMemberCache[p_guildIndex]) then
                        d("[" .. ADDON_NAME .."]ERROR - GuildMemberCache for guildIndex " .. tos(p_guildIndex) .. " could not be created")
                        return nil, nil, nil, nil
                    end
                end
            end
        end
    end

    local searchName = strlow(possibleDisplayNameNormal)
    if searchName == ownDisplayNameLower then return nil, nil, nil, nil end

    local isOnline = false
    local guildIndexFound, memberIndexFound
    local guildIndexIteratorStart = p_guildIndexIteratorStart or 1
    --d(">guildIndexIteratorStart: " ..tos(guildIndexIteratorStart))
    for guildIndex = guildIndexIteratorStart, numGuilds do
        if p_guildIndex == nil or p_guildIndex == guildIndex then
            local guildId = GetGuildId(guildIndex)
            local cache = guildMemberCache[guildIndex]
            if cache ~= nil then
                --Total name match
                if cache[searchName] ~= nil then
                    local memberIndex = cache[searchName]
                    local name, note, rankIndex, playerStatus = GetGuildMemberInfo(guildId, memberIndex)
                    local hasChar, charName = GetGuildMemberCharacterInfo(guildId, memberIndex)
                    isOnline = (playerStatus ~= PLAYER_STATUS_OFFLINE)
                    guildIndexFound = guildIndex
                    memberIndexFound = memberIndex
                    pChat.lastCheckDisplayNameData = { displayName = name, index = guildIndexFound, isOnline = isOnline, type = "guild" }
                    --d(">found guildIndex: " ..tos(guildIndexFound) .. "; name: " ..tos(name) ..", isOnline: " ..tos(isOnline))
                    return name, guildIndexFound, nil, isOnline

                elseif fromSlashCommand == true then
                    --Partially name match?
                    for cachedName, memberIndex in pairs(cache) do
                        local cachedNameLower = strlow(cachedName)
                        local partialMatch = (cachedNameLower ~= "" and strf(zostrf("<<1>>", cachedNameLower), searchName, 0, true) ~= nil) or false
                        --d(">name: " .. tos(zostrf("<<C:1>>", cachedNameLower)) .. ", strf: " .. tos(strf(zostrf("<<1>>", cachedNameLower), searchName, 0, true)) .. ", partialMatch: " .. tos(partialMatch))
                        if partialMatch == true then
                            local name, note, rankIndex, playerStatus = GetGuildMemberInfo(guildId, memberIndex)
                            local hasChar, charName = GetGuildMemberCharacterInfo(guildId, memberIndex)
                            isOnline = (playerStatus ~= PLAYER_STATUS_OFFLINE)
                            guildIndexFound = guildIndex
                            memberIndexFound = memberIndex
                            pChat.lastCheckDisplayNameData = { displayName = name, index = guildIndexFound, isOnline = isOnline, type = "guild" }
                            --d(">partially found guildIndex: " ..tos(guildIndexFound) .. "; name: " ..tos(name) ..", isOnline: " ..tos(isOnline))
                            return name, guildIndexFound, nil, isOnline
                        end
                    end
                end
            end
        end
    end
    --d("<returning guildData with nil")
    return nil, nil, nil, nil
end

--Check if the displayName is a @displayName, partial displayName or any other name like a character name -> Try to find a matching display name via
--friends list, group or guild member list then
-->If it's a partial name the first found name will be teleported to!
local function checkDisplayName(displayName, portType, p_guildIndex, p_guildIndexIteratorStart, wasGuildIndexInDisplayName, fromSlashCommand)
    wasGuildIndexInDisplayName = wasGuildIndexInDisplayName or false
    repeatListCheck = false

    local args
    local isAccountName = false

    local friendIndex
    local isOnline = false

    --Was the guildIndex passed in from a slash command as 1st param, and the displayName is the 2nd param then?
    if wasGuildIndexInDisplayName == true then
        args = parseSlashCommands(displayName, false)
        table.remove(args, 1) --delete the guildIndex, to keep the displayname etc.
    else
        --displayName could be any passed in string from slash command
        --or from the chat message a character name with spaces in there too!
        --Check if the string passed in is a displayname
        isAccountName = isDisplayName(displayName)
        if isAccountName == true then
            args = parseSlashCommands(displayName, false)
        else
            --Could be a character name with spaces so check the whole string
            args = {
                [1] = displayName
            }
        end
    end

    --For debugging only:
    --d("[pChat]???? checkDisplayName ????")
    --[[
    for k,v in ipairs(args) do
        d(tos(k) .. ") " .. tos(v))
    end
    ]]
    --d("?-------------------------------------?")

    --Only consider the first
    if ZO_IsTableEmpty(args) then return end
    --local displayNameOffset = (portType == "guild" and p_guildIndex ~= nil and 2) or 1
    --local possibleDisplayNameNormal = tostring(args[displayNameOffset])
    local possibleDisplayNameNormal = tostring(args[1])
    if type(possibleDisplayNameNormal) ~= "string" then return end
    local possibleDisplayName = strlow(possibleDisplayNameNormal)

--d(">possibleDisplayNameNormal: " ..tos(possibleDisplayNameNormal) .. "; portType: " ..tos(portType) .."; p_guildIndex: " ..tos(p_guildIndex))

    ------------------------------------------------------------------------------------------------------------------------
    if portType == "friend" then
        local friendsDisplayname
        local isStrDisplayName = isDisplayName(possibleDisplayNameNormal)
        if not isStrDisplayName or (isStrDisplayName and not IsFriend(possibleDisplayNameNormal)) then
            --d(">>is no @displayName or no friend")
            --Loop all friends and check if any displayname partially matches the entered text from slash command
            local friendsList = FRIENDS_LIST.list
            if friendsList == nil then return end
            --d(">>>friends scene data update")
            --Open and close the friends list scene to create/update the data
            FRIENDS_LIST_SCENE:SetState(SCENE_SHOWING)
            FRIENDS_LIST_SCENE:SetState(SCENE_SHOWN)
            FRIENDS_LIST_SCENE:SetState(SCENE_HIDING)
            FRIENDS_LIST_SCENE:SetState(SCENE_HIDDEN)
            FRIENDS_LIST:RefreshData()
            friendsList = FRIENDS_LIST.list
            if ZO_IsTableEmpty(friendsList.data) then
                --d(">no friends list data yet")
                repeatListCheck = true
                return
            end
            for k, v in ipairs(friendsList.data) do
                local data = v.data
                local fr_index = data.friendIndex
                if friendsDisplayname == nil then --and data.online == true then
        --d(">index: " ..tos(fr_index) .. "v.data.displayName: " ..tos(v.data.displayName))
                    local friendCharName = strlow(data.characterName)
                    local friendDisplayName = strlow(data.displayName)

                    if friendDisplayName ~= nil and strf(friendDisplayName, possibleDisplayName, 1, true) ~= nil then
                        friendsDisplayname = data.displayName
                        friendIndex = fr_index
                        --d(">>>found online friend: " ..tos(friendsDisplayname))
                        break
                    elseif friendCharName ~= nil and strf(friendCharName, possibleDisplayName, 1, true) ~= nil then
                        friendsDisplayname = data.displayName
                        friendIndex = fr_index
                        isOnline = data.online
                        --d(">>>found online friend by charName: " ..tos(friendsDisplayname) .. ", charName: " .. tos(friendCharName))
                        break
                    end
                end
            end
            if friendsDisplayname ~= nil and not IsFriend(friendsDisplayname) then
                friendsDisplayname = nil
                friendIndex = nil
            end
        else
            friendsDisplayname = possibleDisplayNameNormal
        end
        isStrDisplayName = isDisplayName(friendsDisplayname)
        if not isStrDisplayName then
            friendsDisplayname = nil
            friendIndex = nil
        end
        if friendsDisplayname ~= nil then
            pChat.lastCheckDisplayNameData = { displayName=friendsDisplayname, index=friendIndex, isOnline=isOnline, type = "friends"}
        end

        return friendsDisplayname, friendIndex, isOnline

    ------------------------------------------------------------------------------------------------------------------------
    elseif portType == "guild" then
--d(">>guild check")
        return isPlayerInAnyOfYourGuilds(displayName, possibleDisplayNameNormal, possibleDisplayName, p_guildIndex, p_guildIndexIteratorStart, fromSlashCommand)
    end
end
pChat.checkDisplayName = checkDisplayName

function pChat.PortToGroupLeader()
    if not canTeleport() then return end
    local unitTag, groupLeaderTag
    if not IsUnitGrouped(playerTag) or IsUnitGroupLeader(playerTag) then return end
    groupLeaderTag = GetGroupLeaderUnitTag()
    if groupLeaderTag == nil or groupLeaderTag == "" then
        return
    else
        unitTag = groupLeaderTag
        --[[
        local groupPlayerIndex = GetGroupIndexByUnitTag(playerTag)
        for groupIndex=0, GetGroupSize(), 1 do
            if groupIndex == groupPlayerIndex then
            else
            end
        end
        ]]
    end
    if unitTag == nil then return end
    portToDisplayname(GetUnitDisplayName(unitTag), "groupLeader")
end

function pChat.PortToGroupMember(displayName)
    if displayName == nil or displayName == "" or not canTeleport() then return end
    if not IsUnitGrouped(playerTag) then return end
    local searchName = strlow(displayName)
    if searchName == ownDisplayNameLower then
        return
    end

    displayName = checkDisplayName(displayName, "group")
    portToDisplayname(displayName, "group")
end

function pChat.PortToFriend(displayName)
    if displayName == nil or displayName == "" or not canTeleport() then return end
    local searchName = strlow(displayName)
    if searchName == ownDisplayNameLower then
        return
    end
    displayName = checkDisplayName(displayName, "friend")

    --[[
    if displayName == nil and repeatListCheck == true then
        repeatListCheck = false
        --Delay the call to the same function so the friendsListd ata is build properly
        zo_callLater(function() pChat.PortToFriend(displayName) end, 250)
        return
    end
    ]]

    portToDisplayname(displayName, "friend")
end


--If coming from a slash command /tpg the displayName might be the guildIndex 1 to 5 and the guildIndex might be the display or characteName!
function pChat.PortToGuildMember(displayName, guildIndex, guildIndexIteratorStart)
--d("[pChat.PortToGuildMember]displayName: " ..tos(displayName) .. ", guildIndex: " .. tos(guildIndex) .. ", guildIndexIteratorStart: " ..tos(guildIndexIteratorStart))
    if displayName == nil or displayName == "" or not canTeleport() then return end
    local numGuilds = GetNumGuilds()
    if numGuilds == 0 then return end

    local wasGuildIndexInDisplayName, p_guildIndexFound, p_GuildIndexIteratorStart
    displayName, guildIndex, wasGuildIndexInDisplayName = checkInputParamsSearchStringAndGuildIndexAreSwitched(displayName, guildIndex)

--d(">displayNameNow: " .. tos(displayName) .. ", guildIndexNow: " ..tos(guildIndex) .. "; wasGuildIndexInDisplayName: " .. tos(wasGuildIndexInDisplayName))
    displayName, p_guildIndexFound, p_GuildIndexIteratorStart = checkDisplayName(displayName, "guild", guildIndex, guildIndexIteratorStart, wasGuildIndexInDisplayName, true)
--d(">displayNameFound: " ..tos(displayName) ..", p_guildIndexFound: " ..tos(p_guildIndexFound).. ", p_GuildIndexIteratorStart: " ..tos(p_GuildIndexIteratorStart))

    --Do not start teleport if player is offline
    local lastCheckDisplayNameData = pChat.lastCheckDisplayNameData
    if lastCheckDisplayNameData then
        if lastCheckDisplayNameData.type == "guild" and lastCheckDisplayNameData.displayName == displayName and lastCheckDisplayNameData.index == p_guildIndexFound
                and not lastCheckDisplayNameData.isOnline then
            return
        end
    end

    portToDisplayname(displayName, "guild", p_guildIndexFound or guildIndex)
end

local function getPortTypeFromName(playerName, rawName)
--d("[pChat]getPortTypeFromChatName-playerName: " ..tos(playerName) ..", rawName: " ..tos(rawName))
    if IsIgnored(playerName) then return nil, nil end

    local playerTypeStr = GetString(SI_OUTFIT_PLAYER_SUB_TAB) --"Player"
    local portType = nil
    local guildIndexFound
    local zoneNameOfPlayer

    --Friend
    if IsFriend(playerName) then
--d(">player is a friend!")
        --port to friend
        portType = "friend"
        playerTypeStr = GetString(PCHAT_CHATCONTEXTMENUTYPEFRIEND) --"Friend"
    end

    --Group member
    local localPlayerIsGrouped = IsUnitGrouped(playerTag)
--d(">Are we grouped: " ..tos(localPlayerIsGrouped))
    if portType == nil and localPlayerIsGrouped == true then
        if rawName ~= nil and IsPlayerInGroup(rawName) then
--d(">>player is in group!")
            --port to group member
            portType = "group"
            playerTypeStr = GetString(SI_CHATCHANNELCATEGORIES7) .. " " .. GetString(SI_GUILDRANKS2) --"Group Member"
        end
    end

    --Guild
    if portType == nil then
--d(">check guilds:")
        local guildMemberDisplayname
        guildMemberDisplayname, guildIndexFound, zoneNameOfPlayer = checkDisplayName(playerName, "guild", nil, nil)
--d(">guildMemberDisplayname: " ..tos(guildMemberDisplayname) .. "; guildIndexFound: " ..tos(guildIndexFound))
        --port to guild member
        if guildMemberDisplayname ~= nil then
            portType = "guild"
            if guildIndexFound ~= nil then
                playerTypeStr = GetString(SI_GAMEPAD_GUILD_BANK_GUILD_FOOTER_LABEL) .. " #" .. tos(guildIndexFound) .. " " .. GetString(SI_GUILDRANKS2) --" member"
            else
                playerTypeStr = GetString(SI_GAMEPAD_GUILD_BANK_GUILD_FOOTER_LABEL) .. " " .. GetString(SI_GUILDRANKS2) -- "Guild member"
            end
        end
    end

--[[
        --Group leader
        if localPlayerIsGrouped == true then
            if not IsUnitGroupLeader(playerTag) then
d(">>port to group leader")
                --port to group leader
                portType = "groupLeader"
                playerTypeStr = GetString(SI_GROUP_LIST_PANEL_LEADER_TOOLTIP) --"Group leader"
            end
        end
]]
    return portType, playerTypeStr, guildIndexFound, zoneNameOfPlayer
end
pChat.GetPortTypeFromName = getPortTypeFromName

--local wasPlayerContextMenuShown = false
local function pChat_PlayerContextMenuCallback(playerName, rawName)
     --#21 Fix context menu not shown on first click? That's coming from BeamMeUp function BMU.PortalHandlerLayerPushed -> BMU.HideTeleporter()	 -> ClearMenu() and needs to be fixed in BMU
    --d("[pChat]PlayerContextMenuCallback-playerName: " ..tos(playerName) ..", rawName: " ..tos(rawName))
    --DO NOT CALL ClearMenu() HERE AS ORIGINAL VANILLA/ZOs PLAYER CONTEXT MENU ENTRIES WOULD BE REMOVED THEN!

    --[[
     --#21 Fix context menu not shown on first click? Try to open it once again now directly
    --This does not fix it, so somehow the later called code below closes the menu below?
    -->[pChat]OnLinkClicked-mouseButton: 2, linkText: @Unn_Cygnus/Featherpaws, linkType: display, lineNumber: @Unn_Cygnus, chanCode: nil
    if not wasPlayerContextMenuShown then
        wasPlayerContextMenuShown = true
        SecurePostHook("ClearMenu", function()
d("======== [pChat]ClearMenu was called! =======")
            d(ZO_GetCallerFunctionName())
        end)
    end
    ]]

--d("[pChat]pChat_PlayerContextMenuCallback-playerName: " ..tos(playerName) ..", rawName: " .. tos(rawName))

    pChat.lastCheckDisplayNameData = nil

    local settings = pChat.db
    local wasAdded = 0
    local playerNameStr = " \'" .. tos(playerName) .. "\'"

    local playerNameIsValid = (playerName ~= nil and playerName ~= "" and playerName ~= "nil" and true) or false
    if playerNameIsValid == true then


        if settings.showIgnoredInfoInContextMenuAtChat == true then
    --d("[1]IsIgnored check")
            if IsIgnored(playerName) then
                AddMenuItem(GetString(PCHAT_CHATCONTEXTMENUWARNIGNORE), function()  end)
                wasAdded = wasAdded +1
            end
        end

        if settings.sendMailContextMenuAtChat == true then
    --d("[3]Mail to check - playerName: " ..tos(playerName))
            local chanNumber, numLine --todo how to get those from clicked line?
            if isMonsterChatChannel(chanNumber, numLine) == false then
                AddMenuItem(GetString(SI_SOCIAL_MENU_SEND_MAIL) .. playerNameStr , function()
                    sendMailToPlayer(playerName)
                end)
                wasAdded = wasAdded +1
            end
        end

        if settings.teleportContextMenuAtChat == true then
    --d("[2]Teleport to check")
            local portType, playerTypeStr, guildIndexFound, zoneNameOfPlayer = getPortTypeFromName(playerName, rawName)
            --d(">portType: " ..tos(portType) .. "; playerTypeStr: " ..tos(playerTypeStr))
            if portType ~= nil then
                AddMenuItem(GetString(SI_GAMEPAD_HELP_UNSTUCK_TELEPORT_KEYBIND_TEXT) .. ": " .. playerTypeStr .. playerNameStr, function()
                    portToDisplayname(playerName, portType, guildIndexFound)
                end)
                wasAdded = wasAdded +1

                if settings.whereIsPlayerContextMenuAtChat == true and zoneNameOfPlayer ~= nil then
                    AddCustomMenuItem("> " .. zoneNameOfPlayer, function()
                        portToDisplayname(playerName, portType, guildIndexFound)
                    end, MENU_ADD_OPTION_LABEL)
                    wasAdded = wasAdded +1
                end
            end
        end

    end --if playerNameIsValid == true then

    --This will add the new entries to the chat player context menu
    --> But original showmenu will be called either way at SharedChatSystem:ShowPlayerContextMenu(playerName, rawName)
    --> if ZO_Menu_GetNumMenuItems() > 0 then ShowMenu() end
    if wasAdded > 0 then
--d(">> !ShowMenu!")
        ShowMenu()
    end
end

local ignorePlayerStr = GetString(SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE)
local ignoreDialogInitialized = false
local doNotShowAskBeforeIgnoreDialog = false

local function doIgnorePlayerNow(playerName)
    if playerName == nil or playerName == "" then return end
    if IsIgnored(playerName) then return end
    doNotShowAskBeforeIgnoreDialog = true
    ZO_PlatformIgnorePlayer(playerName)
end

local function initializepChatIgnorePlayerDialog()
--d("[pChat]initializepChatIgnorePlayerDialog")
    ZO_Dialogs_RegisterCustomDialog("pChat_IGNORE_PLAYER_DIALOG", {
        canQueue = true,
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title =
        {
            text = ignorePlayerStr .. "?",
        },
        mainText = function(dialog)
            return { text = ignorePlayerStr .. " \'" .. tos(dialog and dialog.data and dialog.data.playerName) .. "\'" }
        end,
        buttons =
        {
             -- Confirm Button
            {
                keybind = "DIALOG_PRIMARY",
                text = GetString(SI_DIALOG_CONFIRM),
                callback = function(dialog, data)
                    doIgnorePlayerNow((data and data.playerName) or (dialog and dialog.data and dialog.data.playerName))
                end,
            },

            -- Cancel Button
            {
                keybind = "DIALOG_NEGATIVE",
                text = GetString(SI_DIALOG_CANCEL),
            },
        },
        --[[
        noChoiceCallback = function()
        end,
        ]]
    })
    ignoreDialogInitialized = true
end

local function ignorePlayerDialog(playerName)
--d("[pChat]ignorePlayerDialog - playerName: " ..tos(playerName))
    if ignoreDialogInitialized == false then
        initializepChatIgnorePlayerDialog()
    end
    ZO_Dialogs_ShowPlatformDialog("pChat_IGNORE_PLAYER_DIALOG", { playerName = playerName })
end


function pChat.TeleportChanges()
--d("[pChat]pChat.TeleportChanges")
    local settings = pChat.db

    if settings.ignoreWithDialogContextMenuAtChat == true then
        --Fix Ignore player to be down at report player in chat context menu!

        --Is the SecurePosthook still calling LibCustomMenu hooks properly at original first called IsGroupModificationAvailable -> InsertEntries
        --and at ZO_Menu_GetNumMenuItems at the end then?
        --> No :-( So no Posthook or Prehook possible
        --[[
        SecurePostHook(CHAT_SYSTEM, "ShowPlayerContextMenu", function(chatSystem, playerName, rawName)
    --d("[pChat]Chat_SYSTEM.ShowPlayerContextMenu - SecurePostHook; playerName: " ..tos(playerName) .. ", rawName: " ..tos(rawName))
            --pChat_ChatSystemShowPlayerContextMenu_IsHooked = playerName

            ClearMenu()

            -- Add to/Remove from Group
            if IsGroupModificationAvailable() then
                local localPlayerIsGrouped = IsUnitGrouped(playerTag)
                local localPlayerIsGroupLeader = IsUnitGroupLeader(playerTag)
                local otherPlayerIsInPlayersGroup = IsPlayerInGroup(rawName)
                if not localPlayerIsGrouped or (localPlayerIsGroupLeader and not otherPlayerIsInPlayersGroup) then
                    AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_GROUP), function()
                    local SENT_FROM_CHAT = false
                    local DISPLAY_INVITED_MESSAGE = true
                    TryGroupInviteByName(playerName, SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE) end)
                elseif otherPlayerIsInPlayersGroup and localPlayerIsGroupLeader then
                    AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_REMOVE_GROUP), function() GroupKickByName(rawName) end)
                end
            end

            -- Whisper
            AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER), function() CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, playerName) end)

            -- Add Friend
            if not IsFriend(playerName) then
                AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_FRIEND), function() ZO_Dialogs_ShowDialog("REQUEST_FRIEND", { name = playerName }) end)
            end

            -- Report player
            AddMenuItem(zo_strformat(SI_CHAT_PLAYER_CONTEXT_REPORT, rawName), function()
                ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(playerName)
            end)

            -- Ignore
            local function IgnoreSelectedPlayer(p_playerName)
                --Ask before ignore dialog show
                ignorePlayerDialog(p_playerName)
            end
            if not IsIgnored(playerName) then
                AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE), function() IgnoreSelectedPlayer(playerName) end)
            end

            if ZO_Menu_GetNumMenuItems() > 0 then
                ShowMenu()
            end

            --Call original function to let LibCustomMenu work properly!
            --return true --supress original func
        end)
        ]]

        --Try to Posthook the ZO_Menu_GetNumMenuItems funtion to check if it's the menu that opens at character and replace the ignore entry with the one that
        --calls the security dialog
        local function IgnoreSelectedPlayer(p_playerName)
            if pChat.db.ignoreWithDialogContextMenuAtChat == true then
                --Ask before ignore dialog show
                ignorePlayerDialog(p_playerName)
            else
                doIgnorePlayerNow(p_playerName)
            end
        end

        local playerNameAtContextMenuChat = nil
        ZO_PreHook(CHAT_SYSTEM, "ShowPlayerContextMenu", function(chatSystem, playerName, rawName)
            pChat.lastCheckDisplayNameData = nil

            playerNameAtContextMenuChat = playerName
--d("[pChat]CHAT_SYSTEM.ShowPlayerContextMenu-playerName: " ..tos(playerName) ..", rawName: " .. tos(rawName))
            return false
        end)

        SecurePostHook("ClearMenu", function()
--d("[pChat]ClearMenu-playerNameAtContextMenuChat: " ..tos(playerNameAtContextMenuChat))
            playerNameAtContextMenuChat = nil
        end)


        SecurePostHook("ZO_Menu_GetNumMenuItems", function()
            --d("[pChat]ZO_Menu_GetNumMenuItems-playerNameAtContextMenuChat: " ..tos(playerNameAtContextMenuChat))
            if playerNameAtContextMenuChat == nil then return end
            if not pChat.db.ignoreWithDialogContextMenuAtChat then return end

            local menuItems = ZO_Menu.items
            if #menuItems == 0 then return end

            --Get the index of ZO_Menu.items of the entry "Ignore player" -> SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE
            local ignorePlayerContextMenuIndex, ignorePlayerContextMenuDataOrig
            for k, v in ipairs(menuItems) do
                if ignorePlayerContextMenuIndex == nil then
                    local item = v.item
                    if item.name and item.name == ignorePlayerStr then
                        ignorePlayerContextMenuIndex = k
                        ignorePlayerContextMenuDataOrig = ZO_ShallowTableCopy(v)
                        break
                    end
                end
            end
            if ignorePlayerContextMenuIndex ~= nil and ignorePlayerContextMenuDataOrig ~= nil then
                --d(">found ignore enry at index: " ..tos(ignorePlayerContextMenuIndex))
                local playerNameAtContextMenuChatCopy = playerNameAtContextMenuChat

                local ignorePlayerContextMenuDataWithIgnoreDialogCallback = ZO_ShallowTableCopy(ignorePlayerContextMenuDataOrig)
                ignorePlayerContextMenuDataWithIgnoreDialogCallback.item.callback = function()
                    if not IsIgnored(playerNameAtContextMenuChatCopy) then
                        IgnoreSelectedPlayer(playerNameAtContextMenuChatCopy)
                    end
                end
                ZO_Menu.items[ignorePlayerContextMenuIndex] = ignorePlayerContextMenuDataWithIgnoreDialogCallback
            end
            playerNameAtContextMenuChat = nil
        end)


        --Should add the "Ask before ignore" dialog on every "AddIgnore" call, e.g. from Friends list etc.
        local addIgnoreOrig = AddIgnore
        ZO_PreHook("AddIgnore", function(playerName)
--d("[pChat]PreHook AddIgnore-PlayerName: " ..tos(playerName))
            if doNotShowAskBeforeIgnoreDialog == true then
                doNotShowAskBeforeIgnoreDialog = false
                --Do not show dialog again, just call original func
                addIgnoreOrig(playerName)
            else
                if pChat.db.ignoreWithDialogContextMenuAtChat then
                    --Ask before ignore dialog show
                    ignorePlayerDialog(playerName)
                else
                    --Do not show dialog again, just call original func
                    addIgnoreOrig(playerName)
                end
            end
            return true --Suppress original function call
        end)
    end


    if settings.showIgnoredInfoInContextMenuAtChat == true or settings.teleportContextMenuAtChat == true or settings.sendMailContextMenuAtChat == true then --or settings.showAccountAndCharAtContextMenu
--d("[pChat]teleport context menu at chat, or send mail enabled")
        --Add "Teleport to" and "Send mail to" and "!WARNING! Player is ignored" to chat character/displayName context menu entries
        LCM:RegisterPlayerContextMenu(pChat_PlayerContextMenuCallback, LCM.CATEGORY_LATE)
    end
end


EVENT_MANAGER:RegisterForEvent("pChat_GuildCache_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, function(eventId, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent("pChat_GuildCache_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent("pChat_GuildCache_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent("pChat_GuildCache_EVENT_GUILD_MEMBER_ADDED", EVENT_GUILD_MEMBER_ADDED, OnGuildMemberAdded)
    EVENT_MANAGER:RegisterForEvent("pChat_GuildCache_EVENT_GUILD_MEMBER_REMOVED", EVENT_GUILD_MEMBER_REMOVED, OnGuildMemberRemoved)
    EVENT_MANAGER:RegisterForEvent("pChat_GuildCache_EVENT_GUILD_SELF_JOINED_GUILD", EVENT_GUILD_SELF_JOINED_GUILD, OnGuildSelfJoined)
    EVENT_MANAGER:RegisterForEvent("pChat_GuildCache_EVENT_GUILD_SELF_LEFT_GUILD", EVENT_GUILD_SELF_LEFT_GUILD, OnGuildSelfLeft)
end)
