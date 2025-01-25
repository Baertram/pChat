local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME


local EM = EVENT_MANAGER
local tos = tostring
local strf = string.find
local strlow = string.lower

local playerTag = "player"
local ownDisplayName = GetDisplayName()

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
    if displayName == nil or displayName == "" then return end
    portToDisplayname = portToDisplayname or pChat.PortToDisplayname
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
    if numGuilds == 0 then return nil end
    local args = parseSlashCommands(displayName, false)
    if ZO_IsTableEmpty(args) or #args < 2 then return nil end
    local possibleGuildIndex = tonumber(args[1])
--d(">possibleGuildIndex: " ..tos(possibleGuildIndex))
    if type(possibleGuildIndex) == "number" and possibleGuildIndex >= 1 and possibleGuildIndex <= MAX_GUILDS then
        return possibleGuildIndex
    end
    return nil
end

local function isPlayerInAnyOfYourGuilds(displayName, possibleDisplayNameNormal, possibleDisplayName, p_guildIndex, p_guildIndexIteratorStart)
--d("[pChat]isPlayerInAnyOfYourGuilds-displayName: " ..tos(displayName) ..", possibleDisplayName: " ..tos(possibleDisplayNameNormal) .."/"..tos(possibleDisplayName) ..", p_guildIndex: " ..tos(p_guildIndex) .. ", p_guildIndexIteratorStart: " ..tos(p_guildIndexIteratorStart))

    local numGuilds = GetNumGuilds()
    local isOnline = false
    if numGuilds == 0 then return nil, nil, nil, nil end
--d(">numGuilds: " ..tos(numGuilds))

    --Save the currently selected guildId/index
    currentlySelectedGuildData = {}
    currentlySelectedGuildData.guildIndex = nil
    local currentGuildId = GUILD_SELECTOR.guildId
    if currentGuildId ~= nil then
        for iteratedGuildIndex=1, numGuilds, 1 do
            local guildIdOfIterated = GetGuildId(iteratedGuildIndex)
            if guildIdOfIterated == currentGuildId then
                currentlySelectedGuildData.guildIndex = iteratedGuildIndex
--d(">currentGuildID: " ..tos(currentGuildId) ..", currentIndex: " ..tos(iteratedGuildIndex))
                break
            end
        end
    end

    local guildIndexFound
    local guildMemberDisplayname
    local isStrDisplayName = isDisplayName(possibleDisplayNameNormal)

    ------------------------------------------------------------------------------------------------------------------------
    --Function called as guild member data was loaded
    local function onGuildDataLoaded(pl_guildIndex)
--d("[pChat]onGuildDataLoaded-Index: " ..tos(pl_guildIndex))
        local guildsList = GUILD_ROSTER_MANAGER.lists[1].list -- Keyboard
        if ZO_IsTableEmpty(guildsList.data) then
--d("<<[3- ABORT NOW]guildsList.data is empty")
            resetGuildToOldData()
            return true, false
        end
        for _, v in ipairs(guildsList.data) do
            local data = v.data
            if guildMemberDisplayname == nil then --and data.online == true then
                if data.displayName ~= ownDisplayName then
                    local l_isOnline = data.online

--d(">k: " ..tos(k) .. "data.displayName: " ..tos(data.displayName) .. "; charName: " ..tos(data.characterName))
                    local guildCharName = strlow(data.characterName)
                    local guildDisplayName = strlow(data.displayName)

                    if guildDisplayName ~= nil and strf(guildDisplayName, possibleDisplayName, 1, true) ~= nil then
                        guildMemberDisplayname = data.displayName
--d(">>>found online guild by displayName: " ..tos(guildMemberDisplayname))
                        guildIndexFound = pl_guildIndex
                        return true, l_isOnline
                    elseif guildCharName ~= nil and strf(guildCharName, possibleDisplayName, 1, true) ~= nil then
                        guildMemberDisplayname = data.displayName
--d(">>>found online guild by charName: " ..tos(guildMemberDisplayname) .. ", charName: " .. tos(guildCharName))
                        guildIndexFound = pl_guildIndex
                        return true, l_isOnline
                    end
                end
            end
        end
        return false, false
    end
    ------------------------------------------------------------------------------------------------------------------------


    --Check all -> up to 5 guilds
    local guildIndexIteratorStart = p_guildIndexIteratorStart or 1
    for guildIndex=guildIndexIteratorStart, numGuilds, 1 do
        if p_guildIndex == nil or p_guildIndex == guildIndex then
            if guildMemberDisplayname ~= nil then
