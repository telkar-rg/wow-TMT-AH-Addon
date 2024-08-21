local L = LibStub("AceLocale-3.0"):GetLocale("AH_ShowBid")

--------------------------------------------------------------------------------------------------------
--                                        AH_ShowBid variables                                        --
--------------------------------------------------------------------------------------------------------
local AH_ShowBid_OldGetAuctionItemInfo;
local AH_ShowBid_AlreadyHooked;

--------------------------------------------------------------------------------------------------------
--                                          AH_ShowBid events                                         --
--------------------------------------------------------------------------------------------------------
function AH_ShowBid_OnLoad()
	-- Register events
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("AUCTION_HOUSE_SHOW");
end

function AH_ShowBid_OnEvent(event, arg1)
	-- On load
	if ( event == "VARIABLES_LOADED" ) then
		AH_ShowBid_AlreadyHooked = false;
	end

	-- Hook into GetAuctionItemInfo
	if ( (event == "AUCTION_HOUSE_SHOW") and not AH_ShowBid_AlreadyHooked ) then
		AH_ShowBid_AlreadyHooked = true;
		AH_ShowBid_OldGetAuctionItemInfo = GetAuctionItemInfo;
		GetAuctionItemInfo = AH_ShowBid_GetAuctionItemInfo;
	end
end

--------------------------------------------------------------------------------------------------------
--                                        AH_ShowBid functions                                        --
--------------------------------------------------------------------------------------------------------
function AH_ShowBid_GetAuctionItemInfo(list, offset_p1)
	local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, sold =  AH_ShowBid_OldGetAuctionItemInfo(list, offset_p1);
	if ( (list == "list") and (bidAmount > 0) ) then
		name = name.."|cffffff00".." ("..L["bid"]..")".."|r";
	end
	return name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, sold;
end
