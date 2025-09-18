local module = {}

function module:IsBlack(note)
if note%12 == 2 or note%12 == 4 or note%12 == 7 or note%12 == 9 or note%12 == 11 then
	return true
end
return
	end

function module:PianoKeyCodes()
	local keyCodes = {
		Enum.KeyCode.Zero,
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.Five,
		Enum.KeyCode.Six,
		Enum.KeyCode.Seven,
		Enum.KeyCode.Eight,
		Enum.KeyCode.Nine
	}
	for i = 97, 122 do
		table.insert(keyCodes, Enum.KeyCode[string.upper(string.char(i))])
	end
	return table.unpack(keyCodes)
end

function module:VelocityKeyCodes()
	local VelocityLayers = {}
	for i = 0, 100, 3.2 do
		table.insert(VelocityLayers, math.round(i))
	end
	return VelocityLayers
end


module.Piano88KeyCodes = {
	[1] = 0,
	[2] = -1,
	[3] = -2,
	[4] = -3,
	[5] = -4,
	[6] = -5,
	[7] = -6,
	[8] = -7,
	[9] = -8,
	[10] = -9,
	[11] = -10,
	[12] = -11,
	[13] = -12,
	[14] = -13,
	[15] = -14,

	[16] = 62,
	[17] = 63,
	[18] = 64,
	[19] = 65,
	[20] = 66,
	[21] = 67,
	[22] = 68,
	[23] = 69,
	[24] = 70,
	[25] = 71,
	[26] = 72,
	[27] = 73,
	[28] = 74,
}

return module
