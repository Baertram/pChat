local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

local maxChatCharCount = CONSTANTS.maxChatCharCount

local CM = CALLBACK_MANAGER

local function CreateChannelLink(channelInfo, overrideName)
    if channelInfo.channelLinkable then
        local channelName = overrideName or GetChannelName(channelInfo.id)
        return ZO_LinkHandler_CreateChannelLink(channelName)
    end
end


function pChat.InitializeChatHandlers()
    local db = pChat.db
    local logger = pChat.logger
    logger:Debug("InitializeChatHandlers", "Start")

    local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()

    local FormatMessage = pChat.FormatMessage
    local FormatSysMessage = pChat.formatSysMessage

    -- Executed when EVENT_IGNORE_ADDED triggers
    local function OnIgnoreAdded(displayName)
        logger:Debug("OnIgnoreAdded: ", displayName)

        -- DisplayName is linkable
        local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
        local statusMessage = zo_strformat(SI_FRIENDS_LIST_IGNORE_ADDED, displayNameLink)

        -- Only if statusMessage is set
        if statusMessage then
            return FormatSysMessage(statusMessage)
        end

    end

    -- Executed when EVENT_IGNORE_REMOVED triggers
    local function OnIgnoreRemoved(displayName)
        logger:Debug("OnIgnoreRemoved: ", displayName)

        -- DisplayName is linkable
        local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
        local statusMessage = zo_strformat(SI_FRIENDS_LIST_IGNORE_REMOVED, displayNameLink)

        -- Only if statusMessage is set
        if statusMessage then
            return FormatSysMessage(statusMessage)
        end

    end

    -- triggers when EVENT_FRIEND_PLAYER_STATUS_CHANGED
    local function OnFriendPlayerStatusChanged(displayName, characterName, oldStatus, newStatus)
        logger:Verbose("OnFriendPlayerStatusChanged: ", string.format("Account: %s, character: %s, oldStatus: %s, newStatus: %s", displayName, characterName, tostring(oldStatus), tostring(newStatus)))

        local statusMessage

        -- DisplayName is linkable
        local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
        -- CharacterName is linkable
        local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)

        local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
        local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

        -- Not connected before and Connected now (no messages for Away/Busy)
        if not wasOnline and isOnline then
            -- Return
            statusMessage = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink)
            -- Connected before and Offline now
        elseif wasOnline and not isOnline then
            statusMessage = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink)
        end

        -- Only if statusMessage is set
        if statusMessage then
            return FormatSysMessage(statusMessage)
        end

    end

    -- Executed when EVENT_GROUP_TYPE_CHANGED triggers
    local function OnGroupTypeChanged(largeGroup)
        logger:Debug("OnGroupTypeChanged: ", string.format("largeGroup: %s", tostring(largeGroup)))

        if largeGroup then
            return FormatSysMessage(GetString(SI_CHAT_ANNOUNCEMENT_IN_LARGE_GROUP))
        else
            return FormatSysMessage(GetString(SI_CHAT_ANNOUNCEMENT_IN_SMALL_GROUP))
        end

    end

    -- Executed when EVENT_GUILD_KEEP_ATTACK_UPDATE triggers
    local function OnKeepAttackUpdate(channel, numGuardsKilled, numAttackers, location)
        logger:Verbose("OnKeepAttackUpdate: ", string.format("channel: %s, numGuardsKilled: %s, numAttackers: %s, location: %s", tostring(channel), tostring(numGuardsKilled), tostring(numAttackers), tostring(location)))

        if tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_AVA_NOTIFICATIONS)) ~= AVA_NOTIFICATIONS_SETTING_CHOICE_DONT_SHOW and
                tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_GUILD_KEEP_NOTICES)) == GUILD_KEEP_NOTICES_SETTING_CHOICE_CHAT then
            local ChannelInfo = ZO_ChatSystem_GetChannelInfo()
            local channelInfo = ChannelInfo[channel]

            if channelInfo then
                local text
                if numGuardsKilled > 0 then
                    text = zo_strformat(SI_GUILD_KEEP_ATTACK_UPDATE, numGuardsKilled, location, numAttackers)
                else
                    text = zo_strformat(SI_GUILD_KEEP_ATTACK_END, location)
                end
                local channelInfoFormat = GetString(SI_CHAT_MESSAGE_GUILD_NO_SENDER)
                local channelLink = CreateChannelLink(channelInfo)
                local formattedText = string.format(channelInfoFormat, channelLink, text)

                return FormatSysMessage(formattedText)
            end
        end
    end

    --Executed when EVENT_PVP_KILL_FEED_DEATH triggers
    --local g_pvpKillFeedDeathRecurrenceTracker --local in chathandlers.lua at esoui sources so we cannot use tis function here "yet" and need some way to get access to that local!
    local pvpKillFeedFuncProvided = false
    local origPvpKillFeedEventMessageHandler = formatters[EVENT_PVP_KILL_FEED_DEATH]
    if type(origPvpKillFeedEventMessageHandler) == "function" then
        pvpKillFeedFuncProvided = true
    end
    local function OnPVPKillFeed(killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank, victimDisplayName, victimCharacterName, victimAlliance, victimRank, isKillLocation)
        logger:Debug("OnPVPKillFeed: ", string.format("killLocation: %s, killerDisplayName: %s, killerCharacterName: %s, killerAlliance: %s, killerRank: %s, victimDisplayName: %s, victimCharacterName: %s, victimAlliance: %s, victimRank: %s, isKillLocation: %s", tostring(killLocation), tostring(killerDisplayName), tostring(killerCharacterName), tostring(killerAlliance), tostring(killerRank), tostring(victimDisplayName), tostring(victimCharacterName), tostring(victimAlliance), tostring(victimRank), tostring(isKillLocation)))
