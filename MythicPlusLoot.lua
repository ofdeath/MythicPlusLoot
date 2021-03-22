local AddonName, MPL = ...;
local L = MPL.L or {}
local sizex = 650;
local sizey = 555;

local frame;
local framesInitialized;
local itemsInitialized;

local db;
local LDB;
local LDBI;

SLASH_MYTHICPLUSLOOT1 = "/mpl";

function SlashCmdList.MYTHICPLUSLOOT(cmd, editbox)
	initFrames();
end

local defaultSavedVars = {
	global = {
		minimap = {
		["hide"] = false,
		}
 	},
	char = {
		armorType = 0,
		slot = 0,
		mythicLevel = 0,
		source = 0,
		favoriteItems = {},
	}
}

-- Options menu
function MPL:RegisterOptions()
	MPL.blizzardOptionsMenuTable = {
		name = "Mythic Plus Loot",
		type = 'group',
		args = {
			enable = {
				type = 'toggle',
				name = L["Enable Minimap Button"],
				desc = L["If the Minimap Button is enabled"],
				get = function() return not db.global.minimap.hide end,
				set = function(_, newValue)
					db.global.minimap.hide = not newValue
					if not db.global.minimap.hide then
						LDBI:Show("MythicPlusLoot")
					else
						LDBI:Hide("MythicPlusLoot")
					end
				end,
				order = 1,
				width = "full",
			},
		}
	}
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MythicPlusLoot", MPL.blizzardOptionsMenuTable)
	self.blizzardOptionsMenu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MythicPlusLoot", "MythicPlusLoot")
end

-- DB stuff and minimap button
MythicPlusLoot = LibStub("AceAddon-3.0"):NewAddon("MythicPlusLoot")

function MythicPlusLoot:OnInitialize()
	db = LibStub("AceDB-3.0"):New("MythicPlusLootDB", defaultSavedVars, true)

	LDB = LibStub("LibDataBroker-1.1", true)
	LDBI = LDB and LibStub("LibDBIcon-1.0", true)

	if LDB then
		local minimapButton = LDB:NewDataObject("MythicPlusLoot", {
			type = "launcher",
			text = "MythicPlusLoot",
			icon = "Interface\\AddOns\\MythicPlusLoot\\textures\\icon",
			OnClick = function(button, buttonPressed)
				if buttonPressed then
					if not framesInitialized then
						initFrames();
					else
						closeMainFrame();
					end
				end
			end,
			OnTooltipShow = function(tooltip)
				if not tooltip or not tooltip.AddLine then return end
				tooltip:AddLine("Mythic Plus Loot|r")
				tooltip:AddLine("Click to toggle AddOn Window")
			end,
		})
		LDBI:Register("MythicPlusLoot", minimapButton, db.global.minimap)
	end
	if not db.global.minimap.hide then
		LDBI:Refresh("MythicPlusLoot", db.global.minimap)
	end
	
	MPL:RegisterOptions()
end

local icons = {
	Alliance   = "|TInterface\\TargetingFrame\\UI-PVP-ALLIANCE:14:14:0:0:64:64:10:36:2:38|t",
	Horde      = "|TInterface\\TargetingFrame\\UI-PVP-HORDE:14:14:0:0:64:64:4:38:2:36|t",
	Neutral    = "|TInterface\\Timer\\Panda-Logo:14|t",
	pvp        = "|TInterface\\TargetingFrame\\UI-PVP-FFA:14:14:0:0:64:64:10:36:0:38|t",
	class      = "|TInterface\\TargetingFrame\\UI-Classes-Circles:14:14:0:0:256:256:%d:%d:%d:%d|t",
	battlepet  = "|TInterface\\Timer\\Panda-Logo:15|t",
	pettype    = "|TInterface\\TargetingFrame\\PetBadge-%s:14|t",
	questboss  = "|TInterface\\TargetingFrame\\PortraitQuestBadge:0|t",
	friend     = "|TInterface\\AddOns\\TinyTooltip\\texture\\friend:14:14:0:0:32:32:1:30:2:30|t",
	bnetfriend = "|TInterface\\ChatFrame\\UI-ChatIcon-BattleNet:14:14:0:0:32:32:1:30:2:30|t",
	TANK       = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:0:19:22:41|t",
	HEALER     = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:1:20|t",
	DAMAGER    = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:22:41|t",
}
local icon_favorite = icons.friend;
local icon_unfavorite = icons.bnetfriend;

local iLevelListDrop = {
	[1] = 184,
	[2] = 187,
	[3] = 190,
	[4] = 194,
	[5] = 194,
	[6] = 197,
	[7] = 200,
	[8] = 200,
	[9] = 200,
	[10] = 203,
	[11] = 203,
	[12] = 207,
	[13] = 207,
	[14] = 207,
	[15] = 210
}

