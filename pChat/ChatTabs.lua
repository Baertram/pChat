local CONSTANTS = pChat.CONSTANTS
--local ADDON_NAME = CONSTANTS.ADDON_NAME

local ChatSys = CONSTANTS.CHAT_SYSTEM

local constChatTabNoName = CONSTANTS.chatTabNoName

local validateChatChannelHooked = false
local handleTabClickHooked = false
local createNewChatTabHooked = false

--Check if any tabName or index is missing (gaps) or is empty in total, and reset the chat tabs then
--or insert a "- n/a - " as tabName + the correct index then
local function checkAndReOrderMissingChatTabs()
--d("[pChat]checkAndReOrderMissingChatTabs")
    local tabNames = pChat.tabNames
    local tabIndices = pChat.tabIndices

    if ZO_IsTableEmpty(tabNames) then
        pChat.tabNames = {}
        pChat.tabIndices = {}
--d("<1")
        return
    end
    if ZO_IsTableEmpty(tabIndices) then
        pChat.tabNames = {}
        pChat.tabIndices = {}
--d"<2")
        return
    end

    local countTabNames = NonContiguousCount(tabNames)
    local countTabIndices = NonContiguousCount(tabIndices)
--d(">countNames: " ..tostring(countTabNames) .. ", countIndices: " ..tostring(countTabIndices))
    if countTabNames ~= countTabIndices then
        if countTabIndices > countTabNames then
            for idx, indexIdx in pairs(tabIndices) do
                if indexIdx == "" or indexIdx ~= idx then
--d(">1-indexIdx not equal idx: " .. tostring(idx))
                    pChat.tabIndices[idx] = idx
                end

                local tabName = tabNames[idx]
                if tabName == nil or tabName == "" then
--d(">1-tabName nil or empty: " .. tostring(idx))
                    pChat.tabNames[idx] = constChatTabNoName
                end
            end
        else
            for idx, tabName in pairs(tabNames) do
                if tabName == "" then
--d(">2-tabName nil or empty: " .. tostring(idx))
                    pChat.tabNames[idx] = constChatTabNoName
                end

                local indexEntry = tabIndices[idx]
                if indexEntry == nil then
--d(">2-index nil: " .. tostring(idx))
                    pChat.tabIndices[idx] = idx
                end
            end
        end
    else
        for idx, tabName in pairs(tabNames) do
            if tabName == "" then
--d(">3-tabName nil or empty: " .. tostring(idx))
                pChat.tabNames[idx] = constChatTabNoName
            end

            local indexEntry = tabIndices[idx]
            if indexEntry == nil then
--d(">3-index nil: " .. tostring(idx))
                pChat.tabIndices[idx] = idx
            end
        end
    end
end

function pChat.InitializeChatTabs()
    local function getTabNames()
--d("[pChat]getTabNames")
        pChat.tabNames = {}
        pChat.tabIndices = {}

        ChatSys = CONSTANTS.CHAT_SYSTEM
        local totalTabs = ChatSys.tabPool.m_Active
        if totalTabs ~= nil and #totalTabs >= 1 then
            for idx, tmpTab in ipairs(totalTabs) do
                local tabLabel = tmpTab:GetNamedChild("Text")
                if tabLabel ~= nil then
                    local tmpTabName = tabLabel:GetText()
--d(">idx: " .. tostring(idx) ..", tmpTabName: " ..tostring(tmpTabName))
                    if tmpTabName ~= nil then
                        if tmpTabName == "" then
                            tmpTabName = constChatTabNoName
                        end
                        pChat.tabIndices[idx] = idx
                        pChat.tabNames[idx] = tmpTabName
                    else
                        tmpTabName = constChatTabNoName
                        pChat.tabIndices[idx] = idx
                        pChat.tabNames[idx] = tmpTabName
                    end
                --else
--d("<tabLabel = nil!")
                end
            end
        --else
--d("<totalTabs = nil!")
        end
        checkAndReOrderMissingChatTabs()
    end
    pChat.getTabNames = getTabNames

    local function getTabIndexByName(tabName)
        if ZO_IsTableEmpty(pChat.tabNames) then
            getTabNames()
        end
        local chatTabNames = pChat.tabNames
        if ZO_IsTableEmpty(chatTabNames) then return 1 end
        local totalTabs = ChatSys.tabPool.m_Active
        for i = 1, #totalTabs do
            if chatTabNames[i] == tabName then
                return i
            end
        end
        --Fallback: Return chat tab 1
        return 1
    end
    pChat.getTabIndexByName = getTabIndexByName


    --[[
    --Do not preset SHIFt+TAB as default "Next tab" keybind
    local function SetSwitchToNextBinding()
        -- get SwitchTab Keybind params
        local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName("PCHAT_SWITCH_TAB")
        --If exists
        if layerIndex and categoryIndex and actionIndex then
            local key = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, 1)
            if key == KEY_INVALID then
                -- Unbind it
                if IsProtectedFunction("UnbindAllKeysFromAction") then
                    CallSecureProtected("UnbindAllKeysFromAction", layerIndex, categoryIndex, actionIndex)
                else
                    UnbindAllKeysFromAction(layerIndex, categoryIndex, actionIndex)
                end

                -- Set it to its default value
                if IsProtectedFunction("BindKeyToAction") then
                    CallSecureProtected("BindKeyToAction", layerIndex, categoryIndex, actionIndex, 1, KEY_TAB, 0, 0, KEY_SHIFT, 0)
                else
                    BindKeyToAction(layerIndex, categoryIndex, actionIndex, 1, KEY_TAB , 0, 0, KEY_SHIFT, 0)
                end
            end
        end
    end
    ]]

    local alreadyHookedFadeOutContainers = {}
    local function CreateNewChatTabPostHook()
