--=======================================================================================================================================
--Known problems/bugs:
--Last updated: 2020-02-28
--Total number: 2
------------------------------------------------------------------------------------------------------------------------
--#1	2020-02-20 Baetram, bug (ZOs needs to fix!): Chat handlers for formatters etc. not working. See event_player_activated and file pChat_chatHandlers.lua
--	 	ZOs chat changes with Harrowstorm destroyed the chat handlers. Currently LibChatmessage restores them so pChat can overwrite the event formatter function of ChatProxy.
--	 	Needs to be fixed after ZOs fixed the event handlers to accept Chatproxy vanilla UI + other addons again!
------------------------------------------------------------------------------------------------------------------------
--#2	2020-02-28 Baetram, bug: New selection for @accountName/character chat prefix will only show /charactername (@accountName is missing) during whispers,
--		if clicked on a character in the chat to whisper him/her
------------------------------------------------------------------------------------------------------------------------
--=======================================================================================================================================

--  pChat object will receive functions
pChat = pChat or {}

-- Common
local ADDON_NAME	= "pChat"
local ADDON_VERSION	= "9.4.1.4"
local ADDON_AUTHOR	= "Ayantir, DesertDwellers, Baertram (current)"
local ADDON_WEBSITE	= "http://www.esoui.com/downloads/info93-pChat.html"

-- Registering libraries
--> See function loadLibraries() below! Called at EVEN_ADD_ON_LOADED
-- [Needed]
--LibAddonMenu-2.0
local LAM
--LibMediaProvider
local LMP
--LibMainMenu (NOT LibMainMenu-2.0!)
local MENU_CATEGORY_PCHAT
local LMM
local LCM
local function LoadLMM(calledWhen)
	calledWhen = calledWhen or "n/a"
	LMM = LibMainMenu
	if not LMM and LibStub then LMM = LibStub("LibMainMenu", false) end
	if LMM == nil or LMM.AddCategory == nil then
		d(string.format(GetString(PCHAT_LIB_MISSING), "LibMainMenu") .. "\n->Check: " ..tostring(calledWhen))
		d(">pChat should work normally except you cannot use the slash command '/msg' or open the pre-defined messages UI properly!")
		d(">>If you see this message be sure to read the first \'sticky \' comment in the pChat addon at\n> https://www.esoui.com/downloads/fileinfo.php?id=93#comments\n")
		d(">>Read the section \'Known incompatiblity with other addons\' and follow the steps to fix the old embedded LibMainMenu in these other addons!")
		d(">>[Attention] Please do not confuse LibMainMenu (needed within pChat) with LibMainMenu-2.0 (needed in other addons)!")
	end
	pChat.LMM = LMM
	--assert((LMM and LMM.AddCategory), string.format(GetString(PCHAT_LIB_MISSING), "LibMainMenu") .. "\n->Check: " ..tostring(calledWhen))
end
--[Optional]
--LibCustomTitles
local LCT

-- Init
local isAddonLoaded			= false -- OnAddonLoaded() done
local isAddonInitialized	= false

-- Preventer variables
local preventWhisperNotificationsFromHistory = false
local eventPlayerActivatedCheckRunning = false
local eventPlayerActivatedChecksDone = 0

--Variables
pChat.tabNames = {}

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

-- SV
local db
local targetToWhisp

--Constants
local gamepadMode = IsInGamepadPreferredMode()
--Chat Tab template names
local constTabNameTemplate = "ZO_ChatWindowTabTemplate"

-- pChatData will receive variables and objects.
local pChatData = {
	cachedMessages = {}, -- This one must be init before OnAddonLoaded because it will receive data before this event.
}

-- Used for pChat LinkHandling
local PCHAT_LINK = "p"
local PCHAT_URL_CHAN = 97
local PCHAT_CHANNEL_SAY = 98
local PCHAT_CHANNEL_NONE = 99

-- Init Automated Messages
local automatedMessagesList = ZO_SortFilterList:Subclass()

-- Backuping AddMessage for internal debug - AVOID DOING A CHAT_SYSTEM:AddMessage() in pChat, it can cause recursive calls
CHAT_SYSTEM.Zo_AddMessage = CHAT_SYSTEM.AddMessage
function pChat.debug(debugText)
	if not debugText or debugText == "" then return end
	if not LibDebugLogger or not pChat.logger then
		CHAT_SYSTEM.Zo_AddMessage(debugText)
	else
		local logger = pChat.logger
		if logger then logger:Debug(debugText) end
	end
end
local debug = pChat.debug

local function getClassIcon(classId)
    --* GetClassInfo(*luaindex* _index_)
    -- @return defId integer,lore string,normalIconKeyboard textureName,pressedIconKeyboard textureName,mouseoverIconKeyboard textureName,isSelectable bool,ingameIconKeyboard textureName,ingameIconGamepad textureName,normalIconGamepad textureName,pressedIconGamepad textureName
    local classLuaIndex = GetClassIndexById(classId)
    local _, _, textureName, _, _, _, ingameIconKeyboard, _, _, _= GetClassInfo(classLuaIndex)
    return ingameIconKeyboard or textureName or ""
end

local function decorateCharName(charName, classId, decorate)
    if not charName or charName == "" then return "" end
    if not classId then return charName end
    decorate = decorate or false
    if not decorate then return charName end
    local charNameDecorated
    --Get the class color
    local charColorDef = GetClassColor(classId)
    --Apply the class color to the charname
    if nil ~= charColorDef then charNameDecorated = charColorDef:Colorize(charName) end
    --Apply the class textures to the charname
    charNameDecorated = zo_iconTextFormatNoSpace(getClassIcon(classId), 20, 20, charNameDecorated)
    return charNameDecorated
end

--Build the table of all characters of the account
local function getCharactersOfAccount(keyIsCharName, decorate)
    decorate = decorate or false
    keyIsCharName = keyIsCharName or false
    local charactersOfAccount
    --Check all the characters of the account
    for i = 1, GetNumCharacters() do
        --GetCharacterInfo() -> *string* _name_, *[Gender|#Gender]* _gender_, *integer* _level_, *integer* _classId_, *integer* _raceId_, *[Alliance|#Alliance]* _alliance_, *string* _id_, *integer* _locationId_
        local name, gender, level, classId, raceId, alliance, characterId, location = GetCharacterInfo(i)
        local charName = zo_strformat(SI_UNIT_NAME, name)
        if characterId ~= nil and charName ~= "" then
            if charactersOfAccount == nil then charactersOfAccount = {} end
            charName = decorateCharName(charName, classId, decorate)
            if keyIsCharName then
                charactersOfAccount[charName]   = characterId
            else
                charactersOfAccount[characterId]= charName
            end
        end
    end
    return charactersOfAccount
end

--[[
PCHAT_LINK format : ZO_LinkHandler_CreateLink(message, nil, PCHAT_LINK, data)
message = message to display, nil (ignored by ZO_LinkHandler_CreateLink), PCHAT_LINK : declaration
data : strings separated by ":"
1st arg is chancode like CHAT_CHANNEL_GUILD_1
]]--

local ChanInfoArray

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

pChatData.defaultChannels = {
	PCHAT_CHANNEL_NONE,
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

local chatStrings =
{
	standard = "%s%s: |r%s%s%s|r", -- standard format: say, yell, group, npc, npc yell, npc whisper, zone
	esostandart = "%s%s %s: |r%s%s%s|r", -- standard format: say, yell, group, npc, npc yell, npc whisper, zone with tag (except for monsters)
	esoparty = "%s%s%s: |r%s%s%s|r", -- standard format: party
	tellIn = "%s%s: |r%s%s%s|r", -- tell in
	tellOut = "%s-> %s: |r%s%s%s|r", -- tell out
	emote = "%s%s |r%s%s|r", -- emote
	guild = "%s%s %s: |r%s%s%s|r", -- guild
	language = "%s[%s] %s: |r%s%s%s|r", -- language zones

	-- For copy System, only Handle "From part"

	copystandard = "[%s]: ", -- standard format: say, yell, group, npc, npc yell, npc whisper, zone
	copyesostandard = "[%s] %s: ", -- standard format: say, yell, group, npc, npc yell, npc whisper, zone with tag (except for monsters)
	copyesoparty = "[%s]%s: ", -- standard format: party
	copytellIn = "[%s]: ", -- tell in
	copytellOut = "-> [%s]: ", -- tell out
	copyemote = "%s ", -- emote
	copyguild = "[%s] [%s]: ", -- guild
	copylanguage = "[%s] %s: ", -- language zones
	copynpc = "%s: ", -- language zones
}

-- Return true/false if text is a flood
local function SpamFlood(from, text, chanCode)

	-- 2+ messages identiqual in less than 30 seconds on Character channels = spam

	-- Should not happen
	if db.LineStrings then

		if db.lineNumber then
			-- 1st message cannot be a spam
			if db.lineNumber > 1 then

				local checkSpam = true
				local previousLine = db.lineNumber - 1
				local ourMessageTimestamp = GetTimeStamp()

				while checkSpam do

					-- Previous line can be a ChanSystem one
					if db.LineStrings[previousLine].channel ~= CHAT_CHANNEL_SYSTEM then
						if (ourMessageTimestamp - db.LineStrings[previousLine].rawTimestamp) < db.floodGracePeriod then
							-- if our message is sent by our chatter / will be break by "Character" channels and "UserID" Channels
							if from == db.LineStrings[previousLine].rawFrom then
								-- if our message is eq of last message
								if text == db.LineStrings[previousLine].rawText then
									-- Previous and current must be in zone(s), yell, say, emote (Character Channels except party)
									-- TODO: Find a characterchannel func

									-- CHAT_CHANNEL_SAY = 0 == nil in lua, will broke the array, so use PCHAT_CHANNEL_SAY
									local spamChanCode = chanCode
									if spamChanCode == CHAT_CHANNEL_SAY then
										spamChanCode = PCHAT_CHANNEL_SAY
									end

									local spammableChannels = {}
									spammableChannels[CHAT_CHANNEL_ZONE_LANGUAGE_1] = true
									spammableChannels[CHAT_CHANNEL_ZONE_LANGUAGE_2] = true
									spammableChannels[CHAT_CHANNEL_ZONE_LANGUAGE_3] = true
									spammableChannels[CHAT_CHANNEL_ZONE_LANGUAGE_4] = true
									spammableChannels[PCHAT_CHANNEL_SAY] = true
									spammableChannels[CHAT_CHANNEL_YELL] = true
									spammableChannels[CHAT_CHANNEL_ZONE] = true
									spammableChannels[CHAT_CHANNEL_EMOTE] = true

									-- spammableChannels[spamChanCode] = return true if our message was sent in a spammable channel
									-- spammableChannels[db.LineStrings[previousLine].channel] = return true if previous message was sent in a spammable channel
									if spammableChannels[spamChanCode] and spammableChannels[db.LineStrings[previousLine].channel] then
										-- Spam
										--debug("Spam detected ( " .. text ..  " )")
										return true
									end
								end
							end
						else
							-- > 30s, stop analyzis
							checkSpam = false
						end
					end

					if previousLine > 1 then
						previousLine = previousLine - 1
					else
						checkSpam = false
					end

				end

			end
		end

	end

	return false

end

-- Return true/false if text is a LFG message
local function SpamLookingFor(text)

	local spamStrings = {
		[1] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[mMgG]",
		[2] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[hH][eE][aA][lL]",
		[3] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[dD][dD]",
		[4] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[dD][pP][sS]",
		[5] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[tT][aA][nN][kK]",
		[6] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[dD][aA][iI][lL][yY]",
		[7] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[sS][iI][lL][vV][eE][rR]",
		[8] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[gG][oO][lL][dD]", -- bypassed by first rule
		[9] = "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[dD][uU][nN][gG][eE][oO][nN]",
	}

	for _, spamString in ipairs(spamStrings) do
		if string.find(text, spamString) then
			--debug("spamLookingFor:" .. text .." ;spamString=" .. spamString)
			return true
		end
	end

	return false

end

-- Return true/false if text is a WTT message
local function SpamWantTo(text)

	-- "w.T S"
	if string.find(text, "[wW][%s.]?[tT][%s.]?[bBsStT]") then

		-- Item Handler
		if string.find(text, "|H(.-):item:(.-)|h(.-)|h") then
			-- Match
			--debug("WT detected ( " .. text .. " )")
			return true
		elseif string.find(text, "[Ww][Ww][%s]+[Bb][Ii][Tt][Ee]") then
			-- Match
			--debug("WT WW Bite detected ( " .. text .. " )")
			return true
		end

	end

	return false

end

-- Return true/false if text is a Guild recruitment one
local function SpamGuildRecruit(text, chanCode)

	-- Guild Recruitment message are too complex to only use 1/2 patterns, an heuristic method must be used

	-- 1st is channel. only check geographic channels (character ones)
	-- 2nd is text len, they're generally long ones
	-- Then, presence of certain words

	--debug("GR analizis")

	local spamChanCode = chanCode
	if spamChanCode == CHAT_CHANNEL_SAY then
		spamChanCode = PCHAT_CHANNEL_SAY
	end

	local spammableChannels = {}
	spammableChannels[CHAT_CHANNEL_ZONE_LANGUAGE_1] = true
	spammableChannels[CHAT_CHANNEL_ZONE_LANGUAGE_2] = true
	spammableChannels[CHAT_CHANNEL_ZONE_LANGUAGE_3] = true
	spammableChannels[CHAT_CHANNEL_ZONE_LANGUAGE_4] = true
	spammableChannels[PCHAT_CHANNEL_SAY] = true
	spammableChannels[CHAT_CHANNEL_YELL] = true
	spammableChannels[CHAT_CHANNEL_ZONE] = true
	spammableChannels[CHAT_CHANNEL_EMOTE] = true

	local spamStrings = {
		["[Ll]ooking [Ff]or ([Nn]ew+) [Mm]embers"] = 5, -- looking for (new) members
		["%d%d%d\+"] = 5, -- 398+
		["%d%d%d\/500"] = 5, -- 398/500
		["gilde"] = 1, -- 398/500
		["guild"] = 1, -- 398/500
		["[Tt][Ee][Aa][Mm][Ss][Pp][Ee][Aa][Kk]"] = 1,
	}

	--[[

Polska gildia <OUTLAWS> po stronie DC rekrutuje! Oferujemy triale, eventy pvp, dungeony, hardmody, porady doswiadczonych graczy oraz mila atmosfere. Wymagamy TS-a i mikrofonu. "OUTLAWS gildia dla ludzi chcacych tworzyc gildie, a nie tylko byc w gildii!" W sprawie rekrutacji zloz podanie na www.outlawseso.guildlaunch.com lub napisz w grze.
Seid gegrüßt liebe Abenteurer.  Eine der ältesten aktiven Handelsgilden (seit 30.03.14), Caveat Emptor (deutschsprachig), hat wieder Plätze frei. (490+ Mitglieder). Gildenhändler vorhanden! /w bei Interesse
Salut. L'esprit d'équipe est quelque chose qui vous parle ? Relever les plus haut défis en PvE comme en PvP et  RvR vous tente, mais vous ne voulez pas sacrifier votre IRL pour cela ? Empirium League est construite autours de tous ces principes. /w pour plus d'infos ou sur Empiriumleague.com
Die Gilde Drachenstern sucht noch Aktive Member ab V1 für gemeinsamen Spaß und Erfolg:) unserer aktueller Raidcontent ist Sanctum/HelRah und AA unsere Raidtage sind Mittwoch/Freitags und Sonntag bei Fragen/Intresse einfach tell/me:)
Anyone wants to join a BIG ACTIVE TRADE GUILD? Then join Daggerfall Trade Masters 493/500 MEMBERS--5DAYS ACTIVITY--_TEAMSPEAK--CRAGLORN FRONT ROW TRADER (SHELZAKA) Whisper me for invite and start BUYING and SELLING right NOW!
The Cambridge Alliance is a multi-faction social guild based in the UK.  Send me a whisper if you would like to join!  www.cambridge-alliance.co.uk
Rejoignez le Comptoir de Bordeciel, Guilde Internationale de Trade (490+) présente depuis la release. Bénéficiez de nos prices check grâce à un historique de vente et bénéficiez d’estimations réelles. Les taxes sont investies dans le marchand de guilde. Envoyez-moi par mp le code « CDC » pour invitation auto
Valeureux soldats de l'Alliance, rejoignez l'Ordre des Ombres, combattez pour la gloire de Daguefillante, pour la victoire, et la conquète du trône impérial ! -- Mumble et site -- Guilde PVE-PVP -- 18+ -- MP pour info
Join Honour. A well established guild with over 10 years gaming experience and almost 500 active members. We run a full week of Undaunted, Trials, Cyrodiil and low level helper nights. With a social and helpful community and great crafting support. Check out our forums www.honourforever.com. /w for invite
{L'Ordre des Ombres} construite sur l'entraide, la sympathie et bonne ambiance vous invite a rejoindre ses rangs afin de profiter au maximum de TESO. www.ordredesombres.fr Cordialement - Chems
The new guild Auctionhouse Extended is recruiting players, who want to buy or sell items! (300+ member
Totalitarnaya Destructivnaya Sekta "Cadwell's Honor" nabiraet otvazhnyh i bezbashennyh rakov, krabov i drugie moreprodukty v svoi tesnye ryady!! PvE, PvP, TS, neobychnyi RP i prochie huliganstva. Nam nuzhny vashi kleshni!! TeamSpeak dlya priema cadwells-honor.ru
you look for a guild (united trade post / 490+ member) for trade, pve and all other things in eso without obligations? /w me for invitation --- du suchst eine gilde (united trade post / 490+ mitglieder) für handel, pve und alle anderen dinge in eso ohne verpflichtungen. /w me
[The Warehouse] Trading Guild Looking for Members! /w me for Invite :)
Russian guild Daggerfall Bandits is looking for new members! We are the biggest and the most active russian community in Covenant. Regular PvE and PvP raids to normal and hard mode content! 490+ members. Whisper me.
  Bonjour, la Guilde La Flibuste recherche des joueurs francophones.  Sans conditions et pour jouer dans la bonne humeur, notre guilde est ouverte à tous.  On recherche des joueurs de toutes les classes et vétérang pour compléter nos raids.  Pour plus d'infos, c'est ici :) Merci et bon jeu.

	]]--

	-- Our note. Per default, each message get its heuristic level to 0
	local guildHeuristics = 0

	-- spammableChannels[db.LineStrings[previousLine].channel] = return true if previous message was sent in a spammable channel
	if spammableChannels[spamChanCode] then

		local textLen = string.len(text)
		local text300 = (string.len(text) > 300) -- 50
		local text250 = (string.len(text) > 250) -- 40
		local text200 = (string.len(text) > 200) -- 30
		local text150 = (string.len(text) > 150) -- 20
		local text100 = (string.len(text) > 100) -- 10
		local text30  = (string.len(text) > 30)  -- 0

		-- 30 chars are needed to make a phrase of guild recruitment. If recruiter spam in SMS, pChat won't handle it.
		if text30 then

			-- Each message can possibly be a spam, let's wrote our checklist
			--debug("GR Len ( " .. textLen .. " )")

			if text300 then
				guildHeuristics = 50
			elseif text250 then
				guildHeuristics = 40
			elseif text200 then
				guildHeuristics = 30
			elseif text150 then
				guildHeuristics = 20
			elseif text100 then
				guildHeuristics = 10
			end

			-- Still to do

			for spamString, value in ipairs(spamStrings) do
				if string.find(text, spamString) then
					--debug(spamString)
					guildHeuristics = guildHeuristics + value
				end
			end

			if guildHeuristics > 60 then
				--debug("GR : true (score=" .. guildHeuristics .. ")")
				return true
			end

		end

	end

	--debug("GR : false (score=" .. guildHeuristics .. ")")
	return false

end

-- Return true/false if anti spam is enabled for a certain category
-- Categories must be : Flood, LookingFor, WantTo, GuildRecruit
local function IsSpamEnabledForCategory(category)

	if category == "Flood" then

		-- Enabled in Options?
		if db.floodProtect then
			--debug("floodProtect enabled")
			-- AntiSpam is enabled
			return true
		end

		--debug("floodProtect disabled")
		-- AntiSpam is disabled
		return false

	-- LFG
	elseif category == "LookingFor" then
		-- Enabled in Options?
		if db.lookingForProtect then
			-- Enabled in reality?
			if pChatData.spamLookingForEnabled then
				--debug("lookingForProtect enabled")
				-- AntiSpam is enabled
				return true
			else

				--debug("lookingForProtect is temporary disabled since " .. pChat.spamTempLookingForStopTimestamp)

				-- AntiSpam is disabled .. since -/+ grace time ?
				if GetTimeStamp() - pChatData.spamTempLookingForStopTimestamp > (db.spamGracePeriod * 60) then
					--debug("lookingForProtect enabled again")
					-- Grace period outdatted -> we need to re-enable it
					pChatData.spamLookingForEnabled = true
					return true
				end
			end
		end

		--debug("lookingForProtect disabled")
		-- AntiSpam is disabled
		return false

	-- WTT
	elseif category == "WantTo" then
		-- Enabled in Options?
		if db.wantToProtect then
			-- Enabled in reality?
			if pChatData.spamWantToEnabled then
				--debug("wantToProtect enabled")
				-- AntiSpam is enabled
				return true
			else
				-- AntiSpam is disabled .. since -/+ grace time ?
				if GetTimeStamp() - pChatData.spamTempWantToStopTimestamp > (db.spamGracePeriod * 60) then
					--debug("wantToProtect enabled again")
					-- Grace period outdatted -> we need to re-enable it
					pChatData.spamWantToEnabled = true
					return true
				end
			end
		end

		--debug("wantToProtect disabled")
		-- AntiSpam is disabled
		return false

	-- Join my Awesome guild
	elseif category == "GuildRecruit" then
		-- Enabled in Options?
		if db.guildRecruitProtect then
			-- Enabled in reality?
			if pChatData.spamGuildRecruitEnabled then
				-- AntiSpam is enabled
				return true
			else
				-- AntiSpam is disabled .. since -/+ grace time ?
				if GetTimeStamp() - pChatData.spamTempGuildRecruitStopTimestamp > (db.spamGracePeriod * 60) then
					-- Grace period outdatted -> we need to re-enable it
					pChatData.spamGuildRecruitEnabled = true
					return true
				end
			end
		end

		-- AntiSpam is disabled
		return false

	end

