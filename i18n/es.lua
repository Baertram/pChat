-- Vars with -H are headers, -TT are tooltips
--[[
pChat.lang.optionsH = "Opciones"

pChat.lang.guildnumbers = "Numerar gremios"
pChat.lang.guildnumbersTT = "Muestra el número de gremio al lado de su etiqueta"

pChat.lang.preventchattextfading = "Desactivar el desvanecimiento de texto del chat"
pChat.lang.preventchattextfadingTT = "Evita que el texto del chat desaparezca(puedes ajustar la transparencia de fondo bajo Opciones - Social)"

pChat.lang.timestampH = "Etiqueta horaria"

pChat.lang.enabletimestamp = "Activar etiquetas horarias"
pChat.lang.enabletimestampTT = "Añade una etiqueta horaria a los mensajes de texto"

pChat.lang.timestampcolorislcol = "Colorear la etiqueta horaria de igual forma que el interlocutor"
pChat.lang.timestampcolorislcolTT = "Ignora el color de la etiqueta horaria y la colorea igual al nombre del jugador o PNJ interlocutor"

pChat.lang.timestampformat = "Formato de etiqueta horaria"
pChat.lang.timestampformatTT = "FORMAT:\nHH: horas (24)\nhh: horas (12)\nH: hora (24, sin 0 de inicio)\nh: hora (12, sin 0 de inicio)\nA: AM/PM\na: am/pm\nm: minutos\ns: segundos"

pChat.lang.antispamH = "Anti-Spam"

pChat.lang.floodProtect = "Activar anti-flood"
pChat.lang.floodProtectTT = "Evita que los jugadores cerca de usted y no podrá enviar mensajes idénticos repetidos"

pChat.lang.floodGracePeriod = "Duración de destierro anti-flood"
pChat.lang.floodGracePeriodTT = "Número de segundos mientras se ignorará el mensaje idéntico anterior"

pChat.lang.lookingForProtect = "No haga caso de mensajes de agrupación"
pChat.lang.lookingForProtectTT = "No haga caso de los mensajes de los jugadores que buscan establecer / unirse a grupo"

pChat.lang.wantToProtect = "No haga caso de mensajes comerciales"
pChat.lang.wantToProtectTT = "No haga caso de los mensajes de los jugadores que buscan comprar, venta o canje"

pChat.lang.spamGracePeriod = "Detener temporalmente el correo no deseado"
pChat.lang.spamGracePeriodTT = "Cuando te haces un mensaje de grupo de investigación, o el comercio, el spam desactiva temporalmente la función que ha anulado el tiempo para tener una respuesta. Se reactiva automáticamente después de un período que se puede conectar (en minutos)"

pChat.lang.fontChange = "Fuente del texto"
pChat.lang.fontChangeTT = "Establecer la fuente del texto"

pChat.lang.defaultTab = "Default tab"
pChat.lang.defaultTabTT = "Select which tab to display at startup"

pChat.lang.addChannelAndTargetToHistory = "Switch channel when using history"
pChat.lang.addChannelAndTargetToHistoryTT = "Switch the channel when using arrow keys to match the channel previously used."

pChat.lang.urlHandling = "Detect and make URLs linkable"
pChat.lang.urlHandlingTT = "If a URL starting with http(s):// is linked in chat pChat will detect it and you'll be able to click on it to directly go on the concerned link with your system browser"

pChat.lang.enablecopy = "Activar copia"
pChat.lang.enablecopyTT = "Activar copia con un clic derecho sobre el texto - también activar el conmutador de canal con un clic izquierdo. Desactive esta opción si tienes problemas para visualizar los enlaces en el chat"

pChat.lang.switchToNextTabBinding = "Switch to next tab"
pChat.lang.toggleChatBinding = "Activar la ventana de charla"

pChat.lang.restoreChatH = "Restore chat"

pChat.lang.restoreOnReloadUI = "After a ReloadUI"
pChat.lang.restoreOnReloadUITT = "After reloading game with a ReloadUI(), pChat will restore your chat and its history"

pChat.lang.restoreOnLogOut = "After a LogOut"
pChat.lang.restoreOnLogOutTT = "After a logoff, pChat will restore your chat and its history if you login in the allotted time set under"

pChat.lang.restoreOnAFK = "After being kicked"
pChat.lang.restoreOnAFKTT = "After being kicked from game after inactivity, flood or a network disconnect, pChat will restore your chat and its history if you login in the allotted time set under"

pChat.lang.restoreOnQuit = "After leaving game"
pChat.lang.restoreOnQuitTT = "After leaving game, pChat will restore your chat and its history if you login in the allotted time set under"

pChat.lang.timeBeforeRestore = "Maximum time for restoring chat"
pChat.lang.timeBeforeRestoreTT = "After this time (in hours), pChat will not attempt to restore the chat"

pChat.lang.restoreSystem = "Restore System Messages"
pChat.lang.restoreSystemTT = "Restore System Messages (Such as login notifications or add ons messages) when chat is restored"

pChat.lang.restoreSystemOnly = "Restore Only System messages"
pChat.lang.restoreSystemOnlyTT = "Restore Only System Messages (Such as login notifications or add ons messages) when chat is restored"

pChat.lang.restoreWhisps = "Restore Whispers"
pChat.lang.restoreWhispsTT = "Restore whispers sent and received after logoff, disconnect or quit. Whispers are always restored after a ReloadUI()"

pChat.lang.restoreTextEntryHistoryAtLogOutQuit  = "Restore Text entry history"
pChat.lang.restoreTextEntryHistoryAtLogOutQuitTT  = "Restore Text entry history available with arrow keys after logoff, disconnect or quit. History of text entry is always restored after a ReloadUI()"

pChat.lang.guildtagsH = "Gremios"

pChat.lang.nicknamefor = "Nombre"
pChat.lang.nicknameforTT = "Nombre para "

pChat.lang.guildtagsnexttoentrybox = "Etiquetas de gremio en el cajón de escritura del chat"
pChat.lang.guildtagsnexttoentryboxTT = "Muestra la etiqueta del gremio en lugar del nombre en el cajón de escritura del chat"

pChat.lang.chatcolorsH = "Colores del chat"

pChat.lang.allGuildsSameColour = "Usar el mismo color para todos los gremios"
pChat.lang.allGuildsSameColourTT = "Colorea todos los gremios del mismo color que /guild1"

pChat.lang.allZonesSameColour = "Usar el mismo color para todos los chat de zona"
pChat.lang.allZonesSameColourTT = "Colorea todos los chats de zona del mismo color que /zone"

pChat.lang.allNPCSameColour = "Usar el mismo color para todas las lineas de PNJ"
pChat.lang.allNPCSameColourTT = "Hace que todo el texto de PNJs use el mismo color que PNJ /say"

pChat.lang.removecolorsfrommessages = "Eliminar mensajes coloreados"
pChat.lang.removecolorsfrommessagesTT = "Evita gente utilizando cosas como el texto de chat coloreado tipo arco-iris"

pChat.lang.enablepartyswitch = "Habilitar cambio automático al entrar en grupo"
pChat.lang.enablepartyswitchTT = "Habilitar el cambio automático cambiara tu canal de chat actual al canal de grupo al entrar en uno y lo restaurará al salir de el"

pChat.lang.groupLeader = "Special color for party leader"
pChat.lang.groupLeaderTT = "Enabling this feature will let you set a special color for party leader messages"

pChat.lang.groupNames = "Names format for groups"
pChat.lang.groupNamesTT = "Format of your groupmates names in party channel"

pChat.lang.groupNamesChoice = {}
pChat.lang.groupNamesChoice[1] = "@UserID"
pChat.lang.groupNamesChoice[2] = "Character Name"
pChat.lang.groupNamesChoice[3] = "Character Name@UserID"

pChat.lang.useonecolorforlines = "Usar un solo color"
pChat.lang.useonecolorforlinesTT = "En lugar de usar dos colores por canal, usa solo el primer color"

pChat.lang.delzonetags = "Desactiva las etiquetas de zona"
pChat.lang.delzonetagsTT = "Borra las etiquetas del tipo dice, grita al inicio del mensaje de chat"

pChat.lang.carriageReturn = "Player names and chat texts in seperate lines"
pChat.lang.carriageReturnTT = "Player names and chat texts are separated by a newline."

pChat.lang.IMH = "Susurros"

pChat.lang.soundforincwhisps = "Sonido para susurros entrantes"
pChat.lang.soundforincwhispsTT = "Elige un sonido a reproducir cuando recibas un susurro"

pChat.lang.notifyIM = "Visual notification"
pChat.lang.notifyIMTT = "If you miss a whisp, a notification will appear in the top right corner of the chat allowing you to quickly access to it. Plus, if your chat was minimized at that time, a notification will be displayed in the minibar"

pChat.lang.soundforincwhispschoice = {}
pChat.lang.soundforincwhispschoice[SOUNDS.NONE] = "Ninguno"
pChat.lang.soundforincwhispschoice[SOUNDS.NEW_NOTIFICATION] = "Notificación"
pChat.lang.soundforincwhispschoice[SOUNDS.DEFAULT_CLICK] = "Clic"
pChat.lang.soundforincwhispschoice[SOUNDS.EDIT_CLICK] = "Escritura"

pChat.lang.useESOcolors = "Usar colores de ESO"
pChat.lang.useESOcolorsTT = "Usa los colores seleccionados en las opciones sociales del juego en lugar de las de pChat"

pChat.lang.diffforESOcolors = "Diferencia entre los colores de ESO"
pChat.lang.diffforESOcolorsTT = "Si usas los colores de ESO y la opción dos colores de pChat, puedes ajustar la diferencia de brillo entre el nombre de jugador y el mensaje"

pChat.lang.officertag = "Etiqueta de canal de Oficial"
pChat.lang.officertagTT = "Prefijo para canales de Oficiales"

pChat.lang.defaultchannel = "Chat predeterminado"
pChat.lang.defaultchannelTT = "Selecciona el chat a usar al iniciar sesión"

pChat.lang.switchFor = "Switch for channel"
pChat.lang.switchForTT = "New switch for channel. Ex: /myguild"

pChat.lang.officerSwitchFor = "Switch for officer channel"
pChat.lang.officerSwitchForTT = "New switch for officer channel. Ex: /offs"

pChat.lang.defaultchannelchoice = {}
pChat.lang.defaultchannelchoice[PCHAT_CHANNEL_NONE] = "No cambiar"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_ZONE] = "/zone"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_SAY] = "/say"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_1] = "/guild1"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_2] = "/guild2"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_3] = "/guild3"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_4] = "/guild4"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_5] = "/guild5"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_1] = "/officer1"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_2] = "/officer2"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_3] = "/officer3"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_4] = "/officer4"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_5] = "/officer5"

