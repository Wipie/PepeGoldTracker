PepeGoldTracker = LibStub("AceAddon-3.0"):NewAddon("PepeGoldTracker", "AceConsole-3.0", "AceEvent-3.0")
_G["PepeGoldTracker"] = PepeGoldTracker
local StdUi = LibStub('StdUi')
local ldbi = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PepeGoldTracker")

PepeGoldTracker.color = {
    orange = '|cffd4af37',
    red = '|cffDC143C',
    lightgreen = '|cff50C878',
    lightorange = '|cffffd100',
    gray = '|cffaaaaaa',
    reset = '|r'
}
PepeGoldTracker.FRAME_LEVEL = 0
PepeGoldTracker.character = {}

SLASH_pgt1 = "/pepe"
SLASH_pgt2 = "/pepegoldtracker"
function SlashCmdList.pgt(command)
    print(tostring(command))
    command = string.lower(command)
    if (command == 'char') then
        PepeGoldTracker.charactersViewer:OpenPanel()
    elseif (command == 'guild') then
        PepeGoldTracker.guildsViewer:OpenPanel()
    elseif (command == 'version') then
        PepeGoldTracker:Print(PepeGoldTracker.colorString ..L["The current PepeGoldTracker version is: "].. GetAddOnMetadata("PepeGoldTracker", "Version"))
    elseif (command == 'realm') then
        PepeGoldTracker.currentRealm:Toggle()
    elseif (command == 'minimap') then
        PepeGoldTracker.db.global.minimap.hide = not PepeGoldTracker.db.global.minimap.hide
        ldbi:Refresh("PepeGTMinimapButton", PepeGoldTracker.db.global.minimap)
    else
        print(PepeGoldTracker.color.orange .."Pepe Gold Tracker ".. GetAddOnMetadata("PepeGoldTracker", "Version"))
        print(PepeGoldTracker.color.lightgreen ..L["Usage: |cffd4af37/pepe|r or |cffd4af37/pepegoldtracker|r followed by one the commands below"])
        print("   " .. PepeGoldTracker.color.orange .. " char "..PepeGoldTracker.color.reset ..L["- open character window"])
        print("   " .. PepeGoldTracker.color.orange .. " guild "..PepeGoldTracker.color.reset ..L["- open guild window"])
        print("   " .. PepeGoldTracker.color.orange .. " version "..PepeGoldTracker.color.reset ..L["- print the version number of the addon."])
        print("   " .. PepeGoldTracker.color.orange .. " realm "..PepeGoldTracker.color.reset ..L["- open a window showing what realm you are logged on."])
        print("   " .. PepeGoldTracker.color.orange .. " minimap "..PepeGoldTracker.color.reset ..L["- toggle visibility of minimap button"])
    end
end

function PepeGoldTracker:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PepeGoldTrackerDB", defaults)

    PepeGoldTracker:MigrateOldDatabaseSchema()
    PepeGoldTracker:DrawMinimapButton()

    -- Register modules
    self.charactersViewer = PepeGoldTracker:GetModule("PepeCharacterViewer")
    self.exportCharacter = PepeGoldTracker:GetModule("PepeExportCharacter")

    self.guildsViewer = PepeGoldTracker:GetModule("PepeGuildViewer")
    self.exportGuild = PepeGoldTracker:GetModule("PepeExportGuild")

    self.currentRealm = PepeGoldTracker:GetModule("PepeCurrentRealm")
    for name, module in self:IterateModules() do
        module:SetEnabledState(true)
    end

    PepeGoldTracker:SetupOptions() -- Options Page
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PepeGoldTracker", "PepeGoldTracker")

    print(PepeGoldTracker.color.orange .."PepeGoldTracker "..GetAddOnMetadata("PepeGoldTracker", "Version")..L[" initializated successfully"])
end

