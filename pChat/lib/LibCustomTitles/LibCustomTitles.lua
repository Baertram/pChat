--[[
Original Author: Ayantir
Current Author: Dolgubon
Past Author: Kyoma
Filename: LibCustomTitles.lua
Version: 10
]]--

--[[

This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

]]--


--[[

Author: Dolgubon
NOTE: Used Kyoma's version as a base. Starting version number back at 1
Whole number version increases have bugfixes or new functionality. 
Decimal version increases merely have new titles.
Version 4:
	- Changed what the u umlaut character was mapped to. With the previous one, when encoded it was a ' which provided issues

Version 3:
	- Fixed some issues with language and players using a non official langauge

Version 2:
	- Fixed an issue where titles that did not globally replace were not showing up for the player with the title

Version 1:
	- Global titles will now show up only once in the list of titles, replacing 'Volunteer'
	- The title will still be shown to other players regardless of what is selected
	- If no title is given for a player in a certain language, then no custom title will be used
	- The only exception is non official game translations - In that case, the English title will be used
	- Removed the Modules from Kyoma's version
	- Fixed a bug with titles for specific characters
	- Only has test titles
	- Removed many of the titles in the titleLocale


Author: Kyoma
Version 20
Changes: Rewrote how custom titles are added and stored to help reduce conflict between authors
	- Moved table with custom titles into seperate section with register function
	- Use achievementId instead of raw title name to make it work with all languages
	- Make it default to english custom title if nothing is specified for the user's language
	- Support for LibTitleLocale to fix issues with title differences for males and females
	
	(v18) 
	- Added support for colors and even a simple gradient
	- Moved language check to title registration
	
	(v19)
	- Fixed problems with UTF8 characters and color gradients
	
	(v20)
	- Added option to replace a title globally.
]]--
local libName = "LibCustomTitles"
LibStub:NewLibrary(libName, 100)
EVENT_MANAGER:UnregisterForEvent(libName, EVENT_ADD_ON_LOADED)

local libLoaded
local LIB_NAME, VERSION = "LibCustomTitlesN", 4.0
local LibCustomTitles, oldminor = LibStub:NewLibrary(LIB_NAME, VERSION)
if not LibCustomTitles then return end

local titles = {}

local _, nonHideTitle =  GetAchievementRewardTitle(92)
local _, nonHideCharTitle =  GetAchievementRewardTitle(93)



local lang = GetCVar("Language.2")
local supportedLang = 
{
	['en']=1,
	['de']=1,
	['fr']=1,
}


local customTitles = {}
local playerDisplayName = HashString(GetDisplayName())
local playerCharName = HashString( GetUnitName('player'))
local doesPlayerHaveGlobal 
local doesCharHaveGlobal 
function LibCustomTitles:RegisterTitle(displayName, charName, override, title)
	local titleToUse
	if type(title) == "table" then
		if title[lang] then
			titleToUse = title[lang]
		end

		if not supportedLang[lang] then titleToUse=title['en'] end
		if not titleToUse then return end
	end
	title = titleToUse
	--local hidden = (extra == true) --support old format

	if override == true  then
		if playerDisplayName == displayName then

			if charName == playerCharName then
				doesCharHaveGlobal = true
			elseif not charName then
				doesPlayerHaveGlobal = true
			end -- otherwise, it's another character

		end
	end

	local playerGender = GetUnitGender("player")
	local genderTitle

	if type(override) == "boolean" then --override all titles
		override = override and "-ALL-" or "-NONE-"
	elseif type(override) == "number" then --get override title from achievementId
		local hasRewardOfType, titleName = GetAchievementRewardTitle(override, playerGender) --gender is 1 or 2
		if hasRewardOfType and titleName then
			genderTitle = select(2, GetAchievementRewardTitle(override, 3 - playerGender))  -- cuz 3-2=1 and 3-1=2
			override = titleName
		end
	elseif type(override) == "table" then --use language table with strings
		override = override[lang] or override["en"]
	end

	if type(override) == "string" then 
		if not customTitles[displayName] then 
			customTitles[displayName] = {}
		end
		local charOrAccount = customTitles[displayName]
		if charName then
			if not customTitles[displayName][charName]  then 
				customTitles[displayName][charName] = {}
			end
			charOrAccount = customTitles[displayName][charName]
		end
		charOrAccount[override] = title
		if genderTitle and genderTitle ~= override then
			charOrAccount[genderTitle] = title
		end
	end
end

local maps=
{
	[126]=32,
	[125]=111,
	[123]=246,
	[94]=223,
	[40]=228,
	[61]=252,
	[42]=233,
	[43] = 232,
	[47] = 214,
	[58] = 220,
	[59] = 196,
	[60] = 234,
}

