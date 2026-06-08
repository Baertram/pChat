--[[
Ä = \195\132
ä = \195\164
Ö = \195\150
ö = \195\182
Ü = \195\156
ü = \195\188
ß = \195\159

2026-04-14 by lolo77777 (Github pull request)
]]--



-- New May Need Translations
-- ************************************************
-- Chat tab selector Bindings
-- ************************************************
SafeAddString(PCHAT_Tab1                ,"选择聊天标签 1",1)
SafeAddString(PCHAT_Tab2                ,"选择聊天标签 2",1)
SafeAddString(PCHAT_Tab3                ,"选择聊天标签 3",1)
SafeAddString(PCHAT_Tab4                ,"选择聊天标签 4",1)
SafeAddString(PCHAT_Tab5                ,"选择聊天标签 5",1)
SafeAddString(PCHAT_Tab6                ,"选择聊天标签 6",1)
SafeAddString(PCHAT_Tab7                ,"选择聊天标签 7",1)
SafeAddString(PCHAT_Tab8                ,"选择聊天标签 8",1)
SafeAddString(PCHAT_Tab9                ,"选择聊天标签 9",1)
SafeAddString(PCHAT_Tab10               ,"选择聊天标签 10",1)
SafeAddString(PCHAT_Tab11               ,"选择聊天标签 11",1)
SafeAddString(PCHAT_Tab12               ,"选择聊天标签 12",1)
-- 9.3.6.24 Additions
SafeAddString(PCHAT_CHATTABH                     ,"聊天标签设置",1)
SafeAddString(PCHAT_enableChatTabChannel         ,"每个标签启用最后一次使用的频道",1)
SafeAddString(PCHAT_enableChatTabChannelT        ,"开启聊天标签来记住最后一次使用的频道,它将成为默认的,直到你选择使用一个不同的标签。",1)
SafeAddString(PCHAT_enableWhisperTab             ,"开启私聊跳转",1)
SafeAddString(PCHAT_enableWhisperTabT            ,"开启将你的私聊转到一个特定的标签。",1)
SafeAddString(PCHAT_modifierKeyForNewChatTab     ,"SHIFT+左键新建聊天标签",1)
SafeAddString(PCHAT_modifierKeyForNewChatTab_TT  ,"按住SHIFT键并左键点击\"+\"图标来新建聊天标签(防止意外创建新标签)。",1)
SafeAddString(PCHAT_modifierKeyForNewChatTabButtonTT,"[pChat]按 SHIFT + 左键添加新聊天标签",1)
-- New Need Translations


SafeAddString(PCHAT_ADDON_INFO     ,"pChat大幅修改了文本在聊天框中显示的方式。你可以修改颜色, 尺寸, 通知, 播放声音等等。\nChatMentions插件已经被融合进pChat。\n使用slashcommand输入命令 /msg 来定义缩略聊天命令,以将您的长文本写入聊天框 (例如公会欢迎信息)",1)
SafeAddString(PCHAT_ADDON_INFO_2   ,"使用slash命令 \'/pchatdeleteoldsv\' 以删除老旧的聊天记录 (缩小聊天记录文件大小).",1)

SafeAddString(PCHAT_OPTIONSH                         ,"聊天设置",1)
SafeAddString(PCHAT_MESSAGEOPTIONSH                  ,"消息设置",1)
SafeAddString(PCHAT_MESSAGEOPTIONSNAMEH              ,"消息中的名字",1)
SafeAddString(PCHAT_MESSAGEOPTIONSNAME_ALLOTHERH     ,"所有其他聊天信息",1)
SafeAddString(PCHAT_MESSAGEOPTIONSCOLORH             ,"消息颜色",1)

SafeAddString(PCHAT_GUILDNUMBERS                     ,"公会数字",1)
SafeAddString(PCHAT_GUILDNUMBERSTT                   ,"在公会标签边上显示公会数字",1)

SafeAddString(PCHAT_ALLGUILDSSAMECOLOUR              ,"为所有公会使用相同颜色",1)
SafeAddString(PCHAT_ALLGUILDSSAMECOLOURTT            ,"所有公会聊天使用与 \'%s\' 一样的颜色",1)

SafeAddString(PCHAT_ALLZONESSAMECOLOUR               ,"为所有区域聊天使用相同颜色",1)
SafeAddString(PCHAT_ALLZONESSAMECOLOURTT             ,"所有区域聊天使用与 /zone 一样的颜色",1)

SafeAddString(PCHAT_ALLNPCSAMECOLOUR                 ,"为所有NPC使用相同颜色",1)
SafeAddString(PCHAT_ALLNPCSAMECOLOURTT               ,"所有NPC行使用与 NPC说 一样的颜色",1)

SafeAddString(PCHAT_DELZONETAGS                      ,"移除区域标签",1)
SafeAddString(PCHAT_DELZONETAGSTT                    ,"在消息开始处移除例如 说, 吆喝 等标签",1)

SafeAddString(PCHAT_ZONETAGSAY                       ,"说",1)
SafeAddString(PCHAT_ZONETAGYELL                      ,"吆喝",1)
SafeAddString(PCHAT_ZONETAGPARTY                     ,"队伍",1)
SafeAddString(PCHAT_ZONETAGZONE                      ,"区域",1)

SafeAddString(PCHAT_CARRIAGERETURN                   ,"名称和消息间换行",1)
SafeAddString(PCHAT_CARRIAGERETURNTT                 ,"玩家名和聊天文本之间用换行符分隔。",1)

SafeAddString(PCHAT_USEESOCOLORS                     ,"使用ESO颜色",1)
SafeAddString(PCHAT_USEESOCOLORSTT                   ,"使用在社交设置中所设置的颜色替代pChat颜色\n如果您启用这个设置,聊天频道颜色将不会被激活!",1)

SafeAddString(PCHAT_DIFFFORESOCOLORS                 ,"开启亮度差异",1)
SafeAddString(PCHAT_DIFFFORESOCOLORSTT               ,"按照此值调整所显示的玩家名称/区域与消息文本之间的亮度差异(名称会变暗/消息文本会变亮)。\n如果您启用选项\'每行使用同一种颜色\',此选项将失效!\n将滑块设置为0以禁用亮度差。",1)
SafeAddString(PCHAT_DIFFFORESOCOLORSDARKEN           ,"亮度差异：变暗",1)
SafeAddString(PCHAT_DIFFFORESOCOLORSDARKENTT         ,"按照此值变暗聊天名称",1)
SafeAddString(PCHAT_DIFFFORESOCOLORSLIGHTEN          ,"亮度差异：变亮",1)
SafeAddString(PCHAT_DIFFFORESOCOLORSLIGHTENTT        ,"按照此值变亮聊天文本",1)