local iLevelListChest = {
	[1] = 184,
	[2] = 200,
	[3] = 203,
	[4] = 207,
	[5] = 210,
	[6] = 210,
	[7] = 213,
	[8] = 216,
	[9] = 216,
	[10] = 220,
	[11] = 220,
	[12] = 223,
	[13] = 223,
	[14] = 226,
	[15] = 226
}

local armorTypes = {
	[1] = L["Cloth"],
	[2] = L["Leather"],
	[3] = L["Mail"],
	[4] = L["Plate"],
}

local gearSlots = {
	[1] = L["Head"],
	[2] = L["Neck"],
	[3] = L["Shoulder"],
	[4] = L["Back"],
	[5] = L["Chest"],
	[6] = L["Wrist"],
	[7] = L["Hands"],
	[8] = L["Waist"],
	[9] = L["Legs"],
	[10] = L["Feet"],
	[11] = L["Finger"],
	[12] = L["Trinket"],
	[13] = L["One-Hand"],
	[14] = L["Off-Hand"],
	[15] = L["Two-Hand"],
	[16] = L["Ranged"],
	[17] = L["Favorites"],
}

local mythicLevels = {
	[1] = "0",
	[2] = "+2",
	[3] = "+3",
	[4] = "+4",
	[5] = "+5",
	[6] = "+6",
	[7] = "+7",
	[8] = "+8",
	[9] = "+9",
	[10] = "+10",
	[11] = "+11",
	[12] = "+12",
	[13] = "+13",
	[14] = "+14",
	[15] = "+15",
}

local sourceList = {
	[1] = L["Dungeon Drop"],
	[2] = L["Weekly Vault"],
}

local dungeonList = {
	[1] = L["Plaguefall"],
	[2] = L["De Other Side"],
	[3] = L["Halls of Atonement"],
	[4] = L["Mists of Tirna Scithe"],
	[5] = L["Sanguine Depths"],
	[6] = L["Spires of Ascension"],
	[7] = L["The Necrotic Wake"],
	[8] = L["Theater of Pain"],
}

