-- ============================================
-- Nama Script:    Ultimate Script v2.0
-- Author:         [alda]
-- Game Target:    Universal
-- Fitur:          ESP, Fly, Speed, Noclip, GUI, Keybind
-- ============================================

-- 🔒 Cegah script berjalan ganda
if _G.ScriptLoaded then return end
_G.ScriptLoaded = true

-- 📦 Load Service
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ================================
-- 1. VARIABEL GLOBAL (Pengaturan Dasar)
-- ================================
local features = {
    ESP = false,
    Fly = false,
    Noclip = false,
}
local speedValue = 16 -- Kecepatan normal
local flySpeed = 50

-- ================================
-- 2. FITUR UTAMA
-- ================================

-- 🕵️‍♂️ 2.1. ESP (Lihat Pemain)
local espObjects = {}
local function CreateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local esp = Instance.new("BillboardGui")
                esp.Name = "ESP_" .. player.Name
                esp.Size = UDim2.new(0, 200, 0, 50)
                esp.StudsOffset = Vector3.new(0, 2.5, 0)
                esp.AlwaysOnTop = true

                local label = Instance.new("TextLabel", esp)
                label.Text = string.format("%s\n[%.0fm]", player.Name, (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                label.TextColor3 = player.TeamColor and player.TeamColor.Color or Color3.new(1, 0, 0)
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 1, 0)

                esp.Parent = character
                table.insert(espObjects, esp)
            end
        end
    end
end

local function ToggleESP()
    features.ESP = not features.ESP
    if features.ESP then
        CreateESP()
        Players.PlayerAdded:Connect(function(player)
            if features.ESP then
                task.wait(0.5)
                CreateESP()
            end
        end)
    else
        for _, obj in pairs(espObjects) do obj:Destroy() end
        espObjects = {}
    end
end

-- ✈️ 2.2. Fly Mode
local bodyVelocity = nil
local flyConnection = nil
local function ToggleFly()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not (humanoid and rootPart) then return end

    features.Fly = not features.Fly
    if features.Fly then
        humanoid.PlatformStand = true
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Parent = rootPart

        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not features.Fly or not rootPart then
                if flyConnection then flyConnection:Disconnect() end
                return
            end

            local move = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -flySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, flySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-flySpeed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(flySpeed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, flySpeed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0, -flySpeed, 0) end

            bodyVelocity.Velocity = char.CFrame:VectorToWorldSpace(move)
        end)
    else
        humanoid.PlatformStand = false
        if bodyVelocity then bodyVelocity:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
    end
end

-- 🏃 2.3. Speed Hack
local function SetSpeed(speed)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed
    end
end

-- 🧱 2.4. Noclip (Tembus Dinding)
local noclipConnection
local function ToggleNoclip()
    features.Noclip = not features.Noclip
    if features.Noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if not LocalPlayer.Character then return end
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ================================
-- 3. GUI MENGGUNAKAN WINDUI (Lebih Ringan & Stabil)
-- ================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Ultimate Script v2.0",
    Author = "Your Name",
    Folder = "MyScript",
    Size = UDim2.fromOffset(600, 450),
    ToggleKey = Enum.KeyCode.RightShift  -- Tekan Shift Kanan untuk Buka/Tutup GUI
})

-- Tab Utama
local MainTab = Window:AddTab("🚀 Main")

MainTab:AddButton("Fly (Toggle)", function()
    ToggleFly()
end)
MainTab:AddButton("Noclip (Toggle)", function()
    ToggleNoclip()
end)
MainTab:AddSlider("Speed Hack", 16, 250, speedValue, function(value)
    speedValue = value
    SetSpeed(speedValue)
end)

-- Tab Visuals
local VisualsTab = Window:AddTab("👁️ Visuals")
VisualsTab:AddButton("ESP Player (Toggle)", function()
    ToggleESP()
end)

-- Tab Pengaturan
local SettingsTab = Window:AddTab("⚙️ Settings")
SettingsTab:AddButton("Destroy UI", function()
    Window:Destroy()
end)

-- ================================
-- 4. KEYBIND (Tombol Pintasan)
-- ================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        ToggleFly()
    elseif input.KeyCode == Enum.KeyCode.V then
        ToggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.X then
        ToggleESP()
    end
end)

print("Script v2.0 loaded! Press F to Fly, V to Noclip, X for ESP.")