end

-- Return true is message is a spam depending on MANY parameters
local function SpamFilter(chanCode, from, text, isCS)

	-- 5 options for spam : Spam (multiple messages) ; LFM/LFG ; WT(T/S/B) ; Guild Recruitment ; Gold Spamming for various websites

	-- ZOS GM are NEVER blocked
	if isCS then
		return false
	end

	-- CHAT_CHANNEL_PARTY is not spamfiltered, party leader get its own antispam tool (= kick)
	if chanCode == CHAT_CHANNEL_PARTY then
		return false
	end

	-- "I" or anyone do not flood
	if IsSpamEnabledForCategory("Flood") then
		if SpamFlood(from, text, chanCode) then return true end
	end

	-- But "I" can have exceptions
	if zo_strformat(SI_UNIT_NAME, from) == pChatData.localPlayer or from == GetDisplayName() then

		--debug("I say something ( " .. text .. " )")

		if IsSpamEnabledForCategory("LookingFor") then
			-- "I" can look for a group
			if SpamLookingFor(text) then

				--debug("I say a LF Message ( " .. text .. " )")

				-- If I break myself the rule, disable it few minutes
				pChatData.spamTempLookingForStopTimestamp = GetTimeStamp()
				pChatData.spamLookingForEnabled = false

			end
		end

		if IsSpamEnabledForCategory("WantTo") then
			-- "I" can be a trader
			if SpamWantTo(text) then

				--debug("I say a WT Message ( " .. text .. " )")

				-- If I break myself the rule, disable it few minutes
				pChatData.spamTempWantToStopTimestamp = GetTimeStamp()
				pChatData.spamWantToStop = true

			end
		end

		--[[
		if IsSpamEnabledForCategory("GuildRecruit") then
			-- "I" can do some guild recruitment
			if SpamGuildRecruit(text, chanCode) then

				--debug("I say a GR Message ( " .. text .. " )")

				-- If I break myself the rule, disable it few minutes
				pChatData.spamTempGuildRecruitStopTimestamp = GetTimeStamp()
				pChatData.spamGuildRecruitStop = true

			end
		end
		]]--

		-- My message will be displayed in any case
		return false

	end

	-- Spam
	if IsSpamEnabledForCategory("Flood") then
		if SpamFlood(from, text, chanCode) then return true end
	end

	-- Looking For
	if IsSpamEnabledForCategory("LookingFor") then
		if SpamLookingFor(text) then return true end
	end

	-- Want To
	if IsSpamEnabledForCategory("WantTo") then
		if SpamWantTo(text) then return true end
	end

	-- Guild Recruit
	--[[
	if IsSpamEnabledForCategory("GuildRecruit") then
		if SpamGuildRecruit(text, chanCode) then return true end
	end
	]]--

	return false

end

-- Turn a ([0,1])^3 RGB colour to "|cABCDEF" form. We could use ZO_ColorDef, but we have so many colors so we don't do it.
local function ConvertRGBToHex(r, g, b)
	return string.format("|c%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

-- Convert a colour from "|cABCDEF" form to [0,1] RGB form.
local function ConvertHexToRGBA(colourString)
	local r=tonumber(string.sub(colourString, 3, 4), 16) or 255
	local g=tonumber(string.sub(colourString, 5, 6), 16) or 255
	local b=tonumber(string.sub(colourString, 7, 8), 16) or 255
	return r/255, g/255, b/255, 1
end

-- Return a formatted time
local function CreateTimestamp(timeStr, formatStr)
	formatStr = formatStr or db.timestampFormat

	-- split up default timestamp
	local hours, minutes, seconds = timeStr:match("([^%:]+):([^%:]+):([^%:]+)")
	local hoursNoLead = tonumber(hours) -- hours without leading zero
	local hours12NoLead = (hoursNoLead - 1)%12 + 1
	local hours12
	if (hours12NoLead < 10) then
		hours12 = "0" .. hours12NoLead
	else
		hours12 = hours12NoLead
	end
	local pUp = "AM"
	local pLow = "am"
	if (hoursNoLead >= 12) then
		pUp = "PM"
		pLow = "pm"
	end

	-- create new one
	local timestamp = formatStr
	timestamp = timestamp:gsub("HH", hours)
	timestamp = timestamp:gsub("H", hoursNoLead)
	timestamp = timestamp:gsub("hh", hours12)
	timestamp = timestamp:gsub("h", hours12NoLead)
	timestamp = timestamp:gsub("m", minutes)
	timestamp = timestamp:gsub("s", seconds)
	timestamp = timestamp:gsub("A", pUp)
	timestamp = timestamp:gsub("a", pLow)

	return timestamp

end

-- Format from name
local function ConvertName(chanCode, from, isCS, fromDisplayName)

	local function DisplayWithOrWoBrackets(realFrom, displayed, linkType)
		if not displayed then -- reported. Should not happen, maybe parser error with nicknames.
			displayed = realFrom
		end
		if db.disableBrackets then
			return ZO_LinkHandler_CreateLinkWithoutBrackets(displayed, nil, linkType, realFrom)
		else
			return ZO_LinkHandler_CreateLink(displayed, nil, linkType, realFrom)
		end
	end

	-- From can be UserID or Character name depending on wich channel we are
	local new_from = from

	-- Messages from @Someone (guild / whisps)
	if IsDecoratedDisplayName(from) then

		-- Guild / Officer chat only
		if chanCode >= CHAT_CHANNEL_GUILD_1 and chanCode <= CHAT_CHANNEL_OFFICER_5 then

			-- Get guild index based on channel id, and then get the guildId
			--local guildId = GetGuildId((chanCode - CHAT_CHANNEL_GUILD_1) % 5 + 1)
			local guildId = GetGuildId((chanCode - CHAT_CHANNEL_GUILD_1) % MAX_GUILDS + 1)
			--local guildName = GetGuildName(guildId)

			if pChatData.nicknames[new_from] then -- @UserID Nicknammed
				db.LineStrings[db.lineNumber].rawFrom = pChatData.nicknames[new_from]
				new_from = DisplayWithOrWoBrackets(new_from, pChatData.nicknames[new_from], DISPLAY_NAME_LINK_TYPE)
			elseif db.formatguild[guildId] == 2 then -- Char
				local _, characterName = GetGuildMemberCharacterInfo(guildId, GetGuildMemberIndexFromDisplayName(guildId, new_from))
				characterName = zo_strformat(SI_UNIT_NAME, characterName)
				local nickNamedName
				if pChatData.nicknames[characterName] then -- Char Nicknammed
					nickNamedName = pChatData.nicknames[characterName]
				end
				db.LineStrings[db.lineNumber].rawFrom = nickNamedName or characterName
				new_from = DisplayWithOrWoBrackets(characterName, nickNamedName or characterName, CHARACTER_LINK_TYPE)
			elseif db.formatguild[guildId] == 3 then -- Char@UserID
				local _, characterName = GetGuildMemberCharacterInfo(guildId, GetGuildMemberIndexFromDisplayName(guildId, new_from))
				characterName = zo_strformat(SI_UNIT_NAME, characterName)
				if characterName == "" then characterName = new_from end -- Some buggy rosters

				if pChatData.nicknames[characterName] then -- Char Nicknammed
					characterName = pChatData.nicknames[characterName]
				else
					characterName = characterName .. new_from
				end

				db.LineStrings[db.lineNumber].rawFrom = characterName
				new_from = DisplayWithOrWoBrackets(new_from, characterName, DISPLAY_NAME_LINK_TYPE)
			elseif db.formatguild[guildId] == 4 then -- @UserID/Char
				local _, characterName = GetGuildMemberCharacterInfo(guildId, GetGuildMemberIndexFromDisplayName(guildId, new_from))
				characterName = zo_strformat(SI_UNIT_NAME, characterName)
				if characterName == "" then characterName = new_from end -- Some buggy rosters

				if pChatData.nicknames[characterName] then -- Char Nicknammed
					characterName = pChatData.nicknames[characterName]
				else
					characterName = new_from .. "/" .. characterName
				end

				db.LineStrings[db.lineNumber].rawFrom = characterName
				new_from = DisplayWithOrWoBrackets(new_from, characterName, DISPLAY_NAME_LINK_TYPE)
			else
				db.LineStrings[db.lineNumber].rawFrom = new_from
				new_from = DisplayWithOrWoBrackets(new_from, new_from, DISPLAY_NAME_LINK_TYPE)
			end

		else
			-- Wisps with @ We can't guess characterName for those ones

			if pChatData.nicknames[new_from] then -- @UserID Nicknammed
				db.LineStrings[db.lineNumber].rawFrom = pChatData.nicknames[new_from]
				new_from = DisplayWithOrWoBrackets(new_from, pChatData.nicknames[new_from], DISPLAY_NAME_LINK_TYPE)
			else
				db.LineStrings[db.lineNumber].rawFrom = new_from
				new_from = DisplayWithOrWoBrackets(new_from, new_from, DISPLAY_NAME_LINK_TYPE)
			end

		end

	-- Geo chat, Party, Whisps with characterName
	else

		new_from = zo_strformat(SI_UNIT_NAME, new_from)

		local nicknamedFrom
		if pChatData.nicknames[new_from] then -- Character or Account Nicknammed
			nicknamedFrom = pChatData.nicknames[new_from]
		elseif pChatData.nicknames[fromDisplayName] then
			nicknamedFrom = pChatData.nicknames[fromDisplayName]
		end

		db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or new_from

		-- No brackets / UserID for emotes
		if chanCode == CHAT_CHANNEL_EMOTE then
			new_from = ZO_LinkHandler_CreateLinkWithoutBrackets(nicknamedFrom or new_from, nil, CHARACTER_LINK_TYPE, from)
		-- zones / whisps / say / tell. No Handler for NPC
		elseif not (chanCode == CHAT_CHANNEL_MONSTER_SAY or chanCode == CHAT_CHANNEL_MONSTER_YELL or chanCode == CHAT_CHANNEL_MONSTER_WHISPER or chanCode == CHAT_CHANNEL_MONSTER_EMOTE) then

			if chanCode == CHAT_CHANNEL_PARTY then
				if db.groupNames == 1 then
					db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or fromDisplayName
					new_from = DisplayWithOrWoBrackets(fromDisplayName, nicknamedFrom or fromDisplayName, DISPLAY_NAME_LINK_TYPE)
				elseif db.groupNames == 3 then
					new_from = new_from .. fromDisplayName
					db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or new_from
					new_from = DisplayWithOrWoBrackets(from, nicknamedFrom or new_from, CHARACTER_LINK_TYPE)
				elseif db.groupNames == 4 then
					new_from = fromDisplayName .. "/" .. new_from
					db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or new_from
					new_from = DisplayWithOrWoBrackets(from, nicknamedFrom or new_from, CHARACTER_LINK_TYPE)
				else
					db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or new_from
					new_from = DisplayWithOrWoBrackets(from, nicknamedFrom or new_from, CHARACTER_LINK_TYPE)
				end
			else
				if db.geoChannelsFormat == 1 then
					db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or fromDisplayName
					new_from = DisplayWithOrWoBrackets(fromDisplayName, nicknamedFrom or fromDisplayName, DISPLAY_NAME_LINK_TYPE)
				elseif db.geoChannelsFormat == 3 then
					new_from = new_from .. fromDisplayName
					db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or new_from
					new_from = DisplayWithOrWoBrackets(from, nicknamedFrom or new_from, CHARACTER_LINK_TYPE)
				elseif db.geoChannelsFormat == 4 then
					new_from = fromDisplayName .. "/" .. new_from
					db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or new_from
					new_from = DisplayWithOrWoBrackets(from, nicknamedFrom or new_from, CHARACTER_LINK_TYPE)
				else
					db.LineStrings[db.lineNumber].rawFrom = nicknamedFrom or new_from
					new_from = DisplayWithOrWoBrackets(from, nicknamedFrom or new_from, CHARACTER_LINK_TYPE)
				end
			end

		end

	end

	if isCS then -- ZOS icon
		new_from = "|t16:16:EsoUI/Art/ChatWindow/csIcon.dds|t" .. new_from
	end

	return new_from

end

local function UndockTextEntry()

	--local charName = pChatData.localPlayer or GetUnitName("player")
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

	local undockedTexture = WINDOW_MANAGER:CreateControl("UndockedBackground", ZO_ChatWindowTextEntry, CT_TEXTURE)
	undockedTexture:SetTexture("EsoUI/Art/Performance/StatusMeterMunge.dds")
	undockedTexture:SetAnchor(CENTER, ZO_ChatWindowTextEntry, CENTER, 0, 0)
	undockedTexture:SetDimensions(800, 250)

end

local function RedockTextEntry()

	-- Unfinished

	ZO_ChatWindowTextEntry:ClearAnchors()
	ZO_ChatWindowTextEntry:SetAnchor(BOTTOMLEFT, ZO_ChatWindowMinimize, BOTTOMRIGHT, -6, -13)
	ZO_ChatWindowTextEntry:SetAnchor(BOTTOMRIGHT, ZO_ChatWindow, BOTTOMRIGHT, -23, -13)
	ZO_ChatWindowTextEntry:SetMovable(false)

end


-- For console
function pChat.CMD_DEBUG()
	if pChat.DEBUG ~= 1 then
		d("pChat Debug : On")
		pChat.DEBUG = 1
	else
		d("pChat Debug : Off")
		pChat.DEBUG = 0
	end
end

-- For console quest time
function pChat.CMD_DEBUG1()
	if pChat.DEBUG ~= 2 then
		d("pChat Debug 2: On")
		pChat.DEBUG = 2
	else
		d("pChat Debug 2: Off")
		pChat.DEBUG = 0
	end
end

function pChat.CMD_DEBUG2()
	if pChat.DEBUG ~=3 then
		d("pChat Debug 3 : On")
		pChat.DEBUG = 3
	else
		d("pChat Debug 3 : Off")
		pChat.DEBUG = 0
	end
end


-- Also called by bindings
function pChat_ShowAutoMsg()
	LoadLMM("pChat - pChat_ShowAutoMsg")
	if LMM and LMM.ToggleCategory and MENU_CATEGORY_PCHAT then
		LMM:ToggleCategory(MENU_CATEGORY_PCHAT)
	end
end

-- Register Slash commands
SLASH_COMMANDS["/msg"] = pChat_ShowAutoMsg
SLASH_COMMANDS["/pchat_debug"] = pChat.CMD_DEBUG
SLASH_COMMANDS["/pchat_debug1"] = pChat.CMD_DEBUG1
SLASH_COMMANDS["/pchat_debug2"] = pChat.CMD_DEBUG2

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




function automatedMessagesList:New(control)

	ZO_SortFilterList.InitializeSortFilterList(self, control)

	local AutomatedMessagesSorterKeys =
	{
		["name"] = {},
		["message"] = {tiebreaker = "name"}
	}

 	self.masterList = {}
 	ZO_ScrollList_AddDataType(self.list, 1, "pChatXMLAutoMsgRowTemplate", 32, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, AutomatedMessagesSorterKeys, self.currentSortOrder) end
	--self:SetAlternateRowBackgrounds(true)

	return self

end

-- format ESO text to raw text
-- IE : Transforms LinkHandlers into their displayed value
local function FormatRawText(text)

	-- Strip colors from chat
	local newtext = string.gsub(text, "|[cC]%x%x%x%x%x%x", ""):gsub("|r", "")

	-- Transforms a LinkHandler into its localized displayed value
	-- "|H(.-):(.-)|h(.-)|h" = pattern for Linkhandlers
	-- Item : |H1:item:33753:25:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h = [Battaglir] in french -> Link to item 33753, etc
	-- Achievement |H1:achievement:33753|h|h etc (not searched a lot, was easy)
	-- DisplayName = |H1:display:Ayantir|h[@Ayantir]|h = [@Ayantir] -> link to DisplayName @Ayantir
	-- Book = |H1:book:186|h|h = [Climat de guerre] in french -> Link to book 186 .. GetLoreBookTitleFromLink()
	-- pChat = |H1:PCHAT_LINK:124:11|h[06:18]|h = [06:18] (here 0 is the line number reference and 11 is the chanCode) - URL handling : if chanCode = 97, it will popup a dialog to open internet browser
	-- Character = |H1:character:salhamandhil^Mx|h[salhamandhil]|h = text (is there anything which link Characters into a message ?) (here salhamandhil is with brackets volontary)
	-- Need to do quest_items too. |H1:quest_item:4275|h|h

	newtext = string.gsub(newtext, "|H(.-):(.-)|h(.-)|h", function (linkStyle, data, text)
		-- linkStyle = style (ignored by game, seems to be often 1)
		-- data = data saparated by ":"
		-- text = text displayed, used for Channels, DisplayName, Character, and some fake itemlinks (used by addons)

		-- linktype is : item, achievement, character, channel, book, display, pchatlink
		-- DOES NOT HANDLE ADDONS LINKTYPES

		-- for all types, only param1 is important
		local linkType, param1 = zo_strsplit(':', data)

		-- param1 : itemID
		-- Need to get
		if linkType == ITEM_LINK_TYPE or linkType == COLLECTIBLE_LINK_TYPE then
			-- Fakelink and GetItemLinkName
			return "[" .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H" .. linkStyle ..":" .. data .. "|h|h")) .. "]"
		-- param1 : achievementID
		elseif linkType == ACHIEVEMENT_LINK_TYPE then
			-- zo_strformat to avoid masculine/feminine problems
			return "[" .. zo_strformat(GetAchievementInfo(param1)) .. "]"
		-- SysMessages Links CharacterNames
		elseif linkType == CHARACTER_LINK_TYPE then
			return text
		elseif linkType == CHANNEL_LINK_TYPE then
			return text
		elseif linkType == BOOK_LINK_TYPE then
			return "[" .. GetLoreBookTitleFromLink(newtext) .. "]"
		-- SysMessages Links DysplayNames
		elseif linkType == DISPLAY_NAME_LINK_TYPE then
			-- No formatting here
			return "[@" .. param1 .. "]"
		-- Used for Sysmessages
		elseif linkType == "quest_item" then
			-- No formatting here
			return "[" .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetQuestItemNameFromLink(newtext)) .. "]"
		elseif linkType == PCHAT_LINK then
			-- No formatting here .. maybe yes ?..
			return text
		end
	end)

	return newtext

end

function automatedMessagesList:SetupEntry(control, data)

	control.data = data
	control.name = GetControl(control, "Name")
	control.message = GetControl(control, "Message")

	local messageTrunc = FormatRawText(data.message)
	if string.len(messageTrunc) > 53 then
		messageTrunc = string.sub(messageTrunc, 1, 53) .. " .."
	end

	control.name:SetText(data.name)
	control.message:SetText(messageTrunc)

	ZO_SortFilterList.SetupRow(self, control, data)

end

function automatedMessagesList:BuildMasterList()
	self.masterList = {}
	local messages = db.automatedMessages
	if messages then
		for k, v in ipairs(messages) do
			local data = v
			table.insert(self.masterList, data)
		end
	end

end

function automatedMessagesList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

function automatedMessagesList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

local function GetDataByNameInSavedAutomatedMessages(name)
	local dataList = db.automatedMessages
	for index, data in ipairs(dataList) do
		if(data.name == name) then
			return data, index
		end
	end
end

local function GetDataByNameInAutomatedMessages(name)
	local dataList = pChatData.automatedMessagesList.list.data
	for i = 1, #dataList do
		local data = dataList[i].data
		if(data.name == name) then
			return data, index
		end
	end
end

