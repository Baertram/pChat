local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

local tos = tostring
local strfor = string.format
local strsub = string.sub
local strgsub = string.gsub
local strfind = string.find
local strmatch = string.match
local strlen = string.len 
local strbyte = string.byte

local chatChannelLangToLangStr = CONSTANTS.chatChannelLangToLangStr

local isDiceRollSystemMessage = pChat.IsDiceRollSystemMessage

local pChat_CreateTimestamp = pChat.CreateTimestamp
local pChat_getCurrentMillisecondsFormatted = pChat.getCurrentMillisecondsFormatted


function pChat.InitializeMessageFormatters()
    local pChatData = pChat.pChatData
    local db = pChat.db
    local logger = pChat.logger
    local SpamFilter = pChat.SpamFilter

    local cm = pChat.ChatMentions

    local chatStrings = {
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

    -- cTLD + most used (> 0.1%)
    local domains = table.concat({
        ".ac.ad.ae.af.ag.ai.al.am.an.ao.aq.ar.as.at.au.aw.ax.az.ba.bb.bd.be.bf.bg.bh.bi.bj.bl.bm.bn.bo.bq",
        ".br.bs.bt.bv.bw.by.bz.ca.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.cr.cu.cv.cw.cx.cy.cz.de.dj.dk.dm.do.dz",
        ".ec.ee.eg.eh.er.es.et.eu.fi.fj.fk.fm.fo.fr.ga.gb.gd.ge.gf.gg.gh.gi.gl.gm.gn.gp.gq.gr.gs.gt.gu.gw",
        ".gy.hk.hm.hn.hr.ht.hu.id.ie.il.im.in.io.iq.ir.is.it.je.jm.jo.jp.ke.kg.kh.ki.km.kn.kp.kr.kw.ky.kz",
        ".la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly.ma.mc.md.me.mf.mg.mh.mk.ml.mm.mn.mo.mp.mq.mr.ms.mt.mu.mv.mw.mx",
        ".my.mz.na.nc.ne.nf.ng.ni.nl.no.np.nr.nu.nz.om.pa.pe.pf.pg.ph.pk.pl.pm.pn.pr.ps.pt.pw.py.qa.re.ro",
        ".rs.ru.rw.sa.sb.sc.sd.se.sg.sh.si.sj.sk.sl.sm.sn.so.sr.ss.st.su.sv.sx.sy.sz.tc.td.tf.tg.th.tj.tk",
        ".tl.tm.tn.to.tp.tr.tt.tv.tw.tz.ua.ug.uk.um.us.uy.uz.va.vc.ve.vg.vi.vn.vu.wf.ws.ye.yt.za.zm.zw",
        ".biz.com.coop.edu.gov.int.mil.mobi.info.net.org.xyz.top.club.pro.asia",
    }, "")

    -- wxx.yy.zz
    pChatData.tlds = {}
    for tld in domains:gmatch('%w+') do
        pChatData.tlds[tld] = true
    end

    -- protos : only http/https
    pChatData.protocols = {['http://'] = 0, ['https://'] = 0}

    --Detect the QuickChat messages |s<number><number:optional><number:optional><number:optional>|s
    local function detectQuickChat(text, start)
        local startcolQuickChat, _ = strfind(text, "|s%d(.*)|s", start)
        return startcolQuickChat
    end

    -- Add a pChat handler for URL's
    local function AddURLHandling(text)
        --[[
            In Rift Public dungeon -> Oberspäher Justal (quest boss with falcon) raises this error message:
            -> line 71 is for pos, url, prot, subd, tld, colon, port, slash, path in text:gmatch("()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%#=-]*))") do

            user:/AddOns/pChat/MessageFormatters.lua:71: attempt to index a nil value
            |rstack traceback:
            user:/AddOns/pChat/MessageFormatters.lua:71: in function 'AddURLHandling'
            user:/AddOns/pChat/MessageFormatters.lua:862: in function 'FormatMessage'
            |caaaaaa<Locals> chanCode = 8, from = "Oberspäher Justal^M", isCS = F, fromDisplayName = "",
            originalFrom = "Oberspäher Justal^M", originalText = "He! Gebt mir meinen Falken zur...", DDSBeforeAll = "",
            TextBeforeAll = "", DDSBeforeSender = "", TextBeforeSender = "", TextAfterSender = "", DDSAfterSender = "",
            DDSBeforeText = "", TextBeforeText = "", TextAfterText = "", DDSAfterText = "", notHandled = F, isSpam = F,
            message = "|c8F8F8F|H1:p:318:8|h[22:04:03...", new_from = "Oberspäher Justal" </Locals>|r
            user:/AddOns/pChat/ChatHandlers.lua:168: in function 'pChatChatHandlersMessageChannelReceiver'
            |c
        ]]
        if text == nil then return "" end

        -- handle complex URLs and do
        for pos, url, prot, subd, tld, colon, port, slash, path in text:gmatch("()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%#=-]*))") do
            if pChatData.protocols[prot:lower()] == (1 - #slash) * #path
                    and (colon == "" or port ~= "" and port + 0 < 65536)
                    and (pChatData.tlds[tld:lower()] or tld:find("^%d+$") and subd:find("^%d+%.%d+%.%d+%.$") and math.max(tld, subd:match("^(%d+)%.(%d+)%.(%d+)%.$")) < 256)
                    and not subd:find("%W%W")
            then
                local urlHandled = strfor("|H1:%s:%s:%s|h%s|h", CONSTANTS.PCHAT_LINK, db.lineNumber, CONSTANTS.PCHAT_URL_CHAN, url)
                url = url:gsub("([?+-])", "%%%1") -- don't understand why, 1st arg of gsub must be escaped and 2nd not.
                text = text:gsub(url, urlHandled)
            end
        end

        return text

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

    -- Split text with blocs of 100 chars (106 is max for LinkHandle) and add LinkHandle to them
    -- WARNING : See FormatSysMessage()
    local function SplitTextForLinkHandler(text, numLine, chanCode)

        local newText = ""
        local textLen = strlen(text)
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

                    local lastByte = strbyte(splittedString, -1)
                    local beforeLastByte = strbyte(splittedString, -2, -2)

                    -- Characters can be into 1, 2 or 3 bytes. Lua don't support UTF natively. We only handle 3 bytes chars.
                    -- http://www.utf8-chartable.de/unicode-utf8-table.pl

                    if (lastByte < 128) then -- any ansi character (ex : a  97  LATIN SMALL LETTER A) (cut was well made)
                    --
                    elseif lastByte >= 128 and lastByte < 192 then -- any non ansi character ends with last byte = 128-191  (cut was well made) or 2nd byte of a 3 Byte character. We take 1 byte more.  (cut was incorrect)

                        if beforeLastByte >= 192 and beforeLastByte < 224 then -- "2 latin characters" ex: 195 169  LATIN SMALL LETTER E WITH ACUTE ; е 208 181 CYRILLIC SMALL LETTER IE
                        --
                        elseif beforeLastByte >= 128 and beforeLastByte < 192 then -- "3 Bytes Cyrillic & Japaneese" ex U+3057  し   227 129 151 HIRAGANA LETTER SI
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
                    newText = newText .. strfor("|H1:%s:%s:%s|h%s|h", CONSTANTS.PCHAT_LINK, numLine, chanCode, splittedString)
                    splits = splits + 1

                else
                    splittedString = text:sub(splittedStart)
                    local textSplittedlen = splittedString:len()
                    if textSplittedlen > 0 then
                        newText = newText .. strfor("|H1:%s:%s:%s|h%s|h", CONSTANTS.PCHAT_LINK, numLine, chanCode, splittedString)
                    end
                    needToSplit = false
                end

            end
        else
            -- When dumping back, the "from" section is sent here. It will add handler to spaces. prevent it to avoid an uneeded increase of the message.
            if not (text == " " or text == ": ") then
                newText = strfor("|H1:%s:%s:%s|h%s|h", CONSTANTS.PCHAT_LINK, numLine, chanCode, text)
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
                logger:Debug("triggered an infinite LinkHandling loop in the copy system with last message:", textToCheck)
            else
                preventLoopsCol = preventLoopsCol + 1
            end

            noColorlen = textToCheck:len()

            local startpos, endpos = strfind(textToCheck, "|H(.-):(.-)|h(.-)|h", 1)
            -- LinkHandler not found
            if not startpos then
                -- If nil, then we won't have new link after startposition = startNoColor , so add ours util the end

                -- Some addons use table.insert() and chat convert to a CRLF
                -- First, drop the final CRLF if we are at the end of the text
                if strsub(textToCheck, -2) == "\r\n" then
                    textToCheck = strsub(textToCheck, 1, -2)
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
        local noDDSlen -- = textToCheck:len()

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
                logger:Debug("triggered an infinite DDS loop in the copy system with last message: ", textToCheck)
            else
                preventLoopsDDS = preventLoopsDDS + 1
            end

            noDDSlen = textToCheck:len()

            local startpos, endpos = strfind(textToCheck, "|t%-?%d+%%?:%-?%d+%%?:.-|t", 1)
            if startpos == nil and endpos == nil then
                startpos, endpos = strfind(textToCheck, "|tnil:nil:.-|t", 1) --"|tnil:nil:EsoUI/Art/Miscellaneous/roll_dice.dds|t"
            end
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
        local count, countR, notNeeded
        local firstIsR

        rawSys = rawSys:gsub("||([Cc])", "%1") -- | is the escape char for |, so if an user type |c it will be sent as ||c by the game which will lead to an infinite loading screen because xxxxx||xxxxxx is a lua pattern operator and few gsub will broke the code

        --Search for Color tags
        startColSys, endColSys = strfind(rawSys, "|[cC]%x%x%x%x%x%x", 1)
        notNeeded, count = strgsub(rawSys, "|[cC]%x%x%x%x%x%x", "")

        -- No color tags in the SysMessage
        if startColSys then
            -- Found X tag
            -- Searching for |r after tag color

            -- First destroy tags with nothing inside
            rawSys = strgsub(rawSys, "|[cC]%x%x%x%x%x%x|[rR]", "")

            notNeeded, countR = strgsub(rawSys, "|[cC]%x%x%x%x%x%x(.-)|[rR]", "")

            -- Start tag found but end tag ~= start tag
            if count ~= countR then

                -- Add |r before the tag
                rawSys = strgsub(rawSys, "|[cC]%x%x%x%x%x%x", "|r%1")
                firstIsR = strfind(rawSys, "|[cC]%x%x%x%x%x%x")

                --No |r tag at the start of the text if start was |cXXXXXX
                if firstIsR == 3 then
                    rawSys = strsub(rawSys, 3)
                end

                -- Replace
                rawSys = strgsub(rawSys, "|r|r", "|r")
                rawSys = strgsub(rawSys, "|r |r", " |r")

                lastTag = strmatch(rawSys, "^.*()|[cC]%x%x%x%x%x%x")
                lastR = strmatch(rawSys, "^.*()|r")

                -- |r tag found
                if lastR ~= nil then
                    if lastTag ~= nil and lastTag > lastR then
                        rawSys = rawSys .. "|r"
                    end
                else
                    -- Got X tags and 0 |r, happens only when we got 1 tag and 0 |r because we added |r to every tags just before
                    -- So add last "|r"
                    rawSys = rawSys .. "|r"
                end

                -- Double check

                findC = strfind(rawSys, "|[cC]%x%x%x%x%x%x")
                findR = strfind(rawSys, "|[rR]")

                while findR ~= nil and findC ~= nil do

                    if findC then
                        if findR < findC then
                            rawSys = strsub(rawSys, 1, findR - 1) .. strsub(rawSys, findR + 2)
                        end

                        findC = strfind(rawSys, "|[cC]%x%x%x%x%x%x", findR)
                        findR = strfind(rawSys, "|[rR]", findR + 2)
                    end

                end

            end

        end
        -- Added |u search
        startColSys, endColSys = strfind(rawSys, "|u%-?%d+%%?:%-?%d+%%?:.-:|u",1)
        -- if found
        if startColSys then
            rawSys = strgsub(rawSys,"|u%-?%d+%%?:%-?%d+%%?:.-:|u","")
        end

        return rawSys

    end

    -- Add pChatLinks Handlers on the whole text except LinkHandlers already here
    -- WARNING : See FormatSysMessage()
    local function AddLinkHandlerToLine(text, chanCode, numLine)
        local rawText = ReformatSysMessages(text) -- FUCK YOU
        logger:Verbose(strfor("[pChat]AddLinkHandlerToLine - text: %s, rawText: %s", tos(text), tos(rawText)))

        local start = 1
        local rawTextlen = strlen(rawText)
        local stillToParseCol = true
        local formattedText
        local noColorText = ""
        local textToCheck = ""

        local startColortag = ""

        local preventLoops = 0
        local maxLoops = 100 -- This is the max count of items you can deconstruct at a time as well, so in theory, you could use MAX_ITEM_SLOTS_PER_DECONSTRUCTION as the constant here.
        local colorizedText = true
        local newText = ""

        -- Add safety check for empty or invalid input
        if not rawText or rawTextlen == 0 then
            return text
        end

        while stillToParseCol do
            -- Prevent infinite loops while its still in beta
            if preventLoops > maxLoops then
                -- If we hit the limit, return the remaining text as-is
                if start <= rawTextlen then
                    local remaining = strsub(rawText, start)
                    newText = newText .. remaining
                end
                logger:Debug(strfor("Hit loop prevention limit at position %d of %d while processing message: %s", start, rawTextlen, strsub(text, 1, 100) .. "..."))
                stillToParseCol = false
                break
            end
            preventLoops = preventLoops + 1

            -- Handling Colors, search for color tag
            local startcol, endcol = strfind(rawText, "|[cC]%x%x%x%x%x%x(.-)|r", start)

            -- Not Found
            if startcol == nil then
                startColortag = ""
                textToCheck = strsub(rawText, start)
                stillToParseCol = false
                newText = newText .. AddLinkHandlerToString(textToCheck, numLine, chanCode)
            else
                -- Add safety check for malformed color tags
                if endcol and endcol <= rawTextlen then
                    startColortag = strsub(rawText, startcol, startcol + 7)
                    -- pChat format all strings
                    if start == startcol then
                        -- textToCheck is only (.-)
                        textToCheck = strsub(rawText, (startcol + 8), (endcol - 2))
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
                        textToCheck = strsub(rawText, start, startcol - 1)
                        start = startcol
                        -- Tag color found but need to check some strings before
                        newText = newText .. AddLinkHandlerToString(textToCheck, numLine, chanCode)
                    end
                else
                    -- Handle malformed tags by treating remaining text as non-colored
                    textToCheck = strsub(rawText, start)
                    stillToParseCol = false
                    newText = newText .. AddLinkHandlerToString(textToCheck, numLine, chanCode)
                end
            end
        end

        return newText
    end


    --[[
    --Disabled as we cannot copy the text that way, so fixing he link handlers instead!
    local function checkIfLinkHandlerShouldBeAdded(text, chanCode, numLine)
        if chanCode == CHAT_CHANNEL_SYSTEM then
            if isDiceRollSystemMessage(text) then return true end
        end
        return false
    end
    ]]


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
            --Should a link handler be added for that text (e.g. a /roll command get's destroyed by that linkhandler!)
            --local doNotAddLinkHandler = checkIfLinkHandlerShouldBeAdded(text, chanCode, numLine)
            --if doNotAddLinkHandler == true then return text end

            -- No CRLF
            -- ESO LUA Messages output \n instead of \r\n
            local crtext = strgsub(text, "\r\n", "\n")
            -- Find multilines
            local cr = strfind(crtext, "\n")

            if not cr then
                formattedText = AddLinkHandlerToLine(text, chanCode, numLine)
            else
                local lines = {zo_strsplit("\n", crtext)}
                local first = true
                --local strippedLine
                local nunmRows = 0

                for _, line in pairs(lines) do

                    -- Only if there something to display
                    if strlen(line) > 0 then

                        if first then
                            formattedText = AddLinkHandlerToLine(line, chanCode, numLine)
                            first = false
                        else
                            formattedText = formattedText .. "\n" .. AddLinkHandlerToLine(line, chanCode, numLine)
                        end

                        if nunmRows > 10 then
                            logger:Warn("triggered 10 packed lines with text:", text)
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
    pChat.AddLinkHandler = AddLinkHandler

    -- Executed when EVENT_CHAT_MESSAGE_CHANNEL triggers
    -- Formats the message
    local function FormatMessage(chanCode, from, text, isCS, fromDisplayName, originalFrom, originalText, DDSBeforeAll, TextBeforeAll, DDSBeforeSender, TextBeforeSender, TextAfterSender, DDSAfterSender, DDSBeforeText, TextBeforeText, TextAfterText, DDSAfterText)
        local showTimestamp = db.showTimestamp
        local milliseconds
        if showTimestamp then
            milliseconds = pChat_getCurrentMillisecondsFormatted()
        end

        logger.verbose:Debug(strfor("FormatMessage-Line#: %s, channel %s: %s(%s/%s) %s (orig: %s)", tos(db.lineNumber), tos(chanCode), tos(originalFrom), tos(fromDisplayName), tos(from), tos(text), tos(originalText)))
        local notHandled = false

        -- Will calculate if this message is a spam
        local isSpam = SpamFilter(chanCode, from, text, isCS)
        --logger:Debug(">isSpam:", isSpam)
        -- A spam, drop everything
        if isSpam then return end

        --local info = ChannelInfo[chanCode]

        -- Init message with other addons stuff
        local message = DDSBeforeAll .. TextBeforeAll

        -- Init text with other addons stuff. Note : text can also be modified by other addons. Only originalText is the string the game has receive
        text = DDSBeforeText .. TextBeforeText .. text .. TextAfterText .. DDSAfterText

        --logger:Debug(">text:", text)
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

        --  for CopySystem
        --logger:Debug(">db.lineNumber:", db.lineNumber)
        db.LineStrings[db.lineNumber] = {}
        if not db.LineStrings[db.lineNumber].rawFrom then db.LineStrings[db.lineNumber].rawFrom = from end
        --if not db.LineStrings[db.lineNumber].rawValue then db.LineStrings[db.lineNumber].rawValue = text
        --logger:Debug(">>added db.LineStrings[%d].rawValue=%s", db.lineNumber, text)
        --end
        if not db.LineStrings[db.lineNumber].rawMessage then db.LineStrings[db.lineNumber].rawMessage = text end
        if not db.LineStrings[db.lineNumber].rawLine then db.LineStrings[db.lineNumber].rawLine = text end
        if not db.LineStrings[db.lineNumber].rawDisplayed then db.LineStrings[db.lineNumber].rawDisplayed = text end

        local new_from = ConvertName(chanCode, from, isCS, fromDisplayName)
        local displayedFrom = db.LineStrings[db.lineNumber].rawFrom

        -- Add other addons stuff related to sender
        new_from = DDSBeforeSender .. TextBeforeSender .. new_from .. TextAfterSender .. DDSAfterSender

        --logger:Debug(">new_from:", new_from)

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
        local lcol, rcol = pChat.GetChannelColors(chanCode, from)

        -- Add timestamp
        if showTimestamp then

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
            local timeStampData = pChat_CreateTimestamp(GetTimeString(), nil, milliseconds)
            local timestamp = ZO_LinkHandler_CreateLink(timeStampData, nil, CONSTANTS.PCHAT_LINK, db.lineNumber .. ":" .. chanCode) .. " "

            logger:Debug(">showTimestamp:", strfor("timecol: %s, timestamp: %s", tos(timecol), tos(timestamp)))

            -- Timestamp color
            message = message .. strfor("%s%s|r", timecol, timestamp)
            db.LineStrings[db.lineNumber].rawValue = strfor("%s[%s] |r", timecol, timeStampData)
        else
            --Fixed lines by Maggi (pChat PrivateMessage-> Pastebin link: https://pastebin.com/raw/dM7GQCsY)
            db.LineStrings[db.lineNumber].rawValue = ""
        end

		-- Coorbin20200708
        -- Chat Mentions: username highlighting, audible ding, exclamation icon, etc.
        text = cm.cm_format(chanCode, text, fromDisplayName, isCS, rcol)

        local linkedText = text

        -- Add URL Handling
        if db.urlHandling then
            text = AddURLHandling(text)
        end

        local isSayChannel = (chanCode == CHAT_CHANNEL_SAY and true) or false

        if db.enablecopy then
            local addLinkNow = true
            if isSayChannel then
                local isQuickChat = (isSayChannel == true and detectQuickChat(text, 1) ~= nil and true) or false
                if isQuickChat == true then
                    --QuickChat message found
                    logger:Debug(">QuickChat message found, text: " ..tos(text))
                    addLinkNow = false
                end
            end
            if addLinkNow then
                linkedText = AddLinkHandler(text, chanCode, db.lineNumber)
            end
        end

        local carriageReturn = ""
        if db.carriageReturn then
            carriageReturn = "\n"
        end

        -- Standard format
        if isSayChannel or chanCode == CHAT_CHANNEL_YELL or chanCode == CHAT_CHANNEL_PARTY or chanCode == CHAT_CHANNEL_ZONE then
            -- Remove zone tags
            if db.delzonetags then

                -- Used for Copy
                db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copystandard, db.LineStrings[db.lineNumber].rawFrom)

                message = message .. strfor(chatStrings.standard, lcol, new_from, carriageReturn, rcol, linkedText)
                db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.standard, lcol, new_from, carriageReturn, rcol, text)

                --[[
                if isSayChannel then
                    logger:Debug(strfor(">SAY - lineNo: %s, rawFrom: %s, text: %s, linkedText: %s, rawValue: %s",
                            tos(db.lineNumber),
                            tos(db.LineStrings[db.lineNumber].rawFrom),
                            tos(text),
                            tos(linkedText),
                            tos(db.LineStrings[db.lineNumber].rawValue)
                        )
                    )
                end
                ]]

            -- Keep zoneTags
            else
                -- Init zonetag to keep the channel tag
                local zonetag
                -- Pattern for party is [Party]
                if chanCode == CHAT_CHANNEL_PARTY then
                    zonetag = GetString(PCHAT_ZONETAGPARTY)

                    -- Used for Copy
                    db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copyesoparty, zonetag, db.LineStrings[db.lineNumber].rawFrom)

                    -- PartyHandler
                    zonetag = ZO_LinkHandler_CreateLink(zonetag, nil, CHANNEL_LINK_TYPE, chanCode)

                    message = message .. strfor(chatStrings.esoparty, lcol, zonetag, new_from, carriageReturn, rcol, linkedText)
                    db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.esoparty, lcol, zonetag, new_from, carriageReturn, rcol, text)
                else
                    -- Pattern for say/yell/zone is "player says:" ..
                    if isSayChannel then zonetag = GetString(PCHAT_ZONETAGSAY)
                    elseif chanCode == CHAT_CHANNEL_YELL then zonetag = GetString(PCHAT_ZONETAGYELL)
                    elseif chanCode == CHAT_CHANNEL_ZONE then zonetag = GetString(PCHAT_ZONETAGZONE)
                    end

                    -- Used for Copy
                    db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copyesostandard, db.LineStrings[db.lineNumber].rawFrom, zonetag)

                    -- pChat Handler
                    zonetag = strfor("|H1:p:%s|h%s|h", chanCode, zonetag)

                    message = message .. strfor(chatStrings.esostandart, lcol, new_from, zonetag, carriageReturn, rcol, linkedText)
                    db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.esostandart, lcol, new_from, zonetag, carriageReturn, rcol, text)
                end
            end

            -- NPC speech
        elseif chanCode == CHAT_CHANNEL_MONSTER_SAY or chanCode == CHAT_CHANNEL_MONSTER_YELL or chanCode == CHAT_CHANNEL_MONSTER_WHISPER then

            -- Used for Copy
            db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copynpc, db.LineStrings[db.lineNumber].rawFrom)

            message = message .. strfor(chatStrings.standard, lcol, new_from, carriageReturn, rcol, linkedText)
            db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.standard, lcol, new_from, carriageReturn, rcol, text)

            -- Incoming whispers
        elseif chanCode == CHAT_CHANNEL_WHISPER then

            --PlaySound
            local notifyImSoundIndex = db.notifyIMIndex
            if SOUNDS and PlaySound and notifyImSoundIndex and pChat.sounds then
                local soundName = pChat.sounds[notifyImSoundIndex]
                if soundName and SOUNDS[soundName] then
                    PlaySound(SOUNDS[soundName])
                end
            end

            -- Used for Copy
            db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copytellIn, db.LineStrings[db.lineNumber].rawFrom)

            message = message .. strfor(chatStrings.tellIn, lcol, new_from, carriageReturn, rcol, linkedText)
            db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.tellIn, lcol, new_from, carriageReturn, rcol, text)

            -- Outgoing whispers
        elseif chanCode == CHAT_CHANNEL_WHISPER_SENT then

            -- Used for Copy
            db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copytellOut, db.LineStrings[db.lineNumber].rawFrom)

            message = message .. strfor(chatStrings.tellOut, lcol, new_from, carriageReturn, rcol, linkedText)
            db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.tellOut, lcol, new_from, carriageReturn, rcol, text)

            -- Guild chat
        elseif chanCode >= CHAT_CHANNEL_GUILD_1 and chanCode <= CHAT_CHANNEL_GUILD_5 then
            logger:Debug(">Guild chat channel")
            local gtag = tag
            if db.showGuildNumbers then
                logger:Debug(">Guild chat channel:", gtag)
                gtag = (chanCode - CHAT_CHANNEL_GUILD_1 + 1) .. "-" .. tag

                --logger:Debug(">>gtag: %s, chanCode: %d, tag: %s", gtag, chanCode, tag)

                -- Used for Copy
                db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copyguild, gtag, db.LineStrings[db.lineNumber].rawFrom)

                -- GuildHandler
                gtag = ZO_LinkHandler_CreateLink(gtag, nil, CHANNEL_LINK_TYPE, chanCode)
                message = message .. strfor(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, linkedText)
                db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, text)

            else
                --logger:Debug(">No guild number")

                -- Used for Copy
                db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copyguild, gtag, db.LineStrings[db.lineNumber].rawFrom)

                -- GuildHandler
                gtag = ZO_LinkHandler_CreateLink(gtag, nil, CHANNEL_LINK_TYPE, chanCode)

                message = message .. strfor(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, linkedText)
                db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, text)

            end

            -- Officer chat
        elseif chanCode >= CHAT_CHANNEL_OFFICER_1 and chanCode <= CHAT_CHANNEL_OFFICER_5 then

            local gtag = tag
            if db.showGuildNumbers then
                gtag = (chanCode - CHAT_CHANNEL_OFFICER_1 + 1) .. "-" .. tag

                -- Used for Copy
                db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copyguild, gtag, db.LineStrings[db.lineNumber].rawFrom)

                -- GuildHandler
                gtag = ZO_LinkHandler_CreateLink(gtag, nil, CHANNEL_LINK_TYPE, chanCode)

                message = message .. strfor(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, linkedText)
                db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, text)
            else

                -- Used for Copy
                db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copyguild, gtag, db.LineStrings[db.lineNumber].rawFrom)

                -- GuildHandler
                gtag = ZO_LinkHandler_CreateLink(gtag, nil, CHANNEL_LINK_TYPE, chanCode)

                message = message .. strfor(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, linkedText)
                db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.guild, lcol, gtag, new_from, carriageReturn, rcol, text)
            end

            -- Player emotes
        elseif chanCode == CHAT_CHANNEL_EMOTE then

            db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copyemote, db.LineStrings[db.lineNumber].rawFrom)
            message = message .. strfor(chatStrings.emote, lcol, new_from, rcol, linkedText)
            db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.emote, lcol, new_from, rcol, text)

            -- NPC emotes
        elseif chanCode == CHAT_CHANNEL_MONSTER_EMOTE then

            -- Used for Copy
            db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copyemote, db.LineStrings[db.lineNumber].rawFrom)

            message = message .. strfor(chatStrings.emote, lcol, new_from, rcol, linkedText)
            db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.emote, lcol, new_from, rcol, text)

        else
            -- Language zones
            local lang = chatChannelLangToLangStr[chanCode]
            --[[
            elseif chanCode >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and chanCode <= CHAT_CHANNEL_ZONE_LANGUAGE_5 then
                local lang
                if chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_1 then lang = "EN"
                elseif chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_2 then lang = "FR"
                elseif chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_3 then lang = "DE"
                elseif chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_4 then lang = "JP"
                elseif chanCode == CHAT_CHANNEL_ZONE_LANGUAGE_5 then lang = "RU"
                end
            ]]
            if lang ~= nil then
                -- Used for Copy
                db.LineStrings[db.lineNumber].rawFrom = strfor(chatStrings.copylanguage, lang, db.LineStrings[db.lineNumber].rawFrom)

                message = message .. strfor(chatStrings.language, lcol, lang, new_from, carriageReturn, rcol, linkedText)
                db.LineStrings[db.lineNumber].rawValue = db.LineStrings[db.lineNumber].rawValue .. strfor(chatStrings.language, lcol, lang, new_from, carriageReturn, rcol, text)
            else
                -- Unknown messages - just pass it through, no changes.
                notHandled = true
                message = text
            end
        end

        db.LineStrings[db.lineNumber].rawDisplayed = message

        -- Only if handled by pChat

        if not notHandled then
            -- Store message and params into an array for copy system and SpamFiltering
                                --rawTimestamp, rawFrom, text, chanCode, originalFrom, wasTimeStampAdded
            pChat.StorelineNumber(GetTimeStamp(), db.LineStrings[db.lineNumber].rawFrom, text, chanCode, originalFrom, false)
        end

        -- Needs to be after .storelineNumber()
        if chanCode == CHAT_CHANNEL_WHISPER then
            pChat.OnIMReceived(displayedFrom, db.lineNumber - 1)
        end

        --logger:Debug("<messageNew:", message)

        return message

    end

    local function FormatSysMessage(statusMessage)
