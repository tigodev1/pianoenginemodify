local module = {}
local Tween = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Piano = script.Parent.Parent
Piano_Keys = Piano.Keys
local NUMBER_OF_KEYS = 61
local animatedNotes = {}
local MinLifeTime = 0.1 --in seconds
local ROTATION_CFRAME = CFrame.fromEulerAnglesXYZ(math.rad(3),0,0)
local WHITE_KEY_CFRAME = CFrame.new(Vector3.new(0,-0.033,0)) * ROTATION_CFRAME
local BLACK_KEY_CFRAME = CFrame.new(Vector3.new(0,-0.028,0)) * ROTATION_CFRAME
local PlayingAnimation = false
local AnimationTracker
-- VISUALIZER SETTINGS
local VISUALIZER_COLOR = Color3.fromRGB(255, 255, 255) -- Blue color
local INITIAL_SIZE = Vector3.new(0.032, 0.351, 0.116) -- Your specified size
local GROWTH_SPEED = 3 -- How fast it extends upward (studs per second)
local MAX_HEIGHT = 8 -- Maximum height the part can extend to
local FLOAT_SPEED = 4 -- How fast it floats up when released
local FADE_TIME = 1.5 -- How long it takes to fade away
local FLOAT_HEIGHT = 3 -- Additional height it floats before disappearing
local KEY_OFFSET = 0.2 -- Distance above the key to start
-- Track active visualizations - using a unique ID for each press
local activeVisualizations = {}
local visualizationCounter = 0
local origins = {}
for _,key in pairs(Piano_Keys:GetChildren()) do
	origins[key] = key.CFrame
end
local MaxLifeTime = 5
local function IsBlack(note)
	note = (note - 1)%12 + 1
	if NUMBER_OF_KEYS == 88 then -- first note is A
		if note%12 == 2 or note%12 == 5 or note%12 == 7 or note%12 == 10 or note%12 == 0 then
			return true
		end
	else -- first note is C
		if note%12 == 2 or note%12 == 4 or note%12 == 7 or note%12 == 9 or note%12 == 11 then
			return true
		end
	end
end
function Tween:Play(instance, tweenInfo, properties, yield)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	if yield then
		tween.Completed:Wait()
	end
end
-- Create visualization part above key
local function createVisualizationPart(PianoKey, noteNumber)
	local part = Instance.new("Part")
	part.Name = "NoteVisualization_" .. tostring(noteNumber)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = VISUALIZER_COLOR
	part.Size = INITIAL_SIZE
	part.Transparency = 0.2 -- Slight transparency for better visual
	-- Position it just above the key
	local basePosition = PianoKey.Position + Vector3.new(0, PianoKey.Size.Y/2 + KEY_OFFSET + INITIAL_SIZE.Y/2, 0)
	part.Position = basePosition
	part.Parent = workspace
	-- Add a subtle PointLight for glow effect
	local light = Instance.new("PointLight")
	light.Brightness = 1.5
	light.Color = VISUALIZER_COLOR
	light.Range = 3
	light.Parent = part
	return part
end
-- Extend the visualization upward while key is held
local function extendVisualization(part, PianoKey, vizId)
	local connection
	local currentHeight = INITIAL_SIZE.Y
	local baseY = PianoKey.Position.Y + PianoKey.Size.Y/2 + KEY_OFFSET
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		-- Check if this visualization is still active
		if not activeVisualizations[vizId] or not part or not part.Parent then
			if connection then
				connection:Disconnect()
			end
			return
		end
		-- Extend the part upward
		currentHeight = math.min(currentHeight + GROWTH_SPEED * deltaTime, MAX_HEIGHT)
		part.Size = Vector3.new(INITIAL_SIZE.X, currentHeight, INITIAL_SIZE.Z)
		-- Keep the bottom edge fixed, extend upward
		part.Position = Vector3.new(
			PianoKey.Position.X,
			baseY + currentHeight/2,
			PianoKey.Position.Z
		)
	end)
	return connection