SafeAddString(PCHAT_REMOVECOLORSFROMMESSAGES         ,"移除消息颜色",1)
SafeAddString(PCHAT_REMOVECOLORSFROMMESSAGESTT       ,"阻止人们使用彩色的文字",1)

SafeAddString(PCHAT_PREVENTCHATTEXTFADING            ,"防止聊天文字渐隐",1)
SafeAddString(PCHAT_PREVENTCHATTEXTFADINGTT          ,"防止聊天文字自动隐藏 (您可以在社交选项中设置防止聊天背景渐隐",1)
SafeAddString(PCHAT_CHATTEXTFADINGBEGIN	             ,"多少秒后开始文字渐隐",1)
SafeAddString(PCHAT_CHATTEXTFADINGBEGINTT	     ,"此秒数过后,开始渐隐文字",1)
SafeAddString(PCHAT_CHATTEXTFADINGDURATION	     ,"文字渐隐持续秒数",1)
SafeAddString(PCHAT_CHATTEXTFADINGDURATIONTT	     ,"文字渐隐将持续此秒数",1)


SafeAddString(PCHAT_AUGMENTHISTORYBUFFER             ,"增加聊天中显示的行数",1)
SafeAddString(PCHAT_AUGMENTHISTORYBUFFERTT           ,"默认情况下,聊天只显示最后200行。此功能将此值提升到1000行",1)

SafeAddString(PCHAT_USEONECOLORFORLINES              ,"每行使用同一种颜色",1)
SafeAddString(PCHAT_USEONECOLORFORLINESTT            ,"只使用第一种颜色（玩家颜色）,而不是每个频道都使用两种颜色",1)

SafeAddString(PCHAT_GUILDTAGSNEXTTOENTRYBOX          ,"输入框旁边的公会标签",1)
SafeAddString(PCHAT_GUILDTAGSNEXTTOENTRYBOXTT        ,"在你聊天输入框的边上显示公会标签替代公会名",1)

SafeAddString(PCHAT_DISABLEBRACKETS                  ,"删除名称周围的括号",1)
SafeAddString(PCHAT_DISABLEBRACKETSTT                ,"删除玩家名称周围的括号 []",1)

SafeAddString(PCHAT_DEFAULTCHANNEL                   ,"默认频道",1)
SafeAddString(PCHAT_DEFAULTCHANNELTT                 ,"选择登录时默认使用的频道",1)

SafeAddString(PCHAT_DEFAULTCHANNELCHOICE99           ,"不更改",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE31           ,"/zone",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE0            ,"/say",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE12           ,"/guild1",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE13           ,"/guild2",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE14           ,"/guild3",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE15           ,"/guild4",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE16           ,"/guild5",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE17           ,"/officer1",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE18           ,"/officer2",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE19           ,"/officer3",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE20           ,"/officer4",1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE21           ,"/officer5",1)

SafeAddString(PCHAT_GEOCHANNELSFORMAT                ,"名称格式",1)
SafeAddString(PCHAT_GEOCHANNELSFORMATTT              ,"本地频道 (说, 区域, 私聊) 使用的名称格式",1)

SafeAddString(PCHAT_DEFAULTTAB                       ,"默认标签",1)
SafeAddString(PCHAT_DEFAULTTABTT                     ,"选择启动时显示的默认标签",1)

SafeAddString(PCHAT_ADDCHANNELANDTARGETTOHISTORY     ,"使用箭头键切换频道",1)
SafeAddString(PCHAT_ADDCHANNELANDTARGETTOHISTORYTT   ,"当使用箭头键切换频道来匹配先前使用的频道。",1)

SafeAddString(PCHAT_URLHANDLING                      ,"侦测url和链接",1)
SafeAddString(PCHAT_URLHANDLINGTT                    ,"如果一条以 http(s):// 开头的URL在聊天中被链接,pChat将自动检测到它,你将能够通过点击它直接使用您的系统浏览器打开有关的链接。\n注意: ESO总是会先询问您是否想要打开外部链接。",1)

SafeAddString(PCHAT_ENABLECOPY                       ,"开启复制",1)
SafeAddString(PCHAT_ENABLECOPYTT                     ,"开启右击文本复制 - 同时开启左击频道切换。如果在聊天中显示链接出现问题,请禁用此选项",1)

-- Group Settings

SafeAddString(PCHAT_GROUPH                           ,"组队频道微调",1)

SafeAddString(PCHAT_ENABLEPARTYSWITCH                ,"自动切换：组队",1)
SafeAddString(PCHAT_ENABLEPARTYSWITCHTT              ,"开启组队切换将会在您加入队伍时自动将当前频道切换为组队频道,并在您离开队伍时切回您的默认频道。",1)

SafeAddString(PCHAT_ENABLEPARTYSWITCHPORTTODUNGEON   ,"自动切换：地牢/重载界面",1)
SafeAddString(PCHAT_ENABLEPARTYSWITCHPORTTODUNGEONTT ,"如你传送进入地牢/执行重载界面/登录且已经在队伍中等情况下,上面提到的自动切换也会将频道切换为 /party。\n此设置仅当组队切换开启时生效!",1)

SafeAddString(PCHAT_GROUPLEADER                      ,"队长特殊颜色",1)
SafeAddString(PCHAT_GROUPLEADERTT                    ,"开启此功能将允许你为队伍领袖的消息设置一个特殊颜色",1)

SafeAddString(PCHAT_GROUPLEADERCOLOR                 ,"队长名称颜色",1)
SafeAddString(PCHAT_GROUPLEADERCOLORTT               ,"队长名称颜色",1)

SafeAddString(PCHAT_GROUPLEADERCOLOR1                ,"队长消息颜色",1)
SafeAddString(PCHAT_GROUPLEADERCOLOR1TT              ,"队长消息的颜色。当\"使用ESO颜色\"选项开启时,此选项将被禁用。",1)

SafeAddString(PCHAT_GROUPNAMES                       ,"组队名称格式",1)
SafeAddString(PCHAT_GROUPNAMESTT                     ,"组队频道中您队友的名称格式",1)

-- Sync settings

SafeAddString(PCHAT_SYNCH                            ,"同步设置",1)

