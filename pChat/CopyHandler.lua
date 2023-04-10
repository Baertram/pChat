local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

local ChatSys = CONSTANTS.CHAT_SYSTEM

-- pChat Chat Copy Options OBJKCT
pChat.ChatCopyOptions = nil
local mapChatChannelToPChatChannel = pChat.mapChatChannelToPChatChannel

local chatChannelLangToLangStr = CONSTANTS.chatChannelLangToLangStr

-------------------------------------------------------------
-- Helper functions --
-------------------------------------------------------------
-- Split text, courtesy of LibOrangUtils, modified to handle multibyte characters
local function str_lensplit(text, maxChars)

    local ret                   = {}
    local text_len              = string.len(text)
    local UTFAditionalBytes = 0
    local fromWithUTFShift  = 0
    local doCut                 = true

    if(text_len <= maxChars) then
        ret[#ret+1] = text
    else

        local splittedStart = 0
        local splittedEnd = splittedStart + maxChars - 1

        local splittedString
        while doCut do

            if UTFAditionalBytes > 0 then
                fromWithUTFShift = UTFAditionalBytes
            else
                fromWithUTFShift = 0
            end

            UTFAditionalBytes = 0

            splittedEnd = splittedStart + maxChars - 1

            if(splittedEnd >= text_len) then
                splittedEnd = text_len
                doCut = false
            elseif (string.byte(text, splittedEnd, splittedEnd)) > 128 then
                UTFAditionalBytes = 1

                local lastByte = splittedString and string.byte(splittedString, -1) or 0
                local beforeLastByte = splittedString and string.byte(splittedString, -2, -2) or 0

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

-- Set copied text into text entry, if possible
local function CopyToTextEntry(message)

    -- Max of inputbox is 351 chars
    if string.len(message) < 351 then
        if ChatSys.textEntry:GetText() == "" then
            ChatSys.textEntry:Open(message)
            ZO_ChatWindowTextEntryEditBox:SelectAll()
        end
    end

end

-- Copy message (only message)
local function CopyMessage(numLine)
    local db = pChat.db
    if not numLine or not db.LineStrings or not db.LineStrings[numLine] then return end
    -- Args are passed as string trought LinkHandlerSystem
    CopyToTextEntry(db.LineStrings[numLine].rawMessage)
end

--Copy line (including timestamp, from, channel, message, etc)
local function CopyLine(numLine)
    local db = pChat.db
    if not numLine or not db.LineStrings or not db.LineStrings[numLine] then return end
    -- Args are passed as string trought LinkHandlerSystem
    CopyToTextEntry(db.LineStrings[numLine].rawLine)
end

-- Copy discussion
-- It will copy all text mark with the same chanCode
-- Todo : Whisps by person
local function CopyDiscussion(chanNumber, numLine)
    local db = pChat.db
    if not numLine or not chanNumber or not db.LineStrings or not db.LineStrings[numLine] then return end

    -- Args are passed as string trought LinkHandlerSystem
    local numChanCode = tonumber(chanNumber)
    -- Whispers sent and received together
    if numChanCode == CHAT_CHANNEL_WHISPER_SENT then
        numChanCode = CHAT_CHANNEL_WHISPER
    elseif numChanCode == CONSTANTS.PCHAT_URL_CHAN then
        numChanCode = db.LineStrings[numLine].channel
    --CHAT_CHANNEL_SAY = 0, does not work properly in tables so pChat internally uses an alternative value 98 for it!
    else
        numChanCode = mapChatChannelToPChatChannel(numChanCode)
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
--d(">stringToCopy: " ..tostring(stringToCopy))
    pChat_ShowCopyDialog(stringToCopy, numChanCode)
end

--Check if a chat category (of a chat channel) is enabled in any chat tab's settings
local chatCatgoriesEnabledTable = {}
local function isChatCategoryEnabledInAnyChatTab(chatChannel)
    local isChatCategoryEnabledAtAnyChatTabCheck = false
    if chatChannel and chatChannel ~= "" then
        local actualTab = 1
        local numTabs = #ChatSys.primaryContainer.windows
        local chatCategory = GetChannelCategoryFromChannel(chatChannel)
        if chatCategory then
            if chatCatgoriesEnabledTable[chatCategory] == true then return true end
            while actualTab <= numTabs do
                if IsChatContainerTabCategoryEnabled(1, actualTab, chatCategory) then
                    isChatCategoryEnabledAtAnyChatTabCheck = true
                    chatCatgoriesEnabledTable[chatCategory] = true
                end
                actualTab = actualTab + 1
            end
        end
    end
    return isChatCategoryEnabledAtAnyChatTabCheck
end

-- Copy Whole chat (not tab)
-- Filter it by the channelIds from the pchat copy options dialog
--> Special treatment for CHAT_CHANNEL_SAY (0) -> Is stored internally with CONSTANTS.PCHAT_CHANNEL_SAY (98), so needs
--> to be read from there in the lines!
local function CopyWholeChat(updateShownDialog)
--d("[pChat]CopyWholeChat-updateShownDialog: " ..tostring(updateShownDialog))
    updateShownDialog = updateShownDialog or false
    local db = pChat.db
    chatCatgoriesEnabledTable = {}
    local filteredStringCopy = ""
    local pChatData = pChat.pChatData
    local chatChannelsToFilter = pChatData.chatChannelsToFilter
    for k, data in ipairs(db.LineStrings) do
        local doAddLine = (updateShownDialog == true or isChatCategoryEnabledInAnyChatTab(data.channel)) or false
        local lineData = db.LineStrings[k]
        if updateShownDialog == true and chatChannelsToFilter then
            doAddLine = false
            local lineDataChannel = lineData.channel
--d(">lineDataChannel: " ..tostring(lineDataChannel))
            for chatChannelToFilter, isActive in pairs(chatChannelsToFilter) do
                if chatChannelToFilter == lineDataChannel and isActive == true then
                    doAddLine = true
                    break
                end
            end
        end
        if doAddLine == true then
            local textToCopy = lineData.rawLine
            if textToCopy ~= nil then
                if filteredStringCopy == "" then
                    filteredStringCopy = tostring(textToCopy)
                else
                    filteredStringCopy = filteredStringCopy .. "\r\n" .. tostring(textToCopy)
                end
            end
        end
    end
    if filteredStringCopy then
        if updateShownDialog == true then
            return filteredStringCopy
        else
            if filteredStringCopy ~= "" then
                pChat_ShowCopyDialog(filteredStringCopy)
            end
        end
    end
end

--------------------------------------------------
-- pChat ChatCopy Options CLASS
--------------------------------------------------
local FILTERS_PER_ROW = 2
local GUILDS_PER_ROW = 2

--defines channels to be combined under one button
local COMBINED_CHANNELS = {
    [CHAT_CATEGORY_WHISPER_INCOMING] = {parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, name = SI_CHAT_CHANNEL_NAME_WHISPER},
    [CHAT_CATEGORY_WHISPER_OUTGOING] = {parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, name = SI_CHAT_CHANNEL_NAME_WHISPER},

    [CHAT_CATEGORY_MONSTER_SAY] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
    [CHAT_CATEGORY_MONSTER_YELL] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
    [CHAT_CATEGORY_MONSTER_WHISPER] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
    [CHAT_CATEGORY_MONSTER_EMOTE] = {parentChannel = CHAT_CATEGORY_MONSTER_SAY, name = SI_CHAT_CHANNEL_NAME_NPC},
}

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
    [CHAT_CATEGORY_ZONE_RUSSIAN] = 130,
    [CHAT_CATEGORY_ZONE_SPANISH] = 140,
    [CHAT_CATEGORY_ZONE_CHINESE_S] = 150,
}


