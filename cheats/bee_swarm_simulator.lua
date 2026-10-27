-- Bee Swarm Simulator Cheat Suite
-- Tested against current map layout as of late 2026. Field positions may shift after major updates; re-scan if ESP drifts.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

getgenv().BSS = getgenv().BSS or {
    AutoFarm = false,
    AutoDig = false,
    AutoConvert = false,
    CollectTokens = true,
    KillBugs = true,
    ESP = true,
    Speed = 35,
    InfJump = false,
    Noclip = false,
}

-- ========== UTIL ==========
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ========== SPEED / MOVEMENT ==========
RunService.Heartbeat:Connect(function()
    local hum = getHumanoid()
    if hum and BSS.Speed > 16 then
        hum.WalkSpeed = BSS.Speed
    end
    if BSS.Noclip then
        local char = getCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if BSS.InfJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ========== AUTO DIG / FARM ==========
local function dig()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("ClickEvent") then
        tool.ClickEvent:FireServer()
    end
end

RunService.Heartbeat:Connect(function()
    if BSS.AutoDig then
        dig()
    end
end)

-- Auto convert pollen when bag is near full
task.spawn(function()
    while true do
        task.wait(1.5)
        if BSS.AutoConvert then
            local stat = LocalPlayer:FindFirstChild("PlayerStats") or LocalPlayer:FindFirstChild("Stats")
            -- Fallback path used by most BSS forks
            pcall(function()
                ReplicatedStorage.Events.PlayerActivesCommand:FireServer({["Name"] = "Convert Pollens"})
            end)
        end
    end
end)

-- ========== TOKEN / LOOT COLLECT ==========
local function collectTokens()
    if not BSS.CollectTokens then return end
    local root = getRoot()
    if not root then return end
    for _, v in pairs(workspace.Collectibles:GetChildren()) do
        if v:IsA("BasePart") or v:FindFirstChild("Handle") then
            local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle")
            if part and (part.Position - root.Position).Magnitude < 40 then
                root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                task.wait(0.05)
            end
        end
    end
end

-- ========== BUG KILL (simple orbit + dig) ==========
local function killBugs()
    if not BSS.KillBugs then return end
    local root = getRoot()
    if not root then return end
    for _, mob in pairs(workspace.Monsters:GetChildren()) do
        local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob.PrimaryPart
        if hrp and (hrp.Position - root.Position).Magnitude < 80 then
            root.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 8, 0))
            dig()
            task.wait(0.08)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if BSS.AutoFarm then
            collectTokens()
            killBugs()
        end
    end
end)

-- ========== ESP ==========
local drawings = {}
local function clearESP()
    for _, d in pairs(drawings) do
        if d.Remove then d:Remove() end
    end
    drawings = {}
end

local function createESP(obj, text, color)
    local bill = Drawing.new("Text")
    bill.Text = text
    bill.Size = 14
    bill.Center = true
    bill.Outline = true
    bill.Color = color or Color3.fromRGB(0, 255, 100)
    bill.Visible = false
    table.insert(drawings, bill)
    return bill
end

RunService.RenderStepped:Connect(function()
    clearESP()
    if not BSS.ESP then return end
    -- Field tokens / rare spawns
    if workspace:FindFirstChild("Collectibles") then
        for _, v in pairs(workspace.Collectibles:GetChildren()) do
            local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local t = createESP(part, v.Name, Color3.fromRGB(255, 220, 50))
                    t.Position = Vector2.new(pos.X, pos.Y)
                    t.Visible = true
                end
            end
        end
    end
    -- Mobs
    if workspace:FindFirstChild("Monsters") then
        for _, mob in pairs(workspace.Monsters:GetChildren()) do
            local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
            if hrp then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local t = createESP(hrp, mob.Name, Color3.fromRGB(255, 80, 80))
                    t.Position = Vector2.new(pos.X, pos.Y)
                    t.Visible = true
                end
            end
        end
    end
end)

-- ========== SIMPLE UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BSSMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 280)
Frame.Position = UDim2.new(0, 20, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Title.Text = "BSS Cheat | INSERT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

local function makeToggle(name, y, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 26)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Text = name .. ": OFF"
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(function()
        BSS[key] = not BSS[key]
        btn.Text = name .. ": " .. (BSS[key] and "ON" or "OFF")
        btn.BackgroundColor3 = BSS[key] and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(35, 35, 45)
    end)
end

makeToggle("Auto Farm", 40, "AutoFarm")
makeToggle("Auto Dig", 70, "AutoDig")
makeToggle("Auto Convert", 100, "AutoConvert")
makeToggle("Collect Tokens", 130, "CollectTokens")
makeToggle("Kill Bugs", 160, "KillBugs")
makeToggle("ESP", 190, "ESP")
makeToggle("Inf Jump", 220, "InfJump")
makeToggle("Noclip", 250, "Noclip")

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Frame.Visible = not Frame.Visible
    end
end)

print("[BSS] loaded — INSERT to toggle menu")
