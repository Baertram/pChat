-- Messages settings
local strings = {
-- New May Need Translations
	-- ************************************************
	-- Chat tab selector Bindings
	-- ************************************************
	PCHAT_Tab1 = "Select Chat Tab 1",
	PCHAT_Tab2 = "Select Chat Tab 2",
	PCHAT_Tab3 = "Select Chat Tab 3",
	PCHAT_Tab4 = "Select Chat Tab 4",
	PCHAT_Tab5 = "Select Chat Tab 5",
	PCHAT_Tab6 = "Select Chat Tab 6",
	PCHAT_Tab7 = "Select Chat Tab 7",
	PCHAT_Tab8 = "Select Chat Tab 8",
	PCHAT_Tab9 = "Select Chat Tab 9",
	PCHAT_Tab10 = "Select Chat Tab 10",
	PCHAT_Tab11 = "Select Chat Tab 11",
	PCHAT_Tab12 = "Select Chat Tab 12",
	-- 9.3.6.24 Additions
	PCHAT_CHATTABH = "Chat Tab Settings",
	PCHAT_enableChatTabChannel = "Enable Last Used Channel Per Tab",
	PCHAT_enableChatTabChannelT = "Enable chat tabs to remember the last used channel, it will become the default until you opt to use a different one in that tab.",
	PCHAT_enableWhisperTab = "Enable Whisper Redirect",
	PCHAT_enableWhisperTabT = "Enable redirect your whispers to a specific tab.",
	
-- New Need Translations


	PCHAT_ADDON_INFO = "pChat overhauls the way text is displayed in the chatbox.You are able to change colors, sizes, notifications, play sounds, etc.\nThe addon ChatMentions is integrated into pChat.\nUse the slashcommand /msg to define short chat commands which will write your longtext to the chat (guild welcome messages e.g.)",
	PCHAT_ADDON_INFO_2 = "Use the slash command \'/pchatdeleteoldsv\' to delete old non-server dependent SavedVariables (shrink the SV file size).",

	PCHAT_OPTIONSH = "Chat settings",
	PCHAT_MESSAGEOPTIONSH = "Message settings",
	PCHAT_MESSAGEOPTIONSNAMEH = "Name in messages",
	PCHAT_MESSAGEOPTIONSNAME_ALLOTHERH = "All other chat messages",
	PCHAT_MESSAGEOPTIONSCOLORH = "Color of messages",

	PCHAT_GUILDNUMBERS = "Guild numbers",
	PCHAT_GUILDNUMBERSTT = "Shows the guild number next to the guild tag",

	PCHAT_ALLGUILDSSAMECOLOUR = "Same color for all guilds",
	PCHAT_ALLGUILDSSAMECOLOURTT = "Makes all guild chats use the same color as \'%s\'",

	PCHAT_ALLZONESSAMECOLOUR = "Same color for all zones",
	PCHAT_ALLZONESSAMECOLOURTT = "Makes all zone chats use the same color as /zone",

	PCHAT_ALLNPCSAMECOLOUR = "Same color for all NPC",
	PCHAT_ALLNPCSAMECOLOURTT = "Makes all NPC lines use the same color as NPC say",

	PCHAT_DELZONETAGS = "Remove zone tags",
	PCHAT_DELZONETAGSTT = "Remove tags such as says, yells at the beginning of the message",

	PCHAT_ZONETAGSAY = "says",
	PCHAT_ZONETAGYELL = "yells",
	PCHAT_ZONETAGPARTY = "Group",
	PCHAT_ZONETAGZONE = "zone",

	PCHAT_CARRIAGERETURN = "Name & message in seperated lines",
	PCHAT_CARRIAGERETURNTT = "Player names and chat texts are separated by a newline.",

	PCHAT_USEESOCOLORS = "Use ESO colors",
	PCHAT_USEESOCOLORSTT = "Use colors set in social settings instead pChat ones.\nIf you enable this setting the chat channel colors won't be activated!",

	PCHAT_DIFFFORESOCOLORS = "Enable brightness difference",
	PCHAT_DIFFFORESOCOLORSTT = "Adjust brightness difference between player name/zone and message text displayed by this value (name will get darker / message text will get brighter).\nThis option is not working if you enable the option \'Use one color for lines\'!\nSet the slider to 0 to deactivate the brightness difference.",
	PCHAT_DIFFFORESOCOLORSDARKEN = "Brightness diff.: Darken by",
	PCHAT_DIFFFORESOCOLORSDARKENTT = "Darken the chat name by this value.",
	PCHAT_DIFFFORESOCOLORSLIGHTEN = "Brightness diff.: Brighten by",
	PCHAT_DIFFFORESOCOLORSLIGHTENTT = "Brighten the chat text by this value.",

	PCHAT_REMOVECOLORSFROMMESSAGES = "Remove colors from messages",
	PCHAT_REMOVECOLORSFROMMESSAGESTT = "Stops people using things like rainbow colored text",

	PCHAT_PREVENTCHATTEXTFADING = "Prevent chat text fading",
	PCHAT_PREVENTCHATTEXTFADINGTT = "Prevents the chat text from fading (you can prevent the BG from fading at the \'Chat window settings\')",
	PCHAT_CHATTEXTFADINGBEGIN = "Text fade begin after seconds",
	PCHAT_CHATTEXTFADINGBEGINTT = "Fade the text after this seconds have passed",
	PCHAT_CHATTEXTFADINGDURATION = "Text fade duration seconds",
	PCHAT_CHATTEXTFADINGDURATIONTT = "Fade the text taking this duration in seconds",


	PCHAT_AUGMENTHISTORYBUFFER = "Augment # of lines displayed in chat",
	PCHAT_AUGMENTHISTORYBUFFERTT = "Per default, only the last 200 lines are displayed in chat. This feature raise this value up to 1000 lines",

	PCHAT_USEONECOLORFORLINES = "Use one color for lines",
	PCHAT_USEONECOLORFORLINESTT = "Instead of having two colors per channel, only use 1st color (the player color)",

	PCHAT_GUILDTAGSNEXTTOENTRYBOX = "Guild tags next to text box",
	PCHAT_GUILDTAGSNEXTTOENTRYBOXTT = "Show the guild tag instead of the guild name left of the chat's text entry box",

	PCHAT_DISABLEBRACKETS = "Remove brackets around names",
	PCHAT_DISABLEBRACKETSTT = "Remove the brackets [] around player names",

	PCHAT_DEFAULTCHANNEL = "Default channel",
	PCHAT_DEFAULTCHANNELTT = "Select which channel to use at login",

	PCHAT_DEFAULTCHANNELCHOICE99 = "Do not change",
	PCHAT_DEFAULTCHANNELCHOICE31 = "/zone",
	PCHAT_DEFAULTCHANNELCHOICE0 = "/say",
	PCHAT_DEFAULTCHANNELCHOICE12 = "/guild1",
	PCHAT_DEFAULTCHANNELCHOICE13 = "/guild2",
	PCHAT_DEFAULTCHANNELCHOICE14 = "/guild3",
	PCHAT_DEFAULTCHANNELCHOICE15 = "/guild4",
	PCHAT_DEFAULTCHANNELCHOICE16 = "/guild5",
	PCHAT_DEFAULTCHANNELCHOICE17 = "/officer1",
	PCHAT_DEFAULTCHANNELCHOICE18 = "/officer2",
	PCHAT_DEFAULTCHANNELCHOICE19 = "/officer3",
	PCHAT_DEFAULTCHANNELCHOICE20 = "/officer4",
	PCHAT_DEFAULTCHANNELCHOICE21 = "/officer5",

	PCHAT_GEOCHANNELSFORMAT = "Names format",
	PCHAT_GEOCHANNELSFORMATTT = "Names format for local channels (say, zone, tell)",

	PCHAT_DEFAULTTAB = "Default tab",
	PCHAT_DEFAULTTABTT = "Select which tab to display at startup",

	PCHAT_ADDCHANNELANDTARGETTOHISTORY = "Switch channel using arrow keys",
	PCHAT_ADDCHANNELANDTARGETTOHISTORYTT = "Switch the channel when using arrow keys to match the channel previously used.",

	PCHAT_URLHANDLING = "Detect URLs/links",
	PCHAT_URLHANDLINGTT = "If a URL starting with http(s):// is linked in chat pChat will detect it and you'll be able to click on it to directly open the link with your system set standard web browser.\Attention: ESO will always ask if you want to open the external link first.",

	PCHAT_ENABLECOPY = "Enable copy",
	PCHAT_ENABLECOPYTT = "Enable copy with a right click on text - Also enable the channel switch with a left click. Disable this option if you got problems to display links in chat",

	-- Group Settings

	PCHAT_GROUPH = "Party tweaks",

	PCHAT_ENABLEPARTYSWITCH = "Auto channel switch: party",
	PCHAT_ENABLEPARTYSWITCHTT = "Enabling Party switch will switch your current channel to party when joining a party and  switch back to your default channel when leaving a party",

	PCHAT_ENABLEPARTYSWITCHPORTTODUNGEON 	= "Auto switch: dungeon/reloadui",
	PCHAT_ENABLEPARTYSWITCHPORTTODUNGEONTT 	= "The above mentioned party switch will also change the chat channel to /party if you port into a dungeon/do a reloadui/login + your are grouped.\nThis setting will be only available if the party switch is enabled!",

	PCHAT_GROUPLEADER = "Special color for party leader",
	PCHAT_GROUPLEADERTT = "Enabling this feature will let you set a special color for party leader messages",

	PCHAT_GROUPLEADERCOLOR = "Leader name color",
	PCHAT_GROUPLEADERCOLORTT = "Color of party leader name.",

	PCHAT_GROUPLEADERCOLOR1 = "Leader message color",
	PCHAT_GROUPLEADERCOLOR1TT = "Color of message for party leader. If \"Use ESO colors\" is enabled this option will be disabled.",

	PCHAT_GROUPNAMES = "Names format for groups",
	PCHAT_GROUPNAMESTT = "Format of your groupmates names in party channel",

	-- Sync settings

	PCHAT_SYNCH = "Syncing settings",

	PCHAT_CHATSYNCCONFIG = "Sync chat configuration",
	PCHAT_CHATSYNCCONFIGTT = "If the sync is enabled, all your chars will get the same chat configuration (colors, position, window dimensions, tabs)\nPS: Only enable this option after your chat is fully customized !",

	PCHAT_CHATSYNCCONFIGIMPORTFROM = "Import chat settings from",
	PCHAT_CHATSYNCCONFIGIMPORTFROMTT = "You can at any time import chat settings from another character (colors, position, window dimensions, tabs)",

	-- Apparence

	PCHAT_APPARENCEMH = "Chat window settings",

	PCHAT_WINDOWDARKNESS = "Chat window darkness",
	PCHAT_WINDOWDARKNESSTT = "Increase the darkening of the chat window. 0 = No darkness\nWill affect the inactive & the active chat window!",

	PCHAT_CHATMINIMIZEDATLAUNCH = "Chat minimized at startup",
	PCHAT_CHATMINIMIZEDATLAUNCHTT = "Minimize chat window on the left side of the screen when the game starts",

	PCHAT_CHATMINIMIZEDINMENUS = "Chat minimized in menus",
	PCHAT_CHATMINIMIZEDINMENUSTT = "Minimize chat window on the left of the screen when you enter in menus (Guild, Stats, Crafting, etc)",

	PCHAT_CHATMAXIMIZEDAFTERMENUS = "Restore chat after exiting menus",
	PCHAT_CHATMAXIMIZEDAFTERMENUSTT = "Always restore the chat window after exiting menus",

	PCHAT_FONTCHANGE = "Chat Font",
	PCHAT_FONTCHANGETT = "Set the Chat font",

	PCHAT_TABWARNING = "New message warning",
	PCHAT_TABWARNINGTT = "Set the warning color for tab name",

	-- Whisper settings

	PCHAT_IMH = "Whispers",

	PCHAT_SOUNDFORINCWHISPS = "Sound for inc. whisps",
	PCHAT_SOUNDFORINCWHISPSTT = "Choose sound wich will be played when you receive a whisp",

	PCHAT_NOTIFYIM = "Visual notification",
	PCHAT_NOTIFYIMTT = "If you miss a whisp, a notification will appear in the top right corner of the chat allowing you to quickly access to it. Plus, if your chat was minimized at that time, a notification will be displayed in the minibar",

	PCHAT_SOUNDFORINCWHISPSCHOICE1 = "None",
	PCHAT_SOUNDFORINCWHISPSCHOICE2 = "Notification",
	PCHAT_SOUNDFORINCWHISPSCHOICE3 = "Click",
	PCHAT_SOUNDFORINCWHISPSCHOICE4 = "Write",

	-- Restore chat settings

	PCHAT_RESTORECHATH = "Restore chat",

	PCHAT_RESTOREONRELOADUI = "After a ReloadUI",
	PCHAT_RESTOREONRELOADUITT = "After reloading game with a ReloadUI(), pChat will restore your chat and its history",

	PCHAT_RESTOREONLOGOUT = "After a LogOut",
	PCHAT_RESTOREONLOGOUTTT = "After a logoff, pChat will restore your chat and its history if you login in the allotted time set under",

	PCHAT_RESTOREONAFK = "After being kicked",
	PCHAT_RESTOREONAFKTT = "After being kicked from game after inactivity, flood or a network disconnect, pChat will restore your chat and its history if you login in the allotted time set under",

	PCHAT_RESTOREONQUIT = "After leaving game",
	PCHAT_RESTOREONQUITTT = "After leaving game, pChat will restore your chat and its history if you login in the allotted time set under",

	PCHAT_TIMEBEFORERESTORE = "Maximum time for restoring chat",
	PCHAT_TIMEBEFORERESTORETT = "After this time (in hours), pChat will not attempt to restore the chat",

	PCHAT_RESTORESYSTEM = "Restore System Messages",
	PCHAT_RESTORESYSTEMTT = "Restore System Messages (Such as login notifications or add ons messages) when chat is restored",

	PCHAT_RESTORESYSTEMONLY = "Restore Only System messages",
	PCHAT_RESTORESYSTEMONLYTT = "Restore Only System Messages (Such as login notifications or add ons messages) when chat is restored",

	PCHAT_RESTOREWHISPS = "Restore Whispers",
	PCHAT_RESTOREWHISPSTT = "Restore whispers sent and received after logoff, disconnect or quit. Whispers are always restored after a ReloadUI()",

	PCHAT_RESTOREWHISPS_NO_NOTIFY = "No whisper notification on restore",
	PCHAT_RESTOREWHISPS_NO_NOTIFY_TT = "Do not show the whisper notifications, and do not color the chat tab for restored whisper messages.\nCan only be enabled if the whisper notifications are enabled.",

	PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT  = "Restore Text entry history",
	PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT  = "Restore Text entry history available with arrow keys after logoff, disconnect or quit. History of text entry is always restored after a ReloadUI()",

	-- Anti Spam settings

	PCHAT_ANTISPAMH = "Anti-Spam",

	PCHAT_FLOODPROTECT = "Enable anti-flood",
	PCHAT_FLOODPROTECTTT = "Prevents the players close to you from sending identical and repeated messages",

	PCHAT_FLOODGRACEPERIOD = "Duration of anti-flood banishment",
	PCHAT_FLOODGRACEPERIODTT = "Number of seconds while the previous identical message will be ignored",

	PCHAT_LOOKINGFORPROTECT = "Ignore grouping messages",
	PCHAT_LOOKINGFORPROTECTTT = "Ignore the messages players seeking to establish / join group",

	PCHAT_WANTTOPROTECT = "Ignore Commercial messages",
	PCHAT_WANTTOPROTECTTT = "Ignore messages from players looking to buy, sell or trade",

	PCHAT_SPAMGRACEPERIOD = "Temporarily stopping the spam",
	PCHAT_SPAMGRACEPERIODTT = "When you make yourself a research group message or trade, spam temporarily disables the function you have overridden the time to have an answer. It reactivates automatically after a period that can be set (in minutes)",

	-- Nicknames settings

	PCHAT_NICKNAMESH = "Nicknames",
	PCHAT_NICKNAMESD = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name.",
	PCHAT_NICKNAMES = "List of Nicknames",
	PCHAT_NICKNAMESTT = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\n\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name.",

	-- Timestamp settings

	PCHAT_TIMESTAMPH = "Timestamp",

	PCHAT_ENABLETIMESTAMP = "Enable timestamp",
	PCHAT_ENABLETIMESTAMPTT = "Adds a timestamp to chat messages",

	PCHAT_TIMESTAMPCOLORISLCOL = "Timestamp color same as player one",
	PCHAT_TIMESTAMPCOLORISLCOLTT = "Ignore timestamp color and colorize timestamp same as player / NPC name",

	PCHAT_TIMESTAMPFORMAT = "Timestamp format",
	PCHAT_TIMESTAMPFORMATTT = "FORMAT:\nHH: hours (24)\nhh: hours (12)\nH: hour (24, no leading 0)\nh: hour (12, no leading 0)\nA: AM/PM\na: am/pm\nm: minutes\ns: seconds",

	PCHAT_TIMESTAMP = "Timestamp",
	PCHAT_TIMESTAMPTT = "Set color for the timestamp",

	-- Guild settings
	PCHAT_GUILDH = "Guild tweaks",

	PCHAT_CHATCHANNELSH = "Chat channels",

	PCHAT_NICKNAMEFOR = "Nickname",
	PCHAT_NICKNAMEFORTT = "Nickname for ",

	PCHAT_OFFICERTAG = "Officer chat tag",
	PCHAT_OFFICERTAGTT = "Prefix for Officers chats",

	PCHAT_SWITCHFOR = "Switch for channel",
	PCHAT_SWITCHFORTT = "New switch for channel. Ex: /myguild",

	PCHAT_OFFICERSWITCHFOR = "Switch for officer channel",
	PCHAT_OFFICERSWITCHFORTT = "New switch for officer channel. Ex: /offs",

	PCHAT_NAMEFORMAT = "Name format",
	PCHAT_NAMEFORMATTT = "Select how guild member names are formatted",

	PCHAT_FORMATCHOICE1 = "@UserID",
	PCHAT_FORMATCHOICE2 = "Character Name",
	PCHAT_FORMATCHOICE3 = "Character Name@UserID",
	PCHAT_FORMATCHOICE4 = "@UserID/Character Name",

	PCHAT_SETCOLORSFORTT = "Set colors for members of <<1>>",
	PCHAT_SETCOLORSFORCHATTT = "Set colors for messages of <<1>>",

	PCHAT_SETCOLORSFOROFFICIERSTT = "Set colors for members of Officer chat of <<1>>",
	PCHAT_SETCOLORSFOROFFICIERSCHATTT = "Set colors for messages of Officer chat of <<1>>",

	PCHAT_MEMBERS = "Player name",
	PCHAT_CHAT = "Message",

	PCHAT_OFFICERSTT = " Officer",

	-- Channel colors settings

	PCHAT_CHATCOLORSH = "Chat channel colors",

	PCHAT_SAY = "Say - name",
	PCHAT_SAYTT = "Set player name color for say channel",

	PCHAT_SAYCHAT = "Say - message",
	PCHAT_SAYCHATTT = "Set chat message color for say channel",

	PCHAT_ZONE = "Zone - name",
	PCHAT_ZONETT = "Set player name color for zone channel",

	PCHAT_ZONECHAT = "Zone - message",
	PCHAT_ZONECHATTT = "Set chat message color for zone channel",

	PCHAT_YELL = "Yell - name",
	PCHAT_YELLTT = "Set player name color for yell channel",

	PCHAT_YELLCHAT = "Yell - message",
	PCHAT_YELLCHATTT = "Set chat message color for yell channel",

	PCHAT_INCOMINGWHISPERS = "Incoming whispers - name",
	PCHAT_INCOMINGWHISPERSTT = "Set player name color for incoming whispers",

	PCHAT_INCOMINGWHISPERSCHAT = "Incoming whispers - message",
	PCHAT_INCOMINGWHISPERSCHATTT = "Set chat message color for incoming whispers",

	PCHAT_OUTGOINGWHISPERS = "Outgoing whispers - name",
	PCHAT_OUTGOINGWHISPERSTT = "Set player name color for outgoing whispers",

	PCHAT_OUTGOINGWHISPERSCHAT = "Outgoing whispers - message",
	PCHAT_OUTGOINGWHISPERSCHATTT = "Set chat message color for outgoing whispers",

	PCHAT_GROUP = "Group - name",
	PCHAT_GROUPTT = "Set player name color for group chat",

	PCHAT_GROUPCHAT = "Group - message",
	PCHAT_GROUPCHATTT = "Set chat message color for group chat",

	-- Other colors

	PCHAT_OTHERCOLORSH = "Other Colors",

	PCHAT_EMOTES = "Emotes - name",
	PCHAT_EMOTESTT = "Set player name color for emotes",

	PCHAT_EMOTESCHAT = "Emotes - message",
	PCHAT_EMOTESCHATTT = "Set chat message color for emotes",

	PCHAT_ENZONE = "EN Zone - name",
	PCHAT_ENZONETT = "Set player name color for English zone channel",

	PCHAT_ENZONECHAT = "EN Zone - message",
	PCHAT_ENZONECHATTT = "Set chat message color for English zone channel",

	PCHAT_FRZONE = "FR Zone - name",
	PCHAT_FRZONETT = "Set player name color for French zone channel",

	PCHAT_FRZONECHAT = "FR Zone - message",
	PCHAT_FRZONECHATTT = "Set chat message color for French zone channel",

	PCHAT_DEZONE = "DE Zone - name",
	PCHAT_DEZONETT = "Set player name color for German zone channel",

	PCHAT_DEZONECHAT = "DE Zone - message",
	PCHAT_DEZONECHATTT = "Set chat message color for German zone channel",

	PCHAT_JPZONE = "JP Zone - name",
	PCHAT_JPZONETT = "Set player name color for Japanese zone channel",

	PCHAT_JPZONECHAT = "JP Zone - message",
	PCHAT_JPZONECHATTT = "Set chat message color for Japanese zone channel",

	PCHAT_RUZONE = "RU Zone - name",
	PCHAT_RUZONETT = "Set player name color for Russian zone channel",

	PCHAT_RUZONECHAT = "RU Zone - message",
	PCHAT_RUZONECHATTT = "Set chat message color for Russian zone channel",

	PCHAT_ESZONE = "ES Zone - name",
	PCHAT_ESZONETT = "Set player name color for Spanish zone channel",

	PCHAT_ESZONECHAT = "ES Zone - message",
	PCHAT_ESZONECHATTT = "Set chat message color for Spanish zone channel",

	PCHAT_ZHZONE = "ZH Zone - name",
	PCHAT_ZHZONETT = "Set player name color for Chinese zone channel",

	PCHAT_ZHZONECHAT = "ZH Zone - message",
	PCHAT_ZHZONECHATTT = "Set chat message color for Chinese zone channel",

	PCHAT_NPCSAY = "NPC Say - name",
	PCHAT_NPCSAYTT = "Set NPC name color for NPC say",

	PCHAT_NPCSAYCHAT = "NPC Say - message",
	PCHAT_NPCSAYCHATTT = "Set NPC chat message color for NPC say",

	PCHAT_NPCYELL = "NPC Yell - name",
	PCHAT_NPCYELLTT = "Set NPC name color for NPC yell",

	PCHAT_NPCYELLCHAT = "NPC Yell - message",
	PCHAT_NPCYELLCHATTT = "Set NPC chat message color for NPC yell",

	PCHAT_NPCWHISPER = "NPC Whisper - name",
	PCHAT_NPCWHISPERTT = "Set NPC name color for NPC whisper",

	PCHAT_NPCWHISPERCHAT = "NPC Whisper - message",
	PCHAT_NPCWHISPERCHATTT = "Set NPC chat message color for NPC whisper",

	PCHAT_NPCEMOTES = "NPC Emotes - name",
	PCHAT_NPCEMOTESTT = "Set NPC name color for NPC emotes",

	PCHAT_NPCEMOTESCHAT = "NPC Emotes - message",
	PCHAT_NPCEMOTESCHATTT = "Set NPC chat message color for NPC emotes",

	-- Debug settings

	PCHAT_DEBUGH = "Debug",

	PCHAT_DEBUG = "Debug",
	PCHAT_DEBUGTT = "Debug",

	-- Various strings not in panel settings

	PCHAT_UNDOCKTEXTENTRY = "Undock Text Entry",
	PCHAT_REDOCKTEXTENTRY = "Redock Text Entry",

	PCHAT_COPYXMLTITLE = "Copy text with Ctrl+C",
	PCHAT_COPYXMLLABEL = "Copy text with Ctrl+C",
	PCHAT_COPYXMLTOOLONG = "Splitted text",
	PCHAT_COPYXMLPREV = "Prev",
	PCHAT_COPYXMLNEXT = "Next",
	PCHAT_COPYXMLAPPLY = "Apply filter",

	PCHAT_COPYMESSAGECT = "Copy message",
	PCHAT_COPYLINECT = "Copy line",
	PCHAT_COPYDISCUSSIONCT = "Copy channel talk",
	PCHAT_ALLCT = "Copy whole chat",

	PCHAT_SWITCHTONEXTTABBINDING = "Switch to next tab",
	PCHAT_TOGGLECHATBINDING = "Toggle Chat Window",
	PCHAT_WHISPMYTARGETBINDING = "Whisper my target",
	PCHAT_COPYWHOLECHATBINDING = "Copy whole chat (dialog)",

	PCHAT_SAVMSGERRALREADYEXISTS = "Cannot save your message, this one already exists",
	PCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Example : ts3",
	PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Write here the text which will be sent when you'll be using the auto message function",
	PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Newlines will be automatically deleted",
	PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "This message will be sent when you'll validate the message \"!nameOfMessage\". (ex: |cFFFFFF!ts3|r)",
	PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "To send a message in a specified channel, add its switch at the begenning of the message (ex: |cFFFFFF/g1|r)",
	PCHAT_AUTOMSG_NAME_HEADER = "Abbreviation of your message",
	PCHAT_AUTOMSG_MESSAGE_HEADER = "Substitution message",
	PCHAT_AUTOMSG_ADD_TITLE_HEADER = "New automated message",
	PCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modify automated message",
	PCHAT_AUTOMSG_ADD_AUTO_MSG = "Add",
	PCHAT_AUTOMSG_EDIT_AUTO_MSG = "Edit",
	PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG = "Automated messages",
	PCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Remove",

	PCHAT_CLEARBUFFER = "Clear chat",


	--Added by Baertram
	PCHAT_RESTORED_PREFIX = "[H]",
	PCHAT_RESTOREPREFIX = "Add prefix to restored messages",
	PCHAT_RESTOREPREFIXTT = "Add a prefix \'[H]\' to restored messages in order to easily see they were restored.\nThis will affect the current chat only after a reloadUI!\nThe color of the prefix will be shown with the standard ESO chat channel colors.",

	PCHAT_BUILT_IN_CHANNEL_SWITCH_WARNING = "Cannot use existing built-in switch '%s'",
	PCHAT_DUPLICATE_CHANNEL_SWITCH_WARNING = "Tried to replace already existing switch '%s'",

	PCHAT_CHATHANDLERS = "Chat format handlers",
	PCHAT_CHATHANDLER_TEMPLATETT = "Format the chat messages of the event \'%s\'.\n\nIf this setting is disabled the chat messages won't be changed with the different pChat formatting options (e.g. colors, timestamps, names, etc.)",
	PCHAT_CHATHANDLER_SYSTEMMESSAGES = "System messages",
	PCHAT_CHATHANDLER_PLAYERSTATUS = "Player status changed",
	PCHAT_CHATHANDLER_IGNORE_ADDED = "Ignore list added",
	PCHAT_CHATHANDLER_IGNORE_REMOVED = "Ignore list removed",
	PCHAT_CHATHANDLER_GROUP_MEMBER_LEFT = "Group member left",
	PCHAT_CHATHANDLER_GROUP_TYPE_CHANGED = "Group type changed",
	PCHAT_CHATHANDLER_KEEP_ATTACK_UPDATE = "Keep attack update",

	PCHAT_SETTINGS_EDITBOX_HOOKS 					= "Chat editbox",
	PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACE 		= "CTRL + backspace: Remove word",
	PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACETT 	= "Pressing the CTRL key + BACKSPACE key will remove the whole word left to the cursor.",

	PCHAT_SETTINGS_BACKUP 							= "Backup",
	PCHAT_SETTINGS_BACKUP_REMINDER_LAST_REMINDER 	= "Last reminder: %s",
	PCHAT_SETTINGS_BACKUP_REMINDER 					= "Backup reminder",
	PCHAT_SETTINGS_BACKUP_REMINDER_TT 				= "Show a reminder to backup your SavedVariables once a week. It will automatically show if an APIversion increasement was detected (due to a game patch e.g.).\n\nYou always should do a backup of your whole SavedVariables folder after a game patch, BEFORE starting the game client!",
	PCHAT_SETTINGS_BACKUP_REMINDER_DIALOG_TEXT		= "Please |cFF0000!logout!|r and backup your pChat SavedVariables!\nThe following link at www.esoui.com explains\nhow to do it:\n\nhttps://www.esoui.com/forums/showthread.php?t=9235\n\nJust press the confirm button and the next dialog\nshown will ask to open the website\n(if you need to learn how to backup your SavedVariables).",
	PCHAT_SETTINGS_WARNING_REMINDER_LOGOUT_BEFORE	= "Remember to LOGOUT first!",

	PCHAT_RESTORESHOWNAMEANDZONE = "After restore: Show name & zone",
	PCHAT_RESTORESHOWNAMEANDZONE_TT = "Afficher @Account actuellement connecté - Nom et zone du personnage dans le chat, après la restauration de l'historique du chat.",

	PCHAT_SHOWACCANDCHARATCONTEXTMENU = "@Account/Charname at context menu",
	PCHAT_SHOWACCANDCHARATCONTEXTMENU_TT = "Show the @AccountName/Charname at the copy context menu.\nThis will only show both if you have enabled the name formatting of that chat channel to show both too!\nAnd some chat channels like whisper does not provide both!",

	-- Coorbin20200708
	-- Chat Mentions settings strings
	PCHAT_MENTIONSH = "Mentions",
	PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_NAME = "Change color of text when your name is mentioned?",
	PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_TOOLTIP = "Whether or not to change the text color when your name is mentioned.",
	PCHAT_MENTIONS_TEXT_COLOR_PICKER_NAME = "Color of your name when mentioned",
	PCHAT_MENTIONS_ADD_EXCL_ICON_NAME = "Add exclamation icon?",
	PCHAT_MENTIONS_ADD_EXCL_ICON_TOOLTIP = "Whether or not to add an exclamation point icon at the beginning when your name is mentioned.",
	PCHAT_MENTIONS_ALLCAPS_NAME = "ALL CAPS your name?",
	PCHAT_MENTIONS_ALLCAPS_TOOLTIP = "Whether or not to ALL CAPS your name when your name is mentioned.",
	PCHAT_MENTIONS_EXTRA_NAMES_NAME = "Extra names to ping on (newline per name)",
	PCHAT_MENTIONS_EXTRA_NAMES_TOOLTIP = "A newline-separated list of additional names to ping you on. Press ENTER to make new lines. If you put an `!` (exclamation mark) in front of a custom name you'd like to monitor, it will only notify you if that name occurs on a word boundary. For example, if you add '!de' to your Extras list, you'd be notified for 'de nada' but not 'delicatessen'. If you just added 'de' to your Extras list, you'd be notified for 'delicatessen' also.",
	PCHAT_MENTIONS_SELFSEND_NAME = "Apply to messages YOU send?",
	PCHAT_MENTIONS_SELFSEND_TOOLTIP = "Whether or not to apply formatting to messages YOU send.",
	PCHAT_MENTIONS_DING_NAME = "Ding sound?",
	PCHAT_MENTIONS_DING_TOOLTIP = "Whether or not to play a ding sound when your name is mentioned.",
	PCHAT_MENTIONS_DING_SOUND_NAME = "Choose sound",
	PCHAT_MENTIONS_DING_SOUND_NAME_TOOLTIP = "Choose the sound to play",
	PCHAT_MENTIONS_APPLYNAME_NAME = "Apply to your character names?",
	PCHAT_MENTIONS_APPLYNAME_TOOLTIP = "Whether or not to apply formatting to each name (separated by spaces) in your character name. Disable if you use a very common name like 'Me' in your character name.",
	PCHAT_MENTIONS_WHOLEWORD_NAME = "Match your names as whole words only?",
	PCHAT_MENTIONS_WHOLEWORD_TOOLTIP = "Whether or not to match your character names as whole words only. If you have a very short name in your character name, you may want to turn this on.",

	-- Coorbin20211222
	-- CharCount settings strings
	PCHAT_CHARCOUNTH = "Chat Window Header",
	PCHAT_CHARCOUNT_ENABLE_CHECKBOX_NAME = "Show Character Count",
	PCHAT_CHARCOUNT_ENABLE_CHECKBOX_TOOLTIP = "Displays the current number of characters typed into the chat text box out of the max limit of 350. It will appear at the top center position of the chat window.",
	PCHAT_CHARCOUNT_ZONE_POST_TRACKER_NAME = "Show Zone Post Tracker",
	PCHAT_CHARCOUNT_ZONE_POST_TRACKER_TOOLTIP = "Displays the timestamp of when you've last posted in zone chat in the current zone. The time resets when you change zone. Useful for posting announcements to zone chat. It will appear at the top center position of the chat window."
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end