--d("[pChat]CreateNewChatTabPostHook")
        if not ChatSys or not ChatSys.primaryContainer or not ChatSys.primaryContainer.windows then return end
        local db = pChat.db
        --[[
        for i,container in pairs(self.containers) do
            container:FadeIn()

            for tabIndex = 1, #container.windows do
                container.windows[tabIndex].buffer:ShowFadedLines()

                local NEVER_FADE = 0
                container.windows[tabIndex].buffer:SetLineFade(NEVER_FADE, NEVER_FADE)
            end
        end
        ]]

        local NEVER_FADE = 0
        --old values: 3, 2 as of API 101032 2022-01-30:
        local FADE_BEGIN = db.chatTextFadeBegin
        local FADE_DURATION = db.chatTextFadeDuration

        local neverFadeOut = ( db.alwaysShowChat == true and true) or false
        local fadeBegin = ( neverFadeOut == true and NEVER_FADE ) or FADE_BEGIN
        local fadeDuration = ( neverFadeOut == true and NEVER_FADE ) or FADE_DURATION

        --For each chat container, and then for each chat tab in that container, do
        for _, container in pairs(ChatSys.containers) do
            container:FadeIn()

            --Hook the FadeOut function and prevent FadeOut -> If disabled in the settings
            --Disabled as the chat background is somehow disturbed by it
            if neverFadeOut == true and container.FadeOut ~= nil and not alreadyHookedFadeOutContainers[container] then
                --See \esoui\ingame\chatsystem\sharedchatsystem.lua, SharedChatContainer:FadeOut(delay)
                SecurePostHook(container, "FadeOut", function(self, delay)
--d("[pChat]Chat container FadeOut SecurePostHook-delay: " ..tostring(delay))
                    --Always fade in the chat text again?
                    if pChat.db.alwaysShowChat == true then
                        --pChat code addition: Should pChat prevent the FadeOut: Show text lines again
                        if self.currentBuffer then
                            self.currentBuffer:ShowFadedLines()
                        end
                    end --Call original function code!
                end)
                alreadyHookedFadeOutContainers[container] = true
            end

            for _, tabObject in ipairs(container.windows) do
                --Set the maximum lines in the chat tab to 1000 instead of 200
                if db.augmentHistoryBuffer then
                    tabObject.buffer:SetMaxHistoryLines(1000) -- 1000 = max of control
                end
                --If the chat fade out is disabled: Set the fade timeout to 3600 milliseconds
                --New values for fadeOut taken from file:
                --https://github.com/esoui/esoui/blob/master/esoui/ingame/chatsystem/gamepad/gamepadchatsystem.lua
                local bufferOfTab = tabObject.buffer
                if bufferOfTab ~= nil then
                    if neverFadeOut == true then
--d(">ShowFadedLines")
                        bufferOfTab:ShowFadedLines()
                    end
                    --Maybe only working in Gamepad mode?
                    --self.windows[tabIndex].buffer:SetLineFade(FADE_BEGIN, FADE_DURATION)
                    bufferOfTab:SetLineFade(fadeBegin, fadeDuration)
                end
            end
        end
    end
    pChat.CreateNewChatTabPostHook = CreateNewChatTabPostHook


    -- need to call this separately due to the load and init order
    function pChat.SetupChatTabs()
        local db = pChat.db
        local pChatData = pChat.pChatData
        pChatData.activeTab = 1

        if ChatSys.ValidateChatChannel and not validateChatChannelHooked then
            ZO_PreHook(ChatSys, "ValidateChatChannel", function(self)
                if (db.enableChatTabChannel  == true) and (self.currentChannel ~= CHAT_CHANNEL_WHISPER) then
                    local tabIndex = self.primaryContainer.currentBuffer:GetParent().tab.index
                    db.chatTabChannel[tabIndex] = db.chatTabChannel[tabIndex] or {}
                    db.chatTabChannel[tabIndex].channel = self.currentChannel
                    db.chatTabChannel[tabIndex].target  = self.currentTarget
                end
            end)
            validateChatChannelHooked = true
        end

        if ChatSys.primaryContainer.HandleTabClick and not handleTabClickHooked then
            ZO_PreHook(ChatSys.primaryContainer, "HandleTabClick", function(self, tab)
                pChatData.activeTab = tab.index
                --20221106 Check for open whisper notifications shown and if switched to whisper tab, close them if the
                --current tab's whisper chat channel is enabled
                --Check if the whisper notifications visual is enabled
                if db.notifyIM == true then
                    local isWhisperEnabled = IsChatContainerTabCategoryEnabled(tab.container.id, tab.index, CHAT_CATEGORY_WHISPER_INCOMING)
                    --Current tab got incoming whisper chat channel/category enabled
                    if isWhisperEnabled == true then
                        --Is the visual whisper control still shown? Close it
                        pChat_RemoveIMNotification()
                    end
                end

                if (db.enableChatTabChannel == true) then
                    local tabIndex = tab.index
                    if db.chatTabChannel[tabIndex] then
                        ChatSys:SetChannel(db.chatTabChannel[tabIndex].channel, db.chatTabChannel[tabIndex].target)
                    end
                end
                --ZO_TabButton_Text_RestoreDefaultColors(tab)
            end)
            handleTabClickHooked = true
        end

        -- Will set Keybind for "switch to next tab" if needed
        --SetSwitchToNextBinding()

        -- Show 1000 lines instead of 200 & Change fade delay
        if not createNewChatTabHooked then
            SecurePostHook(ChatSys, "CreateNewChatTab", function()
                CreateNewChatTabPostHook()
            end)
            createNewChatTabHooked = true
        end
        CreateNewChatTabPostHook()

        -- Get Chat Tab Names stored in chatTabNames {}
        getTabNames()
    end
end
