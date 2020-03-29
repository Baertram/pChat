function pChat.InitializeChatTabs(pChatData, constTabNameTemplate)

    pChat.tabNames = {}

    local function getTabNames()
        local totalTabs = CHAT_SYSTEM.tabPool.m_Active
        if totalTabs ~= nil and #totalTabs >= 1 then
            pChat.tabNames = {}
            for idx, tmpTab in pairs(totalTabs) do
                local tabLabel = tmpTab:GetNamedChild("Text")
                local tmpTabName = tabLabel:GetText()
                if tmpTabName ~= nil and tmpTabName ~= "" then
                    pChat.tabNames[idx] = tmpTabName
                end
            end
        end
    end
    pChat.getTabNames = getTabNames

    local function getTabIdx (tabName)
        local tabIdx = 0
        local totalTabs = CHAT_SYSTEM.tabPool.m_Active
        for i = 1, #totalTabs do
            if pChat.tabNames[i] == tabName then
                tabIdx = i
            end
        end
        return tabIdx
    end
    pChat.getTabIdx = getTabIdx

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

    -- Can be called by Bindings
    function pChat_SwitchToNextTab()

        local hasSwitched

        local PRESSED = 1
        local UNPRESSED = 2
        local numTabs = #CHAT_SYSTEM.primaryContainer.windows
        local activeTab = pChatData.activeTab

        if numTabs > 1 then
            for numTab, container in ipairs (CHAT_SYSTEM.primaryContainer.windows) do

                if (not hasSwitched) then
                    if activeTab + 1 == numTab then
                        CHAT_SYSTEM.primaryContainer:HandleTabClick(container.tab)

                        local tabText = GetControl(constTabNameTemplate .. numTab .. "Text")
                        tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                        tabText:GetParent().state = PRESSED
                        local oldTabText = GetControl(constTabNameTemplate .. activeTab .. "Text")
                        oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                        oldTabText:GetParent().state = UNPRESSED

                        hasSwitched = true
                    end
                end

            end

            if (not hasSwitched) then
                CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[1].tab)
                local tabText = GetControl(constTabNameTemplate .. "1Text")
                tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                tabText:GetParent().state = PRESSED
                local oldTabText = GetControl(constTabNameTemplate .. tostring(#CHAT_SYSTEM.primaryContainer.windows) .. "Text")
                oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                oldTabText:GetParent().state = UNPRESSED
            end
        end

    end

    function pChat_ChangeTab(tabToSet)
        if type(tabToSet)~="number" then return end
        local container=CHAT_SYSTEM.primaryContainer if not container then return end
        if tabToSet<1 or tabToSet>#container.windows then return end
        if container.windows[tabToSet].tab==nil then return end
        container.tabGroup:SetClickedButton(container.windows[tabToSet].tab)
        if CHAT_SYSTEM:IsMinimized() then CHAT_SYSTEM:Maximize() end
        local container=CHAT_SYSTEM.primaryContainer
        if not container then return end
        local tabToSet=container.currentBuffer:GetParent().tab.tabToSet

    end

    local function CreateNewChatTabPostHook(db)
        if not CHAT_SYSTEM or not CHAT_SYSTEM.primaryContainer or not CHAT_SYSTEM.primaryContainer.windows then return end
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
    function pChat.SetupChatTabs(db)
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

        -- Needed to bind Shift+Tab in SetSwitchToNextBinding
        function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
            return true
        end

        -- Will set Keybind for "switch to next tab" if needed
        SetSwitchToNextBinding()

        -- Show 1000 lines instead of 200 & Change fade delay
        SecurePostHook(CHAT_SYSTEM, "CreateNewChatTab", function()
            CreateNewChatTabPostHook(db)
        end)
        CreateNewChatTabPostHook(db)

        -- Get Chat Tab Names stored in chatTabNames {}
        getTabNames()
    end
end
