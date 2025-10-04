-- Messages settings
local stringsES = {
-- New May Need Translations
	-- ************************************************
	-- Chat tab selector Bindings
	-- ************************************************
	PCHAT_Tab1 = "Seleccionar Pestaña Chat 1",
	PCHAT_Tab2 = "Seleccionar Pestaña Chat 2",
	PCHAT_Tab3 = "Seleccionar Pestaña Chat 3",
	PCHAT_Tab4 = "Seleccionar Pestaña Chat 4",
	PCHAT_Tab5 = "Seleccionar Pestaña Chat 5",
	PCHAT_Tab6 = "Seleccionar Pestaña Chat 6",
	PCHAT_Tab7 = "Seleccionar Pestaña Chat 7",
	PCHAT_Tab8 = "Seleccionar Pestaña Chat 8",
	PCHAT_Tab9 = "Seleccionar Pestaña Chat 9",
	PCHAT_Tab10 = "Seleccionar Pestaña Chat 10",
	PCHAT_Tab11 = "Seleccionar Pestaña Chat 11",
	PCHAT_Tab12 = "Seleccionar Pestaña Chat 12",
	-- 9.3.6.24 Additions
	PCHAT_CHATTABH = "Ajustes Pestaña de Chat",
	PCHAT_enableChatTabChannel = "Habilitar Último Canal Usado por Pestaña",
	PCHAT_enableChatTabChannelT = "Habilite las pestañas de chat para recordar el último canal utilizado; se convertirá en el predeterminado hasta que opte por utilizar uno diferente en esa pestaña.",
	PCHAT_enableWhisperTab = "Habilitar Redirección de Susurro",
	PCHAT_enableWhisperTabT = "Habilite la redirección de sus susurros a una pestaña específica.",
	
-- New Need Translations


	PCHAT_ADDON_INFO = "pChat revisa la forma en que se muestra el texto en el cuadro de chat. Puedes cambiar colores, tamaños, notificaciones, reproducir sonidos, etc.\nEl complemento ChatMentions está integrado en pChat.\nUtiliza el comando de barra /msg para definir comandos de chat cortos que escribirán tu oración en el chat (por ejemplo, mensajes de bienvenida del gremio).\nUtiliza el comando de barra /pchats <texto opcional> para abrir la búsqueda de chat.",
	PCHAT_ADDON_INFO_2 = "Utilice el comando de barra diagonal \'/pchatdeleteoldsv\' para eliminar variables guardadas antiguas que no dependen del servidor (reducir el tamaño del archivo SV).",

	PCHAT_OPTIONSH = "Ajustes Chat",
	PCHAT_MESSAGEOPTIONSH = "Ajustes Mensaje",
	PCHAT_MESSAGEOPTIONSNAMEH = "Nombre en los mensajes",
	PCHAT_MESSAGEOPTIONSNAME_ALLOTHERH = "Todos los demás mensajes de chat",
	PCHAT_MESSAGEOPTIONSCOLORH = "Color de los mensajes",

	PCHAT_GUILDNUMBERS = "Números de gremio",
	PCHAT_GUILDNUMBERSTT = "Muestra el número de gremio al lado de su etiqueta",

	PCHAT_ALLGUILDSSAMECOLOUR = "Igual color para todos los gremios",
	PCHAT_ALLGUILDSSAMECOLOURTT = "Hace que todos los chats del gremio usen el mismo color que \'%s\'",

	PCHAT_ALLZONESSAMECOLOUR = "Igual color para todas las zonas",
	PCHAT_ALLZONESSAMECOLOURTT = "Hace que todos los chats de zona usen el mismo color que /zone",

	PCHAT_ALLNPCSAMECOLOUR = "Igual color para todos los NPC",
	PCHAT_ALLNPCSAMECOLOURTT = "Hace que todas las líneas de NPC usen el mismo color que el NPC, por ejemplo.",

	PCHAT_DELZONETAGS = "Eliminar etiquetas de zona",
	PCHAT_DELZONETAGSTT = "Eliminar etiquetas como dice, grita al principio del mensaje",

	PCHAT_ZONETAGSAY = "dice",
	PCHAT_ZONETAGYELL = "grita",
	PCHAT_ZONETAGPARTY = "Grupo",
	PCHAT_ZONETAGZONE = "Zona",

	PCHAT_CARRIAGERETURN = "Nombre y mensaje en líneas separadas",
	PCHAT_CARRIAGERETURNTT = "Los nombres de los jugadores y los textos del chat están separados por una nueva línea.",

	PCHAT_USEESOCOLORS = "Usar colores ESO",
	PCHAT_USEESOCOLORSTT = "Utilice los colores establecidos en la configuración social en lugar de los de pChat.\nSi habilita esta configuración, los colores del canal de chat no se activarán!",

	PCHAT_DIFFFORESOCOLORS = "Habilitar diferencia de brillo",
	PCHAT_DIFFFORESOCOLORSTT = "Ajuste la diferencia de brillo entre el nombre/zona del jugador y el texto del mensaje mostrado por este valor (el nombre se oscurecerá / el texto del mensaje se volverá más brillante).\n¡Esta opción no funciona si habilita la opción \'Usar un color para las líneas\'!\nEstablezca el control deslizante en 0 para desactivar la diferencia de brillo.",
	PCHAT_DIFFFORESOCOLORSDARKEN = "Diferencia de brillo: Oscurecer",
	PCHAT_DIFFFORESOCOLORSDARKENTT = "Oscurezca el nombre del chat con este valor.",
	PCHAT_DIFFFORESOCOLORSLIGHTEN = "Diferencia de brillo: Aclarar",
	PCHAT_DIFFFORESOCOLORSLIGHTENTT = "Ilumina el texto del chat con este valor.",

	PCHAT_REMOVECOLORSFROMMESSAGES = "Eliminar colores de los mensajes",
	PCHAT_REMOVECOLORSFROMMESSAGESTT = "Evita que la gente use cosas como texto con colores del arcoíris.",

	PCHAT_PREVENTCHATTEXTFADING = "Evitar que el texto del chat se desvanezca",
	PCHAT_PREVENTCHATTEXTFADINGTT = "Evita que el texto del chat se desvanezca (puedes evitar que el fondo se desvanezca en la 'Configuración de la ventana de chat')",
	PCHAT_CHATTEXTFADINGBEGIN = "El texto comienza a desvanecerse después de segundos",
	PCHAT_CHATTEXTFADINGBEGINTT = "Desvanecer el texto después de que pasen estos segundos",
	PCHAT_CHATTEXTFADINGDURATION = "Duración desvanecimiento del texto en segundos",
	PCHAT_CHATTEXTFADINGDURATIONTT = "Desvanecer el texto tomando esta duración en segundos",


	PCHAT_AUGMENTHISTORYBUFFER = "Aumentar # de lineas mostradas en chat",
	PCHAT_AUGMENTHISTORYBUFFERTT = "De forma predeterminada, solo se muestran las últimas 200 líneas en el chat. Esta función aumenta este valor hasta 1000 líneas.",

	PCHAT_USEONECOLORFORLINES = "Usar un color para las líneas",
	PCHAT_USEONECOLORFORLINESTT = "En lugar de tener dos colores por canal, use solo el primer color (el color del jugador)",

	PCHAT_GUILDTAGSNEXTTOENTRYBOX = "Etiquetas de gremio junto al cuadro de texto",
	PCHAT_GUILDTAGSNEXTTOENTRYBOXTT = "Mostrar la etiqueta del gremio en lugar del nombre del gremio a la izquierda del cuadro de entrada de texto del chat",

	PCHAT_DISABLEBRACKETS = "Eliminar corchetes alrededor de nombres",
	PCHAT_DISABLEBRACKETSTT = "Elimina los corchetes [] alrededor de los nombres de los jugadores",

	PCHAT_DEFAULTCHANNEL = "Canal predeterminado",
	PCHAT_DEFAULTCHANNELTT = "Seleccione qué canal utilizar al iniciar sesión",

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

	PCHAT_GEOCHANNELSFORMAT = "Formato de nombres",
	PCHAT_GEOCHANNELSFORMATTT = "Formato de nombres para canales locales (say, zone, tell)",

	PCHAT_DEFAULTTAB = "Pestaña predeterminada",
	PCHAT_DEFAULTTABTT = "Seleccione qué pestaña desea mostrar al inicio",

	PCHAT_ADDCHANNELANDTARGETTOHISTORY = "Cambiar de canal usando teclas de flecha",
	PCHAT_ADDCHANNELANDTARGETTOHISTORYTT = "Cambie el canal al utilizar las teclas de flecha para que coincida con el canal utilizado anteriormente.",

	PCHAT_URLHANDLING = "Detectar URLs/links",
	PCHAT_URLHANDLINGTT = "Si una URL que comienza con http(s):// está vinculada en un chat, pChat la detectará y podrá hacer clic en ella para abrir directamente el enlace con el navegador web estándar configurado en su sistema.\nAtención: ESO siempre le preguntará si desea abrir el enlace externo primero.",

	PCHAT_ENABLECOPY = "Habilitar copiar",
	PCHAT_ENABLECOPYTT = "Habilitar copiar con clic derecho en el texto. También habilitar el cambio de canal con clic izquierdo. Deshabilita esta opción si tienes problemas para mostrar enlaces en el chat.",

	-- Group Settings

	PCHAT_GROUPH = "Ajustes del Grupo",

	PCHAT_ENABLEPARTYSWITCH = "Cambio automático de canal: grupo",
	PCHAT_ENABLEPARTYSWITCHTT = "Al habilitar el cambio de grupo, cambiará su canal actual a grupo cuando se una a un grupo y volverá a su canal predeterminado cuando salga de un grupo.",

	PCHAT_ENABLEPARTYSWITCHPORTTODUNGEON 	= "Cambio automático: dungeon/reloadui",
	PCHAT_ENABLEPARTYSWITCHPORTTODUNGEONTT 	= "El cambio de grupo mencionado anteriormente también cambiará el canal de chat a /grupo si te transportas a una mazmorra/realizas una recarga de interfaz/inicias sesión + estás agrupado.\n¡Esta configuración solo estará disponible si el cambio de grupo está habilitado!",

	PCHAT_GROUPLEADER = "Color especial para líder de Grupo",
	PCHAT_GROUPLEADERTT = "Al habilitar esta función, podrá establecer un color especial para los mensajes del líder del grupo.",

	PCHAT_GROUPLEADERCOLOR = "Color del nombre del líder",
	PCHAT_GROUPLEADERCOLORTT = "Color del nombre del líder del grupo.",

	PCHAT_GROUPLEADERCOLOR1 = "Color del mensaje del líder",
	PCHAT_GROUPLEADERCOLOR1TT = "Color del mensaje para el líder del grupo Si \"Usar colores ESO\" está activado, esta opción se desactivará.",

	PCHAT_GROUPNAMES = "Formato de nombres para grupos",
	PCHAT_GROUPNAMESTT = "Formato de los nombres de tus compañeros en el canal de grupo",

	-- Sync settings

	PCHAT_SYNCH = "Ajustes de sincronización",

	PCHAT_CHATSYNCCONFIG = "Configuración del chat de sincronización: todo igual",
	PCHAT_CHATSYNCCONFIGTT = "Si la sincronización está habilitada, todos tus personajes tendrán la misma configuración de chat (colores, posición, dimensiones de la ventana, pestañas).\nPD: ¡Solo habilita esta opción después de que tu chat esté completamente personalizado!\n\nSi esta configuración está habilitada, la configuración de chat de los últimos personajes que iniciaron sesión se guardará y el próximo personaje que inicie sesión cargará esta configuración, y así sucesivamente...",

	PCHAT_CHATSYNCCONFIGIMPORTFROM = "Importar la configuración del chat desde",
	PCHAT_CHATSYNCCONFIGIMPORTFROMTT = "Puedes importar la configuración del chat de otro personaje (colores, posición, dimensiones de la ventana, pestañas) en cualquier momento.\n\nAtención: Debes haber iniciado sesión con el otro personaje del que quieres copiar la configuración del chat, configurarlo correctamente y luego usar /reloadui para guardarlo en SaveVariables.\nDespués, vuelve a iniciar sesión con los otros personajes a los que quieres copiar la configuración de ese personaje previamente configurado. Selecciona ese personaje previamente configurado en el menú desplegable.\nEsto solo copiará la configuración de chat GUARDADA del personaje seleccionado en el momento en que selecciones la opción del menú desplegable.\nNo se copiará la configuración de nuevo en cada siguiente recarga/inicio de sesión.\nSi quieres copiar la configuración actualizada (después de cambiar la configuración del chat del personaje base de la copia), debes volver a seleccionar la opción del menú desplegable.",

	-- Apparence

	PCHAT_APPARENCEMH = "Ajustes de la ventana de chat",

	PCHAT_WINDOWDARKNESS = "Oscuridad en la ventana de chat",
	PCHAT_WINDOWDARKNESSTT = "Aumenta el oscurecimiento de la ventana de chat. 0 = Transparente/1 = Predeterminado/2 a 11 = más oscuridad. ¡Afectará tanto a la ventana de chat activa como a la inactiva!",

	PCHAT_CHATMINIMIZEDATLAUNCH = "Chat minimizado al inicio",
	PCHAT_CHATMINIMIZEDATLAUNCHTT = "Minimizar la ventana de chat en el lado izquierdo de la pantalla cuando se inicia el juego",

	PCHAT_CHATMINIMIZEDINMENUS = "Chat minimizado en todos los menús",
	PCHAT_CHATMINIMIZEDINMENUSTT = "Minimizar la ventana de chat al ingresar a los menús (Gremio, Estadísticas, Elaboración, Inventario, etc.)",

	PCHAT_CHATMINIMIZEDINMENUS_HALF = "Solo minimizar en algunos menús",
	PCHAT_CHATMINIMIZEDINMENUS_HALFTT = "No minimices la ventana de chat en todos los menús, sino solo en algunos de ellos (por ejemplo, Puntos de campeón, configuraciones).",

	PCHAT_CHATMAXIMIZEDAFTERMENUS = "Restaurar el chat después de salir de los menús",
	PCHAT_CHATMAXIMIZEDAFTERMENUSTT = "Restaurar siempre la ventana de chat después de salir de los menús",

	PCHAT_FONTCHANGE = "Fuente de Chat",
	PCHAT_FONTCHANGETT = "Establecer la Fuente del Chat",

	PCHAT_TABWARNING = "Advertencia de mensaje nuevo",
	PCHAT_TABWARNINGTT = "Establecer el color de advertencia para el nombre de la pestaña",

	-- Whisper settings

	PCHAT_IMH = "Susurros",

	PCHAT_SOUNDFORINCWHISPS = "Sonido para inc. whisps",
	PCHAT_SOUNDFORINCWHISPSTT = "Elige el sonido que se reproducirá cuando recibas un susurro",

	PCHAT_NOTIFYIM = "Notificación visual",
	PCHAT_NOTIFYIMTT = "Si te pierdes un mensaje, aparecerá una notificación en la esquina superior derecha del chat para que puedas acceder rápidamente. Además, si tu chat estaba minimizado en ese momento, se mostrará una notificación en el minibar.",

	-- Restore chat settings

	PCHAT_RESTORECHATH = "Restaurar chat",

	PCHAT_RESTOREONRELOADUI = "Despues de ReloadUI",
	PCHAT_RESTOREONRELOADUITT = "Después de recargar el juego con ReloadUI(), pChat restaurará tu chat y su historial.",

	PCHAT_RESTOREONLOGOUT = "Despues de Cerrar sesión",
	PCHAT_RESTOREONLOGOUTTT = "Después de cerrar sesión, pChat restaurará su chat y su historial si inicia sesión en el tiempo asignado establecido en",

	PCHAT_RESTOREONAFK = "Después de ser expulsado",
	PCHAT_RESTOREONAFKTT = "Después de ser expulsado del juego debido a inactividad, inundación o una desconexión de la red, pChat restaurará su chat y su historial si inicia sesión en el tiempo asignado establecido en",

	PCHAT_RESTOREONQUIT = "Después de salir del juego",
	PCHAT_RESTOREONQUITTT = "Después de salir del juego, pChat restaurará tu chat y su historial si inicias sesión en el tiempo asignado establecido en",

	PCHAT_TIMEBEFORERESTORE = "Tiempo máximo para restaurar el chat",
	PCHAT_TIMEBEFORERESTORETT = "Después de este tiempo (en horas), pChat no intentará restaurar el chat.",

	PCHAT_RESTORESYSTEM = "Restaurar Mensajes del Sistema",
	PCHAT_RESTORESYSTEMTT = "Restaurar mensajes del sistema (como notificaciones de inicio de sesión o mensajes de complementos) cuando se restablece el chat",

	PCHAT_RESTORESYSTEMONLY = "Restaurar Solo Mensajes del Sistema",
	PCHAT_RESTORESYSTEMONLYTT = "Restaurar solo los mensajes del sistema (como notificaciones de inicio de sesión o mensajes de complementos) cuando se restablezca el chat",

	PCHAT_RESTOREWHISPS = "Restaurar Susurros",
	PCHAT_RESTOREWHISPSTT = "Restaurar los susurros enviados y recibidos tras cerrar sesión, desconectarse o salir. Los susurros siempre se restauran después de una operación ReloadUI().",

	PCHAT_RESTOREWHISPS_NO_NOTIFY = "No hay notificación de susurro al restaurar",
	PCHAT_RESTOREWHISPS_NO_NOTIFY_TT = "No mostrar las notificaciones de susurro y no colorear la pestaña de chat para los mensajes de susurro restaurados.\nSolo se puede habilitar si las notificaciones de susurro están habilitadas.",

	PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT  = "Restaurar Historial de Entrada de Texto",
	PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT  = "Restaurar el historial de entrada de texto está disponible con las flechas después de cerrar sesión, desconectarse o salir. El historial de entrada de texto siempre se restaura después de ReloadUI()",

	PCHAT_RESTOREHISTORY_SHOWACTUALZONENAME = "[pChat]Historial restaurado: %s en %s",

	-- Anti Spam settings

	PCHAT_ANTISPAMH = "Anti-Spam",

	PCHAT_FLOODPROTECT = "Habilitar anti-flood",
	PCHAT_FLOODPROTECTTT = "Evita que los jugadores cercanos a ti envíen mensajes idénticos y repetidos",

	PCHAT_FLOODGRACEPERIOD = "Duración de anti-flood",
	PCHAT_FLOODGRACEPERIODTT = "Número de segundos que el mensaje idéntico anterior será ignorado",

	PCHAT_LOOKINGFORPROTECT = "Ignorar mensajes de Agrupación",
	PCHAT_LOOKINGFORPROTECTTT = "Ignorar los mensajes de los jugadores que buscan establecer / unirse a un grupo",

	PCHAT_WANTTOPROTECT = "Ignorar mensajes Comerciales",
	PCHAT_WANTTOPROTECTTT = "Ignorar los mensajes de jugadores que buscan comprar, vender o intercambiar",

	PCHAT_WANTTOPROTECTWWANDVAMP = "Ignorar mensajes Comerciales de Hombre Lobo y Vampiro",
	PCHAT_WANTTOPROTECTWWANDVAMPTT = "Ignorar los mensajes de jugadores que venden o compran mordeduras de hombre lobo o vampiro.",

	PCHAT_WANTTOPROTECT_GOLDCROWNSSPAM = "Ignorar los mensajes de Oro y Coronas",
	PCHAT_WANTTOPROTECT_GOLDCROWNSSPAMTT = "Ignora los mensajes de jugadores que buscan vender coronas por oro",


	PCHAT_SPAMGRACEPERIOD = "Detener temporalmente el spam",
	PCHAT_SPAMGRACEPERIODTT = "Al enviar un mensaje o intercambio a un grupo de investigación, la función de spam desactiva temporalmente la función que has anulado para obtener una respuesta. Se reactiva automáticamente después de un periodo configurable (en minutos)",

	-- Nicknames settings

	PCHAT_NICKNAMESH = "Apodos",
	PCHAT_NICKNAMESD = "Puedes agregar apodos para las personas que quieras, solo escribe OldName = Newname\n\nPor ejemplo: @Ayantir = Little Blonde\nCambiará el nombre de todas las cuentas si OldName es un @UserID o solo el Personaje especificado si OldName es un Nombre de Personaje.",
	PCHAT_NICKNAMES = "Lista de Apodos",
	PCHAT_NICKNAMESTT = "Puedes agregar apodos para las personas que quieras, solo escribe OldName = Newname\n\nPor ejemplo: @Ayantir = Little Blonde\n\nCambiará el nombre de todas las cuentas si OldName es un @UserID o solo el Personaje especificado si OldName es un nombre de personaje.",

	-- Timestamp settings

	PCHAT_TIMESTAMPH = "Marca de Tiempo",

	PCHAT_ENABLETIMESTAMP = "Habilitar marca de tiempo",
	PCHAT_ENABLETIMESTAMPTT = "Agrega una marca de tiempo a los mensajes de chat",

	PCHAT_TIMESTAMPCOLORISLCOL = "Color de marca de tiempo igual que el jugador",
	PCHAT_TIMESTAMPCOLORISLCOLTT = "Ignora el color de la marca de tiempo y colorea la marca de tiempo igual que el nombre del jugador/PNJ",

	PCHAT_TIMESTAMPFORMAT = "Formato de marca de tiempo",
	PCHAT_TIMESTAMPFORMATTT = "FORMAT:\nHH: hours (24)\nhh: hours (12)\nH: hour (24, no leading 0)\nh: hour (12, no leading 0)\nA: AM/PM\na: am/pm\nm: minutes\ns: seconds\nxy: milliseconds",

	PCHAT_TIMESTAMP = "Marca de Tiempo",
	PCHAT_TIMESTAMPTT = "Establecer color para la marca de tiempo",

	-- Guild settings
	PCHAT_GUILDH = "Ajustes del Gremio",

	PCHAT_CHATCHANNELSH = "Canales de chat",

	PCHAT_NICKNAMEFOR = "Apodo",
	PCHAT_NICKNAMEFORTT = "Apodo para ",

	PCHAT_OFFICERTAG = "Etiqueta Chat del Oficial",
	PCHAT_OFFICERTAGTT = "Prefijo chats de oficiales",

	PCHAT_SWITCHFOR = "Atajo de Canal",
	PCHAT_SWITCHFORTT = "Nuevo Atajo para canal. Ej: /myguild",

	PCHAT_OFFICERSWITCHFOR = "Atajo para canal de oficiales",
	PCHAT_OFFICERSWITCHFORTT = "Nuevo Atajo para canal de oficiales. Ex: /offs",

	PCHAT_NAMEFORMAT = "Formato de nombre",
	PCHAT_NAMEFORMATTT = "Seleccionar formato de nombres de los miembros del gremio",

	PCHAT_FORMATCHOICE1 = "@UserID",
	PCHAT_FORMATCHOICE2 = "Nombre Personaje",
	PCHAT_FORMATCHOICE3 = "Nombre Personaje@UserID",
	PCHAT_FORMATCHOICE4 = "@UserID/Nombre Personaje",

	PCHAT_SETCOLORSFORTT = "Establecer colores para los miembros de <<1>>",
	PCHAT_SETCOLORSFORCHATTT = "Establecer colores para los mensajes de <<1>>",

	PCHAT_SETCOLORSFOROFFICIERSTT = "Establecer colores de miembros del chat de Oficiales de <<1>>",
	PCHAT_SETCOLORSFOROFFICIERSCHATTT = "Establecer colores de mensajes del chat de oficiales <<1>>",

	PCHAT_MEMBERS = "Nombre de jugador",
	PCHAT_CHAT = "Mensaje",

	PCHAT_OFFICERSTT = " Oficial",

	-- Channel colors settings

	PCHAT_CHATCOLORSH = "Colores del canal de chat",

	PCHAT_SAY = "Say - nombre",
	PCHAT_SAYTT = "Establecer el color del nombre del jugador para canal Say",

	PCHAT_SAYCHAT = "Say - mensaje",
	PCHAT_SAYCHATTT = "Establecer el color del mensaje de chat para el canal Say",

	PCHAT_ZONE = "Zona - nombre",
	PCHAT_ZONETT = "Establecer el color del nombre del jugador para el canal de Zona",

	PCHAT_ZONECHAT = "Zona - mensaje",
	PCHAT_ZONECHATTT = "Establecer el color del mensaje de chat para el canal de Zona",

	PCHAT_YELL = "Yell - nombre",
	PCHAT_YELLTT = "Establecer el color del nombre del jugador del canal Yell",

	PCHAT_YELLCHAT = "Yell - mensaje",
	PCHAT_YELLCHATTT = "Establecer el color del mensaje de chat para el canal Yell",

	PCHAT_INCOMINGWHISPERS = "Susurros entrantes - nombre",
	PCHAT_INCOMINGWHISPERSTT = "Establecer el color del nombre del jugador para los susurros entrantes",

	PCHAT_INCOMINGWHISPERSCHAT = "Susurros entrantes - mensaje",
	PCHAT_INCOMINGWHISPERSCHATTT = "Establecer el color del mensaje de chat para los susurros entrantes",

	PCHAT_OUTGOINGWHISPERS = "Susurros salientes - nombre",
	PCHAT_OUTGOINGWHISPERSTT = "Establecer el color del nombre del jugador para los susurros salientes",

	PCHAT_OUTGOINGWHISPERSCHAT = "Susurros salientes - mensaje",
	PCHAT_OUTGOINGWHISPERSCHATTT = "Establecer el color del mensaje de chat para los susurros salientes",

	PCHAT_GROUP = "Grupo - nombre",
	PCHAT_GROUPTT = "Establecer el color del nombre del jugador para el chat de grupo",

	PCHAT_GROUPCHAT = "Grupo - mensaje",
	PCHAT_GROUPCHATTT = "Establecer el color del mensaje para el chat de grupo",

	-- Other colors

	PCHAT_OTHERCOLORSH = "Otros Colores",
	PCHAT_USEESOCOLORS_INFO = "Si la opción \'" .. GetString(PCHAT_USEESOCOLORS) .."\' está activada (ver submenú \'" .. GetString(PCHAT_MESSAGEOPTIONSCOLORH) .."\') los colores a continuación no se pueden cambiar!",
	PCHAT_USEESOCOLORS_SUBMENU_INFO = GetString(PCHAT_USEESOCOLORS_INFO) .. "\nSi la opción \'" .. GetString(PCHAT_ALLZONESSAMECOLOUR) .."\' está activada (ver submenú \'" .. GetString(PCHAT_MESSAGEOPTIONSCOLORH) .."\'), no se pueden cambiar los colores de las zonas individualmente.\nSi la opción \'" .. GetString(PCHAT_USEONECOLORFORLINES) .. "\' está activada, no puedes cambiar el color del jugador y el mensaje de chat individualmente.",

	PCHAT_EMOTES = "Emotes - nombre",
	PCHAT_EMOTESTT = "Establecer el color del nombre del jugador para los emotes",

	PCHAT_EMOTESCHAT = "Emotes - mensaje",
	PCHAT_EMOTESCHATTT = "Establecer el color del mensaje de chat para los emotes",

	PCHAT_ENZONE = "EN Zona - Nombre",
	PCHAT_ENZONETT = "Establecer el color del nombre del jugador para el canal de la zona Inglesa",

	PCHAT_ENZONECHAT = "EN Zona - mensaje",
	PCHAT_ENZONECHATTT = "Establecer el color del mensaje de chat para el canal de la zona en inglés",

	PCHAT_FRZONE = "FR Zona - nombre",
	PCHAT_FRZONETT = "Establecer el color del nombre del jugador para el canal de la zona francesa",

	PCHAT_FRZONECHAT = "FR Zona - mensaje",
	PCHAT_FRZONECHATTT = "Establecer el color del mensaje de chat para el canal de la zona francesa",

	PCHAT_DEZONE = "DE Zona - nombre",
	PCHAT_DEZONETT = "Establecer el color del nombre del jugador para el canal de la zona alemana",

	PCHAT_DEZONECHAT = "DE Zona - mensaje",
	PCHAT_DEZONECHATTT = "Establecer el color del mensaje de chat para el canal de la zona alemana",

	PCHAT_JPZONE = "JP Zona - nombre",
	PCHAT_JPZONETT = "Establecer el color del nombre del jugador para el canal de la zona japonesa",

	PCHAT_JPZONECHAT = "JP Zona - mensaje",
	PCHAT_JPZONECHATTT = "Establecer el color del mensaje de chat para el canal de la zona japonesa",

	PCHAT_RUZONE = "RU Zona - nombre",
	PCHAT_RUZONETT = "Establecer el color del nombre del jugador para el canal de la zona rusa",

	PCHAT_RUZONECHAT = "RU Zona - mensaje",
	PCHAT_RUZONECHATTT = "Establecer el color del mensaje de chat para el canal de la zona rusa",

	PCHAT_ESZONE = "ES Zona - nombre",
	PCHAT_ESZONETT = "Establecer el color del nombre del jugador para el canal de la zona española",

	PCHAT_ESZONECHAT = "ES Zona - mensaje",
	PCHAT_ESZONECHATTT = "Establecer el color del mensaje de chat para el canal de la zona española",

	PCHAT_ZHZONE = "ZH Zona - nombre",
	PCHAT_ZHZONETT = "Establecer el color del nombre del jugador para el canal de la zona china",

	PCHAT_ZHZONECHAT = "ZH Zona - mensaje",
	PCHAT_ZHZONECHATTT = "Establecer el color del mensaje de chat para el canal de la zona china",

	PCHAT_NPCSAY = "NPC Say - nombre",
	PCHAT_NPCSAYTT = "Establecer el color del nombre del NPC para NPC say",

	PCHAT_NPCSAYCHAT = "NPC Say - mensaje",
	PCHAT_NPCSAYCHATTT = "Set NPC chat message color for NPC say",

	PCHAT_NPCYELL = "NPC Yell - nombre",
	PCHAT_NPCYELLTT = "Set NPC name color for NPC yell",

	PCHAT_NPCYELLCHAT = "NPC Yell - mensaje",
	PCHAT_NPCYELLCHATTT = "Set NPC chat message color for NPC yell",

	PCHAT_NPCWHISPER = "NPC Whisper - nombre",
	PCHAT_NPCWHISPERTT = "Set NPC name color for NPC whisper",

	PCHAT_NPCWHISPERCHAT = "NPC Whisper - mensaje",
	PCHAT_NPCWHISPERCHATTT = "Set NPC chat message color for NPC whisper",

	PCHAT_NPCEMOTES = "NPC Emotes - nombre",
	PCHAT_NPCEMOTESTT = "Set NPC name color for NPC emotes",

	PCHAT_NPCEMOTESCHAT = "NPC Emotes - mensaje",
	PCHAT_NPCEMOTESCHATTT = "Set NPC chat message color for NPC emotes",

	-- Debug settings

	PCHAT_DEBUGH = "Debug",

	PCHAT_DEBUG = "Debug",
	PCHAT_DEBUGTT = "Debug",

	-- Various strings not in panel settings

	PCHAT_UNDOCKTEXTENTRY = "Desacoplar entrada de texto",
	PCHAT_REDOCKTEXTENTRY = "Reacoplar entrada de texto",

	PCHAT_COPYXMLTITLE = "Copiar el texto del chat",
	PCHAT_COPYXMLLABEL = "Seleccione texto y copie con Ctrl+C",
	PCHAT_COPYXMLTOOLONG = "Seleccione texto y copie con Ctrl+C",
	PCHAT_COPYXMLPREV = "Prev",
	PCHAT_COPYXMLNEXT = "Next",
	PCHAT_COPYXMLAPPLY = "Aplicar filtro",

	PCHAT_COPYMESSAGECT = "Copiar mensaje",
	PCHAT_COPYLINECT = "Copiar línea",
	PCHAT_COPYDISCUSSIONCT = "Copiar canal de conversación",
	PCHAT_ALLCT = "Copiar todo el chat",

	PCHAT_SWITCHTONEXTTABBINDING = "Cambiar a siguiente pestaña",
	PCHAT_TOGGLECHATBINDING = "Toggle Chat Window",
	PCHAT_WHISPMYTARGETBINDING = "Susurra a mi objetivo",
	PCHAT_COPYWHOLECHATBINDING = "Copiar todo el chat (diálogo)",

	PCHAT_SAVMSGERRALREADYEXISTS = "No se puede guardar tu mensaje, éste ya existe",
	PCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Ejemplo : ts3",
	PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Escribe aquí el texto que se enviará cuando uses la función de mensaje automático",
	PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Las nuevas líneas se eliminarán automáticamente",
	PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "Este mensaje se enviará cuando valides el mensaje \"!nameOfMessage\". (ej: |cFFFFFF!ts3|r)",
	PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "Para enviar un mensaje en un canal específico, agregue su modificador al comienzo del mensaje (ej: |cFFFFFF/g1|r)",
	PCHAT_AUTOMSG_NAME_HEADER = "Abreviatura de tu mensaje",
	PCHAT_AUTOMSG_MESSAGE_HEADER = "Mensaje de sustitución",
	PCHAT_AUTOMSG_ADD_TITLE_HEADER = "Nuevo mensaje automatizado",
	PCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modificar mensaje automatizado",
	PCHAT_AUTOMSG_ADD_AUTO_MSG = "Add",
	PCHAT_AUTOMSG_EDIT_AUTO_MSG = "Edit",
	PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG = "Mensajes automatizados",
	PCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Eliminar",

	PCHAT_CLEARBUFFER = "Vaciar chat",


	--Added by Baertram
	PCHAT_RESTORED_PREFIX = "[H]",
	PCHAT_RESTOREPREFIX = "Agregar prefijo a los mensajes restaurados",
	PCHAT_RESTOREPREFIXTT = "Agregue un prefijo \'[H]\' a los mensajes restaurados para ver fácilmente que fueron restaurados.\n¡Esto afectará al chat actual solo después de recargar la interfaz de usuario!\nEl color del prefijo se mostrará con los colores del canal de chat estándar de ESO.",

	PCHAT_BUILT_IN_CHANNEL_SWITCH_WARNING = "No se puede utilizar el switch integrado existente '%s'",
	PCHAT_DUPLICATE_CHANNEL_SWITCH_WARNING = "ntenté reemplazar el switch ya existente '%s'",

	PCHAT_CHATHANDLERS = "Controladores de formato de chat",
	PCHAT_CHATHANDLER_TEMPLATETT = "Formatear los mensajes de chat del evento \'%s\'.\n\nSi esta configuración está deshabilitada, los mensajes de chat no se cambiarán con las diferentes opciones de formato de pChat (por ejemplo, colores, marcas de tiempo, nombres, etc.)",
	PCHAT_CHATHANDLER_SYSTEMMESSAGES = "Mensajes del sistema",
	PCHAT_CHATHANDLER_PLAYERSTATUS = "El estado del jugador cambió",
	PCHAT_CHATHANDLER_IGNORE_ADDED = "Lista de ignorados añadida",
	PCHAT_CHATHANDLER_IGNORE_REMOVED = "Lista de ignorados eliminada",
	PCHAT_CHATHANDLER_GROUP_MEMBER_LEFT = "Miembro del grupo se fue",
	PCHAT_CHATHANDLER_GROUP_TYPE_CHANGED = "El tipo de grupo cambió",
	PCHAT_CHATHANDLER_KEEP_ATTACK_UPDATE = "Mantener actualizado ataque",
	PCHAT_CHATHANDLER_PVP_KILL_FEED = "Info Kills PVP",

	PCHAT_SETTINGS_EDITBOX_HOOKS 					= "Chat editbox",
	PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACE 		= "CTRL + backspace: Eliminar palabra",
	PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACETT 	= "Al presionar la tecla CTRL + la tecla RETROCESO se eliminará toda la palabra a la izquierda del cursor.",

	PCHAT_SETTINGS_BACKUP 							= "Backup",
	PCHAT_SETTINGS_BACKUP_REMINDER_LAST_REMINDER 	= "Último recordatorio: %s",
	PCHAT_SETTINGS_BACKUP_REMINDER 					= "Backup recordatorio",
	PCHAT_SETTINGS_BACKUP_REMINDER_TT 				= "Muestra un recordatorio para hacer una copia de seguridad de tus variables guardadas una vez a la semana. Se mostrará automáticamente si se detectó un aumento en la versión de la API (por ejemplo, debido a un parche del juego).\n\nSiempre debes hacer una copia de seguridad de toda tu carpeta de variables guardadas después de un parche del juego, ANTES de iniciar el cliente!",
	PCHAT_SETTINGS_BACKUP_REMINDER_DIALOG_TEXT		= "Por favor, cierre la sesión y haga una copia de seguridad de sus variables guardadas de pChat.\nEl siguiente enlace en www.esoui.com explica cómo hacerlo:\n\nhttps://www.esoui.com/forums/showthread.php?t=9235\n\nSimplemente presione el botón de confirmación y el siguiente cuadro de diálogo que se muestra le pedirá que abra el sitio web\n(si necesita aprender cómo hacer una copia de seguridad de sus variables guardadas).",
	PCHAT_SETTINGS_WARNING_REMINDER_LOGOUT_BEFORE	= "¡Recuerde Cerrar Sesión primero!",

	PCHAT_RESTORESHOWNAMEANDZONE = "Después de restaurar: Mostrar nombre y zona",
	PCHAT_RESTORESHOWNAMEANDZONE_TT = "Mostrar la cuenta actualmente conectada @Account - Nombre del personaje y zona/área en el chat, después de restaurar el historial de chat.",


	PCHAT_CHATCONTEXTMENU = "Menú contextual del chat",
	PCHAT_SHOWACCANDCHARATCONTEXTMENU = "@Account/Charname en el menú contextual",
	PCHAT_SHOWACCANDCHARATCONTEXTMENU_TT = "Muestra @AccountName/Charname en el menú contextual de copia.\n¡Esto solo mostrará ambos si has habilitado el formato de nombre de ese canal de chat para mostrar ambos también!\n¡Y algunos canales de chat como Whisper no proporcionan ambos!",
	PCHAT_SHOWCHARLEVELATCONTEXTMENU = "Nivel de personaje en el menú contextual",
	PCHAT_SHOWCHARLEVELATCONTEXTMENU_TT = "Muestra el nivel del personaje en el menú contextual de copia.\nSolo funciona si el título @AccountName/CharName está activado, el nombre del personaje está habilitado para mostrarse en los mensajes de chat y el personaje está actualmente en línea en tu grupo, gremio o lista de amigos.",
	PCHAT_SHOWIGNOREDWARNINGCONTEXTMENU		= "Mostrar 'ADVERTENCIA!' adicional para los jugadores ignorados",
	PCHAT_SHOWIGNOREDWARNINGCONTEXTMENUTT	= 'Agrega una entrada de texto de advertencia al menú contextual del chat si el jugador está en tu lista de ignorados.',
	PCHAT_ASKBEFOREIGNORE 					= "Agregar diálogo de yes/no para 'Ignorar' jugadores (chat, amigos, ...)",
	PCHAT_ASKBEFOREIGNORETT					= "Agrega un diálogo con botones de yes/no al menú contextual Ignorar jugador (en el chat, lista de amigos, etc.) para que no ignores accidentalmente a un jugador al que querías susurrar (clic incorrecto)",
	PCHAT_SHOWSENDMAILCONTEXTMENU			= "Añadir entrada \'Send mail\'",
	PCHAT_SHOWSENDMAILCONTEXTMENUTT			= "Añade una entrada al menú contextual del chat que crea directamente un nuevo correo para el personaje/cuenta",
	PCHAT_SHOWTELEPORTTOCONTEXTMENU		= "Agregar entrada para teletransportarse al jugador",
	PCHAT_SHOWTELEPORTTOCONTEXTMENUTT		= "Mostrar entradas del menú contextual para teletransportarse a miembros del grupo, compañeros de gremio o amigos.\nAtención: ¡Esto no puede funcionar con jugadores del chat de zona normal que no sean amigos, compañeros de grupo o de gremio!",

	PCHAT_SHOWWHERECONTEXTMENU =		"Mostrar dónde está el jugador",
	PCHAT_SHOWWHERECONTEXTMENUTT =		"Añade una entrada que muestre dónde se encuentra actualmente el jugador.\nAtención: ¡Esto no puede funcionar con jugadores del chat de zona normal que no sean amigos, compañeros de grupo o de gremio!",

	PCHAT_CHATCONTEXTMENUTPTO = "Teletransportarse a",
	PCHAT_CHATCONTEXTMENUTPFRIEND = "Amigo %q",
	PCHAT_CHATCONTEXTMENUTPGUILD = "Guild #%s member %q",
	PCHAT_CHATCONTEXTMENUTPGROUP = "Miembro del grupo %q",
	PCHAT_CHATCONTEXTMENUTPGROUPLEADER = "Líder de grupo",
	PCHAT_CHATCONTEXTMENUWARNIGNORE = "[|c00FF00!ADVERTENCIA!|r] Ignoras a este jugador!",
	PCHAT_CHATCONTEXTMENUTYPEFRIEND = "Amigo",
	PCHAT_TELEPORTINGTO = "Teletransportarse a: ",

	PCHAT_TOGGLE_SEARCH_UI_ON= "Buscar ON",
	PCHAT_TOGGLE_SEARCH_UI_OFF = "Buscar OFF",
	PCHAT_SEARCHUI_HEADER_TIME = "Tiempo",
	PCHAT_SEARCHUI_HEADER_FROM = "De",
	PCHAT_SEARCHUI_HEADER_CHATCHANNEL = "Canal",
	PCHAT_SEARCHUI_HEADER_MESSAGE = "Mensaje",
	PCHAT_SEARCHUI_MESSAGE_SEARCH_DEFAULT_TEXT = "Introducir \'mensaje\' a buscar aquí...",
	PCHAT_SEARCHUI_FROM_SEARCH_DEFAULT_TEXT = "Introducir \'de\' a buscar aquí...",
	PCHAT_SEARCHUI_CLEAR_SEARCH_HISTORY = "Borrar el historial de búsqueda",
	PCHAT_SEARCHUI_ACCOUNT_SWITCHED = "La cuenta de búsqueda cambió a %q",

	-- Coorbin20200708
	-- Chat Mentions settings strings
	PCHAT_MENTIONSH = "Menciones",
	PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_NAME = "Cambiar el color del texto cuando se menciona tu nombre",
	PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_TOOLTIP = "Si desea cambiar o no el color del texto cuando se menciona su nombre.",
	PCHAT_MENTIONS_TEXT_COLOR_PICKER_NAME = "Color de tu nombre cuando lo mencionan",
	PCHAT_MENTIONS_ADD_EXCL_ICON_NAME = "Añadir icono de exclamación",
	PCHAT_MENTIONS_ADD_EXCL_ICON_TOOLTIP = "Si desea o no agregar un icono de signo de exclamación al comienzo cuando se menciona su nombre.",
	PCHAT_MENTIONS_ALLCAPS_NAME = "Tu nombre en MAYÚSCULAS",
	PCHAT_MENTIONS_ALLCAPS_TOOLTIP = "Si desea o no escribir EN MAYÚSCULAS su nombre cuando te mencionen.",
	PCHAT_MENTIONS_EXTRA_NAMES_NAME = "Nombres adicionales para hacer ping (nueva línea por nombre)",
	PCHAT_MENTIONS_EXTRA_NAMES_TOOLTIP = "Una lista de nombres adicionales, separados por nuevas líneas, para avisarte. Pulsa ENTER para crear nuevas líneas. Si colocas un signo de exclamación (!) delante de un nombre personalizado que quieras supervisar, solo se te notificará si aparece entre palabras. Por ejemplo, si añades '!de' a tu lista de Extras, recibirás una notificación para 'de nada', pero no para 'delicatessen'. Si acabas de añadir 'de' a tu lista de Extras, también recibirás una notificación para 'delicatessen'.",
	PCHAT_MENTIONS_SELFSEND_NAME = "Aplica a los mensajes que TÚ envias",
	PCHAT_MENTIONS_SELFSEND_TOOLTIP = "Si aplicar o no formato a los mensajes que TÚ envias",
	PCHAT_MENTIONS_DING_NAME = "Sonido Ding?",
	PCHAT_MENTIONS_DING_TOOLTIP = "Si desea o no reproducir un sonido ding cuando se menciona su nombre.",
	PCHAT_MENTIONS_DING_SOUND_NAME = "Elige el sonido",
	PCHAT_MENTIONS_DING_SOUND_NAME_TOOLTIP = "Elige el sonido a reproducir",
	PCHAT_MENTIONS_APPLYNAME_NAME = "Aplica a los nombres de tus personajes",
	PCHAT_MENTIONS_APPLYNAME_TOOLTIP = "Si se aplica o no formato a cada nombre (separado por espacios) en el nombre de tu personaje. Desactívalo si usas un nombre muy común, como 'Yo', en el nombre de tu personaje.",
	PCHAT_MENTIONS_WHOLEWORD_NAME = "Coinciden tus nombres sólo con palabras completas",
	PCHAT_MENTIONS_WHOLEWORD_TOOLTIP = "Si quieres que los nombres de tus personajes coincidan solo con palabras completas. Si el nombre de tu personaje es muy corto, te recomendamos activar esta opción.",

	-- Coorbin20211222
	-- CharCount settings strings
	PCHAT_CHARCOUNTH = "Encabezado de Ventana de Chat",
	PCHAT_CHARCOUNT_ENABLE_CHECKBOX_NAME = "Mostrar Recuento de Caracteres",
	PCHAT_CHARCOUNT_ENABLE_CHECKBOX_TOOLTIP = "Muestra la cantidad actual de caracteres escritos en el cuadro de texto del chat, del límite máximo de 350. Aparecerá en la posición central superior de la ventana de chat.",
	PCHAT_CHARCOUNT_ZONE_POST_TRACKER_NAME = "Show Zone Post Tracker",
	PCHAT_CHARCOUNT_ZONE_POST_TRACKER_TOOLTIP = "Muestra la fecha y hora de la última publicación en el chat de la zona actual. La hora se restablece al cambiar de zona. Útil para publicar anuncios en el chat de la zona. Aparecerá en la parte superior central de la ventana de chat."
}

for stringId, stringValue in pairs(stringsES) do
   SafeAddString(_G[stringId], stringValue, 1)
end