local function SaveAutomatedMessage(name, message, isNew)

	if db then

		local alreadyFav = false

		if isNew then
			for k, v in pairs(db.automatedMessages) do
				if "!" .. name == v.name then
					alreadyFav = true
				end
			end
		end

		if not alreadyFav then

			pChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(true)
			pChatXMLAutoMsg:GetNamedChild("Warning"):SetText("")

			if string.len(name) > 12 then
				name = string.sub(name, 1, 12)
			end

			if string.len(message) > 351 then
				message = string.sub(message, 1, 351)
			end

			local entryList = ZO_ScrollList_GetDataList(pChatData.automatedMessagesList.list)

			if isNew then
				local data = {name = "!" .. name, message = message}
				local entry = ZO_ScrollList_CreateDataEntry(1, data)
				table.insert(entryList, entry)
				table.insert(db.automatedMessages, {name = "!" .. name, message = message}) -- "data" variable is modified by ZO_ScrollList_CreateDataEntry and will crash eso if saved to savedvars
			else

				local data = GetDataByNameInAutomatedMessages(name)
				local _, index = GetDataByNameInSavedAutomatedMessages(name)

				data.message = message
				db.automatedMessages[index].message = message
			end

			ZO_ScrollList_Commit(pChatData.automatedMessagesList.list)

		else
			pChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(false)
			pChatXMLAutoMsg:GetNamedChild("Warning"):SetText(GetString(PCHAT_SAVMSGERRALREADYEXISTS))
			pChatXMLAutoMsg:GetNamedChild("Warning"):SetColor(1, 0, 0)
			zo_callLater(function() pChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(true) end, 5000)
		end

	end

end

local function CleanAutomatedMessageListForDB()
	-- :RefreshData() adds dataEntry recursively, delete it to avoid overflow in SavedVars
	for k, v in ipairs(db.automatedMessages) do
		if v.dataEntry then
			v.dataEntry = nil
		end
	end
end

local function RemoveAutomatedMessage()

	local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
	local _, index = GetDataByNameInSavedAutomatedMessages(data.name)
	table.remove(db.automatedMessages, index)
	pChatData.automatedMessagesList:RefreshData()
	CleanAutomatedMessageListForDB()

end

-- Init Automated messages, build the scene and handle array of automated strings
local function InitAutomatedMessages()

	-- Create Scene
	PCHAT_AUTOMSG_SCENE = ZO_Scene:New("pChatAutomatedMessagesScene", SCENE_MANAGER)

	-- Mouse standard position and background
	PCHAT_AUTOMSG_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	PCHAT_AUTOMSG_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

	-- Background Right, it will set ZO_RightPanelFootPrint and its stuff.
	PCHAT_AUTOMSG_SCENE:AddFragment(RIGHT_BG_FRAGMENT)

	-- The title fragment
	PCHAT_AUTOMSG_SCENE:AddFragment(TITLE_FRAGMENT)

	-- Set Title
	ZO_CreateStringId("SI_PCHAT_AUTOMSG_TITLE", ADDON_NAME)
	PCHAT_AUTOMSG_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_PCHAT_AUTOMSG_TITLE)
	PCHAT_AUTOMSG_SCENE:AddFragment(PCHAT_AUTOMSG_TITLE_FRAGMENT)

	-- Add the XML to our scene
	PCHAT_AUTOMSG_SCENE_WINDOW = ZO_FadeSceneFragment:New(pChatXMLAutoMsg)
	PCHAT_AUTOMSG_SCENE:AddFragment(PCHAT_AUTOMSG_SCENE_WINDOW)

	-- Register Scenes and the group name
	SCENE_MANAGER:AddSceneGroup("pChatSceneGroup", ZO_SceneGroup:New("pChatAutomatedMessagesScene"))

	-- Its infos
	PCHAT_MAIN_MENU_CATEGORY_DATA =
	{
		binding = "PCHAT_SHOW_AUTO_MSG",
		categoryName = PCHAT_SHOW_AUTO_MSG,
		normal = "EsoUI/Art/MainMenu/menuBar_champion_up.dds",
		pressed = "EsoUI/Art/MainMenu/menuBar_champion_down.dds",
		highlight = "EsoUI/Art/MainMenu/menuBar_champion_over.dds",
	}

	LoadLMM("pChat - InitAutomatedMessages")
	if LMM and LMM.AddCategory then
		MENU_CATEGORY_PCHAT = LMM:AddCategory(PCHAT_MAIN_MENU_CATEGORY_DATA)
	end

	local iconData = {
		{
		categoryName = SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG,
		descriptor = "pChatAutomatedMessagesScene",
		normal = "EsoUI/Art/MainMenu/menuBar_champion_up.dds",
		pressed = "EsoUI/Art/MainMenu/menuBar_champion_down.dds",
		highlight = "EsoUI/Art/MainMenu/menuBar_champion_over.dds",
		},
	}

	-- Register the group and add the buttons (we cannot all AddRawScene, only AddSceneGroup, so we emulate both functions).
	if LMM and LMM.AddSceneGroup and MENU_CATEGORY_PCHAT then
		LMM:AddSceneGroup(MENU_CATEGORY_PCHAT, "pChatSceneGroup", iconData)
	end

	pChatData.autoMsgDescriptor = {
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		{
			name = GetString(PCHAT_AUTOMSG_ADD_AUTO_MSG),
			keybind = "UI_SHORTCUT_PRIMARY",
			control = self,
			callback = function(descriptor) ZO_Dialogs_ShowDialog("PCHAT_AUTOMSG_SAVE_MSG", nil, {mainTextParams = {functionName}}) end,
			visible = function(descriptor) return true end
		},
		{
			name = GetString(PCHAT_AUTOMSG_EDIT_AUTO_MSG),
			keybind = "UI_SHORTCUT_SECONDARY",
			control = self,
			callback = function(descriptor) ZO_Dialogs_ShowDialog("PCHAT_AUTOMSG_EDIT_MSG", nil, {mainTextParams = {functionName}}) end,
			visible = function(descriptor)
				if pChatData.autoMessagesShowKeybind then
					return true
				else
					return false
				end
			end
		},
		{
			name = GetString(PCHAT_AUTOMSG_REMOVE_AUTO_MSG),
			keybind = "UI_SHORTCUT_NEGATIVE",
			control = self,
			callback = function(descriptor) RemoveAutomatedMessage() end,
			visible = function(descriptor)
				if pChatData.autoMessagesShowKeybind then
					return true
				else
					return false
				end
			end
		},
	}

	pChatData.pChatAutomatedMessagesScene = SCENE_MANAGER:GetScene("pChatAutomatedMessagesScene")
	pChatData.pChatAutomatedMessagesScene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			KEYBIND_STRIP:AddKeybindButtonGroup(pChatData.autoMsgDescriptor)
		elseif newState == SCENE_HIDDEN then
			if KEYBIND_STRIP:HasKeybindButtonGroup(pChatData.autoMsgDescriptor) then
				KEYBIND_STRIP:RemoveKeybindButtonGroup(pChatData.autoMsgDescriptor)
			end
		end
	end)

	if not db.automatedMessages then
		db.automatedMessages = {}
	end

	pChatData.automatedMessagesList = automatedMessagesList:New(pChatXMLAutoMsg)
	pChatData.automatedMessagesList:RefreshData()
	CleanAutomatedMessageListForDB()

	pChatData.automatedMessagesList.keybindStripDescriptor = pChatData.autoMsgDescriptor

end

-- Called by XML
function pChat_HoverRowOfAutomatedMessages(control)
	pChatData.autoMessagesShowKeybind = true
	pChatData.automatedMessagesList:Row_OnMouseEnter(control)
end

-- Called by XML
function pChat_ExitRowOfAutomatedMessages(control)
	pChatData.autoMessagesShowKeybind = false
	pChatData.automatedMessagesList:Row_OnMouseExit(control)
end

-- Called by XML
function pChat_BuildAutomatedMessagesDialog(control)

	local function AddDialogSetup(dialog, data)

		local name = GetControl(dialog, "NameEdit")
		local message = GetControl(dialog, "MessageEdit")

		name:SetText("")
		message:SetText("")
		name:SetEditEnabled(true)

	end

	ZO_Dialogs_RegisterCustomDialog("PCHAT_AUTOMSG_SAVE_MSG",
	{
		customControl = control,
		setup = AddDialogSetup,
		title =
		{
			text = PCHAT_AUTOMSG_ADD_TITLE_HEADER,
		},
		buttons =
		{
			[1] =
			{
				control  = GetControl(control, "Request"),
				text	 = PCHAT_AUTOMSG_ADD_AUTO_MSG,
				callback = function(dialog)
					local name = GetControl(dialog, "NameEdit"):GetText()
					local message = GetControl(dialog, "MessageEdit"):GetText()
					if(name ~= "") and (message ~= "") then
						SaveAutomatedMessage(name, message, true)
					end
				end,
			},
			[2] =
			{
				control = GetControl(control, "Cancel"),
				text = SI_DIALOG_CANCEL,
			}
		}
	})

	local function EditDialogSetup(dialog)
		local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
		local name = GetControl(dialog, "NameEdit")
		local edit = GetControl(dialog, "MessageEdit")


		name:SetText(data.name)
		name:SetEditEnabled(false)
		edit:SetText(data.message)
		edit:TakeFocus()

	end

	ZO_Dialogs_RegisterCustomDialog("PCHAT_AUTOMSG_EDIT_MSG",
	{
		customControl = control,
		setup = EditDialogSetup,
		title =
		{
			text = PCHAT_AUTOMSG_EDIT_TITLE_HEADER,
		},
		buttons =
		{
			[1] =
			{
				control  = GetControl(control, "Request"),
				text	 = PCHAT_AUTOMSG_EDIT_AUTO_MSG,
				callback = function(dialog)
					local name = GetControl(dialog, "NameEdit"):GetText()
					local message = GetControl(dialog, "MessageEdit"):GetText()
					if(name ~= "") and (message ~= "") then
						SaveAutomatedMessage(name, message, false)
					end
				end,
			},
			[2] =
			{
				control = GetControl(control, "Cancel"),
				text = SI_DIALOG_CANCEL,
			}
		}
	})

end
-- **************************************************************************
-- Chat Tab Functions
-- **************************************************************************
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

-- Rewrite of a core function
function CHAT_SYSTEM.textEntry:AddCommandHistory(text)

	local currentChannel = CHAT_SYSTEM.currentChannel
	local currentTarget = CHAT_SYSTEM.currentTarget
	local rewritedText = text

	-- Don't add the switch when chat is restored
	if isAddonInitialized and db.addChannelAndTargetToHistory then
		--Preset with /say switch
		local switch = CHAT_SYSTEM.switchLookup[0]
		-- It's a message
		switch = CHAT_SYSTEM.switchLookup[currentChannel]
		-- Below code suspected issue fix under comment - Bug ticket 2253 6/12/2018
		--[[
				rewritedText = string.format("%s ", switch)
		if currentTarget then
			rewritedText = string.format("%s%s ", rewritedText, currentTarget)
		end
		rewritedText = string.format("%s%s", rewritedText, text)
		]]--
		-- New code for bug ticket 2253 6/12/2018
		if switch ~= nil then
			rewritedText = string.format("%s ", switch)
			if currentTarget then
				rewritedText = string.format("%s%s ", rewritedText, currentTarget)
			end
			rewritedText = string.format("%s%s", rewritedText, text)
		end
	end

	CHAT_SYSTEM.textEntry.commandHistory:Add(rewritedText)
	CHAT_SYSTEM.textEntry.commandHistoryCursor = CHAT_SYSTEM.textEntry.commandHistory:Size() + 1

end

-- Rewrite of a core function: Enable custom switches for the guilds and officers
function CHAT_SYSTEM.textEntry:GetText()
	local text = self.editControl:GetText()

	if text ~= "" then
		if string.sub(text,1,1) == "!" then
			if string.len(text) <= 12 then

				local automatedMessage = true
				for k, v in ipairs(db.automatedMessages) do
					if v.name == text then
						text = db.automatedMessages[k].message
						automatedMessage = true
					end
				end

				if automatedMessage then

					if string.len(text) < 1 or string.len(text) > 351 then
						text = self.editControl:GetText()
					end

					if self.ignoreTextEntryChangedEvent then return end
					self.ignoreTextEntryChangedEvent = true

					local spaceStart, spaceEnd = zo_strfind(text, " ", 1, true)

					if spaceStart and spaceStart > 1 then
						local potentialSwitch = zo_strsub(text, 1, spaceStart - 1)
						local switch = CHAT_SYSTEM.switchLookup[potentialSwitch:lower()]

						local valid, switchArg, deferredError, spaceStartOverride = CHAT_SYSTEM:ValidateSwitch(switch, text, spaceStart)

						if valid then
							if(deferredError) then
								self.requirementErrorMessage = switch.requirementErrorMessage
								if self.requirementErrorMessage then
									if type(self.requirementErrorMessage) == "string" then
										CHAT_SYSTEM:AddMessage(self.requirementErrorMessage)
									elseif type(self.requirementErrorMessage) == "function" then
										CHAT_SYSTEM:AddMessage(self.requirementErrorMessage())
									end
								end
							else
								self.requirementErrorMessage = nil
							end

							CHAT_SYSTEM:SetChannel(switch.id, switchArg)
							local oldCursorPos = CHAT_SYSTEM.textEntry:GetCursorPosition()

							spaceStart = spaceStartOverride or spaceStart
							CHAT_SYSTEM.textEntry:SetText(zo_strsub(text, spaceStart + 1))
							text = zo_strsub(text, spaceStart + 1)
							CHAT_SYSTEM.textEntry:SetCursorPosition(oldCursorPos - spaceStart)
						end
					end

					self.ignoreTextEntryChangedEvent = false

				end
			end
		end
	end

	return text

end

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
		ZO_ChatWindowBg:SetCenterColor(0, 0, 0, 1)
		ZO_ChatWindowBg:SetEdgeColor(0, 0, 0, 1)
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

-- Add IM label on XML Initialization, set anchor and set it hidden
function pChat_AddIMLabel(control)

	control:SetParent(CHAT_SYSTEM.control)
	control:ClearAnchors()
	control:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, -5, 32)
	CHAT_SYSTEM.IMLabel = control

end

-- Add IM label on XML Initialization, set anchor and set it hidden. Used for Chat Minibar
function pChat_AddIMLabelMin(control)

	control:SetParent(CHAT_SYSTEM.control)
	control:ClearAnchors()
	control:SetAnchor(BOTTOM, CHAT_SYSTEM.minBar.maxButton, TOP, 2, 0)
	CHAT_SYSTEM.IMLabelMin = control

end

-- Add IM close button on XML Initialization, set anchor and set it hidden
function pChat_AddIMButton(control)

	control:SetParent(CHAT_SYSTEM.control)
	control:ClearAnchors()
	control:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, 2, 35)
	CHAT_SYSTEM.IMbutton = control

end

-- Hide it
local function HideIMTooltip()
	ClearTooltip(InformationTooltip)
end

-- Show IM notification tooltip
local function ShowIMTooltip(self, lineNumber)

	if db.LineStrings[lineNumber] then

		local sender = db.LineStrings[lineNumber].rawFrom
		local text = db.LineStrings[lineNumber].rawMessage

		if (not IsDecoratedDisplayName(sender)) then
			sender = zo_strformat(SI_UNIT_NAME, sender)
		end

		InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, 0, TOPRIGHT)
		InformationTooltip:AddLine(sender, "ZoFontGame", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)

		local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
		InformationTooltip:AddLine(text, "ZoFontGame", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)

	end

end

-- When an incoming Whisper is received
local function OnIMReceived(from, lineNumber)

	-- Display visual notification
	if db.notifyIM then

		--Do not notify if history gets restored and if the setting to stop notifications is
		if db.doNotNotifyOnRestoredWhisperFromHistory == true and preventWhisperNotificationsFromHistory == true then
--debug("[pChat]<<<Whisper restore aborted!")
			--Prevent the whisper notifications because of history restored messages
			preventWhisperNotificationsFromHistory = false
			return
		end

		-- If chat minimized, show the minified button
		if (CHAT_SYSTEM:IsMinimized()) then
			CHAT_SYSTEM.IMLabelMin:SetHandler("OnMouseEnter", function(self) ShowIMTooltip(self, lineNumber) end)
			CHAT_SYSTEM.IMLabelMin:SetHandler("OnMouseExit", HideIMTooltip)
			CHAT_SYSTEM.IMLabelMin:SetHidden(false)
		else
			-- Chat maximized
			local _, scrollMax = CHAT_SYSTEM.primaryContainer.scrollbar:GetMinMax()

			-- If chat tab with whisper channel activated is not the currently active one, or it's the whisper tab but we did not scroll to the bottom
			local isChatContainerCategoryEnabledWhisperIncoming = IsChatContainerTabCategoryEnabled(1, pChatData.activeTab, CHAT_CATEGORY_WHISPER_INCOMING)
			if (   (not isChatContainerCategoryEnabledWhisperIncoming)
				or (isChatContainerCategoryEnabledWhisperIncoming and CHAT_SYSTEM.primaryContainer.scrollbar:GetValue() < scrollMax) ) then

				-- Undecorate (^F / ^M)
				if (not IsDecoratedDisplayName(from)) then
					from = zo_strformat(SI_UNIT_NAME, from)
				end

				-- Split if name too long
				local displayedFrom = from
				if string.len(displayedFrom) > 8 then
					displayedFrom = string.sub(from, 1, 7) .. "..."
				end

				-- Show
				CHAT_SYSTEM.IMLabel:SetText(displayedFrom)
				CHAT_SYSTEM.IMLabel:SetHidden(false)
				CHAT_SYSTEM.IMbutton:SetHidden(false)

				-- Add handler
				CHAT_SYSTEM.IMLabel:SetHandler("OnMouseEnter", function(self) ShowIMTooltip(self, lineNumber) end)
				CHAT_SYSTEM.IMLabel:SetHandler("OnMouseExit", function(self) HideIMTooltip() end)
			end
		end

	end

end

-- Hide IM notification when click on it. Can be Called by XML
function pChat_RemoveIMNotification()
	CHAT_SYSTEM.IMLabel:SetHidden(true)
	CHAT_SYSTEM.IMLabelMin:SetHidden(true)
	CHAT_SYSTEM.IMbutton:SetHidden(true)
end

-- Will try to display the notified IM. Called by XML
function pChat_TryToJumpToIm(isMinimized)

	-- Show chat first
	if isMinimized then
		CHAT_SYSTEM:Maximize()
		CHAT_SYSTEM.IMLabelMin:SetHidden(true)
	end

	-- Tab get IM, scroll
	if IsChatContainerTabCategoryEnabled(1, pChatData.activeTab, CHAT_CATEGORY_WHISPER_INCOMING) then
		ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)
		pChat_RemoveIMNotification()
	else

		-- Tab don't have IM's, switch to next
		local numTabs = #CHAT_SYSTEM.primaryContainer.windows
		local actualTab = pChatData.activeTab + 1
		local oldActiveTab = pChatData.activeTab
		local PRESSED = 1
		local UNPRESSED = 2
		local hasSwitched = false
		local maxt = 1

		while actualTab <= numTabs and (not hasSwitched) do
			if IsChatContainerTabCategoryEnabled(1, actualTab, CHAT_CATEGORY_WHISPER_INCOMING) then

				CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[actualTab].tab)

				local tabText = GetControl(constTabNameTemplate .. actualTab .. "Text")
				tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
				tabText:GetParent().state = PRESSED
				local oldTabText = GetControl(constTabNameTemplate .. oldActiveTab .. "Text")
				oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
				oldTabText:GetParent().state = UNPRESSED
				ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)

				hasSwitched = true
			else
				actualTab = actualTab + 1
			end
		end

		actualTab = 1

		-- If we were on tab #3 and IM are show on tab #2, need to restart from 1
		while actualTab < oldActiveTab and (not hasSwitched) do
			if IsChatContainerTabCategoryEnabled(1, actualTab, CHAT_CATEGORY_WHISPER_INCOMING) then

				CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[actualTab].tab)

				local tabText = GetControl(constTabNameTemplate .. actualTab .. "Text")
				tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
				tabText:GetParent().state = PRESSED
				local oldTabText = GetControl(constTabNameTemplate .. oldActiveTab .. "Text")
				oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
				oldTabText:GetParent().state = UNPRESSED
				ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)

				hasSwitched = true
			else
				actualTab = actualTab + 1
			end
		end

	end

end

-- Rewrite of a core function, if user click on the scroll to bottom button, Hide IM notification
-- Todo: Hide IM when user manually scroll to the bottom
--[[
function ZO_ChatSystem_ScrollToBottom(control)
	pChat_RemoveIMNotification()
	control.container:ScrollToBottom()
end
]]

-- Set copied text into text entry, if possible
local function CopyToTextEntry(message)

	-- Max of inputbox is 351 chars
	if string.len(message) < 351 then
		if CHAT_SYSTEM.textEntry:GetText() == "" then
			CHAT_SYSTEM.textEntry:Open(message)
			ZO_ChatWindowTextEntryEditBox:SelectAll()
		end
	end

end

-- Copy message (only message)
local function CopyMessage(numLine)
	if not numLine or not db.LineStrings or not db.LineStrings[numLine] then return end
	-- Args are passed as string trought LinkHandlerSystem
	CopyToTextEntry(db.LineStrings[numLine].rawMessage)
end

--Copy line (including timestamp, from, channel, message, etc)
local function CopyLine(numLine)
	if not numLine or not db.LineStrings or not db.LineStrings[numLine] then return end
	-- Args are passed as string trought LinkHandlerSystem
	CopyToTextEntry(db.LineStrings[numLine].rawLine)
