--=======================================================================================================================================
--Known problems/bugs:
--Last updated: 2020-06-23
--Total number: 8
------------------------------------------------------------------------------------------------------------------------
--#2	2020-02-28 Baetram, bug: New selection for @accountName/character chat prefix will only show /charactername (@accountName is missing) during whispers,
--		if clicked on a character in the chat to whisper him/her
------------------------------------------------------------------------------------------------------------------------
--#3	2020-03-27 Baetram, bug: Enter into a group with the dungeon finder will not change to the group chat channel /group automatically, if setting is enabled
------------------------------------------------------------------------------------------------------------------------
--#5	2020-05-22 Baetram, bug: Changing the slider for the chat background behaves weird
--Using the beta version now, and still running into the same problem. Changing the slider for the chat background transparency doesn't actually change it.
--I currently have it set to 10 and it's completely see-through.
--Screenshot: https://gyazo.com/61e2effb4b3837d25c6299edd794808a
--And.... apparently there's the issue. Setting to 9.
--After fully restarting game again, setting 9 is coming up as transparency 0, and a few other numbers are out of wack.
-->Possible cross-addon problem named was: "Social Indicator" with setting "Social indicator on UI" enabled
------------------------------------------------------------------------------------------------------------------------
--#6    2020-06-20 Mikikatze, bug: Setting for automatic selected chat tab does not work
--I turned off all other addons and libs, same problem. Even when I switch into another chat tab, as soon as I log out
--and in again it goes back to the first tab, which is zone chat.
--In settings the 2nd tab ist selected, I double checked.
------------------------------------------------------------------------------------------------------------------------
--#7    2020-06-20 Mikikatze, bug: Time stamps are not shown with system messages anymore
------------------------------------------------------------------------------------------------------------------------
--#8    2020-06-21 sindradottir, bug: /msg and keybind for automated messages do not always work

--=======================================================================================================================================

--=======================================================================================================================================
-- Changelog version: 10.0.0.2 (last version 10.0.0.1)
--=======================================================================================================================================
--Fixed:
--#8 /msg and keybind for automated messages do not always work

--Changed:

--Added:

--Added on request:
--=======================================================================================================================================

--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn Constants
--======================================================================================================================
local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME    = CONSTANTS.ADDON_NAME

--======================================================================================================================
--pChat Variables--
--======================================================================================================================
-- pChatData will receive variables and objects.
local pChatData = {}
-- Logged in char name
pChatData.localPlayer = GetUnitName("player")

--LibDebugLogger objects
local logger

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
        logger = LibDebugLogger(ADDON_NAME)
        logger:Debug("AddOn loaded")
        logger.verbose = logger:Create("Verbose")
        logger.verbose:SetEnabled(true)
        pChat.logger = logger
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

    --Update the available sounds from the game
    pChat.sounds = {}
    if SOUNDS then
        for soundName, _ in pairs(SOUNDS) do
            if soundName ~= "NONE" then
                table.insert(pChat.sounds, soundName)
            end
        end
        if #pChat.sounds > 0 then
            table.sort(pChat.sounds)
            table.insert(pChat.sounds, 1, "NONE")
        end
    end
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
            elseif db.allZonesSameColour and (channelId >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channelId <= CHAT_CHANNEL_ZONE_LANGUAGE_5) then
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
pChat.UpdateCharCorrespondanceTableChannelNames = UpdateCharCorrespondanceTableChannelNames

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
pChat.UpdateGuildCorrespondanceTableSwitches = UpdateGuildCorrespondanceTableSwitches


-- Rewrite of core function
do
    -- we try to set the alert color for the tab buttons, but as TAB_ALERT_TEXT_COLOR is local we have to intercept the call to ZO_TabButton_Text_SetTextColor
    -- this is obviously not ideal, but until ZOS adds a way to set the alert color it's the easiest way
    local originalZO_TabButton_Text_SetTextColor = ZO_TabButton_Text_SetTextColor
    local lastColor, cachedColor
    function ZO_TabButton_Text_SetTextColor(button, color)
        if(button:GetOwningWindow() == ZO_ChatWindow) then
            local colours = db.colours
            if(colours.tabwarning ~= lastColor) then
                lastColor = colours.tabwarning
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
    ChannelInfo[CHAT_CHANNEL_ZONE_LANGUAGE_5].channelLinkable = true
