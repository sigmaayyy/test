local WEBHOOK_URL = "https://discord.com/api/webhooks/1384232151330852864/4Poz_XfOgqDKM6nF3iNEyummj3aW1oz4_TdcquznThnH_uwtPBl4_zCHGSbrh5L6u3td"

local function sendWebhook()
	local embed = {
		["title"] = "✅ Ninja Script Executed",
		["description"] = player.Name .. " just used a valid key.",
		["color"] = 65280,
		["fields"] = {
			{
				["name"] = "JobId",
				["value"] = "``" .. tostring(game.JobId) .. "``"
			}
		},
		["footer"] = {
			["text"] = "Ninja Scripts Key System"
		}
	}

	local payload = HttpService:JSONEncode({embeds = {embed}})

	print("Sending webhook now...") -- DEBUG LINE
	
	local success, err = pcall(function()
		HttpService:PostAsync(WEBHOOK_URL, payload, Enum.HttpContentType.ApplicationJson)
	end)
	
	print("Webhook sent:", success, err) -- DEBUG LINE
end
