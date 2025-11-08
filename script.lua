-- script.lua (LocalScript)
-- Single-file professional-looking fishing simulator UI (client-side simulation only)
-- Logo: 4483362458, Brand: "Alvin Script" (red)
-- Features: Cast, Catch, AutoFish, AutoCatch, Blatant x5 simulation, Delay settings, Open/Close UI, R test key
-- Safe: purely local simulation for learning / UI demo.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ---------- Configuration ----------
local LOGO_ASSET = "rbxassetid://4483362458"
local BRAND_TEXT = "Alvin Script"
local BRAND_COLOR = Color3.fromRGB(255, 65, 65) -- red
local DEFAULT_FISH_DELAY = 1.0
local DEFAULT_CATCH_DELAY = 0.1
local MIN_DELAY = 0.02

-- ---------- Internal state (simulation) ----------
local state = {
	isCasting = false,
	hasBite = false,
	hasCaught = false,
	autoFish = false,
	autoCatch = false,
	blatantMultiplier = 1,
	fishDelay = DEFAULT_FISH_DELAY,
	catchDelay = DEFAULT_CATCH_DELAY,
	_autoFishTask = nil,
	_autoCatchTask = nil,
}

-- ---------- Helper utilities ----------
local function clampDelay(d)
	d = tonumber(d) or 0
	if d < MIN_DELAY then return MIN_DELAY end
	return d
end

local function notify(msg)
	-- local feedback; could be replaced with nicer toasts
	print("[FishingSim] " .. tostring(msg))
end

-- ---------- Auto loops ----------
local function startAutoFishLoop()
	if state._autoFishTask then return end
	state._autoFishTask = task.spawn(function()
		while state.autoFish do
			local delayTime = clampDelay(state.fishDelay)
			for i = 1, math.max(1, math.floor(state.blatantMultiplier)) do
				if not state.isCasting and not state.hasCaught then
					state.isCasting = true
					state.hasBite = false
					-- notify UI
					script:FindFirstChild("__InternalNotifier") and script.__InternalNotifier:Fire("CastStarted")
					notify("AutoCast simulated")
				end
				-- tiny yield for blatant loops
				if i < state.blatantMultiplier then task.wait(0) end
			end
			task.wait(delayTime)
		end
		state._autoFishTask = nil
	end)
end

local function startAutoCatchLoop()
	if state._autoCatchTask then return end
	state._autoCatchTask = task.spawn(function()
		while state.autoCatch do
			local delayTime = clampDelay(state.catchDelay)
			if state.hasBite and state.isCasting and not state.hasCaught then
				-- instant catch
				state.hasCaught = true
				state.hasBite = false
				state.isCasting = false
				script:FindFirstChild("__InternalNotifier") and script.__InternalNotifier:Fire("Caught")
				notify("AutoCatch executed (simulated)")
			end
			task.wait(delayTime)
		end
		state._autoCatchTask = nil
	end)
end

-- ---------- Core simulated actions ----------
local function Cast()
	if state.isCasting then
		notify("Already casting")
		return false
	end
	state.isCasting = true
	state.hasBite = false
	state.hasCaught = false
	script:FindFirstChild("__InternalNotifier") and script.__InternalNotifier:Fire("CastStarted")
	notify("Cast executed (simulated)")
	return true
end

local function TriggerBite()
	if not state.isCasting then
		notify("TriggerBite ignored (not casting)")
		return false
	end
	state.hasBite = true
	script:FindFirstChild("__InternalNotifier") and script.__InternalNotifier:Fire("Bite")
	notify("Bite simulated")
	return true
end

local function Catch()
	if not state.isCasting then
		notify("Cannot catch: not casting")
		return false, "not_casting"
	end
	if not state.hasBite then
		notify("Cannot catch: no bite")
		return false, "no_bite"
	end
	if state.hasCaught then
		notify("Already caught")
		return false, "already_caught"
	end
	state.hasCaught = true
	state.hasBite = false
	state.isCasting = false
	script:FindFirstChild("__InternalNotifier") and script.__InternalNotifier:Fire("Caught")
	notify("Catch executed (simulated)")
	return true, "caught"
end

-- ---------- UI creation (modern floating window) ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishingUI_Sim"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Internal BindableEvent to notify UI parts (keeps separation)
local notifier = Instance.new("BindableEvent")
notifier.Name = "__InternalNotifier"
notifier.Parent = script

-- Main frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 440, 0, 300)
main.Position = UDim2.new(0.5, -220, 0.6, -150)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(248,248,250)
main.BorderSizePixel = 0
main.Parent = screenGui

-- soft shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://1316045217"
shadow.BackgroundTransparency = 1
shadow.Size = UDim2.new(1, 26, 1, 26)
shadow.Position = UDim2.new(0, -13, 0, -13)
shadow.ImageTransparency = 0.86
shadow.ZIndex = 0
shadow.Parent = main