end

-- Popup a dialog message with text to copy
local function ShowCopyDialog(message)
	if not message or message == "" then return end
	-- Split text, courtesy of LibOrangUtils, modified to handle multibyte characters
	local function str_lensplit(text, maxChars)

		local ret					= {}
		local text_len				= string.len(text)
		local UTFAditionalBytes	= 0
		local fromWithUTFShift	= 0
		local doCut					= true

		if(text_len <= maxChars) then
			ret[#ret+1] = text
		else

			local splittedStart = 0
			local splittedEnd = splittedStart + maxChars - 1

			while doCut do

				if UTFAditionalBytes > 0 then
					fromWithUTFShift = UTFAditionalBytes
				else
					fromWithUTFShift = 0
				end

				local UTFAditionalBytes = 0

				splittedEnd = splittedStart + maxChars - 1

				if(splittedEnd >= text_len) then
					splittedEnd = text_len
					doCut = false
				elseif (string.byte(text, splittedEnd, splittedEnd)) > 128 then
					UTFAditionalBytes = 1

					local lastByte = string.byte(splittedString, -1)
					local beforeLastByte = string.byte(splittedString, -2, -2)

					if (lastByte < 128) then
						--
					elseif lastByte >= 128 and lastByte < 192 then

						if beforeLastByte >= 192 and beforeLastByte < 224 then
							--
						elseif beforeLastByte >= 128 and beforeLastByte < 192 then
							--
						elseif beforeLastByte >= 224 and beforeLastByte < 240 then
							UTFAditionalBytes = 1
						end

						splittedEnd = splittedEnd + UTFAditionalBytes
						splittedString = text:sub(splittedStart, splittedEnd)

					elseif lastByte >= 192 and lastByte < 224 then
						UTFAditionalBytes = 1
						splittedEnd = splittedEnd + UTFAditionalBytes
					elseif lastByte >= 224 and lastByte < 240 then
						UTFAditionalBytes = 2
						splittedEnd = splittedEnd + UTFAditionalBytes
					end

				end

				--ret = ret+1
				ret[#ret+1] = string.sub(text, splittedStart, splittedEnd)

				splittedStart = splittedEnd + 1

			end
		end

		return ret

	end

	local maxChars		= 20000

	-- editbox is 20000 chars max
	if string.len(message) < maxChars then
		pChatCopyDialogTLCTitle:SetText(GetString(PCHAT_COPYXMLTITLE))
		pChatCopyDialogTLCLabel:SetText(GetString(PCHAT_COPYXMLLABEL))
		pChatCopyDialogTLCNoteEdit:SetText(message)
		pChatCopyDialogTLCNoteNext:SetHidden(true)
		pChatCopyDialogTLC:SetHidden(false)
		pChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
		pChatCopyDialogTLCNoteEdit:SelectAll()
	else

		pChatCopyDialogTLCTitle:SetText(GetString(PCHAT_COPYXMLTITLE))
		pChatCopyDialogTLCLabel:SetText(GetString(PCHAT_COPYXMLTOOLONG))

		pChatData.messageTableId = 1
		pChatData.messageTable = str_lensplit(message, maxChars)
		pChatCopyDialogTLCNoteNext:SetText(GetString(PCHAT_COPYXMLNEXT) .. " ( " .. pChatData.messageTableId .. " / " .. #pChatData.messageTable .. " )")
		pChatCopyDialogTLCNoteEdit:SetText(pChatData.messageTable[pChatData.messageTableId])
		pChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
		pChatCopyDialogTLCNoteEdit:SelectAll()

		pChatCopyDialogTLC:SetHidden(false)
		pChatCopyDialogTLCNoteNext:SetHidden(false)

		pChatCopyDialogTLCNoteEdit:TakeFocus()

	end

end

-- Copy discussion
-- It will copy all text mark with the same chanCode
-- Todo : Whisps by person
local function CopyDiscussion(chanNumber, numLine)

	if not numLine or not chanNumber or not db.LineStrings or not db.LineStrings[numLine] then return end

	-- Args are passed as string trought LinkHandlerSystem
	local numChanCode = tonumber(chanNumber)
	-- Whispers sent and received together
	if numChanCode == CHAT_CHANNEL_WHISPER_SENT then
		numChanCode = CHAT_CHANNEL_WHISPER
	elseif numChanCode == PCHAT_URL_CHAN then
		numChanCode = db.LineStrings[numLine].channel
	end

	local stringToCopy = ""
	for k, data in ipairs(db.LineStrings) do
		local textToCopy = db.LineStrings[k].rawLine
		if textToCopy ~= nil then
			if numChanCode == CHAT_CHANNEL_WHISPER then -- or numChanCode == CHAT_CHANNEL_WHISPER_SENT then
				if data.channel == CHAT_CHANNEL_WHISPER or data.channel == CHAT_CHANNEL_WHISPER_SENT then
					if stringToCopy == "" then
						stringToCopy = tostring(textToCopy)
					else
						stringToCopy = stringToCopy .. "\r\n" .. tostring(textToCopy)
					end
				end
			elseif data.channel == numChanCode then
				if stringToCopy == "" then
					stringToCopy = tostring(textToCopy)
				else
					stringToCopy = stringToCopy .. "\r\n" .. tostring(textToCopy)
				end
			end
		end
	end
	ShowCopyDialog(stringToCopy)
end

-- Copy Whole chat (not tab)
local function CopyWholeChat()
	local stringToCopy = ""
	for k, data in ipairs(db.LineStrings) do
		local textToCopy = db.LineStrings[k].rawLine
		if textToCopy ~= nil then
			if stringToCopy == "" then
				stringToCopy = tostring(textToCopy)
			else
				stringToCopy = stringToCopy .. "\r\n" .. tostring(textToCopy)
			end
		end
	end
	ShowCopyDialog(stringToCopy)
end

-- Show contextualMenu when clicking on a pChatLink
local function ShowContextMenuOnHandlers(numLine, chanNumber)

	ClearMenu()

	if not ZO_Dialogs_IsShowingDialog() then
		AddCustomMenuItem(GetString(PCHAT_COPYMESSAGECT), function() CopyMessage(numLine) end)
		AddCustomMenuItem(GetString(PCHAT_COPYLINECT), function() CopyLine(numLine) end)
		AddCustomMenuItem(GetString(PCHAT_COPYDISCUSSIONCT), function() CopyDiscussion(chanNumber, numLine) end)
		AddCustomMenuItem(GetString(PCHAT_ALLCT), CopyWholeChat)
	end

	ShowMenu()

end

-- Triggers when right clicking on a LinkHandler
local function OnLinkClicked(rawLink, mouseButton, linkText, color, linkType, lineNumber, chanCode)

	-- Only executed on LinkType = PCHAT_LINK
	if linkType == PCHAT_LINK then

		local chanNumber = tonumber(chanCode)
		local numLine = tonumber(lineNumber)
		-- PCHAT_LINK also handle a linkable channel feature for linkable channels

		-- Context Menu
		if chanCode and mouseButton == MOUSE_BUTTON_INDEX_LEFT then

			-- Only Linkable channel - TODO use .channelLinkable
			if chanNumber == CHAT_CHANNEL_SAY
			or chanNumber == CHAT_CHANNEL_YELL
			or chanNumber == CHAT_CHANNEL_PARTY
			or chanNumber == CHAT_CHANNEL_ZONE
			or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_1
			or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_2
			or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_3
			or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_4
			or (chanNumber >= CHAT_CHANNEL_GUILD_1 and chanNumber <= CHAT_CHANNEL_GUILD_5)
			or (chanNumber >= CHAT_CHANNEL_OFFICER_1 and chanNumber <= CHAT_CHANNEL_OFFICER_5) then
				IgnoreMouseDownEditFocusLoss()
				CHAT_SYSTEM:StartTextEntry(nil, chanNumber)
			elseif chanNumber == CHAT_CHANNEL_WHISPER then
				local target = zo_strformat(SI_UNIT_NAME, db.LineStrings[numLine].rawFrom)
				IgnoreMouseDownEditFocusLoss()
				CHAT_SYSTEM:StartTextEntry(nil, chanNumber, target)
			elseif chanNumber == PCHAT_URL_CHAN then
				RequestOpenUnsafeURL(linkText)
			end

		elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
			-- Right click, copy System
			ShowContextMenuOnHandlers(numLine, chanNumber)
		end

		-- Don't execute LinkHandler code
		return true

	end

end

local function CopyToTextEntryText()
	if db.enablecopy then
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, OnLinkClicked)
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)
	end
end

-- Called by XML
function pChat_ShowCopyDialogNext()

	pChatData.messageTableId = pChatData.messageTableId + 1

	-- Security
	if pChatData.messageTable[pChatData.messageTableId] then

		-- Build button
		pChatCopyDialogTLCNoteNext:SetText(GetString(PCHAT_COPYXMLNEXT) .. " ( " .. pChatData.messageTableId .. " / " .. #pChatData.messageTable .. " )")
		pChatCopyDialogTLCNoteEdit:SetText(pChatData.messageTable[pChatData.messageTableId])
		pChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
		pChatCopyDialogTLCNoteEdit:SelectAll()

		-- Don't show next button if its the last
		if not pChatData.messageTable[pChatData.messageTableId + 1] then
			pChatCopyDialogTLCNoteNext:SetHidden(true)
		end

		pChatCopyDialogTLCNoteEdit:TakeFocus()

	end

end

-- Needed to bind Shift+Tab in SetSwitchToNextBinding
function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
	return true
end

local function SetSwitchToNextBinding()

	ZO_CreateStringId("SI_BINDING_NAME_PCHAT_SWITCH_TAB", GetString(PCHAT_SWITCHTONEXTTABBINDING))

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
--**** Issue
local function SetDefaultTab(tabToSet)
	if not CHAT_SYSTEM or not CHAT_SYSTEM.primaryContainer or not CHAT_SYSTEM.primaryContainer.windows then return end
	-- Search in all tabs the good name
	for numTab in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
		-- Not this one, try the next one, if tab is not found (newly added, removed), pChat_SwitchToNextTab() will go back to tab 1
		if tonumber(tabToSet) ~= numTab then
			pChat_SwitchToNextTab()
		else
			-- Found it, stop
			return
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

local function StripLinesFromLineStrings(typeOfExit)

	local k = 1
	-- First loop is time based. If message is older than our limit, it will be stripped.
	while k <= #db.LineStrings do

		if db.LineStrings[k] then
			local channel = db.LineStrings[k].channel
			if channel == CHAT_CHANNEL_SYSTEM and (not db.restoreSystem) then
				table.remove(db.LineStrings, k)
				db.lineNumber = db.lineNumber - 1
				k = k-1
			elseif channel ~= CHAT_CHANNEL_SYSTEM and db.restoreSystemOnly then
				table.remove(db.LineStrings, k)
				db.lineNumber = db.lineNumber - 1
				k = k-1
			elseif (channel == CHAT_CHANNEL_WHISPER or channel == CHAT_CHANNEL_WHISPER_SENT) and (not db.restoreWhisps) then
				table.remove(db.LineStrings, k)
				db.lineNumber = db.lineNumber - 1
				k = k-1
			elseif typeOfExit ~= 1 then
				if db.LineStrings[k].rawTimestamp then
					if (GetTimeStamp() - db.LineStrings[k].rawTimestamp) > (db.timeBeforeRestore * 60 * 60) then
						table.remove(db.LineStrings, k)
						db.lineNumber = db.lineNumber - 1
						k = k-1
					elseif db.LineStrings[k].rawTimestamp > GetTimeStamp() then -- System clock of users computer badly set and msg received meanwhile.
						table.remove(db.LineStrings, k)
						db.lineNumber = db.lineNumber - 1
						k = k-1
					end
				end
			end
		end

		k = k + 1

	end

	-- 2nd loop is size based. If dump is too big, just delete old ones
	if k > 5000 then
		local linesToDelete = k - 5000
		for l=1, linesToDelete do

			if db.LineStrings[l] then
				table.remove(db.LineStrings, l)
				db.lineNumber = db.lineNumber - 1
			end

		end
	end

end

local function SaveChatHistory(typeOf)

	db.history = {}

	if (db.restoreOnReloadUI == true and typeOf == 1) or (db.restoreOnLogOut == true and typeOf == 2) or (db.restoreOnAFK == true) or (db.restoreOnQuit == true and typeOf == 3) then

		if typeOf == 1 then

			db.lastWasReloadUI = true
			db.lastWasLogOut = false
			db.lastWasQuit = false
			db.lastWasAFK = false

			--Save actual channel
			db.history.currentChannel = CHAT_SYSTEM.currentChannel
			db.history.currentTarget = CHAT_SYSTEM.currentTarget

		elseif typeOf == 2 then
			db.lastWasReloadUI = false
			db.lastWasLogOut = true
			db.lastWasQuit = false
			db.lastWasAFK = false
		elseif typeOf == 3 then
			db.lastWasReloadUI = false
			db.lastWasLogOut = false
			db.lastWasQuit = true
			db.lastWasAFK = false
		end

		db.history.currentTab = pChatData.activeTab

		-- Save Chat History isn't needed, because it's saved in realtime, but we can strip some lines from the array to avoid big dumps
		StripLinesFromLineStrings(typeOf)

		--Save TextEntry history
		db.history.textEntry = {}
		if CHAT_SYSTEM.textEntry.commandHistory.entries then
			db.history.textEntry.entries = CHAT_SYSTEM.textEntry.commandHistory.entries
			db.history.textEntry.numEntries = CHAT_SYSTEM.textEntry.commandHistory.index
		else
			db.history.textEntry.entries = {}
			db.history.textEntry.numEntries = 0
		end
	else
		db.LineStrings = {}
		db.lineNumber = 1
	end

end

local function CreateNewChatTabPostHook()
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

local function ShowFadedLines()
	--[[
	local origChatSystemCreateNewChatTab = CHAT_SYSTEM.CreateNewChatTab
	CHAT_SYSTEM.CreateNewChatTab = function(self, ...)
		origChatSystemCreateNewChatTab(self, ...)
		CreateNewChatTabPostHook()
	end
	]]
	SecurePostHook(CHAT_SYSTEM, "CreateNewChatTab", function()
		CreateNewChatTabPostHook()
	end)

end

local function OnReticleTargetChanged()
	if IsUnitPlayer("reticleover") then
		targetToWhisp = GetUnitName("reticleover")
	end
end

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

-- Change font of chat
local function ChangeChatFont(change)

	local fontSize = GetChatFontSize()

	if db.fonts == "ESO Standard Font" or db.fonts == "Univers 57" then
		return
	else

		local fontPath = LMP:Fetch("font", db.fonts)

		-- Entry Box
		ZoFontEditChat:SetFont(fontPath .. "|".. fontSize .. "|shadow")

		-- Chat window
		ZoFontChat:SetFont(fontPath .. "|" .. fontSize .. "|soft-shadow-thin")

	end

end

-- Rewrite of a core function
function CHAT_SYSTEM:UpdateTextEntryChannel()

	local channelData = self.channelData[self.currentChannel]

	if channelData then
		self.textEntry:SetChannel(channelData, self.currentTarget)

		if isAddonLoaded then
			if not db.useESOcolors then

				local pChatcolor
				if db.allGuildsSameColour and (self.currentChannel >= CHAT_CHANNEL_GUILD_1 and self.currentChannel <= CHAT_CHANNEL_GUILD_5) then
					pChatcolor = db.colours[2*CHAT_CHANNEL_GUILD_1]
				elseif db.allGuildsSameColour and (self.currentChannel >= CHAT_CHANNEL_OFFICER_1 and self.currentChannel <= CHAT_CHANNEL_OFFICER_5) then
					pChatcolor = db.colours[2*CHAT_CHANNEL_OFFICER_1]
				elseif db.allZonesSameColour and (self.currentChannel >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and self.currentChannel <= CHAT_CHANNEL_ZONE_LANGUAGE_4) then
					pChatcolor = db.colours[2*CHAT_CHANNEL_ZONE]
				else
					pChatcolor = db.colours[2*self.currentChannel]
				end

				if not pChatcolor then
					self.textEntry:SetColor(1, 1, 1, 1)
				else
					local r, g, b, a = ConvertHexToRGBA(pChatcolor)
					self.textEntry:SetColor(r, g, b, a)
				end

			else
				self.textEntry:SetColor(ZO_ChatSystem_GetCategoryColorFromChannel(self.currentChannel))
			end
		else
			self.textEntry:SetColor(ZO_ChatSystem_GetCategoryColorFromChannel(self.currentChannel))
		end

	end

end

-- Change guild channel names in entry box
local function UpdateCharCorrespondanceTableChannelNames()
debug("[pChat]UpdateCharCorrespondanceTableChannelNames")
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

			--ChanInfoArray = ZO_ChatSystem_GetChannelInfo()
			-- CHAT_CHANNEL_GUILD_1 /g1 is 12 /g5 is 16, /o1=17, etc
			ChanInfoArray[CHAT_CHANNEL_GUILD_1 - 1 + i].name = tag
			ChanInfoArray[CHAT_CHANNEL_OFFICER_1 - 1 + i].name = officertag
debug(">Set guild/officer tags to: " ..tostring(tag) .."/" .. tostring(officertag) .." for guild# " .. tostring(i))
			--Disabling dynamic chat channel names (see function GetDynamicChatChannelName(channelInfo.id))
			ChanInfoArray[CHAT_CHANNEL_GUILD_1 - 1 + i].dynamicName = false
			ChanInfoArray[CHAT_CHANNEL_OFFICER_1 - 1 + i].dynamicName = false

		else
			ChanInfoArray[CHAT_CHANNEL_GUILD_1 - 1 + i].name = guildName
			ChanInfoArray[CHAT_CHANNEL_OFFICER_1 - 1 + i].name = guildName
			--Enabling dynamic chat channel names (see function GetDynamicChatChannelName(channelInfo.id))
			ChanInfoArray[CHAT_CHANNEL_GUILD_1 - 1 + i].dynamicName = true
			ChanInfoArray[CHAT_CHANNEL_OFFICER_1 - 1 + i].dynamicName = true
		end
	end
end

-- Split text with blocs of 100 chars (106 is max for LinkHandle) and add LinkHandle to them
-- WARNING : See FormatSysMessage()
local function SplitTextForLinkHandler(text, numLine, chanCode)

	local newText = ""
	local textLen = string.len(text)
	local MAX_LEN = 100

	-- LinkHandle does not handle text > 106 chars, so we need to split
	if textLen > MAX_LEN then

		local splittedStart = 1
		local splits = 1
		local needToSplit = true

		while needToSplit do

			local splittedString = ""
			local UTFAditionalBytes = 0

			if textLen > (splits * MAX_LEN) then

				local splittedEnd = splittedStart + MAX_LEN
				splittedString = text:sub(splittedStart, splittedEnd) -- We can "cut" characters by doing this

				local lastByte = string.byte(splittedString, -1)
				local beforeLastByte = string.byte(splittedString, -2, -2)

				-- Characters can be into 1, 2 or 3 bytes. Lua don't support UTF natively. We only handle 3 bytes chars.
				-- http://www.utf8-chartable.de/unicode-utf8-table.pl

				if (lastByte < 128) then -- any ansi character (ex : a	97	LATIN SMALL LETTER A) (cut was well made)
					--
				elseif lastByte >= 128 and lastByte < 192 then -- any non ansi character ends with last byte = 128-191  (cut was well made) or 2nd byte of a 3 Byte character. We take 1 byte more.  (cut was incorrect)

					if beforeLastByte >= 192 and beforeLastByte < 224 then -- "2 latin characters" ex: 195 169	LATIN SMALL LETTER E WITH ACUTE ; е	208 181	CYRILLIC SMALL LETTER IE
						--
					elseif beforeLastByte >= 128 and beforeLastByte < 192 then -- "3 Bytes Cyrillic & Japaneese" ex U+3057	し	227 129 151	HIRAGANA LETTER SI
						--
					elseif beforeLastByte >= 224 and beforeLastByte < 240 then -- 2nd byte of a 3 Byte character. We take 1 byte more.  (cut was incorrect)
						UTFAditionalBytes = 1
					end

					splittedEnd = splittedEnd + UTFAditionalBytes
					splittedString = text:sub(splittedStart, splittedEnd)

				elseif lastByte >= 192 and lastByte < 224 then -- last byte = 1st byte of a 2 Byte character. We take 1 byte more.  (cut was incorrect)
					UTFAditionalBytes = 1
					splittedEnd = splittedEnd + UTFAditionalBytes
					splittedString = text:sub(splittedStart, splittedEnd)
				elseif lastByte >= 224 and lastByte < 240 then -- last byte = 1st byte of a 3 Byte character. We take 2 byte more.  (cut was incorrect)
					UTFAditionalBytes = 2
					splittedEnd = splittedEnd + UTFAditionalBytes
					splittedString = text:sub(splittedStart, splittedEnd)
				end

				splittedStart = splittedEnd + 1
				newText = newText .. string.format("|H1:%s:%s:%s|h%s|h", PCHAT_LINK, numLine, chanCode, splittedString)
				splits = splits + 1

			else
				splittedString = text:sub(splittedStart)
				local textSplittedlen = splittedString:len()
				if textSplittedlen > 0 then
					newText = newText .. string.format("|H1:%s:%s:%s|h%s|h", PCHAT_LINK, numLine, chanCode, splittedString)
				end
				needToSplit = false
			end

		end
	else
		-- When dumping back, the "from" section is sent here. It will add handler to spaces. prevent it to avoid an uneeded increase of the message.
		if not (text == " " or text == ": ") then
			newText = string.format("|H1:%s:%s:%s|h%s|h", PCHAT_LINK, numLine, chanCode, text)
		else
			newText = text
		end
	end

	return newText

end

-- Sub function of addLinkHandlerToString
-- WARNING : See FormatSysMessage()
-- Get a string without |cXXXXXX and without |t as parameter
local function AddLinkHandlerToStringWithoutDDS(textToCheck, numLine, chanCode)

	local stillToParse = true
	local noColorlen = textToCheck:len()

	-- this var seems to get some rework
	local startNoColor = 1
	local textLinked = ""
	local preventLoopsCol = 0
	local handledText = ""

	while stillToParse do

		-- Prevent infinit loops while its still in beta
		if preventLoopsCol > 10 then
			stillToParse = false
			debug("pChat triggered an infinite LinkHandling loop in its copy system with last message : " .. textToCheck .. " -- pChat")
		else
			preventLoopsCol = preventLoopsCol + 1
		end

		noColorlen = textToCheck:len()

		local startpos, endpos = string.find(textToCheck, "|H(.-):(.-)|h(.-)|h", 1)
		-- LinkHandler not found
		if not startpos then
			-- If nil, then we won't have new link after startposition = startNoColor , so add ours util the end

			-- Some addons use table.insert() and chat convert to a CRLF
			-- First, drop the final CRLF if we are at the end of the text
			if string.sub(textToCheck, -2) == "\r\n" then
				textToCheck = string.sub(textToCheck, 1, -2)
			end
			-- MultiCRLF is handled in .addLinkHandler()

			textLinked = SplitTextForLinkHandler(textToCheck, numLine, chanCode)
			handledText = handledText .. textLinked

			-- No need to parse after
			stillToParse = false

		else

			-- Link is at the begginning of the string
			if startpos == 1 then
				-- New text is (only handler because its at the pos 1)
				handledText = handledText .. textToCheck:sub(startpos, endpos)

				-- Do we need to continue ?
				if endpos == noColorlen then
					-- We're at the end
					stillToParse = false
				else
					-- Still to parse
					startNoColor = endpos
					-- textToCheck is next to our string
					textToCheck = textToCheck:sub(startNoColor + 1)
				end

			else

				-- We Handle string from startNoColor of the message up to the Handle link
				local textToHandle = textToCheck:sub(1, startpos - 1)

				-- Add ours
				-- Maybe we need a split due to 106 chars restriction
				textLinked = SplitTextForLinkHandler(textToHandle, numLine, chanCode)

				-- New text is handledText + (textLinked .. LinkHandler)
				handledText = handledText .. textLinked
				handledText = handledText .. textToCheck:sub(startpos, endpos)

				-- Do we need to continue ?
				if endpos == noColorlen then
					-- We're at the end
					stillToParse = false
				else
					-- Still to parse
					startNoColor = endpos
					-- textToCheck is next to our string
					textToCheck = textToCheck:sub(startNoColor + 1)
				end

			end
		end
	end

	return handledText

end

-- Sub function of addLinkHandlerToLine, Handling DDS textures in chat
-- WARNING : See FormatSysMessage()
-- Get a string without |cXXXXXX as parameter
local function AddLinkHandlerToString(textToCheck, numLine, chanCode)

	local stillToParseDDS = true
	local noDDSlen = textToCheck:len()

	-- this var seems to get some rework
	local startNoDDS = 1
	local textLinked = ""
	local preventLoopsDDS = 0
	local textTReformated = ""

	-- Seems the "|" are truncated from the link when send to chatsystem (they're needed for build link, but the output does not include them)

	while stillToParseDDS do

		-- Prevent infinit loops while its still in beta
		if preventLoopsDDS > 20 then
			stillToParseDDS = false
			debug("pChat triggered an infinite DDS loop in its copy system with last message : " .. textToCheck .. " -- pChat")
		else
			preventLoopsDDS = preventLoopsDDS + 1
		end

		noDDSlen = textToCheck:len()

		local startpos, endpos = string.find(textToCheck, "|t%-?%d+%%?:%-?%d+%%?:.-|t", 1)
		-- DDS not found
		if startpos == nil then
			-- If nil, then we won't have new link after startposition = startNoDDS , so add ours until the end

			textLinked = AddLinkHandlerToStringWithoutDDS(textToCheck, numLine, chanCode)

			textTReformated = textTReformated .. textLinked

			-- No need to parse after
			stillToParseDDS = false

		else

			-- DDS is at the begginning of the string
			if startpos == 1 then
				-- New text is (only DDS because its at the pos 1)
				textTReformated = textTReformated .. textToCheck:sub(startpos, endpos)

				-- Do we need to continue ?
				if endpos == noDDSlen then
					-- We're at the end
					stillToParseDDS = false
				else
					-- Still to parse
					startNoDDS = endpos
					-- textToCheck is next to our string
					textToCheck = textToCheck:sub(startNoDDS + 1)
				end

			else

				-- We Handle string from startNoDDS of the message up to the Handle link
				local textToHandle = textToCheck:sub(1, startpos - 1)

				-- Add ours
				textLinked = AddLinkHandlerToStringWithoutDDS(textToHandle, numLine, chanCode)

				-- New text is formattedText + (textLinked .. DDS)
				textTReformated = textTReformated .. textLinked

				textTReformated = textTReformated .. textToCheck:sub(startpos, endpos)

				-- Do we need to continue ?
				if endpos == noDDSlen then
					-- We're at the end
					stillToParseDDS = false
				else
					-- Still to parse
					startNoDDS = endpos
					-- textToCheck is next to our string
					textToCheck = textToCheck:sub(startNoDDS + 1)
				end

			end
		end
	end

	return textTReformated

end

-- Reformat Colored Sysmessages to the correct format
-- Bad format = |[cC]XXXXXXblablabla[,|[cC]XXXXXXblablabla,(...)] with facultative |r
-- Good format : "|c%x%x%x%x%x%x(.-)|r"
-- WARNING : See FormatSysMessage()
-- TODO : Handle LinkHandler + Malformatted strings , such as : "|c87B7CC|c87B7CCUpdated: |H0:achievement:68:5252:0|h|h (Artisanat)."
local function ReformatSysMessages(text)

	local rawSys = text
	local startColSys, endColSys
	local lastTag, lastR, findC, findR
	local count, countR
	local firstIsR

	rawSys = rawSys:gsub("||([Cc])", "%1") -- | is the escape char for |, so if an user type |c it will be sent as ||c by the game which will lead to an infinite loading screen because xxxxx||xxxxxx is a lua pattern operator and few gsub will broke the code

	--Search for Color tags
	startColSys, endColSys = string.find(rawSys, "|[cC]%x%x%x%x%x%x", 1)
	_, count = string.gsub(rawSys, "|[cC]%x%x%x%x%x%x", "")

	-- No color tags in the SysMessage
	if startColSys then
		-- Found X tag
		-- Searching for |r after tag color

		-- First destroy tags with nothing inside
		rawSys = string.gsub(rawSys, "|[cC]%x%x%x%x%x%x|[rR]", "")

		_, countR = string.gsub(rawSys, "|[cC]%x%x%x%x%x%x(.-)|[rR]", "")

		-- Start tag found but end tag ~= start tag
		if count ~= countR then

			-- Add |r before the tag
			rawSys = string.gsub(rawSys, "|[cC]%x%x%x%x%x%x", "|r%1")
			firstIsR = string.find(rawSys, "|[cC]%x%x%x%x%x%x")

			--No |r tag at the start of the text if start was |cXXXXXX
			if firstIsR == 3 then
				rawSys = string.sub(rawSys, 3)
			end

			-- Replace
			rawSys = string.gsub(rawSys, "|r|r", "|r")
			rawSys = string.gsub(rawSys, "|r |r", " |r")

			lastTag = string.match(rawSys, "^.*()|[cC]%x%x%x%x%x%x")
			lastR = string.match(rawSys, "^.*()|r")

			-- |r tag found
			if lastR ~= nil then
				if lastTag > lastR then
					rawSys = rawSys .. "|r"
				end
			else
				-- Got X tags and 0 |r, happens only when we got 1 tag and 0 |r because we added |r to every tags just before
				-- So add last "|r"
				rawSys = rawSys .. "|r"
			end

			-- Double check

			findC = string.find(rawSys, "|[cC]%x%x%x%x%x%x")
			findR = string.find(rawSys, "|[rR]")

			while findR ~= nil and findC ~= nil do

				if findC then
					if findR < findC then
						rawSys = string.sub(rawSys, 1, findR - 1) .. string.sub(rawSys, findR + 2)
					end

					findC = string.find(rawSys, "|[cC]%x%x%x%x%x%x", findR)
					findR = string.find(rawSys, "|[rR]", findR + 2)
				end

			end

		end

	end
	-- Added |u search
	startColSys, endColSys = string.find(rawSys, "|u%-?%d+%%?:%-?%d+%%?:.-:|u",1)
	-- if found
	if startColSys then
		rawSys = string.gsub(rawSys,"|u%-?%d+%%?:%-?%d+%%?:.-:|u","")
	end

	return rawSys

end

-- Add pChatLinks Handlers on the whole text except LinkHandlers already here
-- WARNING : See FormatSysMessage()
local function AddLinkHandlerToLine(text, chanCode, numLine)

	local rawText = ReformatSysMessages(text) -- FUCK YOU

	local start = 1
	local rawTextlen = string.len(rawText)
	local stillToParseCol = true
	local formattedText
	local noColorText = ""
	local textToCheck = ""

	local startColortag = ""

	local preventLoops = 0
	local colorizedText = true
	local newText = ""

	while stillToParseCol do

		-- Prevent infinite loops while its still in beta
		if preventLoops > 10 then
			stillToParseCol = false
		else
			preventLoops = preventLoops + 1
		end

		-- Handling Colors, search for color tag
		local startcol, endcol = string.find(rawText, "|[cC]%x%x%x%x%x%x(.-)|r", start)

		-- Not Found
		if startcol == nil then
			startColortag = ""
			textToCheck = string.sub(rawText, start)
			stillToParseCol = false
			newText = newText .. AddLinkHandlerToString(textToCheck, numLine, chanCode)
		else
			startColortag = string.sub(rawText, startcol, startcol + 7)
			-- pChat format all strings
			if start == startcol then
				-- textToCheck is only (.-)
				textToCheck = string.sub(rawText, (startcol + 8), (endcol - 2))
				-- Change our start -> pos of (.-)
				start = endcol + 1
				newText = newText .. startColortag .. AddLinkHandlerToString(textToCheck, numLine, chanCode) .. "|r"

				-- Do we need to continue ?
				if endcol == rawTextlen then
					-- We're at the end
					stillToParseCol = false
				end

			else
				-- We will check colorized text at next loop
				textToCheck = string.sub(rawText, start, startcol-1)
				start = startcol
				-- Tag color found but need to check some strings before
				newText = newText .. AddLinkHandlerToString(textToCheck, numLine, chanCode)
			end
		end

	end

	return newText

end

-- Split lines using CRLF for function addLinkHandlerToLine
-- WARNING : See FormatSysMessage()
local function AddLinkHandler(text, chanCode, numLine)
	if not text or text == "" then return end
	-- Some Addons output multiple lines into a message
	-- Split the entire string with CRLF, cause LinkHandler don't support CRLF

	-- Init
	local formattedText = ""

	-- Recheck setting if copy is disabled for chat dump
	if db.enablecopy then

		-- No CRLF
		-- ESO LUA Messages output \n instead of \r\n
		local crtext = string.gsub(text, "\r\n", "\n")
		-- Find multilines
		local cr = string.find(crtext, "\n")

		if not cr then
			formattedText = AddLinkHandlerToLine(text, chanCode, numLine)
		else
			local lines = {zo_strsplit("\n", crtext)}
			local first = true
			local strippedLine
			local nunmRows = 0

			for _, line in pairs(lines) do

				-- Only if there something to display
				if string.len(line) > 0 then

					if first then
						formattedText = AddLinkHandlerToLine(line, chanCode, numLine)
						first = false
					else
						formattedText = formattedText .. "\n" .. AddLinkHandlerToLine(line, chanCode, numLine)
					end

					if nunmRows > 10 then
						local errorMessage = string.format(GetString(PCHAT_LUAERROR), tostring(text))
						debug(errorMessage)
						return
					else
						nunmRows = nunmRows + 1
					end

				end

			end

		end
	else
		formattedText = text
	end

	return formattedText

end

-- Can cause infinite loads (why?)
local function RestoreChatMessagesFromHistory(wasReloadUI)
	preventWhisperNotificationsFromHistory = false

	-- Restore Chat
	local lastInsertionWas = 0
	local restoredPrefix = GetString(PCHAT_RESTORED_PREFIX)

	if db.LineStrings then

		local historyIndex = 1
		local categories = ZO_ChatSystem_GetEventCategoryMappings()

		while historyIndex <= #db.LineStrings do
			if db.LineStrings[historyIndex] then
				local channelToRestore = db.LineStrings[historyIndex].channel
				if channelToRestore == PCHAT_CHANNEL_SAY then channelToRestore = 0 end

				if channelToRestore == CHAT_CHANNEL_SYSTEM and not db.restoreSystem then
					table.remove(db.LineStrings, historyIndex)
					db.lineNumber = db.lineNumber - 1
					historyIndex = historyIndex - 1
				elseif channelToRestore ~= CHAT_CHANNEL_SYSTEM and db.restoreSystemOnly then
					table.remove(db.LineStrings, historyIndex)
					db.lineNumber = db.lineNumber - 1
					historyIndex = historyIndex - 1
				elseif (channelToRestore == CHAT_CHANNEL_WHISPER or channelToRestore == CHAT_CHANNEL_WHISPER_SENT) and not db.restoreWhisps then
					table.remove(db.LineStrings, historyIndex)
					db.lineNumber = db.lineNumber - 1
					historyIndex = historyIndex - 1
				else

					local category = categories[EVENT_CHAT_MESSAGE_CHANNEL][channelToRestore]
					--local charName = pChatData.localPlayer or GetUnitName("player")
					local charId = GetCurrentCharacterId()

					--Prevent the whisper notifications because of history restored messages
					if db.notifyIM and db.doNotNotifyOnRestoredWhisperFromHistory == true and (channelToRestore == CHAT_CHANNEL_WHISPER or channelToRestore == CHAT_CHANNEL_WHISPER_SENT) then
						preventWhisperNotificationsFromHistory = true
					end

					local timeStamp = GetTimeStamp()
					if db.LineStrings[historyIndex] and db.LineStrings[historyIndex].rawTimestamp and timeStamp - db.LineStrings[historyIndex].rawTimestamp < db.timeBeforeRestore * 60 * 60 and db.LineStrings[historyIndex].rawTimestamp < timeStamp then
						lastInsertionWas = math.max(lastInsertionWas, db.LineStrings[historyIndex].rawTimestamp)
						for containerIndex=1, #CHAT_SYSTEM.containers do
							for tabIndex=1, #CHAT_SYSTEM.containers[containerIndex].windows do
								if IsChatContainerTabCategoryEnabled(CHAT_SYSTEM.containers[containerIndex].id, tabIndex, category) then
									if not db.chatConfSync[charId].tabs[tabIndex].notBefore or db.LineStrings[historyIndex].rawTimestamp > db.chatConfSync[charId].tabs[tabIndex].notBefore then
										local restoredChatRawText = db.LineStrings[historyIndex].rawValue
										if restoredChatRawText and restoredChatRawText ~= "" then
											if db.addHistoryRestoredPrefix == true then
												--If the message was restored from history then add a prefix [H] )for history) to it!
												restoredChatRawText = restoredPrefix .. restoredChatRawText
											end
											CHAT_SYSTEM.containers[containerIndex]:AddEventMessageToWindow(CHAT_SYSTEM.containers[containerIndex].windows[tabIndex], AddLinkHandler(restoredChatRawText, channelToRestore, historyIndex), category)
									--[[
										else
											--DEBUG: Add SavedVariables entries for erroneous history entries (without rawValue text etc.)
											local restoreError = ""
											if restoredChatRawText and restoredChatRawText == "" then
												--debug("[pChat - Error]restoredChatRawText is missing! HistoryIndex: " ..tostring(historyIndex))
												restoreError = "rawText was missing"
											else
												--debug("[pChat - Error]restoredChatRawText is empty! HistoryIndex: " ..tostring(historyIndex))
												restoreError = "rawText was empty"
											end
											db.wrongRestoredHistoryIndices = db.wrongRestoredHistoryIndices or {}
											db.wrongRestoredHistoryIndices[historyIndex] = db.LineStrings[historyIndex]
											db.wrongRestoredHistoryIndices[historyIndex].restoreError = restoreError
									]]
										end
									end
								end
							end
						end
					else
						table.remove(db.LineStrings, historyIndex)
						db.lineNumber = db.lineNumber - 1
						historyIndex = historyIndex - 1
					end

				end
			end
			historyIndex = historyIndex + 1
		end

		local PRESSED = 1
		local UNPRESSED = 2
		local numTabs = #CHAT_SYSTEM.primaryContainer.windows

		for numTab, container in ipairs (CHAT_SYSTEM.primaryContainer.windows) do
			if numTab > 1 then
				CHAT_SYSTEM.primaryContainer:HandleTabClick(container.tab)
				local tabText = GetControl(constTabNameTemplate .. numTab .. "Text")
				tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
				tabText:GetParent().state = PRESSED
				local oldTabText = GetControl(constTabNameTemplate .. (numTab - 1) .. "Text")
				oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
				oldTabText:GetParent().state = UNPRESSED
			end
		end

		if numTabs > 1 then
			CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[1].tab)
			local tabText = GetControl(constTabNameTemplate.."1Text")
			tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
			tabText:GetParent().state = PRESSED
			local oldTabText = GetControl(constTabNameTemplate .. #CHAT_SYSTEM.primaryContainer.windows .. "Text")
			oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
			oldTabText:GetParent().state = UNPRESSED
		end

	end

	-- Restore TextEntry History
	if (wasReloadUI or db.restoreTextEntryHistoryAtLogOutQuit) and db.history.textEntry then

		if db.history.textEntry.entries then

			if lastInsertionWas and ((GetTimeStamp() - lastInsertionWas) < (db.timeBeforeRestore * 60 * 60)) then
				for _, text in ipairs(db.history.textEntry.entries) do
					CHAT_SYSTEM.textEntry:AddCommandHistory(text)
				end

				CHAT_SYSTEM.textEntry.commandHistory.index = db.history.textEntry.numEntries
			end

		end

	end
	preventWhisperNotificationsFromHistory = false
end

-- Restore History from SavedVars
local function RestoreChatHistory()

	-- Set default tab at login
	SetDefaultTab(db.defaultTab)
	-- Restore History
	if db.history then

		if db.lastWasReloadUI and db.restoreOnReloadUI then

			-- RestoreChannel
			if db.defaultchannel ~= PCHAT_CHANNEL_NONE then
				CHAT_SYSTEM:SetChannel(db.history.currentChannel, db.history.currentTarget)
			end

			-- restore TextEntry and Chat
			RestoreChatMessagesFromHistory(true)

			-- Restore tab when ReloadUI
			--** blocking for now
			--SetDefaultTab(db.history.currentTab)

		elseif (db.lastWasLogOut and db.restoreOnLogOut) or (db.lastWasAFK and db.restoreOnAFK) or (db.lastWasQuit and db.restoreOnQuit) then
			-- restore TextEntry and Chat
			RestoreChatMessagesFromHistory(false)
		end

		pChatData.messagesHaveBeenRestorated = true

		--Prevent the whisper notifications because of history restored messages
		preventWhisperNotificationsFromHistory = false

		local indexMessages = #pChatData.cachedMessages
		if indexMessages > 0 then
			for index=1, indexMessages do
				CHAT_SYSTEM:AddMessage(pChatData.cachedMessages[index])
			end
		end

		db.lastWasReloadUI = false
		db.lastWasLogOut = false
		db.lastWasQuit = false
		db.lastWasAFK = true
	else
		pChatData.messagesHaveBeenRestorated = true
	end

end

-- Store line number
-- Create an array for the copy functions, spam functions and revert history functions
-- WARNING : See FormatSysMessage()
local function StorelineNumber(rawTimestamp, rawFrom, text, chanCode, originalFrom)
	--debug("[pChat]StoreLineNumber")
	-- Strip DDS tag from Copy text
	local function StripDDStags(text)
		return text:gsub("|t(.-)|t", "")
	end

	local formattedMessage = ""
	local rawText = text

	-- SysMessages does not have a from
	if chanCode ~= CHAT_CHANNEL_SYSTEM then

		-- Timestamp cannot be nil anymore with SpamFilter, so use the option itself
		if db.showTimestamp then
			-- Format for Copy
			formattedMessage = "[" .. CreateTimestamp(GetTimeString()) .. "] "
		end

		-- Strip DDS tags for GM
		rawFrom = StripDDStags(rawFrom)

		-- Needed for SpamFilter
		db.LineStrings[db.lineNumber].rawFrom = originalFrom

		-- formattedMessage is only rawFrom for now
		formattedMessage = formattedMessage .. rawFrom

		if db.carriageReturn then
			formattedMessage = formattedMessage .. "\n"
		end

	end

	-- Needed for SpamFilter & Restoration, UNIX timestamp
	db.LineStrings[db.lineNumber].rawTimestamp = rawTimestamp

	-- Store CopyMessage / Used for SpamFiltering. Due to lua 0 == nil in arrays, set value to 98
	if chanCode == CHAT_CHANNEL_SAY then
		db.LineStrings[db.lineNumber].channel = PCHAT_CHANNEL_SAY
	else
		db.LineStrings[db.lineNumber].channel = chanCode
	end

	-- Store CopyMessage
	db.LineStrings[db.lineNumber].rawText = rawText

	-- Store CopyMessage
	--db.LineStrings[db.lineNumber].rawValue = text

	-- Strip DDS tags
	rawText = StripDDStags(rawText)

	-- Used to translate LinkHandlers
	rawText = FormatRawText(rawText)

	-- Store CopyMessage
	db.LineStrings[db.lineNumber].rawMessage = rawText

	-- Store CopyLine
	db.LineStrings[db.lineNumber].rawLine = formattedMessage .. rawText

	--Increment at each message handled
	db.lineNumber = db.lineNumber + 1

end

-- WARNING : Since AddMessage is bypassed, this function and all its subfunctions DOES NOT MUST CALL d() / Emitmessage() / AddMessage() or it will result an infinite loop and crash the game
-- Debug must call CHAT_SYSTEM:Zo_AddMessage() (-> referenced internally with debug() function) wich is backuped copy of CHAT_SYSTEM.AddMessage in order to NOT increase db.lineNumber e.g. and
-- create miss-matching indices in db.lineStrings!
local function FormatSysMessage(statusMessage)

	-- Display Timestamp if needed
	local function ShowTimestamp()

		local timestamp = ""

		-- Add timestamp
		if db.showTimestamp then

			-- Timestamp formatted
			timestamp = CreateTimestamp(GetTimeString())

			local timecol
			-- Timestamp color is chanCode so no coloring
			if db.timestampcolorislcol then
				 -- Show Message
				timestamp = string.format("[%s] ", timestamp)
			else
				-- Timestamp color is our setting color
				timecol = db.colours.timestamp

				-- Show Message
				timestamp = string.format("%s[%s] |r", timecol, timestamp)
			end
		else
			--timestamp = "" -- original lines of Ayantir
			--Fixed lines by Maggi (pChat comments on 2019-10-13 -> https://www.esoui.com/downloads/fileinfo.php?id=93&so=DESC)
			--I have found a bug in addon. You must have timestamp option enabled for addon to work properly.
			--The problem is: when you disable timestamp feature, history becomes bugged. You can check it, looks wierd.
			local lineNumber = db.lineNumber
			if lineNumber then
				db.LineStrings = db.LineStrings or {}
				db.LineStrings[lineNumber] = db.LineStrings[lineNumber] or {}
				db.LineStrings[lineNumber].rawValue = ""
			end
		end

		return timestamp

	end

	-- Only if statusMessage is set
	if statusMessage then

		-- Only if there something to display
		if string.len(statusMessage) > 0 then

			local sysMessage

			-- Some addons are quicker than pChat
			if db then

				-- Show Message
				statusMessage = ShowTimestamp() .. statusMessage

				if not db.lineNumber then
					db.lineNumber = 1
				end

				--	for CopySystem
				db.LineStrings[db.lineNumber] = {}

				-- Make it Linkable

				if db.enablecopy then
					sysMessage = AddLinkHandler(statusMessage, CHAT_CHANNEL_SYSTEM, db.lineNumber)
				else
					sysMessage = statusMessage
				end

				if not db.LineStrings[db.lineNumber].rawFrom then db.LineStrings[db.lineNumber].rawFrom = "" end
				if not db.LineStrings[db.lineNumber].rawMessage then db.LineStrings[db.lineNumber].rawMessage = "" end
				if not db.LineStrings[db.lineNumber].rawLine then db.LineStrings[db.lineNumber].rawLine = "" end
				if not db.LineStrings[db.lineNumber].rawValue then db.LineStrings[db.lineNumber].rawValue = statusMessage end
				if not db.LineStrings[db.lineNumber].rawDisplayed then db.LineStrings[db.lineNumber].rawDisplayed = sysMessage end

				-- No From, rawTimestamp is in statusMessage, sent as arg for SpamFiltering even if SysMessages are not filtered
				StorelineNumber(GetTimeStamp(), nil, statusMessage, CHAT_CHANNEL_SYSTEM, nil)

			end

			-- Show Message
			return sysMessage

		end

	end

end

-- Add a pChat handler for URL's
local function AddURLHandling(text)

	-- handle complex URLs and do
	for pos, url, prot, subd, tld, colon, port, slash, path in text:gmatch("()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%#=-]*))") do
		if pChatData.protocols[prot:lower()] == (1 - #slash) * #path
		and (colon == "" or port ~= "" and port + 0 < 65536)
		and (pChatData.tlds[tld:lower()] or tld:find("^%d+$") and subd:find("^%d+%.%d+%.%d+%.$") and math.max(tld, subd:match("^(%d+)%.(%d+)%.(%d+)%.$")) < 256)
		and not subd:find("%W%W")
		then
			local urlHandled = string.format("|H1:%s:%s:%s|h%s|h", PCHAT_LINK, db.lineNumber, PCHAT_URL_CHAN, url)
			url = url:gsub("([?+-])", "%%%1") -- don't understand why, 1st arg of gsub must be escaped and 2nd not.
			text, count = text:gsub(url, urlHandled)
		end
	end

	return text

end

local function InitializeURLHandling()

	-- cTLD + most used (> 0.1%)
	local domains =
	[[
	.ac.ad.ae.af.ag.ai.al.am.an.ao.aq.ar.as.at.au.aw.ax.az.ba.bb.bd.be.bf.bg.bh.bi.bj.bl.bm.bn.bo.bq
	.br.bs.bt.bv.bw.by.bz.ca.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.cr.cu.cv.cw.cx.cy.cz.de.dj.dk.dm.do.dz
	.ec.ee.eg.eh.er.es.et.eu.fi.fj.fk.fm.fo.fr.ga.gb.gd.ge.gf.gg.gh.gi.gl.gm.gn.gp.gq.gr.gs.gt.gu.gw
	.gy.hk.hm.hn.hr.ht.hu.id.ie.il.im.in.io.iq.ir.is.it.je.jm.jo.jp.ke.kg.kh.ki.km.kn.kp.kr.kw.ky.kz
	.la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly.ma.mc.md.me.mf.mg.mh.mk.ml.mm.mn.mo.mp.mq.mr.ms.mt.mu.mv.mw.mx
	.my.mz.na.nc.ne.nf.ng.ni.nl.no.np.nr.nu.nz.om.pa.pe.pf.pg.ph.pk.pl.pm.pn.pr.ps.pt.pw.py.qa.re.ro
	.rs.ru.rw.sa.sb.sc.sd.se.sg.sh.si.sj.sk.sl.sm.sn.so.sr.ss.st.su.sv.sx.sy.sz.tc.td.tf.tg.th.tj.tk
	.tl.tm.tn.to.tp.tr.tt.tv.tw.tz.ua.ug.uk.um.us.uy.uz.va.vc.ve.vg.vi.vn.vu.wf.ws.ye.yt.za.zm.zw
	.biz.com.coop.edu.gov.int.mil.mobi.info.net.org.xyz.top.club.pro.asia
	]]

	-- wxx.yy.zz
	pChatData.tlds = {}
	for tld in domains:gmatch('%w+') do
		pChatData.tlds[tld] = true
	end

	-- protos : only http/https
	pChatData.protocols = {['http://'] = 0, ['https://'] = 0}

end

local function GetChannelColors(channel, from)

	 -- Substract XX to a color (darker)
	local function FirstColorFromESOSettings(r, g, b)
		-- Scale is from 0-100 so divide per 300 will maximise difference at 0.33 (*2)
		r = math.max(r - (db.diffforESOcolors / 300 ),0)
		g = math.max(g - (db.diffforESOcolors / 300 ),0)
		b = math.max(b - (db.diffforESOcolors / 300 ),0)
		return r,g,b
	end

	 -- Add XX to a color (brighter)
	local function SecondColorFromESOSettings(r, g, b)
		r = math.min(r + (db.diffforESOcolors / 300 ),1)
		g = math.min(g + (db.diffforESOcolors / 300 ),1)
		b = math.min(b + (db.diffforESOcolors / 300 ),1)
		return r,g,b
	end

	if db.useESOcolors then

		-- ESO actual color, return r,g,b
		local rESO, gESO, bESO
		-- Handle the same-colour options.
		if db.allNPCSameColour and (channel == CHAT_CHANNEL_MONSTER_SAY or channel == CHAT_CHANNEL_MONSTER_YELL or channel == CHAT_CHANNEL_MONSTER_WHISPER) then
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_MONSTER_SAY)
		elseif db.allGuildsSameColour and (channel >= CHAT_CHANNEL_GUILD_1 and channel <= CHAT_CHANNEL_GUILD_5) then
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_GUILD_1)
		elseif db.allGuildsSameColour and (channel >= CHAT_CHANNEL_OFFICER_1 and channel <= CHAT_CHANNEL_OFFICER_5) then
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_OFFICER_1)
		elseif db.allZonesSameColour and (channel >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channel <= CHAT_CHANNEL_ZONE_LANGUAGE_4) then
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(CHAT_CHANNEL_ZONE_LANGUAGE_1)
		elseif channel == CHAT_CHANNEL_PARTY and from and db.groupLeader and zo_strformat(SI_UNIT_NAME, from) == GetUnitName(GetGroupLeaderUnitTag()) then
			rESO, gESO, bESO = ConvertHexToRGBA(db.colours["groupleader"])
		else
			rESO, gESO, bESO = ZO_ChatSystem_GetCategoryColorFromChannel(channel)
		end

		-- Set right colour to left colour - cause ESO colors are rewrited, if onecolor, no rewriting
		if db.oneColour then
			pChat.lcol = ConvertRGBToHex(rESO, gESO, bESO)
			pChat.rcol = pChat.lcol
		else
			pChat.lcol = ConvertRGBToHex(FirstColorFromESOSettings(rESO,gESO,bESO))
			pChat.rcol = ConvertRGBToHex(SecondColorFromESOSettings(rESO,gESO,bESO))
		end

	else
		-- pChat Colors
		-- Handle the same-colour options.
		if db.allNPCSameColour and (channel == CHAT_CHANNEL_MONSTER_SAY or channel == CHAT_CHANNEL_MONSTER_YELL or channel == CHAT_CHANNEL_MONSTER_WHISPER) then
			pChat.lcol = db.colours[2*CHAT_CHANNEL_MONSTER_SAY]
			pChat.rcol = db.colours[2*CHAT_CHANNEL_MONSTER_SAY + 1]
		elseif db.allGuildsSameColour and (channel >= CHAT_CHANNEL_GUILD_1 and channel <= CHAT_CHANNEL_GUILD_5) then
			pChat.lcol = db.colours[2*CHAT_CHANNEL_GUILD_1]
			pChat.rcol = db.colours[2*CHAT_CHANNEL_GUILD_1 + 1]
		elseif db.allGuildsSameColour and (channel >= CHAT_CHANNEL_OFFICER_1 and channel <= CHAT_CHANNEL_OFFICER_5) then
			pChat.lcol = db.colours[2*CHAT_CHANNEL_OFFICER_1]
			pChat.rcol = db.colours[2*CHAT_CHANNEL_OFFICER_1 + 1]
		elseif db.allZonesSameColour and (channel >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channel <= CHAT_CHANNEL_ZONE_LANGUAGE_4) then
			pChat.lcol = db.colours[2*CHAT_CHANNEL_ZONE]
			pChat.rcol = db.colours[2*CHAT_CHANNEL_ZONE + 1]
		elseif channel == CHAT_CHANNEL_PARTY and from and db.groupLeader and zo_strformat(SI_UNIT_NAME, from) == GetUnitName(GetGroupLeaderUnitTag()) then
			pChat.lcol = db.colours["groupleader"]
			pChat.rcol = db.colours["groupleader1"]
		else
			pChat.lcol = db.colours[2*channel]
			pChat.rcol = db.colours[2*channel + 1]
		end

		-- Set right colour to left colour
		if db.oneColour then
			pChat.rcol = pChat.lcol
		end

	end

	return pChat.lcol, pChat.rcol

