local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

local TOGGLE_KEY = Enum.KeyCode.RightShift
local BALL_NAME = "Ball"  
local DEFAULT_SIZE = 1
local MAX_SIZE = 10
local MIN_SIZE = 0.5

local enabled = false
local currentSize = DEFAULT_SIZE
local guiVisible = true
local trackedBalls = {} 

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 220)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(40, 40, 40)
stroke.Thickness = 2
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "BALL HITBOX EXPANDER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.Text = "ENABLE: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0.9, 0, 0, 25)
sliderLabel.Position = UDim2.new(0.05, 0, 0, 105)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Size: " .. string.format("%.1f", currentSize)
sliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
sliderLabel.TextSize = 14
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = mainFrame

local sliderBg = Instance.new("Frame")
sliderBg.Name = "SliderBg"
sliderBg.Size = UDim2.new(0.9, 0, 0, 20)
sliderBg.Position = UDim2.new(0.05, 0, 0, 135)
sliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sliderBg.Parent = mainFrame

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(0, 10)
sliderBgCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((currentSize - MIN_SIZE) / (MAX_SIZE - MIN_SIZE), 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderFill.Parent = sliderBg

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 10)
sliderFillCorner.Parent = sliderFill

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 22, 0, 22)
knob.Position = UDim2.new((currentSize - MIN_SIZE) / (MAX_SIZE - MIN_SIZE), -11, 0.5, -11)
knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
knob.Parent = sliderBg

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.9, 0, 0, 25)
infoLabel.Position = UDim2.new(0.05, 0, 0, 175)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Toggle GUI: " .. TOGGLE_KEY.Name
infoLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
infoLabel.TextSize = 12
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = mainFrame

local function addBall(part)
	if part:IsA("BasePart") and not trackedBalls[part] then
		trackedBalls[part] = {
			Size = part.Size,
			Transparency = part.Transparency,
			CanCollide = part.CanCollide
		}
		
		part.AncestryChanged:Connect(function()
			if part.Parent == nil then
				trackedBalls[part] = nil
				print("Ball removed")
			end
		end)
		
		print("Ball detected and registered")
	end
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant.Name == BALL_NAME then
		addBall(descendant)
	end
end)

for _, descendant in pairs(workspace:GetDescendants()) do
	if descendant.Name == BALL_NAME then
		addBall(descendant)
	end
end

RunService.Heartbeat:Connect(function()
	if not enabled then return end
	
	for part, originalProps in pairs(trackedBalls) do
		if part and part.Parent then
			local newSize = Vector3.new(
				originalProps.Size.X * currentSize,
				originalProps.Size.Y * currentSize,
				originalProps.Size.Z * currentSize
			)
			
			if part.Size ~= newSize then
				part.Size = newSize
			end
			
			if part.Transparency ~= 0.5 then
				part.Transparency = 0.5
			end
			if part.CanCollide ~= false then
				part.CanCollide = false
			end
		end
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		toggleBtn.Text = "ENABLE: ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
	else
		toggleBtn.Text = "ENABLE: OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		
		for part, originalProps in pairs(trackedBalls) do
			if part and part.Parent then
				part.Size = originalProps.Size
				part.Transparency = originalProps.Transparency
				part.CanCollide = originalProps.CanCollide
			end
		end
	end
end)

local dragging = false

sliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
	                 input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X
		local sliderAbsPos = sliderBg.AbsolutePosition.X
		local sliderAbsSize = sliderBg.AbsoluteSize.X
		local percent = math.clamp((mouseX - sliderAbsPos) / sliderAbsSize, 0, 1)
		
		currentSize = MIN_SIZE + percent * (MAX_SIZE - MIN_SIZE)
		sliderFill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -11, 0.5, -11)
		sliderLabel.Text = "Size: " .. string.format("%.1f", currentSize)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == TOGGLE_KEY then
		guiVisible = not guiVisible
		mainFrame.Visible = guiVisible
	end
end)
