local X_OFFSET = 50;
local Y_OFFSET = -14;
local function MakeSpellButton(i)
    local name = "SpellButton" .. i;
    local button = CreateFrame("CheckButton", name, SpellBookFrame, "SpellButtonTemplate");
    button:SetID(i);
    return button
end
local function GetSpellButton(i)
    local button = getglobal("SpellButton" .. i);
    if button == nil then
        button = MakeSpellButton(i);
    end
    return button;
end
local function MakeRankString(i)
    local button = getglobal("SpellButton" .. i);
    local rankString = button:CreateFontString("SpellButton" .. i .. "RankText", "ARTWORK");
    rankString:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    rankString:SetJustifyH("RIGHT");
    rankString:SetPoint("TOPLEFT", button, "TOPLEFT", -2, -3);
    rankString:SetWidth(36);
    rankString:SetHeight(10);
end
local function MakeSpellNameString(i)
    local button = getglobal("SpellButton" .. i);
    local spellNameString = button:CreateFontString("SpellButton" .. i .. "SpellNameText", "ARTWORK");
    spellNameString:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE");
    spellNameString:SetJustifyH("CENTER");
    spellNameString:SetPoint("BOTTOMLEFT", button);
    spellNameString:SetWidth(36);
    spellNameString:SetHeight(16);
    spellNameString:SetNonSpaceWrap(true); -- Auto Wrap, not perfect but get the job done
end
local function PuntOffScreen(widget)
    -- Hide() and SetAlpha(0) were insufficient, so...
    widget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 5000);
end
local function SetupGrid()
    -- Player spell list assumes 2 columns for putting similar spells in the same column
    --    e.g. at indices 1, 3, 5
    -- So lay out buttons like it's simultaneously showing 3 pages of 2 columns each
    local i = 1;
    for subpage = 1, 3 do
        for row = 1, 6 do
            for column = 1, 2 do
                local button = GetSpellButton(i);
                PuntOffScreen(getglobal("SpellButton" .. i .. "SpellName"));
                PuntOffScreen(getglobal("SpellButton" .. i .. "SubSpellName"));
                MakeRankString(i);
                MakeSpellNameString(i);
                if i == 1 then
                    -- Leave first button in place
                elseif row == 1 and column == 1 then
                    button:SetPoint("TOPLEFT", "SpellButton" .. (i - 11), "TOPLEFT", X_OFFSET, 0);
                elseif column == 1 then
                    button:SetPoint("TOPLEFT", "SpellButton" .. (i - 2), "BOTTOMLEFT", 0, Y_OFFSET);
                else
                    button:SetPoint("TOPLEFT", "SpellButton" .. (i - 1), "TOPLEFT", X_OFFSET, 0);
                end
                i = i + 1;
            end
        end
    end
    SPELLS_PER_PAGE = i - 1; -- Update for SpellBookFrame.lua
end
-- Hook to update rank text
local Original_SpellButton_UpdateButton = SpellButton_UpdateButton;
function SpellButton_UpdateButton()
    Original_SpellButton_UpdateButton();
	if not this:IsVisible() then
		return;
	end
	local name = this:GetName();
	local rankString = getglobal(name.."RankText");
	local subSpellString = getglobal(name.."SubSpellName");
	local spellNameString = getglobal(name.."SpellNameText");
	
    if not subSpellString:IsVisible() then
        rankString:Hide();
        spellNameString:Hide();
        return;
    end
    
    local subSpellName = subSpellString:GetText();
    if subSpellName ~= nil and string.find(subSpellName, "Rank ") ~= nil then
        rankString:SetText(string.sub(subSpellName, 6));
        rankString:Show();
    else
        rankString:Hide();
    end
    
    local id = SpellBook_GetSpellID(this:GetID());
    local spellName, _ = GetSpellName(id, SpellBookFrame.bookType);
    if spellName and spellNameString then
        -- Troncate if too long
        local displayName = spellName;
        if string.len(displayName) > 15 then
            displayName = string.sub(displayName, 1, 15) .. "..";
        end
        spellNameString:SetText(displayName);
        spellNameString:Show();
    else
        spellNameString:Hide();
    end
end
-- Hook tooltip to add now-hidden subSpellName line
local Original_SpellButton_OnEnter = SpellButton_OnEnter;
function SpellButton_OnEnter()
    Original_SpellButton_OnEnter();
    local id = SpellBook_GetSpellID(this:GetID());
    local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
    GameTooltipTextRight1:SetText(subSpellName);
    GameTooltipTextRight1:SetTextColor(0.5, 0.5, 0.5);
    GameTooltipTextRight1:Show();
    GameTooltip:Show(); -- Needed to update the tooltip's size
end
SetupGrid();
