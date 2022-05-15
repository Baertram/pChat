--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn Constants
--======================================================================================================================
    --AddOn information
    local CONSTANTS = {
        ADDON_NAME          = "pChat",
        ADDON_VERSION       = "10.0.2.9",

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

    --API101034 High Isle - Spanish language added
	local isESLangProvided = CHAT_CHANNEL_ZONE_LANGUAGE_6 ~= nil
	if not isESLangProvided then
		CHAT_CHANNEL_ZONE_LANGUAGE_6 = 37 --workaround to add ES language stuff at live server already
	end

    CONSTANTS.chatChannelLangToLangStr = {
        [CHAT_CHANNEL_ZONE_LANGUAGE_1] = "EN",
        [CHAT_CHANNEL_ZONE_LANGUAGE_2] = "FR",
        [CHAT_CHANNEL_ZONE_LANGUAGE_3] = "DE",
        [CHAT_CHANNEL_ZONE_LANGUAGE_4] = "JP",
        [CHAT_CHANNEL_ZONE_LANGUAGE_5] = "RU",
        [CHAT_CHANNEL_ZONE_LANGUAGE_6] = "ES"
    }

    --Add constants to pChat namespace
    pChat.CONSTANTS = CONSTANTS

