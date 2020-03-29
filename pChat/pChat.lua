--=======================================================================================================================================
--Known problems/bugs:
--Last updated: 2020-02-28
--Total number: 2
------------------------------------------------------------------------------------------------------------------------
--#2    2020-02-28 Baetram, bug: New selection for @accountName/character chat prefix will only show /charactername (@accountName is missing) during whispers,
--      if clicked on a character in the chat to whisper him/her
------------------------------------------------------------------------------------------------------------------------
--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn info
--======================================================================================================================
-- Common
local ADDON_NAME    = "pChat"

--======================================================================================================================
--pChat Variables--
--======================================================================================================================

-- pChatData will receive variables and objects.
local pChatData = {}
-- Logged in char name
pChatData.localPlayer = GetUnitName("player")

--LibDebugLogger objects
local logger
local subloggerVerbose

--======================================================================================================================
--Constants
--======================================================================================================================

-- Used for pChat LinkHandling
local PCHAT_LINK = "p"
local PCHAT_URL_CHAN = 97
local PCHAT_CHANNEL_SAY = 98
local PCHAT_CHANNEL_NONE = 99

--======================================================================================================================
-- Local Variables
--======================================================================================================================
local db

-- Preventer
local eventPlayerActivatedCheckRunning = false
local eventPlayerActivatedChecksDone = 0

--ZOs chat channels table
local ChannelInfo = ZO_ChatSystem_GetChannelInfo()

--======================================================================================================================
--Load the libraries
--======================================================================================================================
local function LoadLibraries()
    --LibDebugLogger
    if not pChat.logger and LibDebugLogger then
        pChat.logger = LibDebugLogger(ADDON_NAME)
        logger = pChat.logger
        logger:Debug("AddOn loaded")
        subloggerVerbose = logger:Create("Verbose")
        subloggerVerbose:SetEnabled(false)
        pChat.verbose = subloggerVerbose
    end
    --LibChatMessage
    --  if not pChat.LCM and LibChatMessage then
    --      pChat.LCM = LibChatMessage(ADDON_NAME, "pC")
    --      if logger then logger:Debug("Library 'LibChatMessage' detected") end
    --  end
end
--Early try to load libs (done again in EVENT_ADD_ON_LOADED)
LoadLibraries()

--======================================================================================================================
-- pChat functions
--======================================================================================================================

--Prepare some needed addon variables
local function PrepareVars()
    --Build the character name to unique ID mapping tables and vice-versa
    --The character names are decorated with the color and icon of the class!
    pChat.characterName2Id = {}
    pChat.characterId2Name = {}
    pChat.characterNameRaw2Id = {}
    pChat.characterId2NameRaw = {}
    --Tables with character charname as key
    pChat.characterName2Id = pChat.getCharactersOfAccount(true, true)
    pChat.characterNameRaw2Id = pChat.getCharactersOfAccount(true, false)
    --Tables with character ID as key
    pChat.characterId2Name = pChat.getCharactersOfAccount(false, true)
    pChat.characterId2NameRaw = pChat.getCharactersOfAccount(false, false)
end


-- Rewrite of a core function
do
    local parts = {}
    local chatSystem = CHAT_SYSTEM
    local originalAddCommandHistory = chatSystem.textEntry.AddCommandHistory
    function chatSystem.textEntry:AddCommandHistory(text)
        -- Don't add the switch when chat is restored
        if db.addChannelAndTargetToHistory and pChatData.isAddonInitialized then
            local currentChannel = chatSystem.currentChannel
            local currentTarget = chatSystem.currentTarget
            local switch = chatSystem.switchLookup[currentChannel]
            if switch ~= nil then
                parts[1] = switch
                if currentTarget then
                    parts[2] = currentTarget
                    parts[3] = text
                else
                    parts[2] = text
                    parts[3] = nil
                end
                text = table.concat(parts, " ")
            end
        end

        originalAddCommandHistory(self, text)
    end
end

