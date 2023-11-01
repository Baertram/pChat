local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

local ChatSys = CONSTANTS.CHAT_SYSTEM

function pChat.InitializeChatTabs()
    pChat.tabNames = {}
    pChat.tabIndices = {}

    local function getTabNames()
        ChatSys = CONSTANTS.CHAT_SYSTEM
        local totalTabs = ChatSys.tabPool.m_Active
        if totalTabs ~= nil and #totalTabs >= 1 then
            pChat.tabNames = {}
            pChat.tabIndices = {}
            for idx, tmpTab in pairs(totalTabs) do
                local tabLabel = tmpTab:GetNamedChild("Text")
                if tabLabel ~= nil then
                    local tmpTabName = tabLabel:GetText()
                    if tmpTabName ~= nil and tmpTabName ~= "" then
                        pChat.tabIndices[idx] = idx
                        pChat.tabNames[idx] = tmpTabName
                    end
                end
            end
        end
    end
    pChat.getTabNames = getTabNames

    --TODO: Not needed anymore. Remove?
    local function getTabIndexByName(tabName)
        pChat.tabNames = pChat.tabNames or {}
        if #pChat.tabNames == 0 then
            getTabNames()
        end
        local chatTabNames = pChat.tabNames
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

        if ChatSys.ValidateChatChannel then
            ZO_PreHook(ChatSys, "ValidateChatChannel", function(self)
                if (db.enableChatTabChannel  == true) and (self.currentChannel ~= CHAT_CHANNEL_WHISPER) then
                    local tabIndex = self.primaryContainer.currentBuffer:GetParent().tab.index
                    db.chatTabChannel[tabIndex] = db.chatTabChannel[tabIndex] or {}
                    db.chatTabChannel[tabIndex].channel = self.currentChannel
                    db.chatTabChannel[tabIndex].target  = self.currentTarget
                end
            end)
        end

        if ChatSys.primaryContainer.HandleTabClick then
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
        end

        -- Will set Keybind for "switch to next tab" if needed
        SetSwitchToNextBinding()

        -- Show 1000 lines instead of 200 & Change fade delay
        SecurePostHook(ChatSys, "CreateNewChatTab", function()
            CreateNewChatTabPostHook()
        end)
        CreateNewChatTabPostHook()

        -- Get Chat Tab Names stored in chatTabNames {}
        getTabNames()
    end
end
