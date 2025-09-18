-- to add a soundfont, append the module with the latest id and data

-- Note that Lifetime + Fadeout < 8!
-- Fadeout also doubles as a minimum sound duration of sorts

-- Packet Types: 1 = 88 Keys, 2 = 61 Keys, 3 = 49 Keys, 4 = 6 Audio Files

local Soundfonts = {
	
	[1] = { -- Soundfont ID, If you wish to add a new one always remember to sum 1 more to the ID.
		Name = "Ivory",
		AssetIds = {
			"233836579",
			"233844049",
			"233845680",
			"233852841",
			"233854135",
			"233856105"
		}, 
		MaxLifetime = 3.5, -- Time that it takes the note to be deleted (8 Max)
		VolumeModifier = 0.5, -- Hard-coded volume boost/lowering
		Offset = 0, -- Soundfont offset (extra miliseconds so it's not delayed)
		Fadeout = 1, -- Time that sustain notes exist (Release)
		Uploader = "Repansniper", -- Person who uploaded it (UNUSED)
		PacketType = 4 -- Packet Type (88, 61, 49 or 6 audio files per note/scales)
	},
	
}

return Soundfonts
