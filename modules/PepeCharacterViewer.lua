local PepeGoldTracker = LibStub("AceAddon-3.0"):GetAddon("PepeGoldTracker")
local PepeCharacterViewer = PepeGoldTracker:NewModule("PepeCharacterViewer", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local StdUi = LibStub("StdUi")
local L = LibStub("AceLocale-3.0"):GetLocale("PepeGoldTracker")

PepeCharacterViewer.IsRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
PepeCharacterViewer.IsClassic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
PepeCharacterViewer.IsBC = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
PepeCharacterViewer.IsWrath = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC

PepeCharacterViewer.format = ""

function PepeCharacterViewer:OnEnable()
    self.configDB = PepeGoldTracker.db.char
    self:RegisterEvent("PLAYER_MONEY", "OnEvent")
end

function PepeCharacterViewer:OpenPanel()
    if (self.characterWindow == nil) then
        self:DrawWindow()
        self:DrawSearchPane()
        self:DrawSearchResultsTable()
    else
        self.characterWindow:Show()
    end
    self:SearchChar("")
end

function PepeCharacterViewer:Toggle()
    if not self.characterWindow then
        PepeGoldTracker:UpdateChar() -- Refer to issue #9 Guild updating issue
        PepeCharacterViewer:OpenPanel()
    elseif self.characterWindow:IsVisible() then
        self.characterWindow:Hide()
    else
        self.characterWindow:Show()
    end
end

function PepeCharacterViewer:DrawWindow()
    local characterWindow
    if (self.configDB.characterWindowSize ~= nil) then
        characterWindow = StdUi:Window(UIParent, self.configDB.characterWindowSize.width, self.configDB.characterWindowSize.height, L["Character overview"])
    else
        characterWindow = StdUi:Window(UIParent, 950, 700, L["Character overview"])
    end

    if (self.configDB.characterWindowPosition ~= nil) then
        characterWindow:SetPoint(self.configDB.characterWindowPosition.point or "CENTER",
                self.configDB.characterWindowPosition.UIParent,
                self.configDB.characterWindowPosition.relPoint or "CENTER",
                self.configDB.characterWindowPosition.relX or 0,
                self.configDB.characterWindowPosition.relY or 0)
    else
        characterWindow:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    end
    characterWindow:SetScript("OnSizeChanged", function(self)
        PepeCharacterViewer.configDB.characterWindowSize = { width = self:GetWidth(), height = self:GetHeight() }
    end)

    characterWindow:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, xOfs, yOfs = self:GetPoint()
        PepeCharacterViewer.configDB.characterWindowPosition = { point = point, relPoint = relPoint, relX = xOfs, relY = yOfs }
    end)

    StdUi:MakeResizable(characterWindow, "BOTTOMRIGHT")
    StdUi:MakeResizable(characterWindow, "TOPLEFT")
    characterWindow:IsMovable(true)
    characterWindow:SetResizeBounds(950, 250)
    characterWindow:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    characterWindow:SetScript("OnMouseDown", function(self)
        self:SetFrameLevel(PepeGoldTracker:GetNextFrameLevel())
    end)

    local logoFrame = StdUi:Frame(characterWindow, 32, 32)
    local logoTexture = StdUi:Texture(logoFrame, 32, 32, [=[Interface\Addons\PepeGoldTracker\media\PepeAlone.tga]=])

    StdUi:GlueTop(logoTexture, logoFrame, 0, 0, "CENTER")
    StdUi:GlueBottom(logoFrame, characterWindow, -10, 10, "RIGHT")

    characterWindow.resultsLabel = StdUi:Label(characterWindow, nil, 16)
    StdUi:GlueBottom(characterWindow.resultsLabel, characterWindow, 0, 17, "CENTER")

    characterWindow.countLabel = StdUi:Label(characterWindow, nil, 16)
    StdUi:GlueBottom(characterWindow.countLabel, characterWindow, 10, 17, "LEFT")

    self.characterWindow = characterWindow
end


function PepeCharacterViewer:ExportData()
    PepeGoldTracker.exportCharacter:Toggle()
    PepeCharacterViewer:Toggle()
end

