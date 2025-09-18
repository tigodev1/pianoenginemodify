-- VARIABLES
-- // SERVICES
SoundService = game:GetService("SoundService")
TweenService = game:GetService("TweenService")
Players = game:GetService("Players")
Piano_Dependencies = workspace.Piano_Dependencies

LocalPlayer = Players.LocalPlayer

-- // FOLDERS
Folder_Remotes = Piano_Dependencies.Remotes

-- // DEFAULT SETTINGS
local VolumePriorityValue = 10 -- server notes volume MINUS this value
local MaxExistingNotes = 35
local MaxTransposition = 24
local MinimumTransposition = -24
local MaxVolume = 200
local MinimumVolume = 10

local PacketType1Offset = 15
local PacketType2Offset = 27

-- ARRAYS
local ExistingNotes = {}

local SustainedNotes = {}
local NonSustainedNotes = {}
ServerSustainedNotes = {}
ServerNonSustainedNotes = {}

-- FUNCTIONS
-- // OTHER FUNCTIONS
function NoteLimit(audio)
	table.insert(ExistingNotes, 1, audio)
	if #ExistingNotes >= MaxExistingNotes then
		ExistingNotes[MaxExistingNotes]:Stop()
		ExistingNotes[MaxExistingNotes] = nil
	end
end


function NoteFadeout(audio, fadeout)
	task.spawn(function()
		if audio then
			local Tween = TweenService:Create(audio, 
				TweenInfo.new(fadeout, Enum.EasingStyle.Linear), 
				{Volume = 0}
			)

			Tween:Play()
			Tween.Completed:Wait()
			audio:Stop()
			audio:Destroy()
		end
	end)
end


