-- Coorbin20200708
-- This is most of the Chat Mentions "engine".
-- Other places in the codebase where Chat Mentions functionality was introduced have the "Coorbin20200708" comment above them.
pChat.ChatMentions = {}
local cm = pChat.ChatMentions

local db = {}

--local ZOs and lua speed-ups
local tos = tostring
local ton = tonumber

local strlow = string.lower
local strup = string.upper
local strfind = string.find
local strfor = string.format
local strsub = string.sub
local strgsub = string.gsub
local strmat = string.match
local strgmat = string.gmatch
local strlen = string.len

local tins = table.insert
local tcon = table.concat

--Local speed-ups (not changing until reloadui/logout)
local exclamationMarkTexture = "pChat/dds/excl3.dds"

local cm_lplayerAt = strlow(GetUnitDisplayName("player"))
local cm_charNameSplitted --= cm.cm_split(GetUnitName("player"))



--If these string parts are found in the texts (itemlinks e.g.) the colorizing of the
--own name etc. won't happen
cm.cm_nonColorizableStringIdentifiers = {
	[1] = ":housing:", --owned houses itemlink for chat posts, from collections
}

--[[
function pChat.getAllLetters(charClass)
	local chars = "%aáéíóúýàèìòùâêîôûäëïöüÿâêîôûãñõçßøÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸ"
	local retval = ""
	if charClass == true then
		retval = "[" .. chars .. "]"
	else
		retval = chars
	end
	return retval
end
local allLettersCharClass = pChat.getAllLetters(true)
]]

function cm.cm_initChatMentionsEngine()
    db = pChat.db
    cm.cm_watches = {}
    cm.cm_regexes = {}
    cm.cm_tempNames = {}
end

function cm.cm_containsSpecialNonColorizableString(textVar)
	for k, v in ipairs(cm.cm_nonColorizableStringIdentifiers) do
		if string.find(textVar, v, 1, true) ~= nil then
--d("[pChat]CM containsSpecialNonColorizableString: " .. tos(textVar) .. " - contains: " .. tos(v) )
			return true
		end
	end
	return false
end

function cm.cm_loadRegexes()
	local splitted = cm.cm_list()
	cm.cm_regexes = {}
	for k,v in pairs(splitted) do
		cm.cm_regexes[cm.cm_decorateText(v, true)] = cm.cm_nocase(v)
	end
end

function cm.cm_isWatched(playerName, rawName)
	playerName = strlow(playerName)
	rawName = strlow(rawName)
	return (cm.cm_watches[playerName] ~= nil and cm.cm_watches[playerName] == true) or (cm.cm_watches[rawName] ~= nil and cm.cm_watches[rawName] == true)
end

function cm.cm_watch_toggle(argu) 
	cm.cm_onWatchToggle(argu, argu)
	local isWat = cm.cm_isWatched(argu, argu)
	if isWat then
		d("Watch is ENABLED for " .. argu)
	else
		d("Watch is DISABLED for " .. argu)
	end
end

function cm.cm_add(argu)
	tins(cm.cm_tempNames, argu)
	cm.cm_loadRegexes()
	d("ChatMentions added " .. argu .. " to temporary list of names to ping on.")
end

function cm.cm_del(argu)
	local keyToRemove = nil
	local valueRemoved = nil
	argu = strlow(argu)
	for k, v in pairs(cm.cm_tempNames) do
		local lcharName = strlow(v)
		if lcharName == argu then
			valueRemoved = v
			keyToRemove = k
		end
	end
	if keyToRemove ~= nil then
		table.remove(cm.cm_tempNames, keyToRemove)
		cm.cm_loadRegexes()
		d("ChatMentions removed " .. argu .. " from temporary list of names to ping on.")
	else
		d("ChatMentions didn't find " .. argu .. " in the list of temporary names to ping on.")
	end
end

function cm.cm_onWatchToggle(playerName, rawName)
	playerName = strlow(playerName)
	rawName = strlow(rawName)
	local isWat = cm.cm_isWatched(playerName, rawName)

	if isWat then
		cm.cm_watches[playerName] = false
		cm.cm_watches[rawName] = false
	else
		cm.cm_watches[playerName] = true
		cm.cm_watches[rawName] = true
	end
end

function cm.cm_nocase (s)
	local news = strgsub(strgsub(s, "!", ""), utf8.charpattern, function (c)
		  return strfor("[%s%s]", strlow(c), strup(c))
		end)
	if strsub(s, 1, 1) == "!" then
		news = "!" .. news
	end
	return news