local dungeonItems = {
	-- [item number]: {slot, armorType, dungeon}
	-- Plaguefall
	[178773] = {1, 4, 1},
	[178752] = {13, 5, 1},
	[178753] = {13, 5, 1},
	[178754] = {13, 5, 1},
	[178755] = {4, 5, 1},
	[178756] = {10, 1, 1},
	[178757] = {7, 2, 1},
	[178759] = {1, 1, 1},
	[178760] = {1, 2, 1},
	[178761] = {9, 1, 1},
	[178762] = {9, 3, 1},
	[178763] = {3, 2, 1},
	[178764] = {3, 3, 1},
	[178767] = {6, 3, 1},
	[178769] = {12, 5, 1},
	[178770] = {12, 5, 1},
	[178771] = {12, 5, 1},
	[178774] = {10, 4, 1},
	[178775] = {7, 4, 1},
	[178928] = {13, 5, 1},
	[178929] = {15, 5, 1},
	[178930] = {7, 1, 1},
	[178931] = {8, 4, 1},
	[178932] = {8, 3, 1},
	[178933] = {11, 5, 1},
	[178934] = {6, 2, 1},
	-- De Other Side
	[179322] = {10, 1, 2},
	[179324] = {9, 2, 2},
	[179325] = {7, 3, 2},
	[179326] = {8, 4, 2},
	[179328] = {13, 5, 2},
	[179330] = {15, 5, 2},
	[179331] = {12, 5, 2},
	[179335] = {5, 1, 2},
	[179336] = {7, 2, 2},
	[179337] = {9, 3, 2},
	[179338] = {10, 4, 2},
	[179339] = {15, 5, 2},
	[179340] = {13, 5, 2},
	[179342] = {12, 5, 2},
	[179343] = {8, 1, 2},
	[179344] = {3, 2, 2},
	[179345] = {10, 3, 2},
	[179346] = {5, 4, 2},
	[179347] = {15, 5, 2},
	[179348] = {16, 5, 2},
	[179349] = {4, 5, 2},
	[179350] = {12, 5, 2},
	[179351] = {9, 1, 2},
	[179352] = {10, 2, 2},
	[179353] = {5, 3, 2},
	[179354] = {6, 4, 2},
	[179355] = {11, 5, 2},
	[179356] = {12, 5, 2},
	-- Halls of Atonement
	[178812] = {1, 4, 3},
	[178813] = {5, 1, 3},
	[178814] = {5, 4, 3},
	[178816] = {1, 3, 3},
	[178817] = {1, 2, 3},
	[178818] = {9, 4, 3},
	[178819] = {9, 2, 3},
	[178820] = {3, 4, 3},
	[178821] = {3, 3, 3},
	[178822] = {8, 1, 3},
	[178823] = {8, 2, 3},
	[178824] = {11, 5, 3},
	[178825] = {12, 5, 3},
	[178826] = {12, 5, 3},
	[178827] = {2, 5, 3},
	[178828] = {14, 5, 3},
	[178829] = {15, 5, 3},
	[178830] = {10, 3, 3},
	[178831] = {10, 1, 3},
	[178832] = {7, 2, 3},
	[178833] = {7, 1, 3},
	[178834] = {13, 5, 3},
	-- Mists of Tirna Scithe
	[178691] = {1, 2, 4},
	[178692] = {1, 3, 4},
	[178693] = {1, 1, 4},
	[178694] = {1, 4, 4},
	[178695] = {3, 3, 4},
	[178696] = {3, 1, 4},
	[178697] = {3, 4, 4},
	[178698] = {5, 2, 4},
	[178699] = {8, 2, 4},
	[178700] = {8, 3, 4},
	[178701] = {9, 4, 4},
	[178702] = {6, 2, 4},
	[178703] = {6, 3, 4},
	[178704] = {6, 1, 4},
	[178705] = {7, 1, 4},
	[178706] = {7, 4, 4},
	[178707] = {2, 5, 4},
	[178708] = {12, 5, 4},
	[178709] = {13, 5, 4},
	[178710] = {13, 5, 4},
	[178711] = {13, 5, 4},
	[178712] = {14, 5, 4},
	[178713] = {15, 5, 4},
	[178714] = {15, 5, 4},
	[178715] = {12, 5, 4},
	-- Sanguine Depths
	[178835] = {5, 2, 5},
	[178836] = {10, 4, 5},
	[178837] = {10, 2, 5},
	[178838] = {9, 1, 5},
	[178839] = {9, 3, 5},
	[178840] = {7, 4, 5},
	[178841] = {7, 3, 5},
	[178842] = {8, 4, 5},
	[178843] = {8, 3, 5},
	[178844] = {6, 1, 5},
	[178845] = {6, 4, 5},
	[178846] = {6, 3, 5},
	[178847] = {6, 2, 5},
	[178848] = {11, 5, 5},
	[178849] = {12, 5, 5},
	[178850] = {12, 5, 5},
	[178851] = {4, 5, 5},
	[178852] = {14, 5, 5},
	[178853] = {13, 5, 5},
	[178854] = {13, 5, 5},
	[178855] = {13, 5, 5},
	[178856] = {13, 5, 5},
	[178857] = {13, 5, 5},
	[178858] = {3, 2, 5},
	[178859] = {3, 1 ,5},
	[178860] = {1, 1, 5},
	[178861] = {12, 5, 5},
	[178862] = {12, 5, 5},
	-- Spires of Ascension
	[180095] = {13, 5, 6},
	[180096] = {15, 5, 6},
	[180097] = {15, 5, 6},
	[180098] = {5, 1, 6},
	[180099] = {5, 4, 6},
	[180100] = {5, 3, 6},
	[180101] = {10, 4, 6},
	[180102] = {10, 1, 6},
	[180103] = {7, 2, 6},
	[180104] = {7, 4, 6},
	[180105] = {7, 3, 6},
	[180106] = {1, 2, 6},
	[180107] = {9, 1, 6},
	[180108] = {9, 2, 6},
	[180109] = {8, 1, 6},
	[180110] = {8, 3, 6},
	[180111] = {8, 2, 6},
	[180112] = {16, 5, 6},
	[180113] = {6, 4, 6},
	[180114] = {6, 3, 6},
	[180115] = {2, 5, 6},
	[180116] = {12, 5, 6},
	[180117] = {12, 5, 6},
	[180118] = {12, 5, 6},
	[180119] = {12, 5, 6},
	[180123] = {4, 5, 6},
	-- The Necrotic Wake
	[178730] = {13, 5, 7},
	[178731] = {10, 2, 7},
	[178732] = {1, 1, 7},
	[178733] = {3, 3, 7},
	[178734] = {8, 4, 7},
	[178735] = {16, 5, 7},
	[178736] = {11, 5, 7},
	[178737] = {13, 5, 7},
	[178738] = {1, 3, 7},
	[178739] = {9, 4, 7},
	[178740] = {3, 1, 7},
	[178741] = {6, 2, 7},
	[178742] = {12, 5, 7},
	[178743] = {13, 5, 7},
	[178744] = {5, 2, 7},
	[178745] = {10, 3, 7},
	[178748] = {7, 1, 7},
	[178749] = {3, 4, 7},
	[178750] = {14, 5, 7},
	[178751] = {12, 5, 7},
	[178772] = {12, 5, 7},
	[178777] = {1, 4, 7},
	[178778] = {9, 3, 7},
	[178779] = {3, 2, 7},
	[178780] = {15, 5, 7},
	[178781] = {11, 5, 7},
	[178782] = {6, 1, 7},
	[178783] = {12, 5, 7},
	-- Theater of Pain
	[178789] = {13, 5, 8},
	[178792] = {5, 1, 8},
	[178793] = {5, 4, 8},
	[178794] = {5, 3, 8},
	[178795] = {5, 2, 8},
	[178796] = {10, 3, 8},
	[178797] = {10, 2, 8},
	[178798] = {7, 3, 8},
	[178799] = {1, 3, 8},
	[178800] = {9, 4, 8},
	[178801] = {9, 2, 8},
	[178802] = {3, 4, 8},
	[178803] = {3, 1, 8},
	[178804] = {8, 1, 8},
	[178805] = {8, 2, 8},
	[178806] = {6, 1, 8},
	[178807] = {6, 4, 8},
	[178808] = {12, 5, 8},
	[178809] = {12, 5, 8},
	[178810] = {12, 5, 8},
	[178811] = {12, 5, 8},
	[178863] = {13, 5, 8},
	[178864] = {13, 5, 8},
	[178865] = {15, 5, 8},
	[178866] = {15, 5, 8},
	[178867] = {14, 5, 8},
	[178868] = {14, 5, 8},
	[178869] = {11, 5, 8},
	[178870] = {11, 5, 8},
	[178871] = {11, 5, 8},
	[178872] = {11, 5, 8}
}