do
    -- we want to return pChat colors when the setting for eso colors is not enabled
    -- TODO investigate how we can use SetChatCategoryColor, so GetChatCategoryColor returns the value directly
    local originalZO_ChatSystem_GetCategoryColorFromChannel = ZO_ChatSystem_GetCategoryColorFromChannel
    function ZO_ChatSystem_GetCategoryColorFromChannel(channelId)
        if pChatData.isAddonLoaded and not db.useESOcolors then
            local pChatColor
            if db.allGuildsSameColour and (channelId >= CHAT_CHANNEL_GUILD_1 and channelId <= CHAT_CHANNEL_GUILD_5) then
                pChatColor = db.colours[2 * CHAT_CHANNEL_GUILD_1]
            elseif db.allGuildsSameColour and (channelId >= CHAT_CHANNEL_OFFICER_1 and channelId <= CHAT_CHANNEL_OFFICER_5) then
                pChatColor = db.colours[2 * CHAT_CHANNEL_OFFICER_1]
            elseif db.allZonesSameColour and (channelId >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channelId <= CHAT_CHANNEL_ZONE_LANGUAGE_4) then
                pChatColor = db.colours[2 * CHAT_CHANNEL_ZONE]
            else
                pChatColor = db.colours[2 * channelId]
            end

            if not pChatColor then
                return 1, 1, 1, 1
            else
                return pChat.ConvertHexToRGBA(pChatColor)
            end
        end
        return originalZO_ChatSystem_GetCategoryColorFromChannel(channelId)
    end
end

-- Change guild channel names in entry box
local function UpdateCharCorrespondanceTableChannelNames()
    logger:Debug("UpdateCharCorrespondanceTableChannelNames-Create the guild short names")
    -- Each guild: Update the table from ZO_ChatSystem_GetChannelInfo()
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if db.showTagInEntry then
            -- Get saved string
            local tag = db.guildTags[guildId]
            -- No SavedVar
            if not tag then
                tag = guildName
                -- SavedVar, but no tag
            elseif tag == "" then
                tag = guildName
            end

            -- Get saved string
            local officertag = db.officertag[guildId]
            -- No SavedVar
            if not officertag then
                officertag = tag
                -- SavedVar, but no tag
            elseif officertag == "" then
                officertag = tag
            end

            -- CHAT_CHANNEL_GUILD_1 /g1 is 12 /g5 is 16, /o1=17, etc
            ChannelInfo[CHAT_CHANNEL_GUILD_1 - 1 + i].name = tag
            ChannelInfo[CHAT_CHANNEL_OFFICER_1 - 1 + i].name = officertag
            logger:Debug(">Set guild/officer tags to: %s/%s for guild #%d", tag, officertag, i)
            --Disabling dynamic chat channel names (see function GetDynamicChatChannelName(channelInfo.id))
            ChannelInfo[CHAT_CHANNEL_GUILD_1 - 1 + i].dynamicName = false
            ChannelInfo[CHAT_CHANNEL_OFFICER_1 - 1 + i].dynamicName = false

        else
            ChannelInfo[CHAT_CHANNEL_GUILD_1 - 1 + i].name = guildName
            ChannelInfo[CHAT_CHANNEL_OFFICER_1 - 1 + i].name = guildName
            --Enabling dynamic chat channel names (see function GetDynamicChatChannelName(channelInfo.id))
            ChannelInfo[CHAT_CHANNEL_GUILD_1 - 1 + i].dynamicName = true
            ChannelInfo[CHAT_CHANNEL_OFFICER_1 - 1 + i].dynamicName = true
        end
    end
end

local function UpdateGuildCorrespondanceTableSwitches()
    -- Update custom guild switches
    logger:Debug("UpdateGuildCorrespondanceTableSwitches-Create the guild chat switches")
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)

        local guildSwitches = db.switchFor[guildId]
        if(guildSwitches and guildSwitches ~= "") then
            pChat.AddCustomChannelSwitches(CHAT_CHANNEL_GUILD_1 - 1 + i, guildSwitches)
        end

        local officerSwitches = db.officerSwitchFor[guildId]
        if(officerSwitches and officerSwitches ~= "") then
            pChat.AddCustomChannelSwitches(CHAT_CHANNEL_OFFICER_1 - 1 + i, officerSwitches)
        end
    end
