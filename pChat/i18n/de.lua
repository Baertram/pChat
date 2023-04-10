--[[
Ä = \195\132
ä = \195\164
Ö = \195\150
ö = \195\182
Ü = \195\156
ü = \195\188
ß = \195\159

Many Thanks to Phidias & Baertram for their work

]]--

-- Vars with -H are headers, -TT are tooltips

-- Messages settings

-- New May Need Translations
-- ************************************************
-- Chat tab selector Bindings
-- ************************************************
SafeAddString(PCHAT_Tab1										,"Selektiere Chat Reiter 1",1)
SafeAddString(PCHAT_Tab2										,"Selektiere Chat Reiter 2",1)
SafeAddString(PCHAT_Tab3										,"Selektiere Chat Reiter 3",1)
SafeAddString(PCHAT_Tab4										,"Selektiere Chat Reiter 4",1)
SafeAddString(PCHAT_Tab5										,"Selektiere Chat Reiter 5",1)
SafeAddString(PCHAT_Tab6										,"Selektiere Chat Reiter 6",1)
SafeAddString(PCHAT_Tab7										,"Selektiere Chat Reiter 7",1)
SafeAddString(PCHAT_Tab8										,"Selektiere Chat Reiter 8",1)
SafeAddString(PCHAT_Tab9										,"Selektiere Chat Reiter 9",1)
SafeAddString(PCHAT_Tab10										,"Selektiere Chat Reiter 10",1)
SafeAddString(PCHAT_Tab11										,"Selektiere Chat Reiter 11",1)
SafeAddString(PCHAT_Tab12										,"Selektiere Chat Reiter 12",1)
-- 9.3.6.24 Additions
SafeAddString(PCHAT_CHATTABH									,"Chat Reiter Einstellungen",1)
SafeAddString(PCHAT_enableChatTabChannel						,"Aktivere letzter verwendeter Kanal",1)
SafeAddString(PCHAT_enableChatTabChannelT						,"Der Chat Reiter merkt sich den zuletzt verwendeten Chat Kanal. Dieser wird im Anschluß der standard Chat Kanal für diesen Chat Reiter, bis du einen anderen als Standard Kanal auf diesem Chat Reiter festlegst.",1)
SafeAddString(PCHAT_enableWhisperTab							,"Aktivere Flüstern Umleitung",1)
SafeAddString(PCHAT_enableWhisperTabT							,"Flüster Nachrichten werden zu einem bestimmten Chat Reiter umgeleitet.",1)


-- New Need Translations
SafeAddString(PCHAT_ADDON_INFO                                  , "pChat überarbeitet alle möglichen Aspekte deines Chats. Du kannst Farben, Größe, Benachrichtigungen usw. anpassen, dich per Sound benachrichtigen lassen, und vieles mehr.\nDas Addon ChatMentions ist mittlerweile in pChat integriert.\nMit dem Befehl /msg im Chat kannst du die UI zum Definieren von Kürzeln öffnen, mit denen du deine Langtexte (Gilden Willkommens-Grüße z.B.) in den Chat senden kannst.", 1)
SafeAddString(PCHAT_ADDON_INFO_2                                , "Benutze den Chat Befehl \'/pchatdeleteoldsv\' um alte, nicht-Server abhängige Einstellungen zu löschen (Dateigröße verringern).", 1)

SafeAddString(PCHAT_OPTIONSH											, "Chat Optionen", 1)
SafeAddString(PCHAT_MESSAGEOPTIONSH										, "Nachrichten Optionen", 1)
SafeAddString(PCHAT_MESSAGEOPTIONSNAMEH                                 , "Name in Nachrichten", 1)
SafeAddString(PCHAT_MESSAGEOPTIONSNAME_ALLOTHERH                        , "Alle anderen Chat Nachrichten", 1)

SafeAddString(PCHAT_MESSAGEOPTIONSCOLORH                                , "Farbe von Nachrichten", 1)

SafeAddString(PCHAT_GUILDNUMBERS										, "Gildennummer", 1)
SafeAddString(PCHAT_GUILDNUMBERSTT									, "Zeigt die Gildennummer neben dem Gilden Spitznamen an.", 1)

SafeAddString(PCHAT_ALLGUILDSSAMECOLOUR							    , "Eine Farbe für alle Gilden", 1)
SafeAddString(PCHAT_ALLGUILDSSAMECOLOURTT							, "Für alle 'Gildenchats' gilt die gleiche Farbeinstellung wie für die erste Gilde \'%s\'", 1)

SafeAddString(PCHAT_ALLZONESSAMECOLOUR								, "Eine Farbe für alle 'Zonen'", 1)
SafeAddString(PCHAT_ALLZONESSAMECOLOURTT							, "Für alle 'Zonenchats' gilt die gleiche Farbeinstellung wie für (/zone).", 1)

SafeAddString(PCHAT_ALLNPCSAMECOLOUR								, "Eine Farbe für alle NSCs", 1)
SafeAddString(PCHAT_ALLNPCSAMECOLOURTT								, "Füe alle Texte von Nicht-Spieler-Charakteren (NSCs / NPCs) gilt die Farbeinstellung für 'NSC Sagen'.", 1)

SafeAddString(PCHAT_DELZONETAGS										, "Bezeichnung entfernen", 1)
SafeAddString(PCHAT_DELZONETAGSTT									, "Bezeichnungen ('tags') wie Schreien oder Zone am Anfang der Nachrichten entfernen.", 1)

SafeAddString(PCHAT_ZONETAGSAY										, "Sagen", 1)
SafeAddString(PCHAT_ZONETAGYELL										, "Schreien", 1)
SafeAddString(PCHAT_ZONETAGPARTY										, "Gruppe", 1)
SafeAddString(PCHAT_ZONETAGZONE										, "Zone", 1)

SafeAddString(PCHAT_CARRIAGERETURN									, "Namen & Text in separate Zeilen", 1)
SafeAddString(PCHAT_CARRIAGERETURNTT								, "Spielernamen und Chattexte werden durch einen Zeilenvorschub getrennt.", 1)

SafeAddString(PCHAT_USEESOCOLORS									, "ESO Standardfarben", 1)
SafeAddString(PCHAT_USEESOCOLORSTT									, "Verwendet statt der pChat Vorgabe die \'The Elder Scrolls Online\' Standard-Chat-Farben.\nMit dieser Option aktiviert sind die Farbeinstellungen für Chat Kanal Farben nicht aktiviert!", 1)