local function stringConvert(str)
	local t = {string.byte(str, 1, #str)}
	for i = 1, #t do
		t[i] = ((t[i] - 38)*3) % 89 + 38
		t[i] =  maps[t[i]] or t[i]
	end
	return string.char(unpack(t))
end

--= MOD(C1 +24,89)+38
--= MOD(E1 +78,89)+38

--iferror(char(VLOOKUP(mid(I1,1,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,2,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,3,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,4,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,5,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,6,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,7,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,8,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,9,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,10,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,11,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,12,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,13,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,14,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,15,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,16,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,17,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,18,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,19,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,20,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,21,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,22,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,23,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,24,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,25,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,26,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,27,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,28,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,29,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,30,1),B1:C,2,false)),"")&iferror(char(VLOOKUP(mid(I1,31,1),B1:C,2,false)),"")
function LibCustomTitles:Init()
	

	local CT_NO_TITLE = 0
	local CT_TITLE_ACCOUNT = 1
	local CT_TITLE_CHARACTER = 2

	local function GetCustomTitleType(displayName, unitName)
		if customTitles[displayName] then
			if customTitles[displayName][unitName] then
				return CT_TITLE_CHARACTER
			end
			return CT_TITLE_ACCOUNT
		end
		return CT_NO_TITLE
	end

	local function GetCustomTitle(originalTitle, customTitle)

		if customTitle then 
			if customTitle[originalTitle] then
				return stringConvert(customTitle[originalTitle])
			elseif originalTitle == "" and customTitle["-NONE-"] then
				return stringConvert(customTitle["-NONE-"])
			elseif customTitle["-ALL-"] then
				return stringConvert(customTitle["-ALL-"])
			end
		end
	end

	local function GetModifiedTitle(originalTitle, displayName, charName)

		-- check for global override
		local returnTitle = GetCustomTitle(originalTitle, customTitles["-GLOBAL-"]) or originalTitle
		-- check for player override
		local registerType = GetCustomTitleType(displayName, charName)

		if registerType == CT_TITLE_CHARACTER then
			return GetCustomTitle(originalTitle, customTitles[displayName][charName]) or returnTitle
		elseif registerType == CT_TITLE_ACCOUNT then 
			return GetCustomTitle(originalTitle, customTitles[displayName]) or returnTitle
		end
		return returnTitle
	end

	local GetUnitTitle_original = GetUnitTitle
	GetUnitTitle = function(unitTag)
		local unitTitleOriginal = GetUnitTitle_original(unitTag)
		local unitDisplayName = HashString(GetUnitDisplayName(unitTag))
		local unitCharacterName = HashString(GetUnitName(unitTag))

		return GetModifiedTitle(unitTitleOriginal, unitDisplayName, unitCharacterName)
	end

	local GetTitle_original = GetTitle
	GetTitle = function(index)
		local titleOriginal = GetTitle_original(index)
		local displayName = HashString(GetDisplayName())
		local characterName = HashString(GetUnitName("player"))
		local title = GetModifiedTitle(titleOriginal, displayName, characterName )

		if title ~= titleOriginal then 
			-- We don't want the title to overwrite everything in the dropdown
			-- So we only replace volunteer

			if nonHideTitle ~= titleOriginal then 
				if doesPlayerHaveGlobal or doesCharHaveGlobal then
					return titleOriginal
				else
					return title 
				end
			end

			return title
		else
			return title
		end
	end

end

local function OnAddonLoaded()
	if not libLoaded then
		libLoaded = true
		local LCC = LibStub(LIB_NAME)
		LCC:Init()
		EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

local lct=LibCustomTitles
lct.RT = lct.RegisterTitle

lct:RT(1276148971,2868841312,true,{en="O;]v;]aCYaku@{",})
lct:RT(383898450,false,true,{en="3u{@;]aCYaT]Z@{",})lct:RT(383898450,4149698651,true,{en="q>v}Z>w",fr="nDZyyC]@;[",de="q>v}Z>w",})
lct:RT(80340145,2040263953,92,{en="S<;ao>;aS]^;",fr="n;a6]uZ",de="0;]aNZ>;aTu<];",})
lct:RT(716725346,4019141728,true,{en="nu{@a/}[;ZvaPZ>w",})
lct:RT(1540406231,false,true,{en="S<;a0C};>",fr="n;a0C};>",de="0;]a0C};>",})
lct:RT(755746377,false,628,{en="S<;aM;>;YuX@C]",fr="n;aMZ;>YuZ@;^]",de="0;]aTC<[@b@;]",})
lct:RT(4141355865,false,92,{en="1^Z[vyu{@;]",fr="1^Z[vyu{@;]",de="1^Z[vyu{@;]",})
lct:RT(959437082,false,2139,{en="1]}z<C>alu]@",})
lct:RT(3185324787,false,92,{en="/]X<Z@;X@",fr="/]X<Z@;X@;",de="/]X<Z@;=@",})
lct:RT(1171120197,false,true,{en="pQ1Cvv;{{",fr="pQ1Cvv;{{",de="pQ1Cvv;{{",})
lct:RT(65500869,false,92,{en="5;u[aMCZ",fr="5;u[aMCZ",de="5;u[aMCZ",})lct:RT(65500869,75627323,92,{en="m[a0^X;",})
lct:RT(4198689717,1143482591,92,{en="/]X<yuwZ{@;]",})
lct:RT(2074654098,false,92,{en="/:{C[^@;[}aQC@a5^{zZXZC^{",fr="ku]]Ey;>@azu{a5^{z;X@",de="/:{C[^@aQZX<@a6;]vbX<@Zw",})lct:RT(2074654098,4247615100,92,{en="4[u>;{Au[=;]",fr="/]z;>@;^{;av;a3C>v;{",de="T;[@;>Au>v;];]",})

lct:RT(3966971491,false,92,{en="n1ka/]wC>Zu>anC|;]",fr="n1ka/]wC>Zu>anC|;]",de="n1ka/]wC>Zu>anC|;]",})
lct:RT(3820965258,false,92,{en="M[CCv@<Z]{@}",fr="M[CCv@<Z]{@}",de="M[CCv@<Z]{@}",})lct:RT(3820965258,1047795165,92,{en="1]u:{a4CzXC]>",fr="1]u:{a4CzXC]>",de="1]u:{a4CzXC]>",})
lct:RT(3782668513,3337670239,92,{en="1^u]vZu>",})
lct:RT(1419169535,false,1330,{en="R^u]@;]yu{@;]",})
lct:RT(3580024219,false,92,{en="5@C]y<C[va3;]X;>u]}",fr="3;]X;>uZ];av;alC]@FS;yzK@;",de="5@^]yY;{@;a5`[v>;]",})
lct:RT(347320517,false,92,{en="4C@u@Ca3u{<;]",fr="3u{<;]av;a4Cyy;{av;aS;]];",de="Pu]@CYY;[{@uyzY;]",})
lct:RT(87490740,false,92,{en="5u>w^Z>;apC{;",de="5u>w^Z>;{apC{;",})
lct:RT(2550321801,false,92,{en="l[^YY}a4uA{alZw<@}ak[uA{",fr="l[^YY}a4uA{alZw<@}ak[uA{",})lct:RT(2550321801,1979421257,1810,{en="Su>=Z@@}Fku@",fr="Su>=Z@@}Fku@",})
lct:RT(3995154142,false,92,{en="N@;]>u[ak<uyzZC>",fr="k<uyzZC>aa@;]>;[",de="NAZw;]ak<uyzZC>",})
lct:RT(874548877,false,92,{en="3^v:u[[a3u|;>",fr="3^v:u[[a3u|;>",de="5X<[uyy:u[[a3u|;>",})
lct:RT(416224960,false,92,{en="6;]}a/>w]}",fr="S]c{a;>aXC[c];",de="5;<]aA'@;>v",})
lct:RT(2740299925,3886364242,92,{en="0]uwC>a5zZ]Z@",fr="0]uwC>a5zZ]Z@",de="0]uwC>a5zZ]Z@",})
lct:RT(3196471767,false,92,{en="1u][ZXakC>>CZ{{;^]",fr="kC>>CZ{{;^]aaa[DuZ[",de="P>C:[u^X<FP;>>;]",})
lct:RT(1731359458,false,92,{en="5u>v:uwa3u{@;]",})
lct:RT(2392316419,false,true,{en="lZ{@Z=[ZaMu=[u|u",fr="ku>>;aMu=[u|u",de="U^X=;]]C<]aMu=[u|u",})lct:RT(2392316419,1701693549,true,{en="4Z{@uX<ZCaMu=[u|u",fr="ku>>;aMu=[u|u",de="U^X=;]]C<]aMu=[u|u",})
lct:RT(2402295877,false,92,{en="1];u@a5uw;(aN?^u[aCYaO;u|;>",fr="1]u>va5uZ>@aawu[av^akZ;[",de="1]Ct;]aO;Z[Zw;]aOZyy;[",})
lct:RT(2762805744,false,1391,{en="5@C>;X^@@;]",})
lct:RT(1069428601,false,92,{en="O;u[;]aCYa@<;aT;u=a",fr="1^E]Z{{;^]av;{aluZ:[;{",de="O;Z[;]av;]a5X<AuX<;>",})
lct:RT(2511359942,false,92,{en="S<;aU;]wakC>v^X@C]",fr="n;ak<;YaU;]w",de="0;]aU;]wa0Z]Zw;>@",})
lct:RT(2037837684,false,92,{en="5;]|u>@aCYa1Cvv;{{a1[Z@@;]",})

lct:RT(1904732837,false,true,{en="/vv;]aCYao>{",fr="/vvZ@ZC>>;^]av;ao>{",de="/vvZ;];]a|C>ao>{",})
lct:RT(2787550069,453923765,true,{en="p;{@CFZ>F0Z{w^Z{;",fr="p;{@CFZ>F0Z{w^Z{;",de="p;{@CFZ>F0Z{w^Z{;",})
lct:RT(1987214583,false,92,{en="S<;aN[v;]a0]uwC>",fr="S<;aN[v;]a0]uwC>",de="S<;aN[v;]a0]uwC>",})lct:RT(1987214583,3107977549,628,{en="S<;a3u{@;]yZ>v",fr="S<;a3u{@;]yZ>v",de="S<;a3u{@;]yZ>v",})
lct:RT(2193066671,false,92,{en="pCX=;@;;]",})lct:RT(2193066671,2274919616,1810,{en="PC{yC>u^@aPZ@@}",})
lct:RT(3600512696,false,92,{en="~XuI+XYYnZw<@>Z>walC]y~]",})
lct:RT(1024520674,false,92,{en="4;uX;=;;z;]",fr="5C[vu@av;a[ua4uZ_",de="l]Z;v;>{AbX<@;]",})
lct:RT(4257573713,false,92,{en="oyu;aTua3C^a5<Z>v;Z]^",fr="oyu;aTua3C^a5<Z>v;Z]^",de="oyu;aTua3C^a5<Z>v;Z]^",})

lct:RT(3316406928,false,92,{en="5C>wA;u|;]",fr="SZ{{;^]av;ak<u>{C>",de="nZ;vA;:;]",})lct:RT(3316406928,331729979,1391,{en="nZ@;]u]}an;w;>v",fr="nEw;>v;anZ@@E]uZ];",de="nZ@;]u]Z{X<;an;w;>v;",})
lct:RT(653129646,false,92,{en="S<;a1C[v;>a5uZ>@",fr="n;a5uZ>@avDo]",de="0;]a1C[v;>;aO;Z[Zw;",})lct:RT(653129646,1618900846,92,{en="S<;a0]^Zv",fr="n;a0]^Zv;",de="0;]a0]^Zv;",})
lct:RT(2514190522,false,92,{en="myz;]Zu[aMu@@[;yuw;",fr="Mu@@[;yuw;amyzE]Zu[",de="myz;]Zu[;]aPuyzYyuwZ;]",})lct:RT(2514190522,2080803584,1810,{en="5z;u]aCYa5@;>vu]]",fr="nu>X;av;a5@;>vu]]",de="5z;;]a|C>a5@;>vu]]",})
lct:RT(2224225614,false,92,{en="5z;u=;]aYC]a@<;a0;uv",})

lct:RT(3879977139,false,92,{en="S<;a/{{;y:[}a1;>;]u[",})lct:RT(3879977139,189200680,92,{en="ku>>C@a4uvalZ|;",})
lct:RT(3957423493,false,92,{en="S<;a5AC[;a4u@]C[",})
lct:RT(3198987902,false,92,{en="S<;a1ZY@;v",})lct:RT(3198987902,3050075638,92,{en="S<;a/Au=;>;v",})
lct:RT(265543675,false,92,{en="0]uwC>a5[u};]",fr="k<u{{;^]av;a0]uwC>",de="0]uX<;>@`@;]",})lct:RT(265543675,1652025059,92,{en="S<;ak^];aYC]a0;u@<",fr="n;ap;ycv;akC>@];a[ua3C]@",de="0Z;aO;Z[^>waY']av;>aSCv",})
lct:RT(1517585757,false,92,{en="MuX<;[u{aMll",})
lct:RT(2188837655,false,92,{en="SCza4]ZC]Z@}",fr="a4]ZC]Z@E",})lct:RT(2188837655,2836585406,51,{en="5<];=",})

lct:RT(2083511209,false,92,{en="0u]=aNy;]u[v",fr="Ny;]u^v;a5Cy:];",})
lct:RT(2050501477,false,92,{en="Tu>v;]Z>wa/v|;>@^];]",})lct:RT(2050501477,3768515314,51,{en="OC[}a4]Z;{@aCYa3;]ZvZu",})
lct:RT(658966427,false,92,{en="/]@ZYZX;]aCYaU;>Z@<u]",fr="/]@ZYZXZ;]av;aU;>Z@<u]",de="P^>{@<u>vA;]=;]a|C>aU;>Z@<u]",})lct:RT(658966427,532842436,628,{en="p;va0ZuyC>v",fr="0Zuyu>@apC^w;",de="apC@;]a0Zuyu>@",})
lct:RT(188206946,false,92,{en="3u{@;]aCYa3;y;{",fr="3ug@];av;{a3cy;{",de="3;Z{@;]av;]a3;y;{",})
lct:RT(3235505263,false,92,{en="1Z>w;]",fr="pC^?^Z>",de="pC@=CzY",})
lct:RT(397091973,false,true,{en="3;]XZ[;{{ap;{C[|;",fr="pE{C[^@ZC>amyzZ@C}u:[;",de="1>uv;>[C{;aN>@{X<[C{{;><;Z@",})
lct:RT(2660919200,false,92,{en="3;>@C]",})

lct:RT(1527484276,false,92,{en="5@C]y:];u=;]",})

lct:RT(1375307746,false,true,{en="/yuBC>aR^;;>",fr="/yuBC>;ap;Z>;",de="/yuBC>;>=`>ZwZ>",})

lct:RT(452725322,false,92,{en="0Z|Z>;aN_;X^@ZC>;]",fr="0Z|Z>aMC^]];u^",de="1`@@[ZX<;]a5X<u]Y]ZX<@;]",})lct:RT(452725322,3541899474,2079,{en="S<;a3uX<Z>;",fr="nua3uX<Z>;",de="0Z;a3u{X<Z>;",})
lct:RT(671038416,false,2079,{en="5Z[|;]aU;]wa5^]Y;]",fr="/]w;>@a5^]Y;^]aU;]w",de="5Z[:;]aU;]wa5^]Y;]",})
lct:RT(391627066,false,92,{en="1^u]vZu>a/>w;[",fr="/>w;a1u]vZ;>",de="5X<^@B;>w;[",})
lct:RT(1449947651,false,92,{en="5X]^:@u{@ZXaku];:;u]",})
lct:RT(1143345413,false,92,{en="l1ea4]Cw];{{ZC>aS;uy",fr="l1ea4]Cw];{{ZC>aS;uy",de="l1ea4]Cw];{{ZC>aS;uy",})
lct:RT(3396402417,false,51,{en="S<;anZ|Z>wa5<uvCA",fr="nDCy:];a6Z|u>@;",de="0;]apu{@[C{;a5X<u@@;>",})lct:RT(3396402417,401432131,628,{en="T<Z@;alu>w",fr="k]CXaM[u>X",de="T;Zt;]alu>wBu<>",})
lct:RT(2837968354,false,92,{en="o>;a3u>a/]y}",fr="q>aOCyy;a/]yE;",de="NZ>Fyu>>Fu]y;;",})


lct:RT(173478323,2881560666,92,{en="5@]C>wa5y;[[Z>wao]X",de="5@u]=a3Z;Y;>v;]ao]=",})
lct:RT(1804301692,false,92,{en="nuv}aCYa@<;a5C^@<am{[u>v",fr="0uy;av;a[Dm[;av^a5^v",de="0uy;av;]a5'vZ>{;[",})
lct:RT(1044122497,false,92,{en="S<;anC];yu{@;]",fr="nC];yu{@;]",de="nC];yu{@;]",})lct:RT(1044122497,2763479321,1330,{en="0ka5z}",fr="N{zZC>a0k",de="0ka5zZC>",})
lct:RT(3836251840,false,true,{en="ku=;{aM}aS<;aoX;u>",fr="1a@;u^au^aMC]vav;anDCXEu>",de="P^X<;>auya3;;]",})lct:RT(3836251840,3297937951,1330,{en="R^;;>aCYaku=;{",fr="p;Z>;av;{a1a@;u^_",de="P`>ZwZ>av;]aP^X<;>",})
lct:RT(1059334478,false,92,{en="kCu_;{a3;@u[",fr="kCu_;{a3E@u[",de="PCu_;{a3;@u[[",})
lct:RT(1076342159,false,92,{en="S<;aOC>C]u:[;",fr="nDOC>C]u:[;",de="0Z;aN<]<uY@;>",})
lct:RT(130665165,false,92,{en="S<;aMCw;}yu>",fr="n;ak]C?^;FyZ@uZ>;",de="0;]aM^<yu>>",})
lct:RT(244717510,false,92,{en="nuakC>?^E]u>@;azu{amyz[u?^u:[;",fr="nuakC>?^E]u>@;azu{amyz[u?^u:[;",de="nuakC>?^E]u>@;azu{amyz[u?^u:[;",})lct:RT(244717510,1184782488,92,{en="4<u]yuXZ;>>;",fr="4<u]yuXZ;>>;",de="4<u]yuXZ;>>;",})
lct:RT(1342813983,2721735970,92,{en="S<;apZzz;]",fr="nDN|;>@];^]",de="0;]a/^Y];Zt;]",})
lct:RT(1627745582,false,92,{en="5=CCyua/vvZX@",fr="n;a5=CCyua/vvZX@",de="5=CCyua/:<b>wZw;>",})
lct:RT(2487628104,false,92,{en="~XYYIJ:f0;{^a0;{^aa~]",fr="~XYYIJ:f0;{^a0;{^aa~]",de="~XYYIJ:f0;{^a0;{^aa~]",})lct:RT(2487628104,2978586387,1810,{en="~XYYIJ:fS;aSu>?^;Ca4uzZaa~]",fr="~XYYIJ:f2;a|uZ{a|C^{aSu>=;]a4uz",de="~XYYIJ:fmX<aA;]v;a4u>B;]avZX<a4",})

lct:RT(210728403,270455745,92,{en="S<;a3;@<CvZXu[",})
lct:RT(3252834201,false,92,{en="S<;a5ZyC>aN_z];{{",fr="n;a5ZyC>aN_z];{{",de="0;]a5ZyC>aN_z];{{",})
lct:RT(1365579521,false,628,{en="TZz;{aC>aS]u{<",})
lct:RT(2822666538,false,true,{en="~XllGGGG5C^[ap;uz;]~]",fr="~XllGGGG5C^[ap;uz;]~]",de="~XllGGGGnD/>=C^~]",})
lct:RT(1507726281,3541509713,92,{en="2u|;[Z>aCYa5@;>vu]]",fr="2u|;[C@av;a5@;>vu]]",de="5z;;]A^]Ya|C>a5@;>vu]]",})

lct:RT(1158594345,false,92,{en="4]C@;X@C]aCYa@<;ap;u[y",})
lct:RT(4267095257,false,92,{en="~X,GGG,Gk[C^vak<u{;]~]",fr="~X,GGG,GQ^uw;ak<u{{;~]",de="~X,GGG,GTC[=;>xbw;]~]",})
lct:RT(109224740,1737010384,92,{en="0];uyaPZ[[;]",fr="S^;^]av;apK|;",de="S]u^yFPZ[[;]",})
lct:RT(713456003,false,1330,{en="S<;al[uA[;{{a1[uvZu@C]",fr="1[uvZu@;^]amyz[uXu:[;",})lct:RT(713456003,3775367921,1330,{en="S<;al[uA[;{{a1[uvZu@C]",fr="1[uvZu@;^]amyz[uXu:[;",})
lct:RT(3750747221,false,92,{en="1^u]vZu>aCYa@<;a1u[u_}",})lct:RT(3750747221,2918372644,51,{en="S<;aMZ]vaY]Cya3Z{YC]@^>;",fr="oZ{;u^av^a3u[<;^]",})
lct:RT(1313177490,false,494,{en="S<;am>|Z>XZ:[;",fr="nDam>|Z>XZ:[;",de="0Z;aq>:;{Z;w:u];",})
lct:RT(2864716338,false,92,{en="3Z{@];{{aCYa@<;a0u]=",})
lct:RT(1013558538,3510921308,2079,{en="0Z{:u>va0Z{:u>va0Z{:u>v",fr="0Z{:u>va0Z{:u>va0Z{:u>v",de="0Z{:u>va0Z{:u>va0Z{:u>v",})
lct:RT(4120068347,false,92,{en="S;ua3u=;]",en="S<EZc];",de="S;;=CX<;]",})lct:RT(4120068347,2030795112,1810,{en='0CoC0',})
lct:RT(2416997617,false,92,{en="4u{<u",en="4uX<u",de="4u{<u",})
lct:RT(841517891,false,92,{en="TC]@<}",})

lct:RT(810384984,238394253,92,{en='/z;_',})

lct:RT(4052732411,false,92,{en='ku{^u[',})lct:RT(4052732411,671906596,92,{en='ku{^u[',})
lct:RT(3204068434,false,92,{fr='0]uwC>YZ];apZv;]',})lct:RT(3204068434,2083966292,51,{en='5@C]yapZv;]',})
lct:RT(425871172,false,92,{en='5AC]vaoYa5<u>>u]u',})
lct:RT(4292278260,false,92,{en='S<;apZ>waM;u];]',})lct:RT(4292278260,2488928266,2079,{en='S<;am[[^yZ>u@;v',})
lct:RT(1553656508,false,92,{en='Q^=;]C]',fr='Q^=;]C]',de="Q^=;]C]",})

lct:RT(3101213993,false,true,{en='~X*gIHv,S<;amyyC]@u[',fr='~X*gIHv,nDZyyC]@;[',de='~X*gIHv,0;]aq>{@;]:[ZX<;',})
lct:RT(2014809841,2978736366,92,{en='k^]ZCakC[[;X@C]',fr='kC[[;X@ZC>>;^]av;ak^]ZC{Z@E{',de='P^]ZC{Z@b@;>{uyy[;]',})
lct:RT(2063947617,false,92,{en='R^;;>aoYanZBu]v{',fr='];Z>;av;{a[EBu]v{',de='aP`>ZwZ>av;]aNZv;X<{;>',})lct:RT(2063947617,341020706,92,{en='Nyz;]C]aoYanZBu]v{',fr='aNyz;];^]a0;{anEBu]v{',de='PuZ{;]av;]aNZv;X<{;>',})

lct:RT(3128590789,false,92,{en='MuXC>a0;{@]C};]',fr='0;{@]^X@;^]av;a:uXC>',de='5z;X=B;]{@`];]',})
lct:RT(4293973946,3056998748,1330,{en='OC[}ak]^{uv;]',de='yu=;[[C{;aN]C:;]Z>',})
lct:RT(1161506350,false,92,{en='0ZBB}Z>wa5zuyy;]',fr='0ZBB}Z>wa5zuyy;]',de='0ZBB}Z>wa5zuyy;]',})
lct:RT(963571677,false,92,{en='S<;a:;u]v;vayu>',fr='nD<Cyy;a:u]:^',de='0;]aMb]@Zw;a3u>>',})
lct:RT(3733334153,false,92,{en='1]u>vaTu]ak<Z;Ya5^z];y;',})
lct:RT(3130962581,false,494,{en='3CC>anZw<@',fr='k[uZ]av;a[^>;',de='3C>v[ZX<@',})lct:RT(3130962581,4261844445,494,{en='3CC>anZw<@',fr='k[uZ]av;a[^>;',de='3C>v[ZX<@',})
lct:RT(2127935949,false,628,{en='S<;a5u{{yu>X;]',})lct:RT(2127935949,3789400369,92,{en='S<;aS;]]Z:[;a5>CAy;]',fr='an;aS;]]Z:[;aQ;Zw;y;]',de='0;]a5X<];X=[ZX<;a5X<>;;y;]',})



lct:RT(4044176894,false,92,{en='S<;ak^]{;vao>;',})
lct:RT(1403951427,false,92,{en='S<;aq>YC]wZ|;>',})

lct:RT(2709370135,false,92,{en='5Z[|;]}a0u]=>;{{',fr='o:{X^]Z@Eau]w;>@E;',de='5Z[:]Zw;a0^>=;[<;Z@',})
lct:RT(4281723531,false,92,{en='TZz;{aC>aS]u{<',fr='nZ>w;@@;{a{^]a[uakC]:;Z[[;',de='TZ{X<@aZya3^[[',})lct:RT(4281723531,306136156,1330,{en='5@uyz[u]aAZ[[a>;|;]avZ;',fr='5@uyz[u]a>;ayC^]]uaxuyuZ{',de='a5@uyz[u]aAZ]va>Z;yu[{a{@;]:;>',})
lct:RT(3619172715,false,92,{en='3u{@;]aU;]wa5^]Y;]',fr='3u{@;]aU;]wa5^]Y;]',de='3u{@;]aU;]wa5^]Y;]',})
lct:RT(3188788347,false,92,{en='lu:^[C^{',fr='lu:^[;^_',de='lu:;[<uY@',})lct:RT(3188788347,1700138827,92,{en='2^{@aua:Z@a3Z;<',fr='2^{@aua:Z@a3Z;<',de='2^{@aua:Z@a3Z;<',})



lct:RT(4048208493,1185902972,92,{en='5Z>Z{@;]aS^]=;}',})
lct:RT(2858992612,false,92,{en='3u{@;]aCYaP>CA[;vw;',fr='3ug@];av;a[uakC>>uZ{{u>X;',de='3;Z{@;]av;{aTZ{{;>{',})

lct:RT(4124279317,false,92,{en='N[;wu>@[}aTu{@;v',fr='a[Ewuyy;>@a1u{zZ[[E',de='N[;wu>@a6;]w;^v;@',})lct:RT(4124279317,1022046773,628,{en='5zCZ[;vaM]u@',fr='1uyZ>a1a@E',de='6;]BCw;>;{a1`]',})
lct:RT(2119731248,1017899260,true,{en='5<uvCAaCYa@<;aT;{@',fr='oy:];av;a[Do^;{@',de='5X<u@@;>av;{aT;{@;>{',})

lct:RT(1298377073,false,92,{en='3u{@;]ak<;Y',})lct:RT(1298377073,599246026,92,{en='3u{@;]ak<;Y',})
lct:RT(763457523,false,1810,{en='/]v;>@al[uy;',fr='l[uyy;au]v;>@;',de='1[^<;>v;al[uyy;',})
lct:RT(798111974,false,92,{en='5Z>aCYa1];;v',})

lct:RT(3085595752,2582039471,92,{en='1C[v;>a1^u]vZu>',})
lct:RT(1953523750,3270432679,92,{en='Mu@@[;yuw;',})
lct:RT(554270662,1747005414,92,{en='P]ZYaN];Za0Z[C>',fr='P]ZYaN];Za0Z[C>',de='P]ZYaN];Za0Z[C>',})
lct:RT(2021154607,false,92,{en='pZzz;]',fr='a|;>@];^]',de='pZzz;]',})

lct:RT(3506149602,false,92,{en='kCvZ>waku@',fr='kCvZ>waku@',de='kCvZ>waku@',})lct:RT(3506149602,2311532378,1810,{en='S<;aN|;]FnZ|Z>w',fr='S<;aN|;]FnZ|Z>w',de='S<;aN|;]FnZ|Z>w',})
lct:RT(533751404,false,92,{en='3^@<{;]u',fr='3^@<{;]u',de='3^@<{;]u',})
lct:RT(2513617898,3008522260,92,{en='/{<=<u>',})

lct:RT(1703460885,false,92,{en='l]Z;>v[}aQ;Zw<:C^]',})lct:RT(1703460885,3210043349,92,{en='TZ>w{aCYaTC>v;]',})
lct:RT(760593166,false,92,{en='M[uX=aTZvCA',fr='6;^|;aQCZ]',de='5X<Au]B;aTZ@A;',})
lct:RT(1134753014,false,92,{en='q]{a3uxC]',fr='q]{a3uxC]',de='q]{a3uxC]',})lct:RT(1134753014,2223000998,92,{en='4]CY;{{C]au@a/>=<F3C]zC]=',fr='4]CY;{{;^]aaa/>=<F3C]zC]=',de='4]CY;{{C]aZ>a/>=<F3C]zC]=',})
lct:RT(1838172566,false,92,{en='nZ|Z>wan;w;>v',fr='nEw;>v;a6Z|u>@;',de='n;:;>v;an;w;>v;',})
lct:RT(3091229980,false,92,{en='6^[_{;v_',fr='6^[_{;v_',de='6^[_{;v_',})lct:RT(3091229980,4134294656,92,{en='k[u}yC];amamar',})
lct:RT(2845909476,false,92,{en='S<;aQC>4[^{q[@]u',fr='n;aQC>4[^{q[@]u',de='0u{aQC>4[^{q[@]u',})lct:RT(2845909476,2216570798,705,{en='QCa3;]X}',})
lct:RT(2359969152,false,2079,{en='oa3uwCaEamyz[uXa|;[',fr='n;ayuwZXZ;>a;{@amyz[uXu:[;',de='0;]aUu^:;];]aZ{@aq>;]:Z@@[ZX<',})

lct:RT(2455827257,false,92,{en='p;u[ay|za5@ZX=a4',fr='p;u[ay|za5@ZX=a4',de='p;u[ay|za5@ZX=a4',})lct:RT(2455827257,1298336713,92,{en='p;u[ay|za5@ZX=a4',})
lct:RT(3436387716,false,705,{en='5XC^]w;aoYak}]CvZZ[',fr='l[Eu^a0^ak}]CvZZ[',de='1;Zt;[a|C>ak}]CvZZ[',})
lct:RT(2929427093,1621733346,true,{en='nZw<@aCYa0uA>',})
lct:RT(3990524561,false,92,{en='4^>=aM^>>}',fr='4^>=anuzZ>',de='4^>=FOu{;',})
lct:RT(3355087462,false,92,{en='kuvA;[[D{a4[u@Z>^ya3;y:;]',fr='3;y:];a4[u@Z>;av;akuvA;[[',de='kuvA;[[{a4[u@Z>^yF3Z@w[Z;v',})
lct:RT(2995614219,false,92,{en='k<Z;YaCYaN?^;{aQCX@Z{a',de='N?^;{aQCX@Z{ak<;YZ>a',})lct:RT(2995614219,3531621777,92,{en='k<Z;YaCYaN?^;{aQCX@Z{',})
lct:RT(2589474561,false,92,{en='S<;aN>@<;Cw;>ZX',fr='nDN>@<;Cw;>ZX',de='0Z;aN>@<;Cw;>;',})


--[[
Author: Kyoma
Filename: LibTitleLocale.lua
Version: 3 (Horns of the Reach)
Total: 95 titles
]]--

local LocaleTitles =
{
	["de"] = 
	{
		[2] = 
		{
			[1810] = "Divayth Fyrs Gehilfe",
			[1838] = "Der Tick-Tack-Peiniger",
			[1330] = "makelloser Eroberer",
			[51] = "Monsterjäger",
			[705] = "Großfeldherr",
			[92] = "Freiwilliger",
			[494] = "Meisterangler",
			[1391] = "dro-m'Athra-Zerstörer",
			[628] = "Held Tamriels",
			[1910] = "Held der Eroberung",
			[1913] = "Großchampion",
			[2139] = "Greifenherz",
			[2079] = "Stimme der Vernunft",
			[2136] = "Lichtbringer",
			[2075] = "Unsterblicher Erlöser",
		},
		[1] = 
		{
			[1810] = "Divayth Fyrs Gehilfin",
			[1838] = "Die Tick-Tack-Peinigerin",
			[1330] = "makellose Eroberin",
			[51] = "Monsterjägerin",
			[705] = "Großfeldherrin",
			[92] = "Freiwillige",
			[494] = "Meisteranglerin",
			[1391] = "dro-m'Athra-Zerstörerin",
			[628] = "Heldin Tamriels",
			[1910] = "Heldin der Eroberung",
			[1913] = "Großchampion",
		},
	},
	["en"] = 
	{
		[2] = 
		{
			[1810] = "Divayth Fyr's Coadjutor",
			[1838] = "Tick-Tock Tormentor",
			[1330] = "The Flawless Conqueror",
			[51] = "Monster Hunter",
			[705] = "Grand Overlord",
			[628] = "Tamriel Hero",
			[1391] = "Dro-m'Athra Destroyer",
			[494] = "Master Angler",
			[92] = "Volunteer",
			[1910] = "Conquering Hero",
			[1913] = "Grand Champion",
			[2079] = "Voice of Reason",
			[2075] = "Immortal Redeemer",
			[2139] = "Gryphon Heart",
			[2136] = "Bringer of Light",
		},
		[1] = 
		{
			[1810] = "Divayth Fyr's Coadjutor",
			[1838] = "Tick-Tock Tormentor",
			[1330] = "The Flawless Conqueror",
			[51] = "Monster Hunter",
			[705] = "Grand Overlord",
			[628] = "Tamriel Hero",
			[1391] = "Dro-m'Athra Destroyer",
			[494] = "Master Angler",
			[92] = "Volunteer",
			[1910] = "Conquering Hero",
			[1913] = "Grand Champion",

		},
	},
	["fr"] = 
	{
		[2] = 
		{
			[1810] = "Coadjuteur de Divayth Fyr",
			[1838] = "Tourmenteur des Tic-tac",
			[1330] = "Le conquérant implacable",
			[51] = "Chasseur de monstres",
			[705] = "Grand maréchal",
			[628] = "Héros de Tamriel",
			[1391] = "Destructeur des dro-m'Athra",
			[494] = "Maître de pêche",
			[92] = "Volontaire",
			[1910] = "Héros conquérant",
			[1913] = "Grand champion",
			[2075] = "Rédempteur immortel",
			[2139] = "Cœur-de-griffon",
			[2136] = "Porteur de lumière",
			[2079] = "Voix de la raison",


		},
		[1] = 
		{

			[1810] = "Coadjutrice de Divayth Fyr",
			[1838] = "Tourmenteuse des Tic-tac",
			[1330] = "La conquérante implacable",
			[51] = "Chasseuse de monstres",
			[1391] = "Destructrice des dro-m'Athra",
			[494] = "Maîtresse de pêche",
			[705] = "Grand maréchal",
			[628] = "Héroïne de Tamriel",
			[92] = "Volontaire",
			[1910] = "Héroïne conquérante",
			[1913] = "Grande championne",
		},
	},
}

local GetAchievementRewardTitle_original

local function Unload()
	GetAchievementRewardTitle = GetAchievementRewardTitle_original
end

local function Load()

	GetAchievementRewardTitle_original = GetAchievementRewardTitle
	GetAchievementRewardTitle = function(achievementId, gender)
		local hasTitle, title = GetAchievementRewardTitle_original(achievementId, gender)
		if (hasTitle and gender) then
			if (LocaleTitles[lang] and LocaleTitles[lang][gender] and LocaleTitles[lang][gender][achievementId]) then
				title = LocaleTitles[lang][gender][achievementId]
			end
		end
		return hasTitle, title
	end

	LibCustomTitles.Unload = Unload
end

if(LibCustomTitles.Unload) then LibCustomTitles.Unload() end
Load()
