--=======================================================================================================================================
--Known problems/bugs:
--Last updated: 2021-11-15
--Total number: 12
------------------------------------------------------------------------------------------------------------------------
--#2	2020-02-28 Baetram, bug: New selection for @accountName/character chat prefix will only show /charactername (@accountName is missing) during whispers,
--		if clicked on a character in the chat to whisper him/her
------------------------------------------------------------------------------------------------------------------------
--#3	2020-03-27 Baetram, bug: Enter into a group with the dungeon finder will not change to the group chat channel /group automatically, if setting is enabled
------------------------------------------------------------------------------------------------------------------------
--#7    2020-06-20 Cutholen, bug: Time stamps are not shown with system messages anymore
--> 2020-09-18: Not fixable at the moment as system message timestamps depend on the used libraries like LibDebugLogger and LibChatMessage etc.
--> Further tests needed
------------------------------------------------------------------------------------------------------------------------
--#9    2020-07-20 Marazota Collectibles linked into chat will not show properly the collectible's link
--link collectibles to chat (especially that one from "Not Collected") + add any word.
--Then right click the message and copy it. The link will be empty (only []shown)
------------------------------------------------------------------------------------------------------------------------
-- #10  2020-07-10 ArtOfShred Message in chat editbox is cutoff if many itemlinks are posted AND the "Copy chat message" option in pChat is enabled.
--Ahah! If I turn of the ability to "enable copy" then it stops the string from being cutoff. What's funny too is with "enable copy" on, if I right click the message in chat
--that is displayed cut off, and copy the line, the full string is copied.
--Example if this displays in chat: <shortened text>
--and then I copy the message and paste I get:
--[19:40:15] You craft [Dwarven Ingot] x33, [Ebony Ingot] x232, [Orichalcum Ingot] x12, [Iron Ingot] x134, [Steel Ingot] x83, [Rubedite Ingot] x91, [Sanded Oak] x91, [Voidstone Ingot] x58, [Quicksilver Ingot] x44, [Galatite Ingot] x73.
------------------------------------------------------------------------------------------------------------------------
--=======================================================================================================================================

--Working on:
--

--=======================================================================================================================================
-- Changelog version: 10.0.2.7 (last version 10.0.2.6)
--=======================================================================================================================================
--Fixed:
--Removed debug messages

--Changed:


--Added:
--Show typed character count at top of chat window (and show max 350 chars info) -> Thanks Coorbin
--Show date & time of last posted zone chat message (for recruiting e.g.) -> Thanks Coorbin

--Added on request:


--=======================================================================================================================================

--  pChat object
pChat = pChat or {}

--======================================================================================================================
-- AddOn Constants
--======================================================================================================================
local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME    = CONSTANTS.ADDON_NAME
local addonNamePrefix = "[" .. ADDON_NAME .. "] "

local EM = EVENT_MANAGER

local strlen = string.len
local strfind = string.find
local strsub = string.sub

--======================================================================================================================
--pChat Variables--
--======================================================================================================================
-- pChatData will receive variables and objects.
local pChatData = {}
-- Logged in char name
pChatData.localPlayer = GetUnitName("player")
-- Logged in @Account name
pChatData.localAccount = GetDisplayName()

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
        logger.verbose:SetEnabled(false)
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

local function migrationInfoOutput(strVar, toChatToo, asAlertToo)
    toChatToo = toChatToo or false
    asAlertToo = asAlertToo or false
    logger:Info(strVar)
    if not logger or toChatToo == true then
        d(addonNamePrefix .. strVar)
    end
    if asAlertToo == true then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.AVA_GATE_OPENED, addonNamePrefix .. strVar)
    end
end
pChat.migrationInfoOutput = migrationInfoOutput

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

