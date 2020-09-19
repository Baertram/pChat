-- Coorbin20200708
-- This is most of the Chat Mentions "engine".
-- Other places in the codebase where Chat Mentions functionality was introduced have the "Coorbin20200708" comment above them.
local db = {}

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

function pChat.cm_initChatMentionsEngine()
    db = pChat.db
    pChat.cm_watches = {}
    pChat.cm_regexes = {}
    pChat.cm_tempNames = {}
end

function pChat.cm_loadRegexes()
	local splitted = pChat.cm_list()
	pChat.cm_regexes = {}
	for k,v in pairs(splitted) do
		pChat.cm_regexes[pChat.cm_decorateText(v, true)] = pChat.cm_nocase(v)
	end
end

function pChat.cm_isWatched(playerName, rawName)
	playerName = string.lower(playerName)
	rawName = string.lower(rawName)
	return (pChat.cm_watches[playerName] ~= nil and pChat.cm_watches[playerName] == true) or (pChat.cm_watches[rawName] ~= nil and pChat.cm_watches[rawName] == true)
end

function pChat.cm_watch_toggle(argu) 
	pChat.cm_onWatchToggle(argu, argu)
	local isWat = pChat.cm_isWatched(argu, argu)
	if isWat then
		d("Watch is ENABLED for " .. argu)
	else
		d("Watch is DISABLED for " .. argu)
	end
end

function pChat.cm_add(argu)
	table.insert(pChat.cm_tempNames, argu)
	pChat.cm_loadRegexes()
	d("ChatMentions added " .. argu .. " to temporary list of names to ping on.")
end

function pChat.cm_del(argu)
	local keyToRemove = nil
	local valueRemoved = nil
	argu = string.lower(argu)
	for k, v in pairs(pChat.cm_tempNames) do
		local lcharName = string.lower(v)
		if lcharName == argu then
			valueRemoved = v
			keyToRemove = k
		end
	end
	if keyToRemove ~= nil then
		table.remove(pChat.cm_tempNames, keyToRemove)
		pChat.cm_loadRegexes()
		d("ChatMentions removed " .. argu .. " from temporary list of names to ping on.")
	else
		d("ChatMentions didn't find " .. argu .. " in the list of temporary names to ping on.")
	end
end

function pChat.cm_onWatchToggle(playerName, rawName)
	playerName = string.lower(playerName)
	rawName = string.lower(rawName)
	local isWat = pChat.cm_isWatched(playerName, rawName)

	if isWat then
		pChat.cm_watches[playerName] = false
		pChat.cm_watches[rawName] = false
	else
		pChat.cm_watches[playerName] = true
		pChat.cm_watches[rawName] = true
	end
end

function pChat.cm_nocase (s)
	news = string.gsub(string.gsub(s, "!", ""), utf8.charpattern, function (c)
		  return string.format("[%s%s]", string.lower(c), string.upper(c))
		end)
	if string.sub(s, 1, 1) == "!" then
		news = "!" .. news
	end
	return news
end