-- // MAIN
local module = {
	
	[1] = function( -- // 88 AUDIO FILES PACKET
		PianoNote, 
		Soundfont_Ids, 
		Offset, NoteLifeTime, Fadeout, Transposition, 
		PacketType, SustainPacket, Above88KeysPacket,
		Velocity, LocalVolume, VolumeModifier, RawKeyCode
	)
		local RealPianoNote = PianoNote
		PianoNote = PianoNote + PacketType1Offset
		
		local pitch = 1
		local audio = Instance.new("Sound", SoundService) -- Create the audio
		local sound

		if PianoNote > 88 then
			pitch = 1.059463^ (PianoNote - 88)
			sound = Soundfont_Ids[88]
		elseif PianoNote < 1 then
			pitch = 1.059463 ^ (-(1 - PianoNote))
			sound = Soundfont_Ids[1]
		else
			sound = Soundfont_Ids[PianoNote]
		end	
		
		audio.SoundId = "rbxassetid://"..sound
		audio.Volume = (LocalVolume/100) * (Velocity/100) + VolumeModifier
		audio.TimePosition = audio.TimePosition + Offset
		audio.Pitch = pitch
		audio:Play()

		Folder_Remotes.NoteRemote:FireServer( -- send to server
			PianoNote, audio.SoundId, audio.Volume, audio.TimePosition, audio.Pitch, 
			SustainPacket, NoteLifeTime, Fadeout, RawKeyCode
		)
		
		NoteLimit(audio)
		
		if SustainPacket == false then
			task.spawn(function()
				NonSustainedNotes[RawKeyCode] = audio
				
				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		elseif SustainPacket == true then
			task.spawn(function()
				table.insert(SustainedNotes, audio)

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		end
			
	end,
	
	[2] = function( -- // 61 AUDIO FILES PACKET
		PianoNote, 
		Soundfont_Ids, 
		Offset, NoteLifeTime, Fadeout, Transposition, 
		PacketType, SustainPacket, Above88KeysPacket,
		Velocity, LocalVolume, VolumeModifier, RawKeyCode
	)
		local RealPianoNote = PianoNote
		-- PianoNote = PianoNote + PacketType1Offset

		local pitch = 1
		local audio = Instance.new("Sound", SoundService) -- Create the audio
		local sound

		if PianoNote > 61 then
			pitch = 1.059463^ (PianoNote - 61)
			sound = Soundfont_Ids[61]
		elseif PianoNote < 1 then
			pitch = 1.059463 ^ (-(1 - PianoNote))
			sound = Soundfont_Ids[1]
		else
			sound = Soundfont_Ids[PianoNote]
		end	

		audio.SoundId = "rbxassetid://"..sound
		audio.Volume = (LocalVolume/100) * (Velocity/100) + VolumeModifier
		audio.TimePosition = audio.TimePosition + Offset
		audio.Pitch = pitch
		audio:Play()

		Folder_Remotes.NoteRemote:FireServer( -- send to server
			PianoNote, audio.SoundId, audio.Volume, audio.TimePosition, audio.Pitch, 
			SustainPacket, NoteLifeTime, Fadeout, RawKeyCode
		)

		NoteLimit(audio)

		if SustainPacket == false then
			task.spawn(function()
				NonSustainedNotes[RawKeyCode] = audio

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		elseif SustainPacket == true then
			task.spawn(function()
				table.insert(SustainedNotes, audio)

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		end

	end,
	
	[3] = function( -- // 48 AUDIO FILES PACKET
		PianoNote, 
		Soundfont_Ids, 
		Offset, NoteLifeTime, Fadeout, Transposition, 
		PacketType, SustainPacket, Above88KeysPacket,
		Velocity, LocalVolume, VolumeModifier, RawKeyCode
	)
		local RealPianoNote = PianoNote
		PianoNote = PianoNote + PacketType2Offset

		local pitch = 1
		local audio = Instance.new("Sound", SoundService) -- Create the audio
		local sound

		if PianoNote > 88 then
			pitch = 1.059463^ (PianoNote - 88)
			sound = Soundfont_Ids[88]
		elseif PianoNote < 1 then
			pitch = 1.059463 ^ (-(1 - PianoNote))
			sound = Soundfont_Ids[1]
		else
			sound = Soundfont_Ids[PianoNote]
		end	

		audio.SoundId = "rbxassetid://"..sound
		audio.Volume = (LocalVolume/100) * (Velocity/100) + VolumeModifier
		audio.TimePosition = audio.TimePosition + Offset
		audio.Pitch = pitch
		audio:Play()

		Folder_Remotes.NoteRemote:FireServer( -- send to server
			PianoNote, audio.SoundId, audio.Volume, audio.TimePosition, audio.Pitch, 
			SustainPacket, NoteLifeTime, Fadeout, RawKeyCode
		)

		NoteLimit(audio)

		if SustainPacket == false then
			task.spawn(function()
				NonSustainedNotes[RawKeyCode] = audio

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		elseif SustainPacket == true then
			task.spawn(function()
				table.insert(SustainedNotes, audio)

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		end

	end,
	
	[4] = function( -- // 6 AUDIO FILES PACKET
		PianoNote, 
		Soundfont_Ids, 
		Offset, NoteLifeTime, Fadeout, Transposition, 
		PacketType, SustainPacket, Above88KeysPacket,
		Velocity, LocalVolume, VolumeModifier, RawKeyCode
	)
		local pitch = 1
		if PianoNote > 61 then
			pitch = 1.059463 ^ (PianoNote - 61)
		elseif PianoNote < 1 then
			pitch = 1.059463 ^ (-(1 - PianoNote))
		end
		
		PianoNote = PianoNote > 61 and 61 or PianoNote < 1 and 1 or PianoNote
		local note2 = (PianoNote - 1)%12 + 1	-- Which note? (1-12)
		local octave = math.ceil(PianoNote/12) -- Which octave?
		local offset = (16 * (octave - 1) + 8 * (1 - note2%2))
		local sound = math.ceil(note2/2) -- Which audio?
		local audio = Instance.new("Sound", SoundService) -- Create the audio

		audio.SoundId = "rbxassetid://"..((Soundfont_Ids and Soundfont_Ids[sound]))
		audio.Volume = (LocalVolume/100) * (Velocity/100) + VolumeModifier
		audio.TimePosition = offset + Offset or offset + 0.027 -- or (octave - .9)/15
		audio.Pitch = pitch
		audio:Play()

		Folder_Remotes.NoteRemote:FireServer( -- send to server
			PianoNote, audio.SoundId, audio.Volume, audio.TimePosition, audio.Pitch, 
			SustainPacket, NoteLifeTime, Fadeout, RawKeyCode
		)

		NoteLimit(audio)

		if SustainPacket == false then
			task.spawn(function()
				NonSustainedNotes[RawKeyCode] = audio

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		elseif SustainPacket == true then
			task.spawn(function()
				table.insert(SustainedNotes, audio)

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		end
	end,
}

-- // MODULE FUNCTIONS

-- // !!!!!!!!!! SERVER NOTES !!!!!!!!!!
function module.PlayServerNote( 
	PianoNote, SoundId, Volume, TimePosition, Pitch, SustainPacket, NoteLifeTime, Fadeout, RawKeyCode
)
	local audio = Instance.new("Sound", SoundService) -- Create the audio
	local sound
	
	if SoundId then
		audio.SoundId = SoundId
		audio.Volume = Volume
		audio.TimePosition = TimePosition
		audio.Pitch = Pitch
		audio:Play()
		
		NoteLimit(audio)

		if SustainPacket == false then
			task.spawn(function()

				ServerNonSustainedNotes[RawKeyCode] = audio

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		elseif SustainPacket == true then
			task.spawn(function()
				table.insert(ServerSustainedNotes, audio)

				task.spawn(function()
					task.delay(NoteLifeTime, function()
						if audio then
							NoteFadeout(audio, Fadeout)
						end
					end)
				end)
			end)
		end
		
	end
end

-- // SUSTAIN

-- // FINISH NON SUSTAINED NOTES
function module.FinishNonSustainNote(RawKeyCode, Fadeout)
	local audio = NonSustainedNotes[RawKeyCode]
	if audio then
		NoteFadeout(audio, Fadeout)
		NonSustainedNotes[RawKeyCode] = nil
	end
end
-- // SERVER
function module.ServerFinishNonSustainNote(RawKeyCode, Fadeout)
	local audio = ServerNonSustainedNotes[RawKeyCode]
	if audio then
		NoteFadeout(audio, Fadeout)
		ServerNonSustainedNotes[RawKeyCode] = nil
	end
end

-- // FINISH ALL SUSTAINED NOTES
function module.FadeoutAllSustainedNotes(fadeout)
	task.spawn(function()
		for num,audio in pairs(SustainedNotes) do
			NoteFadeout(audio, fadeout)
			SustainedNotes[num] = nil
		end
	end)
end
-- // SERVER
function module.ServerFadeoutAllSustainedNotes(fadeout)
	task.spawn(function()
		for num,audio in pairs(ServerSustainedNotes) do
			NoteFadeout(audio, fadeout)
			ServerSustainedNotes[num] = nil
		end
	end)
end

-- // ANIMATIONS
function module.PlayLocalAnimation(PianoModule, PianoNote, Holding)
	if PianoModule then
		local pmodule = require(PianoModule)
		if Holding == true then
			pmodule.PianoAnimation(PianoNote, Holding)
		elseif Holding == false then
			pmodule.PianoAnimation(PianoNote, Holding)
		end
	end
end

-- // MISC FUNCTIONS
function module.Transpose(value, Transposition)
	Transposition = Transposition + value
	
	if Transposition > MaxTransposition then
		Transposition = MaxTransposition
	elseif Transposition < MinimumTransposition then
		Transposition = MinimumTransposition
	end
	
	return Transposition
end

function module.Volume(value, Volume)
	Volume = Volume + value
	
	if Volume > MaxVolume then
		Volume = MaxVolume
	elseif Volume < MinimumVolume then
		Volume = MinimumVolume
	end
	
	return Volume
end

return module
