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
--d("[pChat]ChatSys:ValidateChatChannel - tabIndex: " ..tostring(tabIndex) .. ", channel: " .. tostring(self.currentChannel))

                    --#27 Fix chat channel saved per tab to switch to group if not in a group
                    if self.currentChannel == CHAT_CHANNEL_PARTY then
                        if not IsUnitGrouped("player") then
--d("<not grouped, aborting!")
                            return
                        end
                    end

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
---d("[pChat]ChatSys.primaryContainer:HandleTabClick - tabIndex: " ..tostring(tabIndex) .. ", channel: " .. tostring(db.chatTabChannel[tabIndex].channel))
                    local savedTabChannelData = db.chatTabChannel[tabIndex]
                    if savedTabChannelData then
                        --#27 Fix chat channel saved per tab to switch to group if not in a group
                        if savedTabChannelData.channel == CHAT_CHANNEL_PARTY then
                            if not IsUnitGrouped("player") then
    --d("<not grouped, aborting!")
                                return
                            end
                        end

                        ChatSys:SetChannel(savedTabChannelData.channel, savedTabChannelData.target)
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


------------------------------------------------------------------------------------------------------------------------
    --Enable the CHAT_CHANNEL_SYSTEM entry in chat tab properties
    local FILTERS_PER_ROW = 2
    local GUILDS_PER_ROW = 2

    --defines channels to be combined under one button
    local COMBINED_CHANNELS =
    {
        [CHAT_CATEGORY_WHISPER_INCOMING] = {parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, name = SI_CHAT_CHANNEL_NAME_WHISPER},
        [CHAT_CATEGORY_WHISPER_OUTGOING] = {parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, name = SI_CHAT_CHANNEL_NAME_WHISPER},

        [CHAT_CATEGORY_MONSTER_SAY] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
        [CHAT_CATEGORY_MONSTER_YELL] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
        [CHAT_CATEGORY_MONSTER_WHISPER] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
        [CHAT_CATEGORY_MONSTER_EMOTE] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
    }
    local SKIP_CHANNELS =
    {
        [CHAT_CATEGORY_SYSTEM] = nil, --do not skip anymore! Show in the chat tab settings
        [CHAT_CATEGORY_GUILD_1] = true,
        [CHAT_CATEGORY_GUILD_2] = true,
        [CHAT_CATEGORY_GUILD_3] = true,
        [CHAT_CATEGORY_GUILD_4] = true,
        [CHAT_CATEGORY_GUILD_5] = true,
        [CHAT_CATEGORY_OFFICER_1] = true,
        [CHAT_CATEGORY_OFFICER_2] = true,
        [CHAT_CATEGORY_OFFICER_3] = true,
        [CHAT_CATEGORY_OFFICER_4] = true,
        [CHAT_CATEGORY_OFFICER_5] = true,
    }
    -- defines the ordering of the filter categories
    local CHANNEL_ORDERING_WEIGHT =
    {
        [CHAT_CATEGORY_SAY] = 10,
        [CHAT_CATEGORY_YELL] = 20,

        [CHAT_CATEGORY_WHISPER_INCOMING] = 30,
        [CHAT_CATEGORY_PARTY] = 40,

        [CHAT_CATEGORY_EMOTE] = 50,
        [CHAT_CATEGORY_MONSTER_SAY] = 60,

        [CHAT_CATEGORY_ZONE] = 80,

        [CHAT_CATEGORY_ZONE_ENGLISH] = 90,
        [CHAT_CATEGORY_ZONE_FRENCH] = 100,
        [CHAT_CATEGORY_ZONE_GERMAN] = 110,
        [CHAT_CATEGORY_ZONE_JAPANESE] = 120,
        [CHAT_CATEGORY_ZONE_RUSSIAN] = 130,
        [CHAT_CATEGORY_ZONE_SPANISH] = 140,
        [CHAT_CATEGORY_ZONE_CHINESE_S] = 150,
    }
    internalassert(OFFICIAL_LANGUAGE_MAX_VALUE == 6)

    local function FilterComparator(left, right)
        local leftPrimaryCategory = left.channels[1]
        local rightPrimaryCategory = right.channels[1]

        local leftWeight = CHANNEL_ORDERING_WEIGHT[leftPrimaryCategory]
        local rightWeight = CHANNEL_ORDERING_WEIGHT[rightPrimaryCategory]

        if leftWeight and rightWeight then
            return leftWeight < rightWeight
        elseif leftWeight then
            return true
        end

        return false
    end

    do
        local FILTER_PAD_X = 90
        local FILTER_PAD_Y = 0
        local FILTER_WIDTH = 150
        local FILTER_HEIGHT = 27
        local INITIAL_XOFFS = 0
        local INITIAL_YOFFS = 0

        function CHAT_OPTIONS.BuildFilterButtons(chatOptionsObject, dialogControl)
            --d("[pChat]ChatOptions - BuildFilterButtons")
            local self = chatOptionsObject

            --generate a table of entry data from the chat category header information
            local entryData = {}
            local lastEntry = CHAT_CATEGORY_HEADER_COMBAT - 1

            for i = CHAT_CATEGORY_HEADER_CHANNELS, lastEntry do
                if not IsChannelCategoryCommunicationRestricted(i) then
                    if SKIP_CHANNELS[i] == nil and GetString("SI_CHATCHANNELCATEGORIES", i) ~= "" then
                        if COMBINED_CHANNELS[i] == nil then
                            entryData[i] =
                            {
                                channels = { i },
                                name = GetString("SI_CHATCHANNELCATEGORIES", i),
                            }
                        else
                            --create the entry for those with combined channels just once
                            local parentChannel = COMBINED_CHANNELS[i].parentChannel

                            if not entryData[parentChannel] then
                                entryData[parentChannel] =
                                {
                                    channels = {},
                                    name = GetString(COMBINED_CHANNELS[i].name),
                                }
                            end

                            table.insert(entryData[parentChannel].channels, i)
                        end
                    --else
                        --d("<SKIP_CHANNELS: " ..tostring(SKIP_CHANNELS[i]) .. ", GetStringCategory: " ..tostring(GetString("SI_CHATCHANNELCATEGORIES", i)))
                    end

                --else
                    --d("<IsChannelCategoryCommunicationRestricted: YES, category: " ..tostring(i))
                end
            end

            --now generate and anchor buttons
            local filterAnchor = ZO_Anchor:New(TOPLEFT, self.filterSection, TOPLEFT, 0, 0)
            local count = 0

            local sortedEntries = {}
            for _, entry in pairs(entryData) do
                sortedEntries[#sortedEntries + 1] = entry
            end

            table.sort(sortedEntries, FilterComparator)

            for _, entry in ipairs(sortedEntries) do
                local filter = self.filterPool:AcquireObject()

                local button = filter:GetNamedChild("Check")
                ZO_CheckButton_SetLabelText(button, entry.name)
                button.channels = entry.channels
                table.insert(self.filterButtons, button)

                ZO_Anchor_BoxLayout(filterAnchor, filter, count, FILTERS_PER_ROW, FILTER_PAD_X, FILTER_PAD_Y, FILTER_WIDTH, FILTER_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
                count = count + 1
            end
        end

        local function OnInterfaceSettingChanged()
            --d("[pChat]ChatOptions - OnInterfaceSettingChanged")
                CHAT_OPTIONS.filterPool:ReleaseAllObjects()
                CHAT_OPTIONS:BuildFilterButtons(CHAT_OPTIONS.control)
        end
        OnInterfaceSettingChanged() --Call once to rebuild the chat tab categories and buttons etc.
    end
end

function pChat.NewChatTabButtonHook()
    --self = ChatContainer = SharedChatContainer -> ChatSys.primaryContainer
    --self.newWindowTab:SetHandler("OnMouseUp", function(tab, button, isUpInside) if isUpInside and not ZO_TabButton_IsDisabled(self.newWindowTab) then  self.system:CreateNewChatTab(self) end ZO_TabButton_Unselect(tab) end)
    if not ChatSys or not ChatSys.primaryContainer then return end
    local primaryContainer = ChatSys.primaryContainer
    local newWindowTab = primaryContainer.newWindowTab
    if newWindowTab ~= nil then
        ZO_PreHookHandler(newWindowTab, "OnMouseUp",
            function(tab, button, isUpInside)
                ZO_Tooltips_HideTextTooltip()
                if isUpInside and not ZO_TabButton_IsDisabled(newWindowTab) then
                    if not pChat.db.modifierKeyForNewChatTab then return false end
                    if not IsShiftKeyDown() then return true end --prevent the exectuion of original function OnMouseUp if shift key is not pressed and setting that says to do so is ON
                end
                return false
        end)
        local function showNewChatTabTooltip(ctrl)
            if not pChat.db.modifierKeyForNewChatTab then return false end
            ZO_Tooltips_ShowTextTooltip(ctrl, TOP, GetString(PCHAT_modifierKeyForNewChatTabButtonTT))
        end
        local function hideNewChatTabTooltip()
            ZO_Tooltips_HideTextTooltip()
        end

        if newWindowTab:GetHandler("OnMouseEnter") ~= nil then
            ZO_PreHookHandler(newWindowTab, "OnMouseEnter", function()
                showNewChatTabTooltip(newWindowTab)
            end)
        else
            newWindowTab:SetHandler("OnMouseEnter", function()
                showNewChatTabTooltip(newWindowTab)
            end)
        end
        if newWindowTab:GetHandler("OnMouseExit") ~= nil then
            ZO_PreHookHandler(newWindowTab, "OnMouseExit", function()
                hideNewChatTabTooltip()
            end)
        else
            newWindowTab:SetHandler("OnMouseExit", function()
                hideNewChatTabTooltip()
            end)
        end
    end
end