--d("<<[1-ABORT NOW]guildMemberDisplayname was found: " ..tos(guildMemberDisplayname))
                resetGuildToOldData()

                if guildMemberDisplayname ~= nil then
                    pChat.lastCheckDisplayNameData = { displayName=guildMemberDisplayname, index=guildIndexFound, isOnline=isOnline, type = "guild"}
                end

                return guildMemberDisplayname, guildIndexFound, nil, isOnline
            end

            --Select the guild
--d(">>GuildIndex set to: " .. tos(guildIndex))
            GUILD_SELECTOR:SelectGuildByIndex(guildIndex)
            if not isStrDisplayName or (isStrDisplayName and (possibleDisplayNameNormal == ownDisplayName) or (GUILD_ROSTER_MANAGER:FindDataByDisplayName(possibleDisplayNameNormal) == nil)) then
--d(">>is no @displayName or no guild member")
                --Loop all guilds and check if any displayname partially matches the entered text from slash command


                local guildsList = GUILD_ROSTER_MANAGER.lists[1].list -- Keyboard
                if guildsList == nil or ZO_IsTableEmpty(guildsList.data) then
--d(">>>guilds list was never created yet! Switching scene states now...")
                    --Do once: Open and close the guilds list scene to create/update the data
                    --local sceneGroup = SCENE_MANAGER:GetSceneGroup("guildsSceneGroup")
                    --sceneGroup:SetActiveScene("guildHome")
                    GUILD_ROSTER_SCENE:SetState(SCENE_SHOWING)
                    GUILD_ROSTER_SCENE:SetState(SCENE_SHOWN)
                    GUILD_ROSTER_SCENE:SetState(SCENE_HIDING)
                    GUILD_ROSTER_SCENE:SetState(SCENE_HIDDEN)
    --    d(">>>>guilds scene states update")
                end



                --Update of the guild roster needs some time now...
                --So how are we able to delay the check until data was loaded properly?
                --[[
                --EVENT_GUILD_DATA_LOADED -> NO, is not used after guildIndex is switched...
                EM:RegisterForEvent("pChat_EVENT_GUILD_DATA_LOADED", EVENT_GUILD_DATA_LOADED, function()
                    if onGuildDataLoaded(guildIndex) == true then
                        isStrDisplayName = isDisplayName(guildMemberDisplayname)
                        if not isStrDisplayName then guildMemberDisplayname = nil end
                        if guildMemberDisplayname ~= nil then
                            resetGuildToOldData()
                            return guildMemberDisplayname, guildIndexFound, nil, isOnline
                        end
                    end
                end)
                ]]
                --Update the guild roster data
                GUILD_ROSTER_KEYBOARD:RefreshData()
--d(">>>Refreshing guild list data")

                --Check guild data update
                local dataLoaded
                dataLoaded, isOnline = onGuildDataLoaded(guildIndex)
                if dataLoaded == true then
                    isStrDisplayName = isDisplayName(guildMemberDisplayname)
                    if not isStrDisplayName then guildMemberDisplayname = nil end
                    if guildMemberDisplayname ~= nil then
