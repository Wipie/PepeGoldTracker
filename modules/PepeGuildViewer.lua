local PepeGoldTracker = LibStub("AceAddon-3.0"):GetAddon("PepeGoldTracker")
local OblvionGuildsViewer = PepeGoldTracker:NewModule("PepeGuildViewer", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local StdUi = LibStub("StdUi")
local L = LibStub("AceLocale-3.0"):GetLocale("PepeGoldTracker")

function OblvionGuildsViewer:OnEnable()
    self.configDB = PepeGoldTracker.db.char
    self:RegisterEvent("GUILDBANK_UPDATE_MONEY", "OnEvent")
end

function OblvionGuildsViewer:OpenPanel()
    if (self.guildWindow == nil) then
        self:DrawWindow()
        self:DrawSearchPane()
        self:DrawSearchResultsTable()
    else
        self.guildWindow:Show()
    end
    self:SearchGuild("")
end

function OblvionGuildsViewer:Toggle()
    if not self.guildWindow then
        OblvionGuildsViewer:OpenPanel()
    elseif self.guildWindow:IsVisible() then
        self.guildWindow:Hide()
    else
        self.guildWindow:Show()
    end
    OblvionGuildsViewer:SearchGuild("")
end

function OblvionGuildsViewer:DrawWindow()
    local guildWindow
    if (self.configDB.guildWindowSize ~= nil) then
        guildWindow = StdUi:Window(UIParent, self.configDB.guildWindowSize.width, self.configDB.guildWindowSize.height, L["Guild tracking"])
    else
        guildWindow = StdUi:Window(UIParent, 950, 700, L["Guild tracking"])
    end

    if (self.configDB.guildWindowPosition ~= nil) then
        guildWindow:SetPoint(self.configDB.guildWindowPosition.point or "CENTER",
                self.configDB.guildWindowPosition.UIParent,
                self.configDB.guildWindowPosition.relPoint or "CENTER",
                self.configDB.guildWindowPosition.relX or 0,
                self.configDB.guildWindowPosition.relY or 0)
    else
        guildWindow:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    end

    guildWindow:SetScript("OnSizeChanged", function(self)
        OblvionGuildsViewer.configDB.guildWindowSize = { width = self:GetWidth(), height = self:GetHeight() }
    end)

    guildWindow:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, xOfs, yOfs = self:GetPoint()
        OblvionGuildsViewer.configDB.guildWindowPosition = { point = point, relPoint = relPoint, relX = xOfs, relY = yOfs }
    end)

    StdUi:MakeResizable(guildWindow, "BOTTOMRIGHT")
    StdUi:MakeResizable(guildWindow, "TOPLEFT")
    guildWindow:SetResizeBounds(950, 250)
    guildWindow:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    guildWindow:SetScript("OnMouseDown", function(self)
        self:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    end)

    local logoFrame = StdUi:Frame(guildWindow, 32, 32)
    local logoTexture = StdUi:Texture(logoFrame, 32, 32, [=[Interface\Addons\PepeGoldTracker\media\PepeAlone.tga]=])

    StdUi:GlueTop(logoTexture, logoFrame, 0, 0, "CENTER")
    StdUi:GlueBottom(logoFrame, guildWindow, -10, 10, "RIGHT")

    guildWindow.resultsLabel = StdUi:Label(guildWindow, nil, 16)
    StdUi:GlueBottom(guildWindow.resultsLabel, guildWindow, 0, 17, "CENTER")

    guildWindow.countLabel = StdUi:Label(guildWindow, nil, 16)
    StdUi:GlueBottom(guildWindow.countLabel, guildWindow, 10, 17, "LEFT")

    self.guildWindow = guildWindow
end


function OblvionGuildsViewer:ExportData()
    PepeGoldTracker.exportGuild:Toggle()
    OblvionGuildsViewer:Toggle()
end

