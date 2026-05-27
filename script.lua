-- script.lua - Versi super stabil tanpa library tambahan
print("Script mulai dijalankan")

-- Buat GUI sederhana tanpa library
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MySimpleGUI"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "Script Sederhana v1.0"
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-- Tombol Fly
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 260, 0, 40)
flyBtn.Position = UDim2.new(0, 20, 0, 50)
flyBtn.Text = "Aktifkan Fly"
flyBtn.Parent = frame

local flying = false
local bodyVel = nil

flyBtn.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    
    if not flying then
        flying = true
        flyBtn.Text = "Nonaktifkan Fly"
        humanoid.PlatformStand = true
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVel.Parent = root
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if not flying then return end
            if not root then return end
            local move = Vector3.new(0,0,0)
            local uis = game:GetService("UserInputService")
            if uis:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-50) end
            if uis:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,50) end
            if uis:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-50,0,0) end
            if uis:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(50,0,0) end
            if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,50,0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0,-50,0) end
            bodyVel.Velocity = char.CFrame:VectorToWorldSpace(move)
        end)
    else
        flying = false
        flyBtn.Text = "Aktifkan Fly"
        humanoid.PlatformStand = false
        if bodyVel then bodyVel:Destroy() end
    end
end)

print("GUI selesai dibuat, script siap!")