--d("[pChat]FormatSysMessage: " ..tos(statusMessage))
        local showTimestamp = db.showTimestamp
        local milliseconds
        if showTimestamp then
            milliseconds = pChat_getCurrentMillisecondsFormatted()
        end
        logger.verbose:Debug("FormatSysMessage:", statusMessage)

        -- Display Timestamp if needed
        local function ShowTimestamp()

            local timestamp = ""

            -- Add timestamp
            if showTimestamp then

                -- Timestamp formatted
                timestamp = pChat_CreateTimestamp(GetTimeString(), nil, milliseconds)

                local timecol
                -- Timestamp color is chanCode so no coloring
                if db.timestampcolorislcol then
                    -- Show Message
                    timestamp = strfor("[%s] ", timestamp)
                else
                    -- Timestamp color is our setting color
                    timecol = db.colours.timestamp

                    -- Show Message
                    timestamp = strfor("%s[%s] |r", timecol, timestamp)
                end

                logger.verbose:Debug(">SystemMessage showTimestamp:", timestamp)
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
            if strlen(statusMessage) > 0 then

                local sysMessage

                -- Some addons are quicker than pChat
                if db then
                    --Check if status message is a special one like /roll dice roll
                    local isDiceRoll = isDiceRollSystemMessage(statusMessage)
                    -- Show Message
                    statusMessage = ShowTimestamp() .. statusMessage
                    logger.verbose:Debug(">statusMessage after:", statusMessage)
                    if not db.lineNumber then
                        db.lineNumber = 1
                    end

                    --  for CopySystem
                    db.LineStrings[db.lineNumber] = {}

                    -- Make it Linkable
                    if db.enablecopy then
                        sysMessage = AddLinkHandler(statusMessage, CHAT_CHANNEL_SYSTEM, db.lineNumber)
                    else
                        sysMessage = statusMessage
                    end

                    logger.verbose:Debug(">sysMessage:", sysMessage)

                    if not db.LineStrings[db.lineNumber].rawFrom then db.LineStrings[db.lineNumber].rawFrom = "" end
                    if not db.LineStrings[db.lineNumber].rawMessage then db.LineStrings[db.lineNumber].rawMessage = "" end
                    if not db.LineStrings[db.lineNumber].rawLine then db.LineStrings[db.lineNumber].rawLine = "" end
                    if not db.LineStrings[db.lineNumber].rawValue then db.LineStrings[db.lineNumber].rawValue = statusMessage end
                    if not db.LineStrings[db.lineNumber].rawDisplayed then db.LineStrings[db.lineNumber].rawDisplayed = sysMessage end

                    -- No From, rawTimestamp is in statusMessage, sent as arg for SpamFiltering even if SysMessages are not filtered
                                        --rawTimestamp, rawFrom, text, chanCode, originalFrom, wasTimeStampAdded
                    pChat.StorelineNumber(GetTimeStamp(), nil, statusMessage, CHAT_CHANNEL_SYSTEM, nil, showTimestamp)

                end

                -- Show Message
                return sysMessage

            end

        end

    end

    -- For compatibility. Called by others addons.
    pChat.FormatMessage = FormatMessage
    pChat.formatSysMessage = FormatSysMessage
    --For other addon compatibility: Keep the old name of the global function
    pChat_FormatSysMessage = FormatSysMessage

    return FormatMessage, FormatSysMessage
end