--Any tasks open after a SavedVariables migration was done?
local function checkSavedVariablesMigrationTasks()
    local worldName = GetWorldName()
    logger:Debug("SV Migration - Event_Player_Activated -> checkSavedVariablesMigrationTasks")
    --Were SavedVariables migrated from non-server dependent ones?
    --And do we need a reloadui here?
    if pChat.migrationReloadUI ~= nil then
        if pChat.migrationReloadUI == 1 then
            pChat.migrationReloadUI = nil
            db.migrationJustFinished = nil
            logger:Debug("SV Migration - Migration done! RELOADUI1 RELOADUI1 RELOADUI1 RELOADUI1 RELOADUI1")
            ReloadUI()

        elseif pChat.migrationReloadUI == 2 then
            pChat.migrationReloadUI = nil
            db.migrationJustFinished = nil
            logger:Debug("SV Migration - Nothing migrated! RELOADUI1 RELOADUI1 RELOADUI1 RELOADUI1 RELOADUI1")
            ReloadUI()

        elseif pChat.migrationReloadUI == 3 then
            pChat.migrationReloadUI = nil
            db.migrationJustFinished = true
            logger:Debug("SV Migration - Migration finished! RELOADUI2 RELOADUI2 RELOADUI2 RELOADUI2 RELOADUI2 RELOADUI2 RELOADUI2 RELOADUI2 RELOADUI2")
            ReloadUI()
        end
    else
        if db.migratedSVToServer == true and db.migrationJustFinished == true then
            db.migrationJustFinished = nil

            --Migration finished - Output info
            logger:Debug("SV Migration - Wrote SV file to disk for server: \'" ..tostring(worldName) .."\'")
            migrationInfoOutput("Successfully migrated the SavedVariables to the server \'" ..tostring(worldName) .. "\'", true, true)
            migrationInfoOutput(">Non-server dependent SavedVariables for your account \'"..GetDisplayName().."\' can be deleted via the slash command \'/pchatdeleteoldsv\'!", true, false)
            migrationInfoOutput(">Attention: If you want to copy the SVs to another server login to that other server first BEFORE deleting the non-server dependent SavedVariables, because they will be taken as the base to copy!", true, false)
        end
    end
end

