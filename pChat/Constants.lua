--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn Constants
--======================================================================================================================
    --AddOn information
    local CONSTANTS = {
        ADDON_NAME          = "pChat",
        ADDON_VERSION       = "10.0.2.7",

        API_VERSION         = GetAPIVersion()
    }

    -- Used for pChat LinkHandling
    CONSTANTS.PCHAT_LINK = "p"
    CONSTANTS.PCHAT_URL_CHAN = 97
    CONSTANTS.PCHAT_CHANNEL_SAY = 98
    CONSTANTS.PCHAT_CHANNEL_NONE = 99

    --Backup SavedVariables link on www.esoui.com
    CONSTANTS.BACKUP_SV_URL = "https://www.esoui.com/forums/showthread.php?t=9235" --"https://bit.ly/2SZcXzk" --""

    --Add constants to pChat namespace
    pChat.CONSTANTS = CONSTANTS