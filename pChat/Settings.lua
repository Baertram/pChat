local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME
local ADDON_VERSION			= CONSTANTS.ADDON_VERSION

local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER

--AddOn settings constants
--LibAddonMenu-2.0 panel info constants
local ADDON_AUTHOR        	= "Ayantir, DesertDwellers, Baertram & sirinsidiator"
local ADDON_WEBSITE       	= "http://www.esoui.com/downloads/info93-pChat.html"
local ADDON_FEEDBACK      	= "https://www.esoui.com/forums/private.php?do=newpm&u=2028"
local ADDON_DONATION      	= "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"

--SavedVariables constants
local ADDON_SV_VERSION    	= 0.9 -- ATTENTION: Changing this will reset the SavedVariables!
local ADDON_SV_NAME       	= "PCHAT_OPTS"
CONSTANTS.ADDON_SV_NAME		= ADDON_SV_NAME
CONSTANTS.ADDON_SV_VERSION 	= ADDON_SV_VERSION

local apiVersion = CONSTANTS.API_VERSION

--Initialize the SavedVariables and LAM settings menu
function pChat.InitializeSettings()
	local pChatData = pChat.pChatData
	local logger = pChat.logger
	local UpdateCharCorrespondanceTableChannelNames = pChat.UpdateCharCorrespondanceTableChannelNames

	local ConvertRGBToHex = pChat.ConvertRGBToHex
	local ConvertHexToRGBA = pChat.ConvertHexToRGBA

	--The SavedVariables table
	local db
	-- Default variables to push in SavedVars
	local defaults = {
		--migratedSVToServer = true,
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
		diffChatColorsDarkenValue = 50,
		diffChatColorsLightenValue = 30,
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
		enablepartyswitchPortToDungeon = false,
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
			[2*CHAT_CHANNEL_ZONE_LANGUAGE_5] = "|cCEB36F", -- RU zone Left
			[2*CHAT_CHANNEL_ZONE_LANGUAGE_5 + 1] = "|cB0A074", -- RU zone Right
			["timestamp"] = "|c8F8F8F", -- timestamp
			["tabwarning"] = "|c76BCC3", -- tab Warning ~ "Azure" (ZOS default)
			["groupleader"] = "|cC35582", --
			["groupleader1"] = "|c76BCC3", --
		},
		doNotNotifyOnRestoredWhisperFromHistory = false,
		addHistoryRestoredPrefix = false,
		-- Not LAM
		chatConfSync = {},
		--Chat handlers
		useSystemMessageChatHandler = true,
		usePlayerStatusChangedChatHandler = true,
		useIgnoreAddedChatHandler = true,
		useIgnoreRemovedChatHandler = true,
		useGroupMemberLeftChatHandler = true,
		useGroupTypeChangedChatHandler = true,
		chatEditBoxOnBackspaceHook = true,
		backupYourSavedVariablesReminder = true,
		backupYourSavedVariablesReminderDone = {},

		-- Coorbin20200708
		-- Chat Mentions
		excl = false,
		changeColor = false,
		color = "3af47e",
		capitalize = false,
		extras = "",
		selfsend = false,
		ding = false,
		selfchar = false,
		wholenames = false,
		
		-- @Coorbin 20211222
		-- CharCount
		useCharCount = false,
		charCountZonePostTracker = false,
	}

	--Helper for the format of guilds
	local formatNameChoices       =  { GetString(PCHAT_FORMATCHOICE1), GetString(PCHAT_FORMATCHOICE2), GetString(PCHAT_FORMATCHOICE3), GetString(PCHAT_FORMATCHOICE4)}
	local formatNameChoicesValues =  { 1, 2, 3, 4}

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
				CM:FireCallbacks("LAM-RefreshPanel", pChat.LAMPanel)
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
--d("[pChat]Build LAM Panel")
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
		CM:RegisterCallback("LAM-PanelControlsCreated", pChatLAMPanelCreated)


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
			for numTab, _ in pairs (db.chatConfSync[charId].tabs) do
				table.insert(arrayTab, numTab)
			end
		else
			table.insert(arrayTab, 1)
		end

		--Get the tab names and indices
		pChat.getTabNames()
		--No default tab chosen in SavedVariables yet? Use the first tab	--Update the available sounds from the game
		if not db.defaultTab then
			db.defaultTab = 1
		end


		-- Coorbin20211222
		------------------------------------------------------------------------------------------------------------------------
		--CharCount
		--------------------Char Count Settings getter/setter functions
    	local cc = pChat.charCount

		local function cc_setUseCharCount(var)
			db.useCharCount = var
			cc.setHandlers()
		end

		local function cc_getUseCharCount()
			return db.useCharCount
		end

		local function cc_setCharCountZonePostTracker(var)
			db.charCountZonePostTracker = var
			cc.setHandlers()
		end

		local function cc_getCharCountZonePostTracker()
			return db.charCountZonePostTracker
		end
		-- END Coorbin20211222 charCount
		------------------------------------------------------------------------------------------------------------------------


		--The LAM options data table
		local optionsData = {}

		------------------------------------------------------------------------------------------------------------------------
		--  Guild Stuff -- table "controlsForGuildSubmenu" will be added further down
		local firstGuildName = GetGuildName(GetGuildId(1)) or "/g1"
		local controlsForGuildSubmenu = {
			{-- LAM Option Show Guild Numbers
				type    = "checkbox",
				name    = GetString(PCHAT_GUILDNUMBERS),
				tooltip = GetString(PCHAT_GUILDNUMBERSTT),
				getFunc = function()
					return db.showGuildNumbers
				end,
				setFunc = function(newValue)
					db.showGuildNumbers = newValue
				end,
				width   = "half",
				default = defaults.showGuildNumbers,
			},
			{-- LAM Option Guild Tags next to entry box
				type    = "checkbox",
				name    = GetString(PCHAT_GUILDTAGSNEXTTOENTRYBOX),
				tooltip = GetString(PCHAT_GUILDTAGSNEXTTOENTRYBOXTT),
				width   = "half",
				default = defaults.showTagInEntry,
				getFunc = function()
					return db.showTagInEntry
				end,
				setFunc = function(newValue)
					db.showTagInEntry = newValue
					UpdateCharCorrespondanceTableChannelNames()
				end
			},
			{-- LAM Option Use Same Color for all Guilds
				type    = "checkbox",
				name    = GetString(PCHAT_ALLGUILDSSAMECOLOUR),
				tooltip = string.format(GetString(PCHAT_ALLGUILDSSAMECOLOURTT), firstGuildName),
				getFunc = function()
					return db.allGuildsSameColour
				end,
				setFunc = function(newValue)
					db.allGuildsSameColour = newValue
				end,
				width   = "half",
				default = defaults.allGuildsSameColour,
			},
		}
		--For the chat message name format
		local controlsForGuildSubmenu2 = {}

		--Now add a submenu for each of the 5 guilds
		for guild = 1, GetNumGuilds() do
			-- Guildname
			local guildId = GetGuildId(guild)
			local guildName = GetGuildName(guildId)
			-- Occurs sometimes
			if(not guildName or (guildName):len() < 1) then
				guildName = "Guild " .. guild
			end
			-- If recently added to a new guild and never go in menu db.formatguild[guildName] won't exist
			db.formatguild = db.formatguild or {}
			if db.formatguild[guildId] == nil then
				-- 2 is default value
				db.formatguild[guildId] = 2
			end
			controlsForGuildSubmenu[#controlsForGuildSubmenu + 1] = {
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
						width = "half",
						default = "",
					},
					{
						type = "editbox",
						name = GetString(PCHAT_OFFICERTAG),
						tooltip = GetString(PCHAT_OFFICERTAGTT),
						width = "half",
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
								pChat.RemoveCustomChannelSwitches(channelId, oldValue)
							end

							db.switchFor[guildId] = newValue
							if newValue and newValue ~= "" then
								pChat.AddCustomChannelSwitches(channelId, newValue)
							end
						end,
						width = "half",
						default = "",
					},
					{
						type = "editbox",
						name = GetString(PCHAT_OFFICERSWITCHFOR),
						tooltip = GetString(PCHAT_OFFICERSWITCHFORTT),
						width = "half",
						default = "",
						getFunc = function() return db.officerSwitchFor[guildId] end,
						setFunc = function(newValue)
							local channelId = CHAT_CHANNEL_OFFICER_1 - 1 + guild

							local oldValue = db.officerSwitchFor[guildId]
							if oldValue and oldValue ~= "" then
								pChat.RemoveCustomChannelSwitches(channelId, oldValue)
							end

							db.officerSwitchFor[guildId] = newValue
							if newValue and newValue ~= "" then
								pChat.AddCustomChannelSwitches(channelId, newValue)
							end
						end,
					},
					{
						type = "dropdown",
						name = GetString(PCHAT_NAMEFORMAT),
						tooltip = GetString(PCHAT_NAMEFORMATTT),
						choices = formatNameChoices,
						choicesValues = formatNameChoicesValues,
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
						name = GetString(PCHAT_MEMBERS),
						tooltip = zo_strformat(PCHAT_SETCOLORSFORTT, guildName),
						getFunc = function() return ConvertHexToRGBA(db.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1)]) end,
						setFunc = function(r, g, b) db.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1)] = ConvertRGBToHex(r, g, b) end,
						default = ConvertHexToRGBAPacked(defaults.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1)]),
						disabled = function() return db.useESOcolors or (guild~=1 and db.allGuildsSameColour) end,
						width = "half",
					},
					{
						type = "colorpicker",
						name = GetString(PCHAT_CHAT),
						tooltip = zo_strformat(PCHAT_SETCOLORSFORCHATTT, guildName),
						getFunc = function() return ConvertHexToRGBA(db.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1) + 1]) end,
						setFunc = function(r, g, b) db.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1) + 1] = ConvertRGBToHex(r, g, b) end,
						default = ConvertHexToRGBAPacked(defaults.colours[2*(CHAT_CHANNEL_GUILD_1 + guild - 1) + 1]),
						disabled = function() return db.useESOcolors or (guild~=1 and db.allGuildsSameColour) or db.oneColour end,
						width = "half",
					},
					{
						type = "colorpicker",
						name = GetString(PCHAT_OFFICERSTT) .. " " .. GetString(PCHAT_MEMBERS),
						tooltip = zo_strformat(PCHAT_SETCOLORSFOROFFICIERSTT, guildName),
						getFunc = function() return ConvertHexToRGBA(db.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1)]) end,
						setFunc = function(r, g, b) db.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1)] = ConvertRGBToHex(r, g, b) end,
						default = ConvertHexToRGBAPacked(defaults.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1)]),
						disabled = function() return db.useESOcolors or (guild~=1 and db.allGuildsSameColour) end,
						width = "half",
					},
					{
						type = "colorpicker",
						name = GetString(PCHAT_OFFICERSTT) .. " " .. GetString(PCHAT_CHAT),
						tooltip = zo_strformat(PCHAT_SETCOLORSFOROFFICIERSCHATTT, guildName),
						getFunc = function() return ConvertHexToRGBA(db.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1) + 1]) end,
						setFunc = function(r, g, b) db.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1) + 1] = ConvertRGBToHex(r, g, b) end,
						default = ConvertHexToRGBAPacked(defaults.colours[2*(CHAT_CHANNEL_OFFICER_1 + guild - 1) + 1]),
						disabled = function() return db.useESOcolors or (guild~=1 and db.allGuildsSameColour) or db.oneColour end,
						width = "half",
					},
				},
			}
			--Name format for guild messages
			controlsForGuildSubmenu2[#controlsForGuildSubmenu2+1] = {
				type = "submenu",
				name = guildName,
				controls = {
					{
						type          = "dropdown",
						name          = GetString(PCHAT_NAMEFORMAT),
						tooltip       = GetString(PCHAT_NAMEFORMATTT),
						choices       = formatNameChoices,
						choicesValues = formatNameChoicesValues,
						getFunc       = function()
							-- Config per guild
							return db.formatguild[guildId]
						end,
						setFunc       = function(value)
							db.formatguild[guildId] = value
						end,
						width         = "half",
						default       = 2,
					},
				},
			}
		end

		------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------
		optionsData[#optionsData + 1]  = {
			type="description",
			text = GetString(PCHAT_ADDON_INFO),
		}

		-- Chat settings
		optionsData[#optionsData + 1] = {
			type = "submenu",
			name = GetString(PCHAT_OPTIONSH),
			controls = {
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
				{-- Copy Chat
					type = "checkbox",
					name = GetString(PCHAT_ENABLECOPY),
					tooltip = GetString(PCHAT_ENABLECOPYTT),
					getFunc = function() return db.enablecopy end,
					setFunc = function(newValue) db.enablecopy = newValue end,
					width = "full",
					default = defaults.enablecopy,
				},

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
				-- Chat window
				{
					type = "submenu",
					name = GetString(PCHAT_APPARENCEMH),
					controls = {
						-- BEGIN - Coorbin20211222
						-- BEGIN - Chat char count settings
						{
							type = "submenu",
							name = GetString(PCHAT_CHARCOUNTH),
							controls = {
								{
									type = "checkbox",
									name = GetString(PCHAT_CHARCOUNT_ENABLE_CHECKBOX_NAME),
									getFunc = cc_getUseCharCount,
									setFunc = cc_setUseCharCount,
									tooltip = GetString(PCHAT_CHARCOUNT_ENABLE_CHECKBOX_TOOLTIP),
									default = false,
									width = "full",
								},
								{
									type = "checkbox",
									name = GetString(PCHAT_CHARCOUNT_ZONE_POST_TRACKER_NAME),
									getFunc = cc_getCharCountZonePostTracker,
									setFunc = cc_setCharCountZonePostTracker,
									tooltip = GetString(PCHAT_CHARCOUNT_ZONE_POST_TRACKER_TOOLTIP),
									default = false,
									width = "full",
								},
							},
						},
						-- END - Coorbin20211222
						-- END - Chat char count settings
------------------------------------------------------------------------------------------------------------------------
						{
							type = "submenu",
							name = GetString(PCHAT_SETTINGS_EDITBOX_HOOKS),
							controls = {
								{-- Copy Chat
									type = "checkbox",
									name = GetString(PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACE),
									tooltip = GetString(PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACETT),
									getFunc = function() return db.chatEditBoxOnBackspaceHook end,
									setFunc = function(newValue) db.chatEditBoxOnBackspaceHook = newValue end,
									width = "full",
									default = defaults.chatEditBoxOnBackspaceHook,
								},--
							}, --controls submenu chat edit box

						}, -- submenu chat edit box
------------------------------------------------------------------------------------------------------------------------
						{--	New Message Color
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
								if CHAT_SYSTEM.isMinimized == true then
									CHAT_SYSTEM:Maximize()
								end
							end,
							width = "full",
							default = defaults.windowDarkness,
						},
						{-- Minimize at launch
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
						{ -- Maximize After Menus
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
				},
			},
		}

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
		-- Message settings
		optionsData[#optionsData + 1] = {
			type = "submenu",
			name = GetString(PCHAT_MESSAGEOPTIONSH),
			controls =
			{
				-- Chat message handlers
				{
					type = "submenu",
					name = GetString(PCHAT_CHATHANDLERS),
					controls = {
						{-- LAM Option enable player status changed chat message handler
							type = "checkbox",
							name = GetString(PCHAT_CHATHANDLER_SYSTEMMESSAGES),
							tooltip = string.format(GetString(PCHAT_CHATHANDLER_TEMPLATETT), GetString(PCHAT_CHATHANDLER_SYSTEMMESSAGES)),
							getFunc = function() return db.useSystemMessageChatHandler end,
							setFunc = function(newValue) db.useSystemMessageChatHandler = newValue end,
							width = "full",
							requiresReload = true,
							default = defaults.useSystemMessageChatHandler,
						},
						{-- LAM Option enable player status changed chat message handler
							type = "checkbox",
							name = GetString(PCHAT_CHATHANDLER_PLAYERSTATUS),
							tooltip = string.format(GetString(PCHAT_CHATHANDLER_TEMPLATETT), GetString(PCHAT_CHATHANDLER_PLAYERSTATUS)),
							getFunc = function() return db.usePlayerStatusChangedChatHandler end,
							setFunc = function(newValue) db.usePlayerStatusChangedChatHandler = newValue end,
							width = "full",
							requiresReload = true,
							default = defaults.usePlayerStatusChangedChatHandler,
						},
						{-- LAM Option enable player status changed chat message handler
							type = "checkbox",
							name = GetString(PCHAT_CHATHANDLER_IGNORE_ADDED),
							tooltip = string.format(GetString(PCHAT_CHATHANDLER_TEMPLATETT), GetString(PCHAT_CHATHANDLER_IGNORE_ADDED)),
							getFunc = function() return db.useIgnoreAddedChatHandler end,
							setFunc = function(newValue) db.useIgnoreAddedChatHandler = newValue end,
							width = "full",
							requiresReload = true,
							default = defaults.useIgnoreAddedChatHandler,
						},
						{-- LAM Option enable player status changed chat message handler
							type = "checkbox",
							name = GetString(PCHAT_CHATHANDLER_IGNORE_REMOVED),
							tooltip = string.format(GetString(PCHAT_CHATHANDLER_TEMPLATETT), GetString(PCHAT_CHATHANDLER_IGNORE_REMOVED)),
							getFunc = function() return db.useIgnoreRemovedChatHandler end,
							setFunc = function(newValue) db.useIgnoreRemovedChatHandler = newValue end,
							width = "full",
							requiresReload = true,
							default = defaults.useIgnoreRemovedChatHandler,
						},
						{-- LAM Option enable player status changed chat message handler
							type = "checkbox",
							name = GetString(PCHAT_CHATHANDLER_GROUP_MEMBER_LEFT),
							tooltip = string.format(GetString(PCHAT_CHATHANDLER_TEMPLATETT), GetString(PCHAT_CHATHANDLER_GROUP_MEMBER_LEFT)),
							getFunc = function() return db.useGroupMemberLeftChatHandler end,
							setFunc = function(newValue) db.useGroupMemberLeftChatHandler = newValue end,
							width = "full",
							requiresReload = true,
							default = defaults.useGroupMemberLeftChatHandler,
						},
						{-- LAM Option enable player status changed chat message handler
							type = "checkbox",
							name = GetString(PCHAT_CHATHANDLER_GROUP_TYPE_CHANGED),
							tooltip = string.format(GetString(PCHAT_CHATHANDLER_TEMPLATETT), GetString(PCHAT_CHATHANDLER_GROUP_TYPE_CHANGED)),
							getFunc = function() return db.useGroupTypeChangedChatHandler end,
							setFunc = function(newValue) db.useGroupTypeChangedChatHandler = newValue end,
							width = "full",
							requiresReload = true,
							default = defaults.useGroupTypeChangedChatHandler,
						},

					}, --controls Chat message handlers

				}, --submenu Chat message handlers
------------------------------------------------------------------------------------------------------------------------
				{-- LAM Option Remove Zone Tags
					type = "checkbox",
					name = GetString(PCHAT_DELZONETAGS),
					tooltip = GetString(PCHAT_DELZONETAGSTT),
					getFunc = function() return db.delzonetags end,
					setFunc = function(newValue) db.delzonetags = newValue end,
					width = "half",
					default = defaults.delzonetags,
				},
				{-- URL is clickable
					type = "checkbox",
					name = GetString(PCHAT_URLHANDLING),
					tooltip = GetString(PCHAT_URLHANDLINGTT),
					getFunc = function() return db.urlHandling end,
					setFunc = function(newValue) db.urlHandling = newValue end,
					width = "half",
					default = defaults.urlHandling,
				},
------------------------------------------------------------------------------------------------------------------------
				-- Timestamp options
				{
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
				},
------------------------------------------------------------------------------------------------------------------------
				--Chat messages
				{
					type     = "submenu",
					name     = GetString(PCHAT_MESSAGEOPTIONSNAMEH),
					--helpUrl = "https://www.esoui.com/downloads/info93-pChat.html#comments",
					controls = {
						{-- LAM Option Newline between name and message
							type    = "checkbox",
							name    = GetString(PCHAT_CARRIAGERETURN),
							tooltip = GetString(PCHAT_CARRIAGERETURNTT),
							getFunc = function()
								return db.carriageReturn
							end,
							setFunc = function(newValue)
								db.carriageReturn = newValue
							end,
							default = defaults.carriageReturn,
							width   = "half",
						},
						{-- Disable Brackets
							type    = "checkbox",
							name    = GetString(PCHAT_DISABLEBRACKETS),
							tooltip = GetString(PCHAT_DISABLEBRACKETSTT),
							getFunc = function()
								return db.disableBrackets
							end,
							setFunc = function(newValue)
								db.disableBrackets = newValue
							end,
							default = defaults.disableBrackets,
							width   = "half",
						},
------------------------------------------------------------------------------------------------------------------------
						-- Group Submenu
						{
							type = "submenu",
							name = GetString(PCHAT_GROUPH),
							controls = {
								{-- Group Names
									type = "dropdown",
									name = GetString(PCHAT_GROUPNAMES),
									tooltip = GetString(PCHAT_GROUPNAMESTT),
									choices = formatNameChoices,
									choicesValues = formatNameChoicesValues,
									getFunc = function() return db.groupNames end,
									setFunc = function(value)
										db.groupNames = value
									end,
									default = defaults.groupNames,
									width = "half",
								},
							},
						},
------------------------------------------------------------------------------------------------------------------------
						-- Guild Submenu
						{
							type = "submenu",
							name = GetString(PCHAT_GUILDH),
							controls = controlsForGuildSubmenu2,
						},
------------------------------------------------------------------------------------------------------------------------
						--All other chat messages
						{
							type     = "submenu",
							name     = GetString(PCHAT_MESSAGEOPTIONSNAME_ALLOTHERH),
							controls = {
								{-- LAM Option Names Format
									type          = "dropdown",
									name          = GetString(PCHAT_GEOCHANNELSFORMAT),
									tooltip       = GetString(PCHAT_GEOCHANNELSFORMATTT),
									choices = formatNameChoices,
									choicesValues = formatNameChoicesValues,
									getFunc       = function()
										return db.geoChannelsFormat
									end,
									setFunc       = function(value)
										db.geoChannelsFormat = value
									end,
									default       = defaults.geoChannelsFormat,
									width         = "half",

								},
							},
						},
------------------------------------------------------------------------------------------------------------------------

					}, --controls PCHAT_MESSAGEOPTIONSNAMEH
				}, --submenu Chat messages
------------------------------------------------------------------------------------------------------------------------
				--Colors in chat messages
				{
					type = "submenu",
					name = GetString(PCHAT_MESSAGEOPTIONSCOLORH),
					controls =
					{
						{-- LAM Option Use ESO Colors
							type = "checkbox",
							name = GetString(PCHAT_USEESOCOLORS),
							tooltip = GetString(PCHAT_USEESOCOLORSTT),
							getFunc = function() return db.useESOcolors end,
							setFunc = function(newValue) db.useESOcolors = newValue end,
							width = "half",
							default = defaults.useESOcolors,
						},
						{-- LAM Option Use one color for lines
							type = "checkbox",
							name = GetString(PCHAT_USEONECOLORFORLINES),
							tooltip = GetString(PCHAT_USEONECOLORFORLINESTT),
							getFunc = function() return db.oneColour end,
							setFunc = function(newValue) db.oneColour = newValue end,
							width = "half",
							default = defaults.oneColour,
						},
						{-- LAM Option Use same color for all zone chats
							type = "checkbox",
							name = GetString(PCHAT_ALLZONESSAMECOLOUR),
							tooltip = GetString(PCHAT_ALLZONESSAMECOLOURTT),
							getFunc = function() return db.allZonesSameColour end,
							setFunc = function(newValue) db.allZonesSameColour = newValue end,
							width = "half",
							default = defaults.allZonesSameColour,
						},
						{-- LAM Option Use same color for all NPC
							type = "checkbox",
							name = GetString(PCHAT_ALLNPCSAMECOLOUR),
							tooltip = GetString(PCHAT_ALLNPCSAMECOLOURTT),
							getFunc = function() return db.allNPCSameColour end,
							setFunc = function(newValue) db.allNPCSameColour = newValue end,
							width = "half",
							default = defaults.allNPCSameColour,
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
							disabled = function() return db.oneColour end,
						},
						{
							type = "slider",
							name = GetString(PCHAT_DIFFFORESOCOLORSDARKEN),
							tooltip = GetString(PCHAT_DIFFFORESOCOLORSDARKENTT),
							min = 0,
							max = 90,
							step = 1,
							getFunc = function() return db.diffChatColorsDarkenValue end,
							setFunc = function(newValue) db.diffChatColorsDarkenValue = newValue end,
							width = "half",
							default = defaults.diffChatColorsDarkenValue,
							disabled = function() return db.diffforESOcolors == 0 or db.oneColour end,
						},
						{
							type = "slider",
							name = GetString(PCHAT_DIFFFORESOCOLORSLIGHTEN),
							tooltip = GetString(PCHAT_DIFFFORESOCOLORSLIGHTENTT),
							min = 0,
							max = 90,
							step = 1,
							getFunc = function() return db.diffChatColorsLightenValue end,
							setFunc = function(newValue) db.diffChatColorsLightenValue = newValue end,
							width = "half",
							default = defaults.diffChatColorsLightenValue,
							disabled = function() return db.diffforESOcolors == 0 or db.oneColour end,
						},
------------------------------------------------------------------------------------------------------------------------
						-- Chat channel colors
						{
							type = "submenu",
							name = GetString(PCHAT_CHATCOLORSH),
							disabled = function() return db.useESOcolors end,
							controls = {
								{-- Say players
									type = "colorpicker",
									name = GetString(PCHAT_SAY),
									tooltip = GetString(PCHAT_SAYTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_SAY]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_SAY] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_SAY]),
									disabled = function() return db.useESOcolors end,
									width = "half",
								},
								{--Say Chat Color
									type = "colorpicker",
									name = GetString(PCHAT_SAYCHAT),
									tooltip = GetString(PCHAT_SAYCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_SAY + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_SAY + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_SAY + 1]),
									disabled = function() return db.useESOcolors or db.oneColour end,
									width = "half",
								},
								{-- Zone Player
									type = "colorpicker",
									name = GetString(PCHAT_ZONE),
									tooltip = GetString(PCHAT_ZONETT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE]),
									disabled = function() return db.useESOcolors end,
									width = "half",
								},
								{
									type = "colorpicker",
									name = GetString(PCHAT_ZONECHAT),
									tooltip = GetString(PCHAT_ZONECHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE + 1]),
									disabled = function() return db.useESOcolors or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_ENZONE),
									tooltip = GetString(PCHAT_ENZONETT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_ENZONECHAT),
									tooltip = GetString(PCHAT_ENZONECHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1 + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1 + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_1 + 1]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_FRZONE),
									tooltip = GetString(PCHAT_FRZONETT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour  end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_FRZONECHAT),
									tooltip = GetString(PCHAT_FRZONECHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2 + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2 + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_2 + 1]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_DEZONE),
									tooltip = GetString(PCHAT_DEZONETT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour  end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_DEZONECHAT),
									tooltip = GetString(PCHAT_DEZONECHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3 + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3 + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_3 + 1]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_JPZONE),
									tooltip = GetString(PCHAT_JPZONETT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_JPZONECHAT),
									tooltip = GetString(PCHAT_JPZONECHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4 + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4 + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_4 + 1]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_RUZONE),
									tooltip = GetString(PCHAT_RUZONETT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_5]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_5] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_5]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_RUZONECHAT),
									tooltip = GetString(PCHAT_RUZONECHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_5 + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_5 + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_ZONE_LANGUAGE_5 + 1]),
									disabled = function() return db.useESOcolors or db.allZonesSameColour or db.oneColour end,
									width = "half",
								},
								{-- Yell Player
									type = "colorpicker",
									name = GetString(PCHAT_YELL),
									tooltip = GetString(PCHAT_YELLTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_YELL]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_YELL] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_YELL]),
									disabled = function() return db.useESOcolors end,
									width = "half",
								},
								{--Yell Chat
									type = "colorpicker",
									name = GetString(PCHAT_YELLCHAT),
									tooltip = GetString(PCHAT_YELLCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_YELL + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_YELL + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_YELL + 1]),
									disabled = function() return db.useESOcolors or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_INCOMINGWHISPERS),
									tooltip = GetString(PCHAT_INCOMINGWHISPERSTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_WHISPER]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_WHISPER] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_WHISPER]),
									disabled = function() return db.useESOcolors  end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_INCOMINGWHISPERSCHAT),
									tooltip = GetString(PCHAT_INCOMINGWHISPERSCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_WHISPER + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_WHISPER + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_WHISPER + 1]),
									disabled = function() return db.useESOcolors or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_OUTGOINGWHISPERS),
									tooltip = GetString(PCHAT_OUTGOINGWHISPERSTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_WHISPER_SENT]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_WHISPER_SENT] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_WHISPER_SENT]),
									disabled = function() return db.useESOcolors end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_OUTGOINGWHISPERSCHAT),
									tooltip = GetString(PCHAT_OUTGOINGWHISPERSCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_WHISPER_SENT + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_WHISPER_SENT + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_WHISPER_SENT + 1]),
									disabled = function() return db.useESOcolors or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_GROUP),
									tooltip = GetString(PCHAT_GROUPTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_PARTY]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_PARTY] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_PARTY]),
									disabled = function() return db.useESOcolors  end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_GROUPCHAT),
									tooltip = GetString(PCHAT_GROUPCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_PARTY + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_PARTY + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_PARTY + 1]),
									disabled = function() return db.useESOcolors or db.oneColour end,
									width = "half",
								},
							},
						},
