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


	PCHAT_OPTIONSH = "Messages Settings",

	PCHAT_GUILDNUMBERS = "Guild numbers",
	PCHAT_GUILDNUMBERSTT = "Shows the guild number next to the guild tag",

	PCHAT_ALLGUILDSSAMECOLOUR = "Use same color for all guilds",
	PCHAT_ALLGUILDSSAMECOLOURTT = "Makes all guild chats use the same color as /guild1",

	PCHAT_ALLZONESSAMECOLOUR = "Use same color for all zone chats",
	PCHAT_ALLZONESSAMECOLOURTT = "Makes all zone chats use the same color as /zone",

	PCHAT_ALLNPCSAMECOLOUR = "Use same color for all NPC lines",
	PCHAT_ALLNPCSAMECOLOURTT = "Makes all NPC lines use the same color as NPC say",

	PCHAT_DELZONETAGS = "Remove zone tags",
	PCHAT_DELZONETAGSTT = "Remove tags such as says, yells at the beginning of the message",

	PCHAT_ZONETAGSAY = "says",
	PCHAT_ZONETAGYELL = "yells",
	PCHAT_ZONETAGPARTY = "Group",
	PCHAT_ZONETAGZONE = "zone",

	PCHAT_CARRIAGERETURN = "Newline between name and message",
	PCHAT_CARRIAGERETURNTT = "Player names and chat texts are separated by a newline.",

	PCHAT_USEESOCOLORS = "Use ESO colors",
	PCHAT_USEESOCOLORSTT = "Use colors set in social settings instead pChat ones",

	PCHAT_DIFFFORESOCOLORS = "Difference between ESO colors",
	PCHAT_DIFFFORESOCOLORSTT = "If using ESO colors and Use two colors option, you can adjust brightness difference between player name and message displayed",

	PCHAT_REMOVECOLORSFROMMESSAGES = "Remove colors from messages",
	PCHAT_REMOVECOLORSFROMMESSAGESTT = "Stops people using things like rainbow colored text",

	PCHAT_PREVENTCHATTEXTFADING = "Prevent chat text fading",
	PCHAT_PREVENTCHATTEXTFADINGTT = "Prevents the chat text from fading (you can prevent the BG from fading in the Social options",

	PCHAT_AUGMENTHISTORYBUFFER = "Augment # of lines displayed in chat",
	PCHAT_AUGMENTHISTORYBUFFERTT = "Per default, only the last 200 lines are displayed in chat. This feature raise this value up to 1000 lines",

	PCHAT_USEONECOLORFORLINES = "Use one color for lines",
	PCHAT_USEONECOLORFORLINESTT = "Instead of having two colors per channel, only use 1st color",

	PCHAT_GUILDTAGSNEXTTOENTRYBOX = "Guild tags next to entry box",
	PCHAT_GUILDTAGSNEXTTOENTRYBOXTT = "Show the guild tag instead of the guild name next to where you type",

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

	PCHAT_ADDCHANNELANDTARGETTOHISTORY = "Switch channel when using history",
	PCHAT_ADDCHANNELANDTARGETTOHISTORYTT = "Switch the channel when using arrow keys to match the channel previously used.",

	PCHAT_URLHANDLING = "Detect and make URLs linkable",
	PCHAT_URLHANDLINGTT = "If a URL starting with http(s):// is linked in chat pChat will detect it and you'll be able to click on it to directly go on the concerned link with your system browser",

	PCHAT_ENABLECOPY = "Enable copy",
	PCHAT_ENABLECOPYTT = "Enable copy with a right click on text - Also enable the channel switch with a left click. Disable this option if you got problems to display links in chat",

	-- Group Settings

	PCHAT_GROUPH = "Party channel tweaks",

	PCHAT_ENABLEPARTYSWITCH = "Enable Party Switch",
	PCHAT_ENABLEPARTYSWITCHTT = "Enabling Party switch will switch your current channel to party when joining a party and  switch back to your default channel when leaving a party",

	PCHAT_GROUPLEADER = "Special color for party leader",
	PCHAT_GROUPLEADERTT = "Enabling this feature will let you set a special color for party leader messages",

	PCHAT_GROUPLEADERCOLOR = "Party leader color",
	PCHAT_GROUPLEADERCOLORTT = "Color of party leader messages. 2nd color is only to set if \"Use ESO colors\" is set to Off",

	PCHAT_GROUPLEADERCOLOR1 = "Color of messages for party leader",
	PCHAT_GROUPLEADERCOLOR1TT = "Color of message for party leader. If \"Use ESO colors\" is set to Off, this option will be disabled. The color of the party leader will be the one set above and the party leader messages will be this one",

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

	PCHAT_WINDOWDARKNESS = "Chat window transparency",
	PCHAT_WINDOWDARKNESSTT = "Increase the darkening of the chat window",

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

	PCHAT_MEMBERS = "<<1>> - Players",
	PCHAT_CHAT = "<<1>> - Messages",

	PCHAT_OFFICERSTT = " Officers",

	-- Channel colors settings

	PCHAT_CHATCOLORSH = "Chat Colors",

	PCHAT_SAY = "Say - Player",
	PCHAT_SAYTT = "Set player color for say channel",

	PCHAT_SAYCHAT = "Say - Chat",
	PCHAT_SAYCHATTT = "Set chat color for say channel",

	PCHAT_ZONE = "Zone - Player",
	PCHAT_ZONETT = "Set player color for zone channel",

	PCHAT_ZONECHAT = "Zone - Chat",
	PCHAT_ZONECHATTT = "Set chat color for zone channel",

	PCHAT_YELL = "Yell - Player",
	PCHAT_YELLTT = "Set player color for yell channel",

	PCHAT_YELLCHAT = "Yell - Chat",
	PCHAT_YELLCHATTT = "Set chat color for yell channel",

	PCHAT_INCOMINGWHISPERS = "Incoming whispers - Player",
	PCHAT_INCOMINGWHISPERSTT = "Set player color for incoming whispers",

	PCHAT_INCOMINGWHISPERSCHAT = "Incoming whispers - Chat",
	PCHAT_INCOMINGWHISPERSCHATTT = "Set chat color for incoming whispers",

	PCHAT_OUTGOINGWHISPERS = "Outgoing whispers - Player",
	PCHAT_OUTGOINGWHISPERSTT = "Set player color for outgoing whispers",

	PCHAT_OUTGOINGWHISPERSCHAT = "Outgoing whispers - Chat",
	PCHAT_OUTGOINGWHISPERSCHATTT = "Set chat color for outgoing whispers",

	PCHAT_GROUP = "Group - Player",
	PCHAT_GROUPTT = "Set player color for group chat",

	PCHAT_GROUPCHAT = "Group - Chat",
	PCHAT_GROUPCHATTT = "Set chat color for group chat",

	-- Other colors

	PCHAT_OTHERCOLORSH = "Other Colors",

	PCHAT_EMOTES = "Emotes - Player",
	PCHAT_EMOTESTT = "Set player color for emotes",

	PCHAT_EMOTESCHAT = "Emotes - Chat",
	PCHAT_EMOTESCHATTT = "Set chat color for emotes",

	PCHAT_ENZONE = "EN Zone - Player",
	PCHAT_ENZONETT = "Set player color for English zone channel",

	PCHAT_ENZONECHAT = "EN Zone - Chat",
	PCHAT_ENZONECHATTT = "Set chat color for English zone channel",

	PCHAT_FRZONE = "FR Zone - Player",
	PCHAT_FRZONETT = "Set player color for French zone channel",

	PCHAT_FRZONECHAT = "FR Zone - Chat",
	PCHAT_FRZONECHATTT = "Set chat color for French zone channel",

	PCHAT_DEZONE = "DE Zone - Player",
	PCHAT_DEZONETT = "Set player color for German zone channel",

	PCHAT_DEZONECHAT = "DE Zone - Chat",
	PCHAT_DEZONECHATTT = "Set chat color for German zone channel",

	PCHAT_JPZONE = "JP Zone - Player",
	PCHAT_JPZONETT = "Set player color for Japanese zone channel",

	PCHAT_JPZONECHAT = "JP Zone - Chat",
	PCHAT_JPZONECHATTT = "Set chat color for Japanese zone channel",

	PCHAT_NPCSAY = "NPC Say - NPC name",
	PCHAT_NPCSAYTT = "Set NPC name color for NPC say",

	PCHAT_NPCSAYCHAT = "NPC Say - Chat",
	PCHAT_NPCSAYCHATTT = "Set NPC chat color for NPC say",

	PCHAT_NPCYELL = "NPC Yell - NPC name",
	PCHAT_NPCYELLTT = "Set NPC name color for NPC yell",

	PCHAT_NPCYELLCHAT = "NPC Yell - Chat",
	PCHAT_NPCYELLCHATTT = "Set NPC chat color for NPC yell",

	PCHAT_NPCWHISPER = "NPC Whisper - NPC name",
	PCHAT_NPCWHISPERTT = "Set NPC name color for NPC whisper",

	PCHAT_NPCWHISPERCHAT = "NPC Whisper - Chat",
	PCHAT_NPCWHISPERCHATTT = "Set NPC chat color for NPC whisper",

	PCHAT_NPCEMOTES = "NPC Emotes - NPC name",
	PCHAT_NPCEMOTESTT = "Set NPC name color for NPC emotes",

	PCHAT_NPCEMOTESCHAT = "NPC Emotes - Chat",
	PCHAT_NPCEMOTESCHATTT = "Set NPC chat color for NPC emotes",

	-- Debug settings

	PCHAT_DEBUGH = "Debug",

	PCHAT_DEBUG = "Debug",
	PCHAT_DEBUGTT = "Debug",

	-- Various strings not in panel settings

	PCHAT_UNDOCKTEXTENTRY = "Undock Text Entry",
	PCHAT_REDOCKTEXTENTRY = "Redock Text Entry",

	PCHAT_COPYXMLTITLE = "Copy text with Ctrl+C",
	PCHAT_COPYXMLLABEL = "Copy text with Ctrl+C",
	PCHAT_COPYXMLTOOLONG = "Text is too long and is splitted",
	PCHAT_COPYXMLNEXT = "Next",

	PCHAT_COPYMESSAGECT = "Copy message",
	PCHAT_COPYLINECT = "Copy line",
	PCHAT_COPYDISCUSSIONCT = "Copy channel talk",
	PCHAT_ALLCT = "Copy whole chat",

	PCHAT_SWITCHTONEXTTABBINDING = "Switch to next tab",
	PCHAT_TOGGLECHATBINDING = "Toggle Chat Window",
	PCHAT_WHISPMYTARGETBINDING = "Whisper my target",

	PCHAT_SAVMSGERRALREADYEXISTS = "Cannot save your message, this one already exists",
	PCHAT_PCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Example : ts3",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Write here the text which will be sent when you'll be using the auto message function",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Newlines will be automatically deleted",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "This message will be sent when you'll validate the message \"!nameOfMessage\". (ex: |cFFFFFF!ts3|r)",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "To send a message in a specified channel, add its switch at the begenning of the message (ex: |cFFFFFF/g1|r)",
	PCHAT_PCHAT_AUTOMSG_NAME_HEADER = "Abbreviation of your message",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_HEADER = "Substitution message",
	PCHAT_PCHAT_AUTOMSG_ADD_TITLE_HEADER = "New automated message",
	PCHAT_PCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modify automated message",
	PCHAT_PCHAT_AUTOMSG_ADD_AUTO_MSG = "Add",
	PCHAT_PCHAT_AUTOMSG_EDIT_AUTO_MSG = "Edit",
	PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG = "Automated messages",
	PCHAT_PCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Remove",

	PCHAT_CLEARBUFFER = "Clear chat",


	--Added by Baertram
	PCHAT_LIB_MISSING       = "[pChat] The following library is missing and needs to be installed & enabled: \'%s\'",
	PCHAT_LUAERROR = "[pChat] has triggered 10 packed lines with text=%s -- pChat - Message truncated",

	PCHAT_RESTORED_PREFIX = "[H]",
	PCHAT_RESTOREPREFIX = "Add prefix to restored messages",
	PCHAT_RESTOREPREFIXTT = "Add a prefix \'[H]\' to restored messages in order to easily see they were restored.\nThis will affect the current chat only after a reloadUI!\nThe color of the prefix will be shown with the standard ESO chat channel colors."
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end