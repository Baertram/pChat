--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn Constants
--======================================================================================================================
local CONSTANTS     = pChat.CONSTANTS
local ADDON_NAME    = CONSTANTS.ADDON_NAME

function pChat.LoadDialogs()
    --The reminder to backup the SavedVariables
    ESO_Dialogs["PCHAT_BACKUP_SV_REMINDER"] =
    {
        title =
        {
            text = "[" .. ADDON_NAME .. "] " .. GetString(PCHAT_SETTINGS_BACKUP_REMINDER),
        },
        mainText =
        {
            text = GetString(PCHAT_SETTINGS_BACKUP_REMINDER_DIALOG_TEXT),
        },
        --[[
        editBox =
        {
            matchingString = GetString(SI_DESTROY_ITEM_CONFIRMATION)
        },
        ]]
        noChoiceCallback =  function()

        end,
        buttons =
        {
            {
                --requiresTextInput = true,
                text =      SI_DIALOG_CONFIRM,
                callback =  function(dialog)
                    local warningText = "[" .. ADDON_NAME .. "] " .. GetString(PCHAT_SETTINGS_WARNING_REMINDER_LOGOUT_BEFORE)
                    d(warningText)
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.AVA_GATE_OPENED, warningText)

                    RequestOpenUnsafeURL(CONSTANTS.BACKUP_SV_URL)
                end,
            },
            {
                text =       SI_DIALOG_CANCEL,
                callback =  function(dialog)
                end,
            }
        }
    }

end