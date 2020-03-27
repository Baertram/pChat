function pChat.InitializeSettings(pChatData, ADDON_NAME, PCHAT_CHANNEL_NONE, getTabNames, UpdateCharCorrespondanceTableChannelNames, ConvertHexToRGBA, ConvertRGBToHex, AddCustomChannelSwitches, RemoveCustomChannelSwitches, logger)

    local ADDON_VERSION = "9.4.1.5"
    local ADDON_AUTHOR  = "Ayantir, DesertDwellers, Baertram (current)"
    local ADDON_WEBSITE = "http://www.esoui.com/downloads/info93-pChat.html"

    local db
    -- Default variables to push in SavedVars
    local defaults = {
        -- LAM handled
        showGuildNumbers = false,
        allGuildsSameColour = false,
        allZonesSameColour = true,
        allNPCSameColour = true,
        delzonetags = true,
        carriageReturn = false,
        alwaysShowChat = false,
        augmentHistoryBuffer = true,
        oneColour = false,
        showTagInEntry = true,
        showTimestamp = true,
        timestampcolorislcol = false,
        useESOcolors = true,
        diffforESOcolors = 40,
        timestampFormat = "HH:m",
        guildTags = {},
        officertag = {},
        switchFor = {},
        officerSwitchFor = {},
        formatguild = {},
        defaultchannel = CHAT_CHANNEL_GUILD_1,
        soundforincwhisps = SOUNDS.NEW_NOTIFICATION,
        notifyIMIndex = 1, -- SOUNDS.NONE
        enablecopy = true,
        enableChatTabChannel = true,
        enablepartyswitch = true,
        enableWhisperTab = false,
        groupLeader = false,
        disableBrackets = true,
        chatMinimizedAtLaunch = false,
        chatMinimizedInMenus = false,
        chatMaximizedAfterMenus = false,
        windowDarkness = 6,
        chatSyncConfig = true,
        floodProtect = true,
        floodGracePeriod = 30,
        lookingForProtect = false,
        wantToProtect = false,
        restoreOnReloadUI = true,
        restoreOnLogOut = true,
        restoreOnQuit = false,
        restoreOnAFK = true,
        restoreSystem = true,
        restoreSystemOnly = false,
        restoreWhisps = true,
        restoreTextEntryHistoryAtLogOutQuit = false,
        addChannelAndTargetToHistory = true,
        timeBeforeRestore = 2,
        notifyIM = false,
        nicknames = "",
        defaultTab = 1,
        defaultTabName = "",
        groupNames = 1,
        geoChannelsFormat = 2,
        urlHandling = true,
        -- guildRecruitProtect = false,
        spamGracePeriod = 5,
        fonts = "ESO Standard Font",
        colours =
        {
            [2*CHAT_CHANNEL_SAY] = "|cFFFFFF", -- say Left
            [2*CHAT_CHANNEL_SAY + 1] = "|cFFFFFF", -- say Right
            [2*CHAT_CHANNEL_YELL] = "|cE974D8", -- yell Left
            [2*CHAT_CHANNEL_YELL + 1] = "|cFFB5F4", -- yell Right
            [2*CHAT_CHANNEL_WHISPER] = "|cB27BFF", -- tell in Left
            [2*CHAT_CHANNEL_WHISPER + 1] = "|cB27BFF", -- tell in Right
            [2*CHAT_CHANNEL_PARTY] = "|c6EABCA", -- group Left
            [2*CHAT_CHANNEL_PARTY + 1] = "|cA1DAF7", -- group Right
            [2*CHAT_CHANNEL_WHISPER_SENT] = "|c7E57B5", -- tell out Left
            [2*CHAT_CHANNEL_WHISPER_SENT + 1] = "|c7E57B5", -- tell out Right
            [2*CHAT_CHANNEL_EMOTE] = "|cA5A5A5", -- emote Left
            [2*CHAT_CHANNEL_EMOTE + 1] = "|cA5A5A5", -- emote Right
            [2*CHAT_CHANNEL_MONSTER_SAY] = "|c879B7D", -- npc Left
            [2*CHAT_CHANNEL_MONSTER_SAY + 1] = "|c879B7D", -- npc Right
            [2*CHAT_CHANNEL_MONSTER_YELL] = "|c879B7D", -- npc yell Left
            [2*CHAT_CHANNEL_MONSTER_YELL + 1] = "|c879B7D", -- npc yell Right
            [2*CHAT_CHANNEL_MONSTER_WHISPER] = "|c879B7D", -- npc whisper Left
            [2*CHAT_CHANNEL_MONSTER_WHISPER + 1] = "|c879B7D", -- npc whisper Right
            [2*CHAT_CHANNEL_MONSTER_EMOTE] = "|c879B7D", -- npc emote Left
            [2*CHAT_CHANNEL_MONSTER_EMOTE + 1] = "|c879B7D", -- npc emote Right
            [2*CHAT_CHANNEL_GUILD_1] = "|c94E193", -- guild Left
            [2*CHAT_CHANNEL_GUILD_1 + 1] = "|cC3F0C2", -- guild Right
            [2*CHAT_CHANNEL_GUILD_2] = "|c94E193",
            [2*CHAT_CHANNEL_GUILD_2 + 1] = "|cC3F0C2",
            [2*CHAT_CHANNEL_GUILD_3] = "|c94E193",
            [2*CHAT_CHANNEL_GUILD_3 + 1] = "|cC3F0C2",
            [2*CHAT_CHANNEL_GUILD_4] = "|c94E193",
            [2*CHAT_CHANNEL_GUILD_4 + 1] = "|cC3F0C2",
            [2*CHAT_CHANNEL_GUILD_5] = "|c94E193",
            [2*CHAT_CHANNEL_GUILD_5 + 1] = "|cC3F0C2",
            [2*CHAT_CHANNEL_OFFICER_1] = "|cC3F0C2", -- guild officers Left
            [2*CHAT_CHANNEL_OFFICER_1 + 1] = "|cC3F0C2", -- guild officers Right
            [2*CHAT_CHANNEL_OFFICER_2] = "|cC3F0C2",
            [2*CHAT_CHANNEL_OFFICER_2 + 1] = "|cC3F0C2",
            [2*CHAT_CHANNEL_OFFICER_3] = "|cC3F0C2",
            [2*CHAT_CHANNEL_OFFICER_3 + 1] = "|cC3F0C2",
            [2*CHAT_CHANNEL_OFFICER_4] = "|cC3F0C2",
            [2*CHAT_CHANNEL_OFFICER_4 + 1] = "|cC3F0C2",
            [2*CHAT_CHANNEL_OFFICER_5] = "|cC3F0C2",
            [2*CHAT_CHANNEL_OFFICER_5 + 1] = "|cC3F0C2",
            [2*CHAT_CHANNEL_ZONE] = "|cCEB36F", -- zone Left
            [2*CHAT_CHANNEL_ZONE + 1] = "|cB0A074", -- zone Right
            [2*CHAT_CHANNEL_ZONE_LANGUAGE_1] = "|cCEB36F", -- EN zone Left
            [2*CHAT_CHANNEL_ZONE_LANGUAGE_1 + 1] = "|cB0A074", -- EN zone Right
            [2*CHAT_CHANNEL_ZONE_LANGUAGE_2] = "|cCEB36F", -- FR zone Left
            [2*CHAT_CHANNEL_ZONE_LANGUAGE_2 + 1] = "|cB0A074", -- FR zone Right
            [2*CHAT_CHANNEL_ZONE_LANGUAGE_3] = "|cCEB36F", -- DE zone Left
            [2*CHAT_CHANNEL_ZONE_LANGUAGE_3 + 1] = "|cB0A074", -- DE zone Right
            [2*CHAT_CHANNEL_ZONE_LANGUAGE_4] = "|cCEB36F", -- JP zone Left
            [2*CHAT_CHANNEL_ZONE_LANGUAGE_4 + 1] = "|cB0A074", -- JP zone Right
            ["timestamp"] = "|c8F8F8F", -- timestamp
            ["tabwarning"] = "|c76BCC3", -- tab Warning ~ "Azure" (ZOS default)
            ["groupleader"] = "|cC35582", --
            ["groupleader1"] = "|c76BCC3", --
        },
        doNotNotifyOnRestoredWhisperFromHistory = false,
        addHistoryRestoredPrefix = false,
        -- Not LAM
        chatConfSync = {},
    }

    --Load the nicknames defined in the settings and build the pChatData nicknames table with them
    local function BuildNicknames(lamCall)

        local function Explode(div, str)
            if (div=='') then return false end
            local pos,arr = 0,{}
            for st,sp in function() return string.find(str,div,pos,true) end do
                table.insert(arr,string.sub(str,pos,st-1))
                pos = sp + 1
            end
            table.insert(arr,string.sub(str,pos))
            return arr
        end

        pChatData.nicknames = {}

        if db.nicknames ~= "" then
            local lines = Explode("\n", db.nicknames)

            for lineIndex=#lines, 1, -1 do
                local oldName, newName = string.match(lines[lineIndex], "(@?[%w_-]+) ?= ?([%w- ]+)")
                if not (oldName and newName) then
                    table.remove(lines, lineIndex)
                else
                    pChatData.nicknames[oldName] = newName
                end
            end

            db.nicknames = table.concat(lines, "\n")

            if lamCall then
                CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", pChat.LAMPanel)
            end

        end

    end

    -- Character Sync
    local function SyncCharacterSelectChoices()
        -- Sync Character Select
        pChatData.chatConfSyncChoices = {}
        pChatData.chatConfSyncChoicesCharIds = {}
        if db.chatConfSync then
            for charId, _ in pairs (db.chatConfSync) do
                if charId ~= "lastChar" then
                    local nameOfCharId = pChat.characterId2Name[charId]
                    if charId and nameOfCharId then
                        table.insert(pChatData.chatConfSyncChoices, nameOfCharId)
                        table.insert(pChatData.chatConfSyncChoicesCharIds, charId)
                    end
                end
            end
        else
            table.insert(pChatData.chatConfSyncChoices, pChatData.localPlayer)
            table.insert(pChatData.chatConfSyncChoicesCharIds, GetCurrentCharacterId())
        end
    end

    -- Build LAM Option Table, used when AddonLoads or when a player join/leave a guild
    local function BuildLAMPanel()

        local function UpdateSoundDescription(soundType, newSoundIndex)
            --Whisper sound
            if soundType == "whisper" then
                newSoundIndex = newSoundIndex or db.notifyIMIndex
                pChatLAMWhisperSoundSlider.label:SetText(GetString(PCHAT_SOUNDFORINCWHISPS) .. ": " .. tostring(pChat.sounds[newSoundIndex]))
            end
        end

        --LAM 2.0 callback function if the panel was created
        local pChatLAMPanelCreated = function(panel)
            if panel == pChat.LAMPanel then
                UpdateSoundDescription("whisper")
            end
        end
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", pChatLAMPanelCreated)


        -- Used to reset colors to default value, lam need a formatted array
        -- LAM Message Settings
        local charId = GetCurrentCharacterId()

        local fontsDefined = LibMediaProvider:List('font')

        local function ConvertHexToRGBAPacked(colourString)
            local r, g, b, a = ConvertHexToRGBA(colourString)
            return {r = r, g = g, b = b, a = a}
        end

        SyncCharacterSelectChoices()

        -- CHAT_SYSTEM.primaryContainer.windows doesn't exists yet at OnAddonLoaded. So using the pChat reference.
        local arrayTab = {}
        if db.chatConfSync and db.chatConfSync[charId] and db.chatConfSync[charId].tabs then
            for numTab, data in pairs (db.chatConfSync[charId].tabs) do
                table.insert(arrayTab, numTab)
            end
        else
            table.insert(arrayTab, 1)
        end

        getTabNames()


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
        local optionsData = {}

        -- Messages Settings
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_OPTIONSH),
            controls = {
                {-- LAM Option Show Guild Numbers
                    type = "checkbox",
                    name = GetString(PCHAT_GUILDNUMBERS),
                    tooltip = GetString(PCHAT_GUILDNUMBERSTT),
                    getFunc = function() return db.showGuildNumbers end,
                    setFunc = function(newValue)
                        db.showGuildNumbers = newValue
                    end,
                    width = "full",
                    default = defaults.showGuildNumbers,
                },
                {-- LAM Option Use Same Color for all Guilds
                    type = "checkbox",
                    name = GetString(PCHAT_ALLGUILDSSAMECOLOUR),
                    tooltip = GetString(PCHAT_ALLGUILDSSAMECOLOURTT),
                    getFunc = function() return db.allGuildsSameColour end,
                    setFunc = function(newValue) db.allGuildsSameColour = newValue end,
                    width = "full",
                    default = defaults.allGuildsSameColour,
                },
                {-- LAM Option Use same color for all zone chats
                    type = "checkbox",
                    name = GetString(PCHAT_ALLZONESSAMECOLOUR),
                    tooltip = GetString(PCHAT_ALLZONESSAMECOLOURTT),
                    getFunc = function() return db.allZonesSameColour end,
                    setFunc = function(newValue) db.allZonesSameColour = newValue end,
                    width = "full",
                    default = defaults.allZonesSameColour,
                },
                {-- LAM Option Use same color for all NPC
                    type = "checkbox",
                    name = GetString(PCHAT_ALLNPCSAMECOLOUR),
                    tooltip = GetString(PCHAT_ALLNPCSAMECOLOURTT),
                    getFunc = function() return db.allNPCSameColour end,
                    setFunc = function(newValue) db.allNPCSameColour = newValue end,
                    width = "full",
                    default = defaults.allNPCSameColour,
                },
                {-- LAM Option Remove Zone Tags
                    type = "checkbox",
                    name = GetString(PCHAT_DELZONETAGS),
                    tooltip = GetString(PCHAT_DELZONETAGSTT),
                    getFunc = function() return db.delzonetags end,
                    setFunc = function(newValue) db.delzonetags = newValue end,
                    width = "full",
                    default = defaults.delzonetags,
                },
                {-- LAM Option Newline between name and message
                    type = "checkbox",
                    name = GetString(PCHAT_CARRIAGERETURN),
                    tooltip = GetString(PCHAT_CARRIAGERETURNTT),
                    getFunc = function() return db.carriageReturn end,
                    setFunc = function(newValue) db.carriageReturn = newValue end,
                    width = "full",
                    default = defaults.carriageReturn,
                },
                {-- LAM Option Use ESO Colors
                    type = "checkbox",
                    name = GetString(PCHAT_USEESOCOLORS),
                    tooltip = GetString(PCHAT_USEESOCOLORSTT),
                    getFunc = function() return db.useESOcolors end,
                    setFunc = function(newValue) db.useESOcolors = newValue end,
                    width = "full",
                    default = defaults.useESOcolors,
                },
                {-- LAM Option Difference Between ESO Colors
                    type = "slider",
                    name = GetString(PCHAT_DIFFFORESOCOLORS),
                    tooltip = GetString(PCHAT_DIFFFORESOCOLORSTT),
                    min = 0,
                    max = 100,
                    step = 1,
                    getFunc = function() return db.diffforESOcolors end,
                    setFunc = function(newValue) db.diffforESOcolors = newValue end,
                    width = "full",
                    default = defaults.diffforESOcolors,
                    disabled = function() return not db.useESOcolors end,
                },
                {-- LAM Option Prevent Chat Fading
                    type = "checkbox",
                    name = GetString(PCHAT_PREVENTCHATTEXTFADING),
                    tooltip = GetString(PCHAT_PREVENTCHATTEXTFADINGTT),
                    getFunc = function() return db.alwaysShowChat end,
                    setFunc = function(newValue) db.alwaysShowChat = newValue end,
                    width = "full",
                    default = defaults.alwaysShowChat,
                },
                {-- Augment lines of chat
                    type = "checkbox",
                    name = GetString(PCHAT_AUGMENTHISTORYBUFFER),
                    tooltip = GetString(PCHAT_AUGMENTHISTORYBUFFERTT),
                    getFunc = function() return db.augmentHistoryBuffer end,
                    setFunc = function(newValue) db.augmentHistoryBuffer = newValue end,
                    width = "full",
                    default = defaults.augmentHistoryBuffer,
                },
                {-- LAM Option Use one color for lines
                    type = "checkbox",
                    name = GetString(PCHAT_USEONECOLORFORLINES),
                    tooltip = GetString(PCHAT_USEONECOLORFORLINESTT),
                    getFunc = function() return db.oneColour end,
                    setFunc = function(newValue) db.oneColour = newValue end,
                    width = "full",
                    default = defaults.oneColour,
                },
                {-- LAM Option Guild Tags next to entry box
                    type = "checkbox",
                    name = GetString(PCHAT_GUILDTAGSNEXTTOENTRYBOX),
                    tooltip = GetString(PCHAT_GUILDTAGSNEXTTOENTRYBOXTT),
                    width = "full",
                    default = defaults.showTagInEntry,
                    getFunc = function() return db.showTagInEntry end,
                    setFunc = function(newValue)
                        db.showTagInEntry = newValue
                        UpdateCharCorrespondanceTableChannelNames()
                    end
                },
                {-- LAM Option Names Format
                    type = "dropdown",
                    name = GetString(PCHAT_GEOCHANNELSFORMAT),
                    tooltip = GetString(PCHAT_GEOCHANNELSFORMATTT),
                    choices = {GetString(PCHAT_FORMATCHOICE1), GetString(PCHAT_FORMATCHOICE2), GetString(PCHAT_FORMATCHOICE3), GetString(PCHAT_FORMATCHOICE4)},
                    choicesValues = {1, 2, 3, 4},
                    width = "full",
                    getFunc = function() return db.geoChannelsFormat end,
                    setFunc = function(value)
                        db.geoChannelsFormat = value
                    end,
                    default = defaults.geoChannelsFormat,

                },
                {-- Disable Brackets
                    type = "checkbox",
                    name = GetString(PCHAT_DISABLEBRACKETS),
                    tooltip = GetString(PCHAT_DISABLEBRACKETSTT),
                    getFunc = function() return db.disableBrackets end,
                    setFunc = function(newValue) db.disableBrackets = newValue end,
                    width = "full",
                    default = defaults.disableBrackets,
                },
                {--Target History
                    type = "checkbox",
                    name = GetString(PCHAT_ADDCHANNELANDTARGETTOHISTORY),
                    tooltip = GetString(PCHAT_ADDCHANNELANDTARGETTOHISTORYTT),
                    getFunc = function() return db.addChannelAndTargetToHistory end,
                    setFunc = function(newValue) db.addChannelAndTargetToHistory = newValue end,
                    width = "full",
                    default = defaults.addChannelAndTargetToHistory,
                },
                {-- URL is clickable
                    type = "checkbox",
                    name = GetString(PCHAT_URLHANDLING),
                    tooltip = GetString(PCHAT_URLHANDLINGTT),
                    getFunc = function() return db.urlHandling end,
                    setFunc = function(newValue) db.urlHandling = newValue end,
                    width = "full",
                    default = defaults.urlHandling,
                },
                {-- Copy Chat
                    type = "checkbox",
                    name = GetString(PCHAT_ENABLECOPY),
                    tooltip = GetString(PCHAT_ENABLECOPYTT),
                    getFunc = function() return db.enablecopy end,
                    setFunc = function(newValue) db.enablecopy = newValue end,
                    width = "full",
                    default = defaults.enablecopy,
                },--
            },
        } -- Chat Tabs
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_CHATTABH),
            controls = {
                {-- Enable chat channel memory
                    type = "checkbox",
                    name = GetString(PCHAT_enableChatTabChannel),
                    tooltip = GetString(PCHAT_enableChatTabChannelT),
                    getFunc = function() return db.enableChatTabChannel end,
                    setFunc = function(newValue) db.enableChatTabChannel = newValue end,
                    width = "full",
                    default = defaults.enableChatTabChannel,
                },
                {-- TODO : optimize
                    type = "dropdown",
                    name = GetString(PCHAT_DEFAULTCHANNEL),
                    tooltip = GetString(PCHAT_DEFAULTCHANNELTT),
                    --choices = chatTabNames,
                    choices = {
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", PCHAT_CHANNEL_NONE),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_ZONE),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_SAY),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_1),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_2),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_3),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_4),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_5),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_1),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_2),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_3),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_4),
                        GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_5)
                    },
                    width = "full",
                    default = defaults.defaultchannel,
                    getFunc = function() return GetString("PCHAT_DEFAULTCHANNELCHOICE", db.defaultchannel) end,
                    setFunc = function(choice)
                        if choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_ZONE) then
                            db.defaultchannel = CHAT_CHANNEL_ZONE
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_SAY) then
                            db.defaultchannel = CHAT_CHANNEL_SAY
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_1) then
                            db.defaultchannel = CHAT_CHANNEL_GUILD_1
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_2) then
                            db.defaultchannel = CHAT_CHANNEL_GUILD_2
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_3) then
                            db.defaultchannel = CHAT_CHANNEL_GUILD_3
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_4) then
                            db.defaultchannel = CHAT_CHANNEL_GUILD_4
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_5) then
                            db.defaultchannel = CHAT_CHANNEL_GUILD_5
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_1) then
                            db.defaultchannel = CHAT_CHANNEL_OFFICER_1
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_2) then
                            db.defaultchannel = CHAT_CHANNEL_OFFICER_2
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_3) then
                            db.defaultchannel = CHAT_CHANNEL_OFFICER_3
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_4) then
                            db.defaultchannel = CHAT_CHANNEL_OFFICER_4
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_5) then
                            db.defaultchannel = CHAT_CHANNEL_OFFICER_5
                        elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", PCHAT_CHANNEL_NONE) then
                            db.defaultchannel = PCHAT_CHANNEL_NONE
                        else
                            -- When user click on LAM reinit button
                            db.defaultchannel = defaults.defaultchannel
                        end

                    end,
                },
                {-- CHAT_SYSTEM.primaryContainer.windows doesn't exists yet at OnAddonLoaded. So using the pChat reference.
                    type = "dropdown",
                    name = GetString(PCHAT_DEFAULTTAB),
                    tooltip = GetString(PCHAT_DEFAULTTABTT),
                    choices = pChat.tabNames,
                    width = "full",
                    getFunc = function() return db.defaultTabName end,
                    setFunc =   function(choice)
                        db.defaultTabName = choice
                        --logger:Debug(choice)
                        --logger:Debug(db.defaultTabName)
                        db.defaultTab = getTabIdx(choice)
                        --logger:Debug(db.defaultTab)
                    end,
                },
            --{-- CHAT_SYSTEM.primaryContainer.windows doesn't exists yet at OnAddonLoaded. So using the pChat reference.
            --    type = "dropdown",
            --    name = GetString(PCHAT_DEFAULTTAB),
            --    tooltip = GetString(PCHAT_DEFAULTTABTT),
            --    choices = arrayTab,
            --    width = "full",
            --    default = defaults.defaultTab,
            --    getFunc = function() return db.defaultTab end,
            --    setFunc = function(choice) db.defaultTab = choice end,
            --},
            --{-- Enable whisper redirect
            --    type = "checkbox",
            --    name = GetString(PCHAT_enableWhisperTab),
            --    tooltip = GetString(PCHAT_enableWhisperTabT),
            --    getFunc = function() return db.enableWhisperTab end,
            --    setFunc = function(newValue) db.enableWhisperTab = newValue end,
            --    width = "full",
            --    default = defaults.enableWhisperTab,
            --},
            -- !!!!!need code for specific tab here
            },
        } -- Group Submenu
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_GROUPH),
            controls = {
                {-- Enable Party Switch
                    type = "checkbox",
                    name = GetString(PCHAT_ENABLEPARTYSWITCH),
                    tooltip = GetString(PCHAT_ENABLEPARTYSWITCHTT),
                    getFunc = function() return db.enablepartyswitch end,
                    setFunc = function(newValue) db.enablepartyswitch = newValue end,
                    width = "full",
                    default = defaults.enablepartyswitch,
                },
                {-- Group Leader
                    type = "checkbox",
                    name = GetString(PCHAT_GROUPLEADER),
                    tooltip = GetString(PCHAT_GROUPLEADERTT),
                    getFunc = function() return db.groupLeader end,
                    setFunc = function(newValue) db.groupLeader = newValue end,
                    width = "full",
                    default = defaults.groupLeader,
                },
                {-- Group Leader Color
                    type = "colorpicker",
                    name = GetString(PCHAT_GROUPLEADERCOLOR),
                    tooltip = GetString(PCHAT_GROUPLEADERCOLORTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours["groupleader"]) end,
                    setFunc = function(r, g, b) db.colours["groupleader"] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours["groupleader"]),
                    disabled = function() return not db.groupLeader end,
                },
                {-- Group Leader Coor 2
                    type = "colorpicker",
                    name = GetString(PCHAT_GROUPLEADERCOLOR1),
                    tooltip = GetString(PCHAT_GROUPLEADERCOLOR1TT),
                    getFunc = function() return ConvertHexToRGBA(db.colours["groupleader1"]) end,
                    setFunc = function(r, g, b) db.colours["groupleader1"] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours["groupleader1"]),
                    disabled = function()
                        if not db.groupLeader then
                            return true
                        elseif db.useESOcolors then
                            return true
                        else
                            return false
                        end
                    end,
                },
                {-- Group Names
                    type = "dropdown",
                    name = GetString(PCHAT_GROUPNAMES),
                    tooltip = GetString(PCHAT_GROUPNAMESTT),
                    choices = {GetString(PCHAT_FORMATCHOICE1), GetString(PCHAT_FORMATCHOICE2), GetString(PCHAT_FORMATCHOICE3), GetString(PCHAT_FORMATCHOICE4)},
                    choicesValues = {1, 2, 3, 4},
                    width = "full",
                    getFunc = function() return db.groupNames end,
                    setFunc = function(value)
                        db.groupNames = value
                    end,
                    default = defaults.groupNames,
                },
            },
        } -- Sync Settings Header
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_SYNCH),
            controls = {
                {-- Sync ON
                    type = "checkbox",
                    name = GetString(PCHAT_CHATSYNCCONFIG),
                    tooltip = GetString(PCHAT_CHATSYNCCONFIGTT),
                    getFunc = function() return db.chatSyncConfig end,
                    setFunc = function(newValue) db.chatSyncConfig = newValue end,
                    width = "full",
                    default = defaults.chatSyncConfig,
                },
                {-- Config Import From
                    type = "dropdown",
                    name = GetString(PCHAT_CHATSYNCCONFIGIMPORTFROM),
                    tooltip = GetString(PCHAT_CHATSYNCCONFIGIMPORTFROMTT),
                    choices = pChatData.chatConfSyncChoices,
                    choicesValues = pChatData.chatConfSyncChoicesCharIds,
                    sort = "name-up",
                    scrollable = true,
                    width = "full",
                    getFunc = function() return GetCurrentCharacterId() end,
                    setFunc = function(charId)
                        pChat.SyncChatConfig(true, charId)
                    end,
                },
            },
        } -- Mouse
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_APPARENCEMH),
            controls = {
                {-- New Message Color
                    type = "colorpicker",
                    name = GetString(PCHAT_TABWARNING),
                    tooltip = GetString(PCHAT_TABWARNINGTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours["tabwarning"]) end,
                    setFunc = function(r, g, b) db.colours["tabwarning"] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours["tabwarning"]),
                },
                {-- Chat Window Transparency
                    type = "slider",
                    name = GetString(PCHAT_WINDOWDARKNESS),
                    tooltip = GetString(PCHAT_WINDOWDARKNESSTT),
                    min = 0,
                    max = 11,
                    step = 1,
                    getFunc = function() return db.windowDarkness end,
                    setFunc = function(newValue)
                        db.windowDarkness = newValue
                        pChat.ChangeChatWindowDarkness()
                        CHAT_SYSTEM:Maximize()
                    end,
                    width = "full",
                    default = defaults.windowDarkness,
                },
                {-- Minimize at luanch
                    type = "checkbox",
                    name = GetString(PCHAT_CHATMINIMIZEDATLAUNCH),
                    tooltip = GetString(PCHAT_CHATMINIMIZEDATLAUNCHTT),
                    getFunc = function() return db.chatMinimizedAtLaunch end,
                    setFunc = function(newValue) db.chatMinimizedAtLaunch = newValue end,
                    width = "full",
                    default = defaults.chatMinimizedAtLaunch,
                },
                {-- Minimize Menues
                    type = "checkbox",
                    name = GetString(PCHAT_CHATMINIMIZEDINMENUS),
                    tooltip = GetString(PCHAT_CHATMINIMIZEDINMENUSTT),
                    getFunc = function() return db.chatMinimizedInMenus end,
                    setFunc = function(newValue) db.chatMinimizedInMenus = newValue end,
                    width = "full",
                    default = defaults.chatMinimizedInMenus,
                },
                { -- Mximize After Menus
                    type = "checkbox",
                    name = GetString(PCHAT_CHATMAXIMIZEDAFTERMENUS),
                    tooltip = GetString(PCHAT_CHATMAXIMIZEDAFTERMENUSTT),
                    getFunc = function() return db.chatMaximizedAfterMenus end,
                    setFunc = function(newValue) db.chatMaximizedAfterMenus = newValue end,
                    width = "full",
                    default = defaults.chatMaximizedAfterMenus,
                },
                { -- Fonts
                    type = "dropdown",
                    name = GetString(PCHAT_FONTCHANGE),
                    tooltip = GetString(PCHAT_FONTCHANGETT),
                    choices = fontsDefined,
                    width = "full",
                    getFunc = function() return db.fonts end,
                    setFunc = function(choice)
                        db.fonts = choice
                        pChat.ChangeChatFont(true)
                        ReloadUI()
                    end,
                    default = defaults.fontChange,
                    warning = "ReloadUI"
                },
            },
        } -- LAM Menu Whispers
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_IMH),
            controls = {
                --{-- LAM Option Whispers: Sound
                --    type = "dropdown",
                --    name = GetString(PCHAT_SOUNDFORINCWHISPS),
                --    tooltip = GetString(PCHAT_SOUNDFORINCWHISPSTT),
                --    choices = {
                --        GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 1),
                --        GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 2),
                --        GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 3),
                --        GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 4),
                --        },
                --    width = "full",
                --    default = defaults.soundforincwhisps, --> SOUNDS.NEW_NOTIFICATION
                --    getFunc = function()
                --        if db.soundforincwhisps == SOUNDS.NONE then
                --            return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 1)
                --        elseif db.soundforincwhisps == SOUNDS.NEW_NOTIFICATION then
                --            return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 2)
                --        elseif db.soundforincwhisps == SOUNDS.DEFAULT_CLICK then
                --            return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 3)
                --        elseif db.soundforincwhisps == SOUNDS.EDIT_CLICK then
                --            return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 4)
                --        else
                --            return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 2)
                --        end
                --    end,
                --    setFunc = function(choice)
                --        if choice == GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 1) then
                --            db.soundforincwhisps = SOUNDS.NONE
                --            PlaySound(SOUNDS.NONE)
                --        elseif choice == GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 2) then
                --            db.soundforincwhisps = SOUNDS.NEW_NOTIFICATION
                --            PlaySound(SOUNDS.NEW_NOTIFICATION)
                --        elseif choice == GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 3) then
                --            db.soundforincwhisps = SOUNDS.DEFAULT_CLICK
                --            PlaySound(SOUNDS.DEFAULT_CLICK)
                --        elseif choice == GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 4) then
                --            db.soundforincwhisps = SOUNDS.EDIT_CLICK
                --            PlaySound(SOUNDS.EDIT_CLICK)
                --        else
                --            -- When clicking on LAM default button
                --            db.soundforincwhisps = defaults.soundforincwhisps
                --        end
                --    end,
                --},
                {-- -- LAM Option Whisper: Notification by sound slider
                    type = "slider",
                    name = GetString(PCHAT_SOUNDFORINCWHISPS),
                    tooltip = GetString(PCHAT_SOUNDFORINCWHISPSTT),
                    getFunc = function() return db.notifyIMIndex end,
                    setFunc = function(newIndexValue)
                        db.notifyIMIndex = newIndexValue
                        local soundName = pChat.sounds[newIndexValue]
                        if newIndexValue ~= 1 then
                            if soundName and SOUNDS and SOUNDS[soundName] then
                                PlaySound(SOUNDS[soundName])
                            end
                        end
                        --Update the label to show the sound name
                        UpdateSoundDescription("whisper", newIndexValue)
                    end,
                    width = "full",
                    step = 1,
                    min = 1,
                    max = #pChat.sounds,
                    default = defaults.notifyIMIndex,
                    reference = "pChatLAMWhisperSoundSlider",
                },

                {-- -- LAM Option Whisper: Visual Notification
                    type = "checkbox",
                    name = GetString(PCHAT_NOTIFYIM),
                    tooltip = GetString(PCHAT_NOTIFYIMTT),
                    getFunc = function() return db.notifyIM end,
                    setFunc = function(newValue) db.notifyIM = newValue end,
                    width = "full",
                    default = defaults.notifyIM,
                },
            },
        }-- LAM Menu Restore Chat
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_RESTORECHATH),
            controls = {
                {-- LAM Option Restore: Add prefix [H] for restored messages
                    type = "checkbox",
                    name = GetString(PCHAT_RESTOREPREFIX),
                    tooltip = GetString(PCHAT_RESTOREPREFIXTT),
                    getFunc = function() return db.addHistoryRestoredPrefix end,
                    setFunc = function(newValue) db.addHistoryRestoredPrefix = newValue end,
                    width = "full",
                    default = defaults.addHistoryRestoredPrefix,
                },
                {-- LAM Option Restore: After ReloadUI
                    type = "checkbox",
                    name = GetString(PCHAT_RESTOREONRELOADUI),
                    tooltip = GetString(PCHAT_RESTOREONRELOADUITT),
                    getFunc = function() return db.restoreOnReloadUI end,
                    setFunc = function(newValue) db.restoreOnReloadUI = newValue end,
                    width = "full",
                    default = defaults.restoreOnReloadUI,
                },
                {-- LAM Option Restore: Logout
                    type = "checkbox",
                    name = GetString(PCHAT_RESTOREONLOGOUT),
                    tooltip = GetString(PCHAT_RESTOREONLOGOUTTT),
                    getFunc = function() return db.restoreOnLogOut end,
                    setFunc = function(newValue) db.restoreOnLogOut = newValue end,
                    width = "full",
                    default = defaults.restoreOnLogOut,
                },
                {-- LAM Option Restore: Kicked
                    type = "checkbox",
                    name = GetString(PCHAT_RESTOREONAFK),
                    tooltip = GetString(PCHAT_RESTOREONAFKTT),
                    getFunc = function() return db.restoreOnAFK end,
                    setFunc = function(newValue) db.restoreOnAFK = newValue end,
                    width = "full",
                    default = defaults.restoreOnAFK,
                },
                {-- LAM Option Restore: Hours
                    type = "slider",
                    name = GetString(PCHAT_TIMEBEFORERESTORE),
                    tooltip = GetString(PCHAT_TIMEBEFORERESTORETT),
                    min = 1,
                    max = 24,
                    step = 1,
                    getFunc = function() return db.timeBeforeRestore end,
                    setFunc = function(newValue) db.timeBeforeRestore = newValue end,
                    width = "full",
                    default = defaults.timeBeforeRestore,
                },
                {-- LAM Option Restore: Leave
                    type = "checkbox",
                    name = GetString(PCHAT_RESTOREONQUIT),
                    tooltip = GetString(PCHAT_RESTOREONQUITTT),
                    getFunc = function() return db.restoreOnQuit end,
                    setFunc = function(newValue) db.restoreOnQuit = newValue end,
                    width = "full",
                    default = defaults.restoreOnQuit,
                },
                {-- LAM Option Restore: System Messages
                    type = "checkbox",
                    name = GetString(PCHAT_RESTORESYSTEM),
                    tooltip = GetString(PCHAT_RESTORESYSTEMTT),
                    getFunc = function() return db.restoreSystem end,
                    setFunc = function(newValue) db.restoreSystem = newValue end,
                    width = "full",
                    default = defaults.restoreSystem,
                },
                {-- LAM Option Restore: System Only Messages
                    type = "checkbox",
                    name = GetString(PCHAT_RESTORESYSTEMONLY),
                    tooltip = GetString(PCHAT_RESTORESYSTEMONLYTT),
                    getFunc = function() return db.restoreSystemOnly end,
                    setFunc = function(newValue) db.restoreSystemOnly = newValue end,
                    width = "full",
                    default = defaults.restoreSystemOnly,
                },
                {-- LAM Option Restore: Whispers
                    type = "checkbox",
                    name = GetString(PCHAT_RESTOREWHISPS),
                    tooltip = GetString(PCHAT_RESTOREWHISPSTT),
                    getFunc = function() return db.restoreWhisps end,
                    setFunc = function(newValue) db.restoreWhisps = newValue end,
                    width = "full",
                    default = defaults.restoreWhisps,
                },
                {-- LAM Option Restore: Whispers -> No whisper notifications
                    type = "checkbox",
                    name = GetString(PCHAT_RESTOREWHISPS_NO_NOTIFY),
                    tooltip = GetString(PCHAT_RESTOREWHISPS_NO_NOTIFY_TT),
                    getFunc = function() return db.doNotNotifyOnRestoredWhisperFromHistory end,
                    setFunc = function(newValue) db.doNotNotifyOnRestoredWhisperFromHistory = newValue end,
                    width = "full",
                    disabled = function() return not db.notifyIM end,
                    default = defaults.doNotNotifyOnRestoredWhisperFromHistory,
                },
                {-- LAM Option Restore: Text entry history
                    type = "checkbox",
                    name = GetString(PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT),
                    tooltip = GetString(PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT),
                    getFunc = function() return db.restoreTextEntryHistoryAtLogOutQuit end,
                    setFunc = function(newValue) db.restoreTextEntryHistoryAtLogOutQuit = newValue end,
                    width = "full",
                    default = defaults.restoreTextEntryHistoryAtLogOutQuit,
                },
            },
        } -- Anti-Spam   Timestamp options
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_ANTISPAMH),
            controls = {
                {-- flood protect
                    type = "checkbox",
                    name = GetString(PCHAT_FLOODPROTECT),
                    tooltip = GetString(PCHAT_FLOODPROTECTTT),
                    getFunc = function() return db.floodProtect end,
                    setFunc = function(newValue) db.floodProtect = newValue end,
                    width = "full",
                    default = defaults.floodProtect,
                }, --Anti spam  grace period
                {
                    type = "slider",
                    name = GetString(PCHAT_FLOODGRACEPERIOD),
                    tooltip = GetString(PCHAT_FLOODGRACEPERIODTT),
                    min = 0,
                    max = 180,
                    step = 1,
                    getFunc = function() return db.floodGracePeriod end,
                    setFunc = function(newValue) db.floodGracePeriod = newValue end,
                    width = "full",
                    default = defaults.floodGracePeriod,
                    disabled = function() return not db.floodProtect end,
                },
                {
                    type = "checkbox",
                    name = GetString(PCHAT_LOOKINGFORPROTECT),
                    tooltip = GetString(PCHAT_LOOKINGFORPROTECTTT),
                    getFunc = function() return db.lookingForProtect end,
                    setFunc = function(newValue) db.lookingForProtect = newValue end,
                    width = "full",
                    default = defaults.lookingForProtect,
                },
                {
                    type = "checkbox",
                    name = GetString(PCHAT_WANTTOPROTECT),
                    tooltip = GetString(PCHAT_WANTTOPROTECTTT),
                    getFunc = function() return db.wantToProtect end,
                    setFunc = function(newValue) db.wantToProtect = newValue end,
                    width = "full",
                    default = defaults.wantToProtect,
                },
                {
                    type = "slider",
                    name = GetString(PCHAT_SPAMGRACEPERIOD),
                    tooltip = GetString(PCHAT_SPAMGRACEPERIODTT),
                    min = 0,
                    max = 10,
                    step = 1,
                    getFunc = function() return db.spamGracePeriod end,
                    setFunc = function(newValue) db.spamGracePeriod = newValue end,
                    width = "full",
                    default = defaults.spamGracePeriod,
                },
                {
                    type = "editbox",
                    name = GetString(PCHAT_NICKNAMES),
                    tooltip = GetString(PCHAT_NICKNAMESTT),
                    isMultiline = true,
                    isExtraWide = true,
                    getFunc = function() return db.nicknames end,
                    setFunc = function(newValue)
                        db.nicknames = newValue
                        BuildNicknames(true) -- Rebuild the control if data is invalid
                    end,
                    width = "full",
                    default = defaults.nicknames,
                },
            },
        } -- Timestamp options
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_TIMESTAMPH),
            controls = {
                {
                    type = "checkbox",
                    name = GetString(PCHAT_ENABLETIMESTAMP),
                    tooltip = GetString(PCHAT_ENABLETIMESTAMPTT),
                    getFunc = function() return db.showTimestamp end,
                    setFunc = function(newValue) db.showTimestamp = newValue end,
                    width = "full",
                    default = defaults.showTimestamp,
                },
                {
                    type = "checkbox",
                    name = GetString(PCHAT_TIMESTAMPCOLORISLCOL),
                    tooltip = GetString(PCHAT_TIMESTAMPCOLORISLCOLTT),
                    getFunc = function() return db.timestampcolorislcol end,
                    setFunc = function(newValue) db.timestampcolorislcol = newValue end,
                    width = "full",
                    default = defaults.timestampcolorislcol,
                    disabled = function() return not db.showTimestamp end,
                },
                {
                    type = "editbox",
                    name = GetString(PCHAT_TIMESTAMPFORMAT),
                    tooltip = GetString(PCHAT_TIMESTAMPFORMATTT),
                    getFunc = function() return db.timestampFormat end,
                    setFunc = function(newValue) db.timestampFormat = newValue end,
                    width = "full",
                    default = defaults.timestampFormat,
                    disabled = function() return not db.showTimestamp end,
                },
                {
                    type = "colorpicker",
                    name = GetString(PCHAT_TIMESTAMP),
                    tooltip = GetString(PCHAT_TIMESTAMPTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours.timestamp) end,
                    setFunc = function(r, g, b) db.colours.timestamp = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours.timestamp),
                    disabled = function() return not db.showTimestamp or db.timestampcolorislcol end,
                },
            },
        }
        -- Addon Menu Other Colors
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_CHATCOLORSH),
            controls = {
                {-- Say players
                    type = "colorpicker",
                    name = GetString(PCHAT_SAY),
                    tooltip = GetString(PCHAT_SAYTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_SAY]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_SAY] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_SAY]),
                    disabled = function() return db.useESOcolors end,
                },
                {--Say Chat Color
                    type = "colorpicker",
                    name = GetString(PCHAT_SAYCHAT),
                    tooltip = GetString(PCHAT_SAYCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_SAY + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_SAY + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_SAY + 1]),
                    disabled = function() return db.useESOcolors end,
                },
                {-- Zone Player
                    type = "colorpicker",
                    name = GetString(PCHAT_ZONE),
                    tooltip = GetString(PCHAT_ZONETT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE]),
                    disabled = function() return db.useESOcolors end,
                },
                {
                    type = "colorpicker",
                    name = GetString(PCHAT_ZONECHAT),
                    tooltip = GetString(PCHAT_ZONECHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE + 1]),
                    disabled = function() return db.useESOcolors end,
                },
                {-- Yell Player
                    type = "colorpicker",
                    name = GetString(PCHAT_YELL),
                    tooltip = GetString(PCHAT_YELLTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_YELL]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_YELL] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_YELL]),
                    disabled = function() return db.useESOcolors end,
                },
                {--Yell Chat
                    type = "colorpicker",
                    name = GetString(PCHAT_YELLCHAT),
                    tooltip = GetString(PCHAT_YELLCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_YELL + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_YELL + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_YELL + 1]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_INCOMINGWHISPERS),
                    tooltip = GetString(PCHAT_INCOMINGWHISPERSTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_WHISPER]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_WHISPER] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_WHISPER]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_INCOMINGWHISPERSCHAT),
                    tooltip = GetString(PCHAT_INCOMINGWHISPERSCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_WHISPER + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_WHISPER + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_WHISPER + 1]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_OUTGOINGWHISPERS),
                    tooltip = GetString(PCHAT_OUTGOINGWHISPERSTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_WHISPER_SENT]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_WHISPER_SENT] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_WHISPER_SENT]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_OUTGOINGWHISPERSCHAT),
                    tooltip = GetString(PCHAT_OUTGOINGWHISPERSCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_WHISPER_SENT + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_WHISPER_SENT + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_WHISPER_SENT + 1]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_GROUP),
                    tooltip = GetString(PCHAT_GROUPTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_PARTY]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_PARTY] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_PARTY]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_GROUPCHAT),
                    tooltip = GetString(PCHAT_GROUPCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_PARTY + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_PARTY + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_PARTY + 1]),
                    disabled = function() return db.useESOcolors end,
                },
            },
        }--Other Colors
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = GetString(PCHAT_OTHERCOLORSH),
            controls = {
                {
                    type = "colorpicker",
                    name = GetString(PCHAT_EMOTES),
                    tooltip = GetString(PCHAT_EMOTESTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_EMOTE]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_EMOTE] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_EMOTE]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_EMOTESCHAT),
                    tooltip = GetString(PCHAT_EMOTESCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_EMOTE + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_EMOTE + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_EMOTE + 1]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_NPCSAY),
                    tooltip = GetString(PCHAT_NPCSAYTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_SAY]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_SAY] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_SAY]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_NPCSAYCHAT),
                    tooltip = GetString(PCHAT_NPCSAYCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_SAY + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_SAY + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_SAY + 1]),
                    disabled = function() return db.useESOcolors end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_NPCYELL),
                    tooltip = GetString(PCHAT_NPCYELLTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_YELL]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_YELL] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_YELL]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allNPCSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_NPCYELLCHAT),
                    tooltip = GetString(PCHAT_NPCYELLCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_YELL + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_YELL + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_YELL + 1]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allNPCSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_NPCWHISPER),
                    tooltip = GetString(PCHAT_NPCWHISPERTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_WHISPER]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_WHISPER] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_WHISPER]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allNPCSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_NPCWHISPERCHAT),
                    tooltip = GetString(PCHAT_NPCWHISPERCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_WHISPER + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_WHISPER + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_WHISPER + 1]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allNPCSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_NPCEMOTES),
                    tooltip = GetString(PCHAT_NPCEMOTESTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_EMOTE]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_EMOTE] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_EMOTE]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allNPCSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_NPCEMOTESCHAT),
                    tooltip = GetString(PCHAT_NPCEMOTESCHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_EMOTE + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_EMOTE + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_EMOTE + 1]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allNPCSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_ENZONE),
                    tooltip = GetString(PCHAT_ENZONETT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allZonesSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_ENZONECHAT),
                    tooltip = GetString(PCHAT_ENZONECHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1 + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1 + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1 + 1]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allZonesSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_FRZONE),
                    tooltip = GetString(PCHAT_FRZONETT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allZonesSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_FRZONECHAT),
                    tooltip = GetString(PCHAT_FRZONECHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2 + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2 + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2 + 1]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allZonesSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_DEZONE),
                    tooltip = GetString(PCHAT_DEZONETT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allZonesSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_DEZONECHAT),
                    tooltip = GetString(PCHAT_DEZONECHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3 + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3 + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3 + 1]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allZonesSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_JPZONE),
                    tooltip = GetString(PCHAT_JPZONETT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allZonesSameColour
                        end
                    end,
                },
                {--
                    type = "colorpicker",
                    name = GetString(PCHAT_JPZONECHAT),
                    tooltip = GetString(PCHAT_JPZONECHATTT),
                    getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4 + 1]) end,
                    setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4 + 1] = ConvertRGBToHex(r, g, b) end,
                    default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4 + 1]),
                    disabled = function()
                        if db.useESOcolors then
                            return true
                        else
                            return db.allZonesSameColour
                        end
                    end,
                },
            },
        }
        -- Guilds

        --  Guild Stuff
        --
        for guild = 1, GetNumGuilds() do
            -- Guildname
            local guildId = GetGuildId(guild)
            local guildName = GetGuildName(guildId)
            -- Occurs sometimes
            if(not guildName or (guildName):len() < 1) then
                guildName = "Guild " .. guild
            end
            -- If recently added to a new guild and never go in menu db.formatguild[guildName] won't exist
            if not (db.formatguild[guildId]) then
                -- 2 is default value
                db.formatguild[guildId] = 2
            end
            optionsData[#optionsData + 1] = {
                type = "submenu",
                name = guildName,
                controls = {
                    {
                        type = "editbox",
                        name = GetString(PCHAT_NICKNAMEFOR),
                        tooltip = GetString(PCHAT_NICKNAMEFORTT) .. " " .. guildName .. " (ID: " ..tostring(guildId) ..")",
                        getFunc = function() return db.guildTags[guildId] end,
                        setFunc = function(newValue)
                            db.guildTags[guildId] = newValue
                            UpdateCharCorrespondanceTableChannelNames()
                        end,
                        width = "full",
                        default = "",
                    },
                    {
                        type = "editbox",
                        name = GetString(PCHAT_OFFICERTAG),
                        tooltip = GetString(PCHAT_OFFICERTAGTT),
                        width = "full",
                        default = "",
                        getFunc = function() return db.officertag[guildId] end,
                        setFunc = function(newValue)
                            db.officertag[guildId] = newValue
                            UpdateCharCorrespondanceTableChannelNames()
                        end
                    },
                    {
                        type = "editbox",
                        name = GetString(PCHAT_SWITCHFOR),
                        tooltip = GetString(PCHAT_SWITCHFORTT),
                        getFunc = function() return db.switchFor[guildId] end,
                        setFunc = function(newValue)
                            local channelId = CHAT_CHANNEL_GUILD_1 - 1 + guild

                            local oldValue = db.switchFor[guildId]
                            if oldValue and oldValue ~= "" then
                                RemoveCustomChannelSwitches(channelId, oldValue)
                            end

                            db.switchFor[guildId] = newValue
                            if newValue and newValue ~= "" then
                                AddCustomChannelSwitches(channelId, newValue)
                            end
                        end,
                        width = "full",
                        default = "",
                    },
                    {
                        type = "editbox",
                        name = GetString(PCHAT_OFFICERSWITCHFOR),
                        tooltip = GetString(PCHAT_OFFICERSWITCHFORTT),
                        width = "full",
                        default = "",
                        getFunc = function() return db.officerSwitchFor[guildId] end,
                        setFunc = function(newValue)
                            local channelId = CHAT_CHANNEL_OFFICER_1 - 1 + guild

                            local oldValue = db.officerSwitchFor[guildId]
                            if oldValue and oldValue ~= "" then
                                RemoveCustomChannelSwitches(channelId, oldValue)
                            end

                            db.officerSwitchFor[guildId] = newValue
                            if newValue and newValue ~= "" then
                                AddCustomChannelSwitches(channelId, newValue)
                            end
                        end
                    },
                    -- Config store 1/2/3 to avoid language switchs
                    -- TODO : Optimize
                    {
                        type = "dropdown",
                        name = GetString(PCHAT_NAMEFORMAT),
                        tooltip = GetString(PCHAT_NAMEFORMATTT),
                        choices = {GetString(PCHAT_FORMATCHOICE1), GetString(PCHAT_FORMATCHOICE2), GetString(PCHAT_FORMATCHOICE3), GetString(PCHAT_FORMATCHOICE4)},
                        choicesValues = {1, 2, 3, 4},
                        getFunc = function()
                            -- Config per guild
                            return db.formatguild[guildId]
                        end,
                        setFunc = function(value)
                            db.formatguild[guildId] = value
                        end,
                        width = "full",
                        default = 2,
                    },
                    {
                        type = "colorpicker",
                        name = zo_strformat(PCHAT_MEMBERS, guildName),
                        tooltip = zo_strformat(PCHAT_SETCOLORSFORTT, guildName),
                        getFunc = function() return ConvertHexToRGBA(db.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1)]) end,
                        setFunc = function(r, g, b) db.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1)] = ConvertRGBToHex(r, g, b) end,
                        default = ConvertHexToRGBAPacked(defaults.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1)]),
                        disabled = function() return db.useESOcolors end,
                    },
                    {
                        type = "colorpicker",
                        name = zo_strformat(PCHAT_CHAT, guildName),
                        tooltip = zo_strformat(PCHAT_SETCOLORSFORCHATTT, guildName),
                        getFunc = function() return ConvertHexToRGBA(db.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1) + 1]) end,
                        setFunc = function(r, g, b) db.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1) + 1] = ConvertRGBToHex(r, g, b) end,
                        default = ConvertHexToRGBAPacked(defaults.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1) + 1]),
                        disabled = function() return db.useESOcolors end,
                    },
                    {
                        type = "colorpicker",
                        name = guildName .. GetString(PCHAT_OFFICERSTT) .. zo_strformat(PCHAT_MEMBERS, ""),
                        tooltip = zo_strformat(PCHAT_SETCOLORSFOROFFICIERSTT, guildName),
                        getFunc = function() return ConvertHexToRGBA(db.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1)]) end,
                        setFunc = function(r, g, b) db.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1)] = ConvertRGBToHex(r, g, b) end,
                        default = ConvertHexToRGBAPacked(defaults.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1)]),
                        disabled = function() return db.useESOcolors end,
                    },
                    {
                        type = "colorpicker",
                        name = guildName .. GetString(PCHAT_OFFICERSTT) .. zo_strformat(PCHAT_CHAT, ""),
                        tooltip = zo_strformat(PCHAT_SETCOLORSFOROFFICIERSCHATTT, guildName),
                        getFunc = function() return ConvertHexToRGBA(db.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1) + 1]) end,
                        setFunc = function(r, g, b) db.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1) + 1] = ConvertRGBToHex(r, g, b) end,
                        default = ConvertHexToRGBAPacked(defaults.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1) + 1]),
                        disabled = function() return db.useESOcolors end,
                    },
                },
            }
        end

        LibAddonMenu2:RegisterOptionControls("pChatOptions", optionsData)

    end
    pChat.BuildLAMPanel = BuildLAMPanel

    -- Initialises the settings and settings menu
    local function GetDBAndBuildLAM()

        local panelData = {
            type = "panel",
            name = ADDON_NAME,
            displayName = ZO_HIGHLIGHT_TEXT:Colorize("pChat"),
            author = ADDON_AUTHOR,
            version = ADDON_VERSION,
            slashCommand = "/pchat",
            website = "http://www.esoui.com/downloads/info93-pChat.html",
            registerForRefresh = true,
            registerForDefaults = true,
            website = ADDON_WEBSITE,
        }

        pChat.LAMPanel = LibAddonMenu2:RegisterAddonPanel("pChatOptions", panelData)

        -- Build OptionTable. In a separate func in order to rebuild it in case of Guild Reorg.
        SyncCharacterSelectChoices()
        BuildLAMPanel()

    end

    --Migrate some SavedVariables to new structures
    local function MigrateSavedVars()
        logger:Debug("MigrateSavedVars")
        --Chat configuration synchronization was moved from characterNames as table key in table db.chatConfSync
        --to characterId -> Attention: The charId is a String as well so one needs to change it to a number
        local newChatConfSync = {}
        if db.chatConfSync ~= nil then
            local charName2Id = pChat.characterNameRaw2Id
            local charId2Name = pChat.characterId2NameRaw
            for charName, charsChatConfSyncData in pairs(db.chatConfSync) do
                --logger:Debug(">charName: %s, type: %s", charName, type(tonumber(charName)))
                if charName and charName ~= "" and charName ~= "lastChar" and type(tonumber(charName)) ~= "number" then
                    --Migrate the old charName to it's charId
                    local charId = charName2Id[charName]
                    --CharId exists? If not the char is not existing anymore at this account and will be removed!
                    if charId ~= nil then
                        newChatConfSync[charId] = ZO_DeepTableCopy(charsChatConfSyncData)
                        newChatConfSync[charId].charName = charName
                    end
                else
                    --charName is the charId already!
                    newChatConfSync[charName] = ZO_DeepTableCopy(charsChatConfSyncData)
                    newChatConfSync[charName].charName = charId2Name[charName]
                end
            end
            db.chatConfSync = {}
            db.chatConfSync = newChatConfSync
        end

        --Migrate the old guild settings from guildName to guildId
        for guild = 1, GetNumGuilds() do
            -- Guildname
            local guildId = GetGuildId(guild)
            local guildName = GetGuildName(guildId)
            if db.guildTags and db.guildTags[guildName] then
                db.guildTags[guildId] = db.guildTags[guildName]
                db.guildTags[guildName] = nil
            end
            if db.officertag and db.officertag[guildName] then
                db.officertag[guildId] = db.officertag[guildName]
                db.officertag[guildName] = nil
            end
            if db.switchFor and db.switchFor[guildName] then
                db.switchFor[guildId] = db.switchFor[guildName]
                db.switchFor[guildName] = nil
            end
            if db.officerSwitchFor and db.officerSwitchFor[guildName] then
                db.officerSwitchFor[guildId] = db.officerSwitchFor[guildName]
                db.officerSwitchFor[guildName] = nil
            end
            if db.formatguild and db.formatguild[guildName] then
                db.formatguild[guildId] = db.formatguild[guildName]
                db.formatguild[guildName] = nil
            end
        end
    end

    --Load the SavedVariables
    db = ZO_SavedVars:NewAccountWide('PCHAT_OPTS', 0.9, nil, defaults)
    pChat.db = db

    --Migrate old SavedVariables to new structures
    MigrateSavedVars()

    --LAM and db for saved vars
    GetDBAndBuildLAM()

    --Load the nicknames from the settings
    BuildNicknames()

    return db
end
