local addonName, MTT = ...

local slotIds = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }
local MTTInspectItemCache = {}
local MTTInspectTotalItemCount = 0
local MTTPlayerItemCache = {}
local MTTPlayerTotalItemCount = 0
local configDefaults = {
	showPlayerIL = true,
	showInspectPlayerIL = true,
} 

-- Add the item level text to the tooltip
function MTT:SetToolTipText(tooltip, itemLevel, itemClassID, rowIndex, isShoppingTooltip)

	-- Weapon, Armor, or Projectile
	if itemClassID == 2 or itemClassID == 4 or itemClassID == 6 then
    local left = _G[tooltip:GetName() .. 'TextLeft' .. rowIndex]
		local leftText = left:GetText()
    
    -- There's a weird interaction with new lines for the shopping tooltips, the text gets spaces inserted on render; can't remove
    -- So instead if is shopping tt, then move then combine the existing line with the next one
    if isShoppingTooltip then
    	left:SetText("|cffffd100아이템 레벨: " .. itemLevel .. "|r")

		local nextLeft = _G[tooltip:GetName() .. 'TextLeft' .. rowIndex+1]
		nextLeft:SetText(leftText .. "|n" .. nextLeft:GetText())
  	else
  		left:SetText("|cffffd100아이템 레벨: " .. itemLevel .. "|r|n" .. leftText)
    end		

		tooltip:Show()
	end
end

-- Get the item info from the given item link provided
function MTT:GetItemInfoFromLink(link)
	if link then
		local _, _, _, itemLevel,_,_,_,_,_,_,_, classID,_ = GetItemInfo(link)

		return itemLevel, classID
	end
end

-- Modify the on hover tooltip's text to include current item context's item level
local function GameTooltipSetItem(tooltip, ...)
	if tooltip:IsForbidden() then return end

	local _, link = tooltip:GetItem()

	local itemLevel, classID = MTT:GetItemInfoFromLink(link)

	MTT:SetToolTipText(tooltip, itemLevel, classID, 2)
end

-- The first comparison tooltip when comparison modifier is true, e.g shift key pressed on hover
local function ShoppingTooltip1SetItem(tooltip, ...)
	if tooltip:IsForbidden() then return end

	local _, link = tooltip:GetItem()

	local itemLevel, classID = MTT:GetItemInfoFromLink(link)

	MTT:SetToolTipText(tooltip, itemLevel, classID, 3, true)
end

-- The second comparison tooltip when comparison modifier is true, e.g shift key pressed on hover
local function ShoppingTooltip2SetItem(tooltip, ...)
	if tooltip:IsForbidden() then return end

	local _, link = tooltip:GetItem()

	local itemLevel, classID = MTT:GetItemInfoFromLink(link)

	MTT:SetToolTipText(tooltip, itemLevel, classID, 3, true)
end

-- The third comparison tooltip when comparison modifier is true, e.g shift key pressed on hover
local function ShoppingTooltip3SetItem(tooltip, ...)
	if tooltip:IsForbidden() then return end

	local _, link = tooltip:GetItem()

	local itemLevel, classID = MTT:GetItemInfoFromLink(link)

	MTT:SetToolTipText(tooltip, itemLevel, classID, 3, true)
end

-- The on-item link click tooltip
local function ItemRefTooltipSetItem(tooltip, ...)
	if tooltip:IsForbidden() then return end

	local _, link = tooltip:GetItem()

	local itemLevel, classID = MTT:GetItemInfoFromLink(link)

	MTT:SetToolTipText(tooltip, itemLevel, classID, 2)
end

-- Display the cached result of the Inspection Item leveler 
function MTT:DisplayInspectItemLevel()

	if not MTTDB.showInspectPlayerIL then return end

	--print('total il: ', math.floor(MTTInspectItemCache["itemTotal"] / MTTInspectItemCache["itemCount"] + 0.5), ' ic: ', MTTInspectItemCache["itemCount"], ' it ', MTTInspectItemCache["itemTotal"])
	local avgIL = math.floor(MTTInspectItemCache["itemTotal"] / MTTInspectItemCache["itemCount"] + 0.5)

	-- If at least one person has been inspected, the text field will still exist
	if MTTInspectText then
		MTTInspectText:SetText("|cffffd100Avg IL: " .. avgIL .. "|r")
	else
		-- Create the frame
		local inspectTextFrame=CreateFrame("Frame", "MTTInspectFrame", InspectModelFrame)
		inspectTextFrame:SetWidth(70)
		inspectTextFrame:SetHeight(13)
		inspectTextFrame:SetPoint("CENTER", InspectModelFrame,"TOP",10,-10)

		-- Set the frame colour background
		local inspectTextFrameTexture=inspectTextFrame:CreateTexture(nil,"BACKGROUND")
		inspectTextFrameTexture:SetColorTexture(0,0,0,0.3)
		inspectTextFrameTexture:SetAllPoints(inspectTextFrame)
		inspectTextFrame.texture=inspectTextFrameTexture

		-- Create the text element on the frame
		local inspectText = inspectTextFrame:CreateFontString("MTTInspectText", "OVERLAY", "GameFontNormal")
		inspectText:SetPoint("CENTER", inspectTextFrame)
		inspectText:SetText("|cffffd100Avg IL: " .. avgIL .. "|r")
	end