SafeAddString(PCHAT_DIFFFORESOCOLORS								, "Aktiviere Helligkeitsunterschied", 1)
SafeAddString(PCHAT_DIFFFORESOCOLORSTT								, "Bestimmt den Helligkeitsunterschied zwischen Charakternamen/Chat-Kanal und Nachrichtentext. Der Name wird dunkler, der Text wird heller.\nDiese Option ist nicht verwendbar, wenn die Option \'Einfarbige Zeilen\' aktiviert wurde!\nSetze den Regler auf 0, um den Helligkeitsunterschied zu deaktivieren.", 1)
SafeAddString(PCHAT_DIFFFORESOCOLORSDARKEN                          , "Helligkeitsunt.: Verdunkeln um", 1)
SafeAddString(PCHAT_DIFFFORESOCOLORSDARKENTT                        , "Verdunkle den Chat Namen um diesen Wert.", 1)
SafeAddString(PCHAT_DIFFFORESOCOLORSLIGHTEN                         , "Helligkeitsunt.: Aufhellen um", 1)
SafeAddString(PCHAT_DIFFFORESOCOLORSLIGHTENTT                       , "Helle den Chat Text um diesen Wert auf.", 1)

SafeAddString(PCHAT_REMOVECOLORSFROMMESSAGES						, "Entferne Farbe aus Nachrichten", 1)
SafeAddString(PCHAT_REMOVECOLORSFROMMESSAGESTT					, "Verhindert die Anzeige von Farben in Nachrichten (z.B. Regenbogentext von Mitspielern).", 1)

SafeAddString(PCHAT_AUGMENTHISTORYBUFFER							, "Anzahl Zeilen im Chat erhöhen (1000)", 1)
SafeAddString(PCHAT_AUGMENTHISTORYBUFFERTT						, "Standardmässig werden nur 200 Zeilen im Chat dargestellt. Hiermit kannst du diese auf bis zu 1000 erhöhen.", 1)

SafeAddString(PCHAT_PREVENTCHATTEXTFADING							, "Textausblenden unterbinden", 1)
SafeAddString(PCHAT_PREVENTCHATTEXTFADINGTT						, "Verhindert,daß der Chat-Text ausgeblendet wird (Einstellungen zum Chat-Hintergrund finden sich unter Einstellungen: Soziales - Minimale Transparenz)", 1)
SafeAddString(PCHAT_CHATTEXTFADINGBEGIN,                        "Textausblenden nach Sekunden", 1)
SafeAddString(PCHAT_CHATTEXTFADINGBEGINTT,                      "Blendet den Text nach dieser Anzahl Sekunden aus ", 1)
SafeAddString(PCHAT_CHATTEXTFADINGDURATION,                     "Textausblenden Dauer in Sekunden", 1)
SafeAddString(PCHAT_CHATTEXTFADINGDURATIONTT,                   "Das Ausblenden dauert diese Anzahl an Sekunden", 1)



SafeAddString(PCHAT_USEONECOLORFORLINES							, "Einfarbige Zeilen", 1)
SafeAddString(PCHAT_USEONECOLORFORLINESTT							, "Verwendet nur eine Farbe pro Chat-Kanal, anstatt zwei Farben (Nur die Erste, für den Spieler, wird verwendet)", 1)

SafeAddString(PCHAT_GUILDTAGSNEXTTOENTRYBOX						, "Gilden Spitzname neben Textfeld", 1)
SafeAddString(PCHAT_GUILDTAGSNEXTTOENTRYBOXTT					, "Zeigt den Gilden Spitznamen anstelle des Gildennamens links neben der Text-Eingabezeile an.", 1)

SafeAddString(PCHAT_DISABLEBRACKETS									, "Klammern um Namen entfernen", 1)
SafeAddString(PCHAT_DISABLEBRACKETSTT								, "Entfernt Klammern [] um die Namen der Spieler", 1)

SafeAddString(PCHAT_DEFAULTCHANNEL									, "Standard Kanal", 1)
SafeAddString(PCHAT_DEFAULTCHANNELTT								, "Bestimmt welcher Chat Kanal automatisch nach der Anmeldung ausgewählt wird.", 1)

SafeAddString(PCHAT_DEFAULTCHANNELCHOICE99						, "nicht ändern", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE31						, "/zone", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE0							, "/sagen", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE12						, "/gilde1", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE13						, "/gilde2", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE14						, "/gilde3", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE15						, "/gilde4", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE16						, "/gilde5", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE17						, "/offizier1", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE18						, "/offizier2", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE19						, "/offizier3", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE20						, "/offizier4", 1)
SafeAddString(PCHAT_DEFAULTCHANNELCHOICE21						, "/offizier5", 1)

SafeAddString(PCHAT_GEOCHANNELSFORMAT								, "Namen Darstellung", 1)
SafeAddString(PCHAT_GEOCHANNELSFORMATTT							, "Darstellung der Namensanzeige für die lokalen Kanäle (sagen, Zone, schreien).", 1)

SafeAddString(PCHAT_DEFAULTTAB										, "Standard Reiter nach Anmeldung", 1)
SafeAddString(PCHAT_DEFAULTTABTT										, "Bestimmt welcher Chat Reiter automatisch als Standard nach der Anmeldung ausgewählt wird.", 1)

SafeAddString(PCHAT_ADDCHANNELANDTARGETTOHISTORY				, "Kanal wechseln durch Pfeiltasten", 1)
SafeAddString(PCHAT_ADDCHANNELANDTARGETTOHISTORYTT				, "Der Chat Kanal wird beim Verwenden der Tastatur Pfeiltasten zum davor gewählten Chat Kanal wechseln.", 1)

SafeAddString(PCHAT_URLHANDLING										, "URL\'s/Links erkennen", 1)
SafeAddString(PCHAT_URLHANDLINGTT									, "Wenn eine URL mit http(s):// anfängt, wird pChat diese Links erkennen. Klicke auf diese Links um die Adresse in deinem im System eingestellten Standard Web Browser aufzurufen.\nAchtung: Es wird von ESO immer eine Sicherheitsabfrage angezeigt, ob die Webseite extern angezeigt werden soll.", 1)

SafeAddString(PCHAT_ENABLECOPY										, "Kopie/Chat Kanal Wechsel aktivieren", 1)
SafeAddString(PCHAT_ENABLECOPYTT										, "Aktivieren Sie das Kopieren von Text mit einem Rechtsklick.\nDies ermöglicht ebenfalls den Chat Kanal-Wechsel mit einem Linksklick.\n\nDeaktivieren Sie diese Option, wenn Sie Probleme mit der Anzeige von Links im Chat haben.", 1)

-- Group Settings

SafeAddString(PCHAT_GROUPH												, "Gruppen Einstellungen", 1)