end
-- Float up and fade away when key is released
local function floatAndFade(part)
	if not part or not part.Parent then return end
	local startPos = part.Position
	local endPos = startPos + Vector3.new(0, FLOAT_HEIGHT, 0)
	-- Create smooth float up and fade animation
	local floatTween = TweenService:Create(
		part,
		TweenInfo.new(FADE_TIME, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{
			Position = endPos,
			Transparency = 1,
			Size = Vector3.new(INITIAL_SIZE.X * 0.5, part.Size.Y, INITIAL_SIZE.Z * 0.5) -- Shrink X and Z while floating
		}
	)
	-- Fade the light too
	if part:FindFirstChild("PointLight") then
		local lightTween = TweenService:Create(
			part.PointLight,
			TweenInfo.new(FADE_TIME * 0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{Brightness = 0}
		)
		lightTween:Play()
	end
	floatTween:Play()
	floatTween.Completed:Connect(function()
		part:Destroy()
	end)
end
function module.PianoAnimation(PianoNote, isHolding)
	if not PianoNote then return end
	local PianoKey = Piano_Keys:FindFirstChild(tostring(PianoNote))
	if PianoKey then
		if isHolding == true then
			-- Original key animation
			task.spawn(function()
				local key = Piano_Keys[tostring(PianoNote)]
				if key then
					Tween:Play(key, TweenInfo.new(0.1), {CFrame = origins[key] * (if IsBlack(PianoNote) then BLACK_KEY_CFRAME else WHITE_KEY_CFRAME)})
				end
			end)
			-- Signal to server to increment NotesPlayed stat
			task.spawn(function()
				local notesPlayedEvent = ReplicatedStorage:FindFirstChild("IncrementNotesPlayed")
				if notesPlayedEvent then
					notesPlayedEvent:FireServer()
				end
			end)
			-- Create visualization with unique ID
			task.spawn(function()
				visualizationCounter = visualizationCounter + 1
				local vizId = visualizationCounter
				-- Create new visualization that extends upward
				local visualPart = createVisualizationPart(PianoKey, PianoNote)
				if not visualPart then return end
				local growthConnection = extendVisualization(visualPart, PianoKey, vizId)
				-- Store with unique ID
				activeVisualizations[vizId] = {
					part = visualPart,
					connection = growthConnection,
					noteNumber = PianoNote,
					timestamp = tick()
				}
				-- Safety timeout
				task.delay(MaxLifeTime, function()
					if activeVisualizations[vizId] then
						local viz = activeVisualizations[vizId]
						if viz.connection then
							viz.connection:Disconnect()
						end
						if viz.part and viz.part.Parent then
							floatAndFade(viz.part)
						end
						activeVisualizations[vizId] = nil
					end
					module.EndPianoAnimation(PianoKey)
				end)
			end)
		else
			-- Key released
			module.EndPianoAnimation(PianoKey)
			-- Find and release the most recent visualization for this note
			task.spawn(function()
				local mostRecent = nil
				local mostRecentTime = 0
				for vizId, viz in pairs(activeVisualizations) do
					if viz.noteNumber == PianoNote and viz.timestamp > mostRecentTime then
						mostRecent = vizId
						mostRecentTime = viz.timestamp
					end
				end
				if mostRecent and activeVisualizations[mostRecent] then
					local viz = activeVisualizations[mostRecent]
					if viz.connection then
						viz.connection:Disconnect()
					end
					if viz.part and viz.part.Parent then
						floatAndFade(viz.part)
					end
					activeVisualizations[mostRecent] = nil
				end
			end)
		end
	end
end
function module.EndPianoAnimation(PianoKey)
	if not PianoKey then return end
	task.spawn(function()
		Tween:Play(PianoKey, TweenInfo.new(0.1), {CFrame = origins[PianoKey]})
	end)
end
-- Clean up function for when player leaves
function module.CleanupVisualizations()
	for vizId, viz in pairs(activeVisualizations) do
		if viz.connection then
			viz.connection:Disconnect()
		end
		if viz.part and viz.part.Parent then
			viz.part:Destroy()
		end
	end
	activeVisualizations = {}
end
return module