end

-- Turn a ([0,1])^3 RGB colour to "ABCDEF" form. We could use ZO_ColorDef, but we have so many colors so we don't do it.
function cm.cm_convertRGBToHex(r, g, b)
	return strfor("%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

function cm.cm_containsWholeWord(input, word)
	local rxWord = "^%p*" .. word .. "%p*$"
	local words = cm.cm_dumbSplit(input)
	for k,v in ipairs(words) do
		if strmat(v, rxWord) ~= nil then
			return true
		end
	end
	return false
	-- return input:gsub('%a+', ' %1 '):match(' (' .. word .. ') ') ~= nil
end

function cm.cm_dumbSplit(input)
	local sep = "%s"
	local t = {}
	
	for str in strgmat(input, "([^"..sep.."]+)") do
			tins(t, str)
	end
	return t
end

-- Convert a colour from "ABCDEF" form to [0,1] RGB form.
function cm.cm_convertHexToRGBA(colourString)
	local r=ton(strsub(colourString, 3-2, 4-2), 16) or 255
	local g=ton(strsub(colourString, 5-2, 6-2), 16) or 255
	local b=ton(strsub(colourString, 7-2, 8-2), 16) or 255
	return r/255, g/255, b/255, 1
end

function cm.cm_startsWith(str, start)
   return str:sub(1, #start) == start
end

function cm.cm_convertHexToRGBAPacked(colourString)
	local r, g, b, a = cm.cm_convertHexToRGBA(colourString)
	return {r = r, g = g, b = b, a = a}
end

function cm.cm_split(text)
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	local retval = {}
	for str in text:gmatch("%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then tins(retval, (str:gsub(spat,""):gsub(epat,""))) end
	end
	if buf then 
		return { [1] = "Missing matching quote for "..buf } 
	else
		return retval
	end
end

function cm.cm_list()
    local splitted = {}
    if db.selfchar == true then
		cm_charNameSplitted = cm_charNameSplitted or cm.cm_split(GetUnitName("player"))
        splitted = cm_charNameSplitted
        if db.wholenames == true then
            for l,m in pairs(splitted) do
                splitted[l] = "!" .. m
            end
        end
    end
    if db.extras ~= nil then
        for line in db.extras:gmatch("[^\r\n]+") do
            tins(splitted, line)
        end
    end
    for p,q in pairs(cm.cm_tempNames) do
        tins(splitted, q)
    end
    return splitted
end

function cm.cm_print_list()
	d(cm.cm_list())
end

function cm.cm_correctCase(origtext, text, v, capitalize)
	if capitalize ~= true then
		local i, j, k, l
		i = 0
		j = 0
		k = 0
		l = 0
		while true do
			i, j = strfind(origtext, v, i)
			k, l = strfind(text, v, k)
			if i == nil or k == nil then 
				break 
			end
			local origCasing = strsub(origtext, i, j)
			--local newCasing = strsub(text, k, l) --Baertram 2023-04-10: Why was that in the code, variable newCasing is never used?
			if k > 1 then
				if strlen(text) > l then
					text = strsub(text, 1, k-1) .. origCasing .. strsub(text, l+1)
				else
					text = strsub(text, 1, k-1) .. origCasing
				end
			else
				if strlen(text) > l then
					text = origCasing .. strsub(text, l+1)
				else
					text = origCasing
				end
			end
			i = j
			k = l
		end
	end
	return text
end

function cm.cm_decorateText(origText, useRegSyntax)
	local keyBuild = {}
	if db["excl"] == true then
		if useRegSyntax == true then
			tins(keyBuild, "|t100%%:100%%:" .. exclamationMarkTexture .. "|t")
		else
			tins(keyBuild, "|t100%:100%:" .. exclamationMarkTexture .. "|t")
		end
	end
	if db["changeColor"] == true then
		tins(keyBuild, "|c")
		tins(keyBuild, db["color"])
	end
	local upperProcStr = ""
	if useRegSyntax == true then
		upperProcStr = strgsub(origText, "!", "")
	else
		upperProcStr = origText
	end
	if db["capitalize"] == true then
		tins(keyBuild, strup(upperProcStr))
	else
		tins(keyBuild, tos(upperProcStr))
	end
	if db["changeColor"] == true then
		tins(keyBuild, "|r")
	end
	local retval = tcon(keyBuild, "")
	return retval
end

function pChat.alreadyHasColorize(regex, origColor)
	local keyBuild = {}
	keyBuild[1] = "|r"
	keyBuild[2] = regex
	keyBuild[3] = origColor
	return tcon(keyBuild, "")
end
local pChat_alreadyHasColorize = pChat.alreadyHasColorize

function pChat.doAppendColor(text, v, k, appendColor)
	k = k .. appendColor
	text = strgsub(text, v, k)
	if strsub(text, -#appendColor) == appendColor then
		-- The string ends with the appendColor so we need to remove it
		text = strsub(text, 1, #text - #appendColor)
	end
	return text
end
local pChat_doAppendColor = pChat.doAppendColor


local function checkColorCorrectCaseAndPlaySound(k, v, text, origtext, appendColor, alreadyHasColor, origColor)
	local matched = false
	if alreadyHasColor then
		text = strgsub(text, v, pChat_alreadyHasColorize(k, origColor))
	else
		if appendColor ~= nil then
			text = pChat_doAppendColor(text, v, k, appendColor)
		else
			text = strgsub(text, v, k)
		end
	end

	if origtext ~= text then
		text = cm.cm_correctCase(origtext, text, v, db["capitalize"])
		matched = true
		if db.ding == true then
			local soundToPlay = db.dingSoundName or SOUNDS.NEW_NOTIFICATION
			PlaySound(soundToPlay)
		end
	end

	return text, matched
end

-- The main formatting routine that gets called inside FormatMessage.
function cm.cm_format(text, fromDisplayName, isCS, appendColor)
    local lfrom = strlow(fromDisplayName)

	-- Support custom colors already in the text
	local alreadyHasColor, lastColorValue = strfind(text, "|c[%d%a][%d%a][%d%a][%d%a][%d%a][%d%a]")
	local origColor = ""
	if alreadyHasColor then
		origColor = strsub(text, alreadyHasColor, lastColorValue)
	end
	
    if isCS == false then
		if db.selfsend == true or (lfrom ~= "" and lfrom ~= nil and lfrom ~= cm_lplayerAt) then
			local origtext = text
			local matched = false

			local containsSpecialStringNotToColorize = cm.cm_containsSpecialNonColorizableString(origtext)
			if not containsSpecialStringNotToColorize then
				for k,v in pairs(cm.cm_regexes) do
					-- For debugging regexes: d("v = " .. v)
					if cm.cm_startsWith(v, "!") then
						v = strsub(v,2)
						if cm.cm_containsWholeWord(text, v) then
							text, matched = checkColorCorrectCaseAndPlaySound(k, v, text, origtext, appendColor, alreadyHasColor, origColor, containsSpecialStringNotToColorize)
							if matched == true then return text end
							--[[
							if alreadyHasColor and not containsSpecialStringNotToColorize then
								text = strgsub(text, v, pChat_alreadyHasColorize(k, origColor))
							else
								if appendColor ~= nil and not containsSpecialStringNotToColorize then
									text = pChat_doAppendColor(text, v, k, appendColor)
								else
									text = strgsub(text, v, k)
								end
							end

							if origtext ~= text then
								text = cm.cm_correctCase(origtext, text, v, db["capitalize"])
								matched = true
								if db.ding == true then
									PlaySound(SOUNDS.NEW_NOTIFICATION)
								end
								return text
							end
							]]
						end
					else
						text, matched = checkColorCorrectCaseAndPlaySound(k, v, text, origtext, appendColor, alreadyHasColor, origColor, containsSpecialStringNotToColorize)
						if matched == true then return text end
						--[[
						if alreadyHasColor and not containsSpecialStringNotToColorize then
							text = strgsub(text, v, pChat_alreadyHasColorize(k, origColor))
						else
							if appendColor ~= nil and not containsSpecialStringNotToColorize then
								text = pChat_doAppendColor(text, v, k, appendColor)
							else
								text = strgsub(text, v, k)
							end
						end

						if origtext ~= text then
							text = cm.cm_correctCase(origtext, text, v, db["capitalize"])
							matched = true
							if db.ding == true then
								PlaySound(SOUNDS.NEW_NOTIFICATION)
							end
							return text
						end
						]]
					end
				end
			end
			if matched == false and cm.cm_isWatched(lfrom, lfrom) then
				text = cm.cm_decorateText(origtext, false)
			end
		end
    end
    return text
end