end

-- Executed when EVENT_CHAT_MESSAGE_CHANNEL triggers
-- Formats the message
local function FormatMessage(chanCode, from, text, isCS, fromDisplayName, originalFrom, originalText, DDSBeforeAll, TextBeforeAll, DDSBeforeSender, TextBeforeSender, TextAfterSender, DDSAfterSender, DDSBeforeText, TextBeforeText, TextAfterText, DDSAfterText)
	debug("[pChat]FormatMessage - showGuildNr: " ..tostring(db.showGuildNumbers))
	local notHandled = false

	-- Will calculate if this message is a spam
	local isSpam = SpamFilter(chanCode, from, text, isCS)
	--debug(">isSpam: " ..tostring(isSpam))
	-- A spam, drop everything
	if isSpam then return end

	--local info = ChanInfoArray[chanCode]

	-- Init message with other addons stuff
	local message = DDSBeforeAll .. TextBeforeAll

	-- Init text with other addons stuff. Note : text can also be modified by other addons. Only originalText is the string the game has receive
	text = DDSBeforeText .. TextBeforeText .. text .. TextAfterText .. DDSAfterText

	--debug(">text: " ..tostring(text))
	if text == "" then return end

	if db.disableBrackets then
		chatStrings["copystandard"] = "%s: " -- standard format: say, yell, group, npc, npc yell, npc whisper, zone
		chatStrings["copyesostandard"] = "%s %s: " -- standard format: say, yell, group, npc, npc yell, npc whisper, zone with tag (except for monsters)
		chatStrings["copyesoparty"] = "[%s]%s: " -- standard format: party
		chatStrings["copytellIn"] = "%s: " -- tell in
		chatStrings["copytellOut"] = "-> %s: " -- tell out
		chatStrings["copyguild"] = "[%s] %s: " -- guild
		chatStrings["copylanguage"] = "[%s] %s: " -- language zones
	else
		chatStrings["copystandard"] = "[%s]: " -- standard format: say, yell, group, npc, npc yell, npc whisper, zone
		chatStrings["copyesostandard"] = "[%s] %s: " -- standard format: say, yell, group, npc, npc yell, npc whisper, zone with tag (except for monsters)
		chatStrings["copyesoparty"] = "[%s]%s: " -- standard format: party
		chatStrings["copytellIn"] = "[%s]: " -- tell in
		chatStrings["copytellOut"] = "-> [%s]: " -- tell out
		chatStrings["copyguild"] = "[%s] [%s]: " -- guild
		chatStrings["copylanguage"] = "[%s] %s: " -- language zones
	end

	--	for CopySystem
	--debug(">db.lineNumber: " ..tostring(db.lineNumber))
	db.LineStrings[db.lineNumber] = {}
	if not db.LineStrings[db.lineNumber].rawFrom then db.LineStrings[db.lineNumber].rawFrom = from end
	--if not db.LineStrings[db.lineNumber].rawValue then db.LineStrings[db.lineNumber].rawValue = text
		--debug(">>added db.LineStrings["..tostring(db.lineNumber).."].rawValue=" ..tostring(text))
	--end
	if not db.LineStrings[db.lineNumber].rawMessage then db.LineStrings[db.lineNumber].rawMessage = text end
	if not db.LineStrings[db.lineNumber].rawLine then db.LineStrings[db.lineNumber].rawLine = text end
	if not db.LineStrings[db.lineNumber].rawDisplayed then db.LineStrings[db.lineNumber].rawDisplayed = text end

	local new_from = ConvertName(chanCode, from, isCS, fromDisplayName)
	local displayedFrom = db.LineStrings[db.lineNumber].rawFrom

	-- Add other addons stuff related to sender
	new_from = DDSBeforeSender .. TextBeforeSender .. new_from .. TextAfterSender .. DDSAfterSender

	--debug(">new_from: " ..tostring(new_from))

	-- Guild tag
	local tag
	if (chanCode >= CHAT_CHANNEL_GUILD_1 and chanCode <= CHAT_CHANNEL_GUILD_5) then
		local guild_number = chanCode - CHAT_CHANNEL_GUILD_1 + 1
		local guildId = GetGuildId(guild_number)
		local guild_name = GetGuildName(guildId)
		tag = db.guildTags[guildId]
		if tag and tag ~= "" then
			tag = tag
		else
			tag = guild_name
		end
	elseif (chanCode >= CHAT_CHANNEL_OFFICER_1 and chanCode <= CHAT_CHANNEL_OFFICER_5) then
		local guild_number = chanCode - CHAT_CHANNEL_OFFICER_1 + 1
		local guildId = GetGuildId(guild_number)
		local guild_name = GetGuildName(guildId)
		local officertag = db.officertag[guildId]
		if officertag and officertag ~= "" then
			tag = officertag
		else
			tag = guild_name
		end
	end

	-- Initialise colours
	local lcol, rcol = GetChannelColors(chanCode, from)

	-- Add timestamp
	if db.showTimestamp then

		-- Initialise timstamp color
		local timecol = db.colours.timestamp

		-- Timestamp color is lcol
		if db.timestampcolorislcol then
			timecol = lcol
		else
			-- Timestamp color is timestamp color
			timecol = db.colours.timestamp
		end

		-- Message is timestamp for now
		-- Add PCHAT_HANDLER for display
		local timestamp = ZO_LinkHandler_CreateLink(CreateTimestamp(GetTimeString()), nil, PCHAT_LINK, db.lineNumber .. ":" .. chanCode) .. " "

		-- Timestamp color
		message = message .. string.format("%s%s|r", timecol, timestamp)
		db.LineStrings[db.lineNumber].rawValue = string.format("%s[%s] |r", timecol, CreateTimestamp(GetTimeString()))
	else
		--Fixed lines by Maggi (pChat PrivateMessage-> Pastebin link: https://pastebin.com/raw/dM7GQCsY)
		db.LineStrings[db.lineNumber].rawValue = ""
	end

	local linkedText = text

	-- Add URL Handling
	if db.urlHandling then
		text = AddURLHandling(text)
	end

	if db.enablecopy then
		linkedText = AddLinkHandler(text, chanCode, db.lineNumber)
	end

	local carriageReturn = ""
	if db.carriageReturn then
		carriageReturn = "\n"
	end

	-- Standard format
	if chanCode == CHAT_CHANNEL_SAY or chanCode == CHAT_CHANNEL_YELL or chanCode == CHAT_CHANNEL_PARTY or chanCode == CHAT_CHANNEL_ZONE then
		-- Remove zone tags
		if db.delzonetags then

			-- Used for Copy
			db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copystandard, db.LineStrings[db.lineNumber].rawFrom)

			message = message .. string.format(chatStrings.standard, lcol, new_from, carriageReturn, rcol, linkedText)
			db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.standard, lcol, new_from, carriageReturn, rcol, text)
			-- Keep them
		else
			-- Init zonetag to keep the channel tag
			local zonetag
			-- Pattern for party is [Party]
			if chanCode == CHAT_CHANNEL_PARTY then
				zonetag = GetString(PCHAT_ZONETAGPARTY)

				-- Used for Copy
				db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copyesoparty, zonetag, db.LineStrings[db.lineNumber].rawFrom)

				-- PartyHandler
				zonetag = ZO_LinkHandler_CreateLink(zonetag, nil, CHANNEL_LINK_TYPE, chanCode)

				message = message .. string.format(chatStrings.esoparty, lcol, zonetag, new_from, carriageReturn, rcol, linkedText)
				db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.esoparty, lcol, zonetag, new_from, carriageReturn, rcol, text)
			else
				-- Pattern for say/yell/zone is "player says:" ..
				if chanCode == CHAT_CHANNEL_SAY then zonetag = GetString(PCHAT_ZONETAGSAY)
				elseif chanCode == CHAT_CHANNEL_YELL then zonetag = GetString(PCHAT_ZONETAGYELL)
				elseif chanCode == CHAT_CHANNEL_ZONE then zonetag = GetString(PCHAT_ZONETAGZONE)
				end

				-- Used for Copy
				db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copyesostandard, db.LineStrings[db.lineNumber].rawFrom, zonetag)

				-- pChat Handler
				zonetag = string.format("|H1:p:%s|h%s|h", chanCode, zonetag)

				message = message .. string.format(chatStrings.esostandart, lcol, new_from, zonetag, carriageReturn, rcol, linkedText)
				db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.esostandart, lcol, new_from, zonetag, carriageReturn, rcol, text)
			end
		end

		-- NPC speech
	elseif chanCode == CHAT_CHANNEL_MONSTER_SAY or chanCode == CHAT_CHANNEL_MONSTER_YELL or chanCode == CHAT_CHANNEL_MONSTER_WHISPER then

		-- Used for Copy
		db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copynpc, db.LineStrings[db.lineNumber].rawFrom)

		message = message .. string.format(chatStrings.standard, lcol, new_from, carriageReturn, rcol, linkedText)
		db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.standard, lcol, new_from, carriageReturn, rcol, text)

		-- Incoming whispers
	elseif chanCode == CHAT_CHANNEL_WHISPER then

		--PlaySound
		--[[
		if db.soundforincwhisps then
			PlaySound(db.soundforincwhisps)
		end
		]]
		local notifyImSoundIndex = db.notifyIMIndex
		if SOUNDS and PlaySound and notifyImSoundIndex and pChat.sounds then
			local soundName = pChat.sounds[notifyImSoundIndex]
			if soundName and SOUNDS[soundName] then
				PlaySound(soundName)
			end
		end

		-- Used for Copy
		db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copytellIn, db.LineStrings[db.lineNumber].rawFrom)

		message = message .. string.format(chatStrings.tellIn, lcol, new_from, carriageReturn, rcol, linkedText)
		db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.tellIn, lcol, new_from, carriageReturn, rcol, text)

		-- Outgoing whispers
	elseif chanCode == CHAT_CHANNEL_WHISPER_SENT then

		-- Used for Copy
		db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copytellOut, db.LineStrings[db.lineNumber].rawFrom)

		message = message .. string.format(chatStrings.tellOut, lcol, new_from, carriageReturn, rcol, linkedText)
		db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.tellOut, lcol, new_from, carriageReturn, rcol, text)

		-- Guild chat
	elseif chanCode >= CHAT_CHANNEL_GUILD_1 and chanCode <= CHAT_CHANNEL_GUILD_5 then
		local gtag = tag
		if db.showGuildNumbers then