SafeAddString(PCHAT_ENABLEPARTYSWITCH								, "Autom. Kanalwechsel: Gruppe", 1)
SafeAddString(PCHAT_ENABLEPARTYSWITCHTT							    , "Wenn du einer Gruppe beitrittst, wechselt der Chat Kanal automatisch zur Gruppe. Beim Verlassen der Gruppe entsprechend zurück zum zuletzt verwendeten Kanal.", 1)

SafeAddString(PCHAT_ENABLEPARTYSWITCHPORTTODUNGEON,                 "Autom. Wechsel: Verlies/ReloadUI", 1)
SafeAddString(PCHAT_ENABLEPARTYSWITCHPORTTODUNGEONTT, 	            "Der oben genannte automatische Gruppen Kanal Wechsel wird auch beim Reisen in ein Verlies/Benutzeroberfläche neuladen/Login ausgeführt, wenn du in einer Gruppe bist.\nDiese Option ist nur dann aktiv, wenn der automatische Gruppen Kanel Wechsel aktiviert wurde!", 1)


SafeAddString(PCHAT_GROUPLEADER										, "Sonderfarben für Gruppenleiter", 1)
SafeAddString(PCHAT_GROUPLEADERTT									, "Die Gruppenleiter werden mit einer speziellen Farbe im Gruppenchat schreiben.", 1)

SafeAddString(PCHAT_GROUPLEADERCOLOR								, "Gruppenleiter Name Farbe", 1)
SafeAddString(PCHAT_GROUPLEADERCOLORTT								, "Farbe des Gruppenleiters im Gruppenchat.", 1)

SafeAddString(PCHAT_GROUPLEADERCOLOR1								, "Gruppenleiter Nachricht Farbe", 1)
SafeAddString(PCHAT_GROUPLEADERCOLOR1TT							    , "Farbe der Nachrichten des Gruppenleiters. Wenn \"ESO Standardfarben\" aktiviert wurde ist diese Funktion deaktiviert.", 1)

SafeAddString(PCHAT_GROUPNAMES										, "Namen Darstellung in Gruppen", 1)
SafeAddString(PCHAT_GROUPNAMESTT									, "Darstellung der Namen in Gruppen.", 1)

-- Sync settings

SafeAddString(PCHAT_SYNCH												, "Synchronisierungseinstellungen", 1)

SafeAddString(PCHAT_CHATSYNCCONFIG									, "Chat-Konfiguration synchronisieren", 1)
SafeAddString(PCHAT_CHATSYNCCONFIGTT								, "Wenn die Synchronisierung aktiviert ist, werden alle Charaktere die gleiche Chat-Konfiguration (Farben, Position, Fensterabmessungen, Reiter) bekommen:\nAktivieren Sie diese Option, nachdem Sie Ihren Chat vollständig angepasst haben, und er wird für alle anderen Charaktere gleich eingestellt!", 1)

SafeAddString(PCHAT_CHATSYNCCONFIGIMPORTFROM						, "Chat Einstellungen übernehmen von", 1)
SafeAddString(PCHAT_CHATSYNCCONFIGIMPORTFROMTT					, "Sie können jederzeit die Chat-Einstellungen von einem anderen Charakter importieren (Farbe, Ausrichtung, Fenstergröße, Reiter).\nWählen Sie hier Ihren 'Vorlage Charakter' aus.", 1)

-- Apparence

SafeAddString(PCHAT_APPARENCEMH										, "Chatfenster Aussehen", 1)

SafeAddString(PCHAT_TABWARNING										, "Neue Nachricht Warnung", 1)
SafeAddString(PCHAT_TABWARNINGTT										, "Legen Sie die Farbe für die Warnmeldung im Chat Reiter fest.", 1)

SafeAddString(PCHAT_WINDOWDARKNESS									, "Transparenz des Chat-Fensters", 1)
SafeAddString(PCHAT_WINDOWDARKNESSTT								, "Erhöhen Sie die Verdunkelung des Chat-Fensters", 1)

SafeAddString(PCHAT_CHATMINIMIZEDATLAUNCH							, "Chat beim Start minimiert", 1)
SafeAddString(PCHAT_CHATMINIMIZEDATLAUNCHTT						, "Chat-Fenster auf der linken Seite des Bildschirms minimieren, wenn das Spiel startet", 1)

SafeAddString(PCHAT_CHATMINIMIZEDINMENUS							, "Chat in Menüs minimiert", 1)
SafeAddString(PCHAT_CHATMINIMIZEDINMENUSTT						, "Chat-Fenster auf der linken Seite des Bildschirms minimieren, wenn Menüs (Gilde, Charakter, Handwerk, etc.) geöffnet werden", 1)

SafeAddString(PCHAT_CHATMAXIMIZEDAFTERMENUS						, "Chat nach Menüs wieder herstellen", 1)
SafeAddString(PCHAT_CHATMAXIMIZEDAFTERMENUSTT					, "Zeigt das Chat Fenster, nach dem Verlassen von Menüs, wieder an", 1)

SafeAddString(PCHAT_FONTCHANGE										, "Schriftart", 1)
SafeAddString(PCHAT_FONTCHANGETT										, "Wählen Sie die Schriftart für den Chat aus.\nStandard: 'ESO Standard Font'", 1)

-- Whisper settings

SafeAddString(PCHAT_IMH													, "Flüstern", 1)

SafeAddString(PCHAT_SOUNDFORINCWHISPS								, "Ton für eingehende Flüsternachricht", 1)
SafeAddString(PCHAT_SOUNDFORINCWHISPSTT							, "Wählen Sie Sound, der abgespielt wird, wenn Sie ein Flüstern erhalten", 1)

SafeAddString(PCHAT_NOTIFYIM											, "Visuelle Hinweise anzeigen", 1)
SafeAddString(PCHAT_NOTIFYIMTT										, "Wenn Sie eine Flüsternachricht verpassen, wird eine Meldung in der oberen rechten Ecke des Chat-Fenster angezeigt. Wenn Sie auf diese Meldung klicken werden Sie direkt zur Flüsternachricht im Chat gebracht.\nWar Ihr Chat zum Zeitpunkt des Nachrichteneinganges minimiert, wird in der Chat Mini-Leiste ebenfalls eine Benachrichtigung angezeigt.", 1)

SafeAddString(PCHAT_SOUNDFORINCWHISPSCHOICE0						, "-KEIN TON-", 1)
SafeAddString(PCHAT_SOUNDFORINCWHISPSCHOICE1						, "Benachrichtigung", 1)
SafeAddString(PCHAT_SOUNDFORINCWHISPSCHOICE2						, "Klicken", 1)
SafeAddString(PCHAT_SOUNDFORINCWHISPSCHOICE3						, "Schreiben", 1)

-- Restore chat settings

SafeAddString(PCHAT_RESTORECHATH										, "Chat wiederherstellen", 1)

