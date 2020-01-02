local _, core = ...; -- Namespace

local frame = CreateFrame("Frame");
frame:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
end)
frame:RegisterEvent("ADDON_LOADED")

local combat = false

function frame:ADDON_LOADED(event, ...)
	if event == "ADDON_LOADED" then
		HideErrorTextDb = HideErrorTextDb or {
			hideInCombat = true,
			hideOutOfCombat = false,
		}
		core:MaybeHideErrorText()
		self:UnclampChatFrames()
		self:LoadInterfaceOptions()
		self:UnregisterEvent("ADDON_LOADED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")

		local OrigErrHandler = UIErrorsFrame:GetScript('OnEvent')
			UIErrorsFrame:SetScript('OnEvent', function (self, event, id, err, ...)
				if event == "UI_ERROR_MESSAGE" then
					if (combat and HideErrorTextDb.hideInCombat) or (not combat and HideErrorTextDb.hideOutOfCombat) then
						if 	err == ERR_INV_FULL or
							err == ERR_QUEST_LOG_FULL or
							err == ERR_RAID_GROUP_ONLY or
							err == ERR_NOT_IN_COMBAT or
							err == ERR_PET_SPELL_DEAD or
							err == ERR_SPELL_OUT_OF_RANGE or
							err == ERR_OUT_OF_RANGE or
							err == ERR_USE_TOO_FAR or
							err == ERR_INVALID_ATTACK_TARGET or
							err == ERR_NO_PET or
							err == ERR_PLAYER_DEAD or
							err == ERR_BADATTACKPOS or
							err == ERR_BADATTACKFACING or
							err == ERR_FEIGN_DEATH_RESISTED or
							err == SPELL_FAILED_TARGET_NO_POCKETS or
							err == ERR_USE_TOO_FAR or
							err == ERR_VENDOR_TOO_FAR or
							err == ERR_ALREADY_PICKPOCKETED then
							return OrigErrHandler(self, event, id, err, ...)
						end
					else
						return OrigErrHandler(self, event, id, err, ...) 
					end
				elseif event == 'UI_INFO_MESSAGE'  then
					-- Show information messages
					return OrigErrHandler(self, event, id, err, ...)
				end
			end)
	end
end

-- Regen disabled means the player has entered combat. The entered combat event is for melee combat
-- only.
function frame:PLAYER_REGEN_DISABLED(event, ...)
	combat = true
	core:MaybeHideErrorText()
end

-- Regen enabled means the player has left combat. The left combat event is for melee combat only.
function frame:PLAYER_REGEN_ENABLED(event, ...)
	combat = false
	core:MaybeHideErrorText()
end

function frame:LoadInterfaceOptions(self)
	local loader = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	loader:SetScript('OnShow', function(self)
		self:SetScript('OnShow', nil)
		if not frame.optionsPanel then
			frame.optionsPanel = frame:CreateOptionsGui("Hide Error Text")
			InterfaceOptions_AddCategory(frame.optionsPanel);
		end
	end)
end

function frame:UnclampChatFrames(self)
	ChatFrame1:SetClampedToScreen(false)
	ChatFrame2:SetClampedToScreen(false)
	ChatFrame3:SetClampedToScreen(false)
	ChatFrame4:SetClampedToScreen(false)
	ChatFrame5:SetClampedToScreen(false)
	ChatFrame6:SetClampedToScreen(false)
	ChatFrame7:SetClampedToScreen(false)
	ChatFrame8:SetClampedToScreen(false)
	ChatFrame9:SetClampedToScreen(false)
end

local function CreateCheckbox(name, parent)
    local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    cb:SetWidth(30)
    cb:SetHeight(30)
    cb:Show()
    local cblabel = cb:CreateFontString(nil, "OVERLAY")
    cblabel:SetFontObject("GameFontHighlight")
    cblabel:SetPoint("LEFT", cb,"RIGHT", 5,0)
    cb.label = cblabel
    return cb
end

function frame:CreateOptionsGui(name, parent)
    local f = CreateFrame("Frame", nil, InterfaceOptionsFrame)
    f:Hide()

    f.parent = parent
    f.name = name

    f:SetScript("OnShow", function(self)
		self.content.combat:SetChecked(HideErrorTextDb.hideInCombat)
		self.content.nocombat:SetChecked(HideErrorTextDb.hideOutOfCombat)
    end)

    local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	label:SetPoint("TOPLEFT", 10, -15)
	label:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 10, -45)
	label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    label:SetText(name)

	local content = CreateFrame("Frame", "CADOptionsContent", f)
	content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)
    f.content = content

    local combat = CreateCheckbox(nil, content)
    combat.label:SetText("Hide error text in combat")
    combat:SetPoint("TOPLEFT", 10, -50)
	combat:SetScript("OnClick",function(self,button)
		HideErrorTextDb.hideInCombat = combat:GetChecked()
		core:MaybeHideErrorText()
	end)
	content.combat = combat
	
	local nocombat = CreateCheckbox(nil, content)
    nocombat.label:SetText("Hide error text out of combat")
    nocombat:SetPoint("TOPLEFT", 10, -80)
	nocombat:SetScript("OnClick",function(self,button)
		HideErrorTextDb.hideOutOfCombat = nocombat:GetChecked()
		core:MaybeHideErrorText()
	end)
	content.nocombat = nocombat

    return f
end

function core:MaybeHideErrorText(self)
	if false then
		if combat then
			if HideErrorTextDb.hideInCombat then
				UIErrorsFrame:Hide()
			else
				UIErrorsFrame:Clear()
				UIErrorsFrame:Show()
			end
		else
			if HideErrorTextDb.hideOutOfCombat then
				UIErrorsFrame:Hide()
			else
				UIErrorsFrame:Clear()
				UIErrorsFrame:Show()
			end
		end
	end
end
