Piano_Dependencies = workspace.Piano_Dependencies

Folder_PianoScripts = script.Parent
Folder_Modules = Piano_Dependencies.Modules
Folder_Remotes = Piano_Dependencies.Remotes
Folder_Services = Folder_Modules.Services

ZoneService = require(Folder_Services.Zone)
Module_Piano = require(Folder_PianoScripts.PianoModule)

Remote_Note = Folder_Remotes.NoteRemote
Remote_Sustain = Folder_Remotes.SustainRemote
Remote_Animation = Folder_Remotes.AnimationRemote
FinishNonSustainedNotesRemote = Folder_Remotes.FinishNonSustainedNotesRemote

Piano = Folder_PianoScripts.Parent
ZonePart = Piano.Zone

SeatOccupant = Piano.SeatOccupant

PianoZone = ZoneService.new(ZonePart) -- ZONE INITIALIZATION


-- // RECEIVE SERVER NOTES
Remote_Note.OnServerEvent:Connect(function( 
	PacketSender, PianoNote, SoundId, Volume, TimePosition, Pitch, SustainPacket, NoteLifeTime, Fadeout, RawKeyCode
)
	if PacketSender ~= SeatOccupant.Value then
		return end

	for _,targetPlayer in ipairs(PianoZone:getPlayers()) do
		if targetPlayer ~= SeatOccupant.Value then
		Remote_Note:FireClient(
			targetPlayer, PianoNote, SoundId, Volume, TimePosition, Pitch, SustainPacket, NoteLifeTime, Fadeout, RawKeyCode
		)
		end
	end
end)

-- // RECEIVE SUSTAIN PACKETS
Remote_Sustain.OnServerEvent:Connect(function(
	PacketSender, RawKeyCode, Fadeout
)
	if PacketSender ~= SeatOccupant.Value then
		return end

	for _,targetPlayer in ipairs(PianoZone:getPlayers()) do
		if targetPlayer ~= SeatOccupant.Value then
		Remote_Sustain:FireClient(
			targetPlayer, RawKeyCode, Fadeout
		)
		end
	end
end)

-- // FINISH NON SUSTAIN PACKETS
FinishNonSustainedNotesRemote.OnServerEvent:Connect(function(
	PacketSender, Fadeout
)
	if PacketSender ~= SeatOccupant.Value then
		return end

	for _,targetPlayer in ipairs(PianoZone:getPlayers()) do
		if targetPlayer ~= SeatOccupant.Value then
			FinishNonSustainedNotesRemote:FireClient(
				targetPlayer, Fadeout
			)
		end
	end
end)

-- // ANIMATION PACKETS
Remote_Animation.OnServerEvent:Connect(function(
	PacketSender, key, value
)
	if PacketSender ~= SeatOccupant.Value then
		return end

	for _,targetPlayer in ipairs(PianoZone:getPlayers()) do
		if targetPlayer ~= SeatOccupant.Value then
			Module_Piano.PianoAnimation(key, value)
		end
	end
end)