-- Executed after addon loading allowing to get data from char without having a nil value
function PepeGoldTracker:OnEnable()
    -- Char related event
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
    self:RegisterEvent("PLAYER_MONEY", "OnEvent")

    -- Guild related event
    self:RegisterEvent("GUILDBANKFRAME_OPENED", "OnEvent")
    self:RegisterEvent("GUILDBANK_UPDATE_MONEY", "OnEvent")
    self:RegisterEvent("GUILDBANKFRAME_CLOSED", "OnEvent")
end

function PepeGoldTracker:MigrateOldDatabaseSchema()
    if (not self.db.global.characters) then
        self.db.global.characters = {}
    end

    if (not self.db.global.guilds) then
        self.db.global.guilds = {}
    end

    if (not self.db.global.minimap) then
        self.db.global.minimap = { ["hide"] = false }
    end

    if (not self.db.global.autoOpenCurrentRealm) then
        self.db.global.autoOpenCurrentRealm = { ["hide"] = false }
    end
end

function PepeGoldTracker:DrawMinimapButton()
    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("PepeGTMinimapButton", {
        type = "launcher",
        icon = [=[Interface\Addons\PepeGoldTracker\media\PepeAlone.tga]=],
        OnClick = function(self)
            if (not self.menuFrame) then
                local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", UIParent, "UIDropDownMenuTemplate")
                self.menuFrame = menuFrame
            end
            local menu = {
                { text = "Pepe Gold Tracker", notCheckable = true, isTitle = true },
                { text = L["Toggle character window"], notCheckable = true, func = function()
                    PepeGoldTracker.charactersViewer:Toggle()
                end },
                { text = L["Toggle guild window"], notCheckable = true, func = function()
                    PepeGoldTracker.guildsViewer:Toggle()
                end },
                { text = L["Toggle realm window"], notCheckable = true, func = function()
                    PepeGoldTracker.currentRealm:Toggle()
                end },
            }
            EasyMenu(menu, self.menuFrame, "cursor", 0, 0, "MENU");
        end,
    })

    ldbi:Register("PepeGTMinimapButton", ldb, self.db.global.minimap)
    ldbi:Refresh("PepeGTMinimapButton", self.db.global.minimap)
end

function PepeGoldTracker:GetNextFrameLevel()
    PepeGoldTracker.FRAME_LEVEL = PepeGoldTracker.FRAME_LEVEL + 10
    return math.min(PepeGoldTracker.FRAME_LEVEL, 10000)
end