SafeAddString(PCHAT_CHATSYNCCONFIG                   ,"同步聊天配置",1)
SafeAddString(PCHAT_CHATSYNCCONFIGTT                 ,"如同步开启, 您所有的角色将获取相同的聊天配置 (颜色, 位置, 窗口大小, 标签)\n注意: 请配置好了所有自定义选项后再启用此选项!",1)

SafeAddString(PCHAT_CHATSYNCCONFIGIMPORTFROM         ,"导入聊天设置",1)
SafeAddString(PCHAT_CHATSYNCCONFIGIMPORTFROMTT       ,"您可以随时从其他角色导入聊天设置到本角色 (颜色, 位置, 窗口大小, 标签)",1)

-- Apparence

SafeAddString(PCHAT_APPARENCEMH                      ,"聊天窗口设置",1)

SafeAddString(PCHAT_WINDOWDARKNESS                   ,"聊天窗透明度",1)
SafeAddString(PCHAT_WINDOWDARKNESSTT                 ,"增加聊天窗口的暗化",1)

SafeAddString(PCHAT_CHATMINIMIZEDATLAUNCH            ,"启动时聊天最小化",1)
SafeAddString(PCHAT_CHATMINIMIZEDATLAUNCHTT          ,"游戏开始时最小化屏幕左侧的聊天窗口",1)

SafeAddString(PCHAT_CHATMINIMIZEDINMENUS             ,"在菜单中最小化聊天",1)
SafeAddString(PCHAT_CHATMINIMIZEDINMENUSTT           ,"当您打开菜单时,最小化屏幕左侧的聊天窗口 (公会, 状态, 制造, 等等)",1)

SafeAddString(PCHAT_CHATMINIMIZEDINMENUS_HALF             ,"仅在某些菜单中最小化聊天",1)
SafeAddString(PCHAT_CHATMINIMIZEDINMENUS_HALFTT           ,"仅在CP,设置菜单中最小化聊天",1)

SafeAddString(PCHAT_CHATMAXIMIZEDAFTERMENUS          ,"退出菜单后恢复聊天",1)
SafeAddString(PCHAT_CHATMAXIMIZEDAFTERMENUSTT        ,"总是在退出菜单后恢复聊天窗口",1)

SafeAddString(PCHAT_FONTCHANGE                       ,"聊天字体",1)
SafeAddString(PCHAT_FONTCHANGETT                     ,"设置聊天字体",1)

SafeAddString(PCHAT_TABWARNING                       ,"新消息提醒",1)
SafeAddString(PCHAT_TABWARNINGTT                     ,"设置标签名称的警告颜色",1)

-- Whisper settings

SafeAddString(PCHAT_IMH                              ,"私聊",1)

SafeAddString(PCHAT_SOUNDFORINCWHISPS                ,"收到私聊声音",1)
SafeAddString(PCHAT_SOUNDFORINCWHISPSTT              ,"选择收到私聊时播放的声音",1)

SafeAddString(PCHAT_NOTIFYIM                         ,"视觉通知",1)
SafeAddString(PCHAT_NOTIFYIMTT                       ,"如您错过一条私聊, 一个通知将出现在聊天的右上角,允许您快速访问它。另外, 如果当时你的聊天框被最小化了, 一个通知将显示在隐藏条上",1)

-- Restore chat settings

SafeAddString(PCHAT_RESTORECHATH                     ,"恢复聊天",1)
SafeAddString(PCHAT_RESTOREONRELOADUI                ,"重载界面之后",1)
SafeAddString(PCHAT_RESTOREONRELOADUITT              ,"在使用ReloadUI()重新载入游戏之后, pChat将恢复您的聊天和历史",1)

SafeAddString(PCHAT_RESTOREONLOGOUT                  ,"登出之后",1)
SafeAddString(PCHAT_RESTOREONLOGOUTTT                ,"登出之后, 如果您在下面所设置的时间内登录的话,pChat将恢复您的聊天和历史",1)

SafeAddString(PCHAT_RESTOREONAFK                     ,"被踢出之后",1)
SafeAddString(PCHAT_RESTOREONAFKTT                   ,"因挂机、内存溢出或网络问题被踢出游戏之后, 如果您在下面所设置的时间内登录的话,pChat将恢复您的聊天和历史",1)

SafeAddString(PCHAT_RESTOREONQUIT                    ,"离开游戏之后",1)
SafeAddString(PCHAT_RESTOREONQUITTT                  ,"离开游戏之后, 如果您在下面所设置的时间内登录的话,pChat将恢复您的聊天和历史",1)

SafeAddString(PCHAT_TIMEBEFORERESTORE                ,"恢复聊天的最大时间",1)
SafeAddString(PCHAT_TIMEBEFORERESTORETT              ,"超过此时间之后(小时), pChat将不再尝试恢复聊天",1)

SafeAddString(PCHAT_RESTORESYSTEM                    ,"恢复系统消息",1)
SafeAddString(PCHAT_RESTORESYSTEMTT                  ,"当恢复聊天时,恢复系统消息 (例如登录提醒或插件消息)",1)

SafeAddString(PCHAT_RESTORESYSTEMONLY                ,"只恢复系统消息",1)
SafeAddString(PCHAT_RESTORESYSTEMONLYTT              ,"当恢复聊天时,仅仅恢复系统消息 (例如登录提醒或插件消息)",1)

SafeAddString(PCHAT_RESTOREWHISPS                    ,"恢复私聊",1)
SafeAddString(PCHAT_RESTOREWHISPSTT                  ,"登出、掉线或退出之后恢复发出和收到的私聊。重载界面后将总是恢复私聊",1)

SafeAddString(PCHAT_RESTOREWHISPS_NO_NOTIFY          ,"恢复时关闭私聊通知",1)
SafeAddString(PCHAT_RESTOREWHISPS_NO_NOTIFY_TT       ,"被恢复的私聊信息不显示私聊提醒, 不着色聊天标签。\n仅当私聊通知被开启时可开启。",1)

SafeAddString(PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT        ,"恢复文本输入历史",1)
SafeAddString(PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT      ,"登出、掉线或退出之后使用箭头键恢复文本输入历史。重载界面后将总是恢复文本输入历史",1)

SafeAddString(PCHAT_RESTOREHISTORY_SHOWACTUALZONENAME        ,"[pChat]历史已恢复: %s in %s",1)
-- Anti Spam settings

SafeAddString(PCHAT_ANTISPAMH                        ,"反刷屏",1)

