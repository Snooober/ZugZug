replyAdvert = nil
local replyAdvertText = "Zug, zug: https://www.curseforge.com/wow/addons/zugzug"
local conversionChars = {".", "!", "?", "^", "~"}

-- Function to check if the message contains exactly two "zug" 
function containsTwoZug(message)
    local pattern = "^[%s%p]*zug[%s%p]*zug[%s%p]*$"
    return string.match(message:lower(), pattern) ~= nil
end

-- Function to check if the message is only conversion characters
function isOnlyConversionChars(message)
    for i = 1, #message do
        local char = string.sub(message, i, i)
		local found = false
		for k, v in pairs(conversionChars) do
			if char == v then
				found = true
				break
			end
		end
		if found == false then
			return false
		end
    end
    return true
end

-- Function to check if the message is only z characters
function isZChars(message)
    return string.match(message:lower(),"^z*$") ~= nil
end

-- Function to check if the player is an Orc
function isOrc()
    local playerRace = UnitRace("player")
    return playerRace == "Orc"
end

-- Intercept chat messages before they are sent
local oldSendChatMessage = SendChatMessage
local sentFlag = false

function SendChatMessage(message, type, language, recipient, pass)
	pass = pass or false
	if isOrc() then
		if isOnlyConversionChars(message) then
			message = "Zug, zug" .. message
		end
		if isZChars(message) then
			message = "Zug, zug"
		end
	end
	if not sentFlag then
		if isOrc() then
			if containsTwoZug(message) or pass then
				oldSendChatMessage(message, type, language, recipient)
			else
				DEFAULT_CHAT_FRAME:AddMessage('ZugZug addon: Message blocked as it does not contain exactly two "zug". "/zz" or "/zugzug" for details')
			end
		else
			oldSendChatMessage(message, type, language, recipient)
		end
		sentFlag = true
	else
		sentFlag = false
	end
end

-- Create a frame for the addon's information
local infoFrame = CreateFrame("Frame", "InfoFrame", UIParent, "BasicFrameTemplateWithInset")
infoFrame:SetSize(550, 450)
infoFrame:SetPoint("CENTER")
infoFrame:SetMovable(true)
infoFrame:SetScript("OnMouseDown", function(self, button) self:StartMoving() end)
infoFrame:SetScript("OnMouseUp", function(self, button) self:StopMovingOrSizing() end)
infoFrame:Hide()

-- Create a text frame to display information
local infoText = infoFrame:CreateFontString(nil, "OVERLAY")
infoText:SetPoint("TOPLEFT", 10, -30)
infoText:SetPoint("BOTTOMRIGHT", -10, 10)
infoText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
infoText:SetJustifyH("LEFT")
infoText:SetJustifyV("TOP")
infoText:SetText('"Zug, zug Challenge" Rules:\n' ..
					"        1) Only for Orcs.\n" ..
					"        2) Can only say \"Zug, zug\" in any in-game chat or mail. This includes: say, emote, yell, party, raid,\n" ..
					"            raid_warning, instance, guild, officer, whisper, channel chats, AFK msg, DND msg, and voice_text.\n" ..
					'                    *can only use emotes that are action only, not voice.\n' ..
					'                    Example: "/wave" is allowed. "/hello" is not allowed.\n' ..
					'        3) Must be exactly two "zug"\'s. Can omit space in-between "zug"\'s or add more\n' ..
					'            spaces/punctuation.\n' ..
					"        4) Can use any form of capitalization.\n" ..
					"                    Example: \"zUg ZuG\" is allowed.\n" ..
					"        5) Can use any form of punctuation along with \"Zug zug\" as long as the punctuation highlights the\n" ..
					"            use of \"Zug zug\". Punctuation may not be used for any other reason, such as to spell out words or\n" ..
					"            1337 speak (no attempting to circumvent rules via punctuation). Emoticons allowed.\n" ..
					"                    Examples of allowed punctuation:\n" ..
					'                        "Zug, zug", "Zug, zug!", "Zug, zug?", "Zug, zug...",\n' ..
					'                        "Zug, zug?!", "#zugzug", "Zug, zug :)"\n' ..
					'        6) The addon will block the chat messages but not mail, emotes, or LFG messages. It is up to you to\n' ..
					'            follow these rules for the proper Zug, zug Challenge.\n' ..
					'        7) For third-party apps (i.e. Discord, Twitch chat), the challenge rules must be followed if conversing\n' ..
					'            to another player about activities related to your WoW character if said player is interacting with\n' ..
					'            you in the game. (If you are questing together, trading, etc.).\n' ..
					"\n" ..
					"\n" ..
					'Chat Shortcuts (send left character in chat to auto-convert to "Zug, zug" message on the right):\n' ..
					'        z -> "Zug, zug" (any # of "z"\'s)\n' ..
					'        . -> "Zug, zug."\n' ..
					'        ! -> "Zug, zug!"\n' ..
					'        ? -> "Zug, zug?"\n' ..
					'        ^ -> "Zug, zug^"\n' ..
					'        ~ -> "Zug, zug~"\n' ..
					"    Any number of the symbols will work, even mixed-and-matched:\n" ..
					'        ... -> "Zug, zug..."\n' ..
					'        ?!?! -> "Zug, zug?!?!"\n')