end

--Do some checks after the EVENT_PLAYER_ACTIVATED task was done
local function DoPostEventPlayerActivatedChecks()
    --Check for settings -> auto group channel switch
    if db and db.enablepartyswitch == true and db.enablepartyswitchPortToDungeon == true then
        --Check if in group
        if IsUnitGrouped("player") == true then
            -- Switch to party channel when joinin a group
            CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)
        end
    end
end

-- Registers the formatMessage function.
-- Unregisters itself from the player activation event with the event manager.
local function OnPlayerActivated()
    logger:Debug("EVENT_PLAYER_ACTIVATED - Start")
    --Addon was loaded via EVENT_ADD_ON_LOADED and we are not already doing some EVENT_PLAYER_ACTIVATED tasks
    if pChatData.isAddonLoaded and not eventPlayerActivatedCheckRunning then
        pChatData.sceneFirst = false

        pChat.InitializeChatHandlers()
    end

    --Test if the chat_system containers are given already or wait until they are.
    --Only test 3 seconds, then do the event_player_activated tasks!
    if eventPlayerActivatedChecksDone <= 12 and (CHAT_SYSTEM == nil or CHAT_SYSTEM.primaryContainer == nil) then
        logger:Debug("EVENT_PLAYER_ACTIVATED: CHAT_SYSTEM.primaryContainer is missing!")
        if not eventPlayerActivatedCheckRunning then
            EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Debug_Event_Player_Activated", 250, function()
                eventPlayerActivatedChecksDone = eventPlayerActivatedChecksDone + 1
                eventPlayerActivatedCheckRunning = true
                OnPlayerActivated()
            end)
        end
    else
        logger:Debug("EVENT_PLAYER_ACTIVATED: Found CHAT_SYSTEM.primaryContainer!")
        eventPlayerActivatedCheckRunning = false
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "Debug_Event_Player_Activated")

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
            pChat.SetupChatTabs()

            -- Chat Config setup
            pChat.ApplyChatConfig()

            --Update the guilds custom tags (next to entry box): Add them to the chat channels of table ChannelInfo
            UpdateCharCorrespondanceTableChannelNames()

            --Update the guild's custom channel switches: Add them to the chat switches of table ZO_ChatSystem_GetChannelSwitchLookupTable
            UpdateGuildCorrespondanceTableSwitches()

            -- Handle Copy text
            pChat.InitializeCopyHandler()

            -- Restore History if needed
            pChat.RestoreChatHistory()

            --Do some other checks
            DoPostEventPlayerActivatedChecks()

            -- Set default tab at login
            pChat.SetDefaultTab(db.defaultTab)

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
    --Load Keybind Strings
    pChat.LoadKeybindStrings()

    --Automated message texts
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
    ZO_CreateStringId("PCHAT_AUTOMSG_REMOVE_AUTO_MSG", GetString(PCHAT_PCHAT_AUTOMSG_REMOVE_AUTO_MSG))
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

        --Pointers to pChatData and SavedVariables
        pChat.pChatData = pChatData
        pChat.db = db

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
        pChat.InitializeChatTabs()

        --Load the SV and LAM panel
        db = pChat.InitializeSettings()

        -- set up channel names
        UpdateCharCorrespondanceTableChannelNames()

        -- prepare chat history functionality
        pChat.InitializeChatHistory()

        -- Automated messages
        pChat.InitializeAutomatedMessages()

        --Load some hooks
        LoadHooks()

        -- Initialize Chat Config features
        pChat.InitializeChatConfig()

        pChat.SpamFilter = pChat.InitializeSpamFilter()
        --local FormatMessage, FormatSysMessage = pChat.InitializeMessageFormatters()
        pChat.InitializeMessageFormatters()

        --EVENTS--
        -- Because ChatSystem is loaded after EVENT_ADDON_LOADED triggers, we use 1st EVENT_PLAYER_ACTIVATED wich is run bit after
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED, pChat.OnReticleTargetChanged)

        -- EVENT Unregister
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

        --IM Features
        pChat.InitializeIncomingMessages()

        --Set variable that addon was laoded
        pChatData.isAddonLoaded = true
    end

end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