end


-- Rewrite of core function
do
    -- we try to set the alert color for the tab buttons, but as TAB_ALERT_TEXT_COLOR is local we have to intercept the call to ZO_TabButton_Text_SetTextColor
    -- this is obviously not ideal, but until ZOS adds a way to set the alert color it's the easiest way
    local originalZO_TabButton_Text_SetTextColor = ZO_TabButton_Text_SetTextColor
    local lastColor, cachedColor
    function ZO_TabButton_Text_SetTextColor(button, color)
        if(button:GetOwningWindow() == ZO_ChatWindow) then
            if(db.colours.tabwarning ~= lastColor) then
                lastColor = db.colours.tabwarning
                cachedColor = ZO_ColorDef:New(pChat.ConvertHexToRGBA(lastColor))
            end
            originalZO_TabButton_Text_SetTextColor(button, cachedColor)
        else
            originalZO_TabButton_Text_SetTextColor(button, color)
        end
    end
end

-- Rewrite of core data
do
    -- TODO this isn't currently used in FormatMessage, but may come in handy once we refactor that
    ChannelInfo[CHAT_CHANNEL_SAY].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_YELL].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_1].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_2].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_3].channelLinkable = true
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_4].channelLinkable = true
end


-- Registers the formatMessage function.
-- Unregisters itself from the player activation event with the event manager.
local function OnPlayerActivated()
    logger:Debug("EVENT_PLAYER_ACTIVATED - Start")
    --Addon was loaded via EVENT_ADD_ON_LOADED and we are not already doing some EVENT_PLAYER_ACTIVATED tasks
    if pChatData.isAddonLoaded and not eventPlayerActivatedCheckRunning then
        pChatData.sceneFirst = false

        pChat.InitializeChatHandlers(pChat.FormatMessage, pChat.formatSysMessage, logger)
    end

    --Test if the chat_system containers are given already or wait until they are.
    --Only test 3 seconds, then do the event_player_activated tasks!
    if eventPlayerActivatedChecksDone <= 12 and (CHAT_SYSTEM == nil or CHAT_SYSTEM.primaryContainer == nil) then
        logger:Debug("EVENT_PLAYER_ACTIVATED: CHAT_SYSTEM.primaryContainer is missing!")
        if not eventPlayerActivatedCheckRunning then
            EVENT_MANAGER:RegisterForUpdate("pChatDebug_Event_Player_Activated", 250, function()
                eventPlayerActivatedChecksDone = eventPlayerActivatedChecksDone + 1
                eventPlayerActivatedCheckRunning = true
                OnPlayerActivated()
            end)
        end
    else
        logger:Debug("EVENT_PLAYER_ACTIVATED: Found CHAT_SYSTEM.primaryContainer!")
        eventPlayerActivatedCheckRunning = false
        EVENT_MANAGER:UnregisterForUpdate("pChatDebug_Event_Player_Activated")

        if pChatData.isAddonLoaded then

            --local fontPath = ZoFontChat:GetFontInfo()
            --chat:Print(fontPath)
            --chat:Print("|C3AF24BLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.|r")
            --chat:Print("Characters below should be well displayed :")
            --chat:Print("!\"#$%&'()*+,-./0123456789:;<=>?@ ABCDEFGHIJKLMNOPQRSTUVWXYZ [\]^_`abcdefghijklmnopqrstuvwxyz{|} ~¡£¤¥¦§©«-®°²³´µ¶·»½¿ ÀÁÂÄÆÇÈÉÊËÌÍÎÏÑÒÓÔÖ×ÙÚÛÜßàáâäæçèéêëìíîïñòóôöùúûüÿŸŒœ")

            -- AntiSpam
            pChatData.spamLookingForEnabled = true
            pChatData.spamWantToEnabled = true
            pChatData.spamGuildRecruitEnabled = true

            -- Rebuild Lam Panel
            pChat.BuildLAMPanel()

            -- Chat Tab setup
            pChat.SetupChatTabs(db)

            -- Chat Config setup
            pChat.ApplyChatConfig()

            --Update the guilds custom tags (next to entry box): Add them to the chat channels of table ChannelInfo
            UpdateCharCorrespondanceTableChannelNames()

            --Update teh guild's custom channel switches: Add them to the chat switches of table ZO_ChatSystem_GetChannelSwitchLookupTable
            UpdateGuildCorrespondanceTableSwitches()

            -- Handle Copy text
            pChat.InitializeCopyHandler(pChatData, db, PCHAT_URL_CHAN, PCHAT_LINK)

            -- Restore History if needed
            pChat.RestoreChatHistory()

            pChatData.isAddonInitialized = true

            EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
            logger:Debug("EVENT_PLAYER_ACTIVATED - End: Addon was initialized")
        end
    end