-- Create a close button for the frame
local closeButton = CreateFrame("Button", nil, infoFrame, "UIPanelButtonTemplate")
closeButton:SetText("Close")
closeButton:SetPoint("BOTTOM", 0, 8)
closeButton:SetSize(100, 30)
closeButton:SetScript("OnClick", function(self, button, down)
    infoFrame:Hide()
end)

-- Create a check button for reply advert
local replyAdvertCk = CreateFrame("CheckButton", "ReplyAdvertCk", infoFrame, "ChatConfigCheckButtonTemplate")
replyAdvertCk:SetPoint("BOTTOMLEFT", 10, 50)
replyAdvertCk:SetScript("OnClick", function(self, button, down)
	replyAdvert = self:GetChecked()
	if self:GetChecked() then
		DEFAULT_CHAT_FRAME:AddMessage('ZugZug addon: You will now auto-reply a link to this addon when an Orc player whispers you "Zug, zug".')
	else
		DEFAULT_CHAT_FRAME:AddMessage('ZugZug addon: You will no longer auto-reply a link to this addon when a player whispers you.')
	end
end)

-- Create text for checkbox
local replyAdvertCkText = replyAdvertCk:CreateFontString(nil, "OVERLAY")
replyAdvertCkText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
replyAdvertCkText:SetPoint("CENTER", 200, 1)
replyAdvertCkText:SetText('Auto-reply link to this addon when Orc player whispers "Zug, zug" to you.')

-- Create slash commands
SLASH_ZUGZUG1 = "/zugzug"
SLASH_ZUGZUG2 = "/zz"
SlashCmdList["ZUGZUG"] = function()
    infoFrame:Show()
end

-- Check if the player is an Orc on login
local function OnEvent(self, event, ...)
	local arg1 = select("1", ...)
	if event == "ADDON_LOADED" and arg1 == "ZugZug" then
		if replyAdvert == nil then
			replyAdvert = true
		end
		replyAdvertCk:SetChecked(replyAdvert)
	elseif event == "PLAYER_LOGIN" then
        if isOrc() then
			DEFAULT_CHAT_FRAME:AddMessage('ZugZug addon: "Zug, zug Challenge" active. "/zz" or "/zugzug" for details')
		else
            DEFAULT_CHAT_FRAME:AddMessage('ZugZug addon: You are not playing an Orc and therefore cannot participate in the "Zug, zug Challenge". Messages will not be filtered for this character. "/zz" or "/zugzug" for details')
        end
	elseif event == "CHAT_MSG_WHISPER" then
		local msg = arg1
		local playerName = select("2", ...)
		if containsTwoZug(msg) and isOrc() and replyAdvert then
			SendChatMessage(replyAdvertText, "WHISPER", nil, playerName, true)
		end
	end
end

-- Register the event listener
infoFrame:RegisterEvent("ADDON_LOADED")
infoFrame:RegisterEvent("PLAYER_LOGIN")
infoFrame:RegisterEvent("CHAT_MSG_WHISPER")
infoFrame:SetScript("OnEvent", OnEvent)

-- Hook the SendChatMessage function
hooksecurefunc("SendChatMessage", SendChatMessage)