debug(">Guild chat channel: " ..tostring(gtag))
			gtag = (chanCode - CHAT_CHANNEL_GUILD_1 + 1) .. "-" .. tag

			--debug(">>gtag: " .. tostring(gtag).. ", chanCode: " ..tostring(chanCode) .. ", tag: " ..tostring(tag))

			-- Used for Copy
			db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copyguild, gtag, db.LineStrings[db.lineNumber].rawFrom)

			-- GuildHandler
			gtag = ZO_LinkHandler_CreateLink(gtag, nil, CHANNEL_LINK_TYPE, chanCode)
			message = message .. string.format(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, linkedText)
			db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, text)

		else
			--debug(">No guild number")

			-- Used for Copy
			db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copyguild, gtag, db.LineStrings[db.lineNumber].rawFrom)

			-- GuildHandler
			gtag = ZO_LinkHandler_CreateLink(gtag, nil, CHANNEL_LINK_TYPE, chanCode)

			message = message .. string.format(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, linkedText)
			db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, text)

		end

		-- Officer chat
	elseif chanCode >= CHAT_CHANNEL_OFFICER_1 and chanCode <= CHAT_CHANNEL_OFFICER_5 then

		local gtag = tag
		if db.showGuildNumbers then
			gtag = (chanCode - CHAT_CHANNEL_OFFICER_1 + 1) .. "-" .. tag

			-- Used for Copy
			db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copyguild, gtag, db.LineStrings[db.lineNumber].rawFrom)

			-- GuildHandler
			gtag = ZO_LinkHandler_CreateLink(gtag, nil, CHANNEL_LINK_TYPE, chanCode)

			message = message .. string.format(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, linkedText)
			db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, text)
		else

			-- Used for Copy
			db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copyguild, gtag, db.LineStrings[db.lineNumber].rawFrom)

			-- GuildHandler
			gtag = ZO_LinkHandler_CreateLink(gtag, nil, CHANNEL_LINK_TYPE, chanCode)

			message = message .. string.format(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, linkedText)
			db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, text)
		end

		-- Player emotes
	elseif chanCode == CHAT_CHANNEL_EMOTE then

		db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copyemote, db.LineStrings[db.lineNumber].rawFrom)
		message = message .. string.format(chatStrings.emote, lcol, new_from, rcol, linkedText)
		db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.emote, lcol, new_from, rcol, text)

		-- NPC emotes
	elseif chanCode == CHAT_CHANNEL_MONSTER_EMOTE then

		-- Used for Copy
		db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copyemote, db.LineStrings[db.lineNumber].rawFrom)

		message = message .. string.format(chatStrings.emote, lcol, new_from, rcol, linkedText)
		db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.emote, lcol, new_from, rcol, text)

		-- Language zones
	elseif chanCode >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and chanCode <= CHAT_CHANNEL_ZONE_LANGUAGE_4 then
		local lang
		if chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_1 then lang = "EN"
		elseif chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_2 then lang = "FR"
		elseif chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_3 then lang = "DE"
		elseif chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_4 then lang = "JP"
		end

		-- Used for Copy
		db.LineStrings[db.lineNumber].rawFrom = string.format(chatStrings.copylanguage, lang, db.LineStrings[db.lineNumber].rawFrom)

		message = message .. string.format(chatStrings.language, lcol, lang, new_from, carriageReturn, rcol, linkedText)
		db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. string.format(chatStrings.language, lcol, lang, new_from, carriageReturn, rcol, text)

		-- Unknown messages - just pass it through, no changes.
	else
		notHandled = true
		message = text
	end

	db.LineStrings[db.lineNumber].rawDisplayed = message

	-- Only if handled by pChat

	if not notHandled then
		-- Store message and params into an array for copy system and SpamFiltering
		StorelineNumber(GetTimeStamp(), db.LineStrings[db.lineNumber].rawFrom, text, chanCode, originalFrom)
	end

	-- Needs to be after .storelineNumber()
	if chanCode == CHAT_CHANNEL_WHISPER then
		OnIMReceived(displayedFrom, db.lineNumber - 1)
	end

	--debug("<messageNew: " ..tostring(message))

	return message