--d("<<[2- ABORT NOW]guildMemberDisplayname was found: " ..tos(guildMemberDisplayname))
                        resetGuildToOldData()

                        if guildMemberDisplayname ~= nil then
                            pChat.lastCheckDisplayNameData = { displayName=guildMemberDisplayname, index=guildIndexFound, isOnline=isOnline, type = "guild"}
                        end

                        return guildMemberDisplayname, guildIndexFound, nil, isOnline
                    end
                end


                --[[
                guildsList = GUILD_ROSTER_MANAGER.lists[1].list -- Keyboard
                if ZO_IsTableEmpty(guildsList.data) then
                    d(">2no guilds list data found")
                    repeatListCheck = true
                    resetGuildToOldData()
                    return nil, nil, guildIndex --return the current guildIndex so the next call will go on with that guildIndex as start
                end
                for k, v in ipairs(guildsList.data) do
                    local data = v.data
                    if guildMemberDisplayname == nil and data.online == true then
                        if data.displayName ~= ownDisplayName then

                            d(">k: " ..tos(k) .. "v.data.displayName: " ..tos(v.data.displayName))
                            local guildCharName = strlow(data.characterName)
                            local guildDisplayName = strlow(data.displayName)

                            if guildDisplayName ~= nil and strf(guildDisplayName, possibleDisplayName, 1, true) ~= nil then
                                guildMemberDisplayname = data.displayName
                                d(">>>found online guild: " ..tos(guildMemberDisplayname))
                                guildIndexFound = guildIndex
                                break
                            elseif guildCharName ~= nil and strf(guildCharName, possibleDisplayName, 1, true) ~= nil then
                                guildMemberDisplayname = data.displayName
                                d(">>>found online guild by charName: " ..tos(guildMemberDisplayname) .. ", charName: " .. tos(guildCharName))
                                guildIndexFound = guildIndex
                                break
                            end
                        end
                    end
                end
                ]]
            else
                guildMemberDisplayname = possibleDisplayNameNormal
                guildIndexFound = guildIndex
            end
            isStrDisplayName = isDisplayName(guildMemberDisplayname)
            if not isStrDisplayName then guildMemberDisplayname = nil end
        end --if p_guildIndex == nil or p_guildIndex == guildIndex then
    end -- for guildIndex, numGuilds, 1 do
    resetGuildToOldData()

    if guildMemberDisplayname ~= nil then
        pChat.lastCheckDisplayNameData = { displayName=guildMemberDisplayname, index=guildIndexFound, isOnline=isOnline, type = "guild"}
    end

    return guildMemberDisplayname, guildIndexFound, isOnline
end

--Check if the displayName is a @displayName, partial displayName or any other name like a character name -> Try to find a matching display name via
--friends list, group or guild member list then
-->If it's a partial name the first found name will be teleported to!
local function checkDisplayName(displayName, portType, p_guildIndex, p_guildIndexIteratorStart, wasGuildIndexInDisplayName)
    wasGuildIndexInDisplayName = wasGuildIndexInDisplayName or false
    repeatListCheck = false

    local args
    local isAccountName = false

    local friendIndex
    local isOnline = false

    --Was the guildIndex passed in from a slash command as 1st param and the displayName is the 2nd param then?
    if wasGuildIndexInDisplayName == true then
        args = parseSlashCommands(displayName, false)
        table.remove(args, 1) --delete the guildIndex
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
        return isPlayerInAnyOfYourGuilds(displayName, possibleDisplayNameNormal, possibleDisplayName, p_guildIndex, p_guildIndexIteratorStart)
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
    displayName = checkDisplayName(displayName, "group")
    portToDisplayname(displayName, "group")
end

function pChat.PortToFriend(displayName)
    if displayName == nil or displayName == "" or not canTeleport() then return end
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

function pChat.PortToGuildMember(displayName, guildIndex, guildIndexIteratorStart)
    if displayName == nil or displayName == "" or not canTeleport() then return end
    if not canTeleport() then return end
    local numGuilds = GetNumGuilds()
    if numGuilds == 0 then return end

    --Check if 1st param is a number 1 to 5, then it is the guild number to search
    local wasGuildIndexInDisplayName = false
    if guildIndex == nil then
        guildIndex = checkGuildIndex(displayName)
        if guildIndex ~= nil then
            wasGuildIndexInDisplayName = true
        end
    end
--d(">guildIndex: " ..tos(guildIndex))
    local p_guildIndexFound, p_GuildIndexIteratorStart
    displayName, p_guildIndexFound, p_GuildIndexIteratorStart = checkDisplayName(displayName, "guild", guildIndex, guildIndexIteratorStart, wasGuildIndexInDisplayName)
--d(">displayName: " ..tos(displayName) ..", guildIndex: " ..tos(guildIndex) ..", p_guildIndexFound: " ..tos(p_guildIndexFound))

    --[[
    if displayName == nil and repeatListCheck == true then
        repeatListCheck = false
        --Delay the call to the same function so the friendsListd ata is build properly
        zo_callLater(function() pChat.PortToGuildMember(displayName, guildIndex, p_GuildIndexIteratorStart) end, 250)
        return
    end
    ]]

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