local ADDON_NAME = pChat.CONSTANTS.ADDON_NAME
local PCHAT_LINK = pChat.CONSTANTS.PCHAT_LINK

--local WM = WINDOW_MANAGER

function pChat.InitializeAutomatedMessages()
    local pChatData = pChat.pChatData
    local db = pChat.db

    pChat.MENU_CATEGORY_PCHAT = nil
    local MENU_CATEGORY_PCHAT

    -- Init Automated Messages
    local automatedMessagesList = ZO_SortFilterList:Subclass()


    function automatedMessagesList:New(control)
        ZO_SortFilterList.InitializeSortFilterList(self, control)

        local AutomatedMessagesSorterKeys =
            {
                ["name"] = {},
                ["message"] = {tiebreaker = "name"}
            }

        self.masterList = {}
        ZO_ScrollList_AddDataType(self.list, 1, "pChatXMLAutoMsgRowTemplate", 32, function(control, data) self:SetupEntry(control, data) end)
        ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
        self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, AutomatedMessagesSorterKeys, self.currentSortOrder) end
        --self:SetAlternateRowBackgrounds(true)

        return self
    end

    -- format ESO text to raw text
    -- IE : Transforms LinkHandlers into their displayed value
    local function FormatRawText(text)

        -- Strip colors from chat
        local newtext = string.gsub(text, "|[cC]%x%x%x%x%x%x", ""):gsub("|r", "")

        -- Transforms a LinkHandler into its localized displayed value
        -- "|H(.-):(.-)|h(.-)|h" = pattern for Linkhandlers
        -- Item : |H1:item:33753:25:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h = [Battaglir] in french -> Link to item 33753, etc
        -- Achievement |H1:achievement:33753|h|h etc (not searched a lot, was easy)
        -- DisplayName = |H1:display:Ayantir|h[@Ayantir]|h = [@Ayantir] -> link to DisplayName @Ayantir
        -- Book = |H1:book:186|h|h = [Climat de guerre] in french -> Link to book 186 .. GetLoreBookTitleFromLink()
        -- pChat = |H1:PCHAT_LINK:124:11|h[06:18]|h = [06:18] (here 0 is the line number reference and 11 is the chanCode) - URL handling : if chanCode = 97, it will popup a dialog to open internet browser
        -- Character = |H1:character:salhamandhil^Mx|h[salhamandhil]|h = text (is there anything which link Characters into a message ?) (here salhamandhil is with brackets volontary)
        -- Need to do quest_items too. |H1:quest_item:4275|h|h

        newtext = string.gsub(newtext, "|H(.-):(.-)|h(.-)|h", function (linkStyle, data, text)
            -- linkStyle = style (ignored by game, seems to be often 1)
            -- data = data saparated by ":"
            -- text = text displayed, used for Channels, DisplayName, Character, and some fake itemlinks (used by addons)

            -- linktype is : item, achievement, character, channel, book, display, pchatlink
            -- DOES NOT HANDLE ADDONS LINKTYPES

            -- for all types, only param1 is important
            local linkType, param1 = zo_strsplit(':', data)

            -- param1 : itemID
            -- Need to get
            if linkType == ITEM_LINK_TYPE or linkType == COLLECTIBLE_LINK_TYPE then
                -- Fakelink and GetItemLinkName
                return "[" .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H" .. linkStyle ..":" .. data .. "|h|h")) .. "]"
                    -- param1 : achievementID
            elseif linkType == ACHIEVEMENT_LINK_TYPE then
                -- zo_strformat to avoid masculine/feminine problems
                return "[" .. zo_strformat(GetAchievementInfo(param1)) .. "]"
                    -- SysMessages Links CharacterNames
            elseif linkType == CHARACTER_LINK_TYPE then
                return text
            elseif linkType == CHANNEL_LINK_TYPE then
                return text
            elseif linkType == BOOK_LINK_TYPE then
                return "[" .. GetLoreBookTitleFromLink(newtext) .. "]"
                    -- SysMessages Links DysplayNames
            elseif linkType == DISPLAY_NAME_LINK_TYPE then
                -- No formatting here
                return "[@" .. param1 .. "]"
                    -- Used for Sysmessages
            elseif linkType == "quest_item" then
                -- No formatting here
                return "[" .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetQuestItemNameFromLink(newtext)) .. "]"
            elseif linkType == PCHAT_LINK then
                -- No formatting here .. maybe yes ?..
                return text
            end
        end)

        return newtext

    end
    pChat.FormatRawText = FormatRawText

    function automatedMessagesList:SetupEntry(control, data)

        control.data = data
        control.name = GetControl(control, "Name")
        control.message = GetControl(control, "Message")

        local messageTrunc = FormatRawText(data.message)
        if string.len(messageTrunc) > 53 then
            messageTrunc = string.sub(messageTrunc, 1, 53) .. " .."
        end

        control.name:SetText(data.name)
        control.message:SetText(messageTrunc)

        ZO_SortFilterList.SetupRow(self, control, data)

    end

    function automatedMessagesList:BuildMasterList()
        self.masterList = {}
        local messages = db.automatedMessages
        if messages then
            for k, v in ipairs(messages) do
                local data = v
                table.insert(self.masterList, data)
            end
        end

    end

    function automatedMessagesList:SortScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, self.sortFunction)
    end

    function automatedMessagesList:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        for i = 1, #self.masterList do
            local data = self.masterList[i]
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
        end
    end

    local function GetDataByNameInSavedAutomatedMessages(name)
        local dataList = db.automatedMessages
        for index, data in ipairs(dataList) do
            if(data.name == name) then
                return data, index
            end
        end
    end

    local function GetDataByNameInAutomatedMessages(name)
        local dataList = pChatData.automatedMessagesList.list.data
        for i = 1, #dataList do
            local data = dataList[i].data
            if(data.name == name) then
                return data
            end
        end
    end

    local function SaveAutomatedMessage(name, message, isNew)

        if db then

            local alreadyFav = false

            if isNew then
                for k, v in pairs(db.automatedMessages) do
                    if "!" .. name == v.name then
                        alreadyFav = true
                    end
                end
            end

            if not alreadyFav then

                pChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(true)
                pChatXMLAutoMsg:GetNamedChild("Warning"):SetText("")

                if string.len(name) > 12 then
                    name = string.sub(name, 1, 12)
                end

                if string.len(message) > 351 then
                    message = string.sub(message, 1, 351)
                end

                local entryList = ZO_ScrollList_GetDataList(pChatData.automatedMessagesList.list)

                if isNew then
                    local data = {name = "!" .. name, message = message}
                    local entry = ZO_ScrollList_CreateDataEntry(1, data)
                    table.insert(entryList, entry)
                    table.insert(db.automatedMessages, {name = "!" .. name, message = message}) -- "data" variable is modified by ZO_ScrollList_CreateDataEntry and will crash eso if saved to savedvars
                else

                    local data = GetDataByNameInAutomatedMessages(name)
                    local _, index = GetDataByNameInSavedAutomatedMessages(name)

                    data.message = message
                    db.automatedMessages[index].message = message
                end

                ZO_ScrollList_Commit(pChatData.automatedMessagesList.list)

                pChat.OnpChatAutoMsgAutoCompleteUpdated()

            else
                pChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(false)
                pChatXMLAutoMsg:GetNamedChild("Warning"):SetText(GetString(PCHAT_SAVMSGERRALREADYEXISTS))
                pChatXMLAutoMsg:GetNamedChild("Warning"):SetColor(1, 0, 0)
                zo_callLater(function() pChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(true) end, 5000)
            end

        end

    end

    local function CleanAutomatedMessageListForDB()
        -- :RefreshData() adds dataEntry recursively, delete it to avoid overflow in SavedVars
        for k, v in ipairs(db.automatedMessages) do
            if v.dataEntry then
                v.dataEntry = nil
            end
        end
    end

    local function RemoveAutomatedMessage()

        local data = ZO_ScrollList_GetData(moc()) --WM:GetMouseOverControl()
        local _, index = GetDataByNameInSavedAutomatedMessages(data.name)
        table.remove(db.automatedMessages, index)
        pChatData.automatedMessagesList:RefreshData()
        CleanAutomatedMessageListForDB()

        pChat.OnpChatAutoMsgAutoCompleteUpdated()
    end


    -- Init Automated messages, build the scene and handle array of automated strings
    local function InitAutomatedMessages()
        pChat_BuildAutomatedMessagesDialog(pChatXMLAutoMsgDialog)

        -- Create Scene
        PCHAT_AUTOMSG_SCENE = ZO_Scene:New("pChatAutomatedMessagesScene", SCENE_MANAGER)

        -- Mouse standard position and background
        PCHAT_AUTOMSG_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
        PCHAT_AUTOMSG_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

        -- Background Right, it will set ZO_RightPanelFootPrint and its stuff.
        PCHAT_AUTOMSG_SCENE:AddFragment(RIGHT_BG_FRAGMENT)

        -- The title fragment
        PCHAT_AUTOMSG_SCENE:AddFragment(TITLE_FRAGMENT)

        -- Set Title
        ZO_CreateStringId("SI_PCHAT_AUTOMSG_TITLE", ADDON_NAME)
        PCHAT_AUTOMSG_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_PCHAT_AUTOMSG_TITLE)
        PCHAT_AUTOMSG_SCENE:AddFragment(PCHAT_AUTOMSG_TITLE_FRAGMENT)

        -- Add the XML to our scene
        PCHAT_AUTOMSG_SCENE_WINDOW = ZO_FadeSceneFragment:New(pChatXMLAutoMsg)
        PCHAT_AUTOMSG_SCENE:AddFragment(PCHAT_AUTOMSG_SCENE_WINDOW)

        -- Register Scenes and the group name
        SCENE_MANAGER:AddSceneGroup("pChatSceneGroup", ZO_SceneGroup:New("pChatAutomatedMessagesScene"))

        -- Its infos
        PCHAT_MAIN_MENU_CATEGORY_DATA =
        {
            binding = "PCHAT_SHOW_AUTO_MSG",
            categoryName = PCHAT_SHOW_AUTO_MSG,
            normal = "EsoUI/Art/MainMenu/menuBar_champion_up.dds",
            pressed = "EsoUI/Art/MainMenu/menuBar_champion_down.dds",
            highlight = "EsoUI/Art/MainMenu/menuBar_champion_over.dds",
        }

        MENU_CATEGORY_PCHAT = LibMainMenu2:AddCategory(PCHAT_MAIN_MENU_CATEGORY_DATA)

        local iconData = {
            {
                categoryName = SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG,
                descriptor = "pChatAutomatedMessagesScene",
                normal = "EsoUI/Art/MainMenu/menuBar_champion_up.dds",
                pressed = "EsoUI/Art/MainMenu/menuBar_champion_down.dds",
                highlight = "EsoUI/Art/MainMenu/menuBar_champion_over.dds",
            },
        }

        -- Register the group and add the buttons (we cannot all AddRawScene, only AddSceneGroup, so we emulate both functions).
        if MENU_CATEGORY_PCHAT then
            LibMainMenu2:AddSceneGroup(MENU_CATEGORY_PCHAT, "pChatSceneGroup", iconData)
            pChat.MENU_CATEGORY_PCHAT = MENU_CATEGORY_PCHAT
        end

        pChatData.autoMsgDescriptor = {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            {
                name = GetString(PCHAT_AUTOMSG_ADD_AUTO_MSG),
                keybind = "UI_SHORTCUT_PRIMARY",
                --control = self, -- TODO self is not defined here
                callback = function(descriptor) ZO_Dialogs_ShowDialog("PCHAT_AUTOMSG_SAVE_MSG", nil, {mainTextParams = {}}) end,
                visible = function(descriptor) return true end
            },
            {
                name = GetString(PCHAT_AUTOMSG_EDIT_AUTO_MSG),
                keybind = "UI_SHORTCUT_SECONDARY",
                --control = self, -- TODO self is not defined here
                callback = function(descriptor) ZO_Dialogs_ShowDialog("PCHAT_AUTOMSG_EDIT_MSG", nil, {mainTextParams = {}}) end,
                visible = function(descriptor)
                    if pChatData.autoMessagesShowKeybind then
                        return true
                    else
                        return false
                    end
                end
            },
            {
                name = GetString(PCHAT_AUTOMSG_REMOVE_AUTO_MSG),
                keybind = "UI_SHORTCUT_NEGATIVE",
                --control = self, -- TODO self is not defined here
                callback = function(descriptor) RemoveAutomatedMessage() end,
                visible = function(descriptor)
                    if pChatData.autoMessagesShowKeybind then
                        return true
                    else
                        return false
                    end
                end
            },
        }

        pChatData.pChatAutomatedMessagesScene = SCENE_MANAGER:GetScene("pChatAutomatedMessagesScene")
        pChatData.pChatAutomatedMessagesScene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING then
                KEYBIND_STRIP:AddKeybindButtonGroup(pChatData.autoMsgDescriptor)
            elseif newState == SCENE_HIDDEN then
                if KEYBIND_STRIP:HasKeybindButtonGroup(pChatData.autoMsgDescriptor) then
                    KEYBIND_STRIP:RemoveKeybindButtonGroup(pChatData.autoMsgDescriptor)
                end
            end
        end)

        if not db.automatedMessages then
            db.automatedMessages = {}
        end

        pChatData.automatedMessagesList = automatedMessagesList:New(pChatXMLAutoMsg)
        pChatData.automatedMessagesList:RefreshData()
        CleanAutomatedMessageListForDB()

        pChatData.automatedMessagesList.keybindStripDescriptor = pChatData.autoMsgDescriptor
    end

    function pChat.InitAutomatedMessagesAutoCompletion()
        -- =====================================================================================================================
        -- 20250103 Auto completion at chat editbox - Including pChat's /msg custom ! prefixed "slash commands"
        -- =====================================================================================================================
        --[[
            sharedchatsystem.lua
            self.textEntry = TextEntry:New(self, control:GetNamedChild("TextEntry"), platformSettings.chatEditBufferTop, platformSettings.chatEditBufferBottom)
            -> self = SharedChatSystem -> ZO_ChatSystem -> object = KEYBOARD_CHAT_SYSTEM


            local NO_INCLUDE_FLAGS = nil
            local NO_EXCLUDE_FLAGS = nil
            local DEFAULT_ONLINE_ONLY = nil
            local MAX_RESULTS = 8
            self.slashCommandAutoComplete = SlashCommandAutoComplete:New(self.editControl, NO_INCLUDE_FLAGS, NO_EXCLUDE_FLAGS, DEFAULT_ONLINE_ONLY, MAX_RESULTS, AUTO_COMPLETION_AUTOMATIC_MODE, AUTO_COMPLETION_DONT_USE_ARROWS)
            -> self = KEYBOARD_CHAT_SYSTEM.textEntry

            Add another auto completion for entries in pChat's /msg table
        ]]

        --[[
        local MAX_AUTO_COMPLETION_RESULTS = 10
        local function pChat_AutomatedMessages_GetAutoCompletionResults(selfVar, text)
            --d("[pChat]pChatAutoMsgAutoComplete:GetAutoCompletionResults - text: " ..tostring(text))
            if #text < 2 then
                return
            end
            local startChar = text:sub(1, 1)
            if startChar ~= "!" then
                return
            end
            if text:find(" ", 1, true) then
                return
            end

            if next(selfVar.possibleMatches) == nil then
                for _, commandData in ipairs(pChat.db.automatedMessages) do
                    local command = commandData.name
                    if #command > 0 then
                        selfVar.possibleMatches[command:lower()] = command
                    end
                end
            end

            local results = GetTopMatchesByLevenshteinSubStringScore(selfVar.possibleMatches, text, 2, selfVar.maxResults)
            if results then
                return unpack(results)
            end
            return nil
        end
        ]]



        local LSC = LibSlashCommander
        if LSC then
            --Currently only activates with the / slash command as prefix :(
            local pChat_LSC_AutoMessageCommand

            local commandsAutoCompleteProvidersList = {}

            local resultsList = {}
            local lookupList = {}

            local function AddCommand(results, lookup, alias, description)
                local label = LSC:GenerateLabel(alias, description)
                if(label ~= alias) then
                    lookup[label] = alias
                end
                results[zo_strlower(alias)] = label
            end

            local function getCachedResultsList(init)
--d("[pChat]getCachedResultsList-init: " ..tostring(init) .. "; updateAutoMessageResultsList: " .. tostring(pChat.updateAutoMessageResultsList))
                if pChat.updateAutoMessageResultsList or ZO_IsTableEmpty(resultsList) then
                    resultsList = {}
                    lookupList = {}

                    for _, commandData in ipairs(pChat.db.automatedMessages) do
                        AddCommand(resultsList, lookupList, commandData.name, commandData.message)
                    end

                    if not init then
                        table.insert(commandsAutoCompleteProvidersList, pChat.LSC_AutoMessageAutoComplete)
                    end

                    if not ZO_IsTableEmpty(commandsAutoCompleteProvidersList) then
                        for _, autoCompleteProvider in ipairs(commandsAutoCompleteProvidersList) do
                            if autoCompleteProvider ~= nil then
--d(">calling SetLists for autoCompleteProvider: " ..tostring(autoCompleteProvider) .. ",  pChat.LSC_AutoMessageAutoComplete: " .. tostring(pChat.LSC_AutoMessageAutoComplete))
                                autoCompleteProvider:SetLists(resultsList, lookupList)
                            end
                        end
                    end

                    pChat.updateAutoMessageResultsList = nil
                end
            end
            getCachedResultsList(true)

            --Called if /msg was used to add/remove entries
            local function OnpChatAutoMsgAutoCompleteUpdated()
--d("[pChat]OnpChatAutoMsgAutoCompleteUpdated")
                pChat.updateAutoMessageResultsList = true
                getCachedResultsList(false)
                --pChat.LSC_AutoMessageAutoComplete:SetLists(resultsList, lookupList) --done within getCachedResultsList already
            end
            pChat.OnpChatAutoMsgAutoCompleteUpdated = OnpChatAutoMsgAutoCompleteUpdated


            local pChatAutoMsgAutoComplete = LSC.AutoCompleteProvider:Subclass()
            function pChatAutoMsgAutoComplete:New(myResultsList, myLookupList)
                local autoCompleteProviderObject = LSC.AutoCompleteProvider.New(self)
                autoCompleteProviderObject:SetLists(myResultsList, myLookupList)
                autoCompleteProviderObject:SetPrefix("!")
                return autoCompleteProviderObject
            end

            function pChatAutoMsgAutoComplete:SetLists(myResultsList, myLookupList)
                self.resultsList = myResultsList
                self.lookupList = myLookupList
            end

            function pChatAutoMsgAutoComplete:GetResultList()
--d("[pChat]pChatAutoMsgAutoComplete - GetResultList")
                return self.resultsList
            end

            function pChatAutoMsgAutoComplete:GetResultFromLabel(label)
--d("[pChat]pChatAutoMsgAutoComplete - GetResultFromLabel - label: " .. tostring(label))
                return self.lookupList[label] or label
            end

            function pChatAutoMsgAutoComplete:CanComplete(token)
                local prefix = self.prefix
                local retVar = not prefix or (token:sub(1, #prefix) == prefix)
--d("[pChat]pChatAutoMsgAutoComplete - CanComplete - token: " .. tostring(token) .. ", retVar: " ..tostring(retVar))
                return retVar
            end


            local function Sanitize(value)
                return value:gsub("[-*+?^$().[%]%%]", "%%%0") -- escape meta characters
            end

            local function RunAutoCompletion(selfVar, command, text)
--d("[pChat]RunAutoCompletion - text: " .. tostring(text))
                selfVar.ignoreTextEntryChangedEvent = true
                LSC.currentCommand = command --Leave this in so GetAutoCompletionResults works properly!
                selfVar.textEntry:AutoCompleteTarget(text) --> Calls LSC's GetAutoCompletionResults function via wrapper of selfVar.targetAutoComplete.GetAutoCompletionResults
                selfVar.ignoreTextEntryChangedEvent = false
            end

            local function OnTextEntryChanged(selfVar, text)
--d("[pChat]OnTextEntryChanged - text: " .. tostring(text))
                if(selfVar.ignoreTextEntryChangedEvent or not pChat_LSC_AutoMessageCommand:ShouldAutoComplete(text)) then return end
                LSC.currentCommand = nil

                local command, token = LSC.GetCurrentCommandAndToken(pChat_LSC_AutoMessageCommand, text)
                if(not command or not LSC.IsCommand(command)) then return end

                LSC.lastInput = text:match(string.format("(.+)%%s+%s$", Sanitize(token)))
                if(command:ShouldAutoComplete(token)) then
                    RunAutoCompletion(selfVar, command, token)
                    return true
                end
            end
            ZO_PreHook(CHAT_SYSTEM, "OnTextEntryChanged", OnTextEntryChanged)

            local function OnAutoCompleteEntrySelected(self, text)
                local command = LSC.hasCustomResults
                if(command and command == pChat_LSC_AutoMessageCommand)  then
--d("[pChat]OnAutoCompleteEntrySelected - text: " .. tostring(text))
                    text = command:GetAutoCompleteResultFromDisplayText(text)
                    if(LSC.lastInput) then
                        text = string.format("%s %s", LSC.lastInput, text)
                        LSC.lastInput = nil
                    else
                        text = string.format("%s", text)
                    end
                    --Remove trailing spaces
                    --text = string.gsub(text, '[ \t]+%f[\r\n%z]', '')

                    StartChatInput(text)
                    return true
                end
            end
            ZO_PreHook(CHAT_SYSTEM, "OnAutoCompleteEntrySelected", OnAutoCompleteEntrySelected)

            pChat_LSC_AutoMessageCommand = LSC.Command:New()
            --pChat_LSC_AutoMessageCommand.subCommandAliases = resultsList
            pChat_LSC_AutoMessageCommand.subCommandAliases = setmetatable({}, {
                __index = function(_, key)
                    key = zo_strlower(key)
                    -- use the globals on the off chance an addon replaces them
                    return resultsList[key]
                end,
            })
            pChat.LSC_AutoMessageAutoComplete = pChatAutoMsgAutoComplete:New(resultsList, lookupList)
            pChat_LSC_AutoMessageCommand:SetAutoComplete(pChat.LSC_AutoMessageAutoComplete)


        else
            --Dummy to not raise any error
            function pChat.OnpChatAutoMsgAutoCompleteUpdated()

            end

            --[[ !!! Raises an insecure error at chat editbox if e.g. !bear2 is selected!!!

            local pChatAutoMsgAutoComplete = ZO_AutoComplete:Subclass()

            function pChatAutoMsgAutoComplete:New(...)
                return ZO_AutoComplete.New(self, ...)
            end

            function pChatAutoMsgAutoComplete:Initialize(editControl, ...)
                ZO_AutoComplete.Initialize(self, editControl, ...)

                self.possibleMatches = {}

                self:SetUseCallbacks(true)
                self:SetAnchorStyle(AUTO_COMPLETION_ANCHOR_BOTTOM)
                self:SetOwner(pChat.db.automatedMessages)
                self:SetKeepFocusOnCommit(true)

                local function OnAutoCompleteEntrySelected(name, selectionMethod)
                    StartChatInput(name)
                end

                self:RegisterCallback(ZO_AutoComplete.ON_ENTRY_SELECTED, OnAutoCompleteEntrySelected)

                local selfVar = self
                ZO_PreHook("ZO_ChatTextEntry_PreviousCommand", function(...)
                    if not IsShiftKeyDown() and selfVar:IsOpen() then
                        local index = selfVar:GetAutoCompleteIndex()
                        if not index or index > 1 then
                            selfVar:ChangeAutoCompleteIndex(-1)
                            return true
                        end
                    end
                end)

                ZO_PreHook("ZO_ChatTextEntry_NextCommand", function(...)
                    if not IsShiftKeyDown() and selfVar:IsOpen() then
                        local index = selfVar:GetAutoCompleteIndex()
                        if not index or index < selfVar:GetNumAutoCompleteEntries() then
                            selfVar:ChangeAutoCompleteIndex(1)
                            return true --Handled
                        end
                    end
                end)

                local function OnpChatAutoMsgAutoCompleteUpdated()
                    selfVar:InvalidateAutoMesageCommandCache()
                end
                pChat.OnpChatAutoMsgAutoCompleteUpdated = OnpChatAutoMsgAutoCompleteUpdated
            end

            function pChatAutoMsgAutoComplete:InvalidateAutoMesageCommandCache()
                self.possibleMatches = {}
            end

            function pChatAutoMsgAutoComplete:GetAutoCompletionResults(text)
                return pChat_AutomatedMessages_GetAutoCompletionResults(self, text)
            end

            -- The pChat autocomplete object handles completions for things like ! prefixed /msg short texts
            local NO_INCLUDE_FLAGS = nil
            local NO_EXCLUDE_FLAGS = nil
            local DEFAULT_ONLINE_ONLY = nil

            local chatTextEntry = KEYBOARD_CHAT_SYSTEM.textEntry
            chatTextEntry.pChatMsgAutoComplete = pChatAutoMsgAutoComplete:New(chatTextEntry.editControl, NO_INCLUDE_FLAGS, NO_EXCLUDE_FLAGS, DEFAULT_ONLINE_ONLY, MAX_AUTO_COMPLETION_RESULTS, AUTO_COMPLETION_AUTOMATIC_MODE, nil)

            pChat.OnpChatAutoMsgAutoCompleteUpdated()
            ]]
        end
        -- =====================================================================================================================
    end

    -- Called by XML
    function pChat_HoverRowOfAutomatedMessages(control)
        pChatData.autoMessagesShowKeybind = true
        pChatData.automatedMessagesList:Row_OnMouseEnter(control)
    end

    -- Called by XML
    function pChat_ExitRowOfAutomatedMessages(control)
        pChatData.autoMessagesShowKeybind = false
        pChatData.automatedMessagesList:Row_OnMouseExit(control)
    end

    -- Called by XML
    function pChat_BuildAutomatedMessagesDialog(control)

        local function AddDialogSetup(dialog, data)

            local name = GetControl(dialog, "NameEdit")
            local message = GetControl(dialog, "MessageEdit")

            name:SetText("")
            message:SetText("")
            name:SetEditEnabled(true)

        end

        ZO_Dialogs_RegisterCustomDialog("PCHAT_AUTOMSG_SAVE_MSG",
            {
                customControl = control,
                setup = AddDialogSetup,
                title =
                {
                    text = PCHAT_AUTOMSG_ADD_TITLE_HEADER,
                },
                buttons =
                {
                    [1] =
                    {
                        control  = GetControl(control, "Request"),
                        text     = PCHAT_AUTOMSG_ADD_AUTO_MSG,
                        callback = function(dialog)
                            local name = GetControl(dialog, "NameEdit"):GetText()
                            local message = GetControl(dialog, "MessageEdit"):GetText()
                            if(name ~= "") and (message ~= "") then
                                SaveAutomatedMessage(name, message, true)
                            end
                        end,
                    },
                    [2] =
                    {
                        control = GetControl(control, "Cancel"),
                        text = SI_DIALOG_CANCEL,
                    }
                }
            })

        local function EditDialogSetup(dialog)
            local data = ZO_ScrollList_GetData(moc()) --WM:GetMouseOverControl()
            local name = GetControl(dialog, "NameEdit")
            local edit = GetControl(dialog, "MessageEdit")


            name:SetText(data.name)
            name:SetEditEnabled(false)
            edit:SetText(data.message)
            edit:TakeFocus()

        end

        ZO_Dialogs_RegisterCustomDialog("PCHAT_AUTOMSG_EDIT_MSG",
            {
                customControl = control,
                setup = EditDialogSetup,
                title =
                {
                    text = PCHAT_AUTOMSG_EDIT_TITLE_HEADER,
                },
                buttons =
                {
                    [1] =
                    {
                        control  = GetControl(control, "Request"),
                        text     = PCHAT_AUTOMSG_EDIT_AUTO_MSG,
                        callback = function(dialog)
                            local name = GetControl(dialog, "NameEdit"):GetText()
                            local message = GetControl(dialog, "MessageEdit"):GetText()
                            if(name ~= "") and (message ~= "") then
                                SaveAutomatedMessage(name, message, false)
                            end
                        end,
                    },
                    [2] =
                    {
                        control = GetControl(control, "Cancel"),
                        text = SI_DIALOG_CANCEL,
                    }
                }
            })

    end

    InitAutomatedMessages()

    ZO_PreHook(SharedChatSystem, "SubmitTextEntry", function(self)
        local text = self.textEntry:GetText()
        if text ~= "" and text:sub(1, 1) == "!" and text:len() <= 12 then
            for k, v in ipairs(db.automatedMessages) do
                if v.name == text then
                    local message = db.automatedMessages[k].message
                    if message ~= "" or message:len() > 351 then
                        self.textEntry:SetText(message)
                        return
                    end
                end
            end
        end
    end)
end
