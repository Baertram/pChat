local CONSTANTS = pChat.CONSTANTS
local ADDON_NAME = CONSTANTS.ADDON_NAME

-- Add IM label on XML Initialization, set anchor and set it hidden
function pChat_AddIMLabel(control)

    control:SetParent(CHAT_SYSTEM.control)
    control:ClearAnchors()
    control:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, -5, 32)
    CHAT_SYSTEM.IMLabel = control

end

-- Add IM label on XML Initialization, set anchor and set it hidden. Used for Chat Minibar
function pChat_AddIMLabelMin(control)

    control:SetParent(CHAT_SYSTEM.control)
    control:ClearAnchors()
    control:SetAnchor(BOTTOM, CHAT_SYSTEM.minBar.maxButton, TOP, 2, 0)
    CHAT_SYSTEM.IMLabelMin = control

end

-- Add IM close button on XML Initialization, set anchor and set it hidden
function pChat_AddIMButton(control)

    control:SetParent(CHAT_SYSTEM.control)
    control:ClearAnchors()
    control:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, 2, 35)
    CHAT_SYSTEM.IMbutton = control

end

function pChat.InitializeIncomingMessages()
    local pChatData = pChat.pChatData
    local db = pChat.db
    local logger = pChat.logger

    -- Hide it
    local function HideIMTooltip()
        ClearTooltip(InformationTooltip)
    end

    -- Show IM notification tooltip
    local function ShowIMTooltip(self, lineNumber)

        if db.LineStrings[lineNumber] then

            local sender = db.LineStrings[lineNumber].rawFrom
            local text = db.LineStrings[lineNumber].rawMessage

            if (not IsDecoratedDisplayName(sender)) then
                sender = zo_strformat(SI_UNIT_NAME, sender)
            end

            InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, 0, TOPRIGHT)
            InformationTooltip:AddLine(sender, "ZoFontGame", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)

            local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
            InformationTooltip:AddLine(text, "ZoFontGame", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)

        end

    end

    -- When an incoming Whisper is received
    local function OnIMReceived(from, lineNumber)

        -- Display visual notification
        if db.notifyIM then

            --Do not notify if history gets restored and if the setting to stop notifications is
            if db.doNotNotifyOnRestoredWhisperFromHistory == true and pChatData.preventWhisperNotificationsFromHistory == true then
                logger.verbose:Debug("<<<Whisper restore aborted, from: " ..tostring(from) .. ", line#: " ..tostring(lineNumber))
                --Prevent the whisper notifications because of history restored messages
                pChatData.preventWhisperNotificationsFromHistory = false
                return
            end

            -- If chat minimized, show the minified button
            if (CHAT_SYSTEM:IsMinimized()) then
                CHAT_SYSTEM.IMLabelMin:SetHandler("OnMouseEnter", function(self) ShowIMTooltip(self, lineNumber) end)
                CHAT_SYSTEM.IMLabelMin:SetHandler("OnMouseExit", HideIMTooltip)
                CHAT_SYSTEM.IMLabelMin:SetHidden(false)
            else
                -- Chat maximized
                local _, scrollMax = CHAT_SYSTEM.primaryContainer.scrollbar:GetMinMax()

                -- If chat tab with whisper channel activated is not the currently active one, or it's the whisper tab but we did not scroll to the bottom
                local isChatContainerCategoryEnabledWhisperIncoming = IsChatContainerTabCategoryEnabled(1, pChatData.activeTab, CHAT_CATEGORY_WHISPER_INCOMING)
                if (   (not isChatContainerCategoryEnabledWhisperIncoming)
                    or (isChatContainerCategoryEnabledWhisperIncoming and CHAT_SYSTEM.primaryContainer.scrollbar:GetValue() < scrollMax) ) then

                    -- Undecorate (^F / ^M)
                    if (not IsDecoratedDisplayName(from)) then
                        from = zo_strformat(SI_UNIT_NAME, from)
                    end

                    -- Split if name too long
                    local displayedFrom = from
                    if string.len(displayedFrom) > 8 then
                        displayedFrom = string.sub(from, 1, 7) .. "..."
                    end

                    -- Show
                    CHAT_SYSTEM.IMLabel:SetText(displayedFrom)
                    CHAT_SYSTEM.IMLabel:SetHidden(false)
                    CHAT_SYSTEM.IMbutton:SetHidden(false)

                    -- Add handler
                    CHAT_SYSTEM.IMLabel:SetHandler("OnMouseEnter", function(self) ShowIMTooltip(self, lineNumber) end)
                    CHAT_SYSTEM.IMLabel:SetHandler("OnMouseExit", function(self) HideIMTooltip() end)
                end
            end

        end

    end
    pChat.OnIMReceived = OnIMReceived

    -- Hide IM notification when click on it. Can be Called by XML
    function pChat_RemoveIMNotification()
        CHAT_SYSTEM.IMLabel:SetHidden(true)
        CHAT_SYSTEM.IMLabelMin:SetHidden(true)
        CHAT_SYSTEM.IMbutton:SetHidden(true)
    end

    -- Will try to display the notified IM. Called by XML
    function pChat_TryToJumpToIm(isMinimized)

        -- Show chat first
        if isMinimized then
            CHAT_SYSTEM:Maximize()
            CHAT_SYSTEM.IMLabelMin:SetHidden(true)
        end

        -- Tab get IM, scroll
        if IsChatContainerTabCategoryEnabled(1, pChatData.activeTab, CHAT_CATEGORY_WHISPER_INCOMING) then
            ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)
            pChat_RemoveIMNotification()
        else

            -- Tab don't have IM's, switch to next
            local numTabs = #CHAT_SYSTEM.primaryContainer.windows
            local actualTab = pChatData.activeTab + 1
            local oldActiveTab = pChatData.activeTab
            local PRESSED = 1
            local UNPRESSED = 2
            local hasSwitched = false
            local maxt = 1

            while actualTab <= numTabs and (not hasSwitched) do
                if IsChatContainerTabCategoryEnabled(1, actualTab, CHAT_CATEGORY_WHISPER_INCOMING) then

                    CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[actualTab].tab)

                    local tabText = pChat.GetTabTextControl(actualTab)
                    tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                    tabText:GetParent().state = PRESSED
                    local oldTabText = pChat.GetTabTextControl(oldActiveTab)
                    oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                    oldTabText:GetParent().state = UNPRESSED
                    ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)

                    hasSwitched = true
                else
                    actualTab = actualTab + 1
                end
            end

            actualTab = 1

            -- If we were on tab #3 and IM are show on tab #2, need to restart from 1
            while actualTab < oldActiveTab and (not hasSwitched) do
                if IsChatContainerTabCategoryEnabled(1, actualTab, CHAT_CATEGORY_WHISPER_INCOMING) then

                    CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[actualTab].tab)

                    local tabText = pChat.GetTabTextControl(actualTab)
                    tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                    tabText:GetParent().state = PRESSED
                    local oldTabText = pChat.GetTabTextControl(oldActiveTab)
                    oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                    oldTabText:GetParent().state = UNPRESSED
                    ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)

                    hasSwitched = true
                else
                    actualTab = actualTab + 1
                end
            end

        end

    end

    -- Visual Notification PreHook
    ZO_PreHook(CHAT_SYSTEM, "Maximize", function(self)
        CHAT_SYSTEM.IMLabelMin:SetHidden(true)
    end)
end
