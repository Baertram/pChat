--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn Constants
--======================================================================================================================
    --AddOn information
    local CONSTANTS = {
        ADDON_NAME          = "pChat",
        ADDON_VERSION       = "10.0.5.8",

        API_VERSION         = GetAPIVersion(),

        CHAT_SYSTEM         = CHAT_SYSTEM,
    }

    -- Used for pChat LinkHandling
    CONSTANTS.PCHAT_LINK = "p"
    CONSTANTS.PCHAT_URL_CHAN = 97
    CONSTANTS.PCHAT_CHANNEL_SAY = 98
    CONSTANTS.PCHAT_CHANNEL_NONE = 99

    --Backup SavedVariables link on www.esoui.com
    CONSTANTS.BACKUP_SV_URL = "https://www.esoui.com/forums/showthread.php?t=9235" --"https://bit.ly/2SZcXzk" --""

    --The chat channels available
    CONSTANTS.chatChannelLangToLangStr = {
        [CHAT_CHANNEL_ZONE_LANGUAGE_1] = "EN",
        [CHAT_CHANNEL_ZONE_LANGUAGE_2] = "FR",
        [CHAT_CHANNEL_ZONE_LANGUAGE_3] = "DE",
        [CHAT_CHANNEL_ZONE_LANGUAGE_4] = "JP",
        [CHAT_CHANNEL_ZONE_LANGUAGE_5] = "RU",
        [CHAT_CHANNEL_ZONE_LANGUAGE_6] = "ES",
        [CHAT_CHANNEL_ZONE_LANGUAGE_7] = "ZH", --Chinese
    }

    CONSTANTS.MONSTER_CHAT_CHANNELS = {
        [CHAT_CHANNEL_MONSTER_SAY] = true,
        [CHAT_CHANNEL_MONSTER_YELL] = true,
        [CHAT_CHANNEL_MONSTER_WHISPER] = true,
        [CHAT_CHANNEL_MONSTER_EMOTE] = true,
    }

    CONSTANTS.maxChatCharCount = 350

    --For chat config sync -> The constant for the last logged in character (before current was logged in)
    -->Saved data of lastChar changes at call of function pChat.SaveChatConfig(), at the end, see line db.chatConfSync[CONSTANTS.chatConfigSyncLastChar] = db.chatConfSync[charId]
    CONSTANTS.chatConfigSyncLastChar = "lastChar"

    --Chat tabs that got no name will be saved/shown as this -> To ensure data consistency with saved chatTabIndices
    CONSTANTS.chatTabNoName = "- n/a -"

    --Lookup table with the chat channels and their names
    local COMBINED_CHANNELS = {
        [CHAT_CATEGORY_WHISPER_INCOMING] = {parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, name = SI_CHAT_CHANNEL_NAME_WHISPER},
        [CHAT_CATEGORY_WHISPER_OUTGOING] = {parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, name = SI_CHAT_CHANNEL_NAME_WHISPER},

        [CHAT_CATEGORY_MONSTER_SAY] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
        [CHAT_CATEGORY_MONSTER_YELL] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
        [CHAT_CATEGORY_MONSTER_WHISPER] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
        [CHAT_CATEGORY_MONSTER_EMOTE] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
    }
    CONSTANTS.COMBINED_CHANNELS = COMBINED_CHANNELS

    -- defines channels to skip when building the filter (non guild) section
    local SKIP_CHANNELS = {
        --[CHAT_CATEGORY_SYSTEM] = true,
        [CHAT_CATEGORY_GUILD_1] = true,
        [CHAT_CATEGORY_GUILD_2] = true,
        [CHAT_CATEGORY_GUILD_3] = true,
        [CHAT_CATEGORY_GUILD_4] = true,
        [CHAT_CATEGORY_GUILD_5] = true,
        [CHAT_CATEGORY_OFFICER_1] = true,
        [CHAT_CATEGORY_OFFICER_2] = true,
        [CHAT_CATEGORY_OFFICER_3] = true,
        [CHAT_CATEGORY_OFFICER_4] = true,
        [CHAT_CATEGORY_OFFICER_5] = true,
    }
    CONSTANTS.SKIP_CHANNELS = SKIP_CHANNELS
    --For the chat search UI -> Search history SavedVariables key
    CONSTANTS.SEARCH_TYPE_MESSAGE = 1
    CONSTANTS.SEARCH_TYPE_FROM = 2



------------------------------------------------------------------------------------------------------------------------
    --Add constants to pChat namespace
    pChat.CONSTANTS = CONSTANTS




------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Helper and updater fuctions for the constants
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

    --Build the chat category names and map them for the chat channels!
    local function updateChatChannelNames()
        local chatCategory2Name = {}
        local chatChannel2Name  = {}

        --Non guild chat categories
        local entryData = {}
        for i = CHAT_CATEGORY_HEADER_CHANNELS, CHAT_CATEGORY_HEADER_COMBAT - 1 do
            if(SKIP_CHANNELS[i] == nil and GetString("SI_CHATCHANNELCATEGORIES", i) ~= "") then
                local name
                if COMBINED_CHANNELS[i] == nil then
                    name = GetString("SI_CHATCHANNELCATEGORIES", i)
                else
                    --create the entry for those with combined channels just once
                    local parentChannel = COMBINED_CHANNELS[i].parentChannel
                    if not entryData[parentChannel] then
                        entryData[parentChannel] = true
                        name = GetString(COMBINED_CHANNELS[i].name)
                    end
                end
                if name ~= nil then
                    chatCategory2Name[i] = name
                end
            end
        end

        --Guild chat channels
        local maxGuild = CHAT_CATEGORY_HEADER_GUILDS + MAX_GUILDS - 1
        for k = CHAT_CATEGORY_HEADER_GUILDS, maxGuild do
            local name = GetString("SI_CHATCHANNELCATEGORIES", k)
            if name ~= nil then
                chatCategory2Name[k] = name
            end

            local officerChannel = k + MAX_GUILDS
            if officerChannel ~= nil then
                local officerName                 = GetString("SI_CHATCHANNELCATEGORIES", officerChannel)
                chatCategory2Name[officerChannel] = officerName
            end
        end
        pChat.CONSTANTS.chatCategory2Name = chatCategory2Name

        --Now map the chat categries to the channels
        for chatChannel=CHAT_CHANNEL_ITERATION_BEGIN, CHAT_CHANNEL_ITERATION_END, 1 do
            local chatCategory = GetChannelCategoryFromChannel(chatChannel)
            if chatCategory ~= nil then
                local chatCategoryName = chatCategory2Name[chatCategory]
                if chatCategoryName ~= nil then
                    chatChannel2Name[chatChannel] = chatCategoryName
                end
            end
        end
        --pChat custom chat channels
        chatChannel2Name[CONSTANTS.PCHAT_CHANNEL_SAY]  = chatChannel2Name[mapPChatChannelToChatChannel(CONSTANTS.PCHAT_CHANNEL_SAY)] --Say
        chatChannel2Name[CONSTANTS.PCHAT_CHANNEL_NONE] = "n/a"

        pChat.CONSTANTS.chatChannel2Name               = chatChannel2Name
    end
    pChat.updateChatChannelNames = updateChatChannelNames




    --Get the chat category and channel names now
    updateChatChannelNames()
end





--======================================================================================================================
-- AddOn pChatData
--======================================================================================================================
-- pChatData will receive variables and objects.
local pChatData = {}
pChat.pChatData = pChatData

--Chat categories for the chat config sync etc.
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
    CHAT_CATEGORY_ZONE_RUSSIAN,
    CHAT_CATEGORY_ZONE_SPANISH,
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