pChat.lang.enablefastcopy = "Habilitar copia rápida"
pChat.lang.enablefastcopyTT = "Selecciona para habilitar la copia rápida de texto con clic derecho"

pChat.lang.fastcopychoice = "Acción para copia rápida"
pChat.lang.fastcopychoiceTT = "Selecciona que acción tomar cuando la copia rápida esta habilitada"

pChat.lang.CopyMessageCT = "Copiar mensaje"
pChat.lang.CopyLineCT = "Copiar linea"
pChat.lang.CopyDiscussionCT = "Copiar conversación de canal"
pChat.lang.AllCT = "Copiar chat completo"

pChat.lang.fastcopychoice1 = pChat.lang.CopyMessageCT
pChat.lang.fastcopychoice2 = pChat.lang.CopyLineCT
pChat.lang.fastcopychoice3 = pChat.lang.CopyDiscussionCT
pChat.lang.fastcopychoice4 = pChat.lang.AllCT

pChat.lang.disableBrackets = "Eliminar los corchetes de los nombres"
pChat.lang.disableBracketsTT = "Elimina los corchetes [] que rodean los nombres de jugadores"

pChat.lang.chatMinimizedAtLaunch = "Chat es minimizado en el arranque"
pChat.lang.chatMinimizedAtLaunchTT = "Minimizar la ventana de chat de la izquierda en el lanzamiento"