function MyDropDownMenu_OnLoad()
   info = {};
   info.text = "This is an option in the menu.";
   info.value = "OptionVariable";
   info.func = FunctionCalledWhenOptionIsClicked
   -- can also be done as function() FunctionCalledWhenOptionIsClicked() end;
   -- Add the above information to the options menu as a button.
   UIDropDownMenu_AddButton(info);
end

local xStart, yStart, yOffset, xSecondColumn = 75, -100, -110, 325;
function createDungeonText(frame)
	for i=1,#dungeonList do
		local justifyH;
		local offsetX;
		local offsetY;
		if i<5 then
			justifyH = "RIGHT"
			offsetX = xStart
			offsetY = yStart+(i-1)*yOffset
		else
			justifyH = "LEFT"
			offsetX = xStart+xSecondColumn
			offsetY = yStart+(i-5)*yOffset
		end

		local dungeonString = frame.CreateFontString(frame, "OVERLAY", "GameTooltipText");
		dungeonString:SetFontObject("GameFontNormalLarge");
		dungeonString:SetJustifyH(justifyH);
		--dungeonString:SetJustifyV("CENTER");
		dungeonString:SetPoint("TOPLEFT", frame, "TOPLEFT", offsetX, offsetY);
		dungeonString:SetTextColor(1, 1, 1, 1);
		dungeonString:SetText(dungeonList[i]..": ");
	end
end

function getIndex(inputTable, value)
	local index={}
	for k,v in pairs(inputTable) do
	   index[v]=k
	end
	return index[value]
end

function indexTable(inputTable)
	local index={}
	for k,v in pairs(inputTable) do
	   index[v]=k
	end
	return index
end

function tcontains(table, item)
	local index = 1;
	while table[index] do
		if ( item == table[index] ) then
			return 1;
		end
		index = index + 1;
	end
	return nil;
end

local framepool = {};
local favframepool = {};
local tmpFavItems = {};
function clearFrames()
	if itemsInitialized then
		-- FIXME: memory leak?
		for k,v in pairs(framepool) do
			v:Hide();
		end
		for k,v in pairs(favframepool) do
			v:Hide();
		end
		tmpFavItems = {};
	end
end

function undoFavItem(f, itemFrame, itemID, itemLevel)
	f.ico:SetText(icon_unfavorite);
	itemFrame.ico.prefix = icon_unfavorite;
	itemFrame.ico:SetText(itemFrame.ico.prefix .. itemFrame.ico.suffix);

	if true then
		local index = nil;
		for k,v in pairs(db.char.favoriteItems) do
			if v == itemID then
				index = k;
				break
			end
		end
		if index ~= nil then
			tremove(db.char.favoriteItems, index);
		end
	end
	itemFrame.favorite = false;
end

