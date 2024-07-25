local PepeGoldTracker = LibStub("AceAddon-3.0"):GetAddon("PepeGoldTracker")
local PepeCurrentRealm = PepeGoldTracker:NewModule("PepeCurrentRealm", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local StdUi = LibStub('StdUi')
local L = LibStub("AceLocale-3.0"):GetLocale("PepeGoldTracker")

PepeCurrentRealm.IsRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
PepeCurrentRealm.IsClassic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
PepeCurrentRealm.IsBC = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
PepeCurrentRealm.IsWrath = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC

function PepeCurrentRealm:OnEnable()
    self.configDB = PepeGoldTracker.db.char
end

function PepeCurrentRealm:OpenPanel()
    if (self.currentRealmWindow == nil) then
        self:DrawCurrentRealmWindow()
    else
        self.currentRealmWindow:Show()
    end
end

function PepeCurrentRealm:Toggle()
    if not self.currentRealmWindow then
        PepeCurrentRealm:OpenPanel()
    elseif self.currentRealmWindow:IsVisible() then
        self.currentRealmWindow:Hide()
    else
        self.currentRealmWindow:Show()
    end
end

function PepeCurrentRealm:DrawCurrentRealmWindow()
    local currentRealmWindow
    if (#GetAutoCompleteRealms() > 1) then
        currentRealmWindow = StdUi:Window(UIParent, 400, 160, L["Current Realm:"])
    else
        currentRealmWindow = StdUi:Window(UIParent, 400, 100, L["Current Realm:"])
    end

    currentRealmWindow:SetPoint('CENTER', UIParent, 'CENTER', 0, 420)
    currentRealmWindow:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())

    currentRealmWindow:SetResizeBounds(250, 332)
    currentRealmWindow:IsUserPlaced(true);
    currentRealmWindow:IsMovable(true)

    local logoFrame = StdUi:Frame(currentRealmWindow, 32, 32)
    local logoTexture = StdUi:Texture(logoFrame, 32, 32, [=[Interface\Addons\PepeGoldTracker\media\PepeAlone.tga]=])
    StdUi:GlueTop(logoTexture, logoFrame, 0, 0, "CENTER")
    StdUi:GlueTop(logoFrame, currentRealmWindow, 10, -10, "LEFT")

    local playerRealm = select(2, UnitFullName("player"))

    local realmText = StdUi:Label(currentRealmWindow, playerRealm, 32)
    StdUi:GlueTop(realmText, currentRealmWindow, 0, -40)

    if (#GetAutoCompleteRealms() > 1) then
        local connectedLabel = StdUi:FontString(currentRealmWindow, L["Connected realm:"])
        StdUi:GlueBelow(connectedLabel, realmText, 0, -10)

        local listOfConnectedRealm = ""
        local connectedRealms = GetAutoCompleteRealms()
        local filteredList = {}
        for index, realm in pairs(connectedRealms) do
            if (realm ~= playerRealm) then
                table.insert(filteredList, realm)
            end
        end

        for index, realm in pairs(filteredList) do
            if (index > 1) then
                listOfConnectedRealm = listOfConnectedRealm.."|cffd4af37".." | ".."|r"..realm
            else
                listOfConnectedRealm = listOfConnectedRealm..""..realm
            end
        end

        local connectedRealmLabel = StdUi:Label(currentRealmWindow, listOfConnectedRealm, 18, nil, 375)
        connectedRealmLabel:SetJustifyH('Middle')
        StdUi:GlueBelow(connectedRealmLabel, connectedLabel, 0, -10)
    end

    self.currentRealmWindow = currentRealmWindow
end