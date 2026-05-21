-- Roblox War Tycoon: Perfect Silent Aim v6 (Ultimate Edition - Optimized)
-- Coded by: ita217 | Absolute-01 Configuration
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera



-- الإعدادات الثابتة
local Settings = {
    Enabled = true,
    FOV = 110,
    TargetPart = "Head",
    MaxDistance = 300
}

local CurrentTarget = nil
local IsAiming = false

-- المحرك الصامت
local function GetClosestTarget()
    local Closest = nil
    local ClosestDist = math.huge
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, Player in pairs(Players:GetPlayers()) do
        if Player == LocalPlayer or (Player.Team and Player.Team == LocalPlayer.Team) then continue end

        local Char = Player.Character
        local Humanoid = Char and Char:FindFirstChildOfClass("Humanoid")
        local Part = Char and Char:FindFirstChild(Settings.TargetPart)

        if Humanoid and Humanoid.Health > 0 and Part then
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            local Dist = (Vector2.new(Pos.X, Pos.Y) - Center).Magnitude
            local WorldDist = (Part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

            if OnScreen and Dist < Settings.FOV and WorldDist < Settings.MaxDistance then
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    Closest = Part
                end
            end
        end
    end
    return Closest
end

-- الـ Hook المحترف
local OldNameCall
OldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    if Settings.Enabled and IsAiming and CurrentTarget then
        if Method == "Raycast" then
            local Origin = Args[1]
            local Direction = (CurrentTarget.Position - Origin).Unit * 1000
            return OldNameCall(self, Origin, Direction, unpack(Args, 3))
        elseif Method == "FindPartOnRay" then
            local Origin = Args[1].Origin
            local Direction = (CurrentTarget.Position - Origin).Unit * 1000
            return OldNameCall(self, Ray.new(Origin, Direction), unpack(Args, 2))
        elseif Method == "FireServer" and type(Args[1]) == "Vector3" then
            Args[1] = CurrentTarget.Position
            return OldNameCall(self, unpack(Args))
        end
    end

    return OldNameCall(self, ...)
end)

-- نظام التحكم التلقائي
UserInputService.InputBegan:Connect(function(Input, GPE)
    if GPE then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsAiming = true
        CurrentTarget = GetClosestTarget()
    end
end)

UserInputService.InputEnded:Connect(function(Input, GPE)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsAiming = false
        CurrentTarget = nil
    end
end)