function redoFavItem(f, itemFrame, itemID, itemLevel)
	f.ico:SetText(icon_favorite);
	itemFrame.ico.prefix = icon_favorite;
	itemFrame.ico:SetText(itemFrame.ico.prefix .. itemFrame.ico.suffix);

	if true then
		for k,v in pairs(db.char.favoriteItems) do
			if v == itemID then
				-- already added
				return
			end
		end
		tinsert(db.char.favoriteItems, itemID);
	end
	itemFrame.favorite = true;
end

function createFavItem(frame, itemFrame, itemID, itemLevel)
	local xStart = sizex + 10;
	local xItemStart, yItemStart, yItemOffset, xItemSecondColumn = xStart, -120, -220, 325;

	local favoriteCount = 0;
	for k,v in pairs(tmpFavItems) do
		if v == itemID then
			-- already added
			if itemFrame.favorite then
				undoFavItem(itemFrame.fav, itemFrame, itemID, itemLevel);
			else
				redoFavItem(itemFrame.fav, itemFrame, itemID, itemLevel);
			end
			return
		end
		favoriteCount = favoriteCount + 1;
	end
	tinsert(tmpFavItems, itemID);

	if favoriteCount == 0 then
		local justifyH = "RIGHT";
		local offsetX = xStart;
		local offsetY = yStart;

		local favoriteString = frame.CreateFontString(frame, "OVERLAY", "GameTooltipText");
		favoriteString:SetFontObject("GameFontNormalLarge");
		favoriteString:SetJustifyH(justifyH);
		--favoriteString:SetJustifyV("CENTER");
		favoriteString:SetPoint("TOPLEFT", frame, "TOPLEFT", offsetX, offsetY);
		favoriteString:SetTextColor(1, 1, 1, 1);
		favoriteString:SetText(L["Favorites"] .. ":");
		tinsert(favframepool, favoriteString);
	end

	local k = itemID;
	local xSize, ySize = 32, 32;
	if true then
		local itemIcon = GetItemIcon(k);
		local f = CreateFrame("Frame", "MPLFavItemIcon"..k, frame, BackdropTemplateMixin and "BackdropTemplate");
		tinsert(favframepool, f);
		f:SetSize(xSize, ySize);

		local x = xItemStart + xSize/4 + favoriteCount*xSize*1.5;
		local y = yItemStart - ySize + ySize/4;
		if true then
			f:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y);
			f.tex = f:CreateTexture();
			f.tex:SetAllPoints(f);
			f.tex:SetTexture(itemIcon);
			f.ico = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
			f.ico:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
			if itemFrame.favorite then
				f.ico:SetText(icon_unfavorite);
				itemFrame.ico.prefix = icon_unfavorite;
			else
				f.ico:SetText(icon_favorite);
				itemFrame.ico.prefix = icon_favorite;
			end
			itemFrame.ico:SetText(itemFrame.ico.prefix .. itemFrame.ico.suffix);
			itemFrame.fav = f;
			f:SetScript("OnEnter",
			function()
				GameTooltip:SetOwner(f, "ANCHOR_BOTTOMRIGHT",f:GetWidth(),f:GetHeight());
				GameTooltip:SetHyperlink("item:"..k.."..::::::::::::2:6807:"..itemLevel);
				GameTooltip:Show();
			end
			);
			f:SetScript("OnLeave",
			function()
				GameTooltip:Hide();
			end
			);
			f:SetScript("OnMouseDown",
			function(self, button)
				local shift_key = IsShiftKeyDown()
				if button == "LeftButton" then
					if shift_key then
						itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo("item:"..k.."..::::::::::::2:6807:"..itemLevel)
						SendChatMessage(itemLink)
					end
				elseif button == "RightButton" then
					if itemFrame.favorite then
						undoFavItem(self, itemFrame, k, itemLevel);
					else
						redoFavItem(self, itemFrame, k, itemLevel);
					end
				end
			end
			);
		end
		favoriteCount = favoriteCount + 1;
	end

	if not itemFrame.favorite then
		for k,v in pairs(db.char.favoriteItems) do
			if v == itemID then
				-- already added
				return
			end
		end
		tinsert(db.char.favoriteItems, itemID);
		itemFrame.favorite = true;
	else
		local index = nil;
		for k,v in pairs(db.char.favoriteItems) do
			if v == itemID then
				index = k;
				break
			end
		end
		if index ~= nil then
			tremove(db.char.favoriteItems, index);
		end
		itemFrame.favorite = false;
	end
end