end

--Load some early hooks
local function LoadEarlyHooks()
    -- Resize, must be loaded before CHAT_SYSTEM is set
    local orgCalculateConstraints = SharedChatContainer.CalculateConstraints
    function SharedChatContainer.CalculateConstraints(...)
        local self = ...
        local w, h = GuiRoot:GetDimensions()
        self.system.maxContainerWidth, self.system.maxContainerHeight = w * 0.95, h * 0.95
        return orgCalculateConstraints(...)
    end
end

--Load some hooks
local function LoadHooks()
    -- PreHook ReloadUI, SetCVar, LogOut & Quit to handle Chat Import/Export
    ZO_PreHook("ReloadUI", function()
        pChat.SaveChatHistory(1)
        pChat.SaveChatConfig()
    end)

    ZO_PreHook("SetCVar", function()
        pChat.SaveChatHistory(1)
        pChat.SaveChatConfig()
    end)

    ZO_PreHook("Logout", function()
        pChat.SaveChatHistory(2)
        pChat.SaveChatConfig()
    end)

    ZO_PreHook("Quit", function()
        pChat.SaveChatHistory(3)
        pChat.SaveChatConfig()
    end)


    --Scroll to bottom in Chat: Secure post hook to hide the Whisper Notifications
    SecurePostHook("ZO_ChatSystem_ScrollToBottom", function()
        pChat_RemoveIMNotification()
    end)

end

--Load the string IDs for keybindings e.g.
local function LoadStringIds()
    -- Bindings
    ZO_CreateStringId("PCHAT_AUTOMSG_NAME_DEFAULT_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_NAME_DEFAULT_TEXT))
    ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT))
    ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT))
    ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT))
    ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT))
    ZO_CreateStringId("PCHAT_AUTOMSG_NAME_HEADER", GetString(PCHAT_PCHAT_AUTOMSG_NAME_HEADER))
    ZO_CreateStringId("PCHAT_AUTOMSG_MESSAGE_HEADER", GetString(PCHAT_PCHAT_AUTOMSG_MESSAGE_HEADER))
    ZO_CreateStringId("PCHAT_AUTOMSG_ADD_TITLE_HEADER", GetString(PCHAT_PCHAT_AUTOMSG_ADD_TITLE_HEADER))
    ZO_CreateStringId("PCHAT_AUTOMSG_EDIT_TITLE_HEADER", GetString(PCHAT_PCHAT_AUTOMSG_EDIT_TITLE_HEADER))
    ZO_CreateStringId("PCHAT_AUTOMSG_ADD_AUTO_MSG", GetString(PCHAT_PCHAT_AUTOMSG_ADD_AUTO_MSG))
    ZO_CreateStringId("PCHAT_AUTOMSG_EDIT_AUTO_MSG", GetString(PCHAT_PCHAT_AUTOMSG_EDIT_AUTO_MSG))
    ZO_CreateStringId("SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG", GetString(PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG))
    ZO_CreateStringId("PCHAT_AUTOMSG_REMOVE_AUTO_MSG", GetString(PCHAT_PCHAT_AUTOMSG_REMOVE_AUTO_MSG))

    ZO_CreateStringId("SI_BINDING_NAME_PCHAT_SWITCH_TAB", GetString(PCHAT_SWITCHTONEXTTABBINDING))
    ZO_CreateStringId("SI_BINDING_NAME_PCHAT_TOGGLE_CHAT_WINDOW", GetString(PCHAT_TOGGLECHATBINDING))
    ZO_CreateStringId("SI_BINDING_NAME_PCHAT_WHISPER_MY_TARGET", GetString(PCHAT_WHISPMYTARGETBINDING))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_1", GetString(PCHAT_Tab1))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_2", GetString(PCHAT_Tab2))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_3", GetString(PCHAT_Tab3))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_4", GetString(PCHAT_Tab4))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_5", GetString(PCHAT_Tab5))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_6", GetString(PCHAT_Tab6))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_7", GetString(PCHAT_Tab7))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_8", GetString(PCHAT_Tab8))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_9", GetString(PCHAT_Tab9))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_10", GetString(PCHAT_Tab10))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_11", GetString(PCHAT_Tab11))
    ZO_CreateStringId("SI_BINDING_NAME_TAB_12", GetString(PCHAT_Tab12))
