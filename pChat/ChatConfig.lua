local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

function pChat.InitializeChatConfig()
    local pChatData = pChat.pChatData
    local db = pChat.db

    pChatData.chatCategories = {
        CHAT_CATEGORY_SAY,
        CHAT_CATEGORY_YELL,
        CHAT_CATEGORY_WHISPER_INCOMING,
        CHAT_CATEGORY_WHISPER_OUTGOING,
        CHAT_CATEGORY_ZONE,
        CHAT_CATEGORY_PARTY,
        CHAT_CATEGORY_EMOTE,
        CHAT_CATEGORY_SYSTEM,
        CHAT_CATEGORY_GUILD_1,
        CHAT_CATEGORY_GUILD_2,
        CHAT_CATEGORY_GUILD_3,
        CHAT_CATEGORY_GUILD_4,
        CHAT_CATEGORY_GUILD_5,
        CHAT_CATEGORY_OFFICER_1,
        CHAT_CATEGORY_OFFICER_2,
        CHAT_CATEGORY_OFFICER_3,
        CHAT_CATEGORY_OFFICER_4,
        CHAT_CATEGORY_OFFICER_5,
        CHAT_CATEGORY_ZONE_ENGLISH,
        CHAT_CATEGORY_ZONE_FRENCH,
        CHAT_CATEGORY_ZONE_GERMAN,
        CHAT_CATEGORY_ZONE_JAPANESE,
        CHAT_CATEGORY_MONSTER_SAY,
        CHAT_CATEGORY_MONSTER_YELL,
        CHAT_CATEGORY_MONSTER_WHISPER,
        CHAT_CATEGORY_MONSTER_EMOTE,
    }

    pChatData.guildCategories = {
        CHAT_CATEGORY_GUILD_1,
        CHAT_CATEGORY_GUILD_2,
        CHAT_CATEGORY_GUILD_3,
        CHAT_CATEGORY_GUILD_4,
        CHAT_CATEGORY_GUILD_5,
        CHAT_CATEGORY_OFFICER_1,
        CHAT_CATEGORY_OFFICER_2,
        CHAT_CATEGORY_OFFICER_3,
        CHAT_CATEGORY_OFFICER_4,
        CHAT_CATEGORY_OFFICER_5,
    }

    -- TODO unused. remove
    pChatData.defaultChannels = {
        CONSTANTS.PCHAT_CHANNEL_NONE,
        CHAT_CHANNEL_ZONE,
        CHAT_CHANNEL_SAY,
        CHAT_CHANNEL_GUILD_1,
        CHAT_CHANNEL_GUILD_2,
        CHAT_CHANNEL_GUILD_3,
        CHAT_CHANNEL_GUILD_4,
        CHAT_CHANNEL_GUILD_5,
        CHAT_CHANNEL_OFFICER_1,
        CHAT_CHANNEL_OFFICER_2,
        CHAT_CHANNEL_OFFICER_3,
        CHAT_CHANNEL_OFFICER_4,
        CHAT_CHANNEL_OFFICER_5,
    }

    local function UndockTextEntry()
        local charId = GetCurrentCharacterId()
        -- Unfinshed
        if not db.chatConfSync[charId].TextEntryPoint then
            db.chatConfSync[charId].TextEntryPoint = CENTER
            db.chatConfSync[charId].TextEntryRelPoint = CENTER
            db.chatConfSync[charId].TextEntryX = 0
            db.chatConfSync[charId].TextEntryY = -300
            db.chatConfSync[charId].TextEntryWidth = 200
        end

        ZO_ChatWindowTextEntry:ClearAnchors()
        ZO_ChatWindowTextEntry:SetAnchor(db.chatConfSync[charId].TextEntryPoint, GuiRoot, db.chatConfSync[charId].TextEntryRelPoint, db.chatConfSync[charId].TextEntryX, 300)
        ZO_ChatWindowTextEntry:SetDimensions(400, 27)
        ZO_ChatWindowTextEntry:SetMovable(false)

        local undockedTexture = WM:CreateControl("UndockedBackground", ZO_ChatWindowTextEntry, CT_TEXTURE)
        undockedTexture:SetTexture("EsoUI/Art/Performance/StatusMeterMunge.dds")
        undockedTexture:SetAnchor(CENTER, ZO_ChatWindowTextEntry, CENTER, 0, 0)
        undockedTexture:SetDimensions(800, 250)
    end

    -- TODO what is needed to finish this or can it be removed?
    --local function RedockTextEntry()
    --    -- Unfinished
    --    ZO_ChatWindowTextEntry:ClearAnchors()
    --    ZO_ChatWindowTextEntry:SetAnchor(BOTTOMLEFT, ZO_ChatWindowMinimize, BOTTOMRIGHT, -6, -13)
    --    ZO_ChatWindowTextEntry:SetAnchor(BOTTOMRIGHT, ZO_ChatWindow, BOTTOMRIGHT, -23, -13)
    --    ZO_ChatWindowTextEntry:SetMovable(false)
    --end

    -- Change ChatWindow Darkness by modifying its <Center> & <Edge>. Originally defined in virtual object ZO_ChatContainerTemplate in sharedchatsystem.xml
    local function ChangeChatWindowDarkness()
        --New dynamic code
        local chatWindowDarknesssSetting = db.windowDarkness
        if chatWindowDarknesssSetting == 0 then
            ZO_ChatWindowBg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
            ZO_ChatWindowBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
        elseif chatWindowDarknesssSetting == 1 then
            ZO_ChatWindowBg:SetCenterColor(0, 0, 0, 0)
            ZO_ChatWindowBg:SetEdgeColor(0, 0, 0, 0)
        elseif chatWindowDarknesssSetting > 1 then
            local textureStringMultiValue = tonumber((chatWindowDarknesssSetting - 1) * 10)
            if textureStringMultiValue == nil or textureStringMultiValue > 100 then return end
            local texturePathCenterDependingOnWindowDarknessTemplate = "pChat/dds/chat_bg_center_%d.dds"
            local texturePathCenterDependingOnWindowDarkness = string.format(texturePathCenterDependingOnWindowDarknessTemplate, textureStringMultiValue)
            local texturePathEdgeDependingOnWindowDarknessTemplate = "pChat/dds/chat_bg_edge_%d.dds"
            local texturePathEdgeDependingOnWindowDarkness = string.format(texturePathEdgeDependingOnWindowDarknessTemplate, textureStringMultiValue)
            ZO_ChatWindowBg:SetCenterTexture(texturePathCenterDependingOnWindowDarkness)
            ZO_ChatWindowBg:SetEdgeTexture(texturePathEdgeDependingOnWindowDarkness, 256, 256, 32)
        end
    end
    pChat.ChangeChatWindowDarkness = ChangeChatWindowDarkness

    -- Change font of chat
    local function ChangeChatFont(change)

        local fontSize = GetChatFontSize()

        if db.fonts == "ESO Standard Font" or db.fonts == "Univers 57" then
            return
        else

            local fontPath = LibMediaProvider:Fetch("font", db.fonts)

            -- Entry Box
            ZoFontEditChat:SetFont(fontPath .. "|".. fontSize .. "|shadow")

            -- Chat window
            ZoFontChat:SetFont(fontPath .. "|" .. fontSize .. "|soft-shadow-thin")

        end

    end
    pChat.ChangeChatFont = ChangeChatFont

    -- Save chat configuration
    local function SaveChatConfig()

        if not pChatData.tabNotBefore then
            pChatData.tabNotBefore = {} -- Init here or in SyncChatConfig depending if the "Clear Tab" has been used
        end

        if pChatData.isAddonLoaded and CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer then -- Some addons calls SetCVar before
            local charId = GetCurrentCharacterId()

            -- Rewrite the whole char tab
            db.chatConfSync[charId] = {}

            -- Save Chat positions
            db.chatConfSync[charId].relPoint = CHAT_SYSTEM.primaryContainer.settings.relPoint
            db.chatConfSync[charId].x = CHAT_SYSTEM.primaryContainer.settings.x
            db.chatConfSync[charId].y = CHAT_SYSTEM.primaryContainer.settings.y
            db.chatConfSync[charId].height = CHAT_SYSTEM.primaryContainer.settings.height
            db.chatConfSync[charId].width = CHAT_SYSTEM.primaryContainer.settings.width
            db.chatConfSync[charId].point = CHAT_SYSTEM.primaryContainer.settings.point

            --db.chatConfSync[charId].textEntryDocked = true

            -- Don't overflow screen, remove 10px.
            if CHAT_SYSTEM.primaryContainer.settings.height >= ( CHAT_SYSTEM.maxContainerHeight - 15 ) then
                db.chatConfSync[charId].height = ( CHAT_SYSTEM.maxContainerHeight - 15 )
            else
                db.chatConfSync[charId].height = CHAT_SYSTEM.primaryContainer.settings.height
            end

            -- Same
            if CHAT_SYSTEM.primaryContainer.settings.width >= ( CHAT_SYSTEM.maxContainerWidth - 15 ) then
                db.chatConfSync[charId].width = ( CHAT_SYSTEM.maxContainerWidth - 15 )
            else
                db.chatConfSync[charId].width = CHAT_SYSTEM.primaryContainer.settings.width
            end

            -- Save Colors
            db.chatConfSync[charId].colors = {}

            for _, category in ipairs (pChatData.chatCategories) do
                local r, g, b = GetChatCategoryColor(category)
                db.chatConfSync[charId].colors[category] = { red = r, green = g, blue = b }
            end

            -- Save Font Size
            db.chatConfSync[charId].fontSize = GetChatFontSize()

            -- Save Tabs
            db.chatConfSync[charId].tabs = {}

            -- GetNumChatContainerTabs(1) don't refresh its number before a ReloadUI
            -- for numTab = 1, GetNumChatContainerTabs(1) do
            for numTab in ipairs (CHAT_SYSTEM.primaryContainer.windows) do

                db.chatConfSync[charId].tabs[numTab] = {}

                -- Save "Clear Tab" flag
                if pChatData.tabNotBefore[numTab] then
                    db.chatConfSync[charId].tabs[numTab].notBefore = pChatData.tabNotBefore[numTab]
                end

                -- No.. need a ReloadUI     local name, isLocked, isInteractable, isCombatLog, areTimestampsEnabled = GetChatContainerTabInfo(1, numTab)
                -- IsLocked
                if CHAT_SYSTEM.primaryContainer:IsLocked(numTab) then
                    db.chatConfSync[charId].tabs[numTab].isLocked = true
                else
                    db.chatConfSync[charId].tabs[numTab].isLocked = false
                end

                -- IsInteractive
                if CHAT_SYSTEM.primaryContainer:IsInteractive(numTab) then
                    db.chatConfSync[charId].tabs[numTab].isInteractable = true
                else
                    db.chatConfSync[charId].tabs[numTab].isInteractable = false
                end

                -- IsCombatLog
                if CHAT_SYSTEM.primaryContainer:IsCombatLog(numTab) then
                    db.chatConfSync[charId].tabs[numTab].isCombatLog = true
                    -- AreTimestampsEnabled
                    if CHAT_SYSTEM.primaryContainer:AreTimestampsEnabled(numTab) then
                        db.chatConfSync[charId].tabs[numTab].areTimestampsEnabled = true
                    else
                        db.chatConfSync[charId].tabs[numTab].areTimestampsEnabled = false
                    end
                else
                    db.chatConfSync[charId].tabs[numTab].isCombatLog = false
                    db.chatConfSync[charId].tabs[numTab].areTimestampsEnabled = false
                end

                -- GetTabName
                db.chatConfSync[charId].tabs[numTab].name = CHAT_SYSTEM.primaryContainer:GetTabName(numTab)

                -- Enabled categories
                db.chatConfSync[charId].tabs[numTab].enabledCategories = {}

                for _, category in ipairs (pChatData.chatCategories) do
                    local isEnabled = IsChatContainerTabCategoryEnabled(1, numTab, category)
                    db.chatConfSync[charId].tabs[numTab].enabledCategories[category] = isEnabled
                end

            end

            db.chatConfSync.lastChar = db.chatConfSync[charId]

        end

    end
    pChat.SaveChatConfig = SaveChatConfig

    -- Function for Minimizing chat at launch
    local function MinimizeChatAtLaunch()
        if db.chatMinimizedAtLaunch then
            CHAT_SYSTEM:Minimize()
        end
    end

    local function MinimizeChatInMenus()

        -- RegisterCallback for Maximize/Minimize chat when entering/leaving scenes
        -- "hud" is base scene (with "hudui")
        local hudScene = SCENE_MANAGER:GetScene("hud")
        hudScene:RegisterCallback("StateChange", function(oldState, newState)

                if db.chatMinimizedInMenus then
                    if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
                        CHAT_SYSTEM:Minimize()
                    end
                end

                if db.chatMaximizedAfterMenus then
                    if newState == SCENE_SHOWING then
                        CHAT_SYSTEM:Maximize()
                    end
                end

        end)

    end

    -- Set the chat config from pChat settings
    local function SyncChatConfig(shouldSync, whichCharId)

        if shouldSync then
            if db.chatConfSync and db.chatConfSync[whichCharId] and CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer then
                local chatConfSyncForCharId = db.chatConfSync[whichCharId]
                if CHAT_SYSTEM.control then
                    -- Position and width/height
                    CHAT_SYSTEM.control:SetAnchor(chatConfSyncForCharId.point, GuiRoot, chatConfSyncForCharId.relPoint, chatConfSyncForCharId.x, chatConfSyncForCharId.y)
                    -- Height / Width
                    CHAT_SYSTEM.control:SetDimensions(chatConfSyncForCharId.width, chatConfSyncForCharId.height)
                end

                -- Save settings immediatly (to check, maybe call function which do this)
                if CHAT_SYSTEM.primaryContainer.settings then
                    CHAT_SYSTEM.primaryContainer.settings.height = chatConfSyncForCharId.height
                    CHAT_SYSTEM.primaryContainer.settings.point = chatConfSyncForCharId.point
                    CHAT_SYSTEM.primaryContainer.settings.relPoint = chatConfSyncForCharId.relPoint
                    CHAT_SYSTEM.primaryContainer.settings.width = chatConfSyncForCharId.width
                    CHAT_SYSTEM.primaryContainer.settings.x = chatConfSyncForCharId.x
                    CHAT_SYSTEM.primaryContainer.settings.y = chatConfSyncForCharId.y
                end

                -- TODO why is this commented out?
                ---- Don't overflow screen, remove 15px.
                --if chatConfSyncForCharId.height >= (CHAT_SYSTEM.maxContainerHeight - 15 ) then
                --    CHAT_SYSTEM.control:SetHeight((CHAT_SYSTEM.maxContainerHeight - 15 ))
                --    logger:Debug("Overflow height %d -+- %d",  chatConfSyncForCharId.height, (CHAT_SYSTEM.maxContainerHeight - 15))
                --    logger:Debug(CHAT_SYSTEM.control:GetHeight())
                --else
                --    -- Don't set good values ?! SetHeight(674) = GetHeight(524) ? same with Width and resizing is buggy
                --    --CHAT_SYSTEM.control:SetHeight(chatConfSyncForCharId.height)
                --    CHAT_SYSTEM.control:SetDimensions(settings.width, settings.height)
                --    logger:Debug("height %d -+- %d", chatConfSyncForCharId.height, CHAT_SYSTEM.control:GetHeight())
                --end
                --
                ---- Same
                --if chatConfSyncForCharId.width >= (CHAT_SYSTEM.maxContainerWidth - 15 ) then
                --    CHAT_SYSTEM.control:SetWidth((CHAT_SYSTEM.maxContainerWidth - 15 ))
                --    logger:Debug("Overflow width %d -+- %d", chatConfSyncForCharId.width, (CHAT_SYSTEM.maxContainerWidth - 15))
                --    logger:Debug(CHAT_SYSTEM.control:GetWidth())
                --else
                --    CHAT_SYSTEM.control:SetHeight(chatConfSyncForCharId.width)
                --    logger:Debug("width %d -+- %d", chatConfSyncForCharId.width, CHAT_SYSTEM.control:GetWidth())
                --end

                -- Colors
                if GetChatCategoryColor and SetChatCategoryColor then
                    for _, category in ipairs (pChatData.chatCategories) do
                        if not chatConfSyncForCharId.colors[category] then
                            local r, g, b = GetChatCategoryColor(category)
                            chatConfSyncForCharId.colors[category] = { red = r, green = g, blue = b }
                        end
                        SetChatCategoryColor(category, chatConfSyncForCharId.colors[category].red, chatConfSyncForCharId.colors[category].green, chatConfSyncForCharId.colors[category].blue)
                    end
                end

                -- Font Size
                -- Not in Realtime SetChatFontSize(chatConfSyncForCharId.fontSize), need to add CHAT_SYSTEM:SetFontSize for Realtimed

                -- ?!? Need to go by a local?..
                if CHAT_SYSTEM.SetFontSize and SetChatFontSize then
                    local fontSize = chatConfSyncForCharId.fontSize
                    CHAT_SYSTEM:SetFontSize(fontSize)
                    SetChatFontSize(chatConfSyncForCharId.fontSize)
                end

                local chatSyncNumTab = 1
                if chatConfSyncForCharId.tabs then
                    for numTab in ipairs(chatConfSyncForCharId.tabs) do

                        --Create a Tab if nessesary
                        if (GetNumChatContainerTabs(1) < numTab) then
                            -- AddChatContainerTab(1, , chatConfSyncForCharId.tabs[numTab].isCombatLog) No ! Require a ReloadUI
                            CHAT_SYSTEM.primaryContainer:AddWindow(chatConfSyncForCharId.tabs[numTab].name)
                        end

                        if chatConfSyncForCharId.tabs[numTab] and chatConfSyncForCharId.tabs[numTab].notBefore then

                            if not pChatData.tabNotBefore then
                                pChatData.tabNotBefore = {} -- Used for tab restoration, init here.
                            end

                            pChatData.tabNotBefore[numTab] = chatConfSyncForCharId.tabs[numTab].notBefore

                        end

                        -- Set Tab options
                        -- Not in realtime : SetChatContainerTabInfo(1, numTab, chatConfSyncForCharId.tabs[numTab].name, chatConfSyncForCharId.tabs[numTab].isLocked, chatConfSyncForCharId.tabs[numTab].isInteractable, chatConfSyncForCharId.tabs[numTab].areTimestampsEnabled)

                        CHAT_SYSTEM.primaryContainer:SetTabName(numTab, chatConfSyncForCharId.tabs[numTab].name)
                        CHAT_SYSTEM.primaryContainer:SetLocked(numTab, chatConfSyncForCharId.tabs[numTab].isLocked)
                        CHAT_SYSTEM.primaryContainer:SetInteractivity(numTab, chatConfSyncForCharId.tabs[numTab].isInteractable)
                        CHAT_SYSTEM.primaryContainer:SetTimestampsEnabled(numTab, chatConfSyncForCharId.tabs[numTab].areTimestampsEnabled)

                        -- Set Channel per tab configuration
                        for _, category in ipairs (pChatData.chatCategories) do
                            if chatConfSyncForCharId.tabs[numTab].enabledCategories[category] == nil then -- Cal be false
                                chatConfSyncForCharId.tabs[numTab].enabledCategories[category] = IsChatContainerTabCategoryEnabled(1, numTab, category)
                            end
                            SetChatContainerTabCategoryEnabled(1, numTab, category, chatConfSyncForCharId.tabs[numTab].enabledCategories[category])
                        end

                        chatSyncNumTab = numTab

                    end
                end

                -- If they're was too many tabs before, drop them
                local removeTabs = true
                while removeTabs do
                    -- Too many tabs, deleting one
                    if GetNumChatContainerTabs(1) > chatSyncNumTab then
                        -- Not in realtime : RemoveChatContainerTab(1, chatSyncNumTab + 1)
                        CHAT_SYSTEM.primaryContainer:RemoveWindow(chatSyncNumTab + 1, nil)
                    else
                        removeTabs = false
                    end
                end
            end
        end

    end
    pChat.SyncChatConfig = SyncChatConfig

    -- When creating a char, try to import settings
    local function AutoSyncSettingsForNewPlayer()

        -- New chars get automaticaly last char config
        if GetIsNewCharacter() then
            SyncChatConfig(true, "lastChar")
        end

    end

    -- Set channel to the default one
    local function SetToDefaultChannel()
        if db.defaultchannel ~= CONSTANTS.PCHAT_CHANNEL_NONE then
            CHAT_SYSTEM:SetChannel(db.defaultchannel)
        end
    end

    -- triggers when EVENT_GROUP_MEMBER_LEFT
    local function OnGroupMemberLeft(_, characterName, reason, wasMeWhoLeft)

        -- Go back to default channel
        if GetGroupSize() <= 1 then
            -- Go back to default channel when leaving a group
            if db.enablepartyswitch then
                -- Only if we was on party
                if CHAT_SYSTEM.currentChannel == CHAT_CHANNEL_PARTY and db.defaultchannel ~= CONSTANTS.PCHAT_CHANNEL_NONE then
                    SetToDefaultChannel()
                end
            end
        end

    end

    local function SwitchToParty(characterName)
        zo_callLater(function() -- characterName = avoid ZOS bug
            -- If "me" join group
            if(characterName and GetRawUnitName("player") == characterName) then

                    -- Switch to party channel when joining a group
                    if db.enablepartyswitch then
                        CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)
                    end
            else
                -- Someone else joined group
                -- If GetGroupSize() == 2 : Means "me" just created a group and "someone" just joining
                if GetGroupSize() == 2 then
                    -- Switch to party channel when joinin a group
                    if db.enablepartyswitch then
                        CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)
                    end
                end

            end
        end, 200)
    end

    -- Triggers when EVENT_GROUP_MEMBER_JOINED
    local function OnGroupMemberJoined(_, characterName)
        SwitchToParty(characterName)
    end

    -- Save a category color for guild chat, set by ChatSystem at launch + when user change manually
    local function SaveChatCategoriesColors(category, r, g, b)
        local charId = GetCurrentCharacterId()
        if db.chatConfSync[charId] then
            if db.chatConfSync[charId].colors[category] == nil then
                db.chatConfSync[charId].colors[category] = {}
            end
            db.chatConfSync[charId].colors[category] = { red = r, green = g, blue = b }
        end
    end

    -- PreHook of ZO_ChatSystem_ShowOptions() and ZO_ChatWindow_OpenContextMenu(control.index)
    local function ChatSystemShowOptions(tabIndex)
        local self = CHAT_SYSTEM.primaryContainer
        tabIndex = tabIndex or (self.currentBuffer and self.currentBuffer:GetParent() and self.currentBuffer:GetParent().tab and self.currentBuffer:GetParent().tab.index)
        local window = self.windows[tabIndex]
        if window then
            ClearMenu()

            if not ZO_Dialogs_IsShowingDialog() then
                AddCustomMenuItem(GetString(SI_CHAT_CONFIG_CREATE_NEW), function() self.system:CreateNewChatTab(self) end)
                if not window.combatLog and (not self:IsPrimary() or tabIndex ~= 1) then
                    AddCustomMenuItem(GetString(SI_CHAT_CONFIG_REMOVE), function() self:ShowRemoveTabDialog(tabIndex) end)
                end
                AddCustomMenuItem(GetString(SI_CHAT_CONFIG_OPTIONS), function() self:ShowOptions(tabIndex) end)
                AddCustomMenuItem(GetString(PCHAT_CLEARBUFFER), function()
                    pChatData.tabNotBefore[tabIndex] = GetTimeStamp()
                    self.windows[tabIndex].buffer:Clear()
                    self:SyncScrollToBuffer()
                end)
            end

            if self:IsPrimary() and tabIndex == 1 then
                if self:IsLocked(tabIndex) then
                    AddCustomMenuItem(GetString(SI_CHAT_CONFIG_UNLOCK), function() self:SetLocked(tabIndex, false) end)
                else
                    AddCustomMenuItem(GetString(SI_CHAT_CONFIG_LOCK), function() self:SetLocked(tabIndex, true) end)
                end
            end

            if window.combatLog then
                if self:AreTimestampsEnabled(tabIndex) then
                    AddCustomMenuItem(GetString(SI_CHAT_CONFIG_HIDE_TIMESTAMP), function() self:SetTimestampsEnabled(tabIndex, false) end)
                else
                    AddCustomMenuItem(GetString(SI_CHAT_CONFIG_SHOW_TIMESTAMP), function() self:SetTimestampsEnabled(tabIndex, true) end)
                end
            end

            -- TODO why is this commented out?
            --local charId = GetCurrentCharacterId()
            --if db.chatConfSync[charId].textEntryDocked then
            --    AddCustomMenuItem(GetString(PCHAT_UNDOCKTEXTENTRY), function() UndockTextEntry() end)
            --else
            --    AddCustomMenuItem(GetString(PCHAT_REDOCKTEXTENTRY), function() RedockTextEntry() end)
            --end

            ShowMenu(window.tab)
        end
        --Do not call original ZO_ChatSystem_ShowOptions() or ZO_ChatWindow_OpenContextMenu()
        return true
    end


    -- Save Chat Tabs config when user changes it
    local function SaveTabsCategories()
        local charId = GetCurrentCharacterId()

        for numTab in ipairs (CHAT_SYSTEM.primaryContainer.windows) do

            for _, category in ipairs (pChatData.guildCategories) do
                local isEnabled = IsChatContainerTabCategoryEnabled(1, numTab, category)
                if db.chatConfSync[charId].tabs[numTab] then
                    db.chatConfSync[charId].tabs[numTab].enabledCategories[category] = isEnabled
                else
                    SaveChatConfig()
                end
            end

        end

    end

    -- Append system category to chat filters
    local FILTERS_PER_ROW = 2
    local FILTER_PAD_X = 90
    local FILTER_PAD_Y = 0
    local FILTER_WIDTH = 150
    local FILTER_HEIGHT = 27
    local INITIAL_XOFFS = 0
    local INITIAL_YOFFS = 0

    SecurePostHook(CHAT_OPTIONS, "InitializeFilterButtons", function(self)
        local filterAnchor = ZO_Anchor:New(TOPLEFT, self.filterSection, TOPLEFT, 0, 0)
        local count = self.filterPool:GetActiveObjectCount()

        local filter, key = self.filterPool:AcquireObject()
        filter.key = key

        local button = filter:GetNamedChild("Check")
        ZO_CheckButton_SetLabelText(button, GetString("SI_CHATCHANNELCATEGORIES", CHAT_CATEGORY_SYSTEM))
        button.channels = { CHAT_CATEGORY_SYSTEM }
        table.insert(self.filterButtons, button)

        ZO_Anchor_BoxLayout(filterAnchor, filter, count, FILTERS_PER_ROW, FILTER_PAD_X, FILTER_PAD_Y, FILTER_WIDTH, FILTER_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
    end)

    -- Social option change color
    ZO_PreHook("SetChatCategoryColor", SaveChatCategoriesColors)
    -- Chat option change categories filters, add a callLater because settings are set after this function triggers.
    ZO_PreHook("ZO_ChatOptions_ToggleChannel", function() zo_callLater(SaveTabsCategories, 100) end)

    -- Right click on a tab name
    ZO_PreHook("ZO_ChatSystem_ShowOptions", function(control) return ChatSystemShowOptions() end)
    ZO_PreHook("ZO_ChatWindow_OpenContextMenu", function(control) return ChatSystemShowOptions(control.index) end)

    -- Will change font if needed
    ChangeChatFont()

    -- Minimize Chat in Menus
    MinimizeChatInMenus()

    -- Party switches
    EM:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    EM:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)

    -- this is called during the first EVENT_PLAYER_ACTIVATED
    function pChat.ApplyChatConfig()
        if not pChatData.isAddonInitialized then
            -- Should we minimize ?
            MinimizeChatAtLaunch()

            -- Message for new chars
            AutoSyncSettingsForNewPlayer()

            -- Chat Config synchronization
            SyncChatConfig(db.chatSyncConfig, "lastChar")
            SaveChatConfig()

            -- Change Window apparence
            ChangeChatWindowDarkness()

            -- Set default channel at login
            SetToDefaultChannel()
        end
    end

end