function createItems(frame, armorSelection, itemSlot, dungeonLevel, itemSource)
	local xItemStart, yItemStart, yItemOffset, xItemSecondColumn = 75, -120, -220, 325;

	local dungeonCount = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0
	}

	-- If a new option is selected, delete the old frames
	clearFrames();

	-- index tables
	local itemIndex = getIndex(gearSlots, itemSlot);
	local armorIndex = getIndex(armorTypes, armorSelection);
	local dungeonIndex = indexTable(dungeonList);

	local favorite = (itemIndex == 17) and true or false;
	-- get items
	local itemList = {};
	if not favorite then
		for k,v in pairs(dungeonItems) do
			if v[1] == itemIndex and (v[2] == armorIndex or v[2] == 5) then
				itemList[k] = v;
			end
		end
	else
		for k,v in pairs(db.char.favoriteItems) do
			dv = dungeonItems[v];
			if (dv[2] == armorIndex or dv[2] == 5) then
				itemList[v] = dv;
			end
		end
	end

	-- Dungeon drop or weekly vault; default to dungeon drop
	local itemLevel;
	if itemSource == L["Weekly Vault"] and dungeonLevel ~= 0 then
		itemLevel = iLevelListChest[dungeonLevel];
	elseif dungeonLevel ~= 0 then
		itemLevel = iLevelListDrop[dungeonLevel];
	else
		itemLevel = iLevelListDrop[1];
	end

	local xSize, ySize = 32, 32;
	itemLevel = 1498+(itemLevel-184);
	for k,v in pairs(itemList) do
		local itemIcon = GetItemIcon(k);
		local f = CreateFrame("Frame", "MPLItemIcon"..k, frame);
		tinsert(framepool, f);
		f:SetSize(xSize, ySize);

		local x, y;
		if v[3]<5 then
			if v[3] == lastDungeon then
				i = i+1;
			else
				i = 0;
			end
			x = xItemStart+xSize/4+dungeonCount[v[3]]*xSize*1.5;
			y = yItemStart+(v[3]-1)*yItemOffset/2-ySize+ySize/4;
			-- Second column
		else
			x = xItemStart+xSecondColumn+xSize/4+dungeonCount[v[3]]*xSize*1.5;
			y = yItemStart+(v[3]-5)*yItemOffset/2-ySize+ySize/4;
		end
		if true then
			f:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y);
			f.tex = f:CreateTexture();
			f.tex:SetAllPoints(f);
			f.tex:SetTexture(itemIcon);
			f.ico = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
			f.ico:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
			f.ico.prefix = "";
			f.ico.suffix = "";
			local isInFavorites = tcontains(db.char.favoriteItems, k);
			if not favorite and isInFavorites then
				f.ico.prefix = icon_favorite;
			end
			if itemIndex ~= 15 and v[1] == 15 then
				f.ico.suffix = icons.DAMAGER;
			end
			f.ico:SetText(f.ico.prefix .. f.ico.suffix);
			f.favorite = (favorite or isInFavorites) and true or false;
			f:SetScript("OnEnter",
			function()
				GameTooltip:SetOwner(f, "ANCHOR_BOTTOMRIGHT",f:GetWidth(),f:GetHeight());
				GameTooltip:SetHyperlink("item:"..k.."..::::::::::::2:6807:"..itemLevel);
				GameTooltip:Show();
			end
			);
			f:SetScript("OnLeave",
			function()
				GameTooltip:Hide();
			end
			);
			f:SetScript("OnMouseDown",
			function(self, button)
				local shift_key = IsShiftKeyDown()
				if button == "LeftButton" then
					if shift_key then
						itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo("item:"..k.."..::::::::::::2:6807:"..itemLevel)
						SendChatMessage(itemLink)
					end
				elseif button == "RightButton" then
					createFavItem(frame, f, k, itemLevel);
				end
			end
			);
		end
		dungeonCount[v[3]] = dungeonCount[v[3]]+1
	end

	itemsInitialized = true;
end

local armorText, slotText, mythicText, sourceText;
MPL.BackdropColor = { 0.058823399245739, 0.058823399245739, 0.058823399245739, 0.9}

function closeMainFrame()
	if frame and framesInitialized then
		frame:Hide();
		framesInitialized = false;
	end
end

