local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

function pChat.InitializeChatTabs()
    pChat.tabNames = {}
    pChat.tabIndices = {}

    local function getTabNames()
        local totalTabs = CHAT_SYSTEM.tabPool.m_Active
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
        local totalTabs = CHAT_SYSTEM.tabPool.m_Active
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

    local function CreateNewChatTabPostHook()
        if not CHAT_SYSTEM or not CHAT_SYSTEM.primaryContainer or not CHAT_SYSTEM.primaryContainer.windows then return end
        local db = pChat.db
        --For each chat tab do
        for tabIndex, tabObject in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
            --Set the maximum lines in the chat tab to 1000 instead of 200
            if db.augmentHistoryBuffer then
                tabObject.buffer:SetMaxHistoryLines(1000) -- 1000 = max of control
            end
            --If the chat fade out is disabled: Set the fade timeout to 3600 milliseconds
            if db.alwaysShowChat then
                --New values for fadeOut taken from file:
                --https://github.com/esoui/esoui/blob/360dee5f494a444c2418a4e20fab8237e29f641b/esoui/ingame/chatsystem/console/gamepadchatsystem.lua
                local NEVER_FADE = 0
                --container.windows[tabIndex].buffer:SetLineFade(NEVER_FADE, NEVER_FADE)
                tabObject.buffer:SetLineFade(NEVER_FADE, NEVER_FADE) --old values: 3600, 2
            end
        end

    end

    -- need to call this separately due to the load and init order
    function pChat.SetupChatTabs()
        local db = pChat.db
        local pChatData = pChat.pChatData
        pChatData.activeTab = 1

        if CHAT_SYSTEM.ValidateChatChannel then
            ZO_PreHook(CHAT_SYSTEM, "ValidateChatChannel", function(self)
                if (db.enableChatTabChannel  == true) and (self.currentChannel ~= CHAT_CHANNEL_WHISPER) then
                    local tabIndex = self.primaryContainer.currentBuffer:GetParent().tab.index
                    db.chatTabChannel[tabIndex] = db.chatTabChannel[tabIndex] or {}
                    db.chatTabChannel[tabIndex].channel = self.currentChannel
                    db.chatTabChannel[tabIndex].target  = self.currentTarget
                end
            end)
        end

        if CHAT_SYSTEM.primaryContainer.HandleTabClick then
            ZO_PreHook(CHAT_SYSTEM.primaryContainer, "HandleTabClick", function(self, tab)
                pChatData.activeTab = tab.index
                if (db.enableChatTabChannel == true) then
                    local tabIndex = tab.index
                    if db.chatTabChannel[tabIndex] then
                        CHAT_SYSTEM:SetChannel(db.chatTabChannel[tabIndex].channel, db.chatTabChannel[tabIndex].target)
                    end
                end
                --ZO_TabButton_Text_RestoreDefaultColors(tab)
            end)
        end

        -- Will set Keybind for "switch to next tab" if needed
        SetSwitchToNextBinding()

        -- Show 1000 lines instead of 200 & Change fade delay
        SecurePostHook(CHAT_SYSTEM, "CreateNewChatTab", function()
            CreateNewChatTabPostHook()
        end)
        CreateNewChatTabPostHook()

        -- Get Chat Tab Names stored in chatTabNames {}
        getTabNames()
    end
end
