-- VARIABLES
TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local module = {}

--// SETTINGS
local ActiveColor = Color3.fromRGB(106, 106, 106)
local ShiftColor = Color3.fromRGB(62, 62, 62)
local TurnedOffColor = Color3.fromRGB(150, 150, 150)
local WhiteKeyColor = Color3.fromRGB(0, 0, 0)
local BlackKeyColor = Color3.fromRGB(255, 255, 255)

-- FUNCTIONS
-- // KEYS FUNCTIONS
function IsBlack(note)
	if note%12 == 2 or note%12 == 4 or note%12 == 7 or note%12 == 9 or note%12 == 11 then
		return true
	end
	return
end

function module.FinishNote(KeyFrame,Note)
	if not Note then return end
	local PianoNote1 = KeyFrame:FindFirstChild(Note)
	if PianoNote1 then
		if IsBlack(Note) then
			PianoNote1.ImageColor3 = WhiteKeyColor
		else
			PianoNote1.ImageColor3 = BlackKeyColor
		end
	end
end

function module.PlayNote(KeyFrame,Note)
	local PianoNote = KeyFrame:FindFirstChild(Note)
	if PianoNote then
		PianoNote.ImageColor3 = ActiveColor
	end
end

-- // FRAME FUNCTIONS
function module.ShowHideFrame(frame)
	frame.Visible = not frame.Visible
end

function module.ForceShowFrame(frame)
	frame.Visible = true
end

-- // REAL TIME OBJECT UPDATE
function module.UpdateTextLabel(label, value)
	label.Text = tostring(value)
end

function module.GlowCheck(led, value)
	if value == true then
		led.ImageColor3 = ActiveColor
	else
		led.ImageColor3 = TurnedOffColor
	end
end

function module.ShiftFlash(shiftframe, value)
	if value == true then
		shiftframe.BackgroundColor3 = ActiveColor
	else
		shiftframe.BackgroundColor3 = ShiftColor
	end
end

function module.UpdateCanvasSize(Canvas, Constraint)
	Canvas.CanvasSize = UDim2.new(0, Constraint.AbsoluteContentSize.X, 0, Constraint.AbsoluteContentSize.Y+20)
end


return module