function OblvionGuildsViewer:DrawSearchPane()
    local guildWindow = self.guildWindow
    local searchBox = StdUi:Autocomplete(guildWindow, 400, 30, "", nil, nil, nil)
    StdUi:ApplyPlaceholder(searchBox, L["Search.. name, realm, faction, date"], [=[Interface\Common\UI-Searchbox-Icon]=])
    searchBox:SetFontSize(16)

    local searchButton = StdUi:Button(guildWindow, 80, 30, L["Search"])

    StdUi:GlueTop(searchBox, guildWindow, 10, -40, "LEFT")
    StdUi:GlueTop(searchButton, guildWindow, 420, -40, "LEFT")

    searchBox:SetScript("OnEnterPressed", function()
        OblvionGuildsViewer:SearchGuild(searchBox:GetText())
    end)
    searchButton:SetScript("OnClick", function()
        OblvionGuildsViewer:SearchGuild(searchBox:GetText())
    end)

    local exportButton = StdUi:Button(guildWindow, 80, 30, L["Export"])
    StdUi:GlueRight(exportButton, searchButton, 10, 0)

    exportButton:SetScript("OnClick", function()
        OblvionGuildsViewer:ExportData()
    end)
    
    local deleteAll = StdUi:Button(guildWindow, 80, 30, L["Purge DB"])
    StdUi:FrameTooltip(deleteAll, L["Clear the guild database.\nThis effect is permanent and cannot be undone."], "tooltip", "RIGHT", true)
    StdUi:GlueRight(deleteAll, exportButton, 10, 0)

    deleteAll:SetScript("OnClick", function()
        OblvionGuildsViewer:Toggle()
        OblvionGuildsViewer:DrawConfirmationWindowAllGuilds()
    end)

    local thisRealmToggle = StdUi:Checkbox(guildWindow, L["Only show this realm"])
    StdUi:GlueRight(thisRealmToggle, deleteAll, 15, 0)
    thisRealmToggle.OnValueChanged = function(self, state)
        OblvionGuildsViewer:SearchGuild(searchBox:GetText())
    end
    StdUi:FrameTooltip(thisRealmToggle, L["Only show guilds that are on this realm."], "tooltip", "RIGHT", true)


    guildWindow.thisRealmToggle = thisRealmToggle
    guildWindow.searchBox = searchBox
    guildWindow.searchButton = searchButton
end

function OblvionGuildsViewer:OnEvent(event)
    if (event == 'GUILDBANK_UPDATE_MONEY')  then
        OblvionGuildsViewer:SearchGuild("")
    end
end

function OblvionGuildsViewer:DrawSearchResultsTable()
    local guildWindow = self.guildWindow

    local function showTooltip(frame, show, text)
        if show then
            GameTooltip:SetOwner(frame);
            GameTooltip:SetText(text)
        else
            GameTooltip:Hide();
        end
    end

    local cols = {
        {
            name = L["Guild name"],
            width = 150,
            align = "MIDDLE",
            index = "name",
            format = "string",
        },
        {
            name = L["Realm"],
            width = 110,
            align = "LEFT",
            index = "realm",
            format = "string",
        },
        {
            name = L["Faction"],
            width = 55,
            align = "LEFT",
            index = "faction",
            format = "string",
        },
        {
            name = L["Gold"],
            width = 100,
            align = "LEFT",
            index = "gold",
            format = "money",
        },
        {
            name = L["Last update"],
            width = 125,
            align = "LEFT",
            index = "date",
            format = "string",
        },
        {
            name = "",
            width = 32,
            align = "CENTER",
            index = "deleteButton",
            format = "icon",
            texture = true,
            events = {
                OnClick = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
                    OblvionGuildsViewer:Toggle()
                    self.id = cols.id
                    self.name = cols.name
                    OblvionGuildsViewer:DrawConfirmationWindow()
                end,
            },
        },
    }

    guildWindow.searchResults = StdUi:ScrollTable(guildWindow, cols, 18, 29)
    guildWindow.searchResults:EnableSelection(true)
    guildWindow.searchResults:SetDisplayRows(math.floor(guildWindow.searchResults:GetWidth() / guildWindow.searchResults:GetHeight()), guildWindow.searchResults.rowHeight)

    guildWindow.searchResults:SetScript("OnSizeChanged", function(self)
        local tableWidth = self:GetWidth();
        local tableHeight = self:GetHeight();

        -- Determine total width of columns
        local total = 0;
        for i = 1, #self.columns do
            total = total + self.columns[i].width;
        end

        -- Adjust all column widths proportionally
        for i = 1, #self.columns do
            self.columns[i]:SetWidth((self.columns[i].width / total) * (tableWidth - 30));
        end

        -- Set the number of displayed rows according to the new height
        self:SetDisplayRows(math.floor(tableHeight / self.rowHeight), self.rowHeight);
    end)

    StdUi:GlueAcross(guildWindow.searchResults, guildWindow, 10, -110, -10, 50)

    guildWindow.stateLabel = StdUi:Label(guildWindow.searchResults, L["No results found."])
    StdUi:GlueTop(guildWindow.stateLabel, guildWindow.searchResults, 0, -40, "CENTER")
end

