-- fishing.lua (ModuleScript)
-- Client-side modular fishing system for learning / task
-- Place in ReplicatedStorage > Module > fishing (ModuleScript)
-- Exposes API: Cast, TriggerBite, Catch, StartAutoFish, StopAutoFish, StartAutoCatch, StopAutoCatch, SetDelays, SetBlatantMultiplier, GetStatus
-- WARNING: This module runs client-side and simulates fishing. For multiplayer server-validation, use server-side logic.

local Fishing = {}
Fishing.__index = Fishing

-- state (single-player/client)
local state = {
	isCasting = false,
	hasBite = false,
	hasCaught = false,
	autoFish = false,
	autoCatch = false,
	blatantMultiplier = 1,
	fishDelay = 1.0,
	catchDelay = 0.1,
	_autoFishTask = nil,
	_autoCatchTask = nil,
	onUpdateCallbacks = {}, -- listeners: function(payload)
}

local MIN_DELAY = 0.02

-- internal helper: notify listeners (UI)
local function notify(payload)
	for _, cb in ipairs(state.onUpdateCallbacks) do
		pcall(cb, payload)
	end
end

-- internal auto loops
local function startAutoFishLoop()
	if state._autoFishTask then return end
	state._autoFishTask = task.spawn(function()
		while state.autoFish do
			local delayTime = math.max(MIN_DELAY, state.fishDelay or 1)
			for i = 1, math.max(1, math.floor(state.blatantMultiplier or 1)) do
				if not state.isCasting and not state.hasCaught then
					state.isCasting = true
					state.hasBite = false
					notify({Type="CastStarted"})
				end
				-- micro-yield to prevent hard freeze if blatant>1
				if i < (state.blatantMultiplier or 1) then
					task.wait(0)
				end
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
			local delayTime = math.max(MIN_DELAY, state.catchDelay or 0.1)
			if state.hasBite and state.isCasting and not state.hasCaught then
				-- instant catch
				state.hasCaught = true
				state.hasBite = false
				state.isCasting = false
				notify({Type="Caught"})
			end
			task.wait(delayTime)
		end
		state._autoCatchTask = nil
	end)
end

-- API --

function Fishing.onUpdate(fn)
	if type(fn) == "function" then
		table.insert(state.onUpdateCallbacks, fn)
	end
end

function Fishing.Cast()
	if state.isCasting then
		return false, "already_casting"
	end
	state.isCasting = true
	state.hasBite = false
	state.hasCaught = false
	notify({Type="CastStarted"})
	return true
end

-- TriggerBite: mark bite (e.g. called by test or server event)
function Fishing.TriggerBite()
	if not state.isCasting then
		-- if not casting, ignore (unless you want force)
		return false, "not_casting"
	end
	state.hasBite = true
	notify({Type="Bite"})
	-- if autoCatch enabled, autoCatch loop will pick it up (or user can call Catch)
	return true
end

function Fishing.Catch()
	if not state.isCasting then return false, "not_casting" end
	if not state.hasBite then return false, "no_bite" end
	if state.hasCaught then return false, "already_caught" end

	state.hasCaught = true
	state.hasBite = false
	state.isCasting = false
	notify({Type="Caught"})
	return true, "caught"
end

function Fishing.StartAutoFish(config)
	state.autoFish = true
	if type(config) == "table" then
		if config.fishDelay then state.fishDelay = math.max(MIN_DELAY, tonumber(config.fishDelay) or state.fishDelay) end
		if config.blatantMultiplier then state.blatantMultiplier = math.max(1, tonumber(config.blatantMultiplier) or state.blatantMultiplier) end
	end
	startAutoFishLoop()
	notify({Type="AutoFishToggled", Data={enabled=true, fishDelay=state.fishDelay, blatant=state.blatantMultiplier}})
end

function Fishing.StopAutoFish()
	state.autoFish = false
	notify({Type="AutoFishToggled", Data={enabled=false}})
end

function Fishing.StartAutoCatch(config)
	state.autoCatch = true
	if type(config) == "table" and config.catchDelay then
		state.catchDelay = math.max(MIN_DELAY, tonumber(config.catchDelay) or state.catchDelay)
	end
	startAutoCatchLoop()
	notify({Type="AutoCatchToggled", Data={enabled=true, catchDelay=state.catchDelay}})
end

function Fishing.StopAutoCatch()
	state.autoCatch = false
	notify({Type="AutoCatchToggled", Data={enabled=false}})
end

function Fishing.SetDelays(fishDelay, catchDelay)
	if fishDelay then state.fishDelay = math.max(MIN_DELAY, tonumber(fishDelay) or state.fishDelay) end
	if catchDelay then state.catchDelay = math.max(MIN_DELAY, tonumber(catchDelay) or state.catchDelay) end
	notify({Type="DelaysUpdated", Data={fishDelay=state.fishDelay, catchDelay=state.catchDelay}})
end

function Fishing.SetBlatantMultiplier(mult)
	state.blatantMultiplier = math.max(1, tonumber(mult) or state.blatantMultiplier)
	notify({Type="BlatantUpdated", Data={blatant=state.blatantMultiplier}})
end

function Fishing.GetStatus()
	return {
		isCasting = state.isCasting,
		hasBite = state.hasBite,
		hasCaught = state.hasCaught,
		autoFish = state.autoFish,
		autoCatch = state.autoCatch,
		fishDelay = state.fishDelay,
		catchDelay = state.catchDelay,
		blatantMultiplier = state.blatantMultiplier,
	}
end

-- small utility to reset for tests
function Fishing.Reset()
	state.isCasting = false
	state.hasBite = false
	state.hasCaught = false
	state.autoFish = false
	state.autoCatch = false
	state.blatantMultiplier = 1
	state.fishDelay = 1.0
	state.catchDelay = 0.1
	notify({Type="Reset"})
end

return Fishing
