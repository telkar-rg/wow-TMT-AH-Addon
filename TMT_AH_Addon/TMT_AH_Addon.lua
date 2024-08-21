
--------------------------------------------------------------------------------------------------------
--                                        TMT_AH_Addon variables                                        --
--------------------------------------------------------------------------------------------------------
local TMT_AH_Addon_OldGetAuctionItemInfo;
local TMT_AH_Addon_AlreadyHooked;
local TMT
local tex_1 = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0\124t" 	-- Square
local tex_2 = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0\124t" 	-- Circle

--------------------------------------------------------------------------------------------------------
--                                          TMT_AH_Addon events                                         --
--------------------------------------------------------------------------------------------------------
function TMT_AH_Addon_OnLoad()
	-- Register events
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("AUCTION_HOUSE_SHOW");
end

function TMT_AH_Addon_OnEvent(event, arg1)
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
	local itemLink = GetAuctionItemLink(list, offset_p1)
	local itemId = strmatch(itemLink, "\124c%x+\124Hitem:(%d+):.+\124h.+\124h\124r")
	-- print("--", offset_p1, itemLink, gsub(itemLink,"\124","!"))
	local tmt_known_1, tmt_known_2
	if itemId then
		itemId = tonumber(itemId)
		tmt_known_1 = TMT:checkItemId(itemId)
		
		if tmt_known_1 then
			name = tex_1 .. " " .. name
		else
			tmt_known_2 = TMT:checkUniqueId(itemId)
			if tmt_known_2 and next(tmt_known_2) then
				name = tex_2 .. " " .. name
			end
		end
	end
	
	-- if ( (list == "list") and (bidAmount > 0) ) then
		-- name = name.."|cffffff00".." ("..L["bid"]..")".."|r";
	-- end
	return name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, sold;
end
