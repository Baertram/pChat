local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

function pChat.InitializeChatHandlers()
    local db = pChat.db
    local logger = pChat.logger
    logger:Debug("InitializeChatHandlers", "Start")

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
        logger:Debug("OnFriendPlayerStatusChanged: ", string.format("Account: %s, character: %s, oldStatus: %s, newStatus: %s", displayName, characterName, tostring(oldStatus), tostring(newStatus)))

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
        logger:Debug("MessageChannelReceiver-channelID: %s, from: %s, text: %s, isCustomerService: %s, fromDisplayName: %s", tostring(channelID), tostring(from), tostring(text), tostring(isCustomerService), tostring(fromDisplayName))
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

        return message, info.saveTarget

    end
    pChat.MessageChannelReceiver = pChatChatHandlersMessageChannelReceiver

    --For chat messages send to the system channel CHAT_CHANNEL_SYSTEM
    local function pChatOnSystemMessage(statusMessage)
        logger:Debug("pChatOnSystemMessage, message: " ..tostring(statusMessage))
        -- Function to format system messages (add timestamp e.g.)
        local message = FormatSysMessage(statusMessage)
        if not message then return statusMessage end
        return message
    end
    pChat.OnSystemMessage = pChatOnSystemMessage

    --Set the chat handlers for the chat/friend/group events
    CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, pChatChatHandlersMessageChannelReceiver)
    if db.useSystemMessageChatHandler == true then
        if LibChatMessage then
            local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
            local originalLCMFormatter = formatters["LibChatMessage"]
            if originalLCMFormatter then
                logger:Debug("pChatMessageFormatter", "Re-registered \'LibChatMessage\' system messages")
                CHAT_ROUTER:RegisterMessageFormatter("LibChatMessage", function(...)
                    return pChatOnSystemMessage(originalLCMFormatter(...))
                end)
            end
        end
        CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", pChatOnSystemMessage)
    end
    if db.usePlayerStatusChangedChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_FRIEND_PLAYER_STATUS_CHANGED, OnFriendPlayerStatusChanged)
    end
    if db.useIgnoreAddedChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_IGNORE_ADDED, OnIgnoreAdded)
    end
    if db.useIgnoreRemovedChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_IGNORE_REMOVED, OnIgnoreRemoved)
    end
    if db.useGroupMemberLeftChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    end
    if db.useGroupTypeChangedChatHandler == true then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_GROUP_TYPE_CHANGED, OnGroupTypeChanged)
    end
end
