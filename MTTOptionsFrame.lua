local addonName, MTT = ...

function MTT:InitializeOptions()
	local panel = CreateFrame("Frame")
	panel.name = addonName

	local cb1 = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	cb1:SetPoint("TOPLEFT", 20, -20)
	cb1.Text:SetText("Show Player Average Item Level")

	cb1:HookScript("OnClick", function(_, btn, down)
		local checked = cb1:GetChecked()
		MTTDB.showPlayerIL = checked

		-- Generate the frame and display if checked or hide
		if MTTPlayerFrame and not checked then
			MTTPlayerFrame:Hide()
		elseif checked then
			if MTTPlayerFrame then
				MTTPlayerFrame:Show()
			else
				MTT:DisplayPlayerItemLevel()
			end
		end
	end)
	cb1:SetChecked(MTTDB.showPlayerIL) -- set the initial checked state

	local cb2 = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	cb2:SetPoint("TOPLEFT", 20, -60)
	cb2.Text:SetText("Show Inspection Average Item Level")

	cb2:HookScript("OnClick", function(_, btn, down)
		local checked = cb2:GetChecked()
		MTTDB.showInspectPlayerIL = checked

		if MTTInspectFrame and not checked then
			MTTInspectFrame:Hide()
		elseif MTTInspectFrame and checked then
			MTTInspectFrame:Show()
		end
	end)
	cb2:SetChecked(MTTDB.showInspectPlayerIL) -- set the initial checked state

	InterfaceOptions_AddCategory(panel)
end

-- TODO: Is bug where if you turn on the flag to show player iL after first loading in with it off it doesn't show
-- >> Need to make the player inspection one above call the display function
-- Also move the other functions to the MTT namespace
