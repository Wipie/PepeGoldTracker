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

function PepeCurrentGold:UpdateWindow()
    if (self.currentGoldWindow) then
        self.currentGoldWindow:Hide()
        PepeCurrentGold:DrawCurrentGoldWindow()
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
    if (PepeGoldTracker.db.global.goldWindowOptions.data == "account") then
        for _, character in pairs(db) do
            totalGold = totalGold + character.gold
        end
    elseif (PepeGoldTracker.db.global.goldWindowOptions.data == "realm") then
        local name, realm = UnitFullName("player")
        for _, character in pairs(db) do
            if (character.realm == realm) then
                totalGold = totalGold + character.gold 
            end
        end
    elseif (PepeGoldTracker.db.global.goldWindowOptions.data == "character") then
        totalGold = GetMoney();
    end
    local formatGold = PepeGoldTracker:formatGold(totalGold, true)
    currentGoldWindow = StdUi:Window(UIParent, PepeGoldTracker.db.global.goldWindowOptions.width, PepeGoldTracker.db.global.goldWindowOptions.height, nil, true)
    local goldText = StdUi:Label(currentGoldWindow, formatGold, 16)
    goldText:SetJustifyH('RIGHT');
    StdUi:GlueAcross(goldText, currentGoldWindow, 0, 0)

    if (self.configDB.goldWindowPosition ~= nil) then
        currentGoldWindow:SetPoint(self.configDB.goldWindowPosition.point or "CENTER",
                self.configDB.goldWindowPosition.UIParent,
                self.configDB.goldWindowPosition.relPoint or "CENTER",
                self.configDB.goldWindowPosition.relX or 0,
                self.configDB.goldWindowPosition.relY or 0)
    else
        currentGoldWindow:SetPoint('CENTER', UIParent, 'CENTER', 0, 420)
    end
    currentGoldWindow:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())

    currentGoldWindow:SetResizeBounds(250, 332)
    currentGoldWindow:IsUserPlaced(false);
    currentGoldWindow:IsMovable(PepeGoldTracker.db.global.goldWindowOptions.lock);


    currentGoldWindow:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, xOfs, yOfs = self:GetPoint()
        PepeCurrentGold.configDB.goldWindowPosition = { point = point, relPoint = relPoint, relX = xOfs, relY = yOfs }
    end)

    self.currentGoldWindow = currentGoldWindow
end