-- top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 64)
top.BackgroundTransparency = 1
top.Parent = main

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 48, 0, 48)
logo.Position = UDim2.new(0, 12, 0, 8)
logo.BackgroundTransparency = 1
logo.Image = LOGO_ASSET
logo.Parent = top

local title = Instance.new("TextLabel")
title.Text = "🎣 Fishing Console"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(36,36,36)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 72, 0, 8)
title.Size = UDim2.new(0.5, -72, 0, 24)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local brand = Instance.new("TextLabel")
brand.Text = BRAND_TEXT
brand.Font = Enum.Font.GothamBold
brand.TextSize = 15
brand.TextColor3 = BRAND_COLOR
brand.BackgroundTransparency = 1
brand.Position = UDim2.new(0.62, -12, 0, 8)
brand.Size = UDim2.new(0.38, -12, 0, 24)
brand.TextXAlignment = Enum.TextXAlignment.Right
brand.Parent = top

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 36, 0, 36)
toggleBtn.Position = UDim2.new(1, -50, 0, 12)
toggleBtn.BackgroundColor3 = Color3.fromRGB(232,232,232)
toggleBtn.Text = "✕"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = top

-- body
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -40, 1, -96)
body.Position = UDim2.new(0, 20, 0, 64)
body.BackgroundTransparency = 1
body.Parent = main

-- left column (controls)
local left = Instance.new("Frame")
left.Size = UDim2.new(0, 220, 1, 0)
left.BackgroundTransparency = 1
left.Parent = body

local function makeButton(parent, y, text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 44)
	b.Position = UDim2.new(0, 0, y, 0)
	b.BackgroundColor3 = Color3.fromRGB(60,130,255)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Text = text
	b.BorderSizePixel = 0
	b.Parent = parent
	local cr = Instance.new("UICorner", b)
	cr.CornerRadius = UDim.new(0, 8)
	return b
end

local castBtn = makeButton(left, 0, "CAST")
local catchBtn = makeButton(left, 0.18, "CATCH")
local autoFishBtn = makeButton(left, 0.36, "AutoFish: OFF")
local autoCatchBtn = makeButton(left, 0.54, "AutoCatch: OFF")
local blatantBtn = makeButton(left, 0.72, "Blatant x1")

-- right column (status + controls)
local right = Instance.new("Frame")
right.Size = UDim2.new(1, -240, 1, 0)
right.Position = UDim2.new(0, 240, 0, 0)
right.BackgroundTransparency = 1
right.Parent = body

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 26)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
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
	tb.Size = UDim2.new(0.5, -8, 0, 28)
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
local fishDelayBox = makeBox(right, 0, 40, tostring(DEFAULT_FISH_DELAY))
fishDelayBox.Text = tostring(DEFAULT_FISH_DELAY)

local catchDelayLabel = makeLabel(right, 80, "Delay Catch (s):")
local catchDelayBox = makeBox(right, 0, 80, tostring(DEFAULT_CATCH_DELAY))
catchDelayBox.Text = tostring(DEFAULT_CATCH_DELAY)

-- progress bar
local progressBG = Instance.new("Frame")
progressBG.Size = UDim2.new(1, 0, 0, 10)
progressBG.Position = UDim2.new(0, 0, 1, -18)
progressBG.BackgroundColor3 = Color3.fromRGB(230,230,230)
progressBG.BorderSizePixel = 0
progressBG.Parent = main
local progress = Instance.new("Frame")
progress.Size = UDim2.new(0, 0, 1, 0)
progress.BackgroundColor3 = Color3.fromRGB(60,130,255)
progress.BorderSizePixel = 0
progress.Parent = progressBG
local pbCorner = Instance.new("UICorner", progress)
pbCorner.CornerRadius = UDim.new(0, 6)

-- UI polish
for _,v in pairs({main, toggleBtn, castBtn, catchBtn, autoFishBtn, autoCatchBtn, blatantBtn, fishDelayBox, catchDelayBox, progressBG}) do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,8)
	c.Parent = v
end

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Transparency = 0.9
stroke.Parent = main

