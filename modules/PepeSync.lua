local PepeGoldTracker = LibStub("AceAddon-3.0"):GetAddon("PepeGoldTracker")
local PepeSync = PepeGoldTracker:NewModule("PepeSync", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local StdUi = LibStub('StdUi')
local L = LibStub("AceLocale-3.0"):GetLocale("PepeGoldTracker")

PepeSync.IsRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
PepeSync.IsClassic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
PepeSync.IsBC = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
PepeSync.IsWrath = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC

function PepeSync:OnEnable()
    self.configDB = PepeGoldTracker.db.char

    self:RegisterEvent("CHAT_MSG_ADDON", "OnSync")
end

function PepeSync:OpenPanel()
    if (self.syncToWindow == nil) then
        self:DrawSyncRequestWindow()
    else
        self.syncToWindow:Show()
    end
end

function PepeSync:Toggle()
    if not self.syncToWindow then
        PepeSync:OpenPanel()
    elseif self.syncToWindow:IsVisible() then
        self.syncToWindow:Hide()
    else
        PepeSync:DrawSyncRequestWindow()
    end
end

-- Draw the export panel
function PepeSync:DrawSyncRequestWindow()
    local syncToWindow = StdUi:Window(UIParent, 420, 170, L["Synchronization request"])
    syncToWindow:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    syncToWindow:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    syncToWindow:SetScript("OnMouseDown", function(self)
        self:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    end)

    local statusText = StdUi:Label(syncToWindow, L["Enter the character you wish to sync with \n*Must be on the same realm/connected-realm"], 14)
    StdUi:GlueTop(statusText, syncToWindow, 0, -40)

    local editBox = StdUi:SimpleEditBox(syncToWindow, 360, 24, nil)
    StdUi:GlueTop(editBox, syncToWindow, 0, -85, 'CENTER');


    local logoFrame = StdUi:Frame(syncToWindow, 32, 32)
    local logoTexture = StdUi:Texture(logoFrame, 32, 32, [=[Interface\Addons\PepeGoldTracker\media\PepeAlone.tga]=])
    StdUi:GlueTop(logoTexture, logoFrame, 0, 0, "CENTER")
    StdUi:GlueBottom(logoFrame, syncToWindow, -10, 10, "RIGHT")

    local sendRequestButton = StdUi:Button(syncToWindow, 150, 30, L['Send request'])
    StdUi:GlueBottom(sendRequestButton, syncToWindow, 0, 10, 'CENTER')
    sendRequestButton:SetScript('OnClick', function()
        local name, realm = UnitFullName("player")
        local player = name.."-"..realm
        if (player == self.syncToWindow.editBox:GetText()) then
            PepeGoldTracker:Print(L["You cannot synchronize with yourself."])
        else
            PepeSync:SendRequest()
            self.syncToWindow:Hide()
        end
    end)

    self.syncToWindow = syncToWindow
    self.syncToWindow.editBox = editBox
end

function PepeSync:OnSync(event, ...)
    local prefix, content, channel, sender = ...
    if ((event == "CHAT_MSG_ADDON") and (prefix == "PepeSyncStatus")) then
        if content == "request" then
            PepeSync:DrawConfirmationWindowRequestSync(sender)
        elseif (content == "declined") then
            PepeGoldTracker:Print(L["%s declined your sync request."]:format(sender))
        elseif (content == "accepted") then
            PepeGoldTracker:Print(L["%s accepted your sync request."]:format(sender))
        end
    end
    if ((event == "CHAT_MSG_ADDON") and (prefix == "PepeSyncStart")) then
        local range = PepeGoldTracker:Split(content, ";")
        PepeSync:OpenSyncProgressWindow(range[1], range[2])
    end
    if ((event == "CHAT_MSG_ADDON") and (prefix == "PepeSync")) then
        local character = PepeGoldTracker:Split(content, ";")
        self.syncProgressWindow.progressBar:SetValue(character[7])
        if character[7] == character[8] then
            self.syncProgressWindow.statusText:SetText(L["Synchronization completed"].." ("..character[7].."/"..character[8]..")")
        else
            self.syncProgressWindow.statusText:SetText(L["Synching: %s"]:format(character[1]).. " ("..character[7].."/"..character[8]..")")
        end
        if (PepeGoldTracker:CheckIfCharExist(character[1])) then
            PepeGoldTracker:UpdateCharFromSync(character)
        else
            PepeGoldTracker:RegisterCharFromSync(character)
        end
    end

end


function PepeSync:SendRequest()
    local syncTarget = self.syncToWindow.editBox:GetText()
    PepeGoldTracker:Print(L["Sync request has been sent to %s, awaiting their confirmation."]:format(syncTarget))
    C_ChatInfo.SendAddonMessage("PepeSyncStatus", "request", "WHISPER", syncTarget)
end

function PepeSync:DrawConfirmationWindowRequestSync(source)
    local buttons = {
        yes = {
            text = L["Yes"],
            onClick = function(b)
                local db = PepeGoldTracker.db.global.characters
                local filteredChar = {}
                for _, char in pairs(db) do
                    if (char.syncIcon == 0) then
                        table.insert(filteredChar, char)
                    end
                end


                C_ChatInfo.SendAddonMessage("PepeSyncStatus", "accepted", "WHISPER", source)
                success = C_ChatInfo.SendAddonMessage("PepeSyncStart", "1;"..#filteredChar, "WHISPER", source)
                
                if (success) then
                    PepeGoldTracker:Print(L["Started synching. Do not close your game."])
                end

                for i, character in pairs(filteredChar) do
                    local preSync = ""
                    local guild = ""
                    if (character.guild) then
                        guild = character.guild
                    end
                    preSync = preSync..character.name..";"..character.realm..";"..character.faction..";"..character.gold..";"..guild..";"..character.date..";"..i..";"..#filteredChar
                    success = C_ChatInfo.SendAddonMessage("PepeSync", preSync, "WHISPER", source)
                    if (success) then
                        PepeGoldTracker:Print(L["Character data sent for: %s"]:format(character.name))
                    end
                end
                PepeGoldTracker:Print(L["Synchronization completed. You may now log off."])
                b.window:Hide()
            end
        },
        no = {
            text = L["No"],
            onClick = function(b)
                C_ChatInfo.SendAddonMessage("PepeSyncStatus", "declined", "WHISPER", source)
                b.window:Hide()
            end
        },
    }

    StdUi:Confirm(L["Pending request"], L["%s is requesting to sync your data."]:format(source), buttons, 2)
end

function PepeSync:OpenSyncProgressWindow(min, max)
    if not self.syncProgressWindow then
        PepeSync:OpenProgressPanel(min, max)
    elseif self.syncProgressWindow:IsVisible() then
        self.syncProgressWindow:Hide()
    else
        self.syncProgressWindow:Show()
    end
end

function PepeSync:OpenProgressPanel(min, max)
    if (self.syncProgressWindow == nil) then
        self:DrawSyncProgressWindow(min, max)
    else
        self.syncProgressWindow:Show()
    end
end

function PepeSync:DrawSyncProgressWindow(min, max)
    local syncProgressWindow = StdUi:Window(UIParent, 350, 150, L['Synchronization']);
    syncProgressWindow:SetPoint('CENTER');


    local logoFrame = StdUi:Frame(syncProgressWindow, 32, 32)
    local logoTexture = StdUi:Texture(logoFrame, 32, 32, [=[Interface\Addons\PepeGoldTracker\media\PepeAlone.tga]=])
    StdUi:GlueTop(logoTexture, logoFrame, 0, 0, "CENTER")
    StdUi:GlueTop(logoFrame, syncProgressWindow, 10, -10, "LEFT")

    local pb = StdUi:ProgressBar(syncProgressWindow, 300, 20);
    StdUi:GlueTop(pb, syncProgressWindow, 0, -55, 'CENTER');
    pb:SetStatusBarColor(0.2, 0.58, 0.98, 1)
    pb:SetMinMaxValues(min, max);


    local statusText = StdUi:Label(syncProgressWindow, "", 14)
    StdUi:GlueTop(statusText, syncProgressWindow, 0, -80)

    local closeButton = StdUi:Button(syncProgressWindow, 80, 30, L["Close"])
    StdUi:GlueBottom(closeButton, syncProgressWindow, 0, 10, 'CENTER')
    closeButton:SetScript('OnClick', function()
        self.syncProgressWindow:Hide()
    end)

    self.syncProgressWindow = syncProgressWindow
    self.syncProgressWindow.progressBar = pb
    self.syncProgressWindow.statusText = statusText
end