local chatChannelsToMap = {
    CHAT_CHANNEL_SAY,
    CHAT_CHANNEL_YELL,
    CHAT_CHANNEL_ZONE,
    CHAT_CHANNEL_ZONE_LANGUAGE_1,
    CHAT_CHANNEL_ZONE_LANGUAGE_2,
    CHAT_CHANNEL_ZONE_LANGUAGE_3,
    CHAT_CHANNEL_ZONE_LANGUAGE_4,
    CHAT_CHANNEL_ZONE_LANGUAGE_5,
    CHAT_CHANNEL_ZONE_LANGUAGE_6,
    CHAT_CHANNEL_ZONE_LANGUAGE_7,
    CHAT_CHANNEL_WHISPER,
    CHAT_CHANNEL_WHISPER_SENT,
    CHAT_CHANNEL_PARTY,
    CHAT_CHANNEL_EMOTE,
    CHAT_CHANNEL_SYSTEM,
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
    CHAT_CHANNEL_MONSTER_SAY,
    CHAT_CHANNEL_MONSTER_YELL,
    CHAT_CHANNEL_MONSTER_WHISPER,
    CHAT_CHANNEL_MONSTER_EMOTE,
}

local ChatCategory2ChatChannel = {}
for _, chatChannelId in pairs(chatChannelsToMap) do
    local chatCat = GetChannelCategoryFromChannel(chatChannelId)
    if chatCat then
        ChatCategory2ChatChannel[chatCat] = chatChannelId
    end