function PepeCharacterViewer:DrawSearchPane()
    local characterWindow = self.characterWindow
    local searchBox = StdUi:Autocomplete(characterWindow, 400, 30, "", nil, nil, nil)
    StdUi:ApplyPlaceholder(searchBox, L["Search.. name, realm, faction, date"], [=[Interface\Common\UI-Searchbox-Icon]=])
    searchBox:SetFontSize(16)

    local searchButton = StdUi:Button(characterWindow, 80, 30, L["Search"])

    StdUi:GlueTop(searchBox, characterWindow, 10, -40, "LEFT")
    StdUi:GlueTop(searchButton, characterWindow, 420, -40, "LEFT")

    searchBox:SetScript("OnEnterPressed", function()
        PepeCharacterViewer:SearchChar(searchBox:GetText())
    end)
    searchButton:SetScript("OnClick", function()
        PepeCharacterViewer:SearchChar(searchBox:GetText())
    end)

    local exportButton = StdUi:Button(characterWindow, 80, 30, L["Export"])
    StdUi:GlueRight(exportButton, searchButton, 10, 0)

    exportButton:SetScript("OnClick", function()
        PepeCharacterViewer:ExportData()
    end)

    local thisRealmToggle = StdUi:Checkbox(characterWindow, L["Only show this realm"])
    StdUi:GlueRight(thisRealmToggle, exportButton, 15, 0)
    thisRealmToggle.OnValueChanged = function(self, state)
        PepeCharacterViewer:SearchChar(searchBox:GetText())
    end
    local thisRealmToggleTooltip = StdUi:FrameTooltip(thisRealmToggle, L["Only show characters that are on this realm."], "tooltip", "RIGHT", true)

    characterWindow.thisRealmToggle = thisRealmToggle
    characterWindow.searchBox = searchBox
    characterWindow.searchButton = searchButton
end

function PepeCharacterViewer:OnEvent(event)
    if ((event == 'PLAYER_MONEY') or (event == 'PLAYER_ENTERING_WORLD'))  then
        if (self.characterWindow) then
            PepeCharacterViewer:SearchChar("")
        end
    end
end

function PepeCharacterViewer:UpdateSearchTable()
    if (self.characterWindow) then
        self.characterWindow.searchResults:Hide()
        PepeCharacterViewer:DrawSearchResultsTable()
        PepeCharacterViewer:SearchChar("")
    end
end

