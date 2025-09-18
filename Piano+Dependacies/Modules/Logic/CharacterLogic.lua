local module = {}

TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

module.AddCamera = function(humanoid)
	local SeatPart = humanoid.SeatPart
	local Piano = SeatPart.Parent
	local FocusPart = Piano.Cameras:FindFirstChild("1")
	
	Camera.CameraType = "Scriptable"
	local Goal = {CFrame = FocusPart.CFrame}
	local TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, .25)
	local Animation = TweenService:Create(Camera, TweenInfo, Goal)
	Animation:Play()
	print("[UI Logic] Added custom camera")
end

module.RevokeCamera = function()
	Camera.CameraType = "Custom"
	print("[UI Logic] Removed custom camera")
end

return module
