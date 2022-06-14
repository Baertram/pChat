--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn Constants
--======================================================================================================================
local CONSTANTS     = pChat.CONSTANTS
local ADDON_NAME    = CONSTANTS.ADDON_NAME

local ChatSys = CONSTANTS.CHAT_SYSTEM

--======================================================================================================================
-- Keybindings
--======================================================================================================================
    --[Variables]---

    -- Whisper target below reticle
    local targetToWhisp

    --[Functions]--

    --Load the keybind Strings from translation files
    local function LoadKeybindStrings()
        --Keybind strings
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG", GetString(PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_SWITCH_TAB", GetString(PCHAT_SWITCHTONEXTTABBINDING))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TOGGLE_CHAT_WINDOW", GetString(PCHAT_TOGGLECHATBINDING))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_COPY_WHOLE_CHAT", GetString(PCHAT_COPYWHOLECHATBINDING))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_WHISPER_MY_TARGET", GetString(PCHAT_WHISPMYTARGETBINDING))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_1", GetString(PCHAT_Tab1))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_2", GetString(PCHAT_Tab2))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_3", GetString(PCHAT_Tab3))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_4", GetString(PCHAT_Tab4))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_5", GetString(PCHAT_Tab5))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_6", GetString(PCHAT_Tab6))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_7", GetString(PCHAT_Tab7))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_8", GetString(PCHAT_Tab8))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_9", GetString(PCHAT_Tab9))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_10", GetString(PCHAT_Tab10))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_11", GetString(PCHAT_Tab11))
        ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TAB_12", GetString(PCHAT_Tab12))
    end
    pChat.LoadKeybindStrings = LoadKeybindStrings

    --Event callback function of EVENT_RETICLE_TARGET_CHANGED
    local function OnReticleTargetChanged()
        if IsUnitPlayer("reticleover") then
            targetToWhisp = GetUnitName("reticleover")
        end
    end
    pChat.OnReticleTargetChanged = OnReticleTargetChanged



    --[GLOBAL functions of ESOUI keybinds]--
    -- Needed to bind Shift+Tab in SetSwitchToNextBinding, called in EVENT_PLAYER_ACTIVATED -> pChat.SetupChatTabs
    --[[
    function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
        return true
    end
    ]]
    KEYBINDING_MANAGER:SetChordingAlwaysEnabled(true)


    ---------------------------------
    -- Whisper --
    ---------------------------------

    --[GLOBAL functions for pChat keybinds]--
    -- Called by bindings
    function pChat_WhispMyTarget()
        if targetToWhisp then
            ChatSys:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, targetToWhisp)
        end
    end
    pChat.WhispMyTarget = pChat_WhispMyTarget


    ---------------------------------
    -- Chat window --
    ---------------------------------

    --Toggle the chat window
    function pChat_ToggleChat()
        if not ChatSys then return end
        if ChatSys:IsMinimized() then
            ChatSys:Maximize()
        else
            ChatSys:Minimize()
            pChat.pChatData.wasManuallyMinimized = true
        end
    end
    pChat.ToggleChat = pChat_ToggleChat

    ---------------------------------
    --Chat tabs--
    ---------------------------------

    -- Can be called by Bindings
    function pChat_SwitchToNextTab()
        local logger = pChat.logger
        logger:Debug("pChat_SwitchToNextTab")
        local pChatData = pChat.pChatData

        local hasSwitched

        local PRESSED = 1
        local UNPRESSED = 2
        local numTabs = #ChatSys.primaryContainer.windows
        local activeTab = pChatData.activeTab

        if numTabs > 1 then
            for numTab, container in ipairs (ChatSys.primaryContainer.windows) do

                if (not hasSwitched) then
                    if activeTab + 1 == numTab then
                        ChatSys.primaryContainer:HandleTabClick(container.tab)

                        local tabText = pChat.GetTabTextControl(numTab)
                        tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                        tabText:GetParent().state = PRESSED
                        local oldTabText = pChat.GetTabTextControl(activeTab)
                        oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                        oldTabText:GetParent().state = UNPRESSED

                        hasSwitched = true
                    end
                end

            end

            if (not hasSwitched) then
                ChatSys.primaryContainer:HandleTabClick(ChatSys.primaryContainer.windows[1].tab)
                local tabText = pChat.GetTabTextControl(1)
                tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                tabText:GetParent().state = PRESSED
                local oldTabText = pChat.GetTabTextControl(#ChatSys.primaryContainer.windows)
                oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                oldTabText:GetParent().state = UNPRESSED
            end
        end

    end
    pChat.SwitchToNextTab = pChat_SwitchToNextTab

    function pChat_ChangeTab(tabToSet)
        local logger = pChat.logger
        logger:Debug("pChat_ChangeTab", "To tab: " ..tostring(tabToSet))
        if type(tabToSet)~="number" then return end
        local container=ChatSys.primaryContainer if not container then return end
        if tabToSet<1 or tabToSet>#container.windows then return end
        if container.windows[tabToSet].tab==nil then return end
        container.tabGroup:SetClickedButton(container.windows[tabToSet].tab)
        if ChatSys:IsMinimized() then
            ChatSys:Maximize()
        end
        --TODO: Why is this source below needed? Container was defined and checked already above,
        --TODO: and setting tabToSet without returning/using the value makes no sense?
        --[[
        container=ChatSys.primaryContainer
        if not container then return end
        tabToSet=container.currentBuffer:GetParent().tab.tabToSet
        ]]
    end
    pChat.ChangeTab = pChat_ChangeTab


    ---------------------------------
    --Automated messages--
    ---------------------------------

    -- Also called by bindings
    function pChat_ShowAutoMsg()
        if LibMainMenu2 and pChat and pChat.MENU_CATEGORY_PCHAT then
            LibMainMenu2:ToggleCategory(pChat.MENU_CATEGORY_PCHAT)
        end
    end
    pChat.ShowAutoMsg = pChat_ShowAutoMsg