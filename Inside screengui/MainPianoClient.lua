--[[ 

	Hello, thank you for using my piano engine! Please credit me if possible or atleast leave my logo in the piano. It means a lot to me.
	Due to Roblox update my newest engine broke and I had to COPE but if they ever enable audio files to be public I will update this!
	For now, we have to stick to a single soundfont. Anyways, ENJOY!

]]

Players = game:GetService("Players")
ContextActionService = game:GetService("ContextActionService")
UserInputService = game:GetService("UserInputService")

Piano_Dependencies = workspace.Piano_Dependencies

Folder_Modules = Piano_Dependencies.Modules
Folder_Remotes = Piano_Dependencies.Remotes
Folder_Logic = Folder_Modules.Logic
Folder_Dependencies = Folder_Modules.Dependencies

-- MODULES
Dependence_DraggableObject = require(Folder_Dependencies.DraggableObject)
Dependence_Soundfonts = require(Folder_Dependencies.Soundfonts)
Dependence_PlayerVariables = require(Folder_Dependencies.PlayerVariables)

Logic_Piano = require(Folder_Logic.PianoLogic)
Logic_Character = require(Folder_Logic.CharacterLogic)
Logic_Keymap = require(Folder_Logic.KeymapLogic)
Logic_UI = require(Folder_Logic.UILogic)

LocalPlayer = Players.LocalPlayer
Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Humanoid = Character:WaitForChild("Humanoid")

PianoUI = script.Parent
PianoContainer = PianoUI.PianoContainer
KeysFrame = PianoContainer.KeyFrame
OptionFrame = PianoContainer.OptionFrame
Screen = PianoContainer.Screen
VelocityBar = PianoContainer.VelocityBar

local Above88KeyPacket = false
local VelocityPacket = false
local SustainPacket = true

Transposition = 0
Velocity = 50
LocalVolume = 100 

KEY_OFFSET = 15

local LetterNoteMap = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"
local Letter88Map = "trewq0987654321yuiopasdfghj"
local VelocityMap = "1234567890qwertyuiopasdfghjklzxc"

local PianoVisualDictionary = {}

DraggableFrames = {PianoContainer.Soundfonts, PianoContainer.Sheets}

local function ProcessPianoAction(_, inputState, inputObject) 
	local keyCodeValue = inputObject.KeyCode.Value
	local LetterNote = LetterNoteMap:find(string.char(keyCodeValue), 1, true)
	if LetterNote then
		local PianoNote = LetterNote + Transposition

		local Soundfont_ID = Dependence_PlayerVariables["Current_SoundfontID"]
		local Soundfont_Pick = Dependence_Soundfonts[Soundfont_ID]

		local Soundfont_Ids = Soundfont_Pick["AssetIds"]
		local Offset = Soundfont_Pick["Offset"]
		local NoteLifeTime = Soundfont_Pick["MaxLifetime"]
		local Fadeout = Soundfont_Pick["Fadeout"]
		local VolumeModifier = Soundfont_Pick["VolumeModifier"]
		local PacketType = Soundfont_Pick["PacketType"]

		local PianoModule = Humanoid.SeatPart.Parent.Scripts.PianoModule 
		-- // idk if theres a better way to check for animations without running into an error

		if inputState == Enum.UserInputState.Begin then 
			-- // VELOCITY PACKET
			if VelocityPacket == true then 
				local VelocityKeymap = Logic_Keymap:VelocityKeyCodes()
				local VelocityLevel = VelocityMap:find(string.char(keyCodeValue), 1, true)
				local RealVelocity = VelocityKeymap[VelocityLevel]
				Velocity = tonumber(RealVelocity)
				Logic_UI.ForceShowFrame(VelocityBar)
				VelocityBar.Bar.Size = UDim2.fromOffset(Velocity, 5)

				return end

			-- // 88 KEYS PACKET
			if Above88KeyPacket == true then 
				local Piano88KeyCodes = Logic_Keymap.Piano88KeyCodes
				local Above88Key = Letter88Map:find(string.char(keyCodeValue), 1, true) 
				local RealPianoNote = Piano88KeyCodes[Above88Key] + Transposition
				Logic_Piano[PacketType]( -- // PIANO LOGIC
					RealPianoNote, 
					Soundfont_Ids, 
					Offset, NoteLifeTime, Fadeout, Transposition, 
					PacketType, SustainPacket, Above88KeyPacket,
					Velocity, LocalVolume, VolumeModifier, inputObject.KeyCode
				)
				-- // VISUALS
				PianoVisualDictionary[inputObject.KeyCode] = RealPianoNote
				Logic_UI.PlayNote(KeysFrame, RealPianoNote)

				-- // ANIMATIONS
				if PianoModule then
					local Module = require(PianoModule)
					Module.PianoAnimation(RealPianoNote+KEY_OFFSET,true)
					Folder_Remotes.AnimationRemote:FireServer(PianoNote+KEY_OFFSET,true)
				end
				return end

			-- // NORMAL PACKET
			Logic_Piano[PacketType]( -- // PIANO LOGIC
				PianoNote, 
				Soundfont_Ids, 
				Offset, NoteLifeTime, Fadeout, Transposition, 
				PacketType, SustainPacket, Above88KeyPacket,
				Velocity, LocalVolume, VolumeModifier, inputObject.KeyCode
			)

			-- // VISUALS
			PianoVisualDictionary[inputObject.KeyCode] = PianoNote
			Logic_UI.PlayNote(KeysFrame, PianoNote)
			-- // ANIMATIONS
			if PianoModule then
				local Module = require(PianoModule)
				Module.PianoAnimation(PianoNote+KEY_OFFSET,true)
				Folder_Remotes.AnimationRemote:FireServer(PianoNote+KEY_OFFSET,true)
			end

		elseif inputState == Enum.UserInputState.End then
			Logic_Piano.FinishNonSustainNote(inputObject.KeyCode, Fadeout)
			Folder_Remotes.SustainRemote:FireServer(inputObject.KeyCode, Fadeout)

			if SustainPacket == false then -- // double check
				Logic_Piano.FadeoutAllSustainedNotes(Fadeout)
				Folder_Remotes.FinishNonSustainedNotesRemote:FireServer(Fadeout)
			end

			-- // VISUALS
			Logic_UI.FinishNote(KeysFrame, PianoVisualDictionary[inputObject.KeyCode])

			-- // ANIMATIONS
			if PianoModule then
				local Module = require(PianoModule)
				local TempNote = PianoVisualDictionary[inputObject.KeyCode]

				if TempNote then
					Module.PianoAnimation(TempNote+KEY_OFFSET,false)
					Folder_Remotes.AnimationRemote:FireServer(TempNote+KEY_OFFSET,false)
				end
			end
		end
	end