end

--Load the slash commands
local function LoadSlashCommands()
    -- Register Slash commands
    SLASH_COMMANDS["/msg"] = pChat_ShowAutoMsg
end

-- Please note that some things are delayed in OnPlayerActivated() because Chat isn't ready when this function triggers
local function OnAddonLoaded(_, addonName)
    --Protect
    if addonName == ADDON_NAME then
        eventPlayerActivatedChecksDone = 0

        --Prepare variables
        PrepareVars()

        --Load early hooks before chat system is ready e.g.
        LoadEarlyHooks()

        --Load the libraries (again)
        LoadLibraries()

        --Load keybinding and other text IDs
        LoadStringIds()

        --Load slash commands
        LoadSlashCommands()

        -- prepare chat tab functions
        pChat.InitializeChatTabs(pChatData)

        --Load the SV and LAM panel
        db = pChat.InitializeSettings(pChatData, ADDON_NAME, PCHAT_CHANNEL_NONE, UpdateCharCorrespondanceTableChannelNames, logger)

        -- set up channel names
        UpdateCharCorrespondanceTableChannelNames()

        -- prepare chat history functionality
        pChat.InitializeChatHistory(pChatData, db, PCHAT_CHANNEL_SAY, PCHAT_CHANNEL_NONE, subloggerVerbose)


        -- Automated messages
        pChat.InitializeAutomatedMessages(pChatData, db, ADDON_NAME)

        --Load some hookds
        LoadHooks()

        -- Initialize Chat Config features
        pChat.InitializeChatConfig(pChatData, db, PCHAT_CHANNEL_NONE)

        local SpamFilter = pChat.InitializeSpamFilter(pChatData, db, PCHAT_CHANNEL_SAY, subloggerVerbose)
        local FormatMessage, FormatSysMessage = pChat.InitializeMessageFormatters(pChatData, db, PCHAT_LINK, PCHAT_URL_CHAN, SpamFilter, logger, subloggerVerbose)

        -- For compatibility. Called by others addons.
        pChat.FormatMessage = FormatMessage
        pChat.formatSysMessage = FormatSysMessage
        pChat_FormatSysMessage = FormatSysMessage

        -- Because ChatSystem is loaded after EVENT_ADDON_LOADED triggers, we use 1st EVENT_PLAYER_ACTIVATED wich is run bit after
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

        -- Unregisters
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

        --Pointers to pChatData and SavedVariables
        pChat.pChatData = pChatData
        pChat.db = db

        --IM Features
        pChat.InitializeIncomingMessages(pChatData, db, subloggerVerbose)

        --Set variable that addon was laoded
        pChatData.isAddonLoaded = true
    end

end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

--Handled by keybind
function pChat_ToggleChat()

    if CHAT_SYSTEM:IsMinimized() then
        CHAT_SYSTEM:Maximize()
    else
        CHAT_SYSTEM:Minimize()
    end

end

-- Whisp my target
do
    local targetToWhisp

    local function OnReticleTargetChanged()
        if IsUnitPlayer("reticleover") then
            targetToWhisp = GetUnitName("reticleover")
        end
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)

    -- Called by bindings
    function pChat_WhispMyTarget()
        if targetToWhisp then
            CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, targetToWhisp)
        end
    end
end


