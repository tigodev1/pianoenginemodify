Players = game:GetService("Players")
Folder_Pianos = workspace:FindFirstChild("Pianos")

for _,piano in pairs(Folder_Pianos:GetChildren()) do
	local LocalPianoOccupantValue = piano:FindFirstChild("SeatOccupant")
	local PianoSeat = piano:FindFirstChild("Seat")

	PianoSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if PianoSeat.Occupant then
			print("[OccupantService] "..tostring(piano).." has new occupant: "..tostring(Players:GetPlayerFromCharacter(PianoSeat.Occupant.Parent)))
			LocalPianoOccupantValue.Value = Players:GetPlayerFromCharacter(PianoSeat.Occupant.Parent)
		else
			print("[OccupantService] "..tostring(piano).." has no occupant")
			LocalPianoOccupantValue.Value = nil
		end
	end)

	print("[OccupantService] "..tostring(piano).." Initializated correctly.")
end

print("[OccupantService] SERVICE STARTED CORRECTLY.")