--df("[pChat]OnPVPKillFeed - killLocation: %s, killerDisplayName: %s, killerCharacterName: %s, killerAlliance: %s, killerRank: %s, victimDisplayName: %s, victimCharacterName: %s, victimAlliance: %s, victimRank: %s, isKillLocation: %s", tostring(killLocation), tostring(killerDisplayName), tostring(killerCharacterName), tostring(killerAlliance), tostring(killerRank), tostring(victimDisplayName), tostring(victimCharacterName), tostring(victimAlliance), tostring(victimRank), tostring(isKillLocation))
        --message, DEFAULT_TARGET_CHANNEL, DEFAULT_FROM_DISPLAY_NAME, DEFAULT_RAW_MESSAGE_TEXT, narrationMessage, ZO_WHITE
        local message, targetChan, fromDisplayName, rawMessageText, narrationMessage, colorVar = origPvpKillFeedEventMessageHandler(killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank, victimDisplayName, victimCharacterName, victimAlliance, victimRank, isKillLocation)

        return FormatSysMessage(message), targetChan, fromDisplayName, rawMessageText, narrationMessage, colorVar
    end

    local function OnGroupMemberLeft(_, reason, isLocalPlayer, _, _, actionRequiredVote)
        logger:Debug("OnGroupMemberLeft: ", string.format("reason: %s, isLocalPlayer: %s, actionRequiredVote: %s", tostring(reason), tostring(isLocalPlayer), tostring(actionRequiredVote)))

        if reason == GROUP_LEAVE_REASON_KICKED and isLocalPlayer and actionRequiredVote then
            return GetString(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
        end
    end

    -- Returns ZOS CustomerService Icon if needed
    local function GetCustomerServiceIcon(isCustomerService)

        if(isCustomerService) then
            return "|t16:16:EsoUI/Art/ChatWindow/csIcon.dds|t"
        end

        return ""

    end

    -- Listens for EVENT_CHAT_MESSAGE_CHANNEL event from ZO_ChatSystem
    --Parameter: (number eventCode, MsgChannelType channelType, string fromName, string text, boolean isCustomerService, string fromDisplayName)
    local function pChatChatHandlersMessageChannelReceiver(channelID, from, text, isCustomerService, fromDisplayName)
        logger:Verbose("MessageChannelReceiver-channelID: %s, from: %s, text: %s, isCustomerService: %s, fromDisplayName: %s", tostring(channelID), tostring(from), tostring(text), tostring(isCustomerService), tostring(fromDisplayName))
        local message
        local DDSBeforeAll = ""
        local TextBeforeAll = ""
        local DDSBeforeSender = ""
        local TextBeforeSender = ""
        local DDSAfterSender = ""
        local TextAfterSender = ""
        local DDSBeforeText = ""
        local TextBeforeText = ""
        local TextAfterText = ""
        local DDSAfterText = ""
        local originalFrom = from
        local originalText = text
        local fromClean = zo_strformat("<<C:1>>", from)

        -- Get channel information
        local ChanInfoArray = ZO_ChatSystem_GetChannelInfo()
        local info = ChanInfoArray[channelID]

        if not info or not info.format then
            return
        end

        -- Function to format message
        message = FormatMessage(channelID, from, text, isCustomerService, fromDisplayName, originalFrom, originalText, DDSBeforeAll, TextBeforeAll, DDSBeforeSender, TextBeforeSender, TextAfterSender, DDSAfterSender, DDSBeforeText, TextBeforeText, TextAfterText, DDSAfterText)
        if not message then return end

        --12/22/21 @Coorbin - CharCount handler
        if (db.useCharCount == true or db.charCountZonePostTracker == true) and fromClean == pChat.pChatData.localPlayer and channelID == CHAT_CHANNEL_ZONE then
            pChat.charCount.postedstr =  " Z@" .. pChat.CreateTimestamp(GetTimeString())
            pChat.charCount.updateLabelText()
        end

        return message, info.saveTarget

    end
    pChat.MessageChannelReceiver = pChatChatHandlersMessageChannelReceiver

    --For chat messages send to the system channel CHAT_CHANNEL_SYSTEM
    local function pChatOnSystemMessage(statusMessage)
        logger:Verbose("pChatOnSystemMessage, message: " ..tostring(statusMessage))
        -- Function to format system messages (add timestamp e.g.)
        local message = FormatSysMessage(statusMessage)
        if not message then return statusMessage end
        return message
    end
    pChat.OnSystemMessage = pChatOnSystemMessage

    --Set the chat handlers for the chat/friend/group events
    CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, pChatChatHandlersMessageChannelReceiver)
    CM:FireCallbacks("pChat_Initialized_EVENT_CHAT_MESSAGE_CHANNEL", function() return pChatChatHandlersMessageChannelReceiver end)

    if db.useSystemMessageChatHandler == true then
        if LibChatMessage then
            local currentFormatters    = CHAT_ROUTER:GetRegisteredMessageFormatters()
            local originalLCMFormatter = currentFormatters["LibChatMessage"]
            if originalLCMFormatter then
                logger:Debug("pChatMessageFormatter", "Re-registered \'LibChatMessage\' system messages")
                CHAT_ROUTER:RegisterMessageFormatter("LibChatMessage", function(...)
                    return pChatOnSystemMessage(originalLCMFormatter(...))
                end)
            end
        end
        CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", pChatOnSystemMessage)
        CM:FireCallbacks("pChat_Initialized_AddSystemMessage", function() return pChatOnSystemMessage end)
    end


    if db.usePlayerStatusChangedChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_FRIEND_PLAYER_STATUS_CHANGED, OnFriendPlayerStatusChanged)
        CM:FireCallbacks("pChat_Initialized_EVENT_FRIEND_PLAYER_STATUS_CHANGED", function() return OnFriendPlayerStatusChanged end)
    end
    if db.useIgnoreAddedChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_IGNORE_ADDED, OnIgnoreAdded)
        CM:FireCallbacks("pChat_Initialized_EVENT_IGNORE_ADDED", function() return OnIgnoreAdded end)
    end
    if db.useIgnoreRemovedChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_IGNORE_REMOVED, OnIgnoreRemoved)
        CM:FireCallbacks("pChat_Initialized_EVENT_IGNORE_REMOVED", function() return OnIgnoreRemoved end)
    end
    if db.useGroupMemberLeftChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
        CM:FireCallbacks("pChat_Initialized_EVENT_GROUP_MEMBER_LEFT", function() return OnGroupMemberLeft end)
    end
    if db.useGroupTypeChangedChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_GROUP_TYPE_CHANGED, OnGroupTypeChanged)
        CM:FireCallbacks("pChat_Initialized_EVENT_GROUP_TYPE_CHANGED", function() return OnGroupTypeChanged end)
    end
    if db.useKeepAttackUpdateChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_GUILD_KEEP_ATTACK_UPDATE, OnKeepAttackUpdate)
        CM:FireCallbacks("pChat_Initialized_EVENT_GUILD_KEEP_ATTACK_UPDATE", function() return OnKeepAttackUpdate end)
    end
    -- 2024-01-30 g_pvpKillFeedDeathRecurrenceTracker is local in chathandlers.lua of ESOUI source so we cannot add the timestamps properly at the handler by overwriting the function
    if db.usePVPKillFeedChatHandler == true then
        if not pvpKillFeedFuncProvided then return end
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_PVP_KILL_FEED_DEATH, OnPVPKillFeed)
        CM:FireCallbacks("pChat_Initialized_EVENT_PVP_KILL_FEED_DEATH", function() return OnPVPKillFeed end)
    end


    --20211222 @Coorbin - Init CharCount functionality
    pChat.charCount = {
        postedstr = "",
        control = nil,
        hookedOTC = false,
        updateLabelText = function()
            if pChat.charCount ~= nil and pChat.charCount.control ~= nil then
                if db.useCharCount == true then
                    local currentChatEditBoxStr = ZO_ChatWindowTextEntryEditBox:GetText()
                    local currentChatEditBoxStrLen = string.len(currentChatEditBoxStr)
                    local hideCharCountLabel = (currentChatEditBoxStrLen == nil or currentChatEditBoxStrLen == 0 and true) or false
                    local chatCharCountTextBase = tostring(currentChatEditBoxStrLen) .. "/" .. maxChatCharCount
                    if db.charCountZonePostTracker == true then
                        pChat.charCount.control:SetText(chatCharCountTextBase .. pChat.charCount.postedstr)
                    else
                        pChat.charCount.control:SetText(chatCharCountTextBase)
                    end
                    pChat.charCount.control:SetHidden(hideCharCountLabel)
                else
                    if db.charCountZonePostTracker == true then
                        pChat.charCount.control:SetText(pChat.charCount.postedstr)
                        pChat.charCount.control:SetHidden(false)
                    else
                        pChat.charCount.control:SetText("")
                        pChat.charCount.control:SetHidden(true)
                    end
                end
            end
        end,
        curr = ZO_ChatWindowTextEntryEditBox:GetHandler("OnTextChanged"),
        createControl = function()
            pChat.charCount.control = WINDOW_MANAGER:CreateControl("PCHAT_CHAT_CHARCOUNT", ZO_ChatWindow, CT_LABEL)
            pChat.charCount.control:SetFont("ZoFontWinH4")
            pChat.charCount.control:SetHeight(33)
            pChat.charCount.control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            pChat.charCount.control:SetAnchor(CENTER, ZO_ChatWindow, TOP, 0, 30)
            pChat.charCount.updateLabelText()
        end,
        setHandlers = function()
            if db.useCharCount == true then
                if pChat.charCount.hookedOTC ~= true then
                    ZO_ChatWindowTextEntryEditBox:SetHandler("OnTextChanged", function(self)
                        pChat.charCount.updateLabelText()
                        if pChat.charCount.curr ~= nil then
                            pChat.charCount.curr(self)
                        end
                    end)
                    pChat.charCount.hookedOTC = true
                end
            else
                if pChat.charCount.hookedOTC == true and pChat.charCount.curr ~= nil then
                    ZO_ChatWindowTextEntryEditBox:SetHandler("OnTextChanged", pChat.charCount.curr)
                end
                pChat.charCount.hookedOTC = false
            end
            if db.charCountZonePostTracker == true then
                if pChat.charCount.hookedEPA ~= true then
                    EVENT_MANAGER:RegisterForEvent("pChat.charCount", EVENT_PLAYER_ACTIVATED, function()
                        pChat.charCount.postedstr = ""
                        pChat.charCount.updateLabelText()
                    end)
                    pChat.charCount.hookedEPA = true
                end
            else
                if pChat.charCount.hookedEPA == true then
                    EVENT_MANAGER:UnregisterForEvent("pChat.charCount", EVENT_PLAYER_ACTIVATED)
                end
                pChat.charCount.hookedEPA = false
            end
            pChat.charCount.updateLabelText()
        end,
    }
    pChat.charCount.createControl()
    pChat.charCount.setHandlers()
end


