local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

function pChat.InitializeCopyHandler()
    local pChatData = pChat.pChatData
    local db = pChat.db

    -- Set copied text into text entry, if possible
    local function CopyToTextEntry(message)

        -- Max of inputbox is 351 chars
        if string.len(message) < 351 then
            if CHAT_SYSTEM.textEntry:GetText() == "" then
                CHAT_SYSTEM.textEntry:Open(message)
                ZO_ChatWindowTextEntryEditBox:SelectAll()
            end
        end

    end

    -- Copy message (only message)
    local function CopyMessage(numLine)
        if not numLine or not db.LineStrings or not db.LineStrings[numLine] then return end
        -- Args are passed as string trought LinkHandlerSystem
        CopyToTextEntry(db.LineStrings[numLine].rawMessage)
    end

    --Copy line (including timestamp, from, channel, message, etc)
    local function CopyLine(numLine)
        if not numLine or not db.LineStrings or not db.LineStrings[numLine] then return end
        -- Args are passed as string trought LinkHandlerSystem
        CopyToTextEntry(db.LineStrings[numLine].rawLine)
    end

    -- Popup a dialog message with text to copy
    local function ShowCopyDialog(message)
        if not message or message == "" then return end
        -- Split text, courtesy of LibOrangUtils, modified to handle multibyte characters
        local function str_lensplit(text, maxChars)

            local ret                   = {}
            local text_len              = string.len(text)
            local UTFAditionalBytes = 0
            local fromWithUTFShift  = 0
            local doCut                 = true

            if(text_len <= maxChars) then
                ret[#ret+1] = text
            else

                local splittedStart = 0
                local splittedEnd = splittedStart + maxChars - 1

                local splittedString
                while doCut do

                    if UTFAditionalBytes > 0 then
                        fromWithUTFShift = UTFAditionalBytes
                    else
                        fromWithUTFShift = 0
                    end

                    local UTFAditionalBytes = 0

                    splittedEnd = splittedStart + maxChars - 1

                    if(splittedEnd >= text_len) then
                        splittedEnd = text_len
                        doCut = false
                    elseif (string.byte(text, splittedEnd, splittedEnd)) > 128 then
                        UTFAditionalBytes = 1

                        local lastByte = string.byte(splittedString, -1)
                        local beforeLastByte = string.byte(splittedString, -2, -2)

                        if (lastByte < 128) then
                        --
                        elseif lastByte >= 128 and lastByte < 192 then

                            if beforeLastByte >= 192 and beforeLastByte < 224 then
                            --
                            elseif beforeLastByte >= 128 and beforeLastByte < 192 then
                            --
                            elseif beforeLastByte >= 224 and beforeLastByte < 240 then
                                UTFAditionalBytes = 1
                            end

                            splittedEnd = splittedEnd + UTFAditionalBytes
                            splittedString = text:sub(splittedStart, splittedEnd)

                        elseif lastByte >= 192 and lastByte < 224 then
                            UTFAditionalBytes = 1
                            splittedEnd = splittedEnd + UTFAditionalBytes
                        elseif lastByte >= 224 and lastByte < 240 then
                            UTFAditionalBytes = 2
                            splittedEnd = splittedEnd + UTFAditionalBytes
                        end

                    end

                    --ret = ret+1
                    ret[#ret+1] = string.sub(text, splittedStart, splittedEnd)

                    splittedStart = splittedEnd + 1

                end
            end

            return ret

        end

        local maxChars      = 20000

        -- editbox is 20000 chars max
        if string.len(message) < maxChars then
            pChatCopyDialogTLCTitle:SetText(GetString(PCHAT_COPYXMLTITLE))
            pChatCopyDialogTLCLabel:SetText(GetString(PCHAT_COPYXMLLABEL))
            pChatCopyDialogTLCNoteEdit:SetText(message)
            pChatCopyDialogTLCNoteNext:SetHidden(true)
            pChatCopyDialogTLC:SetHidden(false)
            pChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
            pChatCopyDialogTLCNoteEdit:SelectAll()
        else

            pChatCopyDialogTLCTitle:SetText(GetString(PCHAT_COPYXMLTITLE))
            pChatCopyDialogTLCLabel:SetText(GetString(PCHAT_COPYXMLTOOLONG))

            pChatData.messageTableId = 1
            pChatData.messageTable = str_lensplit(message, maxChars)
            pChatCopyDialogTLCNoteNext:SetText(GetString(PCHAT_COPYXMLNEXT) .. " ( " .. pChatData.messageTableId .. " / " .. #pChatData.messageTable .. " )")
            pChatCopyDialogTLCNoteEdit:SetText(pChatData.messageTable[pChatData.messageTableId])
            pChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
            pChatCopyDialogTLCNoteEdit:SelectAll()

            pChatCopyDialogTLC:SetHidden(false)
            pChatCopyDialogTLCNoteNext:SetHidden(false)

            pChatCopyDialogTLCNoteEdit:TakeFocus()

        end

    end

    -- Copy discussion
    -- It will copy all text mark with the same chanCode
    -- Todo : Whisps by person
    local function CopyDiscussion(chanNumber, numLine)
        if not numLine or not chanNumber or not db.LineStrings or not db.LineStrings[numLine] then return end

        -- Args are passed as string trought LinkHandlerSystem
        local numChanCode = tonumber(chanNumber)
        -- Whispers sent and received together
        if numChanCode == CHAT_CHANNEL_WHISPER_SENT then
            numChanCode = CHAT_CHANNEL_WHISPER
        elseif numChanCode == CONSTANTS.PCHAT_URL_CHAN then
            numChanCode = db.LineStrings[numLine].channel
        end

        local stringToCopy = ""
        for k, data in ipairs(db.LineStrings) do
            local textToCopy = db.LineStrings[k].rawLine
            if textToCopy ~= nil then
                if numChanCode == CHAT_CHANNEL_WHISPER then -- or numChanCode == CHAT_CHANNEL_WHISPER_SENT then
                    if data.channel == CHAT_CHANNEL_WHISPER or data.channel == CHAT_CHANNEL_WHISPER_SENT then
                        if stringToCopy == "" then
                            stringToCopy = tostring(textToCopy)
                        else
                            stringToCopy = stringToCopy .. "\r\n" .. tostring(textToCopy)
                        end
                end
                elseif data.channel == numChanCode then
                    if stringToCopy == "" then
                        stringToCopy = tostring(textToCopy)
                    else
                        stringToCopy = stringToCopy .. "\r\n" .. tostring(textToCopy)
                    end
                end
            end
        end
        ShowCopyDialog(stringToCopy)
    end

    --Check if a chat category (of a chat channel) is enabled in any chat tab's settings
    local chatCatgoriesEnabledTable = {}
    local function isChatCategoryEnabledInAnyChatTab(chatChannel)
        local isChatCategoryEnabledAtAnyChatTabCheck = false
        if chatChannel and chatChannel ~= "" then
            local actualTab = 1
            local numTabs = #CHAT_SYSTEM.primaryContainer.windows
            local chatCategory = GetChannelCategoryFromChannel(chatChannel)
            if chatCategory then
                if chatCatgoriesEnabledTable[chatCategory] == true then return true end
                while actualTab <= numTabs do
                    if IsChatContainerTabCategoryEnabled(1, actualTab, chatCategory) then
                        isChatCategoryEnabledAtAnyChatTabCheck = true
                        chatCatgoriesEnabledTable[chatCategory] = true
                    end
                    actualTab = actualTab + 1
                end
            end
        end
        return isChatCategoryEnabledAtAnyChatTabCheck
    end

    -- Copy Whole chat (not tab)
    local function CopyWholeChat()
        chatCatgoriesEnabledTable = {}
        local stringToCopy = ""
        for k, data in ipairs(db.LineStrings) do
            --bug#3: Check if the chatChannel number is given and then check if the chatChannel's category is enabled somewhere at the current chat tabs
            --if not: Do not add this text to the dialog!
            local doAddLine = isChatCategoryEnabledInAnyChatTab(data.channel) or false
            if doAddLine == true then
                local textToCopy = db.LineStrings[k].rawLine
                if textToCopy ~= nil then
                    if stringToCopy == "" then
                        stringToCopy = tostring(textToCopy)
                    else
                        stringToCopy = stringToCopy .. "\r\n" .. tostring(textToCopy)
                    end
                end
            end
        end
        if stringToCopy and stringToCopy ~= "" then ShowCopyDialog(stringToCopy) end
    end

    -- Show contextualMenu when clicking on a pChatLink
    local function ShowContextMenuOnHandlers(numLine, chanNumber)

        ClearMenu()

        if not ZO_Dialogs_IsShowingDialog() then
            AddCustomMenuItem(GetString(PCHAT_COPYMESSAGECT), function() CopyMessage(numLine) end)
            AddCustomMenuItem(GetString(PCHAT_COPYLINECT), function() CopyLine(numLine) end)
            AddCustomMenuItem(GetString(PCHAT_COPYDISCUSSIONCT), function() CopyDiscussion(chanNumber, numLine) end)
            AddCustomMenuItem(GetString(PCHAT_ALLCT), CopyWholeChat)
        end

        ShowMenu()

    end

    -- Triggers when right clicking on a LinkHandler
    local function OnLinkClicked(rawLink, mouseButton, linkText, color, linkType, lineNumber, chanCode)

        -- Only executed on LinkType = CONSTANTS.PCHAT_LINK
        if linkType == CONSTANTS.PCHAT_LINK then

            local chanNumber = tonumber(chanCode)
            local numLine = tonumber(lineNumber)
            -- CONSTANTS.PCHAT_LINK also handle a linkable channel feature for linkable channels

            -- Context Menu
            if chanCode and mouseButton == MOUSE_BUTTON_INDEX_LEFT then

                -- Only Linkable channel - TODO use .channelLinkable
                if chanNumber == CHAT_CHANNEL_SAY
                    or chanNumber == CHAT_CHANNEL_YELL
                    or chanNumber == CHAT_CHANNEL_PARTY
                    or chanNumber == CHAT_CHANNEL_ZONE
                    or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_1
                    or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_2
                    or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_3
                    or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_4
                    or (chanNumber >= CHAT_CHANNEL_GUILD_1 and chanNumber <= CHAT_CHANNEL_GUILD_5)
                    or (chanNumber >= CHAT_CHANNEL_OFFICER_1 and chanNumber <= CHAT_CHANNEL_OFFICER_5) then
                    IgnoreMouseDownEditFocusLoss()
                    CHAT_SYSTEM:StartTextEntry(nil, chanNumber)
                elseif chanNumber == CHAT_CHANNEL_WHISPER then
                    local target = zo_strformat(SI_UNIT_NAME, db.LineStrings[numLine].rawFrom)
                    IgnoreMouseDownEditFocusLoss()
                    CHAT_SYSTEM:StartTextEntry(nil, chanNumber, target)
                elseif chanNumber == CONSTANTS.PCHAT_URL_CHAN then
                    RequestOpenUnsafeURL(linkText)
                end

            elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
                -- Right click, copy System
                ShowContextMenuOnHandlers(numLine, chanNumber)
            end

            -- Don't execute LinkHandler code
            return true

        end

    end

    -- Called by XML
    function pChat_ShowCopyDialogNext()

        pChatData.messageTableId = pChatData.messageTableId + 1

        -- Security
        if pChatData.messageTable[pChatData.messageTableId] then

            -- Build button
            pChatCopyDialogTLCNoteNext:SetText(GetString(PCHAT_COPYXMLNEXT) .. " ( " .. pChatData.messageTableId .. " / " .. #pChatData.messageTable .. " )")
            pChatCopyDialogTLCNoteEdit:SetText(pChatData.messageTable[pChatData.messageTableId])
            pChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
            pChatCopyDialogTLCNoteEdit:SelectAll()

            -- Don't show next button if its the last
            if not pChatData.messageTable[pChatData.messageTableId + 1] then
                pChatCopyDialogTLCNoteNext:SetHidden(true)
            end

            pChatCopyDialogTLCNoteEdit:TakeFocus()

        end

    end

    if db.enablecopy then
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, OnLinkClicked)
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)
    end
end