SafeAddString(PCHAT_FLOODPROTECT                     ,"开启抗刷屏",1)
SafeAddString(PCHAT_FLOODPROTECTTT                   ,"防止你附近的玩家重复发送相同的信息",1)

SafeAddString(PCHAT_FLOODGRACEPERIOD                 ,"抗刷屏持续时间",1)
SafeAddString(PCHAT_FLOODGRACEPERIODTT               ,"相同消息将被忽略的秒数",1)

SafeAddString(PCHAT_LOOKINGFORPROTECT                ,"忽略求组队消息",1)
SafeAddString(PCHAT_LOOKINGFORPROTECTTT              ,"忽略玩家求组队的信息",1)

SafeAddString(PCHAT_WANTTOPROTECT                    ,"忽略求交易消息",1)
SafeAddString(PCHAT_WANTTOPROTECTTT                  ,"忽略玩家寻求买卖交易的信息",1)

SafeAddString(PCHAT_WANTTOPROTECTWWANDVAMP           ,"忽略狼人吸血鬼交易消息",1)
SafeAddString(PCHAT_WANTTOPROTECTWWANDVAMPTT         ,"忽略玩家买卖狼人或吸血鬼咬的信息",1)

SafeAddString(PCHAT_WANTTOPROTECT_GOLDCROWNSSPAM                    ,"忽略皇冠金币交易消息",1)
SafeAddString(PCHAT_WANTTOPROTECT_GOLDCROWNSSPAMTT                  ,"忽略玩家寻求买卖皇冠和金币的信息",1)


SafeAddString(PCHAT_SPAMGRACEPERIOD                  ,"临时刷屏阻止",1)
SafeAddString(PCHAT_SPAMGRACEPERIODTT                ,"当你自己发布了一条求组队或交易信息时, 临时刷屏阻止此功能被改写, 给你一个时间来获取回答。功能会在所设置的时间之后自动生效 (以分钟记)",1)

-- Nicknames settings

SafeAddString(PCHAT_NICKNAMESH                       ,"简称",1)
SafeAddString(PCHAT_NICKNAMESD                       ,"你可以为想要的人设置简称, 输入 老名字,新名字 即可\n\n例如: @Ayantir,Little Blonde\n\n如果老名字是 @玩家ID 格式将替换该账号下所有角色,如果老名字是角色名的话则只替换指定角色。",1)
SafeAddString(PCHAT_NICKNAMES                        ,"简称清单",1)
SafeAddString(PCHAT_NICKNAMESTT                      ,"你可以为想要的人设置简称, 输入 老名字,新名字 即可\n\n例如: @Ayantir,Little Blonde\n\n如果老名字是 @玩家ID 格式将替换该账号下所有角色,如果老名字是角色名的话则只替换指定角色。",1)

-- Timestamp settings

SafeAddString(PCHAT_TIMESTAMPH                       ,"时间戳",1)

SafeAddString(PCHAT_ENABLETIMESTAMP                  ,"开启时间戳",1)
SafeAddString(PCHAT_ENABLETIMESTAMPTT                ,"为聊天消息添加时间戳",1)

SafeAddString(PCHAT_TIMESTAMPCOLORISLCOL             ,"时间戳颜色与玩家名相同",1)
SafeAddString(PCHAT_TIMESTAMPCOLORISLCOLTT           ,"忽略时间戳颜色并使用与玩家/NPC名称相同的颜色",1)

SafeAddString(PCHAT_TIMESTAMPFORMAT                  ,"时间戳格式",1)
SafeAddString(PCHAT_TIMESTAMPFORMATTT                ,"格式:\nHH: 小时(24)\nhh: 小时(12)\nH: 小时(24, 不含0)\nh: 小时(12, 不含0)\nA: AM/PM\na: am/pm\nm: 分钟\ns: 秒钟",1)

SafeAddString(PCHAT_TIMESTAMP                        ,"时间戳",1)
SafeAddString(PCHAT_TIMESTAMPTT                      ,"为时间戳设置颜色",1)

-- Guild settings
SafeAddString(PCHAT_GUILDH                           ,"公会微调",1)

SafeAddString(PCHAT_CHATCHANNELSH                    ,"聊天频道",1)

SafeAddString(PCHAT_NICKNAMEFOR                      ,"简称",1)
SafeAddString(PCHAT_NICKNAMEFORTT                    ,"设置简称",1)

SafeAddString(PCHAT_OFFICERTAG                       ,"官员聊天标签",1)
SafeAddString(PCHAT_OFFICERTAGTT                     ,"官员聊天频道前缀",1)

SafeAddString(PCHAT_SWITCHFOR                        ,"频道开关",1)
SafeAddString(PCHAT_SWITCHFORTT                      ,"频道的新开关。例如: /myguild",1)

SafeAddString(PCHAT_OFFICERSWITCHFOR                 ,"官员聊天开关",1)
SafeAddString(PCHAT_OFFICERSWITCHFORTT               ,"官员聊天频道的新开关。例如: /offs",1)

SafeAddString(PCHAT_NAMEFORMAT                       ,"名称格式",1)
SafeAddString(PCHAT_NAMEFORMATTT                     ,"选择公会成员名称格式",1)

SafeAddString(PCHAT_FORMATCHOICE1                    ,"@玩家ID",1)
SafeAddString(PCHAT_FORMATCHOICE2                    ,"角色名",1)
SafeAddString(PCHAT_FORMATCHOICE3                    ,"角色名@玩家ID",1)
SafeAddString(PCHAT_FORMATCHOICE4                    ,"@玩家ID/角色名",1)

SafeAddString(PCHAT_SETCOLORSFORTT                   ,"为<<1>>的成员设置颜色",1)
SafeAddString(PCHAT_SETCOLORSFORCHATTT               ,"为<<1>>的消息设置颜色",1)

SafeAddString(PCHAT_SETCOLORSFOROFFICIERSTT          ,"为<<1>>的官员聊天频道成员设置颜色",1)
SafeAddString(PCHAT_SETCOLORSFOROFFICIERSCHATTT      ,"为<<1>>的官员聊天频道消息设置颜色",1)

SafeAddString(PCHAT_MEMBERS                          ,"玩家名",1)
SafeAddString(PCHAT_CHAT                             ,"消息",1)

SafeAddString(PCHAT_OFFICERSTT                       ,"官员",1)

-- Channel colors settings

SafeAddString(PCHAT_CHATCOLORSH                      ,"聊天频道颜色",1)