------------------------------------------------------------------------------------------------------------------------
						--Other Colors
						{
							type = "submenu",
							name = GetString(PCHAT_OTHERCOLORSH),
							controls = {
								{
									type="description",
									text = GetString(PCHAT_USEESOCOLORS_INFO),
								},
								{
									type = "colorpicker",
									name = GetString(PCHAT_EMOTES),
									tooltip = GetString(PCHAT_EMOTESTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_EMOTE]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_EMOTE] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_EMOTE]),
									disabled = function() return db.useESOcolors end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_EMOTESCHAT),
									tooltip = GetString(PCHAT_EMOTESCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_EMOTE + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_EMOTE + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_EMOTE + 1]),
									disabled = function() return db.useESOcolors or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_NPCSAY),
									tooltip = GetString(PCHAT_NPCSAYTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_SAY]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_SAY] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_SAY]),
									disabled = function() return db.useESOcolors end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_NPCSAYCHAT),
									tooltip = GetString(PCHAT_NPCSAYCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_SAY + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_SAY + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_SAY + 1]),
									disabled = function() return db.useESOcolors or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_NPCYELL),
									tooltip = GetString(PCHAT_NPCYELLTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_YELL]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_YELL] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_YELL]),
									disabled = function() return db.useESOcolors or db.allNPCSameColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_NPCYELLCHAT),
									tooltip = GetString(PCHAT_NPCYELLCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_YELL + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_YELL + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_YELL + 1]),
									disabled = function() return db.useESOcolors or db.allNPCSameColour or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_NPCWHISPER),
									tooltip = GetString(PCHAT_NPCWHISPERTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_WHISPER]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_WHISPER] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_WHISPER]),
									disabled = function() return db.useESOcolors or db.allNPCSameColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_NPCWHISPERCHAT),
									tooltip = GetString(PCHAT_NPCWHISPERCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_WHISPER + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_WHISPER + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_WHISPER + 1]),
									disabled = function() return db.useESOcolors or db.allNPCSameColour or db.oneColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_NPCEMOTES),
									tooltip = GetString(PCHAT_NPCEMOTESTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_EMOTE]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_EMOTE] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_EMOTE]),
									disabled = function() return db.useESOcolors or db.allNPCSameColour end,
									width = "half",
								},
								{--
									type = "colorpicker",
									name = GetString(PCHAT_NPCEMOTESCHAT),
									tooltip = GetString(PCHAT_NPCEMOTESCHATTT),
									getFunc = function() return ConvertHexToRGBA(db.colours[2*CHAT_CHANNEL_MONSTER_EMOTE + 1]) end,
									setFunc = function(r, g, b) db.colours[2*CHAT_CHANNEL_MONSTER_EMOTE + 1] = ConvertRGBToHex(r, g, b) end,
									default = ConvertHexToRGBAPacked(defaults.colours[2*CHAT_CHANNEL_MONSTER_EMOTE + 1]),
									disabled = function() return db.useESOcolors or db.allNPCSameColour or db.oneColour end,
									width = "half",
								},
							},
						}, --other colors