-- make main draggable (modern feel)
local dragging = false
local dragStart = nil
local startPos = nil
top.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = inp.Position
		startPos = main.Position
		inp.Changed:Connect(function()
			if inp.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
top.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		local delta = inp.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ---------- Connect UI with simulation ----------
toggleBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

castBtn.MouseButton1Click:Connect(function()
	statusLabel.Text = "Status: Casting..."
	Cast()
end)

catchBtn.MouseButton1Click:Connect(function()
	statusLabel.Text = "Status: Attempting catch..."
	local ok, msg = Catch()
	if not ok then
		statusLabel.Text = "Status: " .. tostring(msg)
	end
end)

autoFishBtn.MouseButton1Click:Connect(function()
	state.autoFish = not state.autoFish
	if state.autoFish then
		autoFishBtn.Text = "AutoFish: ON"
		autoFishBtn.BackgroundColor3 = Color3.fromRGB(40,180,110)
		-- apply delays and blatant
		state.fishDelay = clampDelay(tonumber(fishDelayBox.Text) or DEFAULT_FISH_DELAY)
		startAutoFishLoop()
	else
		autoFishBtn.Text = "AutoFish: OFF"
		autoFishBtn.BackgroundColor3 = Color3.fromRGB(60,130,255)
		state.autoFish = false
	end
end)

autoCatchBtn.MouseButton1Click:Connect(function()
	state.autoCatch = not state.autoCatch
	if state.autoCatch then
		autoCatchBtn.Text = "AutoCatch: ON"
		autoCatchBtn.BackgroundColor3 = Color3.fromRGB(40,180,110)
		state.catchDelay = clampDelay(tonumber(catchDelayBox.Text) or DEFAULT_CATCH_DELAY)
		startAutoCatchLoop()
	else
		autoCatchBtn.Text = "AutoCatch: OFF"
		autoCatchBtn.BackgroundColor3 = Color3.fromRGB(60,130,255)
		state.autoCatch = false
	end
end)

-- blatant cycles: 1 -> 5 (x5 requested) -> 1 (toggle)
blatantBtn.MouseButton1Click:Connect(function()
	if state.blatantMultiplier == 1 then
		state.blatantMultiplier = 5
	else
		state.blatantMultiplier = 1
	end
	blatantBtn.Text = "Blatant x" .. tostring(state.blatantMultiplier)
	if state.blatantMultiplier > 1 then
		blatantBtn.BackgroundColor3 = Color3.fromRGB(255,120,80)
	else
		blatantBtn.BackgroundColor3 = Color3.fromRGB(60,130,255)
	end
end)

-- R to test: cast + quick bite (self test)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.R then
		if not state.isCasting then
			Cast()
		end
		-- tiny delay so UI shows casting
		task.delay(0.08, function()
			TriggerBite()
		end)
	end
end)

-- ---------- UI update based on internal notifications ----------
notifier.Event:Connect(function(eventType)
	if eventType == "CastStarted" then
		statusLabel.Text = "Status: Line casted..."
		progress:TweenSize(UDim2.new(0.18,0,1,0), "Out", "Quad", 0.25, true)
	elseif eventType == "Bite" then
		statusLabel.Text = "Status: Bite detected!"
		progress:TweenSize(UDim2.new(0.9,0,1,0), "Out", "Quad", 0.12, true)
		-- if autoCatch is ON then auto-catch loop will try to catch
		if state.autoCatch then
			-- nothing to do; loop will catch
		else
			-- if user wants immediate manual catch, they press CATCH button
		end
	elseif eventType == "Caught" then
		statusLabel.Text = "Status: Fish caught!"
		progress:TweenSize(UDim2.new(1,0,1,0), "Out", "Quad", 0.18, true)
		task.delay(0.7, function()
			progress:TweenSize(UDim2.new(0,0,1,0), "Out", "Quad", 0.2, true)
			statusLabel.Text = "Status: Ready"
		end)
	end
end)

-- ---------- Small UX: update delays when textboxes change ----------
fishDelayBox.FocusLost:Connect(function(enter)
	local v = tonumber(fishDelayBox.Text)
	if v and v >= MIN_DELAY then
		state.fishDelay = v
		statusLabel.Text = string.format("Fish delay set to %.2f s", state.fishDelay)
	else
		fishDelayBox.Text = tostring(state.fishDelay)
		statusLabel.Text = "Invalid fish delay (kept previous)"
	end
end)

catchDelayBox.FocusLost:Connect(function(enter)
	local v = tonumber(catchDelayBox.Text)
	if v and v >= MIN_DELAY then
		state.catchDelay = v
		statusLabel.Text = string.format("Catch delay set to %.2f s", state.catchDelay)
	else
		catchDelayBox.Text = tostring(state.catchDelay)
		statusLabel.Text = "Invalid catch delay (kept previous)"
	end
end)

-- ---------- Final init ----------
-- set initial UI values
fishDelayBox.Text = tostring(state.fishDelay)
catchDelayBox.Text = tostring(state.catchDelay)
blatantBtn.Text = "Blatant x" .. tostring(state.blatantMultiplier)

-- Make sure progress starts hidden
progress.Size = UDim2.new(0,0,1,0)

notify("Fishing UI (single-file) initialized. Press R to test quick bite.")