pChat.lang.chatMinimizedInMenus = "Chat es minimizado en menús"
pChat.lang.chatMinimizedInMenusTT = "Minimizar ventana de chat a la izquierda de la pantalla cuando usted entra en los menús (Gremio, Personaje, la artesanía, etc.)"

pChat.lang.chatMaximizedAfterMenus = "Restaurar chat después de salir de los menús"
pChat.lang.chatMaximizedAfterMenusTT = "Siempre restaurar la ventana de chat después de salir de los menús"

pChat.lang.chatSyncConfig = "Sincronizar la configuración del chat"
pChat.lang.chatSyncConfigTT = "Si la sincronización está habilitada, todos tus personajes tendrán la misma configuración del chat (color, orientación, tamaño de la ventana, pestañas) \ nPS: Seleccione esta opción cuando su chat configurado correctamente!"

pChat.lang.chatSyncConfigImportFrom = "Importar configuración del chat"
pChat.lang.chatSyncConfigImportFromTT = "Siempre se puede importar la configuración del chat instantánea de otro personaje (color, orientación, tamaño de la ventana, pestañas)"

pChat.lang.copyXMLTitle = "Copie el texto con Ctrl + C"
pChat.lang.copyXMLLabel = "Copie el texto con Ctrl + C"
pChat.lang.copyXMLTooLong = "El texto es demasiado largo y está dividido"
pChat.lang.copyXMLNext = "Siguiente"