------------------------------------------------------------------------------------------------------------------------
					}, --colors in chat messages
------------------------------------------------------------------------------------------------------------------------
				}, --colors in chat messages
------------------------------------------------------------------------------------------------------------------------
			} --pchat chat handlers
------------------------------------------------------------------------------------------------------------------------
		}--pchat message options
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------
		-- Chat Tabs
		optionsData[#optionsData + 1] = {
			type = "submenu",
			name = GetString(PCHAT_CHATTABH),
			controls = {
				{-- CHAT_SYSTEM.primaryContainer.windows doesn't exists yet at OnAddonLoaded. So using the pChat reference.
					type = "dropdown",
					name = GetString(PCHAT_DEFAULTTAB),
					tooltip = GetString(PCHAT_DEFAULTTABTT),
					choices = pChat.tabNames,
					choicesValues = pChat.tabIndices,
					width = "full",
					getFunc = function() return db.defaultTab end,
					setFunc = function(choice)
						db.defaultTab = choice
						--logger:Debug(choice)
					end,
					default = defaults.defaultTab,
				},
			},
		}

		------------------------------------------------------------------------------------------------------------------------
		--Chat channels
		optionsData[#optionsData + 1] = {
			type = "submenu",
			name = GetString(PCHAT_CHATCHANNELSH),
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
						GetString("PCHAT_DEFAULTCHANNELCHOICE", CONSTANTS.PCHAT_CHANNEL_NONE),
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
						elseif choice == GetString("PCHAT_DEFAULTCHANNELCHOICE", CONSTANTS.PCHAT_CHANNEL_NONE) then
							db.defaultchannel = CONSTANTS.PCHAT_CHANNEL_NONE
						else
							-- When user click on LAM reinit button
							db.defaultchannel = defaults.defaultchannel
						end

					end,
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
				-- Group Submenu
				{
					type = "submenu",
					name = GetString(PCHAT_GROUPH),
					controls = {
						{-- Enable Party Switch
							type = "checkbox",
							name = GetString(PCHAT_ENABLEPARTYSWITCH),
							tooltip = GetString(PCHAT_ENABLEPARTYSWITCHTT),
							getFunc = function() return db.enablepartyswitch end,
							setFunc = function(newValue) db.enablepartyswitch = newValue end,
							width = "half",
							default = defaults.enablepartyswitch,
						},
						{-- Enable Party Switch Port to/reloadui in dungeon
							type = "checkbox",
							name = GetString(PCHAT_ENABLEPARTYSWITCHPORTTODUNGEON),
							tooltip = GetString(PCHAT_ENABLEPARTYSWITCHPORTTODUNGEONTT),
							getFunc = function() return db.enablepartyswitchPortToDungeon end,
							setFunc = function(newValue) db.enablepartyswitchPortToDungeon = newValue end,
							width = "half",
							default = defaults.enablepartyswitchPortToDungeon,
							disabled = function() return not db.enablepartyswitch end
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
							width = "half",
						},
						{-- Group Leader Color 2
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
								elseif db.oneColour then
									return true
								else
									return false
								end
							end,
							width = "half",
						},
					},
				},
				-- Guild settings
				{
					type = "submenu",
					name = GetString(PCHAT_GUILDH),
					controls = controlsForGuildSubmenu,	--Above build table with each guild's settings as a LAM submenu
				},
				-- Whispers
				{
					type = "submenu",
					name = GetString(PCHAT_IMH),
					controls = {

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
				},
			}
		}

		-- Sync Settings Header
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
					setFunc = function(p_charId)
						pChat.SyncChatConfig(true, p_charId)
					end,
				},
			},
		}

		-- Anti-Spam options
		optionsData[#optionsData + 1] =	{
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
		}

		-- LAM Menu Restore Chat
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
		}

		-- Coorbin20200708
		------------------------------------------------------------------------------------------------------------------------
		--Chat Mentions

		--------------------Chat Mentions Settings getter/setter functions
    	local cm = pChat.ChatMentions

		local function cm_setMentionColorOption(var)
			db.changeColor = var
			cm.cm_loadRegexes()
		end

		local function cm_getMentionColorOption()
			return db.changeColor
		end

		local function cm_setMentionColorPickerOption(r, g, b)
			db.color = cm.cm_convertRGBToHex(r, g, b)
			cm.cm_loadRegexes()
		end

		local function cm_getMentionColorPickerOption()
			return cm.cm_convertHexToRGBA(db.color)
		end

		local function cm_getMentionColorPickerDefault()
			return cm.cm_convertHexToRGBAPacked(defaults.color)
		end

		local function cm_getMentionColorPickerDisabled()
			return not db.changeColor
		end

		local function cm_getMentionExclamationOption()
			return db.excl
		end

		local function cm_setMentionExclamationOption(var)
			db.excl = var
			cm.cm_loadRegexes()
		end

		local function cm_getMentionAllCapsOption()
			return db.capitalize
		end

		local function cm_setMentionAllCapsOption(var)
			db.capitalize = var
			cm.cm_loadRegexes()
		end

		local function cm_getMentionExtraNamesOption()
			return db.extras
		end

		local function cm_setMentionExtraNamesOption(var)
			db.extras = var
			cm.cm_loadRegexes()
		end

		local function cm_getMentionSelfSendOption()
			return db.selfsend
		end

		local function cm_setMentionSelfSendOption(var)
			db.selfsend = var
		end

		local function cm_getMentionDingOption()
			return db.ding
		end

		local function cm_setMentionDingOption(var)
			db.ding = var
		end

		local function cm_getMentionApplyNameOption()
			return db.selfchar
		end

		local function cm_setMentionApplyNameOption(var)
			db.selfchar = var
			cm.cm_loadRegexes()
		end

		local function cm_getMentionWholeWordOption()
			return db.wholenames
		end

		local function cm_setMentionWholeWordOption(var)
			db.wholenames = var
			cm.cm_loadRegexes()
		end

		-- Coorbin20200708
		-- Chat Mentions Data
		optionsData[#optionsData + 1] = {
			type = "submenu",
			name = GetString(PCHAT_MENTIONSH),
			controls = {
				{
					type = "checkbox",
					name = GetString(PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_NAME),
					getFunc = cm_getMentionColorOption,
					setFunc = cm_setMentionColorOption,
					tooltip = GetString(PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_TOOLTIP),
					default = false,
					width = "full",
				},
				{
					type = "colorpicker",
					name = GetString(PCHAT_MENTIONS_TEXT_COLOR_PICKER_NAME),
					getFunc = cm_getMentionColorPickerOption,
					setFunc = cm_setMentionColorPickerOption,
					disabled = cm_getMentionColorPickerDisabled,
					default = cm_getMentionColorPickerDefault,
				},
				{
					type = "checkbox",
					name = GetString(PCHAT_MENTIONS_ADD_EXCL_ICON_NAME),
					getFunc = cm_getMentionExclamationOption,
					setFunc = cm_setMentionExclamationOption,
					tooltip = GetString(PCHAT_MENTIONS_ADD_EXCL_ICON_TOOLTIP),
					default = false,
					width = "full",
				},
				{
					type = "checkbox",
					name = GetString(PCHAT_MENTIONS_ALLCAPS_NAME),
					getFunc = cm_getMentionAllCapsOption,
					setFunc = cm_setMentionAllCapsOption,
					tooltip = GetString(PCHAT_MENTIONS_ALLCAPS_TOOLTIP),
					default = false,
					width = "full",
				},
				{
					type = "editbox",
					name = GetString(PCHAT_MENTIONS_EXTRA_NAMES_NAME),
					tooltip = GetString(PCHAT_MENTIONS_EXTRA_NAMES_TOOLTIP),
					getFunc = cm_getMentionExtraNamesOption,
					setFunc = cm_setMentionExtraNamesOption,
					isMultiline = true,
					isExtraWide = true,
					width = "full",
					default = "",
				},
				{
					type = "checkbox",
					name = GetString(PCHAT_MENTIONS_SELFSEND_NAME),
					getFunc = cm_getMentionSelfSendOption,
					setFunc = cm_setMentionSelfSendOption,
					tooltip = GetString(PCHAT_MENTIONS_SELFSEND_TOOLTIP),
					default = false,
					width = "full",
				},
				{
					type = "checkbox",
					name = GetString(PCHAT_MENTIONS_DING_NAME),
					getFunc = cm_getMentionDingOption,
					setFunc = cm_setMentionDingOption,
					tooltip = GetString(PCHAT_MENTIONS_DING_TOOLTIP),
					default = false,
					width = "full",
				},
				{
					type = "checkbox",
					name = GetString(PCHAT_MENTIONS_APPLYNAME_NAME),
					getFunc = cm_getMentionApplyNameOption,
					setFunc = cm_setMentionApplyNameOption,
					tooltip = GetString(PCHAT_MENTIONS_APPLYNAME_TOOLTIP),
					default = false,
					width = "full",
				},
				{
					type = "checkbox",
					name = GetString(PCHAT_MENTIONS_WHOLEWORD_NAME),
					getFunc = cm_getMentionWholeWordOption,
					setFunc = cm_setMentionWholeWordOption,
					tooltip = GetString(PCHAT_MENTIONS_WHOLEWORD_TOOLTIP),
					default = false,
					width = "full",
				},
			},
		}
		

		--
		-- Baertram 2021-06-06
		-- Backup SavedVariables reminder
		optionsData[#optionsData + 1] = {
			type = "submenu",
			name = GetString(PCHAT_SETTINGS_BACKUP),
			controls = {
				{
					type = "description",
					text = string.format(GetString(PCHAT_SETTINGS_BACKUP_REMINDER_LAST_REMINDER), pChat.lastBackupReminderDoneStr),
				},
				{
					type    = "checkbox",
					name    = GetString(PCHAT_SETTINGS_BACKUP_REMINDER),
					tooltip = GetString(PCHAT_SETTINGS_BACKUP_REMINDER_TT),
					getFunc = function() return db.backupYourSavedVariablesReminder end,
					setFunc = function(value) db.backupYourSavedVariablesReminder = value end,
					default = defaults.backupYourSavedVariablesReminder,
					width   = "full",
				},
			}
		}

		--[[
		index = index + 1
		optionsTable[index] = {
				type = "header",
				name = GetString(PCHAT_DEBUGH),
				width = "full",
		}

		index = index + 1
		optionsTable[index] = {
				type = "checkbox",
				name = GetString(PCHAT_DEBUG),
				tooltip = GetString(PCHAT_DEBUGTT),
				getFunc = function() return db.debug end,
				setFunc = function(newValue) db.debug = newValue end,
				width = "full",
				default = defaults.debug,
		},
		]]--


		optionsData[#optionsData + 1]  = {
			type="description",
			text = GetString(PCHAT_ADDON_INFO_2),
		}

		--Create the LibAdonMenu2 settings panel now
		LibAddonMenu2:RegisterOptionControls("pChatOptions", optionsData)

	end
	pChat.BuildLAMPanel = BuildLAMPanel

	-- Initialises the settings and settings menu
	local function GetDBAndBuildLAM()

		local panelData = {
			type = "panel",
			name = ADDON_NAME,
			displayName = ZO_HIGHLIGHT_TEXT:Colorize(ADDON_NAME),
			author = ADDON_AUTHOR,
			version = ADDON_VERSION,
			slashCommand = "/pchat",
			website = ADDON_WEBSITE,
			feedback = ADDON_FEEDBACK,
			donation = ADDON_DONATION,
			registerForRefresh = true,
			registerForDefaults = true,
		}

		pChat.LAMPanel = LibAddonMenu2:RegisterAddonPanel("pChatOptions", panelData)

		-- Build OptionTable. In a separate func in order to rebuild it in case of Guild Reorg.
		BuildLAMPanel()

	end

	-- Revert category settings
	local function RevertCategories(guildId)

		-- Old GuildId
		local oldIndex = pChatData.guildIndexes[guildId].num
		-- old Total Guilds
		local totGuilds = GetNumGuilds() + 1

		if oldIndex and oldIndex < totGuilds then
			local charId = GetCurrentCharacterId()

			-- If our guild was not the last one, need to revert colors
			--logger:Debug("pChat will revert starting from %d to %d", oldIndex, totGuilds)

			-- Does not need to reset chat settings for first guild if the 2nd has been left, same for 1-2/3 and 1-2-3/4
			for iGuilds=oldIndex, (totGuilds - 1) do

				-- If default channel was g1, keep it g1
				if not (db.defaultchannel == CHAT_CATEGORY_GUILD_1 or db.defaultchannel == CHAT_CATEGORY_OFFICER_1) then

					if db.defaultchannel == (CHAT_CATEGORY_GUILD_1 + iGuilds) then
						db.defaultchannel = (CHAT_CATEGORY_GUILD_1 + iGuilds - 1)
					elseif db.defaultchannel == (CHAT_CATEGORY_OFFICER_1 + iGuilds) then
						db.defaultchannel = (CHAT_CATEGORY_OFFICER_1 + iGuilds - 1)
					end

				end

				-- New Guild color for Guild #X is the old #X+1
				SetChatCategoryColor(CHAT_CATEGORY_GUILD_1 + iGuilds - 1, db.chatConfSync[charId].colors[CHAT_CATEGORY_GUILD_1 + iGuilds].red, db.chatConfSync[charId].colors[CHAT_CATEGORY_GUILD_1 + iGuilds].green, db.chatConfSync[charId].colors[CHAT_CATEGORY_GUILD_1 + iGuilds].blue)
				-- New Officer color for Guild #X is the old #X+1
				SetChatCategoryColor(CHAT_CATEGORY_OFFICER_1 + iGuilds - 1, db.chatConfSync[charId].colors[CHAT_CATEGORY_OFFICER_1 + iGuilds].red, db.chatConfSync[charId].colors[CHAT_CATEGORY_OFFICER_1 + iGuilds].green, db.chatConfSync[charId].colors[CHAT_CATEGORY_OFFICER_1 + iGuilds].blue)

				-- Restore tab config previously set.
				for numTab in ipairs (CHAT_SYSTEM.primaryContainer.windows) do
					if db.chatConfSync[charId].tabs[numTab] then
						SetChatContainerTabCategoryEnabled(1, numTab, (CHAT_CATEGORY_GUILD_1 + iGuilds - 1), db.chatConfSync[charId].tabs[numTab].enabledCategories[CHAT_CATEGORY_GUILD_1 + iGuilds])
						SetChatContainerTabCategoryEnabled(1, numTab, (CHAT_CATEGORY_OFFICER_1 + iGuilds - 1), db.chatConfSync[charId].tabs[numTab].enabledCategories[CHAT_CATEGORY_OFFICER_1 + iGuilds])
					end
				end

			end
		end

	end

	local function SaveGuildIndexes()
		pChatData.guildIndexes = {}
		--For each guild get the unique serverGuildId
		for guildNum = 1, GetNumGuilds() do
			-- Guildname
			local guildId = GetGuildId(guildNum)
			local guildName = GetGuildName(guildId)
			-- Occurs sometimes
			if(not guildName or (guildName):len() < 1) then
				guildName = "Guild " .. guildNum
			end
			pChatData.guildIndexes[guildId] = {
				num     = guildNum,
				id      = guildId,
				name    = guildName,
			}
		end
	end


	-- Triggered by EVENT_GUILD_SELF_JOINED_GUILD
	local function OnSelfJoinedGuild(_, guildServerId, _, _)

		-- It will rebuild optionsTable and recreate tables if user didn't went in this section before
		BuildLAMPanel()

		-- If recently added to a new guild and never go in menu db.formatguild[guildId] won't exist, it won't create the value if joining an known guild
		if not db.formatguild[guildServerId] then
			-- 2 is default value
			db.formatguild[guildServerId] = 2
		end

		-- Save Guild indexes for guild reorganization
		SaveGuildIndexes()

	end

	-- Runs whenever "me" left a guild (or get kicked)
	local function OnSelfLeftGuild(_, guildServerId, _, _)
		-- It will rebuild optionsTable and recreate tables if user didn't went in this section before
		BuildLAMPanel()

		-- Revert category colors & options
		RevertCategories(guildServerId)
	end


	--Migrate old character name SavedVariables to new unique characterId structures
	local function migrateToCharacterIdSavedVars()
		logger:Debug("MigrateSavedVars - ChatConfSync")
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
	end

	local function getLastBackupSVReminderText()
		local settings = pChat.db

		pChat.lastBackupReminderWasFound = nil
		pChat.lastBackupReminderDoneStr = ""

		local function lastBackupReminderNotFound()
			if not settings.backupYourSavedVariablesReminder then return end
			local lastBackupReminderDateTime = GetTimeStamp()
			pChat.lastBackupReminderDateTime = lastBackupReminderDateTime
			pChat.lastBackupReminderDoneStr = os.date("%c", lastBackupReminderDateTime)
		end

		if settings.backupYourSavedVariablesReminderDone[apiVersion] == nil then
			lastBackupReminderNotFound()
		else
			local lastRemindedApiVersion = apiVersion
			if settings.backupYourSavedVariablesReminderDone[apiVersion].reminded == true then
				if settings.backupYourSavedVariablesReminderDone[apiVersion].timestamp ~= nil then
					pChat.lastBackupReminderWasFound = true
				end
			end
			if not pChat.lastBackupReminderWasFound and lastRemindedApiVersion == apiVersion then
				--No reminder at current API version found, maybe the last APIversion has shown a reminder?
				--Check the last 3 APIversions and else show the reminder again
				for i=1, 3, 1 do
					lastRemindedApiVersion = lastRemindedApiVersion - 1
					if not pChat.lastBackupReminderWasFound and
							settings.backupYourSavedVariablesReminderDone[lastRemindedApiVersion] ~= nil and
							settings.backupYourSavedVariablesReminderDone[lastRemindedApiVersion].reminded == true then
						pChat.lastBackupReminderWasFound = true
						break
					end
				end
			end

			--Any last reminder was found?
			if pChat.lastBackupReminderWasFound == true then
				local lastReminderData = settings.backupYourSavedVariablesReminderDone[lastRemindedApiVersion]
				if lastReminderData.timestamp == nil then
					pChat.lastBackupReminderDoneStr = "ESO API version \'" .. tostring(lastRemindedApiVersion) .. "\'"
				else
					pChat.lastBackupReminderDoneStr = os.date("%c", lastReminderData.timestamp)
				end
			else
				lastBackupReminderNotFound()
			end
		end
	end

	local function migrateSavedVarsToServerDependent()
		local migrationInfoOutput = pChat.migrationInfoOutput
		--Variable for EVENT_PLAYER_ACTIVATED
		pChat.migrationReloadUI = nil

		--Load the SavedVariables
		local worldName = GetWorldName()
		--savedVariableTable, version, namespace, defaults, profile, displayName
		db = ZO_SavedVars:NewAccountWide(ADDON_SV_NAME, ADDON_SV_VERSION, nil, defaults, worldName, nil)
		--Migrate the SV from non-server to server SV
		if db.migratedSVToServer == nil then
			migrationInfoOutput("Migrating the SavedVariables to the server \'" ..tostring(worldName) .. "\' now...", true, false)
			local displayName = GetDisplayName()
			if not _G[ADDON_SV_NAME] or not _G[ADDON_SV_NAME] ["Default"] or not _G[ADDON_SV_NAME]["Default"][displayName] or not _G[ADDON_SV_NAME]["Default"][displayName]["$AccountWide"] then
				--New pChat user with no non-server SV created yet. No migration needed
				migrationInfoOutput("Migration of the SavedVariables to the server \'" ..tostring(worldName) .. "\' not started as there is no non-server SV data available to migrate!", false, false)
				migrationInfoOutput(">Using default values for the server dependent SavedVariables.", false, false)
				db.migratedSVToServer = true
				pChat.migrationReloadUI = 2
				return
			end
			local dbOld = _G[ADDON_SV_NAME]["Default"][displayName]["$AccountWide"]
			--Do the old SV exist with recently new pChat data?
			if dbOld and dbOld.colours ~= nil then
				local dbOldCopy = ZO_ShallowTableCopy(dbOld)
				_G[ADDON_SV_NAME][worldName][displayName]["$AccountWide"] = nil
				db = ZO_SavedVars:NewAccountWide(ADDON_SV_NAME, ADDON_SV_VERSION, nil, dbOldCopy, worldName, nil)
				db.migratedSVToServer = false
				migrationInfoOutput("Migration of the SavedVariables to the server \'" ..tostring(worldName) .. "\' done.\nReloading the UI now to save the data to the disk.", true, true)
				pChat.migrationReloadUI = 1
			else
				migrationInfoOutput("Migration of the SavedVariables to the server \'" ..tostring(worldName) .. "\' not started as there is no non-server SV data available to migrate!", false, false)
				migrationInfoOutput(">Using default values for the server dependent SavedVariables.", false, false)
				db.migratedSVToServer = true
				pChat.migrationReloadUI = 2
			end
		else
			logger:Debug("[SavedVariables migration] db.migratedSVToServer: " ..tostring(db.migratedSVToServer))

			--SV were migrated already
			if db.migratedSVToServer == false then
				migrationInfoOutput("Successfully migrated the SavedVariables to the server \'" ..tostring(worldName) .. "\'", true, true)
				migrationInfoOutput(">Non-server dependent SavedVariables for your account \'"..GetDisplayName().."\' can be deleted via the slash command \'/pchatdeleteoldsv\'!", true, false)
            	migrationInfoOutput(">Attention: If you want to copy the SVs to another server login to that other server first BEFORE deleting the non-server dependent SavedVariables, because they will be taken as the base to copy!", true, false)
				db.migratedSVToServer = true
				pChat.migrationReloadUI = 3
			end
		end
	end

	--Check the name format (character, @account/character, ...) and migrate old "strings" / guild names to the new numbers / guildId
	local function checkNameFormat()
		--Migrate the old guild settings from guildName to guildId
		for guildIndex = 1, GetNumGuilds() do
			-- Guildname
			local guildId = GetGuildId(guildIndex)
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

			--Check the guild channel message format - formatGuild
			if db.formatguild ~= nil then
				local formatguildWithGuildName = db.formatguild[guildName]
				--Check if db.formatguild[guildName] is not a number and then change it to the appropriate number
				-->e.g. do not copy over old strings like "username@Account"
				local formatValue
				if formatguildWithGuildName ~= nil and type(formatguildWithGuildName) == "string" then
					formatValue = ZO_IndexOfElementInNumericallyIndexedTable(formatNameChoices, formatguildWithGuildName)
				else
					formatValue = db.formatguild[guildId]
				end
				if formatValue == nil or type(formatValue) ~= "number" or formatValue <= 0 then