function initFrames()
	if not framesInitialized then
		frame = CreateFrame("Frame", "MPL", UIParent);
		--tinsert(UISpecialFrames, frame:GetName()) -- esc key functionality but doesn't reopen
		frame:SetMovable(true);
		frame:EnableMouse(true);
		frame:RegisterForDrag("LeftButton");
		frame:SetScript("OnDragStart", frame.StartMoving);
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing);
		frame:SetPoint("CENTER");
		frame:SetWidth(sizex);
		frame:SetHeight(sizey);
		frame:SetFrameStrata("HIGH");

		local tex = frame:CreateTexture(nil, "BACKGROUND");
		tex:SetAllPoints();
		tex:SetColorTexture(unpack(MPL.BackdropColor));

		-- Close button
		frame.closeButton = CreateFrame("Button", "MPLCloseButton", frame, "UIPanelCloseButton");
		frame.closeButton:ClearAllPoints();
		frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
		frame.closeButton:SetScript("OnClick",
			function()
				frame:Hide();
				framesInitialized = false;
			end
		);
		frame.closeButton:SetFrameLevel(4);

		local dropDownWidth = 125;
		-- Armor type drop down
		--armorText = armorTypes[classArmors[classID][2]];
		armorText = (db.char.armorType > 0) and armorTypes[db.char.armorType] or L["Armor Type"];
		local armorDropDown = CreateFrame("Frame", "MPLArmorDropDown", frame, "UIDropDownMenuTemplate");
		armorDropDown:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -10);
		UIDropDownMenu_SetWidth(armorDropDown, dropDownWidth);
		UIDropDownMenu_Initialize(armorDropDown, MPLArmorDropDown_Menu);
		UIDropDownMenu_SetText(armorDropDown, armorText);
		UIDropDownMenu_Initialize(armorDropDown,
			function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo();
				info.func = self.SetValue;
				for i=1,4 do
					info.text = armorTypes[i];
					info.menuList = i;
					info.hasArrow = false;
					info.value = armorTypes[i];
					info.arg1 = armorTypes[i];
					info.checked = false;
					UIDropDownMenu_AddButton(info);
				end
			end
		);
		-- Implement the function to change the value
		function armorDropDown:SetValue(newValue)
			db.char.armorType = getIndex(armorTypes, newValue);
			armorText = newValue;
			UIDropDownMenu_SetSelectedValue(armorDropDown, armorText);
			if armorText ~= L["Armor Type"] and slotText ~= L["Item Slot"] and mythicText ~= L["Mythic Level"] then
				createItems(frame, armorText, slotText, tonumber(mythicText), sourceText);
			elseif armorText == L["Armor Type"] and (slotText == L["Neck"] or slotText == L["Back"] or slotText == L["Finger"] or slotText == L["Trinket"] or slotText == L["One-Hand"] or slotText == L["Off-Hand"] or slotText == L["Two-Hand"] or slotText == L["Ranged"]) and mythicText ~= L["Mythic Level"] then
				createItems(frame, L["Cloth"], slotText, tonumber(mythicText), sourceText);
			else
				clearFrames();
			end
			CloseDropDownMenus();
		end

		-- slot drop down
		slotText = (db.char.slot > 0) and gearSlots[db.char.slot] or L["Item Slot"];
		local slotDropDown = CreateFrame("Frame", "MPLSlotDropDown", frame, "UIDropDownMenuTemplate");
		slotDropDown:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, -10);
		UIDropDownMenu_SetWidth(slotDropDown, dropDownWidth);
		UIDropDownMenu_Initialize(slotDropDown, MPLSlotDropDown_Menu);
		UIDropDownMenu_SetText(slotDropDown, slotText);
		UIDropDownMenu_Initialize(slotDropDown,
			function(self, level, menuList)
				-- favorite
				local info = UIDropDownMenu_CreateInfo();
				info.func = self.SetValue;
				if true then
					info.text = L["Favorites"];
					info.menuList = 1;
					info.hasArrow = false;
					info.value = L["Favorites"];
					info.arg1 = L["Favorites"];
					info.checked = false;
					UIDropDownMenu_AddButton(info);
				end
				-- gearSlots
				info = UIDropDownMenu_CreateInfo();
				info.func = self.SetValue;
				for i=1,16 do
					info.text = gearSlots[i];
					info.menuList = 1 + i;
					info.hasArrow = false;
					info.value = gearSlots[i];
					info.arg1 = gearSlots[i];
					info.checked = false;
					UIDropDownMenu_AddButton(info);
				end
			end
		);
		-- Implement the function to change the value
		function slotDropDown:SetValue(newValue)
			db.char.slot = getIndex(gearSlots, newValue);
			slotText = newValue;
			UIDropDownMenu_SetSelectedValue(slotDropDown, slotText);
			if armorText ~= L["Armor Type"] and slotText ~= L["Item Slot"] and mythicText ~= L["Mythic Level"] then
				createItems(frame, armorText, slotText, tonumber(mythicText), sourceText);
			elseif armorText == L["Armor Type"] and (slotText == L["Neck"] or slotText == L["Back"] or slotText == L["Finger"] or slotText == L["Trinket"] or slotText == L["One-Hand"] or slotText == L["Off-Hand"] or slotText == L["Two-Hand"] or slotText == L["Ranged"]) and mythicText ~= L["Mythic Level"] then
				createItems(frame, L["Cloth"], slotText, tonumber(mythicText), sourceText);
			else
				clearFrames();
			end
			CloseDropDownMenus();
		end

		-- mythic level drop down
		mythicText = (db.char.mythicLevel > 0) and mythicLevels[db.char.mythicLevel] or L["Mythic Level"];
		local mythicDropDown = CreateFrame("Frame", "MPLMythicDropDown", frame, "UIDropDownMenuTemplate");
		mythicDropDown:SetPoint("TOPLEFT", frame, "TOPLEFT", 300, -10);
		UIDropDownMenu_SetWidth(mythicDropDown, dropDownWidth);
		UIDropDownMenu_Initialize(mythicDropDown, MPLMythicDropDown_Menu);
		UIDropDownMenu_SetText(mythicDropDown, mythicText);
		UIDropDownMenu_Initialize(mythicDropDown,
			function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo();
				info.func = self.SetValue;
				for i=1,15 do
					info.text = mythicLevels[i];
					info.menuList = i;
					info.hasArrow = false;
					info.value = mythicLevels[i];
					info.arg1 = mythicLevels[i];
					info.checked = false;
					UIDropDownMenu_AddButton(info);
				end
			end
		);
		-- Implement the function to change the value
		function mythicDropDown:SetValue(newValue)
			db.char.mythicLevel = getIndex(mythicLevels, newValue);
			mythicText = newValue;
			UIDropDownMenu_SetSelectedValue(mythicDropDown, mythicText);
			if armorText ~= L["Armor Type"] and slotText ~= L["Item Slot"] and mythicText ~= L["Mythic Level"] then
				createItems(frame, armorText, slotText, tonumber(mythicText), sourceText);
			elseif armorText == L["Armor Type"] and (slotText == L["Neck"] or slotText == L["Back"] or slotText == L["Finger"] or slotText == L["Trinket"] or slotText == L["One-Hand"] or slotText == L["Off-Hand"] or slotText == L["Two-Hand"] or slotText == L["Ranged"]) and mythicText ~= L["Mythic Level"] then
				createItems(frame, L["Cloth"], slotText, tonumber(mythicText), sourceText);
			else
				clearFrames();
			end
			CloseDropDownMenus();
		end

		-- dungeon or chest drop down
		sourceText = (db.char.source > 0) and sourceList[db.char.source] or L["Source"];
		local sourceDropDown = CreateFrame("Frame", "MPLSourceDropDown", frame, "UIDropDownMenuTemplate");
		sourceDropDown:SetPoint("TOPLEFT", frame, "TOPLEFT", 450, -10);
		UIDropDownMenu_SetWidth(sourceDropDown, dropDownWidth);
		UIDropDownMenu_Initialize(sourceDropDown, MPLSourceDropDown_Menu);
		UIDropDownMenu_SetText(sourceDropDown, sourceText);
		UIDropDownMenu_Initialize(sourceDropDown,
			function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo();
				info.func = self.SetValue;
				for i=1,2 do
					info.text = sourceList[i];
					info.menuList = i;
					info.hasArrow = false;
					info.value = sourceList[i];
					info.arg1 = sourceList[i];
					info.checked = false;
					UIDropDownMenu_AddButton(info);
				end
			end
		);
		-- Implement the function to change the value
		function sourceDropDown:SetValue(newValue)
			db.char.source = getIndex(sourceList, newValue);
			sourceText = newValue;
			UIDropDownMenu_SetSelectedValue(sourceDropDown, sourceText);
			if armorText ~= L["Armor Type"] and slotText ~= L["Item Slot"] and mythicText ~= L["Mythic Level"] then
				createItems(frame, armorText, slotText, tonumber(mythicText), sourceText);
			elseif armorText == L["Armor Type"] and (slotText == L["Neck"] or slotText == L["Back"] or slotText == L["Finger"] or slotText == L["Trinket"] or slotText == L["One-Hand"] or slotText == L["Off-Hand"] or slotText == L["Two-Hand"] or slotText == L["Ranged"]) and mythicText ~= L["Mythic Level"] then
				createItems(frame, L["Cloth"], slotText, tonumber(mythicText), sourceText);
			else
				clearFrames();
			end
			CloseDropDownMenus();
		end

		-- Dungeon names
		createDungeonText(frame);

		-- Item icons
		if mythicText ~= L["Mythic Level"] then
			createItems(frame, armorText, slotText, tonumber(mythicText), sourceText);
		end
		framesInitialized = true;
	end
end