end
pChat.FormatMessage = FormatMessage

-- Rewrite of core function
function CHAT_SYSTEM:AddMessage(text)

	-- Overwrite CHAT_SYSTEM:AddMessage() function to format it
	-- Overwrite SharedChatContainer:AddDebugMessage(formattedEventText) in order to display system message in specific tabs
	-- debug() can be used in order to use old function
	-- Store the message in pChatData.cachedMessages if this one is sent before CHAT_SYSTEM.primaryContainer goes up (before 1st EVENT_PLAYER_ACTIVATED)

	-->Attention! Endless loop if you add debug messages via d() inside this function!
	if CHAT_SYSTEM.primaryContainer and pChatData.messagesHaveBeenRestorated then
		for k in ipairs(CHAT_SYSTEM.containers) do
			local chatContainer = CHAT_SYSTEM.containers[k]
			--Before API100030
			if chatContainer.OnChatEvent then
				chatContainer:OnChatEvent(nil, FormatSysMessage(text), CHAT_CATEGORY_SYSTEM)
			else
				--Since API10030
				--/pts5.3/esoui/ingame/chatsystem/sharedchatsystem.lua: SharedChatContainer:AddEventMessageToContainer(formattedEvent, category)
				chatContainer:AddEventMessageToContainer(FormatSysMessage(text), CHAT_CATEGORY_SYSTEM)
			end
		end
	else
		table.insert(pChatData.cachedMessages, text)
	end

end

local function EmitMessage(text)
	if CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer and pChatData.messagesHaveBeenRestorated then
		if text == "" then
			text = "[Empty String]"
		end
		CHAT_SYSTEM:AddMessage(text)
	else
		table.insert(pChatData.cachedMessages, text)
	end
end

local function EmitTable(t, indent, tableHistory)
	indent		  = indent or "."
	tableHistory	= tableHistory or {}

	for k, v in pairs(t)
	do
		local vType = type(v)

		EmitMessage(indent.."("..vType.."): "..tostring(k).." = "..tostring(v))

		if(vType == "table")
		then
			if(tableHistory[v])
			then
				EmitMessage(indent.."Avoiding cycle on table...")
			else
				tableHistory[v] = true
				EmitTable(v, indent.."  ", tableHistory)
			end
		end
	end
end

-- Rewrite of a core function d() to use the local defined new
-- EmitTable and EmitMessage functions!
function d(...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if(type(value) == "table")
		then
			EmitTable(value)
		else
			EmitMessage(tostring (value))
		end
	end
end

-- Rewrite of core function
function ZO_TabButton_Text_SetTextColor(self, color)

	local r, g, b, a = ConvertHexToRGBA(db.colours.tabwarning)

	if(self.allowLabelColorChanges) then
		local label = GetControl(self, "Text")
		label:SetColor(r, g, b, a)
	end

end

local FILTERS_PER_ROW = 2

-- defines the ordering of the filter categories
local CHANNEL_ORDERING_WEIGHT = {
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
	--CHAT_CATEGORY_ZONE_RUSSIAN] = 130,

	[CHAT_CATEGORY_SYSTEM] = 200,
}

local function FilterComparator(left, right)
	local leftPrimaryCategory = left.channels[1]
	local rightPrimaryCategory = right.channels[1]

	local leftWeight = CHANNEL_ORDERING_WEIGHT[leftPrimaryCategory]
	local rightWeight = CHANNEL_ORDERING_WEIGHT[rightPrimaryCategory]

	if leftWeight and rightWeight then
		return leftWeight < rightWeight
	elseif not leftWeight and not rightWeight then
		return false
	elseif leftWeight then
		return true
	end

	return false
end

--ESO standard chat channels to skip in chat options:
--Disable System channel so it is shown inside the options!
-- defines channels to skip when building the filter (non guild) section
local SKIP_CHANNELS = {
	--[CHAT_CATEGORY_SYSTEM] = true,
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

local FILTER_PAD_X = 90
local FILTER_PAD_Y = 0
local FILTER_WIDTH = 150
local FILTER_HEIGHT = 27
local INITIAL_XOFFS = 0
local INITIAL_YOFFS = 0

-- Rewrite of a core data
local COMBINED_CHANNELS = {
	[CHAT_CATEGORY_WHISPER_INCOMING] = {parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, name = SI_CHAT_CHANNEL_NAME_WHISPER},
	[CHAT_CATEGORY_WHISPER_OUTGOING] = {parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, name = SI_CHAT_CHANNEL_NAME_WHISPER},

	[CHAT_CATEGORY_MONSTER_SAY] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
	[CHAT_CATEGORY_MONSTER_YELL] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
	[CHAT_CATEGORY_MONSTER_WHISPER] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
	[CHAT_CATEGORY_MONSTER_EMOTE] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
}
--Rewrite chat options
function CHAT_OPTIONS:InitializeFilterButtons(dialogControl)
	--generate a table of entry data from the chat category header information
	local entryData = {}
	local lastEntry = CHAT_CATEGORY_HEADER_COMBAT - 1

	for i = CHAT_CATEGORY_HEADER_CHANNELS, lastEntry do
		if(SKIP_CHANNELS[i] == nil and GetString("SI_CHATCHANNELCATEGORIES", i) ~= "") then

			if(COMBINED_CHANNELS[i] == nil) then
				entryData[i] =
				{
					channels = { i },
					name = GetString("SI_CHATCHANNELCATEGORIES", i),
				}
			else
				--create the entry for those with combined channels just once
				local parentChannel = COMBINED_CHANNELS[i].parentChannel

				if(not entryData[parentChannel]) then
					entryData[parentChannel] =
					{
						channels = { },
						name = GetString(COMBINED_CHANNELS[i].name),
					}
				end

				table.insert(entryData[parentChannel].channels, i)
			end
		end
	end

	--now generate and anchor buttons
	local filterAnchor = ZO_Anchor:New(TOPLEFT, self.filterSection, TOPLEFT, 0, 0)
	local count = 0

	--pChat._entryData = entryData

	local sortedEntries = {}
	for _, entry in pairs(entryData) do
		sortedEntries[#sortedEntries + 1] = entry
	end

	table.sort(sortedEntries, FilterComparator)

	--pChat._sortedEntries = sortedEntries

	for _, entry in ipairs(sortedEntries) do
		local filter, key = self.filterPool:AcquireObject()
		filter.key = key

		local button = filter:GetNamedChild("Check")
		local zoCheckButtonWasUsed = false
		if ZO_CheckButton_SetLabelText and button then
			ZO_CheckButton_SetLabelText(button, entry.name)
			zoCheckButtonWasUsed = true
		end
		button.channels = entry.channels
		table.insert(self.filterButtons, button)
		if not zoCheckButtonWasUsed then
			local label = filter:GetNamedChild("Label")
			if label and label.SetText then
				label:SetText(entry.name)
			end
		end
		ZO_Anchor_BoxLayout(filterAnchor, filter, count, FILTERS_PER_ROW, FILTER_PAD_X, FILTER_PAD_Y, FILTER_WIDTH, FILTER_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
		count = count + 1
	end
end

-- Save chat configuration
local function SaveChatConfig()

	if not pChatData.tabNotBefore then
		pChatData.tabNotBefore = {} -- Init here or in SyncChatConfig depending if the "Clear Tab" has been used
	end

	if isAddonLoaded and CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer then -- Some addons calls SetCVar before
		--local charName = pChatData.localPlayer or GetUnitName("player")
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

			-- No.. need a ReloadUI		local name, isLocked, isInteractable, isCombatLog, areTimestampsEnabled = GetChatContainerTabInfo(1, numTab)
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

-- Save Chat Tabs config when user changes it
local function SaveTabsCategories()
	--local charName = pChatData.localPlayer or GetUnitName("player")
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

			--[[
			-- Don't overflow screen, remove 15px.
			if chatConfSyncForCharId.height >= (CHAT_SYSTEM.maxContainerHeight - 15 ) then
				CHAT_SYSTEM.control:SetHeight((CHAT_SYSTEM.maxContainerHeight - 15 ))
				debug("Overflow height " .. chatConfSyncForCharId.height .. " -+- " .. (CHAT_SYSTEM.maxContainerHeight - 15))
				debug(CHAT_SYSTEM.control:GetHeight())
			else
				-- Don't set good values ?! SetHeight(674) = GetHeight(524) ? same with Width and resizing is buggy
				--CHAT_SYSTEM.control:SetHeight(chatConfSyncForCharId.height)
				CHAT_SYSTEM.control:SetDimensions(settings.width, settings.height)
				debug("height " .. chatConfSyncForCharId.height .. " -+- " .. CHAT_SYSTEM.control:GetHeight())
			end

			-- Same
			if chatConfSyncForCharId.width >= (CHAT_SYSTEM.maxContainerWidth - 15 ) then
				CHAT_SYSTEM.control:SetWidth((CHAT_SYSTEM.maxContainerWidth - 15 ))
				debug("Overflow width " .. chatConfSyncForCharId.width .. " -+- " .. (CHAT_SYSTEM.maxContainerWidth - 15))
				debug(CHAT_SYSTEM.control:GetWidth())
			else
				CHAT_SYSTEM.control:SetHeight(chatConfSyncForCharId.width)
				debug("width " .. chatConfSyncForCharId.width .. " -+- " .. CHAT_SYSTEM.control:GetWidth())
			end
			]]--

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

-- When creating a char, try to import settings
local function AutoSyncSettingsForNewPlayer()

	-- New chars get automaticaly last char config
	if GetIsNewCharacter() then
		SyncChatConfig(true, "lastChar")
	end

end

-- Set channel to the default one
local function SetToDefaultChannel()
	if db.defaultchannel ~= PCHAT_CHANNEL_NONE then
		CHAT_SYSTEM:SetChannel(db.defaultchannel)
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
			num		= guildNum,
			id 		= guildId,
			name 	= guildName,
		}
	end
end

-- Executed when EVENT_IGNORE_ADDED triggers
local function OnIgnoreAdded(displayName)

	-- DisplayName is linkable
	local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
	local statusMessage = zo_strformat(SI_FRIENDS_LIST_IGNORE_ADDED, displayNameLink)

	-- Only if statusMessage is set
	if statusMessage then
		return FormatSysMessage(statusMessage)
	end

end

-- Executed when EVENT_IGNORE_REMOVED triggers
local function OnIgnoreRemoved(displayName)

	-- DisplayName is linkable
	local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
	local statusMessage = zo_strformat(SI_FRIENDS_LIST_IGNORE_REMOVED, displayNameLink)

	-- Only if statusMessage is set
	if statusMessage then
		return FormatSysMessage(statusMessage)
	end

end

-- triggers when EVENT_FRIEND_PLAYER_STATUS_CHANGED
local function OnFriendPlayerStatusChanged(displayName, characterName, oldStatus, newStatus)

	local statusMessage

	-- DisplayName is linkable
	local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
	-- CharacterName is linkable
	local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)

	local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
	local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

	-- Not connected before and Connected now (no messages for Away/Busy)
	if not wasOnline and isOnline then
		-- Return
		statusMessage = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink)
	-- Connected before and Offline now
	elseif wasOnline and not isOnline then
		statusMessage = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink)
	end

	-- Only if statusMessage is set
	if statusMessage then
		return FormatSysMessage(statusMessage)
	end

end

-- Executed when EVENT_GROUP_TYPE_CHANGED triggers
local function OnGroupTypeChanged(largeGroup)

	if largeGroup then
		return FormatSysMessage(GetString(SI_CHAT_ANNOUNCEMENT_IN_LARGE_GROUP))
	else
		return FormatSysMessage(GetString(SI_CHAT_ANNOUNCEMENT_IN_SMALL_GROUP))
	end

end

