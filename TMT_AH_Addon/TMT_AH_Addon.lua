local addonName, addonTable = ...

local orig_print = print()
local print = function(...) print("|cFFFF4040{"..addonName.."}:|r", ...) end

--------------------------------------------------------------------------------------------------------
--                                        TMT_AH_Addon variables                                        --
--------------------------------------------------------------------------------------------------------
local TMT_AH_Addon_OldGetAuctionItemInfo;
local TMT_AH_Addon_AlreadyHooked;
local TMT
local TMT_AH_Addon_GetAuctionItemInfo -- forward declaration

local PlayerFaction, PlayerClassEN, PlayerClassLocal
local tmog_itemSubClasses = {}

local tex_1, tex_2, tex_3
do
	local size1,size2,xoffset,yoffset,dimx,dimy,coordx1,coordx2,coordy1,coordy2
	local path = "Interface\\Minimap\\TRACKING\\OBJECTICONS"
	size1 = 20
	size2 = 20
	xoffset,yoffset = 0,0
	dimx,dimy = 256,64
	coordx1 = 70
	coordx2 = coordx1 + 20
	coordy1 = 6
	coordy2 = coordy1 + 20
	
	tex_1 = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0\124t" 	-- Square
	tex_2 = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0\124t" 	-- Circle
	tex_3 = format("\124T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d\124t", path, size1, size2, xoffset, yoffset, dimx, dimy, coordx1, coordx2, coordy1, coordy2)
	coordx1 = 70 + 32
	coordx2 = coordx1 + 20
	tex_2 = format("\124T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d\124t", path, size1, size2, xoffset, yoffset, dimx, dimy, coordx1, coordx2, coordy1, coordy2)
	coordx1 = 70 + 64
	coordx2 = coordx1 + 20
	tex_1 = format("\124T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d\124t", path, size1, size2, xoffset, yoffset, dimx, dimy, coordx1, coordx2, coordy1, coordy2)
end

local tmog_allowed = {
	["ALL"] = {
		["INVTYPE_HEAD"] 		= 1,
		["INVTYPE_SHOULDER"] 	= 1,
		["INVTYPE_BODY"] 		= 1,
		["INVTYPE_CHEST"] 		= 1,
		["INVTYPE_ROBE"] 		= 1,
		["INVTYPE_WAIST"] 		= 1,
		["INVTYPE_LEGS"] 		= 1,
		["INVTYPE_FEET"] 		= 1,
		["INVTYPE_WRIST"] 		= 1,
		["INVTYPE_HAND"] 		= 1,
		["INVTYPE_CLOAK"] 		= 1,
		["INVTYPE_WEAPON"] 		= 1,
		["INVTYPE_2HWEAPON"] 	= 1,
		["INVTYPE_WEAPONMAINHAND"] 	= 1,
	},
	["WARRIOR"] = {
		["INVTYPE_WEAPONOFFHAND"] 	= 1,
		["INVTYPE_RANGEDRIGHT"] 	= 1, -- needs 2nd check
		["INVTYPE_SHIELD"] 	= 1,
		["INVTYPE_RANGED"] 	= 1,
		["INVTYPE_THROWN"] 	= 1,
	},
	["DEATHKNIGHT"] = {
		["INVTYPE_WEAPONOFFHAND"] 	= 1,
	},
	["PALADIN"] = {
		["INVTYPE_SHIELD"] 	= 1,
	},
	["PRIEST"] = {
		["INVTYPE_HOLDABLE"] 	= 1,
		["INVTYPE_RANGEDRIGHT"] = 1, -- needs 2nd check
	},
	["SHAMAN"] = {
		["INVTYPE_SHIELD"] 	= 1,
		["INVTYPE_WEAPONOFFHAND"] 	= 1,
	},
	["DRUID"] = {
		["INVTYPE_HOLDABLE"] 	= 1
	},
	["ROGUE"] = {
		["INVTYPE_WEAPONOFFHAND"] 	= 1,
		["INVTYPE_RANGED"] 	= 1,
		["INVTYPE_THROWN"] 	= 1,
		["INVTYPE_RANGEDRIGHT"] = 1, -- needs 2nd check
	},
	["MAGE"] = {
		["INVTYPE_HOLDABLE"] 	= 1,
		["INVTYPE_RANGEDRIGHT"] = 1,
	},
	["WARLOCK"] = {
		["INVTYPE_HOLDABLE"] 	= 1,
		["INVTYPE_RANGEDRIGHT"] = 1, -- needs 2nd check
	},
	["HUNTER"] = {
		["INVTYPE_WEAPONOFFHAND"] 	= 1,
		["INVTYPE_RANGED"] 	= 1,
		["INVTYPE_THROWN"] 	= 1,
		["INVTYPE_RANGEDRIGHT"] 	= 1, -- needs 2nd check
	},
	["GUNS_CROSSBOWS"] = {
		["HUNTER"] 	= 1,
		["ROGUE"] 	= 1,
		["WARRIOR"] = 1,
	},
	["WANDS"] = {
		["PRIEST"] 	= 1,
		["MAGE"] 	= 1,
		["WARLOCK"] = 1,
	},
}