--d(">resetting guildformat to character, for guild: " ..tostring(guildName))
					formatValue = 2 --default/fallback value for guild messages: Character name
				end
				--Remove old guildName entry
				db.formatguild[guildName] = nil
				--Set new guildId value to guildformat
				db.formatguild[guildId] = formatValue
			end
		end

		--Check the group channel message format - groupName
		local newFormatValue
		local chosenGroupNameFormat = db.groupNames
		newFormatValue = db.groupNames
		if chosenGroupNameFormat and type(chosenGroupNameFormat) == "string" then
			--Change to the relating "number" value, or the default number
			newFormatValue = ZO_IndexOfElementInNumericallyIndexedTable(formatNameChoices, chosenGroupNameFormat)
		end
		if newFormatValue == nil or type(newFormatValue) ~= "number" or newFormatValue <= 0 then
			newFormatValue = defaults.groupNames --default/fallback value
		end
		db.groupNames = newFormatValue

		--Check the zone/other channel message format - geoChannels
		local chosenGeoChannelsFormat = db.geoChannelsFormat
		newFormatValue = db.geoChannelsFormat
		if chosenGeoChannelsFormat and type(chosenGeoChannelsFormat) == "string" then
			--Change to the relating "number" value, or the default number
			newFormatValue = ZO_IndexOfElementInNumericallyIndexedTable(formatNameChoices, chosenGeoChannelsFormat)
		end
		if newFormatValue == nil or type(newFormatValue) ~= "number" or newFormatValue <= 0 then
			newFormatValue = defaults.geoChannelsFormat --default/fallback value
		end
		db.geoChannelsFormat = newFormatValue
	end

	--After loading the SavedVariables check some values, and update them
	local function AfterSettings()
		migrateToCharacterIdSavedVars()
		checkNameFormat()
		getLastBackupSVReminderText()
	end


	--Migrate old non-server dependent SavedVariables to new server dependent ones
	migrateSavedVarsToServerDependent()

	pChat.db = db

	--Change settings before optionsmenu etc.
	AfterSettings()

	--LAM and db for saved vars
	GetDBAndBuildLAM()

	--Load the nicknames from the settings
	BuildNicknames()

	-- Save all guild indices
	SaveGuildIndexes()

	-- Register OnSelfJoinedGuild with EVENT_GUILD_SELF_JOINED_GUILD
	EM:RegisterForEvent(ADDON_NAME, EVENT_GUILD_SELF_JOINED_GUILD, OnSelfJoinedGuild)

	-- Register OnSelfLeftGuild with EVENT_GUILD_SELF_LEFT_GUILD
	EM:RegisterForEvent(ADDON_NAME, EVENT_GUILD_SELF_LEFT_GUILD, OnSelfLeftGuild)

	return db
end