local function OnGroupMemberLeft(_, reason, isLocalPlayer, _, _, actionRequiredVote)
	if reason == GROUP_LEAVE_REASON_KICKED and isLocalPlayer and actionRequiredVote then
		return GetString(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
	end
end

local function UpdateCharCorrespondanceTableSwitchs()
debug("[pChat]UpdateCharCorrespondanceTableSwitchs")
	-- Each guild:_ Update table from ZO_ChatSystem_GetChannelInfo() to set teh possible switches (chat commands like /guild1 etc.)
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		--local guildName = GetGuildName(guildId)
		-- Get saved string
		local switch = db.switchFor[guildId]
		if switch and switch ~= "" then
			switch = GetString(SI_CHANNEL_SWITCH_GUILD_1 - 1 + i) .. " " .. switch
		else
			switch = GetString(SI_CHANNEL_SWITCH_GUILD_1 - 1 + i)
		end
		ChanInfoArray[CHAT_CHANNEL_GUILD_1 - 1 + i].switches = switch

debug(">Set switch " ..tostring(switch) .." for guild# " .. tostring(i))

		-- Get saved string
		local officerSwitch = db.officerSwitchFor[guildId]
		-- No SavedVar
		if officerSwitch and officerSwitch ~= "" then
			officerSwitch = GetString(SI_CHANNEL_SWITCH_OFFICER_1 - 1 + i)  .. " " .. officerSwitch
		else
			officerSwitch = GetString(SI_CHANNEL_SWITCH_OFFICER_1 - 1 + i)
		end
		ChanInfoArray[CHAT_CHANNEL_OFFICER_1 - 1 + i].switches = officerSwitch
	end

end

-- *********************************************************************************
-- * Section: LAM Outside Functions : used in LAM but function resides outside LAM
-- *********************************************************************************
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


-- *********************************************************************************
-- * Section: Settings Start (LAM)
-- *********************************************************************************
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
	--local charName = pChatData.localPlayer or GetUnitName("player")
	local charId = GetCurrentCharacterId()

	local fontsDefined = LMP:List('font')

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
				setFunc = 	function(choice)
								db.defaultTabName = choice
								--debug(choice)
								--debug(db.defaultTabName)
								db.defaultTab = getTabIdx(choice)
								--debug(db.defaultTab)
							end,
			},
			--[[{-- CHAT_SYSTEM.primaryContainer.windows doesn't exists yet at OnAddonLoaded. So using the pChat reference.
				type = "dropdown",
				name = GetString(PCHAT_DEFAULTTAB),
				tooltip = GetString(PCHAT_DEFAULTTABTT),
				choices = arrayTab,
				width = "full",
				default = defaults.defaultTab,
				getFunc = function() return db.defaultTab end,
				setFunc = function(choice) db.defaultTab = choice end,
			},]]--
			--[[{-- Enable whisper redirect
				type = "checkbox",
				name = GetString(PCHAT_enableWhisperTab),
				tooltip = GetString(PCHAT_enableWhisperTabT),
				getFunc = function() return db.enableWhisperTab end,
				setFunc = function(newValue) db.enableWhisperTab = newValue end,
				width = "full",
				default = defaults.enableWhisperTab,
			},]]--
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
					SyncChatConfig(true, charId)
				end,
			},
		},
	} -- Mouse
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = GetString(PCHAT_APPARENCEMH),
		controls = {
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
					ChangeChatWindowDarkness()
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
					ChangeChatFont(true)
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
			--[[
			{-- LAM Option Whispers: Sound
				type = "dropdown",
				name = GetString(PCHAT_SOUNDFORINCWHISPS),
				tooltip = GetString(PCHAT_SOUNDFORINCWHISPSTT),
				choices = {
					GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 1),
					GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 2),
					GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 3),
					GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 4),
					},
				width = "full",
				default = defaults.soundforincwhisps, --> SOUNDS.NEW_NOTIFICATION
				getFunc = function()
					if db.soundforincwhisps == SOUNDS.NONE then
						return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 1)
					elseif db.soundforincwhisps == SOUNDS.NEW_NOTIFICATION then
						return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 2)
					elseif db.soundforincwhisps == SOUNDS.DEFAULT_CLICK then
						return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 3)
					elseif db.soundforincwhisps == SOUNDS.EDIT_CLICK then
						return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 4)
					else
						return GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 2)
					end
				end,
				setFunc = function(choice)
					if choice == GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 1) then
						db.soundforincwhisps = SOUNDS.NONE
						PlaySound(SOUNDS.NONE)
					elseif choice == GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 2) then
						db.soundforincwhisps = SOUNDS.NEW_NOTIFICATION
						PlaySound(SOUNDS.NEW_NOTIFICATION)
					elseif choice == GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 3) then
						db.soundforincwhisps = SOUNDS.DEFAULT_CLICK
						PlaySound(SOUNDS.DEFAULT_CLICK)
					elseif choice == GetString("PCHAT_SOUNDFORINCWHISPSCHOICE", 4) then
						db.soundforincwhisps = SOUNDS.EDIT_CLICK
						PlaySound(SOUNDS.EDIT_CLICK)
					else
						-- When clicking on LAM default button
						db.soundforincwhisps = defaults.soundforincwhisps
					end

				end,
			},
			]]
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
					pChat.ChatSystem_CreateChannelData()
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
					pChat.ChatSystem_CreateChannelData()
				end
			},
			{
				type = "editbox",
				name = GetString(PCHAT_SWITCHFOR),
				tooltip = GetString(PCHAT_SWITCHFORTT),
				getFunc = function() return db.switchFor[guildId] end,
				setFunc = function(newValue)
					db.switchFor[guildId] = newValue
					UpdateCharCorrespondanceTableSwitchs()
					pChat.ChatSystem_CreateChannelData()
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
					db.officerSwitchFor[guildId] = newValue
					UpdateCharCorrespondanceTableSwitchs()
					pChat.ChatSystem_CreateChannelData()
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

	LAM:RegisterOptionControls("pChatOptions", optionsData)

end

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

	pChat.LAMPanel = LAM:RegisterAddonPanel("pChatOptions", panelData)

	-- Build OptionTable. In a separate func in order to rebuild it in case of Guild Reorg.
	SyncCharacterSelectChoices()
	BuildLAMPanel()

end
--**Settings End
-- Triggered by EVENT_GUILD_SELF_JOINED_GUILD
local function OnSelfJoinedGuild(_, guildServerId, characterName, guildId)

	-- It will rebuild optionsTable and recreate tables if user didn't went in this section before
	BuildLAMPanel()

	-- If recently added to a new guild and never go in menu db.formatguild[guildName] won't exist, it won't create the value if joining an known guild
	if not db.formatguild[guildServerId] then
		-- 2 is default value
		db.formatguild[guildServerId] = 2
	end

	-- Save Guild indexes for guild reorganization
	SaveGuildIndexes()

end

-- Revert category settings
local function RevertCategories(guildId)

	-- Old GuildId
	local oldIndex = pChatData.guildIndexes[guildId].num
	-- old Total Guilds
	local totGuilds = GetNumGuilds() + 1

	if oldIndex and oldIndex < totGuilds then
		--local charName = pChatData.localPlayer or GetUnitName("player")
		local charId = GetCurrentCharacterId()

		-- If our guild was not the last one, need to revert colors
		--debug("pChat will revert starting from " .. oldIndex .. " to " .. totGuilds)

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

-- Registers the formatMessage function.
-- Unregisters itself from the player activation event with the event manager.
local function OnPlayerActivated()
debug("EVENT_PLAYER_ACTIVATED - Start")
	if isAddonLoaded and not eventPlayerActivatedCheckRunning then
		pChatData.sceneFirst = false

		--Adding the formatting to the text, the timestamp, username/accountname etc.
		local chatHandlerFunctions = pChat.chatHandlers --> See file pChat_chatHandlers.lua
		if chatHandlerFunctions and CHAT_ROUTER and CHAT_ROUTER.RegisterMessageFormatter then
			--Set the local variables in file pChat_chatHandlers.lua to the pChat function names
			--for the formatters
			chatHandlerFunctions.SetChatHandlerFunctions()

			--2020-03-02 Baertram
			--ZOs fixed the chat event handler callback function registering.
			--Not using LibChatMessage fix anmyore!
			--And not "overwriting" the functions anymore, but registering new ones using CHAT_ROUTER:RegisterMessageFormatter(eventKey, messageFormatter)
			for eventId, eventCallBackFunc in pairs(chatHandlerFunctions) do
				if eventId and eventCallBackFunc and type(eventCallBackFunc) == "function" then
					CHAT_ROUTER:RegisterMessageFormatter(eventId, eventCallBackFunc)
				end
			end
		end
	end

	--Test if the chat_system containers are given already or wait until they are.
	--Only test 3 seconds (12x250ms), then do the event_player_activated tasks!
	if eventPlayerActivatedChecksDone <= 12 and (CHAT_SYSTEM == nil or CHAT_SYSTEM.primaryContainer == nil) then
debug("EVENT_PLAYER_ACTIVATED: CHAT_SYSTEM.primaryContainer is missing!")
		if not eventPlayerActivatedCheckRunning then
			EVENT_MANAGER:RegisterForUpdate("pChatDebug_Event_Player_Activated", 250, function()
				eventPlayerActivatedChecksDone = eventPlayerActivatedChecksDone + 1
				eventPlayerActivatedCheckRunning = true
				OnPlayerActivated()
			end)
		end
	else
debug("EVENT_PLAYER_ACTIVATED: Found CHAT_SYSTEM.primaryContainer!")
		eventPlayerActivatedCheckRunning = false
		EVENT_MANAGER:UnregisterForUpdate("pChatDebug_Event_Player_Activated")

		if isAddonLoaded then
			--Get a reference to the chat channelData (CHAT_SYSTEM.channelData)
			ChanInfoArray = ZO_ChatSystem_GetChannelInfo()

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

			if CHAT_SYSTEM.Maximize then
				-- Visual Notification PreHook
				ZO_PreHook(CHAT_SYSTEM, "Maximize", function(self)
					CHAT_SYSTEM.IMLabelMin:SetHidden(true)
				end)
			end

			--Scroll to bottom in Chat: Secure post hook to hide the Whisper Notifications
			SecurePostHook("ZO_ChatSystem_ScrollToBottom", function(ctrl)
				pChat_RemoveIMNotification()
			end)


			--local fontPath = ZoFontChat:GetFontInfo()
			--CHAT_SYSTEM:AddMessage(fontPath)
			--CHAT_SYSTEM:AddMessage("|C3AF24BLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.|r")
			--CHAT_SYSTEM:AddMessage("Characters below should be well displayed :")
			--CHAT_SYSTEM:AddMessage("!\"#$%&'()*+,-./0123456789:;<=>?@ ABCDEFGHIJKLMNOPQRSTUVWXYZ [\]^_`abcdefghijklmnopqrstuvwxyz{|} ~¡£¤¥¦§©«-®°²³´µ¶·»½¿ ÀÁÂÄÆÇÈÉÊËÌÍÎÏÑÒÓÔÖ×ÙÚÛÜßàáâäæçèéêëìíîïñòóôöùúûüÿŸŒœ")

			-- AntiSpam
			pChatData.spamLookingForEnabled = true
			pChatData.spamWantToEnabled = true
			pChatData.spamGuildRecruitEnabled = true

			-- Show 1000 lines instead of 200 & Change fade delay
			ShowFadedLines()
			-- Get Chat Tab Names stored in chatTabNames {}
			getTabNames()
			-- Rebuild Lam Panel
			BuildLAMPanel()
			-- Create the chat tab's PostHook
			CreateNewChatTabPostHook()

			-- Should we minimize ?
			MinimizeChatAtLaunch()

			-- Message for new chars
			AutoSyncSettingsForNewPlayer()

			-- Chat Config synchronization
			SyncChatConfig(db.chatSyncConfig, "lastChar")
			SaveChatConfig()

			-- Tags next to entry box: Add them to the chat channels of table ChanInfoArray
			UpdateCharCorrespondanceTableChannelNames()

			-- Update chat switches: Add them to the chat channels of table ChanInfoArray
			UpdateCharCorrespondanceTableSwitchs()

			--Update the channel and channel switch lookup tables
			-->With API100030 the function CHAT_SYSTEM:CreateChannelData does not exist anymore but the code is used inside SharedChatSystem:Initialize
			-->Create a Compatibility function and call it then
			function pChat.ChatSystem_CreateChannelData()
				debug("pChat.ChatSystem_CreateChannelData-Start")
				local switchLookup = {}
				local channelInfo = ChanInfoArray
				for channelId, data in pairs(channelInfo) do
					data.id = channelId

					if data.switches then
						debug(">switch: " ..tostring(data.switches))
						for switchArg in data.switches:gmatch("%S+") do
							switchArg = switchArg:lower()
							switchLookup[switchArg] = data
							if not switchLookup[channelId] then
								switchLookup[channelId] = switchArg
							end
						end
					end

					if data.targetSwitches then
						debug(">targetSwitches: " ..tostring(data.targetSwitches))
						local targetData = ZO_ShallowTableCopy(data)
						targetData.target = channelId
						for switchArg in data.targetSwitches:gmatch("%S+") do
							switchArg = switchArg:lower()
							switchLookup[switchArg] = targetData
							if not switchLookup[channelId] then
								switchLookup[channelId] = switchArg
							end
						end
					end
				end
				--Reassign the change table values to the CHAT_SYSTEM now in order to make the
				--changed guild switches work (e.g. /guildnameshort)
				CHAT_SYSTEM.switchLookup = switchLookup
				debug("pChat.ChatSystem_CreateChannelData-End")
			end
			pChat.ChatSystem_CreateChannelData()

			-- Set default channel at login
			SetToDefaultChannel()

			-- Save all category colors
			SaveGuildIndexes()

			-- Handle Copy text
			CopyToTextEntryText()

			-- Restore History if needed
			RestoreChatHistory()
			-- Default Tab
			SetDefaultTab(db.defaultTab)
			-- Change Window apparence
			ChangeChatWindowDarkness()

			isAddonInitialized = true

			EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
			debug("EVENT_PLAYER_ACTIVATED - End: Addon was initialized")
		end
	end
end


-- Runs whenever "me" left a guild (or get kicked)
local function OnSelfLeftGuild(_, guildServerId, characterName, guildId)

	-- It will rebuild optionsTable and recreate tables if user didn't went in this section before
	BuildLAMPanel()

	-- Revert category colors & options
	RevertCategories(guildServerId)

end

local function SwitchToParty(characterName)

	zo_callLater(function(characterName) -- characterName = avoid ZOS bug
		-- If "me" join group
		if(GetRawUnitName("player") == characterName) then

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

-- triggers when EVENT_GROUP_MEMBER_LEFT
local function OnGroupMemberLeft(_, characterName, reason, wasMeWhoLeft)

	-- Go back to default channel
	if GetGroupSize() <= 1 then
		-- Go back to default channel when leaving a group
		if db.enablepartyswitch then
			-- Only if we was on party
			if CHAT_SYSTEM.currentChannel == CHAT_CHANNEL_PARTY and db.defaultchannel ~= PCHAT_CHANNEL_NONE then
				SetToDefaultChannel()
			end
		end
	end

end

-- Save a category color for guild chat, set by ChatSystem at launch + when user change manually
local function SaveChatCategoriesColors(category, r, g, b)
	--local charName = pChatData.localPlayer or GetUnitName("player")
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
			AddMenuItem(GetString(SI_CHAT_CONFIG_CREATE_NEW), function() self.system:CreateNewChatTab(self) end)
		end

		if not ZO_Dialogs_IsShowingDialog() and not window.combatLog and (not self:IsPrimary() or tabIndex ~= 1) then
			AddMenuItem(GetString(SI_CHAT_CONFIG_REMOVE), function() self:ShowRemoveTabDialog(tabIndex) end)
		end

		if not ZO_Dialogs_IsShowingDialog() then
			AddMenuItem(GetString(SI_CHAT_CONFIG_OPTIONS), function() self:ShowOptions(tabIndex) end)
		end

		if not ZO_Dialogs_IsShowingDialog() then
			AddMenuItem(GetString(PCHAT_CLEARBUFFER), function()
				pChatData.tabNotBefore[tabIndex] = GetTimeStamp()
				self.windows[tabIndex].buffer:Clear()
				self:SyncScrollToBuffer()
			end)
		end

		if self:IsPrimary() and tabIndex == 1 then
			if self:IsLocked(tabIndex) then
				AddMenuItem(GetString(SI_CHAT_CONFIG_UNLOCK), function() self:SetLocked(tabIndex, false) end)
			else
				AddMenuItem(GetString(SI_CHAT_CONFIG_LOCK), function() self:SetLocked(tabIndex, true) end)
			end
		end

		if window.combatLog then
			if self:AreTimestampsEnabled(tabIndex) then
				AddMenuItem(GetString(SI_CHAT_CONFIG_HIDE_TIMESTAMP), function() self:SetTimestampsEnabled(tabIndex, false) end)
			else
				AddMenuItem(GetString(SI_CHAT_CONFIG_SHOW_TIMESTAMP), function() self:SetTimestampsEnabled(tabIndex, true) end)
			end
		end

		--[[
		local charId = GetCurrentCharacterId()
		if db.chatConfSync[charId].textEntryDocked then
			AddMenuItem(GetString(PCHAT_UNDOCKTEXTENTRY), function() UndockTextEntry() end)
		else
			AddMenuItem(GetString(PCHAT_REDOCKTEXTENTRY), function() RedockTextEntry() end)
		end
		]]

		ShowMenu(window.tab)
	end

	return true

end

--need the needed libraries and show error messages if not found
local function loadLibraries()
	--[Needed]
	LAM = LibAddonMenu2
	if LAM == nil and LibStub then LAM = LibStub("LibAddonMenu-2.0", true) end
	assert(LAM, string.format(GetString(PCHAT_LIB_MISSING), "LibAddonMenu-2.0"))
	pChat.LAM = LAM

	LMP = pChat.LMP or LibMediaProvider
	if LMP == nil and LibStub then LMP = LibStub("LibMediaProvider-1.0", true) end
	assert(LMP, string.format(GetString(PCHAT_LIB_MISSING), "LibMediaProvider-1.0"))
	pChat.LMP = LMP

	LoadLMM("pChat - Start")

	LCM = LibChatMessage
	pChat.LCM = LCM
	--assert(LCM, string.format(GetString(PCHAT_LIB_MISSING), "LibChatMessage"))

	--[Optional]
	LCT = LibCustomTitles
	if not LCT and LibStub then LCT = LibStub("LibCustomTitles", true) end
	pChat.LCT = LCT

	if LibDebugLogger then
		pChat.logger = LibDebugLogger("pChat")
	end
end

--Migrate some SavedVariables to new structures
local function MigrateSavedVars()
debug("MigrateSavedVars")
	--Chat configuration synchronization was moved from characterNames as table key in table db.chatConfSync
	--to characterId -> Attention: The charId is a String as well so one needs to change it to a number
	local newChatConfSync = {}
	if db.chatConfSync ~= nil then
		local charName2Id = pChat.characterNameRaw2Id
		local charId2Name = pChat.characterId2NameRaw
		for charName, charsChatConfSyncData in pairs(db.chatConfSync) do
			--debug(">charName: " ..tostring(charName) .. ", type: " ..tostring(type(tonumber(charName))))
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
local function LoadSavedVariables()
	db = ZO_SavedVars:NewAccountWide('PCHAT_OPTS', 0.9, nil, defaults)
	pChat.db = db

	--Migrate old SavedVariables to new structures
	MigrateSavedVars()
end

-- Please note that some things are delayed in OnPlayerActivated() because Chat isn't ready when this function triggers
local function OnAddonLoaded(_, addonName)
	--Protect
	if addonName == ADDON_NAME then
		eventPlayerActivatedChecksDone = 0

		--Load the needed libraries
		loadLibraries()

		--PTS API100030 Harrowstorm: Chat message event handler fix by LibChatMessage @sirinsidiator
		--> 2020-03-02: Fix is not needed anymore as ZOs provided a fix to the chat message handlers. Disabling it in LCM!
		if LCM then LCM.formatRegularChat = false end

		-- Resize, must be loaded before CHAT_SYSTEM is set
		--local width, height = GuiRoot:GetDimensions()
		--CHAT_SYSTEM.maxContainerWidth, CHAT_SYSTEM.maxContainerHeight = width, height

		do
			local orgCalculateConstraints = SharedChatContainer.CalculateConstraints
			function SharedChatContainer.CalculateConstraints(...)
				local self = ...
				local w, h = GuiRoot:GetDimensions()
				self.system.maxContainerWidth, self.system.maxContainerHeight = w * 0.95, h * 0.95
				return orgCalculateConstraints(...)
			end
		end

		--Build the character name to unique ID mapping tables and vice-versa
		--The character names are decorated with the color and icon of the class!
		pChat.characterName2Id = getCharactersOfAccount(true, true)
		pChat.characterId2Name = getCharactersOfAccount(false, true)
		pChat.characterNameRaw2Id = getCharactersOfAccount(true, false)
		pChat.characterId2NameRaw = getCharactersOfAccount(false, false)

		-- Char name
		pChatData.localPlayer = GetUnitName("player")

		--Load the SV
		LoadSavedVariables()

		--LAM and db for saved vars
		GetDBAndBuildLAM()

		-- Used for CopySystem

		if not db.lineNumber then
			db.lineNumber = 1
		elseif type(db.lineNumber) ~= "number" then
			db.lineNumber = 1
			db.LineStrings = {}
		elseif db.lineNumber > 5000 then
			StripLinesFromLineStrings(0)
		end

		if not db.chatTabChannel then
			db.chatTabChannel = {}
		end

		if not db.LineStrings then
			db.LineStrings = {}
		end

		if not pChat.tabNames then
			pChat.tabNames = {}
		end

		-- Will set Keybind for "switch to next tab" if needed
		SetSwitchToNextBinding()

		-- Will change font if needed
		ChangeChatFont()

		-- Automated messages
		InitAutomatedMessages()

		-- Minimize Chat in Menus
		MinimizeChatInMenus()

		BuildNicknames()

		InitializeURLHandling()

		-- PreHook ReloadUI, SetCVar, LogOut & Quit to handle Chat Import/Export
		ZO_PreHook("ReloadUI", function()
			SaveChatHistory(1)
			SaveChatConfig()
		end)

		ZO_PreHook("SetCVar", function()
			SaveChatHistory(1)
			SaveChatConfig()
		end)

		ZO_PreHook("Logout", function()
			SaveChatHistory(2)
			SaveChatConfig()
		end)

		ZO_PreHook("Quit", function()
			SaveChatHistory(3)
			SaveChatConfig()
		end)

		-- Social option change color
		ZO_PreHook("SetChatCategoryColor", SaveChatCategoriesColors)
		-- Chat option change categories filters, add a callLater because settings are set after this function triggers.
		ZO_PreHook("ZO_ChatOptions_ToggleChannel", function() zo_callLater(SaveTabsCategories, 100) end)

		-- Right click on a tab name
		ZO_PreHook("ZO_ChatSystem_ShowOptions", function(control) return ChatSystemShowOptions() end)
		ZO_PreHook("ZO_ChatWindow_OpenContextMenu", function(control) return ChatSystemShowOptions(control.index) end)
		-- Bindings
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

		-- Because ChatSystem is loaded after EVENT_ADDON_LOADED triggers, we use 1st EVENT_PLAYER_ACTIVATED wich is run bit after
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

		-- Register OnSelfJoinedGuild with EVENT_GUILD_SELF_JOINED_GUILD
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_SELF_JOINED_GUILD, OnSelfJoinedGuild)
		-- Register OnSelfLeftGuild with EVENT_GUILD_SELF_LEFT_GUILD
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_SELF_LEFT_GUILD, OnSelfLeftGuild)

		-- Whisp my target
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)

		-- Party switches
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)

		-- Unregisters
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

		pChat.pChatData = pChatData
		pChat.db = db

		isAddonLoaded = true
	end
	
end

--Handled by keybind
function pChat_ToggleChat()
	
	if CHAT_SYSTEM:IsMinimized() then
		CHAT_SYSTEM:Maximize()
	else
		CHAT_SYSTEM:Minimize()
	end
	
end

-- Called by bindings
function pChat_WhispMyTarget()
	if targetToWhisp then
		CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, targetToWhisp)
	end
end

-- For compatibility. Called by others addons.
function pChat.formatSysMessage(statusMessage)
	return FormatSysMessage(statusMessage)
end

-- For compatibility. Called by others addons.
function pChat_FormatSysMessage(statusMessage)
	return FormatSysMessage(statusMessage)
end

-- For compatibility. Called by others addons.
function pChat_GetChannelColors(channel, from)
	return GetChannelColors(channel, from)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