SafeAddString(PCHAT_SAY                              ,"说 - 名称",1)
SafeAddString(PCHAT_SAYTT                            ,"为 说 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_SAYCHAT                          ,"说 - 信息",1)
SafeAddString(PCHAT_SAYCHATTT                        ,"为 说 频道设置聊天信息颜色",1)

SafeAddString(PCHAT_ZONE                             ,"区域 - 名称",1)
SafeAddString(PCHAT_ZONETT                           ,"为 区域 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_ZONECHAT                         ,"区域 - 信息",1)
SafeAddString(PCHAT_ZONECHATTT                       ,"为 区域 频道设置聊天信息颜色",1)

SafeAddString(PCHAT_YELL                             ,"吆喝 - 名称",1)
SafeAddString(PCHAT_YELLTT                           ,"为 吆喝 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_YELLCHAT                         ,"吆喝 - 信息",1)
SafeAddString(PCHAT_YELLCHATTT                       ,"为 吆喝 频道设置聊天信息颜色",1)

SafeAddString(PCHAT_INCOMINGWHISPERS                 ,"收到私聊 - 名称",1)
SafeAddString(PCHAT_INCOMINGWHISPERSTT               ,"为 收到私聊 设置玩家名称颜色",1)

SafeAddString(PCHAT_INCOMINGWHISPERSCHAT             ,"收到私聊 - 信息",1)
SafeAddString(PCHAT_INCOMINGWHISPERSCHATTT           ,"为 收到私聊 设置聊天信息颜色",1)

SafeAddString(PCHAT_OUTGOINGWHISPERS                 ,"发出私聊 - 名称",1)
SafeAddString(PCHAT_OUTGOINGWHISPERSTT               ,"为 发出私聊 设置玩家名称颜色",1)

SafeAddString(PCHAT_OUTGOINGWHISPERSCHAT             ,"发出私聊 - 信息",1)
SafeAddString(PCHAT_OUTGOINGWHISPERSCHATTT           ,"为 发出私聊 设置聊天信息颜色",1)

SafeAddString(PCHAT_GROUP                            ,"组队 - 名称",1)
SafeAddString(PCHAT_GROUPTT                          ,"为 组队聊天 设置玩家名称颜色",1)

SafeAddString(PCHAT_GROUPCHAT                        ,"组队 - 信息",1)
SafeAddString(PCHAT_GROUPCHATTT                      ,"为 组队聊天 设置聊天信息颜色",1)

-- Other colors

SafeAddString(PCHAT_OTHERCOLORSH                     ,"其他颜色",1)
SafeAddString(PCHAT_USEESOCOLORS_INFO                ,"如果选项 \'" .. GetString(PCHAT_USEESOCOLORS) .. "\' 已激活 (见子菜单 \'" .. GetString(PCHAT_MESSAGEOPTIONSCOLORH) .. "\')，以下颜色无法更改!",1)
SafeAddString(PCHAT_USEESOCOLORS_SUBMENU_INFO        ,GetString(PCHAT_USEESOCOLORS_INFO) .. "\n如果选项 \'" .. GetString(PCHAT_ALLZONESSAMECOLOUR) .. "\' 已激活 (见子菜单 \'" .. GetString(PCHAT_MESSAGEOPTIONSCOLORH) .. "\')，您无法单独更改各区域的颜色。\n如果选项 \'" .. GetString(PCHAT_USEONECOLORFORLINES) .. "\' 已激活，您无法单独更改玩家名称和聊天消息的颜色。",1)

SafeAddString(PCHAT_EMOTES                           ,"表情 - 名称",1)
SafeAddString(PCHAT_EMOTESTT                         ,"为 表情 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_EMOTESCHAT                       ,"表情 - 消息",1)
SafeAddString(PCHAT_EMOTESCHATTT                     ,"为 表情 频道设置聊天消息颜色",1)

SafeAddString(PCHAT_ENZONE                           ,"英语区域 - 名称",1)
SafeAddString(PCHAT_ENZONETT                         ,"为 英语区域 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_ENZONECHAT                       ,"英语区域 - 消息",1)
SafeAddString(PCHAT_ENZONECHATTT                     ,"为 英语区域 频道设置聊天消息颜色",1)

SafeAddString(PCHAT_FRZONE                           ,"法语区域 - 名称",1)
SafeAddString(PCHAT_FRZONETT                         ,"为 法语区域 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_FRZONECHAT                       ,"法语区域 - 消息",1)
SafeAddString(PCHAT_FRZONECHATTT                     ,"为 法语区域 频道设置聊天消息颜色",1)

SafeAddString(PCHAT_DEZONE                           ,"德语区域 - 名称",1)
SafeAddString(PCHAT_DEZONETT                         ,"为 德语区域 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_DEZONECHAT                       ,"德语区域 - 消息",1)
SafeAddString(PCHAT_DEZONECHATTT                     ,"为 德语区域 频道设置聊天消息颜色",1)

SafeAddString(PCHAT_JPZONE                           ,"日语区域 - 名称",1)
SafeAddString(PCHAT_JPZONETT                         ,"为 日语区域 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_JPZONECHAT                       ,"日语区域 - 消息",1)
SafeAddString(PCHAT_JPZONECHATTT                     ,"为 日语区域 频道设置聊天消息颜色",1)

SafeAddString(PCHAT_RUZONE                           ,"俄语区域 - 名称",1)
SafeAddString(PCHAT_RUZONETT                         ,"为 俄语区域 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_RUZONECHAT                       ,"俄语区域 - 消息",1)
SafeAddString(PCHAT_RUZONECHATTT                     ,"为 俄语区域 频道设置聊天消息颜色",1)

SafeAddString(PCHAT_ESZONE                           ,"西语区域 - 名称",1)
SafeAddString(PCHAT_ESZONETT                         ,"为 西语区域 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_ESZONECHAT                       ,"西语区域 - 消息",1)
SafeAddString(PCHAT_ESZONECHATTT                     ,"为 西语区域 频道设置聊天消息颜色",1)

SafeAddString(PCHAT_ZHZONE                           ,"中文区域 - 名称",1)
SafeAddString(PCHAT_ZHZONETT                         ,"为 中文区域 频道设置玩家名称颜色",1)

SafeAddString(PCHAT_ZHZONECHAT                       ,"中文区域 - 消息",1)
SafeAddString(PCHAT_ZHZONECHATTT                     ,"为 中文区域 频道设置聊天消息颜色",1)

SafeAddString(PCHAT_NPCSAY                           ,"NPC 说 - 名称",1)
SafeAddString(PCHAT_NPCSAYTT                         ,"为NPC 说 设置NPC名称颜色",1)

SafeAddString(PCHAT_NPCSAYCHAT                       ,"NPC 说 - 消息",1)
SafeAddString(PCHAT_NPCSAYCHATTT                     ,"为NPC 说 设置NPC聊天消息颜色",1)

SafeAddString(PCHAT_NPCYELL                          ,"NPC 吆喝 - 名称",1)
SafeAddString(PCHAT_NPCYELLTT                        ,"为NPC 吆喝 设置NPC名称颜色",1)

SafeAddString(PCHAT_NPCYELLCHAT                      ,"NPC 吆喝 - 消息",1)
SafeAddString(PCHAT_NPCYELLCHATTT                    ,"为NPC 吆喝 设置NPC聊天消息颜色",1)

SafeAddString(PCHAT_NPCWHISPER                       ,"NPC 私语 - 名称",1)
SafeAddString(PCHAT_NPCWHISPERTT                     ,"为NPC 私语 设置NPC名称颜色",1)

SafeAddString(PCHAT_NPCWHISPERCHAT                   ,"NPC 私语 - 消息",1)
SafeAddString(PCHAT_NPCWHISPERCHATTT                 ,"为NPC 私语 设置NPC聊天消息颜色",1)

SafeAddString(PCHAT_NPCEMOTES                        ,"NPC 表情 - 名称",1)
SafeAddString(PCHAT_NPCEMOTESTT                      ,"为NPC 表情 设置NPC名称颜色",1)

SafeAddString(PCHAT_NPCEMOTESCHAT                    ,"NPC 表情 - 消息",1)
SafeAddString(PCHAT_NPCEMOTESCHATTT                  ,"为NPC 表情 设置NPC聊天消息颜色",1)

-- Debug settings

SafeAddString(PCHAT_DEBUGH                           ,"调试",1)

SafeAddString(PCHAT_DEBUG                            ,"调试",1)
SafeAddString(PCHAT_DEBUGTT                          ,"调试",1)

-- Various strings not in panel settings

SafeAddString(PCHAT_UNDOCKTEXTENTRY                  ,"解锁文本输入",1)
SafeAddString(PCHAT_REDOCKTEXTENTRY                  ,"锁定文本输入",1)

SafeAddString(PCHAT_COPYXMLTITLE                     ,"使用Ctrl+C复制文本",1)
SafeAddString(PCHAT_COPYXMLLABEL                     ,"使用Ctrl+C复制文本",1)
SafeAddString(PCHAT_COPYXMLTOOLONG                   ,"被分段文本",1)
SafeAddString(PCHAT_COPYXMLPREV                      ,"上一个",1)
SafeAddString(PCHAT_COPYXMLNEXT                      ,"下一个",1)
SafeAddString(PCHAT_COPYXMLAPPLY                     ,"应用筛选器",1)

SafeAddString(PCHAT_COPYMESSAGECT                    ,"复制消息",1)
SafeAddString(PCHAT_COPYLINECT                       ,"复制行",1)
SafeAddString(PCHAT_COPYDISCUSSIONCT                 ,"复制频道聊天",1)
SafeAddString(PCHAT_ALLCT                            ,"复制全部聊天",1)

SafeAddString(PCHAT_SWITCHTONEXTTABBINDING           ,"切换到下一个标签",1)
SafeAddString(PCHAT_TOGGLECHATBINDING                ,"切出聊天窗口",1)
SafeAddString(PCHAT_WHISPMYTARGETBINDING             ,"私聊我的目标",1)
SafeAddString(PCHAT_COPYWHOLECHATBINDING	     ,"复制全部聊天 (对话)",1)

SafeAddString(PCHAT_SAVMSGERRALREADYEXISTS                ,"无法保存您的消息, 此条已经存在",1)
SafeAddString(PCHAT_AUTOMSG_NAME_DEFAULT_TEXT             ,"例如 : ts3",1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT          ,"当您使用自动信息功能时发送的文本",1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT             ,"新行将被自动删除",1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT             ,"当您认证消息 \"!nameOfMessage\"时此消息将被发送。(例如: |cFFFFFF!ts3|r)",1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT             ,"要在指定频道发送消息, 在消息开头加上它的开关 (例如: |cFFFFFF/g1|r)",1)
SafeAddString(PCHAT_AUTOMSG_NAME_HEADER                   ,"您的信息的缩写",1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_HEADER                ,"替换信息",1)
SafeAddString(PCHAT_AUTOMSG_ADD_TITLE_HEADER              ,"新自动信息",1)
SafeAddString(PCHAT_AUTOMSG_EDIT_TITLE_HEADER             ,"修改自动信息",1)
SafeAddString(PCHAT_AUTOMSG_ADD_AUTO_MSG                  ,"添加",1)
SafeAddString(PCHAT_AUTOMSG_EDIT_AUTO_MSG                 ,"编辑",1)
SafeAddString(PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG   ,"自动消息",1)
SafeAddString(PCHAT_AUTOMSG_REMOVE_AUTO_MSG               ,"移除",1)

SafeAddString(PCHAT_CLEARBUFFER                           ,"清除聊天",1)


--Added by Baertram
SafeAddString(PCHAT_RESTORED_PREFIX                       ,"[H]",1)
SafeAddString(PCHAT_RESTOREPREFIX                         ,"为被恢复的消息添加前缀",1)
SafeAddString(PCHAT_RESTOREPREFIXTT                       ,"为被恢复的消息添加一个前缀 \'[H]\' 以更易分辨恢复。\n需要重载界面后生效!\n前缀的颜色将使用标准ESO聊天频道颜色。",1)

SafeAddString(PCHAT_BUILT_IN_CHANNEL_SWITCH_WARNING       ,"不能使用现有的内置开关 '%s'",1)
SafeAddString(PCHAT_DUPLICATE_CHANNEL_SWITCH_WARNING      ,"试图替换现有的开关 '%s'",1)

SafeAddString(PCHAT_CHATHANDLERS                          ,"聊天格式处理器",1)
SafeAddString(PCHAT_CHATHANDLER_TEMPLATETT                ,"格式化事件\'%s\'的聊天信息。\n\n如果此设置被禁用,聊天信息将不会被各种pChat格式选项所改变(例如 颜色,时间戳,名称等)。",1)
SafeAddString(PCHAT_CHATHANDLER_SYSTEMMESSAGES            ,"系统消息",1)
SafeAddString(PCHAT_CHATHANDLER_PLAYERSTATUS              ,"玩家状态改变",1)
SafeAddString(PCHAT_CHATHANDLER_IGNORE_ADDED              ,"添加了忽略列表",1)
SafeAddString(PCHAT_CHATHANDLER_IGNORE_REMOVED            ,"移除了忽略列表",1)
SafeAddString(PCHAT_CHATHANDLER_GROUP_MEMBER_LEFT         ,"队员离开",1)
SafeAddString(PCHAT_CHATHANDLER_GROUP_TYPE_CHANGED        ,"队伍类型改变",1)
SafeAddString(PCHAT_CHATHANDLER_KEEP_ATTACK_UPDATE         ,"保持攻击更新",1)
SafeAddString(PCHAT_CHATHANDLER_PVP_KILL_FEED        ,"PVP击杀",1)
SafeAddString(PCHAT_SETTINGS_EDITBOX_HOOKS 		  ,"聊天编辑框",1)
SafeAddString(PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACE  ,"CTRL + backspace: 清除文字",1)
SafeAddString(PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACETT,"按 CTRL键 + BACKSPACE退格键 将删除光标左边的所有文字。",1)

SafeAddString(PCHAT_SETTINGS_BACKUP 			   ,"备份",1)
SafeAddString(PCHAT_SETTINGS_BACKUP_REMINDER_LAST_REMINDER ,"最后提醒: %s",1)
SafeAddString(PCHAT_SETTINGS_BACKUP_REMINDER 		   ,"备份提醒",1)
SafeAddString(PCHAT_SETTINGS_BACKUP_REMINDER_TT 	   ,"每周显示一次提醒,提醒您备份您的SavedVariables。如果检测到API版本增加,它将自动显示(例如游戏版本升级)。\n\n你总是应该在游戏版本升级之后,打开游戏客户端之前,备份你的整个SavedVariables文件夹!",1)
SafeAddString(PCHAT_SETTINGS_BACKUP_REMINDER_DIALOG_TEXT   ,"请|cFF0000!登出!|r并备份你的pChat SavedVariables!\n以下www.esoui.com链接解释了该如何做:\n\nhttps://www.esoui.com/forums/showthread.php?t,9235\n\n按下确认按钮,下个对话框将询问是否打开网站\n(如果你需要学习如何备份你的SavedVariables的话)。",1)
SafeAddString(PCHAT_SETTINGS_WARNING_REMINDER_LOGOUT_BEFORE,"记得先登出!",1)

SafeAddString(PCHAT_RESTORESHOWNAMEANDZONE,"恢复后：显示名称和区域",1)
SafeAddString(PCHAT_RESTORESHOWNAMEANDZONE_TT,"恢复聊天记录后,显示当前登录的帐户名称以及聊天中的角色名称和区域/地区。",1)

SafeAddString(PCHAT_CHATCONTEXTMENU,"聊天栏右键菜单",1)
SafeAddString(PCHAT_SHOWACCANDCHARATCONTEXTMENU,"复制菜单显示帐户名称/角色名称",1)
SafeAddString(PCHAT_SHOWACCANDCHARATCONTEXTMENU_TT,"在复制上下文菜单中显示@账号名/角色名。前提是已经为相应的聊天频道启用了@账号名/角色名标题！私聊频道将不会显示！",1)
SafeAddString(PCHAT_SHOWCHARLEVELATCONTEXTMENU,"复制菜单中显示角色等级",1)
SafeAddString(PCHAT_SHOWCHARLEVELATCONTEXTMENU_TT,"在复制右键菜单中显示角色等级，前提是启用了@账号名/角色名标题，允许在聊天消息中显示角色名称，并且该角色当前在线，位于您的队伍、公会或好友列表中时，此功能才有效！",1)
SafeAddString(PCHAT_SHOWIGNOREDWARNINGCONTEXTMENU		, "对于忽略的玩家显示额外的 \'!警告!\'",1)
SafeAddString(PCHAT_SHOWIGNOREDWARNINGCONTEXTMENUTT	, "如果玩家位于您的忽略列表中，则在聊天右键菜单中添加警告提示。",1)
SafeAddString(PCHAT_ASKBEFOREIGNORE 					, "对于忽略的玩家添加 是/否 对话框 \'忽略\'  (聊天, 好友, ...)",1)
SafeAddString(PCHAT_ASKBEFOREIGNORETT					, "在忽略玩家的右键菜单（如聊天窗口、好友列表等）中添加了一个带有“是/否”按钮的对话框，这样您就不会意外地忽略原本打算进行其他操作（例如，误点击了想要密语的玩家）的玩家。",1)
SafeAddString(PCHAT_SHOWSENDMAILCONTEXTMENU			, "添加 \'发送邮件\' 选项",1)
SafeAddString(PCHAT_SHOWSENDMAILCONTEXTMENUTT			, "在右键菜单中添加一个选项，直接向角色/帐户发送新邮件",1)
SafeAddString(PCHAT_SHOWTELEPORTTOCONTEXTMENU		, "添加传送到玩家的选项",1)
SafeAddString(PCHAT_SHOWTELEPORTTOCONTEXTMENUTT		, "右键菜单中显示一个传送到队友、公会成员或好友的选项。注意：这不适用于非好友、队友或公会成员的普通区域聊天玩家！",1)
SafeAddString(PCHAT_SHOWWHERECONTEXTMENU		, "显示玩家所在位置",1)
SafeAddString(PCHAT_SHOWWHERECONTEXTMENUTT		, "添加一个显示玩家当前位置的条目。\n注意：这不适用于非好友、队友或公会成员的普通区域聊天玩家！",1)
SafeAddString(PCHAT_CHATCONTEXTMENUTPTO,"传送到",1)
SafeAddString(PCHAT_CHATCONTEXTMENUTPFRIEND,"好友 %q",1)
SafeAddString(PCHAT_CHATCONTEXTMENUTPGUILD,"公会 #%s 成员 %q",1)
SafeAddString(PCHAT_CHATCONTEXTMENUTPGROUP,"队伍 成员 %q",1)
SafeAddString(PCHAT_CHATCONTEXTMENUTPGROUPLEADER,"队长",1)
SafeAddString(PCHAT_CHATCONTEXTMENUWARNIGNORE,"[|c00FF00!WARNING!|r] 你忽略了这名玩家!",1)
SafeAddString(PCHAT_CHATCONTEXTMENUTYPEFRIEND,"好友",1)
SafeAddString(PCHAT_TELEPORTINGTO,"传送到: ",1)

SafeAddString(PCHAT_TOGGLE_SEARCH_UI_ON, "开启搜索",1)
SafeAddString(PCHAT_TOGGLE_SEARCH_UI_OFF,"关闭搜索",1)
SafeAddString(PCHAT_SEARCHUI_HEADER_TIME,"时间",1)
SafeAddString(PCHAT_SEARCHUI_HEADER_FROM,"从",1)
SafeAddString(PCHAT_SEARCHUI_HEADER_CHATCHANNEL,"频道",1)
SafeAddString(PCHAT_SEARCHUI_HEADER_MESSAGE,"消息",1)
SafeAddString(PCHAT_SEARCHUI_MESSAGE_SEARCH_DEFAULT_TEXT,"输入 \'message\' 在这里搜索...",1)
SafeAddString(PCHAT_SEARCHUI_FROM_SEARCH_DEFAULT_TEXT,"输入 \'from\' 在这里搜索...",1)
SafeAddString(PCHAT_SEARCHUI_CLEAR_SEARCH_HISTORY,"清除搜索历史",1)
SafeAddString(PCHAT_SEARCHUI_ACCOUNT_SWITCHED,"搜索账号切换至 %q",1)
SafeAddString(PCHAT_RESTORESCHOOSEACCOUNT,"默认账号 (聊天搜索)",1)
SafeAddString(PCHAT_RESTORESCHOOSEACCOUNT_TT,"为聊天搜索界面下拉框选择默认账号。\n如果您选择" .. GetString(SI_ALLIANCE0) .. "将使用当前登录的账号(首次打开聊天搜索时),或最后选择的账号。\n聊天消息右键菜单仅使用当前登录的账号!",1)

SafeAddString(PCHAT_CHATSCROLLEDUPWARNING,"\'聊天已向上滚动\' 警告",1)
SafeAddString(PCHAT_CHATSCROLLEDUPWARNING_TT,"在\'滚动聊天到底部按钮\'处显示调整大小动画,以便您可以轻松注意到聊天已向上滚动,您可能会错过新传入的消息。",1)

-- Coorbin20200708
-- Chat Mentions settings strings
SafeAddString(PCHAT_MENTIONSH                                   ,"提及",1)
SafeAddString(PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_NAME 		,"当你的名字被提到时改变文本颜色?",1)
SafeAddString(PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_TOOLTIP	,"当提到您的名字时,是否更改文本颜色。",1)
SafeAddString(PCHAT_MENTIONS_TEXT_COLOR_PICKER_NAME		,"被提到时你名字的颜色",1)
SafeAddString(PCHAT_MENTIONS_ADD_EXCL_ICON_NAME			,"加感叹号图标?",1)
SafeAddString(PCHAT_MENTIONS_ADD_EXCL_ICON_TOOLTIP		,"当提到您的名字时,是否在开头添加感叹号图标。",1)
SafeAddString(PCHAT_MENTIONS_ALLCAPS_NAME			,"你的名字都用大写?",1)
SafeAddString(PCHAT_MENTIONS_ALLCAPS_TOOLTIP			,"当提到你的名字时,要不要用大写。",1)
SafeAddString(PCHAT_MENTIONS_EXTRA_NAMES_NAME			,"额外提示名称 (每个名称换行)",1)
SafeAddString(PCHAT_MENTIONS_EXTRA_NAMES_TOOLTIP		,"一个以换行符分隔的额外名称列表。按回车键以换行。如果你在希望被监听的自定义名称前加一个`!` (感叹号) , 将只会在该名称出现在单词边界时通知您。举个例子, 如果您添加'!de' 到额外列表中, 当监听到'de nada'时将通知您,但'delicatessen'则不会通知。如果您只是添加'de'到额外列表, 则'delicatessen'也会通知。",1)
SafeAddString(PCHAT_MENTIONS_SELFSEND_NAME			,"适用于您发送的消息?",1)
SafeAddString(PCHAT_MENTIONS_SELFSEND_TOOLTIP			,"是否对您所发送的消息应用格式。",1)
SafeAddString(PCHAT_MENTIONS_DING_NAME				,"声音提示?",1)
SafeAddString(PCHAT_MENTIONS_DING_TOOLTIP			,"当你的名字被提到时,是否要发出叮的声音。",1)
SafeAddString(PCHAT_MENTIONS_DING_SOUND_NAME		,"声音: ",1)
SafeAddString(PCHAT_MENTIONS_DING_SOUND_NAME_TOOLTIP	,"选择要播放的声音",1)
SafeAddString(PCHAT_MENTIONS_APPLYNAME_NAME			,"适用于你的角色名字?",1)
SafeAddString(PCHAT_MENTIONS_APPLYNAME_TOOLTIP			,"是否对你每个角色的名称(以空格分隔)应用格式。如果你在角色名中使用了非常常见的名字,比如“Me”,则请禁用它。",1)
SafeAddString(PCHAT_MENTIONS_WHOLEWORD_NAME			,"你的名字只进行完全匹配?",1)
SafeAddString(PCHAT_MENTIONS_WHOLEWORD_TOOLTIP			,"是否仅以全部字符匹配您的角色名。如果你的角色名很短,你可能需要打开它。",1)

-- Coorbin20211222
-- CharCount settings strings
SafeAddString(PCHAT_CHARCOUNTH ,"聊天窗标题",1)
SafeAddString(PCHAT_CHARCOUNT_ENABLE_CHECKBOX_NAME ,"显示字符计数",1)
SafeAddString(PCHAT_CHARCOUNT_ENABLE_CHECKBOX_TOOLTIP ,"显示当前输入到聊天文本框超过350的最大限制以外的字符数。它将出现在聊天窗口的顶部中心位置。",1)
SafeAddString(PCHAT_CHARCOUNT_ZONE_POST_TRACKER_NAME ,"显示区域发布追踪",1)
SafeAddString(PCHAT_CHARCOUNT_ZONE_POST_TRACKER_TOOLTIP ,"显示您最后一次在当前区域的区域聊天频道中发布内容的时间戳。当你改变区域时,时间会重置。对于在区域聊天频道中发布公告很有用。它将出现在聊天窗口的顶部中心位置。",1)
