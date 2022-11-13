local PepeGoldTracker = LibStub("AceAddon-3.0"):GetAddon("PepeGoldTracker")
local PepeExportGuild = PepeGoldTracker:NewModule("PepeExportGuild", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local StdUi = LibStub('StdUi')
local L = LibStub("AceLocale-3.0"):GetLocale("PepeGoldTracker")

PepeExportGuild.IsRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
PepeExportGuild.IsClassic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
PepeExportGuild.IsBC = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
PepeExportGuild.IsWrath = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC

function PepeExportGuild:OnEnable()
    self.configDB = PepeGoldTracker.db.char
    self.db = PepeGoldTracker.db.global.guilds
end

function PepeExportGuild:OpenPanel()
    if (self.exportGuildWindow == nil) then
        self:DrawExportGuildWindow()
    else
        PepeExportGuild:DrawExportGuildWindow()
    end
end

function PepeExportGuild:Toggle()
    if not self.exportGuildWindow then
        PepeExportGuild:OpenPanel()
    elseif self.exportGuildWindow:IsVisible() then
        self.exportGuildWindow:Hide()
    else
        PepeExportGuild:DrawExportGuildWindow()
    end
end

-- Draw the export panel
function PepeExportGuild:DrawExportGuildWindow()
    local exportGuildWindow = StdUi:Window(UIParent, 700, 400, L["Export guilds data"])
    exportGuildWindow:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    exportGuildWindow:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    exportGuildWindow:SetScript("OnMouseDown", function(self)
        self:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    end)

    StdUi:MakeResizable(exportGuildWindow, "BOTTOMRIGHT")
    if (self.IsRetail) then
        exportGuildWindow:SetResizeBounds(250, 332)
    else
        exportGuildWindow:SetMinResize(250, 332)
    end
    exportGuildWindow:IsUserPlaced(true);

    local editBox = StdUi:MultiLineBox(exportGuildWindow, 280, 300, nil)
    editBox:SetAlpha(0.75)
    StdUi:GlueAcross(editBox, exportGuildWindow, 10, -50, -10, 50)
    editBox:SetFocus()

    local logoFrame = StdUi:Frame(exportGuildWindow, 32, 32)
    local logoTexture = StdUi:Texture(logoFrame, 32, 32, [=[Interface\Addons\PepeGoldTracker\media\PepeAlone.tga]=])
    StdUi:GlueTop(logoTexture, logoFrame, 0, 0, "CENTER")
    StdUi:GlueBottom(logoFrame, exportGuildWindow, -10, 10, "RIGHT")

    local closeButton = StdUi:Button(exportGuildWindow, 80, 30, L["Close"])
    StdUi:GlueBottom(closeButton, exportGuildWindow, 0, 10, 'CENTER')
    closeButton:SetScript('OnClick', function()
        self.exportGuildWindow:Hide()
    end)

    local preExport = ""
    for _, guild in pairs(self.db) do
		if ((guild.name ~= "") and (guild.name ~= nil) and (guild.realm ~= "") and (guild.realm ~= nil)) then
			preExport = preExport..guild.name..";"..guild.realm..";"..guild.faction..";"..(math.floor(guild.gold / 10000))..";"..guild.date.."\n"
		end
    end

    editBox:SetValue(preExport)
    
    self.exportGuildWindow = exportGuildWindow
    self.exportGuildWindow.editBox = editBox
end