end

-- Display the cached result of the Inspection Item leveler 
function MTT:DisplayPlayerItemLevel()

	if not MTTDB.showPlayerIL then return end

	--print('total il: ', math.floor(MTTInspectItemCache["itemTotal"] / MTTInspectItemCache["itemCount"] + 0.5), ' ic: ', MTTInspectItemCache["itemCount"], ' it ', MTTInspectItemCache["itemTotal"])
	local avgIL = math.floor(MTTPlayerItemCache["itemTotal"] / MTTPlayerItemCache["itemCount"] + 0.5)

	-- If at least one person has been inspected, the text field will still exist
	if MTTPlayerText then
		MTTPlayerText:SetText("|cffffd100Avg IL: " .. avgIL .. "|r")
	else
		-- Create the frame
		local playerTextFrame=CreateFrame("Frame", "MTTPlayerFrame", CharacterModelFrame)
		playerTextFrame:SetWidth(70)
		playerTextFrame:SetHeight(13)
		playerTextFrame:SetPoint("CENTER", CharacterModelFrame,"TOP",10,-10)

		-- Set the frame colour background
		local playerTextFrameTexture=playerTextFrame:CreateTexture(nil,"BACKGROUND")
		playerTextFrameTexture:SetColorTexture(0,0,0,0.3)
		playerTextFrameTexture:SetAllPoints(playerTextFrame)
		playerTextFrame.texture=playerTextFrameTexture

		-- Create the text element on the frame
		local playerText = playerTextFrame:CreateFontString("MTTPlayerText", "OVERLAY", "GameFontNormal")
		playerText:SetPoint("CENTER", playerTextFrame)
		playerText:SetText("|cffffd100Avg IL: " .. avgIL .. "|r")
	end
end

-- unit is player GUID
-- Go through the target's equipped items and request their item levels
local function InspectFrameItemLeveler(_, event, _) 

	if (event == "INSPECT_READY") then
		MTTInspectItemCache = {}
		MTTInspectItemCache["itemCount"] = 0
		MTTInspectItemCache["itemTotal"] = 0
		MTTInspectTotalItemCount = 0

    for _, slotNumber in ipairs(slotIds) do
    	local itemId = GetInventoryItemID("target", slotNumber)

    	if itemId then
				local itemLevel = select(4, GetItemInfo(itemId))

				if itemLevel then
					MTTInspectItemCache["itemTotal"] = MTTInspectItemCache["itemTotal"] + itemLevel	
					MTTInspectItemCache["itemCount"] = MTTInspectItemCache["itemCount"] + 1
    		else
    			MTTInspectItemCache[itemId] = true
  			end

				MTTInspectTotalItemCount = MTTInspectTotalItemCount + 1
			end
		end

		if MTTInspectItemCache["itemCount"] and MTTInspectItemCache["itemCount"] == MTTInspectTotalItemCount then
			MTT:DisplayInspectItemLevel()
		end
	end
end

-- Handle GET_ITEM_INFO_RECEIVED for item info requested that wasn't in the cache
function MTT:HandleItemInfo(itemId)

	-- Handle fringe case of player open character info && inspection and there is a common item that wasn't in the cache
	if MTTInspectItemCache[itemId] and MTTPlayerItemCache[itemId] then 
		local itemLevel = select(4, GetItemInfo(itemId))

		MTTPlayerItemCache["itemTotal"] = MTTPlayerItemCache["itemTotal"] + itemLevel
		MTTPlayerItemCache["itemCount"] = MTTPlayerItemCache["itemCount"] + 1
		MTTPlayerItemCache[itemId] = nil

		MTTInspectItemCache["itemTotal"] = MTTInspectItemCache["itemTotal"] + itemLevel
		MTTInspectItemCache["itemCount"] = MTTInspectItemCache["itemCount"] + 1
		MTTInspectItemCache[itemId] = nil

		if MTTInspectItemCache["itemCount"] and MTTInspectItemCache["itemCount"] == MTTInspectTotalItemCount then
			MTT:DisplayInspectItemLevel()			
		end

		if MTTPlayerItemCache["itemCount"] and MTTPlayerItemCache["itemCount"] == MTTPlayerTotalItemCount then
			MTT:DisplayPlayerItemLevel()			
		end
	elseif MTTInspectItemCache[itemId] then
		local itemLevel = select(4, GetItemInfo(itemId))
		MTTInspectItemCache["itemTotal"] = MTTInspectItemCache["itemTotal"] + itemLevel
		MTTInspectItemCache["itemCount"] = MTTInspectItemCache["itemCount"] + 1
		MTTInspectItemCache[itemId] = nil

		if MTTInspectItemCache["itemCount"] and MTTInspectItemCache["itemCount"] == MTTInspectTotalItemCount then
			MTT:DisplayInspectItemLevel()			
		end
	elseif MTTPlayerItemCache[itemId] then
		local itemLevel = select(4, GetItemInfo(itemId))
		MTTPlayerItemCache["itemTotal"] = MTTPlayerItemCache["itemTotal"] + itemLevel
		MTTPlayerItemCache["itemCount"] = MTTPlayerItemCache["itemCount"] + 1
		MTTPlayerItemCache[itemId] = nil

		if MTTPlayerItemCache["itemCount"] and MTTPlayerItemCache["itemCount"] == MTTPlayerTotalItemCount then
			MTT:DisplayPlayerItemLevel()			
		end
	end
