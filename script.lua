-- script.lua (LocalScript)
-- Place as a LocalScript inside StarterGui (or inside a ScreenGui in StarterGui)
-- Requires: ReplicatedStorage.Module.fishing (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- require module (assumes Module folder exists in ReplicatedStorage with fishing ModuleScript)
local moduleFolder = ReplicatedStorage:WaitForChild("Module")
local Fishing = require(moduleFolder:WaitForChild("fishing"))

-- ========== UI Creation (Modern style) ==========
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishingUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 420, 0, 280)
main.Position = UDim2.new(0.5, -210, 0.65, -140)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(245,245,247)
main.BorderSizePixel = 0
main.Parent = screenGui

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://1316045217"
shadow.BackgroundTransparency = 1
shadow.Size = UDim2.new(1,20,1,20)
shadow.Position = UDim2.new(0,-10,0,-10)
shadow.ImageTransparency = 0.85
shadow.ZIndex = 0
shadow.Parent = main

-- Top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,60)
top.BackgroundTransparency = 1
top.Parent = main

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0,44,0,44)
logo.Position = UDim2.new(0, 12, 0, 8)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://4483362458"
logo.Parent = top

local title = Instance.new("TextLabel")
title.Text = "🎣 Fishing Console"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(36,36,36)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,68,0,6)
title.Size = UDim2.new(0.5, -68, 0, 26)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local brand = Instance.new("TextLabel")
brand.Text = "Alvin Script"
brand.Font = Enum.Font.GothamBold
brand.TextSize = 16
brand.TextColor3 = Color3.fromRGB(255,65,65) -- red
brand.BackgroundTransparency = 1
brand.Position = UDim2.new(0.62, -20, 0, 8)
brand.Size = UDim2.new(0.38, -40, 0, 26)
brand.TextXAlignment = Enum.TextXAlignment.Right
brand.Parent = top

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,36,0,36)
toggleBtn.Position = UDim2.new(1, -46, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(230,230,230)
toggleBtn.Text = "✕"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = top

-- Body
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -40, 1, -96)
body.Position = UDim2.new(0,20,0,64)
body.BackgroundTransparency = 1
body.Parent = main

-- Left column (controls)
local left = Instance.new("Frame")
left.Size = UDim2.new(0,200,1,0)
left.BackgroundTransparency = 1
left.Parent = body

local function makeButton(parent, y, txt)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,44)
	b.Position = UDim2.new(0,0,0,y)
	b.BackgroundColor3 = Color3.fromRGB(60,130,255)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Text = txt
	b.BorderSizePixel = 0
	b.Parent = parent
	local cr = Instance.new("UICorner", b)
	cr.CornerRadius = UDim.new(0,8)
	return b
end

local castBtn = makeButton(left, 0, "CAST")
local autoFishBtn = makeButton(left, 0.2, "AutoFish: OFF")
local autoCatchBtn = makeButton(left, 0.4, "AutoCatch: OFF")
local blatantBtn = makeButton(left, 0.6, "Blatant x1")

-- Right column (status & settings)
local right = Instance.new("Frame")
right.Size = UDim2.new(1, -220, 1, 0)
right.Position = UDim2.new(0, 220, 0, 0)
right.BackgroundTransparency = 1
right.Parent = body

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,0,0,28)
statusLabel.Position = UDim2.new(0,0,0,0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 15
statusLabel.TextColor3 = Color3.fromRGB(80,80,80)
statusLabel.Text = "Status: Ready"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = right

local function makeLabel(parent, y, txt)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, -8, 0, 24)
	lbl.Position = UDim2.new(0, 0, 0, y)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.fromRGB(90,90,90)
	lbl.Text = txt
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = parent
	return lbl
end

local function makeBox(parent, x, y, placeholder)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(0.5, -8, 0, 26)
	tb.Position = UDim2.new(x, 8, 0, y)
	tb.PlaceholderText = placeholder
	tb.Text = ""
	tb.ClearTextOnFocus = false
	tb.Font = Enum.Font.Gotham
	tb.TextSize = 14
	tb.TextColor3 = Color3.fromRGB(40,40,40)
	tb.BackgroundColor3 = Color3.fromRGB(250,250,250)
	tb.BorderSizePixel = 0
	tb.Parent = parent
	local cr = Instance.new("UICorner", tb)
	cr.CornerRadius = UDim.new(0,6)
	return tb
end

local fishDelayLabel = makeLabel(right, 40, "Delay Fish (s):")
local fishDelayBox = makeBox(right, 0, 40, "1.0")
local catchDelayLabel = makeLabel(right, 74, "Delay Catch (s):")
local catchDelayBox = makeBox(right, 0, 74, "0.1")

-- Progress bar
local progressBG = Instance.new("Frame")
progressBG.Size = UDim2.new(1,0,0,10)
progressBG.Position = UDim2.new(0,0,1,-18)
progressBG.BackgroundColor3 = Color3.fromRGB(230,230,230)
progressBG.BorderSizePixel = 0
progressBG.Parent = main
local progress = Instance.new("Frame")
progress.Size = UDim2.new(0,0,1,0)
progress.BackgroundColor3 = Color3.fromRGB(60,130,255)
progress.BorderSizePixel = 0
progress.Parent = progressBG
local pbCorner = Instance.new("UICorner", progress)
pbCorner.CornerRadius = UDim.new(0,6)