function PepeCharacterViewer:DrawSearchResultsTable()
    local characterWindow = self.characterWindow

    local newTable = {}
    local cols = {
        {
            key = "icon",
            order = 1,
            name = "",
            width = 24,
            align = "CENTER",
            index = "syncIcon",
            format = "icon",
            texture = true,
            events = {
                OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                    if rowData.syncIcon == 625757 then
                        GameTooltip:SetOwner(cellFrame)
                        GameTooltip:SetText(L["Synched character"])
                        GameTooltip:Show()
                    end

                end,
                OnLeave = function(rowFrame, cellFrame)
                    GameTooltip:Hide()
                end
            },
        },
        {
            key = "name",
            order = 2,
            name = L["Character name"],
            width = 150,
            align = "CENTER",
            index = "name",
            format = "string",
        },
        {
            key = "realm",
            order = 3,
            name = L["Realm"],
            width = 110,
            align = "LEFT",
            index = "realm",
            format = "string",
        },
        {
            key = "faction",
            order = 4,
            name = L["Faction"],
            width = 55,
            align = "LEFT",
            index = "faction",
            format = "string",
        },
        {
            key = "gold",
            order = 5,
            name = L["Gold"],
            width = 100,
            align = "LEFT",
            index = "gold",
            format = PepeGoldTracker.db.global.moneyFormat,
        },
        {
            key = "guild",
            order = 6,
            name = L["Guild name"],
            width = 150,
            align = "CENTER",
            index = "guild",
            format = "string",
            defaultSort = "asc"
        },
        {
            key = "update",
            order = 7,
            name = L["Last update"],
            width = 125,
            align = "LEFT",
            index = "date",
            format = "string",
        },
        {
            key = "delete",
            order = 8,
            name = "",
            width = 32,
            align = "CENTER",
            index = "deleteButton",
            sortable = false,
            format = "icon",
            texture = true,
            events = {
                OnClick = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
                    PepeCharacterViewer:Toggle()
                    self.id = cols.id
                    self.name = cols.name
                    PepeCharacterViewer:DrawConfirmationWindow()
                end,
                OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                    cellFrame.texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
                end,
                OnLeave = function(rowFrame, cellFrame)
                    cellFrame.texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Down]])
                end
            },
        },
    }

    local function getIndex(key)
        for column = 1, #cols do
            if (cols[column].key == key) then
                return column
            end
        end
    end  
    for key, value in pairs (PepeGoldTracker.db.global.hideColumnCharacters) do
        local index = getIndex(tostring(key))
        if ((index) and not value) then
            table.insert(newTable, cols[index])
        end
    end

    table.sort(newTable, function(a,b)
        if a.order < b.order then 
            return true 
        end
    end)

    -- Add the delete button as you don't want to hide it in for any reason
    table.insert(newTable, cols[getIndex('delete')])
    
    characterWindow.searchResults = StdUi:ScrollTable(characterWindow, newTable, 18, 29)
    characterWindow.searchResults:EnableSelection(true)
    characterWindow.searchResults:SetDisplayRows(math.floor(characterWindow.searchResults:GetWidth() / characterWindow.searchResults:GetHeight()), characterWindow.searchResults.rowHeight)

    characterWindow.searchResults:SetScript("OnSizeChanged", function(self)
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

    StdUi:GlueAcross(characterWindow.searchResults, characterWindow, 10, -110, -10, 50)

    characterWindow.stateLabel = StdUi:Label(characterWindow.searchResults, L["No results found."])
    StdUi:GlueTop(characterWindow.stateLabel, characterWindow.searchResults, 0, -40, "CENTER")
    self.characterWindow.searchResults =  characterWindow.searchResults
end

function PepeCharacterViewer:UpdateStateText()
    if (#self.currentView > 0) then
        self.characterWindow.stateLabel:Hide()
    else
        self.characterWindow.stateLabel:SetText(L["No results found."])
    end
end

function PepeCharacterViewer:SearchChar(filter)
    local characterWindow = self.characterWindow
    local searchFilter = filter:lower()
    local allResults = PepeGoldTracker.db.global.characters
    local filteredResults = {}
    local name, realm = UnitFullName("player")
    local player = name .. "-" .. realm
    local thisRealmToggled = characterWindow.thisRealmToggle:GetChecked()
    local date = date("%Y-%m-%d %H:%M:%S")
    for index, character in pairs(allResults) do
        if ((character.realm and (not thisRealmToggled or (character.realm == realm)))
                and (character.realm and (character.realm:lower():find(searchFilter, 1, true))
                or (character.gold and tostring(floor(character.gold / COPPER_PER_GOLD)):find(searchFilter, 1, true))
                or (character.faction and character.faction:lower():find(searchFilter, 1, true))
                or (character.guild and character.guild:lower():find(searchFilter, 1, true))
                or (character.date and character.date:lower():find(searchFilter, 1, true))
                or (character.name and character.name:lower():find(searchFilter, 1, true)))) then
            character.deleteButton = [=[Interface\Buttons\UI-GroupLoot-Pass-Down]=]
            if not (character.syncIcon) then
                character.syncIcon = 0
            end
            character.id = index
            table.insert(filteredResults, character)
        end
    end
    -- TODO: This really should not be necessary, but I can't figure out how to get StdUi to sort our primary column by desc by default...
    PepeCharacterViewer:ApplyDefaultSort(filteredResults)

    self.currentView = filteredResults
    self.characterWindow.searchResults:SetData(self.currentView, true)
    PepeCharacterViewer:UpdateStateText()
    PepeCharacterViewer:UpdateResultsText()
end

function PepeCharacterViewer:DrawConfirmationWindow()
    local buttons = {
        yes = {
            text = "Yes",
            onClick = function(b)
                local db = PepeGoldTracker.db.global.characters
                table.remove(db, self.id)
                PepeCharacterViewer:SearchChar("")
                PepeGoldTracker:Print(L["Character %s deleted successfully"]:format(self.name))
                b.window:Hide()
                PepeCharacterViewer:Toggle()
            end
        },
        no = {
            text = "No",
            onClick = function(b)
                b.window:Hide()
                PepeCharacterViewer:Toggle()
            end
        },
    }

    StdUi:Confirm(L["Delete character"], L["Are you sure you want to delete %s"]:format(self.name), buttons, 1)
end

function PepeCharacterViewer:ApplyDefaultSort(tableToSort)
    if (self.characterWindow.searchResults.head.columns) then
        local isSorted = false

        for k, v in pairs(self.characterWindow.searchResults.head.columns) do
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

function PepeCharacterViewer:UpdateResultsText()
    if (#self.currentView > 0) then
        local totalGold = 0
        for _, character in pairs(self.currentView) do
            totalGold = totalGold + character.gold
        end
        self.characterWindow.resultsLabel:SetText(PepeGoldTracker:formatGold(totalGold, true))
        self.characterWindow.resultsLabel:Show()

        self.characterWindow.countLabel:SetText(L["Current results: %s"]:format(#self.currentView))
        self.characterWindow.countLabel:Show()
    else
        self.characterWindow.resultsLabel:Hide()
        self.characterWindow.countLabel:Hide()
    end
end