pChat.lang.zonetagsay = "dice"
pChat.lang.zonetagyell = "grita"
pChat.lang.zonetagparty = "Grupo"
pChat.lang.zonetagzone = "zona"

pChat.lang.nameformat = "Formato de nombre"
pChat.lang.nameformatTT = "Selecciona como son presentados los nombres de miembros del gremio"

pChat.lang.formatchoice1 = "@IDUsuario"
pChat.lang.formatchoice2 = "Nombre del personaje"
pChat.lang.formatchoice3 = "Nombre del personaje@IDUsuario"

pChat.lang.say = "Dice - Jugador"
pChat.lang.sayTT = "Establece el color para el nombre del jugador en el canal principal"

pChat.lang.saychat = "Dice - Chat"
pChat.lang.saychatTT = "Establece el color del mensaje de chat para el canal principal"

pChat.lang.zone = "Zona - Jugador"
pChat.lang.zoneTT = "Establece el color para el nombre del jugador en el canal de zona"

pChat.lang.zonechat = "Zona - Chat"
pChat.lang.zonechatTT = "Establece el color del mensaje de chat para el canal de zona"

pChat.lang.yell = "Grito - Jugador"
pChat.lang.yellTT = "Establece el color para el nombre del jugador en el canal de gritos"

pChat.lang.yellchat = "Grito - Chat"
pChat.lang.yellchatTT = "Establece el color del mensaje de chat para el canal de gritos"

pChat.lang.incomingwhispers = "Susurros entrantes - Jugador"
pChat.lang.incomingwhispersTT = "Establece el color para el nombre del jugador en susurros entrantes"

pChat.lang.incomingwhisperschat = "Susurros entrantes - Chat"
pChat.lang.incomingwhisperschatTT = "Establece el color del mensaje de chat para susurros entrantes"

pChat.lang.outgoingwhispers = "Susurros salientes - Jugador"
pChat.lang.outgoingwhispersTT = "Establece el color para el nombre del jugador en susurros salientes"

pChat.lang.outgoingwhisperschat = "Susurros salientes - Chat"
pChat.lang.outgoingwhisperschatTT = "Establece el color del mensaje de chat para susurros salientes"

pChat.lang.group = "Grupo - Jugador"
pChat.lang.groupTT = "Establece el color para el nombre del jugador en el canal de grupo"

pChat.lang.groupchat = "Grupo - Chat"
pChat.lang.groupchatTT = "Establece el color del mensaje de chat para grupos"

pChat.lang.guildcolorsH = "Colores de gremio"

pChat.lang.setcolorsforTT = "Establecer colores para miembros de "
pChat.lang.setcolorsforchatTT = "Establecer colores para mensajes de "

pChat.lang.setcolorsforofficiersTT = "Establecer colores para miembro del chat de Oficiales de "
pChat.lang.setcolorsforofficierschatTT = "Establecer colores para mensajes del chat de Oficiales de "

pChat.lang.members = " - Jugadores"
pChat.lang.chat = " - Mensajes"