end
pChat.ChatCategory2ChatChannel = ChatCategory2ChatChannel

--[[ ChatCopyOptions Class ]]--
local ChatCopyOptions = ZO_Object:Subclass()

function ChatCopyOptions:New(...)
    local options = ZO_Object.New(self)
    return options
end

local function SetupChatCopyOptionsDialog(control)
    ZO_Dialogs_RegisterCustomDialog("PCHAT_CHAT_COPY_DIALOG",
            {
                customControl = control,
                title =
                {
                    text = PCHAT_COPYXMLTITLE,
                },
                setup = function(self)
                    pChat.ChatCopyOptions:Initialize(control)
                end,
                buttons =
                {
                    --[[
                    --Using the button here will always close the dialog :-(
                    {

                        control =   GetControl(control, "ApplyFilter"),
                        text =      PCHAT_COPYXMLAPPLY,
                        keybind =   "DIALOG_PRIMARY",
                        callback =  function(dialog)
                                        pChat_ChatCopyOptions_OnCommitClicked(control)
                                    end,
                    },
                    ]]
                    {
                        control =   GetControl(control, "Close"),
                        text =      SI_DIALOG_EXIT,
                        keybind =   "DIALOG_NEGATIVE",
                    },
                },
                --[[
                finishedCallback = function()
                end,
                ]]
            })
end

function ChatCopyOptions:UpdateEditAndButtons()
    local control = self.control
    local pChatData = pChat.pChatData
    local message = self.message
--d("pChat ChatCopyOptions:UpdateEditAndButtons, message: " ..tostring(message))
    if not message then return end

    -- editbox is 20000 chars max
    local maxChars      = 20000
    local label     = GetControl(control, "Label")
    local notePrev  = GetControl(control, "NotePrev")
    local noteNext  = GetControl(control, "NoteNext")
    local noteEdit  = GetControl(control, "NoteEdit")

    if string.len(message) < maxChars then
        label:SetText(GetString(PCHAT_COPYXMLLABEL))
        noteEdit:SetText(message)
        noteNext:SetHidden(true)
        notePrev:SetHidden(true)
        --DO not use or the scenes with HUDUI and hud will stay switched after closing the dialog
        --control:SetHidden(false)

        noteEdit:SetEditEnabled(false)
        noteEdit:SelectAll()


    else
        label:SetText(GetString(PCHAT_COPYXMLTOOLONG))
        pChatData.messageTableId = 1
        pChatData.messageTable = str_lensplit(message, maxChars)
        notePrev:SetText(GetString(PCHAT_COPYXMLPREV))
        noteNext:SetText(GetString(PCHAT_COPYXMLNEXT) .. " ( " .. pChatData.messageTableId .. " / " .. #pChatData.messageTable .. " )")
        noteEdit:SetText(pChatData.messageTable[pChatData.messageTableId])
        noteEdit:SetEditEnabled(false)
        noteEdit:SelectAll()

        --DO not use or the scenes with HUDUI and hud will stay switched after closing the dialog
        --control:SetHidden(false)

        noteNext:SetHidden(false)
        notePrev:SetHidden(true)
        noteEdit:TakeFocus()
    end
end

function ChatCopyOptions:Initialize(control)
    if(not self.initialized) then
        self.control = control
        control.owner = self
        self.filterSection = control:GetNamedChild("FilterSection")
        self.guildSection = control:GetNamedChild("GuildSection")

        local function Reset(p_control)
            p_control:SetHidden(true)
        end

        local function FilterFactory(pool)
            return ZO_ObjectPool_CreateControl("pChat_ChatCopyOptionsFilterEntry", pool, self.filterSection)
        end

        local function GuildFactory(pool)
            return ZO_ObjectPool_CreateControl("pChat_ChatCopyOptionsGuildFilters", pool, self.guildSection)
        end

        self.filterPool = ZO_ObjectPool:New(FilterFactory, Reset)
        self.guildPool = ZO_ObjectPool:New(GuildFactory, Reset)

        self.filterButtons = {}
        self.guildNameLabels = {}
        self:InitializeFilterButtons(control)
        self:InitializeGuildFilters(control)
        self.filteredChannels = {}
        self.initialized = true
    end

    --[Always run this code as dialog's setup function is called]

    --Get the message
    local message = self.message
    if not message or message == "" then return end
    --Get the selected chatChannel (via ShowDiscussion)
    local chatChannel = self.chatChannel
    --ShowDiscussion (a specific chat channel only) was called?
    local isShowDiscussion = chatChannel ~= nil
--d("[pChat]ChatCopyOptions:Initialize - chatChannel: " ..tostring(chatChannel))
    --Uncheck all checkboxes and enable them again
    self:ResetFilterCheckBoxes()

    --Update the chat tab names and indices
    pChat.getTabNames()
    --Check each chat tab in the chat container and update the checkboxes of the filters:
    --Mark those where any chat channel matching to the enabled chat container chat channels applies
    if pChat.tabIndices and #pChat.tabIndices > 0 then
        local chatContainer = ChatSys.primaryContainer
        if chatContainer then
            if isShowDiscussion == true then
                local pChatData = pChat.pChatData
                local activeTab = pChatData.activeTab
                self:SetCurrentChannelSelections(chatContainer, activeTab, chatChannel, isShowDiscussion)
            else
                for chatTabIndex, _ in ipairs(pChat.tabIndices) do
                    self:SetCurrentChannelSelections(chatContainer, chatTabIndex, chatChannel, isShowDiscussion)
                end
            end
        end
        --Update the button checked state and enabled state to true for the filtered ones.
        --All non-filtered were disabled via self:ResetFilterCheckBoxes()
        for button, isFilterEnabled in pairs(self.filteredChannels) do
            if isFilterEnabled == true then
                --Update their checked state
                button:SetEnabled(isFilterEnabled)
                button:SetMouseEnabled(isFilterEnabled)
                local label = GetControl(button, "Label")
                if label then
                    label:SetMouseEnabled(isFilterEnabled)
                end
                ZO_CheckButton_SetCheckState(button, isFilterEnabled)
            end
        end
    end
    --Update the guild names
    self:UpdateGuildNames()

    --Do not allow more filters if we only show one chatChannel
    local applyFilter = GetControl(control, "ApplyFilter")
    applyFilter:SetText(GetString(PCHAT_COPYXMLAPPLY))
    applyFilter:SetEnabled(not isShowDiscussion)
    applyFilter:SetMouseEnabled(not isShowDiscussion)
    applyFilter:SetHidden(isShowDiscussion)

    --Update the edit box and the buttons + labels
    self:UpdateEditAndButtons()
end

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

do
    local FILTER_PAD_X = 90
    local FILTER_PAD_Y = 0
    local FILTER_WIDTH = 150
    local FILTER_HEIGHT = 27
    local INITIAL_XOFFS = 0
    local INITIAL_YOFFS = 0

    function ChatCopyOptions:InitializeFilterButtons(dialogControl)
        --generate a table of entry data from the chat category header information
        --The checkbox's channel subtable will be the chatCategory! So we need to map it to the chatChannels later on
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

        local sortedEntries = {}
        for _, entry in pairs(entryData) do
            sortedEntries[#sortedEntries + 1] = entry
        end

        table.sort(sortedEntries, FilterComparator)

        for _, entry in ipairs(sortedEntries) do
            local filter, key = self.filterPool:AcquireObject()
            filter.key = key

            local button = filter:GetNamedChild("Check")
            ZO_CheckButton_SetLabelText(button, entry.name)
            button.channels = entry.channels
            table.insert(self.filterButtons, button)

            ZO_Anchor_BoxLayout(filterAnchor, filter, count, FILTERS_PER_ROW, FILTER_PAD_X, FILTER_PAD_Y, FILTER_WIDTH, FILTER_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
            count = count + 1
        end
    end

    local GUILD_PAD_X = 90
    local GUILD_PAD_Y = 0
    local GUILD_WIDTH = 150
    local GUILD_HEIGHT = 70

    function ChatCopyOptions:InitializeGuildFilters(dialogControl)
        local guildAnchor = ZO_Anchor:New(TOPLEFT, self.guildSection, TOPLEFT, 0, 0)
        local count = 0

        -- setup and anchor the guild sections
        local maxGuild = CHAT_CATEGORY_HEADER_GUILDS + MAX_GUILDS - 1
        for k = CHAT_CATEGORY_HEADER_GUILDS, maxGuild do
            local guild, key = self.guildPool:AcquireObject()
            guild.key = key

            --local guildFilter = guild:GetNamedChild("Guild")
            --local guildButton = guild:GetNamedChild("Check")
            local guildButton = guild:GetNamedChild("Guild")
            ZO_CheckButton_SetLabelText(guildButton, GetString("SI_CHATCHANNELCATEGORIES", k))
            guildButton.channels = {k}
            table.insert(self.filterButtons, guildButton)

            --local officerFilter = guild:GetNamedChild("Officer")
            --local officerButton = officerFilter:GetNamedChild("Check")
            local officerButton = guild:GetNamedChild("Officer")
            local officerChannel = k + MAX_GUILDS
            ZO_CheckButton_SetLabelText(officerButton, GetString("SI_CHATCHANNELCATEGORIES", officerChannel))
            officerButton.channels = {officerChannel}
            table.insert(self.filterButtons, officerButton)

            local nameLabel = guild:GetNamedChild("GuildName")
            table.insert(self.guildNameLabels, nameLabel)

            ZO_Anchor_BoxLayout(guildAnchor, guild, count, GUILDS_PER_ROW, GUILD_PAD_X, GUILD_PAD_Y, GUILD_WIDTH, GUILD_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
            count = count + 1
        end
    end
end

function ChatCopyOptions:UpdateGuildNames()
    for i,label in ipairs(self.guildNameLabels) do
        local guildID = GetGuildId(i)
        local guildName = GetGuildName(guildID)
        local alliance = GetGuildAlliance(guildID)

        if(guildName ~= "") then
            local r,g,b = GetAllianceColor(alliance):UnpackRGB()
            label:SetText(guildName)
            label:SetColor(r, g, b, 1)
        else
            label:SetText(zo_strformat(SI_EMPTY_GUILD_CHANNEL_NAME, i))
        end
    end
end

function ChatCopyOptions:ResetFilterCheckBoxes()
--d("[pChat]ResetFilterCheckBoxes")
    if not self.filterButtons then return end
    for _, button in ipairs(self.filterButtons) do
        ZO_CheckButton_SetCheckState(button, false)
        button:SetEnabled(false)
        button:SetMouseEnabled(false)
        button:SetHidden(false)
        local label = GetControl(button, "Label")
        if label then
            label:SetMouseEnabled(false)
        end
    end
    self.filteredChannels = {}
end

function ChatCopyOptions:SetCurrentChannelSelections(container, chatTabIndex, chatChannel, isShowDiscussion)
    if not self.filterButtons then return end
    isShowDiscussion = isShowDiscussion or false
    -- Iterate each button's channel list and check just the first entry in each as they are all toggled together
    -- e.g. NPC got more than 1 chatChannel below the NPC checkBox
    --Attention: button.channels are the chatCategories not the chatChannels!
    --> As multiple chat tabs are checked: Keep the already checked checkboxes enabled!
    -- If a chatChannel is given as 3rd parameter, only use this one but check all channels assigned to the buttons instead of only the first
--d("pChat SetCurrentChannelSelections-chatTabIndex: " ..tostring(chatTabIndex) ..", chatChannel: " ..tostring(chatChannel) .. ", isShowDiscussion: " ..tostring(isShowDiscussion))
    for _, button in ipairs(self.filterButtons) do
--d(">button: " ..tostring(button:GetName()))
        if not ZO_CheckButton_IsChecked(button) then
            if chatChannel == nil then
                local chatChannelIsEnabeldAtChatTab = IsChatContainerTabCategoryEnabled(container.id, chatTabIndex, button.channels[1]) or false
--d(">chatTabIndex: " ..tostring(chatTabIndex) .. ", chatChannel1AtTab: " ..tostring(button.channels[1]) .."->" ..tostring(chatChannelIsEnabeldAtChatTab))
                self.filteredChannels[button] = self.filteredChannels[button] or chatChannelIsEnabeldAtChatTab
            else
                local chatCategoryToCheck = GetChannelCategoryFromChannel(chatChannel)
                if not chatCategoryToCheck then return end
                for _, chatCategoryAtCheckbox in ipairs(button.channels) do
                    local chatChannelCategoryIsEnabledAtChatTab = false
                    if chatCategoryToCheck == chatCategoryAtCheckbox then
                        chatChannelCategoryIsEnabledAtChatTab = IsChatContainerTabCategoryEnabled(container.id, chatTabIndex, chatCategoryToCheck) or false
--d(">category equals cboxCategory ->" ..tostring(chatChannelCategoryIsEnabledAtChatTab))
                    end
--d(">category: toCompare/WithCheckBox: " ..tostring(chatCategoryToCheck) .. "/" ..tostring(chatCategoryAtCheckbox) .."->" ..tostring(chatChannelCategoryIsEnabledAtChatTab))
                    self.filteredChannels[button] = self.filteredChannels[button] or chatChannelCategoryIsEnabledAtChatTab
                end
            end
        end
    end
end

function ChatCopyOptions:ApplyFilters()
--d("[pChat]CopyDialog-ApplyFilters")
    pChat.pChatData.chatChannelsToFilter = nil
    --Filter the entries in the list now according to selected checkboxes!
    --Get the selected checkboxes
    if not self.filterButtons then return end
    local chatChannelsToFilter = {}
    local chatChannelsToFilterAdded = false
    local oneCheckBoxWasChecked = false
    for _, button in ipairs(self.filterButtons) do
        if ZO_CheckButton_IsChecked(button) then
            oneCheckBoxWasChecked = true
            --Get their chatCategories
            for _, chatCat in pairs(button.channels) do
                --Get the relating chatChannels of the categories
                local chatChannel = ChatCategory2ChatChannel[chatCat]
                if chatChannel then
                    --pChat internally uses CONSTANTS.PCHAT_CHANNEL_SAY (98) instead of CHAT_CHANNEL_SAY (0)
                    chatChannel = mapChatChannelToPChatChannel(chatChannel)

                    chatChannelsToFilter[chatChannel] = true
                    chatChannelsToFilterAdded = true
                end
            end
        end
    end
    if chatChannelsToFilter and (chatChannelsToFilterAdded == true or oneCheckBoxWasChecked == false) then
        pChat.pChatData.chatChannelsToFilter = chatChannelsToFilter
        --Filter the text with the given chat channels
        self.message = CopyWholeChat(true)
        --Reset the buttons "prev"/"next" etc.
        self:UpdateEditAndButtons()
    end
end

function ChatCopyOptions:ChangeFiltersState(doEnable, filterType)
    if not self.filterButtons then return end

    if filterType == nil then
        for _, button in ipairs(self.filterButtons) do
            if doEnable == true then
                if ZO_CheckButton_IsChecked(button) == false then
                    ZO_CheckButton_SetChecked(button)
                end
            else
                if ZO_CheckButton_IsChecked(button) == true then
                    ZO_CheckButton_SetUnchecked(button)
                end
            end

        end
    else
        if filterType == "filter" then
        for _, button in ipairs(self.filterButtons) do
            if button:GetParent():GetParent() == pChatCopyOptionsDialogFilterSection then
                if doEnable == true then
                    if ZO_CheckButton_IsChecked(button) == false then
                        ZO_CheckButton_SetChecked(button)
                    end
                else
                    if ZO_CheckButton_IsChecked(button) == true then
                        ZO_CheckButton_SetUnchecked(button)
                    end
                end
            end
        end

        elseif filterType == "guild" then
            for _, button in ipairs(self.filterButtons) do
                if button:GetParent():GetParent() == pChatCopyOptionsDialogGuildSection then
                    if doEnable == true then
                        if ZO_CheckButton_IsChecked(button) == false then
                            ZO_CheckButton_SetChecked(button)
                        end
                    else
                        if ZO_CheckButton_IsChecked(button) == true then
                            ZO_CheckButton_SetUnchecked(button)
                        end
                    end
                end
            end
        end
    end
end

function ChatCopyOptions:Show()
--d("[pChat]ChatCopyOptions:Show()")
    ZO_Dialogs_ShowDialog("PCHAT_CHAT_COPY_DIALOG")
end

function ChatCopyOptions:Hide()
    --Unset the messageText and chatChannel variables in the dialog object
    self.message = nil
    self.chatChannel = nil
end

--[[ XML Handlers ]]--
function pChat_ChatCopyOptions_OnInitialized(dialogControl)
    SetupChatCopyOptionsDialog(dialogControl)
	pChat.ChatCopyOptions = ChatCopyOptions:New(dialogControl)
end

function pChat_ChatCopyOptions_OnCommitClicked()
	pChat.ChatCopyOptions:ApplyFilters()
end

function pChat_ChatCopyOptions_OnHide()
--d("pChat_ChatCopyOptions_OnHide")
    ZO_Dialogs_ReleaseDialog("PCHAT_CHAT_COPY_DIALOG")
    pChat.ChatCopyOptions:Hide()
end

function pChat_ChatCopyOptions_EnableAllFilters(filterType)
    --d("[pChat]Enable all filters")
    pChat.ChatCopyOptions:ChangeFiltersState(true, filterType)
end

function pChat_ChatCopyOptions_DisableAllFilters(filterType)
--d("[pChat]Disable all filters")
    pChat.ChatCopyOptions:ChangeFiltersState(false, filterType)
end


--[[
function pChat_ChatCopyOptionsOnCheckboxToggled(buttonControl, checked)
    if not buttonControl then return end
    d("pChat, changed checkbox: " ..tostring(buttonControl:GetName() .. ", state: " ..tostring(checked)))
    local channels = buttonControl.channels
    d(">ChatChannels related to checkbox: ")
    for i,channel in ipairs(channels) do
        d(">>"..tostring(channel))
    end
end
]]
----------------------------------------------------------------------------------------------

--Keybidning function
function pChat_CopyWholeChat()
    CopyWholeChat(false)
end

-- Create the controls and the dialog
-- & transfer the message to the dialog (for the setup function)
-- then show the dialog
function pChat_ShowCopyDialog(messageText, chatChannel)
    if not messageText or messageText == "" then return end
    local pChatChatCopyOptions = pChat.ChatCopyOptions
    if pChatChatCopyOptions ~= nil and pChatChatCopyOptions.Show then
        pChatChatCopyOptions.message = messageText
        pChatChatCopyOptions.chatChannel = chatChannel
        --Show the dialog now
        pChatChatCopyOptions:Show()
    end
end

local function changeCopyDialogPage(p_control, newIndex)
    local pChatData = pChat.pChatData
    if not p_control then return end
    if not newIndex or newIndex == 0 or newIndex > 1 or newIndex < -1 then return end
    local oldIndex = pChatData.messageTableId
    local numPages = tostring(#pChatData.messageTable)
    pChatData.messageTableId = pChatData.messageTableId + newIndex
    local messageTableId = pChatData.messageTableId
    if pChatData.messageTable[messageTableId] then
        -- Build button
        local notePrev = GetControl(p_control, "NotePrev")
        local noteNext = GetControl(p_control, "NoteNext")
        local noteEdit = GetControl(p_control, "NoteEdit")
        local prevButtonText = tostring(oldIndex) .. " / " .. numPages
        local nextButtonText = tostring(messageTableId) .. " / " .. numPages
        notePrev:SetText(GetString(PCHAT_COPYXMLPREV) .. " ( " ..  prevButtonText .. " )")
        noteNext:SetText(GetString(PCHAT_COPYXMLNEXT) .. " ( " ..  nextButtonText .. " )")
        noteEdit:SetText(pChatData.messageTable[messageTableId])
        noteEdit:SetEditEnabled(false)
        noteEdit:SelectAll()

        -- Don't show prev button if its the first
        if not pChatData.messageTable[messageTableId - 1] then
            notePrev:SetHidden(true)
        else
            notePrev:SetHidden(false)
        end
        -- Don't show next button if its the last
        if not pChatData.messageTable[messageTableId + 1] then
            noteNext:SetHidden(true)
        else
            noteNext:SetHidden(false)
        end
        noteEdit:TakeFocus()
    end
end

-- Called by XML
function pChat_ShowCopyDialogPrev(p_control)
    changeCopyDialogPage(p_control, -1)
end

function pChat_ShowCopyDialogNext(p_control)
    changeCopyDialogPage(p_control, 1)
end

function pChat.InitializeCopyHandler(control)
    local db = pChat.db

    --Initialize the chat copy options dialog
    -->Will be done via the XML's OnInitialized at TLC "pChatCopyOptionsDialog" as the dialog is shown
    --[[
    if pChatCopyOptionsDialog then
        pChat_ChatCopyOptions_OnInitialized(pChatCopyOptionsDialog)
    end
    ]]

    -- Show contextualMenu when clicking on a pChatLink
    local function ShowContextMenuOnHandlers(numLine, chanNumber)
--d("pChat ShowContextMenuOnHandlers, chanNumber: "..tostring(chanNumber))
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

        -- Only executed on LinkType = CONSTANTS.PCHAT_LINK
        if linkType == CONSTANTS.PCHAT_LINK then

            local chanNumber = tonumber(chanCode)
            local numLine = tonumber(lineNumber)
            -- CONSTANTS.PCHAT_LINK also handle a linkable channel feature for linkable channels

            -- Context Menu
            if chanCode and mouseButton == MOUSE_BUTTON_INDEX_LEFT then

                -- Only Linkable channel - TODO use .channelLinkable
                if chanNumber == CHAT_CHANNEL_SAY
                        or chanNumber == CHAT_CHANNEL_YELL
                        or chanNumber == CHAT_CHANNEL_PARTY
                        or chanNumber == CHAT_CHANNEL_ZONE
                        --[[
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_1
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_2
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_3
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_4
                        or chanNumber == CHAT_CHANNEL_ZONE_LANGUAGE_5
                        ]]
                        or chatChannelLangToLangStr[chanNumber] ~= nil
                        or (chanNumber >= CHAT_CHANNEL_GUILD_1 and chanNumber <= CHAT_CHANNEL_GUILD_5)
                        or (chanNumber >= CHAT_CHANNEL_OFFICER_1 and chanNumber <= CHAT_CHANNEL_OFFICER_5)
                then
                    IgnoreMouseDownEditFocusLoss()
                    --ChatSys:StartTextEntry(nil, chanNumber)
                    StartChatInput(nil, chanNumber, nil)
                elseif chanNumber == CHAT_CHANNEL_WHISPER then
                    local target = zo_strformat(SI_UNIT_NAME, db.LineStrings[numLine].rawFrom)
                    IgnoreMouseDownEditFocusLoss()
                    --ChatSys:StartTextEntry(nil, chanNumber, target)
                    StartChatInput(nil, chanNumber, target)
                elseif chanNumber == CONSTANTS.PCHAT_URL_CHAN then
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

    if db.enablecopy then
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, OnLinkClicked)
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)
    end

end