--------------------------------------------------------------------------------------------------------
--                                          TMT_AH_Addon events                                         --
--------------------------------------------------------------------------------------------------------
function TMT_AH_Addon_OnLoad()
	-- stop if other AH addons are loaded
	if IsAddOnLoaded("Auc-Advanced") then
		print( "Auc-Advanced", "|cffFFFF40is loaded")
		return
	end
	if IsAddOnLoaded("Auctionator") then
		print( "Auctionator", "|cffFFFF40is loaded")
		return
	end
	
	PlayerFaction = UnitFactionGroup("player") 	-- get EN PlayerFaction
	PlayerClassLocal, PlayerClassEN = UnitClass("player") 		-- get EN PlayerClass
	
	tmog_itemSubClasses = { GetAuctionItemSubClasses(1) }
	
	-- Register events
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("AUCTION_HOUSE_SHOW");
end

function TMT_AH_Addon_OnEvent(event, ...)
	-- On load
	if ( event == "VARIABLES_LOADED" ) then
		TMT_AH_Addon_AlreadyHooked = false;
		TMT = TransmogTracker
	end

	-- Hook into GetAuctionItemInfo
	if ( (event == "AUCTION_HOUSE_SHOW") and not TMT_AH_Addon_AlreadyHooked ) then
		TMT_AH_Addon_AlreadyHooked = true;
		TMT_AH_Addon_OldGetAuctionItemInfo = GetAuctionItemInfo;
		GetAuctionItemInfo = TMT_AH_Addon_GetAuctionItemInfo;
	end
end

--------------------------------------------------------------------------------------------------------
--                                        TMT_AH_Addon functions                                        --
--------------------------------------------------------------------------------------------------------
function TMT_AH_Addon_GetAuctionItemInfo(list, offset_p1)
	local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, sold =  TMT_AH_Addon_OldGetAuctionItemInfo(list, offset_p1);
	local itemLink, itemType, itemSubType, itemEquipLoc, tmogState
	itemLink = GetAuctionItemLink(list, offset_p1)
	local itemId = strmatch(itemLink, "\124c%x+\124Hitem:(%d+):.+\124h.+\124h\124r")
	-- print("--", offset_p1, itemLink, gsub(itemLink,"\124","!"))
	local tmt_known_1, tmt_known_2
	if itemId then
		itemId = tonumber(itemId)
		_, _, _, _, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemId)
		-- print(name, itemLink, itemEquipLoc, itemType, itemSubType)
		
		-- tmt_known_1 = TMT:checkItemId(itemId)
		
		-- ################################################################
		-- ################################################################
		if TMT:checkItemId(itemId) then
			tmogState = 1 -- we know it
		elseif TMT:checkUniqueId(itemId) then
			tmogState = 2 -- we know it through others
		else
			tmogState = 3 -- we dont know it
		end
		
		
		-- check if we even want to track this
		if tmogState == 3 then
			if not (tmog_allowed.ALL[itemEquipLoc] or tmog_allowed[PlayerClassEN][itemEquipLoc]) then
				-- print("this class", PlayerClassEN, "cannot tmog", itemEquipLoc)
				tmogState = 0
			
			elseif itemEquipLoc == "INVTYPE_RANGEDRIGHT" then
				if ( itemSubType == tmog_itemSubClasses[16] ) then -- if WAND
					if not tmog_allowed.WANDS[PlayerClassEN] then
						-- print("this class", PlayerClassEN, "cannot tmog", itemSubType)
						tmogState = 0
					end
				else -- if GUNS CROSSBOWS
					if not tmog_allowed.GUNS_CROSSBOWS[PlayerClassEN] then
						-- print("this class", PlayerClassEN, "cannot tmog", itemSubType)
						tmogState = 0
					end
				end
			end
		end
		
		
		if tmogState == 1 then
			name = tex_1 .. " " .. name
		elseif tmogState == 2 then
			name = tex_2 .. " " .. name
		elseif tmogState == 3 then
			name = tex_3 .. " " .. name
		end
		
		
		
		-- ################################################################
		-- ################################################################
		
		-- if tmt_known_1 then
			-- name = tex_1 .. " " .. name
		-- else
			-- tmt_known_2 = TMT:checkUniqueId(itemId)
			-- if tmt_known_2 and next(tmt_known_2) then
				-- name = tex_2 .. " " .. name
			-- end
		-- end
	end
	
	-- if ( (list == "list") and (bidAmount > 0) ) then
		-- name = name.."|cffffff00".." ("..L["bid"]..")".."|r";
	-- end
	return name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, sold;
end