-- Turn a ([0,1])^3 RGB colour to "ABCDEF" form. We could use ZO_ColorDef, but we have so many colors so we don't do it.
function pChat.cm_convertRGBToHex(r, g, b)
	return string.format("%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

function pChat.cm_containsWholeWord(input, word)
	local rxWord = "^%p*" .. word .. "%p*$"
	local words = pChat.cm_dumbSplit(input)
	for k,v in ipairs(words) do
		if string.match(v, rxWord) ~= nil then
			return true
		end
	end
	return false
	-- return input:gsub('%a+', ' %1 '):match(' (' .. word .. ') ') ~= nil
end

function pChat.cm_dumbSplit(input)
	local sep = "%s"
	local t = {}
	
	for str in string.gmatch(input, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

-- Convert a colour from "ABCDEF" form to [0,1] RGB form.
function pChat.cm_convertHexToRGBA(colourString)
	local r=tonumber(string.sub(colourString, 3-2, 4-2), 16) or 255
	local g=tonumber(string.sub(colourString, 5-2, 6-2), 16) or 255
	local b=tonumber(string.sub(colourString, 7-2, 8-2), 16) or 255
	return r/255, g/255, b/255, 1
end

function pChat.cm_startsWith(str, start)
   return str:sub(1, #start) == start
end

function pChat.cm_convertHexToRGBAPacked(colourString)
	local r, g, b, a = pChat.cm_convertHexToRGBA(colourString)
	return {r = r, g = g, b = b, a = a}
end

function pChat.cm_split(text)
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
		if not buf then table.insert(retval, (str:gsub(spat,""):gsub(epat,""))) end
	end
	if buf then 
		return { [1] = "Missing matching quote for "..buf } 
	else
		return retval
	end
end

function pChat.cm_list()
    local splitted = {}
    if db.selfchar == true then
        splitted = pChat.cm_split(GetUnitName("player"))
        if db.wholenames == true then
            for l,m in pairs(splitted) do
                splitted[l] = "!" .. m
            end
        end
    end
    if db.extras ~= nil then
        for line in db.extras:gmatch("[^\r\n]+") do
            table.insert(splitted, line)
        end
    end
    for p,q in pairs(pChat.cm_tempNames) do
        table.insert(splitted, q)
    end
    return splitted
end

function pChat.cm_print_list()
	d(pChat.cm_list())
end

function pChat.cm_correctCase(origtext, text, v, capitalize)
	if capitalize ~= true then
		local i, j, k, l
		i = 0
		j = 0
		k = 0
		l = 0
		while true do
			i, j = string.find(origtext, v, i)
			k, l = string.find(text, v, k)
			if i == nil or k == nil then 
				break 
			end
			local origCasing = string.sub(origtext, i, j)
			local newCasing = string.sub(text, k, l)
			if k > 1 then
				if string.len(text) > l then
					text = string.sub(text, 1, k-1) .. origCasing .. string.sub(text, l+1)
				else
					text = string.sub(text, 1, k-1) .. origCasing
				end
			else
				if string.len(text) > l then
					text = origCasing .. string.sub(text, l+1)
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

function pChat.cm_decorateText(origText, useRegSyntax)
	local keyBuild = {}
	if db["excl"] == true then
		if useRegSyntax == true then
			table.insert(keyBuild, "|t100%%:100%%:pChat/dds/excl3.dds|t")
		else
			table.insert(keyBuild, "|t100%:100%:pChat/dds/excl3.dds|t")
		end
	end
	if db["changeColor"] == true then
		table.insert(keyBuild, "|c")
		table.insert(keyBuild, db["color"])
	end
	local upperProcStr = ""
	if useRegSyntax == true then
		upperProcStr = string.gsub(origText, "!", "")
	else
		upperProcStr = origText
	end
	if db["capitalize"] == true then
		table.insert(keyBuild, string.upper(upperProcStr))
	else
		table.insert(keyBuild, tostring(upperProcStr))
	end
	if db["changeColor"] == true then
		table.insert(keyBuild, "|r")
	end
	local retval = table.concat(keyBuild, "")
	return retval
end

function pChat.alreadyHasColorize(regex, origColor)
	local keyBuild = {}
	table.insert(keyBuild, "|r")
	table.insert(keyBuild, regex)
	table.insert(origColor)
	return table.concat(keyBuild, "")
end

function pChat.doAppendColor(text, v, k, appendColor)
	k = k .. appendColor
	text = string.gsub(text, v, k)
	if string.sub(text, -#appendColor) == appendColor then
		-- The string ends with the appendColor so we need to remove it
		text = string.sub(text, 1, #text - #appendColor)
	end
	return text
end

-- The main formatting routine that gets called inside FormatMessage.
function pChat.cm_format(text, fromDisplayName, isCS, appendColor)
    local lfrom = string.lower(fromDisplayName)
    local cm_lplayerAt = string.lower(GetUnitDisplayName("player"))
	
	-- Support custom colors already in the text
	local alreadyHasColor, lastColorValue = string.find(text, "|c[%d%a][%d%a][%d%a][%d%a][%d%a][%d%a]")
	local origColor = ""
	if alreadyHasColor then
		origColor = string.sub(text, alreadyHasColor, lastColorValue)
	end
	
    if isCS == false then
        if db.selfsend == true or (lfrom ~= "" and lfrom ~= nil and lfrom ~= cm_lplayerAt) then
            local origtext = text
            local matched = false
            for k,v in pairs(pChat.cm_regexes) do
				-- For debugging regexes: d("v = " .. v)
                if pChat.cm_startsWith(v, "!") then
                    v = string.sub(v,2)
                    if pChat.cm_containsWholeWord(text, v) then
                        if alreadyHasColor then
							text = string.gsub(text, v, pChat.alreadyHasColorize(k, origColor))
						else
							if appendColor ~= nil then
								text = pChat.doAppendColor(text, v, k, appendColor)
							else
								text = string.gsub(text, v, k)
							end
						end
						
                        if origtext ~= text then
                            text = pChat.cm_correctCase(origtext, text, v, db["capitalize"])
                            matched = true
                            if db.ding == true then
                                PlaySound(SOUNDS.NEW_NOTIFICATION)
                            end
                            return text
                        end
                    end
                else
					if alreadyHasColor then
						text = string.gsub(text, v, pChat.alreadyHasColorize(k, origColor))
					else
						if appendColor ~= nil then
							text = pChat.doAppendColor(text, v, k, appendColor)
						else
							text = string.gsub(text, v, k)
						end
					end
					
                    if origtext ~= text then
                        text = pChat.cm_correctCase(origtext, text, v, db["capitalize"])
                        matched = true
                        if db.ding == true then
                            PlaySound(SOUNDS.NEW_NOTIFICATION)
                        end
                        return text
                    end
                end
            end
            if matched == false and pChat.cm_isWatched(lfrom, lfrom) then
                text = pChat.cm_decorateText(origtext, false)
            end
        end
    end
    return text
end