-- UI polish corners
for _,v in pairs({main, toggleBtn, castBtn, autoFishBtn, autoCatchBtn, blatantBtn, fishDelayBox, catchDelayBox, progressBG}) do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,8)
	c.Parent = v
end

-- initial states
local uiOpen = true
local autoFishOn = false
local autoCatchOn = false
local blatantVal = 1

-- helper functions connecting to module
local function applyDelaysToModule()
	local fd = tonumber(fishDelayBox.Text) or 1.0
	local cd = tonumber(catchDelayBox.Text) or 0.1
	Fishing.SetDelays(fd, cd)
end

local function applyBlatantToModule()
	Fishing.SetBlatantMultiplier(blatantVal)
end

-- UI interactions
toggleBtn.MouseButton1Click:Connect(function()
	uiOpen = not uiOpen
	main.Visible = uiOpen
end)

castBtn.MouseButton1Click:Connect(function()
	statusLabel.Text = "Status: Casting..."
	Fishing.Cast()
end)

autoFishBtn.MouseButton1Click:Connect(function()
	autoFishOn = not autoFishOn
	if autoFishOn then
		autoFishBtn.Text = "AutoFish: ON"
		autoFishBtn.BackgroundColor3 = Color3.fromRGB(40,180,110)
		applyDelaysToModule()
		applyBlatantToModule()
		Fishing.StartAutoFish({ fishDelay = tonumber(fishDelayBox.Text) or 1.0, blatantMultiplier = blatantVal })
	else
		autoFishBtn.Text = "AutoFish: OFF"
		autoFishBtn.BackgroundColor3 = Color3.fromRGB(60,130,255)
		Fishing.StopAutoFish()
	end
end)

autoCatchBtn.MouseButton1Click:Connect(function()
	autoCatchOn = not autoCatchOn
	if autoCatchOn then
		autoCatchBtn.Text = "AutoCatch: ON"
		autoCatchBtn.BackgroundColor3 = Color3.fromRGB(40,180,110)
		Fishing.StartAutoCatch({ catchDelay = tonumber(catchDelayBox.Text) or 0.1 })
	else
		autoCatchBtn.Text = "AutoCatch: OFF"
		autoCatchBtn.BackgroundColor3 = Color3.fromRGB(60,130,255)
		Fishing.StopAutoCatch()
	end
end)

blatantBtn.MouseButton1Click:Connect(function()
	if blatantVal == 1 then blatantVal = 5
	elseif blatantVal == 5 then blatantVal = 10
	else blatantVal = 1
	end
	blatantBtn.Text = "Blatant x" .. tostring(blatantVal)
	if blatantVal > 1 then
		blatantBtn.BackgroundColor3 = Color3.fromRGB(255,120,80)
	else
		blatantBtn.BackgroundColor3 = Color3.fromRGB(60,130,255)
	end
	applyBlatantToModule()
end)

-- Keyboard quick-test: R to trigger self-bite (safe local test)
UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.R then
		-- if not casting, Cast then trigger bite quickly
		if not Fishing.GetStatus().isCasting then
			Fishing.Cast()
		end
		-- small delay to simulate immediate bite if desired (or 0)
		task.wait(0.1)
		Fishing.TriggerBite()
	end
end)

-- React to module updates
Fishing.onUpdate(function(payload)
	if not payload or type(payload) ~= "table" then return end
	local typ = payload.Type
	local data = payload.Data or {}

	if typ == "CastStarted" then
		statusLabel.Text = "Status: Line casted..."
		progress:TweenSize(UDim2.new(0.18,0,1,0), "Out", "Quad", 0.25, true)
	elseif typ == "Bite" then
		statusLabel.Text = "Status: Bite detected!"
		progress:TweenSize(UDim2.new(0.9,0,1,0), "Out", "Quad", 0.12, true)
		-- if autoCatch on, module will catch automatically; otherwise you can auto-call Catch
		if autoCatchOn then
			-- module auto-catch loop will pick it up; if you want, you can explicitly call Catch()
			-- Fishing.Catch()
		end
	elseif typ == "Caught" then
		statusLabel.Text = "Status: Fish caught!"
		progress:TweenSize(UDim2.new(1,0,1,0), "Out", "Quad", 0.18, true)
		task.delay(0.8, function()
			progress:TweenSize(UDim2.new(0,0,1,0), "Out", "Quad", 0.2, true)
			statusLabel.Text = "Status: Ready"
		end)
	elseif typ == "AutoFishToggled" then
		statusLabel.Text = "Status: AutoFish " .. (data.enabled and "ON" or "OFF")
	elseif typ == "AutoCatchToggled" then
		statusLabel.Text = "Status: AutoCatch " .. (data.enabled and "ON" or "OFF")
	elseif typ == "DelaysUpdated" then
		statusLabel.Text = string.format("Delays: fish=%.2f, catch=%.2f", data.fishDelay or 0, data.catchDelay or 0)
	elseif typ == "BlatantUpdated" then
		statusLabel.Text = "Blatant: x" .. tostring(data.blatant or 1)
	elseif typ == "Reset" then
		statusLabel.Text = "Status: Reset"
	end
end)

-- initial quick setup: set module default delays to what's in boxes
task.delay(0.2, function()
	applyDelaysToModule()
	applyBlatantToModule()
end)