pChat.lang.officersTT = " Oficiales"

pChat.lang.othercolorsH = "Otros colores"

pChat.lang.tabwarning = "Alerta de mensaje nuevo"
pChat.lang.tabwarningTT = "Establece el color de alerta para pestañas del chat"

pChat.lang.emotes = "Emoticones - Jugador"
pChat.lang.emotesTT = "Establece el color para el jugador en emoticones"

pChat.lang.emoteschat = "Emoticones - Chat"
pChat.lang.emoteschatTT = "Establece el color de texto de los emoticones"

pChat.lang.enzone = "EN Zona - Jugador"
pChat.lang.enzoneTT = "Establece el color para el jugador en el canal de zona ingles"

pChat.lang.enzonechat = "EN Zona - Chat"
pChat.lang.enzonechatTT = "Establece el color de chat para el canal de zona ingles"

pChat.lang.frzone = "FR Zona - Jugador"
pChat.lang.frzoneTT = "Establece el color para el jugador en el canal de zona francés"

pChat.lang.frzonechat = "FR Zona - Chat"
pChat.lang.frzonechatTT = "Establece el color de chat para el canal de zona francés"

pChat.lang.dezone = "DE Zona - Jugador"
pChat.lang.dezoneTT = "Establece el color para el jugador en el canal de zona alemán"

pChat.lang.dezonechat = "DE Zona - Chat"
pChat.lang.dezonechatTT = "Establece el color de chat para el canal de zona alemán"

pChat.lang.npcsay = "PNJ Decir - Nombre PNJ"
pChat.lang.npcsayTT = "Establece el color para el nombre de PNJ"

pChat.lang.npcsaychat = "PNJ Decir - Chat"
pChat.lang.npcsaychatTT = "Establece el color para el mensaje de PNJs"

pChat.lang.npcyell = "PNJ Gritos - Nombre PNJ"
pChat.lang.npcyellTT = "Establece el color para el nombre de PNJ"

pChat.lang.npcyellchat = "PNJ Gritos - Chat"
pChat.lang.npcyellchatTT = "Establece el color del mensaje para gritos de PNJs"

pChat.lang.npcwhisper = "PNJ Susurros - Nombre PNJ"
pChat.lang.npcwhisperTT = "Establece el color para el nombre de PNJ"

pChat.lang.npcwhisperchat = "PNJ Susurros - Chat"
pChat.lang.npcwhisperchatTT = "Establece el color del mensaje para susurros de PNJs"

pChat.lang.npcemotes = "PNJ Emoticones - Nombre PNJ"
pChat.lang.npcemotesTT = "Establece el color para el nombre de PNJ"

pChat.lang.npcemoteschat = "PNJ Emoticones - Chat"
pChat.lang.npcemoteschatTT = "Establece el color del mensaje para emoticones de PNJs"

pChat.lang.timestamp = "Etiqueta horaria"
pChat.lang.timestampTT = "Establece el color para la etiqueta horaria"

pChat.lang.debugH = "Depuración"

pChat.lang.debug = "Depuración"
pChat.lang.debugTT = "Depuración"

pChat.lang.savMsgErrAlreadyExists = "Cannot save your message, this one already exists"
pChat.lang.PCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Example : ts3"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Write here the text which will be sent when you'll be using the auto message function"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Newlines will be automatically deleted"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "This message will be sent when you'll validate the message \"!nameOfMessage\". (ex: |cFFFFFF!ts3|r)"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "To send a message in a specified channel, add its switch at the begenning of the message (ex: |cFFFFFF/g1|r)"
pChat.lang.PCHAT_AUTOMSG_NAME_HEADER = "Abbreviation of your message"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_HEADER = "Substitution message"
pChat.lang.PCHAT_AUTOMSG_ADD_TITLE_HEADER = "New automated message"
pChat.lang.PCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modify automated message"
pChat.lang.PCHAT_AUTOMSG_ADD_AUTO_MSG = "Add"
pChat.lang.PCHAT_AUTOMSG_EDIT_AUTO_MSG = "Edit"
pChat.lang.SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG = "Automated messages"
pChat.lang.PCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Remove"

pChat.lang.clearBuffer = "Clear chat"
]]