local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

local BALL_NAME = "Ball"
local EXPAND_SIZE = 2.6  -- الحجم الثابت عند التفعيل

local enabled = false
local trackedBalls = {}

-- دالة تشغيل الصوت (صوت الموت)
local function playSound(id)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Parent = game:GetService("SoundService")
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
end

-- تسجيل الكرة وحفظ خصائصها الأصلية
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
			end
		end)
	end
end

-- مراقبة الكرات الموجودة والجديدة
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

-- حلقة التحديث المستمر
RunService.Heartbeat:Connect(function()
	if not enabled then return end

	for part, originalProps in pairs(trackedBalls) do
		if part and part.Parent then
			-- تكبير الحجم بنسبة 2.6
			local newSize = Vector3.new(
				originalProps.Size.X * EXPAND_SIZE,
				originalProps.Size.Y * EXPAND_SIZE,
				originalProps.Size.Z * EXPAND_SIZE
			)
			if part.Size ~= newSize then
				part.Size = newSize
			end

			-- إخفاء الكرة وعدم التصادم
			if part.Transparency ~= 1 then
				part.Transparency = 1
			end
			if part.CanCollide ~= false then
				part.CanCollide = false
			end
		end
	end
end)

-- اختصار التبديل: Shift + K
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		enabled = not enabled
		if enabled then
			playSound(12222242)  -- صوت الموت عند التشغيل
		else
			-- إيقاف التشغيل: إعادة كل كرة لأصلها (بدون صوت)
			for part, originalProps in pairs(trackedBalls) do
				if part and part.Parent then
					part.Size = originalProps.Size
					part.Transparency = originalProps.Transparency
					part.CanCollide = originalProps.CanCollide
				end
			end
		end
	end
end)