-- Registers the formatMessage function.
-- Unregisters itself from the player activation event with the event manager.
local function OnPlayerActivated()
    logger:Debug("EVENT_PLAYER_ACTIVATED - Start")
    --Were SavedVariables migrated from non-server dependent ones?
    --And do we need a reloadui here?
    checkSavedVariablesMigrationTasks()

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
            EM:RegisterForUpdate(ADDON_NAME .. "Debug_Event_Player_Activated", 250, function()
                eventPlayerActivatedChecksDone = eventPlayerActivatedChecksDone + 1
                eventPlayerActivatedCheckRunning = true
                OnPlayerActivated()
            end)
        end
    else
        logger:Debug("EVENT_PLAYER_ACTIVATED: Found CHAT_SYSTEM.primaryContainer!")
        eventPlayerActivatedCheckRunning = false
        EM:UnregisterForUpdate(ADDON_NAME .. "Debug_Event_Player_Activated")

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

            EM:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)

            --Show the backup reminder?
            pChat.ShowBackupReminder()

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

    --Code by Dolgubon, 2020-12-25 -- Delete whole word by using CTRL + backspace
    ZO_PreHookHandler(ZO_ChatWindowTextEntryEditBox, "OnBackspace", function(self)
        if not db.chatEditBoxOnBackspaceHook then return end
        local ctrlPressed = IsControlKeyDown()
        --local deletePressed = IsKeyDown(KEY_DELETE)
        if not ctrlPressed then return end --and not deletePressed then return end

        local text = self:GetText()
        local position = self:GetCursorPosition()
        local beforeOrAfterCursor = strsub(text, 1, position)

        --TODO: Code update needed here to work with DELETE key
        local space= #beforeOrAfterCursor - (strfind(string.reverse(beforeOrAfterCursor), "[% %(\"%']") or #beforeOrAfterCursor)
        local newText = strsub(text, 0, space+1)..strsub(text, #beforeOrAfterCursor+1)
        if space == 0 then
            newText = ""..strsub(text, #beforeOrAfterCursor+1)
        end

        self:SetText(newText)
        self:SetCursorPosition(space+1)
    end)

end

--Load the string IDs for keybindings e.g.
local function LoadStringIds()
    --Load Keybind Strings
    pChat.LoadKeybindStrings()

    --Automated message texts
    --[[
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
    ]]
end

--Load the slash commands
local function LoadSlashCommands()
    -- Register Slash commands
    SLASH_COMMANDS["/msg"] = pChat_ShowAutoMsg

    -- Coorbin20200708 Chat mentions
    local cm = pChat.ChatMentions
    SLASH_COMMANDS["/cmadd"] = cm.cm_add
    SLASH_COMMANDS["/cmdel"] = cm.cm_del
    SLASH_COMMANDS["/cmlist"] = cm.cm_print_list
    SLASH_COMMANDS["/cmwatch"] = cm.cm_watch_toggle

    local function pChatDeleteOldNonServerDependentSVForAccount(argu)
        local ADDON_SV_NAME     = CONSTANTS["ADDON_SV_NAME"]
 	    local ADDON_SV_VERSION  = CONSTANTS["ADDON_SV_VERSION"]

        local displayName = GetDisplayName()
        migrationInfoOutput("Looking for old non-server dependent SavedVariables of account \'".. displayName .."\'....", true, false)
        local dbOld = ZO_SavedVars:NewAccountWide(ADDON_SV_NAME, ADDON_SV_VERSION, nil, nil, nil, nil)
--pChat._dbOld = dbOld
        --Do the old SV exist with recently new pChat data?
        if dbOld ~= nil and dbOld.colours ~= nil then
            local dbOldNonServerDependent = _G[ADDON_SV_NAME]["Default"][displayName]["$AccountWide"]
            --pChat._dbOldNonServerDependent = dbOldNonServerDependent
            if dbOldNonServerDependent ~= nil then
                _G[ADDON_SV_NAME]["Default"][displayName]["$AccountWide"] = nil
                dbOldNonServerDependent = nil
                migrationInfoOutput("Successfully deleted the old, non-server dependent SavedVariables of account \'"..displayName.."\'.", true, true)
                migrationInfoOutput(">A reloadUI saves the changes to disk in 3 seconds...", true, true)
                zo_callLater(function()
                    ReloadUI("ingame")
                    logger:Debug("SV Delete - Old non-server data deleted! RELOADUI1_old RELOADUI1a RELOADUI1_old RELOADUI1_old RELOADUI1_old")
                end, 3000)
        end
        else
            migrationInfoOutput("No non-server dependent SavedVariables found for account \'"..displayName.."\'!", true, true)
        end
    end
    SLASH_COMMANDS["/pchatdeleteoldsv"] = pChatDeleteOldNonServerDependentSVForAccount
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

        --Load the dialogs
        pChat.LoadDialogs()

        -- set up channel names
        UpdateCharCorrespondanceTableChannelNames()

        -- prepare chat history functionality
        pChat.InitializeChatHistory()

        -- Automated messages
        pChat.InitializeAutomatedMessages()

        --Load some hooks
        LoadHooks()

        -- Coorbin20200708
        -- Initialize Chat Mentions
        local cm = pChat.ChatMentions
        cm.cm_initChatMentionsEngine()
        cm.cm_loadRegexes()

        -- Initialize Chat Config features
        pChat.InitializeChatConfig()

        pChat.SpamFilter = pChat.InitializeSpamFilter()
        --local FormatMessage, FormatSysMessage = pChat.InitializeMessageFormatters()
        pChat.InitializeMessageFormatters()

        --EVENTS--
        -- Because ChatSystem is loaded after EVENT_ADDON_LOADED triggers, we use 1st EVENT_PLAYER_ACTIVATED wich is run bit after
        EM:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        EM:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED, pChat.OnReticleTargetChanged)

        -- EVENT Unregister
        EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

        --IM Features
        pChat.InitializeIncomingMessages()

        --Set variable that addon was laoded
        pChatData.isAddonLoaded = true
    end

end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