SafeAddString(PCHAT_RESTOREONRELOADUI								, "Nach ReloadUI", 1)
SafeAddString(PCHAT_RESTOREONRELOADUITT							, "Nach dem Neuladen der Benutzeroberfläche (/reloadui) wird pChat den vorherigen Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.", 1)

SafeAddString(PCHAT_RESTOREONLOGOUT									, "Nach LogOut", 1)
SafeAddString(PCHAT_RESTOREONLOGOUTTT								, "Nach dem Ausloggen wird pChat den vorherigen Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!", 1)

SafeAddString(PCHAT_RESTOREONAFK										, "Nach Kick (z.B. Inaktivität)", 1)
SafeAddString(PCHAT_RESTOREONAFKTT									, "Nachdem Sie vom Spiel rausgeschmissen wurden, z.B. durch Inaktivität, Senden zuvieler Nachrichten oder einer Netzwerk Trennung, wird pChat den Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!", 1)

SafeAddString(PCHAT_RESTOREONQUIT									, "Nach dem Verlassen", 1)
SafeAddString(PCHAT_RESTOREONQUITTT									, "Wenn Sie das Spiel selbstständig verlassen, wird pChat den Chat + Historie wieder herstellen. Sie können somit Ihre vorherige Konversation wieder aufnehmen.\nAchtung: Dies wird nur passieren, wenn Sie sich in der unten eingestellten 'Maximale Zeit für Wiederherstellung' erneut anmelden!", 1)

SafeAddString(PCHAT_TIMEBEFORERESTORE								, "Maximale Zeit (Stunden) für Wiederherstellung", 1)
SafeAddString(PCHAT_TIMEBEFORERESTORETT							    , "NACH dieser Zeit (in Stunden), wird pChat nicht mehr versuchen, den Chat wieder herzustellen", 1)

SafeAddString(PCHAT_RESTORESYSTEM									, "Systemnachrichten wiederherstellen", 1)
SafeAddString(PCHAT_RESTORESYSTEMTT									, "Stelle auch Systemnachrichten wieder her (z.B. Login Nachrichten, Addon Nachrichten) wenn der Chat + Historie wiederhergestellt werden", 1)

SafeAddString(PCHAT_RESTORESYSTEMONLY								, "Nur Systemnachrichten wiederherstellen", 1)
SafeAddString(PCHAT_RESTORESYSTEMONLYTT							, "Stellt nur Systemnachrichten wieder her (z.B. Anmelde- und Addon-Nachrichten).", 1)

SafeAddString(PCHAT_RESTOREWHISPS									, "Flüsternachricht wiederherstellen", 1)
SafeAddString(PCHAT_RESTOREWHISPSTT									, "Stellt Flüsternachrichten wieder her. Flüsternachrichten sind nach einem /ReloadUI immer wiederhergestellt.", 1)
SafeAddString(PCHAT_RESTOREWHISPS_NO_NOTIFY                         , "Keine Flüster Hinweise beim Wiederherstellen", 1)
SafeAddString(PCHAT_RESTOREWHISPS_NO_NOTIFY_TT                      , "Zeige keine Hinweise an, und färbe den Chat Reiter nicht ein, wenn Flüsternachrichten wiederhergestellt werden.\nKann nur aktiviert werden, wenn die Flüster Hinweise/Benachrichtigungen aktiviert wurden.", 1)


SafeAddString(PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT		        , "Text wiederherstellen bei Pfeiltasten Historie", 1)
SafeAddString(PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT	        , "Stellt die Historie wieder her beim verwenden der Tastatur Pfeiltasten. Die Historie ist nach einem /ReloadUI immer wiederhergestellt.", 1)

-- Anti Spam settings

SafeAddString(PCHAT_ANTISPAMH											, "Anti-Spam", 1)

SafeAddString(PCHAT_FLOODPROTECT										, "Aktiviere Anti-Flood", 1)
SafeAddString(PCHAT_FLOODPROTECTTT									, "Verhindert, dass Ihnen sich wiederholende, identische Nachrichten von Spielern angezeigt werden", 1)

SafeAddString(PCHAT_FLOODGRACEPERIOD								, "Dauer Anti-Flood Verbannung", 1)
SafeAddString(PCHAT_FLOODGRACEPERIODTT								, "Anzahl der Sekunden in denen sich wiederholende, identische Nachrichten ignoriert werden", 1)

SafeAddString(PCHAT_LOOKINGFORPROTECT								, "Ignoriere Gruppen(suche)nachrichten", 1)
SafeAddString(PCHAT_LOOKINGFORPROTECTTT							, "Ignoriert Nachrichten, mit denen nach Gruppen/Gruppenmitgliedern gesucht wird", 1)

SafeAddString(PCHAT_WANTTOPROTECT									, "Ignoriere Handelsnachrichten ", 1)
SafeAddString(PCHAT_WANTTOPROTECTTT									, "Ignoriert Nachrichten von Spielern, die etwas handeln oder ver-/kaufen möchten", 1)

SafeAddString(PCHAT_SPAMGRACEPERIOD									, "Anti-Flood temporär deaktivieren", 1)
SafeAddString(PCHAT_SPAMGRACEPERIODTT								, "Wenn Sie selber eine Gruppe suchen, einen Handel oder Ver-/Kauf über den Chat kommunizieren, wird der Anti-Flood Schutz temporär aufgehoben.\nDiese Einstellung legt die Minuten fest, nachdem der Anti-Flood Schutz wieder aktiviert wird.", 1)

-- Nicknames settings

SafeAddString(PCHAT_NICKNAMESH										, "Spitzname", 1)
SafeAddString(PCHAT_NICKNAMESD										, "Du kannst an gewissen Spielern separate Spitznamen vergeben.\nBeispiel ganzer Account: @Ayantir = Blondschopf\nBeispiel nur einen Charakter: Der-gern-kaut = Blondschopf", 1)
SafeAddString(PCHAT_NICKNAMES											, "Liste der Spitznamen", 1)
SafeAddString(PCHAT_NICKNAMESTT										, "Du kannst an gewissen Spielern separate Spitznamen vergeben.\nBeispiel ganzer Account: @Ayantir = Blondschopf\nBeispiel nur einen Charakter: Der-gern-kaut = Blondschopf", 1)

-- Timestamp settings

SafeAddString(PCHAT_TIMESTAMPH										, "Zeitstempel & Zwischenablage", 1)

SafeAddString(PCHAT_ENABLETIMESTAMP									, "Aktiviere Zeitstempel", 1)
SafeAddString(PCHAT_ENABLETIMESTAMPTT								, "Fügt Chat-Nachrichten einen Zeitstempel hinzu.", 1)

