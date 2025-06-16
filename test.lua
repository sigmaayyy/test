local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- Webhook URL for notifications
local WEBHOOK_URL = "https://discord.com/api/webhooks/1384232151330852864/4Poz_XfOgqDKM6nF3iNEyummj3aW1oz4_TdcquznThnH_uwtPBl4_zCHGSbrh5L6u3td"

-- Key System Settings
local KEY_LINK = "https://link-center.net/1354045/key-system"
local VALID_KEY = "NINJA_141005bb02fc40b2af1a8fce4f019860" -- Replace with your real key if needed
local KEY_STORE_ID = "NinjaKey_" .. player.UserId
local KEY_EXPIRY_SECONDS = 7 * 24 * 60 * 60 -- 1 week

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Name = "AdvancedKeySystem"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BackgroundTransparency = 0.05
frame.AnchorPoint = Vector2.new(0.5, 0.5)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Dragging Support
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

local function createLabel(text, size, pos)
	local label = Instance.new("TextLabel", frame)
	label.Size = size
	label.Position = pos
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 24
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	return label
end

local function createButton(text, pos)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.4, 0, 0, 35)
	btn.Position = pos
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	return btn
end

local title = createLabel("🔑 Enter Your Key", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0))

local keyBox = Instance.new("TextBox", frame)
keyBox.Size = UDim2.new(0.9, 0, 0, 40)
keyBox.Position = UDim2.new(0.05, 0, 0, 60)
keyBox.PlaceholderText = "Enter or paste your key..."
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 18
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
keyBox.ClearTextOnFocus = false
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local pasteBtn = createButton("📋 Paste Key", UDim2.new(0.05, 0, 0, 120))
local getBtn = createButton("🔗 Get Key", UDim2.new(0.55, 0, 0, 120))
local checkBtn = createButton("✅ Check Key", UDim2.new(0.3, 0, 0, 180))

-- Functions
local function saveKeyData(key)
	local expiry = os.time() + KEY_EXPIRY_SECONDS
	local data = {key = key, expiry = expiry}
	pcall(function()
		writefile(KEY_STORE_ID, HttpService:JSONEncode(data))
	end)
end

local function loadSavedKey()
	local success, result = pcall(function()
		return HttpService:JSONDecode(readfile(KEY_STORE_ID))
	end)
	if success and result and result.expiry > os.time() then
		return result.key
	end
	return nil
end

local function notify(txt)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = "Key System", Text = txt, Duration = 5})
	end)
end

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
	pcall(function()
		HttpService:PostAsync(WEBHOOK_URL, payload, Enum.HttpContentType.ApplicationJson)
	end)
end

pasteBtn.MouseButton1Click:Connect(function()
	pcall(function()
		keyBox.Text = getclipboard()
	end)
end)

getBtn.MouseButton1Click:Connect(function()
	pcall(function()
		setclipboard(KEY_LINK)
	end)
	notify("Key link copied to clipboard!")
end)

local function validateAndExecute(key)
	if key == VALID_KEY then
		saveKeyData(key)
		notify("Key valid! Loading script...")
		sendWebhook()
		wait(1)
		gui:Destroy()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/sigmaayyy/badge-autofarm-hub/refs/heads/main/source.lua"))()
	else
		notify("❌ Invalid key!")
	end
end

checkBtn.MouseButton1Click:Connect(function()
	validateAndExecute((keyBox.Text or ""):gsub("%s+", ""))
end)

local savedKey = loadSavedKey()
if savedKey then
	validateAndExecute(savedKey)
end