end

local function SustainAction(_, inputState, inputObject)
	local Soundfont_ID = Dependence_PlayerVariables["Current_SoundfontID"]
	local Soundfont_Pick = Dependence_Soundfonts[Soundfont_ID]
	local Fadeout = Soundfont_Pick["Fadeout"]

	if inputState == Enum.UserInputState.Begin then
		SustainPacket = not SustainPacket

		if SustainPacket == false then -- // FADEOUT ALL NOTES
			Logic_Piano.FadeoutAllSustainedNotes(Fadeout)
			Folder_Remotes.FinishNonSustainedNotesRemote:FireServer(Fadeout)
		end

		Logic_UI.GlowCheck(OptionFrame.Sustain.LED, SustainPacket)
	elseif inputState == Enum.UserInputState.End then
		SustainPacket = not SustainPacket
		Logic_UI.GlowCheck(OptionFrame.Sustain.LED, SustainPacket)
	end
end

local function VelocityAction(_, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		VelocityPacket = true
	elseif inputState == Enum.UserInputState.End then
		VelocityPacket = false
	end
end

local function Above88KeyAction(_, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Above88KeyPacket = true
	elseif inputState == Enum.UserInputState.End then
		Above88KeyPacket = false
	end
end

local function ShiftAction(_, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Transposition = Logic_Piano.Transpose(1, Transposition)
		Logic_UI.UpdateTextLabel(Screen.Transposition.Value, Transposition)
	elseif inputState == Enum.UserInputState.End then
		Transposition = Logic_Piano.Transpose(-1, Transposition)
		Logic_UI.UpdateTextLabel(Screen.Transposition.Value, Transposition)
	end
end

local function TranspositionAction(_, inputState, inputObject)
	local KeyCode = inputObject.KeyCode

	if inputState == Enum.UserInputState.Begin then
		if KeyCode == Enum.KeyCode.Up then
			Transposition = Logic_Piano.Transpose(1, Transposition)
			Logic_UI.UpdateTextLabel(Screen.Transposition.Value, Transposition)

		elseif KeyCode == Enum.KeyCode.Down then
			Transposition = Logic_Piano.Transpose(-1, Transposition)
			Logic_UI.UpdateTextLabel(Screen.Transposition.Value, Transposition)
		end
	end
end

local function VolumeAction(_, inputState, inputObject)
	local KeyCode = inputObject.KeyCode

	if inputState == Enum.UserInputState.Begin then
		if KeyCode == Enum.KeyCode.Left then
			LocalVolume = Logic_Piano.Volume(-10, LocalVolume)
			Logic_UI.UpdateTextLabel(Screen.Volume.Value, LocalVolume)

		elseif KeyCode == Enum.KeyCode.Right then
			LocalVolume = Logic_Piano.Volume(10, LocalVolume)
			Logic_UI.UpdateTextLabel(Screen.Volume.Value, LocalVolume)
		end
	end
end

function BindPiano(seatpart)
	print("[PianoMain] Binding piano actions.")
	PianoUI.Enabled = true
	Logic_Character.AddCamera(Humanoid)
	ContextActionService:BindAction("ShiftCheck", ShiftAction, false, Enum.KeyCode.RightShift, Enum.KeyCode.LeftShift)
	ContextActionService:BindAction("AltCheck", VelocityAction, false, Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt)
	ContextActionService:BindAction("ControlCheck", Above88KeyAction, false, Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl)
	ContextActionService:BindAction("TranspositionCheck", TranspositionAction, false, Enum.KeyCode.Up, Enum.KeyCode.Down)
	ContextActionService:BindAction("SustainCheck", SustainAction, false, Enum.KeyCode.Space)
	ContextActionService:BindAction("ExitCheck", UnbindPiano, false, Enum.KeyCode.Backspace)
	ContextActionService:BindAction("VolumeCheck", VolumeAction, false, Enum.KeyCode.Left, Enum.KeyCode.Right)
	ContextActionService:BindAction("PianoAction", ProcessPianoAction, false, Logic_Keymap.PianoKeyCodes())
end

function UnbindPiano()
	print("[PianoMain] Un-binding piano actions.")
	PianoUI.Enabled = false
	ContextActionService:UnbindAction("PianoAction")
	ContextActionService:UnbindAction("ShiftCheck")
	ContextActionService:UnbindAction("AltCheck")
	ContextActionService:UnbindAction("ControlCheck")
	ContextActionService:UnbindAction("TranspositionCheck")
	ContextActionService:UnbindAction("SustainCheck")
	ContextActionService:UnbindAction("ExitCheck")
	Humanoid.Sit = false
	Logic_Character.RevokeCamera()
end

Humanoid.Seated:Connect(function(sitting, seatpart)
	if sitting then
		if seatpart.Parent.Parent.Name == "Pianos" then
			BindPiano(seatpart)
		end
	end
end)

VelocityBar.MouseButton1Click:Connect(function()
	Velocity = 50
	VelocityBar.Visible = false
end)

Humanoid.Died:Connect(function()
	UnbindPiano()
end)


OptionFrame.Sustain.MouseButton1Click:Connect(function()
	SustainPacket = not SustainPacket
	Logic_UI.GlowCheck(OptionFrame.Sustain.LED, SustainPacket)
end)

OptionFrame.TransposeUp.MouseButton1Click:Connect(function()
	Transposition = Logic_Piano.Transpose(1, Transposition)
	Logic_UI.UpdateTextLabel(Screen.Transposition.Value, Transposition)
end)
OptionFrame.TransposeDown.MouseButton1Click:Connect(function()
	Transposition = Logic_Piano.Transpose(-1, Transposition)
	Logic_UI.UpdateTextLabel(Screen.Transposition.Value, Transposition)
end)

OptionFrame.VolumeUp.MouseButton1Click:Connect(function()
	LocalVolume = Logic_Piano.Volume(10, LocalVolume)
	Logic_UI.UpdateTextLabel(Screen.Volume.Value, LocalVolume)
end)
OptionFrame.VolumeDown.MouseButton1Click:Connect(function()
	LocalVolume = Logic_Piano.Volume(-10, LocalVolume)
	Logic_UI.UpdateTextLabel(Screen.Volume.Value, LocalVolume)
end)

OptionFrame.Soundfonts.MouseButton1Click:Connect(function()
	Logic_UI.ShowHideFrame(PianoContainer.Soundfonts)
end)

OptionFrame.Sheets.MouseButton1Click:Connect(function()
	Logic_UI.ShowHideFrame(PianoContainer.Sheets)
end)

Folder_Remotes.NoteRemote.OnClientEvent:Connect(function(PianoNote, SoundId, Volume, TimePosition, Pitch, SustainPacket, NoteLifeTime, Fadeout, RawKeyCode)
	Logic_Piano.PlayServerNote(PianoNote, SoundId, Volume, TimePosition, Pitch, SustainPacket, NoteLifeTime, Fadeout, RawKeyCode)
end)

Folder_Remotes.SustainRemote.OnClientEvent:Connect(function(RawKeyCode, Fadeout)
	Logic_Piano.ServerFinishNonSustainNote(RawKeyCode, Fadeout)

end)

Folder_Remotes.FinishNonSustainedNotesRemote.OnClientEvent:Connect(function(Fadeout)
	Logic_Piano.ServerFadeoutAllSustainedNotes(Fadeout)
end)

for num,frame in pairs(DraggableFrames) do
	local FrameDrag = Dependence_DraggableObject.new(frame)
	FrameDrag:Enable()
end

-- INITIAL SETUP
PianoUI.Enabled = false
print("[PianoMain] UI initialized succesfully.")