SafeAddString(PCHAT_TIMESTAMPCOLORISLCOL							, "Zeitstempel und Namen gleich färben", 1)
SafeAddString(PCHAT_TIMESTAMPCOLORISLCOLTT						, "Für den Zeitstempel gilt die gleiche Farbeinstellung wie für den Spielernamen, oder Nicht-Spieler-Charakter (NSC / NPC)", 1)

SafeAddString(PCHAT_TIMESTAMPFORMAT									, "Zeitstempelformat", 1)
SafeAddString(PCHAT_TIMESTAMPFORMATTT								, "FORMAT:\nHH: Stunden (24)\nhh: Stunden (12)\nH: Stunde (24, keine vorangestellte 0)\nh: Stunde (12, keine vorangestellte 0)\nA: AM/PM\na: am/pm\nm: Minuten\ns: Sekunden", 1)

SafeAddString(PCHAT_TIMESTAMP											, "Zeitstempel", 1)
SafeAddString(PCHAT_TIMESTAMPTT										, "Legt die Farbe des Zeitstempels fest.", 1)

-- Guild settings
SafeAddString(PCHAT_GUILDH,                                         "Gilden Einstellungen", 1)

SafeAddString(PCHAT_CHATCHANNELSH,                                  "Chat Kanäle", 1)

SafeAddString(PCHAT_NICKNAMEFOR										, "Spitzname", 1)
SafeAddString(PCHAT_NICKNAMEFORTT									, "Spitzname für ", 1)

SafeAddString(PCHAT_OFFICERTAG										, "Offizierskanal", 1)
SafeAddString(PCHAT_OFFICERTAGTT										, "Seperates Präfix für den Offizierskanal verwenden.", 1)

SafeAddString(PCHAT_SWITCHFOR											, "Wechsel zum Kanal", 1)
SafeAddString(PCHAT_SWITCHFORTT										, "Neuer Wechsel zu Kanal. Beispiel: /myguild", 1)

SafeAddString(PCHAT_OFFICERSWITCHFOR								, "Wechsel zu Offizierskanal", 1)
SafeAddString(PCHAT_OFFICERSWITCHFORTT								, "Neuer Wechsel zu Offizierskanal. Beispiel /offs", 1)

SafeAddString(PCHAT_NAMEFORMAT										, "Namensformat", 1)
SafeAddString(PCHAT_NAMEFORMATTT										, "Legt die Formatierung für die Namensanzeige von Gildenmitgliedern fest.", 1)

SafeAddString(PCHAT_FORMATCHOICE1									, "@Accountname", 1)
SafeAddString(PCHAT_FORMATCHOICE2									, "Charaktername", 1)
SafeAddString(PCHAT_FORMATCHOICE3									, "Charaktername@Accountname", 1)
SafeAddString(PCHAT_FORMATCHOICE4									, "@Accountname/Charaktername", 1)

SafeAddString(PCHAT_SETCOLORSFORTT									, "Farbe für Mitglieder von <<1>>", 1)
SafeAddString(PCHAT_SETCOLORSFORCHATTT								, "Farbe für Nachrichten von <<1>>", 1)

SafeAddString(PCHAT_SETCOLORSFOROFFICIERSTT						, "Farbe für Mitglieder des 'Offiziers-Chats' von <<1>>", 1)
SafeAddString(PCHAT_SETCOLORSFOROFFICIERSCHATTT					, "Farbe für Nachrichten des 'Offiziers-Chats' von <<1>>", 1)

SafeAddString(PCHAT_MEMBERS											, "Spielername", 1)
SafeAddString(PCHAT_CHAT												, "Nachrichten", 1)

SafeAddString(PCHAT_OFFICERSTT										, " Offiziere", 1)

-- Channel colors settings

SafeAddString(PCHAT_CHATCOLORSH										, "Chat Kanal Farben", 1)

SafeAddString(PCHAT_SAY													, "Sagen - Spieler", 1)
SafeAddString(PCHAT_SAYTT												, "Legt die Farbe für Spieler Namen im Chat-Kanal: Sagen fest.", 1)

SafeAddString(PCHAT_SAYCHAT											, "Sagen - Nachricht", 1)
SafeAddString(PCHAT_SAYCHATTT											, "Legt die Farbe der Nachrichten im Chat-Kanal: Sagen fest.", 1)

SafeAddString(PCHAT_ZONE												, "Zone - Spieler", 1)
SafeAddString(PCHAT_ZONETT												, "Legt die Farbe für Spieler Namen im Chat-Kanal: Zone fest.", 1)

SafeAddString(PCHAT_ZONECHAT											, "Zone - Nachricht", 1)
SafeAddString(PCHAT_ZONECHATTT										, "Legt die Farbe der Nachrichten im Chat-Kanal: Zone fest.", 1)

SafeAddString(PCHAT_YELL												, "Schreien - Spieler", 1)
SafeAddString(PCHAT_YELLTT												, "Legt die Farbe für Spieler Namen im Chat-Kanal: Schreien fest.", 1)

SafeAddString(PCHAT_YELLCHAT											, "Schreien - Nachricht", 1)
SafeAddString(PCHAT_YELLCHATTT										, "Legt die Farbe der Nachrichten im Chat-Kanal: Schreien fest.", 1)

SafeAddString(PCHAT_INCOMINGWHISPERS								, "Eingehendes Flüstern - Spieler", 1)
SafeAddString(PCHAT_INCOMINGWHISPERSTT								, "Legt die Farbe für Spieler Namen im Chat-Kanal: eingehendes Flüstern fest.", 1)

SafeAddString(PCHAT_INCOMINGWHISPERSCHAT							, "Eingehendes Flüstern - Nachricht", 1)
SafeAddString(PCHAT_INCOMINGWHISPERSCHATTT						    , "Legt die Farbe der Nachrichten im Chat-Kanal: eingehendes Flüstern fest.", 1)

SafeAddString(PCHAT_OUTGOINGWHISPERS								, "Ausgehendes Flüstern - Spieler", 1)
SafeAddString(PCHAT_OUTGOINGWHISPERSTT								, "Legt die Farbe für Spieler Namen im Chat-Kanal: ausgehendes Flüstern fest.", 1)

SafeAddString(PCHAT_OUTGOINGWHISPERSCHAT							, "Ausgehendes Flüstern - Nachricht", 1)
SafeAddString(PCHAT_OUTGOINGWHISPERSCHATTT						    , "Legt die Farbe der Nachrichten im Chat-Kanal: ausgehendes Flüstern fest.", 1)

SafeAddString(PCHAT_GROUP												, "Gruppe - Spieler", 1)
SafeAddString(PCHAT_GROUPTT											, "Legt die Farbe für Spieler Namen im Chat-Kanal: Gruppe fest.", 1)

