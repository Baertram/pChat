--  pChat object will receive functions
pChat = pChat or {}
pChat.chatHandlers = {}
local chatHandlers = pChat.chatHandlers

local logger

-- local declaration
local funcFormat

local funcFriendStatus
local funcIgnoreAdd
local funcIgnoreRemove
local funcGroupMemberLeft
local funcGroupTypeChanged

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
--[[
	-- Function to append
	if funcDDSBeforeAll then
		DDSBeforeAll = funcDDSBeforeAll(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcTextBeforeAll then
		TextBeforeAll = funcTextBeforeAll(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcDDSBeforeSender then
		DDSBeforeSender = funcDDSBeforeSender(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcTextBeforeSender then
		TextBeforeSender = funcTextBeforeSender(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcDDSAfterSender then
		DDSAfterSender = funcDDSAfterSender(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcTextAfterSender then
		TextAfterSender = funcTextAfterSender(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcDDSBeforeText then
		DDSBeforeText = funcDDSBeforeText(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcTextBeforeText then
		TextBeforeText = funcTextBeforeText(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcTextAfterText then
		TextAfterText = funcTextAfterText(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to append
	if funcDDSAfterText then
		DDSAfterText = funcDDSAfterText(channelID, from, text, isCustomerService, fromDisplayName)
	end

	-- Function to affect From
	if funcName then
		from = funcName(channelID, from, isCustomerService, fromDisplayName)
		if not from then return	end
	end

	-- Function to format text
	if funcText then
		text = funcText(channelID, from, text, isCustomerService, fromDisplayName)
		if not text then return end
	end
]]
	-- Function to format message
	if funcFormat then
		message = funcFormat(channelID, from, text, isCustomerService, fromDisplayName, originalFrom, originalText, DDSBeforeAll, TextBeforeAll, DDSBeforeSender, TextBeforeSender, TextAfterSender, DDSAfterSender, DDSBeforeText, TextBeforeText, TextAfterText, DDSAfterText)
		if not message then return end
	else

		-- Code to run with pChatChatHandlers loaded and Addon not registered to pChatChatHandlers - IT MUST BE ~SAME~ AS ESOUI -

		-- Create channel link
		local channelLink
		if info.channelLinkable then
			local channelName = GetChannelName(info.id)
			channelLink = ZO_LinkHandler_CreateChannelLink(channelName)
		end

		-- Create player link
		local playerLink
		if info.playerLinkable and not from:find("%[") then
			playerLink = DDSBeforeSender .. TextBeforeSender .. ZO_LinkHandler_CreatePlayerLink((fromClean)) .. TextAfterSender .. DDSAfterSender
		else
			playerLink = DDSBeforeSender .. TextBeforeSender .. fromClean .. TextAfterSender .. DDSAfterSender
		end

		text = DDSBeforeText .. TextBeforeText .. text .. TextAfterText .. DDSAfterText

		-- Create default formatting
		--[[
		if channelLink then
			message = DDSBeforeAll .. TextBeforeAll .. zo_strformat(info.format, channelLink, playerLink, text)
		else
			message = DDSBeforeAll .. TextBeforeAll .. zo_strformat(info.format, playerLink, text, GetCustomerServiceIcon(isCustomerService))
		end
		]]
		if channelLink then
			message = DDSBeforeAll .. TextBeforeAll .. string.format(GetString(info.format), channelLink, playerLink, text)
		else
			if info.supportCSIcon then
				message = DDSBeforeAll .. TextBeforeAll .. string.format(GetString(info.format), GetCustomerServiceIcon(isCustomerService), playerLink, text)
			else
				message = DDSBeforeAll .. TextBeforeAll .. string.format(GetString(info.format), playerLink, text)
			end
		end

	end

	return message, info.saveTarget

end

-- Listens for EVENT_FRIEND_PLAYER_STATUS_CHANGED event from ZO_ChatSystem
local function pChatChatHandlersFriendPlayerStatusChangedReceiver(displayName, characterName, oldStatus, newStatus)

	-- If function registrered in Addon, code will run
	local friendStatusMessage

	if funcFriendStatus then
		friendStatusMessage = funcFriendStatus(displayName, characterName, oldStatus, newStatus)
		if friendStatusMessage then
			return friendStatusMessage
		else
			return
		end
	else

		-- Code to run with pChatChatHandlers loaded and Addon not registered to pChatChatHandlers - IT MUST BE ~SAME~ AS ESOUI -

		local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
		local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

		-- DisplayName is linkable
		local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
		-- CharacterName is linkable
		local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)

		-- Not connected before and Connected now (no messages for Away/Busy)
		if(not wasOnline and isOnline) then
			-- Return
			return zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink)
		-- Connected before and Offline now
		elseif(wasOnline and not isOnline) then
			return zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink)
		end

	end

end

-- Listens for EVENT_IGNORE_ADDED event from ZO_ChatSystem
local function pChatChatHandlersIgnoreAddedReceiver(displayName)

	-- If function registrered in Addon, code will run
	local ignoreAddMessage

	if funcIgnoreAdd then
		ignoreAddMessage = funcIgnoreAdd(displayName)
		if ignoreAddMessage then
			return ignoreAddMessage
		else
			return
		end
	else

		-- Code to run with pChatChatHandlers loaded and Addon not registered to pChatChatHandlers - IT MUST BE ~SAME~ AS ESOUI -

		-- DisplayName is linkable
		local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
		ignoreAddMessage = zo_strformat(SI_FRIENDS_LIST_IGNORE_ADDED, displayNameLink)

	end

	return ignoreAddMessage

end

-- Listens for EVENT_IGNORE_REMOVED event from ZO_ChatSystem
local function pChatChatHandlersIgnoreRemovedReceiver(displayName)

	-- If function registrered in Addon, code will run
	local ignoreRemoveMessage

	if funcIgnoreRemove then
		ignoreRemoveMessage = funcIgnoreRemove(displayName)
		if ignoreRemoveMessage then
			return ignoreRemoveMessage
		else
			return
		end
	else

		-- Code to run with pChatChatHandlers loaded and Addon not registered to pChatChatHandlers - IT MUST BE ~SAME~ AS ESOUI -

		-- DisplayName is linkable
		local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
		ignoreRemoveMessage = zo_strformat(SI_FRIENDS_LIST_IGNORE_REMOVED, displayNameLink)

	end

	return ignoreRemoveMessage

end

-- Listens for EVENT_GROUP_MEMBER_LEFT event from ZO_ChatSystem
local function pChatChatHandlersGroupMemberLeftReceiver(characterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)

	-- If function registrered in Addon, code will run
	local groupMemberLeftMessage

	if funcGroupMemberLeft then
		groupMemberLeftMessage = funcGroupMemberLeft(characterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
		if groupMemberLeftMessage then
			return groupMemberLeftMessage
		else
			return
		end
	else

		-- Code to run with pChatChatHandlers loaded and Addon not registered to pChatChatHandlers - IT MUST BE ~SAME~ AS ESOUI -
		if reason == GROUP_LEAVE_REASON_KICKED and isLocalPlayer and actionRequiredVote then
			groupMemberLeftMessage = GetString(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
		end

	end

	return groupMemberLeftMessage

end

-- Listens for EVENT_GROUP_TYPE_CHANGED event from ZO_ChatSystem
local function pChatChatHandlersGroupTypeChangedReceiver(largeGroup)

	-- If function registrered in Addon, code will run
	local GroupTypeChangedMessage

	if funcGroupTypeChanged then
		GroupTypeChangedMessage = funcGroupTypeChanged(largeGroup)
		if GroupTypeChangedMessage then
			return GroupTypeChangedMessage
		else
			return
		end
	else

		-- Code to run with pChatChatHandlers loaded and Addon not registered to pChatChatHandlers - IT MUST BE ~SAME~ AS ESOUI -

        if largeGroup then
            return GetString(SI_CHAT_ANNOUNCEMENT_IN_LARGE_GROUP)
        else
            return GetString(SI_CHAT_ANNOUNCEMENT_IN_SMALL_GROUP)
        end

	end

end

--Set the chat handlers for the chat/friend/group events
chatHandlers[EVENT_CHAT_MESSAGE_CHANNEL]          = pChatChatHandlersMessageChannelReceiver
chatHandlers[EVENT_FRIEND_PLAYER_STATUS_CHANGED]  = pChatChatHandlersFriendPlayerStatusChangedReceiver
chatHandlers[EVENT_IGNORE_ADDED]                  = pChatChatHandlersIgnoreAddedReceiver
chatHandlers[EVENT_IGNORE_REMOVED]                = pChatChatHandlersIgnoreRemovedReceiver
chatHandlers[EVENT_GROUP_MEMBER_LEFT]             = pChatChatHandlersGroupMemberLeftReceiver
chatHandlers[EVENT_GROUP_TYPE_CHANGED]            = pChatChatHandlersGroupTypeChangedReceiver

--Set the functions for the different events to pChat function names to use
function chatHandlers.SetChatHandlerFunctions()
	funcFormat 				= pChat.FormatMessage
	funcFriendStatus 		= pChat.OnFriendPlayerStatusChanged
	funcIgnoreAdd 			= pChat.OnIgnoreAdded
	funcIgnoreRemove 		= pChat.OnIgnoreRemoved
	funcGroupMemberLeft 	= pChat.OnGroupMemberLeft
	funcGroupTypeChanged 	= pChat.OnGroupTypeChanged

	logger = pChat.logger
end