end

-- Get the player's avg IL
function MTT:GetPlayerAvgIL(_, _)
	MTTPlayerItemCache = {}
	MTTPlayerItemCache["itemCount"] = 0
	MTTPlayerItemCache["itemTotal"] = 0
	MTTPlayerTotalItemCount = 0

	for _, slotNumber in ipairs(slotIds) do
  	local itemId = GetInventoryItemID("player", slotNumber)

  	if itemId then
			local itemLevel = select(4, GetItemInfo(itemId))

			if itemLevel then
				MTTPlayerItemCache["itemTotal"] = MTTPlayerItemCache["itemTotal"] + itemLevel
				MTTPlayerItemCache["itemCount"] = MTTPlayerItemCache["itemCount"] + 1
  		else
  			MTTPlayerItemCache[itemId] = true
			end

			MTTPlayerTotalItemCount = MTTPlayerTotalItemCount + 1
		end
	end

	if MTTPlayerItemCache["itemCount"] and MTTPlayerItemCache["itemCount"] == MTTPlayerTotalItemCount then
		MTT:DisplayPlayerItemLevel()			
	end
end

local function eventHandler(_, event, arg1, _) 
	if event == "GET_ITEM_INFO_RECEIVED" then
		MTT:HandleItemInfo(arg1)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
		MTT:GetPlayerAvgIL(arg1)
	end
end

-- Hook Scripts up to when an item's information is added to a tooltip before render
function MTT:Init()
	-- Set DB defaults on first load
	if MTTDB == nil then
    MTTDB = configDefaults
  end

  MTT:InitializeOptions()

	GameTooltip:HookScript("OnTooltipSetItem", GameTooltipSetItem)
	ItemRefTooltip:HookScript("OnTooltipSetItem", ItemRefTooltipSetItem)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", ShoppingTooltip1SetItem)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", ShoppingTooltip2SetItem)
	--ShoppingTooltip3:HookScript("OnTooltipSetItem", ShoppingTooltip3SetItem) -- Don't think the third one ever gets used

	-- Create & register event handler
	local infoFrame = CreateFrame("Frame")
	infoFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	infoFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	infoFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	infoFrame:SetScript("OnEvent", eventHandler)			
end

-- Hook the inspect & player frame up once the blizzard inspect addon has loaded
function MTT:HookInspectPaperDolls()
    InspectPaperDollFrame:HookScript("OnEvent", InspectFrameItemLeveler)
end

-- Self Initialise
local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function(_, event, addon)
    if (event == "ADDON_LOADED") then
      if (addon == addonName) then   		
          MTT:Init()
      end

			if (addon == "Blizzard_InspectUI") then
				MTT:HookInspectPaperDolls()
			end
    end
	end)

-- Possibly useful in the future for reconstructing GameToolip
--[=====[
function RedrawToolTip(tooltip) 

	local nextLeft
	local nextRight
	local numLines = tooltip:NumLines()

	for i = 1, numLines - 1 do
	    nextLeft = _G["GameTooltipTextLeft" .. i + 1]:GetText()
	    nextRight = _G["GameTooltipTextRight" .. i + 1]:GetText()
	    local currentLeft = _G["GameTooltipTextLeft" .. i]:GetText()
	    local currentRight  = _G["GameTooltipTextRight" .. i]:GetText()

	    _G["GameTooltipTextLeft" .. i + 1]:SetText(currentLeft)
	    _G["GameTooltipTextRight" .. i + 1]:SetText(currentRight)
	end

	--tooltip:AddLine(' ')
	--tooltip["GameTooltipTextLeft" .. numLines + 1]:SetText(nextLeft)
    --tooltip["GameTooltipTextRight" .. numLines + 1]:SetText(nextRight)
end 
--]=====]