function PepeGoldTracker:SetupOptions()
    self.options = {
        name = "PepeGoldTracker",
        descStyle = "inline",
        type = "group",
        childGroups = "tab",
        args = {
            desc = {
                type = "description",
                name = L["Addon that help tracking gold stored accross your account"],
                fontSize = "medium",
                order = 1
            },
            author = {
                type = "description",
                name = PepeGoldTracker.color.lightorange..L["Author: "]..PepeGoldTracker.color.reset..GetAddOnMetadata("PepeGoldTracker", "Author") .. "\n",
                order = 2
            },
            version = {
                type = "description",
                name = PepeGoldTracker.color.lightorange..L["Version: "]..PepeGoldTracker.color.reset..GetAddOnMetadata("PepeGoldTracker", "Version") .. "\n",
                order = 3
            },
            hideminimap = {
                name = L["Show minimap icon"],
                desc = PepeGoldTracker.color.gray..L["Whether or not to show the minimap icon."]..PepeGoldTracker.color.reset,
                descStyle = "inline",
                width = "full",
                type = "toggle",
                order = 4,
                set = function(info, val)
                    PepeGoldTracker.db.global.minimap.hide = not val
                    ldbi:Refresh("PepeGTMinimapButton", PepeGoldTracker.db.global.minimap)
                end,
                get = function(info)
                    return not PepeGoldTracker.db.global.minimap.hide
                end
            },
            turnOffCurrentRealmWindow = {
                name = L["Show current realm window"],
                desc = PepeGoldTracker.color.gray..L["Auto-open the current realm window for character that are level 10 and under"]..PepeGoldTracker.color.reset,
                descStyle = "inline",
                width = "full",
                type = "toggle",
                order = 4,
                set = function(info, val)
                    PepeGoldTracker.db.global.autoOpenCurrentRealm.hide = not val
                end,
                get = function(info)
                    return not PepeGoldTracker.db.global.autoOpenCurrentRealm.hide
                end
            },
        }
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("PepeGoldTracker", self.options)
end

-- Register char if its first time logging
function PepeGoldTracker:RegisterChar()
    local name, pRealm = UnitFullName("player")
    local player = name .. "-" .. pRealm
    local guild = ""
    local date = date("%Y-%m-%d %H:%M:%S")
    self.character = {
        realm = pRealm,
        name =  player,
        faction = select(1, UnitFactionGroup("player")),
        gold = GetMoney("player"),
        date = date,
        guild = "" -- Defaulting to empty to avoid nil due since nil is breaking the sort
    }
    if not (PepeGoldTracker:CheckIfCharExist()) then
        PepeGoldTracker.db.global.characters[#PepeGoldTracker.db.global.characters + 1] = self.character
        PepeGoldTracker:Print(L["Character registered successfully."])
    end
end

-- Update char data if he is already registered
function PepeGoldTracker:UpdateChar()
    local allChars = PepeGoldTracker.db.global.characters
    local name, realm = UnitFullName("player")
    local player = name .. "-" .. realm
    local date = date("%Y-%m-%d %H:%M:%S")

    if (PepeGoldTracker:CheckIfCharExist()) then
        local index = PepeGoldTracker:getIndexByName(allChars, player)
        PepeGoldTracker.db.global.characters[index].gold = GetMoney("player")
        PepeGoldTracker.db.global.characters[index].date = date
        PepeGoldTracker.db.global.characters[index].faction = select(1, UnitFactionGroup("player"))
        PepeGoldTracker.db.global.characters[index].realm = realm
        if (select(1, GetGuildInfo("player")) ~= nil) then
            PepeGoldTracker.db.global.characters[index].guild = select(1, GetGuildInfo("player"))
        else
            PepeGoldTracker.db.global.characters[index].guild = ""
        end
    end
end

-- Register guild if its the first time openning
function PepeGoldTracker:RegisterGuild()
    local guildName = select(1, GetGuildInfo("player"))
    local date = date("%Y-%m-%d %H:%M:%S")
    local gRealm
    if (select(4, GetGuildInfo("player")) ~= nil) then -- Check if the guild is hosted on a connected realm
        gRealm = select(4, GetGuildInfo("player"))
    else
        gRealm = select(2, UnitFullName("player"))
    end

    self.guild = {
        realm = gRealm,
        name =  guildName,
        faction = select(1, UnitFactionGroup("player")),
        gold = GetGuildBankMoney(),
        date = date,
    }
    if not (PepeGoldTracker:CheckIfGuildExist()) then
        PepeGoldTracker.db.global.guilds[#PepeGoldTracker.db.global.guilds + 1] = self.guild
        PepeGoldTracker:Print(L["Guild registered successfully."])
    end
end

-- Update guild if it is already registered
function PepeGoldTracker:UpdateGuild()
    local allGuilds = PepeGoldTracker.db.global.guilds
    local date = date("%Y-%m-%d %H:%M:%S")
    local guildName = select(1, GetGuildInfo("player"))
    local gRealm
    if (select(4, GetGuildInfo("player")) ~= nil) then -- Check if the guild is hosted on a connected realm
        gRealm = select(4, GetGuildInfo("player"))
    else
        gRealm = select(2, UnitFullName("player"))
    end


    if ((PepeGoldTracker:CheckIfGuildExist()) and (guildName ~= nil) and (guildName ~= "") and (gRealm ~= nil) and (gRealm ~= "") ) then
        local index = PepeGoldTracker:getGuildIndexByName(allGuilds, guildName, gRealm)
        PepeGoldTracker.db.global.guilds[index].name = guildName
        PepeGoldTracker.db.global.guilds[index].realm = gRealm
        PepeGoldTracker.db.global.guilds[index].gold = GetGuildBankMoney()
        PepeGoldTracker.db.global.guilds[index].date = date
        PepeGoldTracker.db.global.guilds[index].faction = select(1, UnitFactionGroup("player")) -- Faction, assuming its the same as player otherwise mad sus (Using GetGuildFactionGroup require more logical operations.)
    else
        PepeGoldTracker:Print(L["An error occured while updating the guild."])
    end
end
-- Check if a character exist in the database
function PepeGoldTracker:CheckIfCharExist() 
    local allChars = PepeGoldTracker.db.global.characters
    local name, realm = UnitFullName("player")
    local player = name .. "-" .. realm
    for _, character in pairs(allChars) do
        if (character.name == player) then
            return true
        end
    end
    return false
end

-- Check if a guild exist in the database

function PepeGoldTracker:CheckIfGuildExist()
    local allGuilds = PepeGoldTracker.db.global.guilds
    local guildName = select(1, GetGuildInfo("player"))
    local guildRealm
    if (select(4, GetGuildInfo("player")) ~= nil) then -- Check if the guild is hosted on a connected realm
        guildRealm = select(4, GetGuildInfo("player"))
    else
        guildRealm = select(2, UnitFullName("player"))
    end

    for _, guild in pairs(allGuilds) do
        if ((guild.name == guildName) and (guild.realm == guildRealm)) then
            return true
        end
    end
    return false
end

function PepeGoldTracker:OnEvent(event)
    if ((event == 'PLAYER_MONEY') or (event == 'PLAYER_ENTERING_WORLD')) then
        if ((event == 'PLAYER_ENTERING_WORLD') and (UnitLevel("player") < 11) and (not PepeGoldTracker.db.global.autoOpenCurrentRealm.hide)) then
            PepeGoldTracker.currentRealm:OpenPanel()
        end
        if (PepeGoldTracker:CheckIfCharExist()) then
            PepeGoldTracker:UpdateChar()
        else
            PepeGoldTracker:RegisterChar()
        end
    elseif ((event == 'GUILDBANKFRAME_OPENED') or (event == 'GUILDBANK_UPDATE_MONEY') or (event == 'GUILDBANKFRAME_CLOSED')) then
        if (PepeGoldTracker:CheckIfGuildExist()) then 
            PepeGoldTracker:UpdateGuild()
        else
            PepeGoldTracker:RegisterGuild()
        end
    end
end

function PepeGoldTracker:formatGold(amount, onlyGold)
    local gold = floor(amount / 10000)
    local silver = floor(mod(amount / 100, 100))
    local copper = floor(mod(amount, 100))
    local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"
    local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"
    local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"

    if (onlyGold) then
        if gold > 0 then
            return format('%s%s ', BreakUpLargeNumbers(gold), goldIcon)
        elseif silver > 0 then
            return format('%d%s %d%s', silver, silverIcon, copper, copperIcon)
        else
            return format('%d%s', copper, coppername)
        end
    else

        if gold > 0 then
            return format('%s%s %d%s %d%s', BreakUpLargeNumbers(gold), goldIcon, silver, silverIcon, copper, copperIcon)
        elseif silver > 0 then
            return format('%d%s %d%s', silver, silverIcon, copper, copperIcon)
        else
            return format('%d%s', copper, copperIcon)
        end
    end
end

function PepeGoldTracker:getIndexByName (table, val)
    for i=1, #table do
        if table[i].name == val then 
           return i
        end
    end
end

function PepeGoldTracker:getGuildIndexByName (table, name, realm)
    for i=1, #table do
        if ((table[i].name == name) and (table[i].realm == realm)) then 
           return i
        end
    end
end