function OblvionGuildsViewer:UpdateStateText()
    if (#self.currentView > 0) then
        self.guildWindow.stateLabel:Hide()
    else
        self.guildWindow.stateLabel:SetText(L["No results found."])
    end
end

function OblvionGuildsViewer:SearchGuild(filter)
    local guildWindow = self.guildWindow
    local searchFilter = filter:lower()
    local allResults = PepeGoldTracker.db.global.guilds
    local filteredResults = {}

    local realm
    if (select(4, GetGuildInfo("player")) ~= nil) then -- Check if the guild is hosted on a connected realm
        realm = select(4, GetGuildInfo("player"))
    else
        realm = select(2, UnitFullName("player"))
    end

    local thisRealmToggled = guildWindow.thisRealmToggle:GetChecked()
    local date = date("%Y-%m-%d %H:%M:%S")
    for index, guild in pairs(allResults) do
        if ((guild.name ~= nil) and (guild.name ~= "") and (guild.realm ~= nil) and (guild.realm ~= "")) then
            if ((guild.realm and (not thisRealmToggled or (guild.realm == realm)) or (guild.realm and (not thisRealmToggled or (guild.realm == realm))))
                    and (guild.realm and (guild.realm:lower():find(searchFilter, 1, true))
                    or (guild.gold and tostring(floor(guild.gold / COPPER_PER_GOLD)):find(searchFilter, 1, true))
                    or (guild.faction and guild.faction:lower():find(searchFilter, 1, true))
                    or (guild.date and guild.date:lower():find(searchFilter, 1, true))
                    or (guild.name and guild.name:lower():find(searchFilter, 1, true)))) then
                guild.deleteButton = [=[Interface\Buttons\UI-GroupLoot-Pass-Down]=]
                guild.id = index
                table.insert(filteredResults, guild)
            end
        elseif (guild.name == nil or guild.realm == nil or guild.gold == nil or guild.faction == nil) then
            PepeGoldTracker:Print(L["Detecting a bugged guild ID: "]..index..L[". The guild will be deleted make sure to confirm information while exporting!"])
            table.remove(allResults, index)
        end
    end

    -- TODO: This really should not be necessary, but I can't figure out how to get StdUi to sort our primary column by desc by default...
    OblvionGuildsViewer:ApplyDefaultSort(filteredResults)

    self.currentView = filteredResults
    self.guildWindow.searchResults:SetData(self.currentView, true)
    OblvionGuildsViewer:UpdateStateText()
    OblvionGuildsViewer:UpdateResultsText()
end

function OblvionGuildsViewer:ApplyDefaultSort(tableToSort)
    if (self.guildWindow.searchResults.head.columns) then
        local isSorted = false

        for k, v in pairs(self.guildWindow.searchResults.head.columns) do
            if (v.arrow:IsVisible()) then
                isSorted = true
            end
        end
    end

    if (not isSorted) then
        return table.sort(tableToSort, function(a, b)
            return a["date"] > b["date"]
        end)
    end

    return tableToSort
end

function OblvionGuildsViewer:UpdateResultsText()
    if (#self.currentView > 0) then
        local totalGold = 0
        for _, guild in pairs(self.currentView) do
            totalGold = totalGold + guild.gold
        end
        self.guildWindow.resultsLabel:SetText(PepeGoldTracker:formatGold(totalGold, true))
        self.guildWindow.resultsLabel:Show()

        self.guildWindow.countLabel:SetText(L["Current results: "] .. tostring(#self.currentView))
        self.guildWindow.countLabel:Show()
    else
        self.guildWindow.resultsLabel:Hide()
        self.guildWindow.countLabel:Hide()
    end
end

function OblvionGuildsViewer:DrawConfirmationWindow()
    local buttons = {
        yes = {
            text = L["Yes"],
            onClick = function(b)
                local db = PepeGoldTracker.db.global.guilds
                table.remove(db, self.id)
                OblvionGuildsViewer:SearchGuild("")
                PepeGoldTracker:Print(L["Guild "]..self.name..L[" deleted successfully"])
                b.window:Hide()
                OblvionGuildsViewer:Toggle()
            end
        },
        no = {
            text = L["No"],
            onClick = function(b)
                b.window:Hide()
                OblvionGuildsViewer:Toggle()
            end
        },
    }

    StdUi:Confirm(L["Delete guild"], L["Are you sure you want to delete "]..self.name, buttons, 2)
end

function OblvionGuildsViewer:DrawConfirmationWindowAllGuilds()
    local buttons = {
        yes = {
            text = L["Yes"],
            onClick = function(b)
                for index, guild in pairs(PepeGoldTracker.db.global.guilds) do
                    PepeGoldTracker.db.global.guilds[index] = nil
                end
                OblvionGuildsViewer:SearchGuild("")
                PepeGoldTracker:Print(L["All guilds have been successfully deleted."])
                b.window:Hide()
                OblvionGuildsViewer:Toggle()
            end
        },
        no = {
            text = L["No"],
            onClick = function(b)
                b.window:Hide()
                OblvionGuildsViewer:Toggle()
            end
        },
    }

    StdUi:Confirm(L["Delete guild"], L["Are you sure you want to delete ALL guilds?"], buttons, 3)
end