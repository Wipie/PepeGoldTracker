local PepeGoldTracker = LibStub("AceAddon-3.0"):GetAddon("PepeGoldTracker")
local PepeExportCharacter = PepeGoldTracker:NewModule("PepeExportCharacter", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local StdUi = LibStub('StdUi')
local L = LibStub("AceLocale-3.0"):GetLocale("PepeGoldTracker")

function PepeExportCharacter:OnEnable()
    self.configDB = PepeGoldTracker.db.char
end

function PepeExportCharacter:OpenPanel()
    if (self.exportCharWindow == nil) then
        self:DrawExportCharWindow()
    else
        self.exportCharWindow:Show()
    end
end

function PepeExportCharacter:Toggle()
    if not self.exportCharWindow then
        PepeGoldTracker:UpdateChar() -- Force updating, workaround for guild refer to issue #9
        PepeExportCharacter:OpenPanel()
    elseif self.exportCharWindow:IsVisible() then
        self.exportCharWindow:Hide()
    else
        PepeExportCharacter:DrawExportCharWindow()
    end
end

-- Draw the export panel
function PepeExportCharacter:DrawExportCharWindow()
    local exportCharWindow = StdUi:Window(UIParent, 700, 400, L["Export characters data"])
    exportCharWindow:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    exportCharWindow:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    exportCharWindow:SetScript("OnMouseDown", function(self)
        self:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    end)

    StdUi:MakeResizable(exportCharWindow, "BOTTOMRIGHT")
    exportCharWindow:SetResizeBounds(250, 332)
    exportCharWindow:IsUserPlaced(true);

    local editBox = StdUi:MultiLineBox(exportCharWindow, 280, 300, nil)
    editBox:SetAlpha(0.75)
    StdUi:GlueAcross(editBox, exportCharWindow, 10, -50, -10, 50)
    editBox:SetFocus()

    local logoFrame = StdUi:Frame(exportCharWindow, 32, 32)
    local logoTexture = StdUi:Texture(logoFrame, 32, 32, [=[Interface\Addons\PepeGoldTracker\media\PepeAlone.tga]=])
    StdUi:GlueTop(logoTexture, logoFrame, 0, 0, "CENTER")
    StdUi:GlueBottom(logoFrame, exportCharWindow, -10, 10, "RIGHT")

    local closeButton = StdUi:Button(exportCharWindow, 80, 30, L["Close"])
    StdUi:GlueBottom(closeButton, exportCharWindow, 0, 10, 'CENTER')
    closeButton:SetScript('OnClick', function()
        self.exportCharWindow:Hide()
    end)

    local preExport = ""
    local allResults = PepeGoldTracker.db.global.characters
    for _, character in pairs(allResults) do
        local guild = ""
        if (character.guild) then
            guild = character.guild
        end
        preExport = preExport..character.name..";"..character.realm..";"..character.faction..";"..(math.floor(character.gold / 10000))..";"..guild..";"..character.date.."\n"
    end

    editBox:SetValue(preExport)
    
    self.exportCharWindow = exportCharWindow
    self.exportCharWindow.editBox = editBox
end