SafeAddString(PCHAT_GROUPCHAT											, "Gruppe - Nachricht", 1)
SafeAddString(PCHAT_GROUPCHATTT										, "Legt die Farbe der Nachrichten im Chat-Kanal: Gruppe fest.", 1)

-- Other colors

SafeAddString(PCHAT_OTHERCOLORSH										, "Sonstige Farben", 1)

SafeAddString(PCHAT_EMOTES												, "'Emotes' - Name", 1)
SafeAddString(PCHAT_EMOTESTT											, "Legt die Farbe für den Spieler Namen bei ausgeführten 'Emotes' fest.", 1)

SafeAddString(PCHAT_EMOTESCHAT										    , "Emotes - Nachricht", 1)
SafeAddString(PCHAT_EMOTESCHATTT										, "Legt die Farbe von 'Emotes' im Chat fest.", 1)

SafeAddString(PCHAT_ENZONE												, "EN Zone - Name", 1)
SafeAddString(PCHAT_ENZONETT											, "Legt die Farbe für Spieler Namen im englischsprachigen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_ENZONECHAT										, "EN Zone - Nachricht", 1)
SafeAddString(PCHAT_ENZONECHATTT										, "Legt die Farbe der Nachrichten im englischsprachigen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_FRZONE												, "FR Zone - Name", 1)
SafeAddString(PCHAT_FRZONETT											, "Legt die Farbe für Spieler Namen im französischsprachigen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_FRZONECHAT										, "FR Zone - Nachricht", 1)
SafeAddString(PCHAT_FRZONECHATTT										, "Legt die Farbe der Nachrichten im französischsprachigen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_DEZONE												, "DE Zone - Name", 1)
SafeAddString(PCHAT_DEZONETT											, "Legt die Farbe für Spieler Namen im deutschsprachigen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_DEZONECHAT										, "DE Zone - Nachricht", 1)
SafeAddString(PCHAT_DEZONECHATTT										, "Legt die Farbe der Nachrichten im deutschsprachigen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_JPZONE												, "JP Zone - Name", 1)
SafeAddString(PCHAT_JPZONETT											, "Legt die Farbe für Spieler Namen im japanisch Chat-Kanal fest.", 1)

SafeAddString(PCHAT_JPZONECHAT										, "JP Zone - Nachricht", 1)
SafeAddString(PCHAT_JPZONECHATTT										, "Legt die Farbe der Nachrichten im japanisch Chat-Kanal fest.", 1)

SafeAddString(PCHAT_RUZONE                                          , "RU Zone - Name", 1)
SafeAddString(PCHAT_RUZONETT                                        , "Legt die Farbe für Spieler Namen im russischen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_RUZONECHAT                                      , "RU Zone - Nachricht", 1)
SafeAddString(PCHAT_RUZONECHATTT                                    , "Legt die Farbe der Nachrichten im russischen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_ESZONE                                          , "ES Zone - Name", 1)
SafeAddString(PCHAT_ESZONETT                                        , "Legt die Farbe für Spieler Namen im spanischen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_ESZONECHAT                                      , "ES Zone - Nachricht", 1)
SafeAddString(PCHAT_ESZONECHATTT                                    , "Legt die Farbe der Nachrichten im spanischen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_ZHZONE                                          , "ZH Zone - Name", 1)
SafeAddString(PCHAT_ZHZONETT                                        , "Legt die Farbe für Spieler Namen im chinesischen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_ZHZONECHAT                                      , "ZH Zone - Nachricht", 1)
SafeAddString(PCHAT_ZHZONECHATTT                                    , "Legt die Farbe der Nachrichten im chinesischen Chat-Kanal fest.", 1)

SafeAddString(PCHAT_NPCSAY												, "NSC Sagen - NSC Name", 1)
SafeAddString(PCHAT_NPCSAYTT											, "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in NSC-Texten fest.", 1)

SafeAddString(PCHAT_NPCSAYCHAT										, "NSC Sagen - Nachricht", 1)
SafeAddString(PCHAT_NPCSAYCHATTT										, "Legt die Farbe für Nicht-Spieler-Charaktertexte fest.", 1)

SafeAddString(PCHAT_NPCYELL											, "NSC Schreien - NSC Name", 1)
SafeAddString(PCHAT_NPCYELLTT											, "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in geschrienen NSC-Texten fest.", 1)

SafeAddString(PCHAT_NPCYELLCHAT										, "NSC Schreien - Nachricht", 1)
SafeAddString(PCHAT_NPCYELLCHATTT									, "Legt die Farbe für geschriene Nicht-Spieler-Charaktertexte fest.", 1)

SafeAddString(PCHAT_NPCWHISPER										, "NSC Flüstern - NSC Name", 1)
SafeAddString(PCHAT_NPCWHISPERTT										, "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) in geflüsterten NSC-Texten fest.", 1)

SafeAddString(PCHAT_NPCWHISPERCHAT									, "NSC Flüstern - Nachricht", 1)
SafeAddString(PCHAT_NPCWHISPERCHATTT								, "Legt die Farbe für geflüsterte Nicht-Spieler-Charaktertexte fest.", 1)

SafeAddString(PCHAT_NPCEMOTES											, "NSC 'Emote' - NSC Name", 1)
SafeAddString(PCHAT_NPCEMOTESTT										, "Legt die Farbe des Namens des Nicht-Spieler-Charakters (NSC - NPC) der ein 'Emote' ausführt fest.", 1)

SafeAddString(PCHAT_NPCEMOTESCHAT									, "NSC 'Emote' - Nachricht", 1)
SafeAddString(PCHAT_NPCEMOTESCHATTT									, "Legt die Farbe für 'Nicht-Spieler-Charakter-Emotes' im Chat fest.", 1)

-- Debug settings

SafeAddString(PCHAT_DEBUGH												, "Debug", 1)

SafeAddString(PCHAT_DEBUG												, "Debug", 1)
SafeAddString(PCHAT_DEBUGTT											, "Debug", 1)

-- Various strings not in panel settings

SafeAddString(PCHAT_COPYMESSAGECT									, "Nachricht kopieren", 1)
SafeAddString(PCHAT_COPYLINECT										, "Zeile kopieren", 1)
SafeAddString(PCHAT_COPYDISCUSSIONCT								, "Diskussion kopieren", 1)
SafeAddString(PCHAT_ALLCT												, "Ganzes Plaudern kopieren", 1)

SafeAddString(PCHAT_COPYXMLTITLE										, "Kopiere Text mit STRG+C", 1)
SafeAddString(PCHAT_COPYXMLLABEL										, "Kopiere Text mit STRG+C", 1)
SafeAddString(PCHAT_COPYXMLTOOLONG									, "Aufgeteilter Text:", 1)
SafeAddString(PCHAT_COPYXMLPREV										, "Vorherige", 1)
SafeAddString(PCHAT_COPYXMLNEXT										, "Nächste", 1)
SafeAddString(PCHAT_COPYXMLAPPLY                                    , "Filter anwenden", 1)

SafeAddString(PCHAT_SWITCHTONEXTTABBINDING						, "Zur nächsten Registerkarte", 1)
SafeAddString(PCHAT_TOGGLECHATBINDING								, "Toggle Chat-Fenster", 1)
SafeAddString(PCHAT_WHISPMYTARGETBINDING							, "Flüsternachricht an Zielperson", 1)
SafeAddString(PCHAT_COPYWHOLECHATBINDING                        ,   "Kopiere den Chat (Dialog)", 1)

SafeAddString(PCHAT_SAVMSGERRALREADYEXISTS						, "Kann die Nachricht nicht speichern, da sie schon existiert!", 1)
SafeAddString(PCHAT_AUTOMSG_NAME_DEFAULT_TEXT			, "Beispiel: ts3", 1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT		, "Schreibe hier deine Nachricht, die bei der Sendefunktion geschickt werden sollte.", 1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT			, "Leere Zeilen werden automatisch gelöscht.", 1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT			, "Die Nachricht wird gesendet, sobald du sie bestätigt hast: \"!nameOfMessage\". (Bsp: |cFFFFFF!ts3|r)", 1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT			, "Um eine Nachricht in einem bestimmten Kanal zu senden, füge am Anfang der Nachricht den Kanal ein (Bsp: |cFFFFFF/g1|r)", 1)
SafeAddString(PCHAT_AUTOMSG_NAME_HEADER					, "Akronym deiner Nachricht", 1)
SafeAddString(PCHAT_AUTOMSG_MESSAGE_HEADER				, "Nachricht", 1)
SafeAddString(PCHAT_AUTOMSG_ADD_TITLE_HEADER				, "Neue automatische Nachricht", 1)
SafeAddString(PCHAT_AUTOMSG_EDIT_TITLE_HEADER			, "Ändere automatische Nachricht", 1)
SafeAddString(PCHAT_AUTOMSG_ADD_AUTO_MSG					, "Hinzufügen", 1)
SafeAddString(PCHAT_AUTOMSG_EDIT_AUTO_MSG					, "Ändern", 1)
SafeAddString(PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG		, "Automatische Nachricht", 1)
SafeAddString(PCHAT_AUTOMSG_REMOVE_AUTO_MSG				, "Löschen", 1)

SafeAddString(PCHAT_CLEARBUFFER								, "Chatverlauf löschen", 1)

--Added by Baertram
SafeAddString(PCHAT_RESTORED_PREFIX                         , "[H]", 1)
SafeAddString(PCHAT_RESTOREPREFIX                           , "Prefix vor wiederherg. Nachrichten anzeigen", 1)
SafeAddString(PCHAT_RESTOREPREFIXTT                         , "Zeigt den Prefix \'[H]\' vor wiederhergestellten Nachrichten an, damit man diese einfach erkennen kann.\nDies wirkt sich erst nach einem ReloadUI auf den aktuellen Chat aus!\nDie Farbe des Prefix wird mit den ESO Standard Farben der Chat Kanäle angezeigt.", 1)

SafeAddString(PCHAT_CHATHANDLERS                            , "Chat Formatierungs Handler", 1)
SafeAddString(PCHAT_CHATHANDLER_TEMPLATETT                  , "Formatiere die Chat Nachrichten für das Event \'%s\'\n\nIst diese Einstellung deaktiviert, so werden die entsprechenden Chat Nachrichten durch die pChat Formatierungs Einstellungen nicht verändert (z.B. Farben, Zeitstempel, Namen, etc.)", 1)
SafeAddString(PCHAT_CHATHANDLER_SYSTEMMESSAGES              , "System Nachrichten", 1)
SafeAddString(PCHAT_CHATHANDLER_PLAYERSTATUS                , "Spieler Status geändert", 1)
SafeAddString(PCHAT_CHATHANDLER_IGNORE_ADDED                , "Ignorierte Spieler hinzugefügt", 1)
SafeAddString(PCHAT_CHATHANDLER_IGNORE_REMOVED              , "Ignorierte Spieler entfernt", 1)
SafeAddString(PCHAT_CHATHANDLER_GROUP_MEMBER_LEFT           , "Gruppen Mitglied verlassen", 1)
SafeAddString(PCHAT_CHATHANDLER_GROUP_TYPE_CHANGED          , "Gruppen Typ geändert", 1)

SafeAddString(PCHAT_SETTINGS_EDITBOX_HOOKS 					, "Chat Text Eingabefeld", 1)
SafeAddString(PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACE 	, "STRG + <-: Wort löschen", 1)
SafeAddString(PCHAT_SETTINGS_EDITBOX_HOOK_CTRL_BACKSPACETT 	, "Wenn die STRG + Zurück (<- Taste, auch BACKSPACE genannt) gedrückt wird, so wird das ganze Wort links vor dem Cursor gelöscht.", 1)

SafeAddString(PCHAT_SETTINGS_BACKUP 				        , "Backup", 1)
SafeAddString(PCHAT_SETTINGS_BACKUP_REMINDER_LAST_REMINDER  , "Letzte Erinnerung: %s", 1)
SafeAddString(PCHAT_SETTINGS_BACKUP_REMINDER 		        , "Backup Erinnerung", 1)
SafeAddString(PCHAT_SETTINGS_BACKUP_REMINDER_TT 	        , "Zeige eine Erinnerung, dass du deine Einstellungen sichern sollst, jede Woche 1x an. Die Erinnerung wird auch angezeigt, wenn ein Wechsel der APIVersion festgestellt wird (durch einen Patch z.B.).\n\nDu solltest generell nach einem Spiel Patch, aber VOR dem Einloggen in das Spiel, ein Backup deines SavedVariables Verzeichnisses durchführen!", 1)
SafeAddString(PCHAT_SETTINGS_BACKUP_REMINDER_DIALOG_TEXT	, "Bitte |cFF0000!logge dich aus!|r und sichere deine pChat SavedVariables!\nDer folgende Link auf www.esoui.com erklärt dir\nwie du dies tun kannst:\n\nhttps://www.esoui.com/forums/showthread.php?t=9235\n\nBestätige diesen Dialog und der nächste Dialog\nkann dir diese Webseite direkt öffnen\n(falls du noch lernen musst, wie man seine\nSavedVariables sichern kann).", 1)
SafeAddString(PCHAT_SETTINGS_WARNING_REMINDER_LOGOUT_BEFORE	, "Denk daran dich zuerst AUSZULOGGEN!", 1)

SafeAddString(PCHAT_RESTORESHOWNAMEANDZONE, "Nach Widerherst.: Zeige Name & Zone", 1)
SafeAddString(PCHAT_RESTORESHOWNAMEANDZONE_TT, "Zeige den aktuell eingeloggten @Account - Charakter Name & Zone im Chat, nachdem die Chat Historie wiederhergestellt wurde.", 1)


-- Coorbin20200708
-- Chat Mentions settings strings
SafeAddString(PCHAT_MENTIONSH ,  "Erwähnungen (Mentions)", 1)
SafeAddString(PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_NAME ,  "Text Farbe anpassen, wenn Name erwähnt wird?", 1)
SafeAddString(PCHAT_MENTIONS_TEXT_COLOR_CHECKBOX_TOOLTIP ,  "Soll die Text Farbe verändert werden, wenn dein Account Name (oder auch Charakter Name, sofern weiter unten in den Einstellungen aktiviert) erwähnt wird", 1)
SafeAddString(PCHAT_MENTIONS_TEXT_COLOR_PICKER_NAME ,  "Farbe des Namens, wenn du erwähnt wirst", 1)
SafeAddString(PCHAT_MENTIONS_ADD_EXCL_ICON_NAME ,  "Ausrufezeichen hinzufügen?", 1)
SafeAddString(PCHAT_MENTIONS_ADD_EXCL_ICON_TOOLTIP ,  "Soll ein ! (Ausrufzeichen) Symbol am Anfang des Namens hinzugefügt werden, wenn dein Name erwähnt wird?", 1)
SafeAddString(PCHAT_MENTIONS_ALLCAPS_NAME ,  "Den NAMEN GROß schreiben?", 1)
SafeAddString(PCHAT_MENTIONS_ALLCAPS_TOOLTIP ,  "Soll dein Name in großbuchstaben dargestellt werden, wenn er erwähnt wird?", 1)
SafeAddString(PCHAT_MENTIONS_EXTRA_NAMES_NAME ,  "Extra Namen, welche als Erwähnung gelten (je Zeile: 1 Name)", 1)
SafeAddString(PCHAT_MENTIONS_EXTRA_NAMES_TOOLTIP ,  "Eine Liste in welcher je Zeile ein weiterer Name eingetragen werden kann, welcher zu einer Erwähnunh führen wird. Drücke die ENTER Taste, um eine neue Zeile zu beginnen. Wenn du ein \'!\' (Ausrufezeichen) vor den Namen setzt, so wird dieser Name nur erwähnt, wenn dieser ein eigenständiges Wort (mt Leerzeichen davor und dahinter) darstellt!\n\nBeispiel: \'!de\' Du wirst bei \'de nada\' informiert, nicht jedoch bei \'Delikatessen\'. Wenn du nur z.B. \'de\' hinzufügst, werden alle Wörte mit den Buchstaben \'de\' zu einer Benachrichtigung führen (z.B. Hunde, Delikatessen, Deutschland, ...).", 1)
SafeAddString(PCHAT_MENTIONS_SELFSEND_NAME ,  "Auch für eigen-versendete Nachrichten?", 1)
SafeAddString(PCHAT_MENTIONS_SELFSEND_TOOLTIP ,  "Sollen die Benachrichtigungen auch für Nachrichten, welche du selbst versendest, aktiviert werden?", 1)
SafeAddString(PCHAT_MENTIONS_DING_NAME ,  "\'Ding\' Klang?", 1)
SafeAddString(PCHAT_MENTIONS_DING_TOOLTIP ,  "Soll ein Ding Klang ertönen, wenn eine Erwähnung vorliegt?", 1)
SafeAddString(PCHAT_MENTIONS_DING_SOUND_NAME, "Wähle Klang", 1)
SafeAddString(PCHAT_MENTIONS_DING_SOUND_NAME_TOOLTIP, "Wähle den Klang aus, welcher abgespielt werden soll", 1)
SafeAddString(PCHAT_MENTIONS_APPLYNAME_NAME ,  "Charakter Namen auch berücksichtigen?", 1)
SafeAddString(PCHAT_MENTIONS_APPLYNAME_TOOLTIP ,  "Soll nicht nicht der Account Name, sondern auch der Charakter Name, berücksichtigt werden?\nAchtung: Dies wird für jeden Bestandteil deines Charakter Namens (also jeden durch Leerzeichen getrennten Teil) angewandt! z.B. wird bei  \'Baertram der Bärenfreund\' dann benachrichtigt, wenn jemand \'Baertram\', \'der\' oder \'Bärenfreund\' schreibt.\nDeaktiviere diese Option, wenn du einen sehr gewöhnlichen Namensbestandteil wie z.B. \'der\' in deinem Charakternamen verwendest.", 1)
SafeAddString(PCHAT_MENTIONS_WHOLEWORD_NAME ,  "Namen nur als ganze Wörter prüfen?", 1)
SafeAddString(PCHAT_MENTIONS_WHOLEWORD_TOOLTIP ,  "Charakter Namen werden nur als ganze Wörter geprüft, und nicht jeder Charakternamen Bestandteil (durch Leerzeichen getrennt) einzeln. Wenn du einen kurzen Charakternamen Bestandteil verendest, z.B. \'der\' in \'Baertram der Bärenfreund\', dann sollte diese Option dir helfen .", 1)

-- Coorbin20211223
-- CharCount settings strings
SafeAddString(PCHAT_CHARCOUNTH, "Chat Fenster Kopfbereich", 1)
SafeAddString(PCHAT_CHARCOUNT_ENABLE_CHECKBOX_NAME, "Zeige Anzahl getippter Zeichen", 1)
SafeAddString(PCHAT_CHARCOUNT_ENABLE_CHECKBOX_TOOLTIP, "Zeigt die Anzahl der aktuell getippten Zeichen des Text Eingabefeldes des Chats, sowie die maximalen 350 Zeichen an. Dies wird mittig in der Kopfzeile des Chat Fensters angezeigt.", 1)
SafeAddString(PCHAT_CHARCOUNT_ZONE_POST_TRACKER_NAME, "Zeige letzten ausgehenden Zonen-Chat Zeitpunkt", 1)
SafeAddString(PCHAT_CHARCOUNT_ZONE_POST_TRACKER_TOOLTIP, "Zeigt den Zeitpunkt der letzten ausgehenden (gesendeten) Zonen Chat Nachricht an (in der aktuellen Zone). Der Zeitpunkt wird zurückgesetzt, wenn du die Zone wechselst. Dies kann hilfreich sein wenn man Werbung oder Ankündigugen in mehreren Zonen versenden möchte. Dies wird mittig in der Kopfzeile des Chat Fensters angezeigt.", 1)
