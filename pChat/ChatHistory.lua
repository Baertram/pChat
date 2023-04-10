local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

local ChatSys = CONSTANTS.CHAT_SYSTEM

local mapChatChannelToPChatChannel = pChat.mapChatChannelToPChatChannel
local mapPChatChannelToChatChannel = pChat.mapPChatChannelToChatChannel

function pChat.InitializeChatHistory()
    local pChatData = pChat.pChatData
    local db = pChat.db
    local logger = pChat.logger

    local function StripLinesFromLineStrings(typeOfExit)

        local k = 1
        -- First loop is time based. If message is older than our limit, it will be stripped.
        while k <= #db.LineStrings do

            if db.LineStrings[k] then
                local channel = db.LineStrings[k].channel
                if channel == CHAT_CHANNEL_SYSTEM and (not db.restoreSystem) then
                    table.remove(db.LineStrings, k)
                    db.lineNumber = db.lineNumber - 1
                    k = k-1
                elseif channel ~= CHAT_CHANNEL_SYSTEM and db.restoreSystemOnly then
                    table.remove(db.LineStrings, k)
                    db.lineNumber = db.lineNumber - 1
                    k = k-1
                elseif (channel == CHAT_CHANNEL_WHISPER or channel == CHAT_CHANNEL_WHISPER_SENT) and (not db.restoreWhisps) then
                    table.remove(db.LineStrings, k)
                    db.lineNumber = db.lineNumber - 1
                    k = k-1
                elseif typeOfExit ~= 1 then
                    if db.LineStrings[k].rawTimestamp then
                        if (GetTimeStamp() - db.LineStrings[k].rawTimestamp) > (db.timeBeforeRestore * 60 * 60) then
                            table.remove(db.LineStrings, k)
                            db.lineNumber = db.lineNumber - 1
                            k = k-1
                        elseif db.LineStrings[k].rawTimestamp > GetTimeStamp() then -- System clock of users computer badly set and msg received meanwhile.
                            table.remove(db.LineStrings, k)
                            db.lineNumber = db.lineNumber - 1
                            k = k-1
                        end
                    end
                end
            end

            k = k + 1

        end

        -- 2nd loop is size based. If dump is too big, just delete old ones
        if k > 5000 then
            local linesToDelete = k - 5000
            for l=1, linesToDelete do

                if db.LineStrings[l] then
                    table.remove(db.LineStrings, l)
                    db.lineNumber = db.lineNumber - 1
                end

            end
        end

    end

    --Initialize some tables of the addon
    local function InitTables()
        -- Used for CopySystem
        if not db.lineNumber then
            db.lineNumber = 1
        elseif type(db.lineNumber) ~= "number" then
            db.lineNumber = 1
            db.LineStrings = {}
        elseif db.lineNumber > 5000 then
            StripLinesFromLineStrings(0)
        end

        if not db.chatTabChannel then db.chatTabChannel = {} end
        if not db.LineStrings then db.LineStrings = {} end
        if not pChat.tabNames then pChat.tabNames = {} end
    end

    local function SaveChatHistory(typeOf)

        db.history = {}

        if (db.restoreOnReloadUI == true and typeOf == 1) or (db.restoreOnLogOut == true and typeOf == 2) or (db.restoreOnAFK == true) or (db.restoreOnQuit == true and typeOf == 3) then

            if typeOf == 1 then

                db.lastWasReloadUI = true
                db.lastWasLogOut = false
                db.lastWasQuit = false
                db.lastWasAFK = false

                --Save actual channel
                db.history.currentChannel = ChatSys.currentChannel
                db.history.currentTarget = ChatSys.currentTarget

            elseif typeOf == 2 then
                db.lastWasReloadUI = false
                db.lastWasLogOut = true
                db.lastWasQuit = false
                db.lastWasAFK = false
            elseif typeOf == 3 then
                db.lastWasReloadUI = false
                db.lastWasLogOut = false
                db.lastWasQuit = true
                db.lastWasAFK = false
            end

            db.history.currentTab = pChatData.activeTab

            -- Save Chat History isn't needed, because it's saved in realtime, but we can strip some lines from the array to avoid big dumps
            StripLinesFromLineStrings(typeOf)

            --Save TextEntry history
            db.history.textEntry = {}
            if ChatSys.textEntry.commandHistory.entries then
                db.history.textEntry.entries = ChatSys.textEntry.commandHistory.entries
                db.history.textEntry.numEntries = ChatSys.textEntry.commandHistory.index
            else
                db.history.textEntry.entries = {}
                db.history.textEntry.numEntries = 0
            end
        else
            db.LineStrings = {}
            db.lineNumber = 1
        end

    end
    pChat.SaveChatHistory = SaveChatHistory

    -- Can cause infinite loads (why?)
    local function RestoreChatMessagesFromHistory(wasReloadUI)
        pChatData.preventWhisperNotificationsFromHistory = false

        -- Restore Chat
        local lastInsertionWas = 0
        local restoredPrefix = GetString(PCHAT_RESTORED_PREFIX)

        if db.LineStrings then

            local historyIndex = 1
            local categories = ZO_ChatSystem_GetEventCategoryMappings()

            while historyIndex <= #db.LineStrings do
                if db.LineStrings[historyIndex] then
                    local channelToRestore = db.LineStrings[historyIndex].channel
                    --if channelToRestore == CONSTANTS.PCHAT_CHANNEL_SAY then channelToRestore = CHAT_CHANNEL_SAY end
                    channelToRestore = mapPChatChannelToChatChannel(channelToRestore)

                    if channelToRestore == CHAT_CHANNEL_SYSTEM and not db.restoreSystem then
                        table.remove(db.LineStrings, historyIndex)
                        db.lineNumber = db.lineNumber - 1
                        historyIndex = historyIndex - 1
                    elseif channelToRestore ~= CHAT_CHANNEL_SYSTEM and db.restoreSystemOnly then
                        table.remove(db.LineStrings, historyIndex)
                        db.lineNumber = db.lineNumber - 1
                        historyIndex = historyIndex - 1
                    elseif (channelToRestore == CHAT_CHANNEL_WHISPER or channelToRestore == CHAT_CHANNEL_WHISPER_SENT) and not db.restoreWhisps then
                        table.remove(db.LineStrings, historyIndex)
                        db.lineNumber = db.lineNumber - 1
                        historyIndex = historyIndex - 1
                    else

                        local category = categories[EVENT_CHAT_MESSAGE_CHANNEL][channelToRestore]
                        local charId = GetCurrentCharacterId()

                        --Prevent the whisper notifications because of history restored messages
                        if db.notifyIM and db.doNotNotifyOnRestoredWhisperFromHistory == true and (channelToRestore == CHAT_CHANNEL_WHISPER or channelToRestore == CHAT_CHANNEL_WHISPER_SENT) then
                            pChatData.preventWhisperNotificationsFromHistory = true
                        end

                        local timeStamp = GetTimeStamp()
                        if db.LineStrings[historyIndex] and db.LineStrings[historyIndex].rawTimestamp and timeStamp - db.LineStrings[historyIndex].rawTimestamp < db.timeBeforeRestore * 60 * 60 and db.LineStrings[historyIndex].rawTimestamp < timeStamp then
                            lastInsertionWas = math.max(lastInsertionWas, db.LineStrings[historyIndex].rawTimestamp)
                            for containerIndex=1, #ChatSys.containers do
                                for tabIndex=1, #ChatSys.containers[containerIndex].windows do
                                    if IsChatContainerTabCategoryEnabled(ChatSys.containers[containerIndex].id, tabIndex, category) then
                                        if not db.chatConfSync[charId].tabs[tabIndex].notBefore or db.LineStrings[historyIndex].rawTimestamp > db.chatConfSync[charId].tabs[tabIndex].notBefore then
                                            local restoredChatRawText = db.LineStrings[historyIndex].rawValue
                                            if restoredChatRawText and restoredChatRawText ~= "" then
                                                if db.addHistoryRestoredPrefix == true then
                                                    --If the message was restored from history then add a prefix [H] )for history) to it!
                                                    restoredChatRawText = restoredPrefix .. restoredChatRawText
                                                end
                                                ChatSys.containers[containerIndex]:AddEventMessageToWindow(ChatSys.containers[containerIndex].windows[tabIndex], pChat.AddLinkHandler(restoredChatRawText, channelToRestore, historyIndex), category)
                                                -- TODO why is this commented out?
                                                --else
                                                --    --DEBUG: Add SavedVariables entries for erroneous history entries (without rawValue text etc.)
                                                --    local restoreError = ""
                                                --    if restoredChatRawText and restoredChatRawText == "" then
                                                --        --logger:Warn("restoredChatRawText is missing! HistoryIndex:", historyIndex)
                                                --        restoreError = "rawText was missing"
                                                --    else
                                                --        --logger:Warn("restoredChatRawText is empty! HistoryIndex:", historyIndex)
                                                --        restoreError = "rawText was empty"
                                                --    end
                                                --    db.wrongRestoredHistoryIndices = db.wrongRestoredHistoryIndices or {}
                                                --    db.wrongRestoredHistoryIndices[historyIndex] = db.LineStrings[historyIndex]
                                                --    db.wrongRestoredHistoryIndices[historyIndex].restoreError = restoreError
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            table.remove(db.LineStrings, historyIndex)
                            db.lineNumber = db.lineNumber - 1
                            historyIndex = historyIndex - 1
                        end

                    end
                end
                historyIndex = historyIndex + 1
            end

            local PRESSED = 1
            local UNPRESSED = 2
            local numTabs = #ChatSys.primaryContainer.windows

            for numTab, container in ipairs (ChatSys.primaryContainer.windows) do
                if numTab > 1 then
                    ChatSys.primaryContainer:HandleTabClick(container.tab)
                    local tabText = pChat.GetTabTextControl(numTab)
                    tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                    tabText:GetParent().state = PRESSED
                    local oldTabText = pChat.GetTabTextControl(numTab - 1)
                    oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                    oldTabText:GetParent().state = UNPRESSED
                end
            end

            if numTabs > 1 then
                ChatSys.primaryContainer:HandleTabClick(ChatSys.primaryContainer.windows[1].tab)
                local tabText = pChat.GetTabTextControl(1)
                tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                tabText:GetParent().state = PRESSED
                local oldTabText = pChat.GetTabTextControl(#ChatSys.primaryContainer.windows)
                oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                oldTabText:GetParent().state = UNPRESSED
            end

        end

        -- Restore TextEntry History
        if (wasReloadUI or db.restoreTextEntryHistoryAtLogOutQuit) and db.history.textEntry then

            if db.history.textEntry.entries then

                if lastInsertionWas and ((GetTimeStamp() - lastInsertionWas) < (db.timeBeforeRestore * 60 * 60)) then
                    for _, text in ipairs(db.history.textEntry.entries) do
                        ChatSys.textEntry:AddCommandHistory(text)
                    end

                    ChatSys.textEntry.commandHistory.index = db.history.textEntry.numEntries
                end

            end

        end
        pChatData.preventWhisperNotificationsFromHistory = false
    end

    --**** Issue
    local function SetDefaultTab(tabToSet)
        logger:Debug("DefaultTab", "START, tabToSet: " ..tostring(tabToSet))
        if not ChatSys or not ChatSys.primaryContainer or not ChatSys.primaryContainer.windows then return end
        --OLD CODE
        --[[
        -- Search in all tabs the good name
        for numTab in ipairs(ChatSys.primaryContainer.windows) do
            -- Not this one, try the next one, if tab is not found (newly added, removed), pChat_SwitchToNextTab() will go back to tab 1
            if tonumber(tabToSet) ~= numTab then
                pChat_SwitchToNextTab()
            else
                -- Found it, stop
                logger.verbose:Debug(">DefaultTab", "was set")
                return
            end
        end
        ]]
        --NEW CODE
        pChat_ChangeTab(tabToSet)
    end
    pChat.SetDefaultTab = SetDefaultTab

    -- Restore History from SavedVars
    local function RestoreChatHistory()
        -- Set default tab at login -> Moved to event_player_activated
        --SetDefaultTab(db.defaultTab)

        -- Restore History
        if db.history then

            if db.lastWasReloadUI and db.restoreOnReloadUI then

                -- RestoreChannel
                if db.defaultchannel ~= CONSTANTS.PCHAT_CHANNEL_NONE then
                    ChatSys:SetChannel(db.history.currentChannel, db.history.currentTarget)
                end

                -- restore TextEntry and Chat
                RestoreChatMessagesFromHistory(true)

                -- Restore tab when ReloadUI
                --** blocking for now
                --SetDefaultTab(db.history.currentTab)

            elseif (db.lastWasLogOut and db.restoreOnLogOut) or (db.lastWasAFK and db.restoreOnAFK) or (db.lastWasQuit and db.restoreOnQuit) then
                -- restore TextEntry and Chat
                RestoreChatMessagesFromHistory(false)
            end

            pChatData.messagesHaveBeenRestorated = true

            --Prevent the whisper notifications because of history restored messages
            pChatData.preventWhisperNotificationsFromHistory = false

            db.lastWasReloadUI = false
            db.lastWasLogOut = false
            db.lastWasQuit = false
            db.lastWasAFK = true
        else
            pChatData.messagesHaveBeenRestorated = true
        end
		-- @Baertram - By Ernest Bagwell 2023-02-10 Added this line to show the player name and zone, it will be added once the add-on has loaded the historical chats ######
        -- CHAT_SYSTEM:AddMessage(string.format("pChat loaded: %s in %s", GetUnitName("player"), ZO_WorldMapTitle:GetText()))
        if db.restoreShowCurrentNameAndZone == true then
            CHAT_SYSTEM:AddMessage(string.format("[pChat]History restored: %s in %s", GetDisplayName()  .. " - " .. zo_strformat(SI_UNIT_NAME, GetUnitName("player")), ZO_WorldMapTitle:GetText()))
        end
    end
    pChat.RestoreChatHistory = RestoreChatHistory

    -- Store line number
    -- Create an array for the copy functions, spam functions and revert history functions
    -- WARNING : See FormatSysMessage()
    local function StorelineNumber(rawTimestamp, rawFrom, text, chanCode, originalFrom, wasTimeStampAdded)
        logger.verbose:Debug(string.format("StoreLineNumber-Channel %s: [%s]%s(%s) %s", tostring(chanCode), tostring(rawTimestamp), tostring(originalFrom), tostring(rawFrom), tostring(text)))
        wasTimeStampAdded = wasTimeStampAdded or false

        -- Strip DDS tag from Copy text
        local function StripDDStags(text)
            return text:gsub("|t(.-)|t", "")
        end

        local formattedMessage = ""
        local rawText = text

        -- Timestamp cannot be nil anymore with SpamFilter, so use the option itself
        if not wasTimeStampAdded and db.showTimestamp then
            -- Format for Copy
            formattedMessage = "[" .. pChat.CreateTimestamp(GetTimeString()) .. "] "
        end

        -- SysMessages does not have a from
        if chanCode ~= CHAT_CHANNEL_SYSTEM then


            -- Strip DDS tags for GM
            rawFrom = StripDDStags(rawFrom)

            -- Needed for SpamFilter
            db.LineStrings[db.lineNumber].rawFrom = originalFrom

            -- formattedMessage is only rawFrom for now
            formattedMessage = formattedMessage .. rawFrom

            if db.carriageReturn then
                formattedMessage = formattedMessage .. "\n"
            end

        end

        -- Needed for SpamFilter & Restoration, UNIX timestamp
        db.LineStrings[db.lineNumber].rawTimestamp = rawTimestamp

        -- Store CopyMessage / Used for SpamFiltering. Due to lua 0 == nil in arrays, set value to 98
        chanCode = mapChatChannelToPChatChannel(chanCode)
        --[[
        if chanCode == CHAT_CHANNEL_SAY then
            db.LineStrings[db.lineNumber].channel = CONSTANTS.PCHAT_CHANNEL_SAY
        else
        ]]
            db.LineStrings[db.lineNumber].channel = chanCode
        --end

        -- Store CopyMessage
        db.LineStrings[db.lineNumber].rawText = rawText

        -- Store CopyMessage
        --db.LineStrings[db.lineNumber].rawValue = text

        -- Strip DDS tags
        rawText = StripDDStags(rawText)

        -- Used to translate LinkHandlers
        rawText = pChat.FormatRawText(rawText)

        -- Store CopyMessage
        db.LineStrings[db.lineNumber].rawMessage = rawText

        -- Store CopyLine
        db.LineStrings[db.lineNumber].rawLine = formattedMessage .. rawText

        --Increment at each message handled
        db.lineNumber = db.lineNumber + 1

    end
    pChat.StorelineNumber = StorelineNumber

    --Init some tables of the addon
    InitTables()
end
