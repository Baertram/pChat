--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn Constants
--======================================================================================================================
    --AddOn information
    local CONSTANTS = {
        ADDON_NAME          = "pChat",
    }

    -- Used for pChat LinkHandling
    CONSTANTS.PCHAT_LINK = "p"
    CONSTANTS.PCHAT_URL_CHAN = 97
    CONSTANTS.PCHAT_CHANNEL_SAY = 98
    CONSTANTS.PCHAT_CHANNEL_NONE = 99

    --Add constants to pChat namespace
    pChat.CONSTANTS = CONSTANTS