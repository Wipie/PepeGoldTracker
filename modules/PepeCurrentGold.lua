local PepeGoldTracker = LibStub("AceAddon-3.0"):GetAddon("PepeGoldTracker")
local PepeCurrentGold = PepeGoldTracker:NewModule("PepeCurrentGold", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local StdUi = LibStub('StdUi')
local L = LibStub("AceLocale-3.0"):GetLocale("PepeGoldTracker")

PepeCurrentGold.IsRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
PepeCurrentGold.IsClassic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
PepeCurrentGold.IsBC = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
PepeCurrentGold.IsWrath = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC

function PepeCurrentGold:OnEnable()
    self.configDB = PepeGoldTracker.db.char
end

function PepeCurrentGold:OpenPanel()
    if (self.currentGoldWindow == nil) then
        self:DrawCurrentGoldWindow()
    else
        self.currentGoldWindow:Show()
    end
end

function PepeCurrentGold:Toggle()
    if not self.currentGoldWindow then
        PepeCurrentGold:OpenPanel()
    elseif self.currentGoldWindow:IsVisible() then
        self.currentGoldWindow:Hide()
    else
        self.currentGoldWindow:Show()
    end
end

function PepeCurrentGold:DrawCurrentGoldWindow()
    local currentGoldWindow
    local db = PepeGoldTracker.db.global.characters
    local totalGold = 0;
    for _, character in pairs(db) do
        totalGold = totalGold + character.gold
    end
    local formatGold = PepeGoldTracker:formatGold(totalGold, true)
    currentGoldWindow = StdUi:Window(UIParent, 150, 30)
    local goldText = StdUi:Label(currentGoldWindow, formatGold, 16)
    StdUi:GlueTop(goldText, currentGoldWindow, 0, -40)

    currentGoldWindow:SetPoint('CENTER', UIParent, 'CENTER', 0, 420)
    currentGoldWindow:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())

    currentGoldWindow:SetResizeBounds(250, 332)
    currentGoldWindow:IsUserPlaced(false);
    currentGoldWindow:IsMovable(false);

    self.currentGoldWindow = currentGoldWindow
end