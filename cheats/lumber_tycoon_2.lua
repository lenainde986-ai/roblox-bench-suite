-- Lumber Tycoon 2 Cheat Suite
-- Works on the current LT2 place. Tree nodes and plot ownership checks are soft; re-validate after big updates.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().LT2 = getgenv().LT2 or {
    AutoChop = false,
    AutoSell = false,
    Fly = false,
    Speed = 40,
    Noclip = false,
    ESP = true,
    InfJump = false,
    HardenedAxe = true, -- forces max axe damage path when possible
}

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Movement
RunService.Heartbeat:Connect(function()
    local hum = getHumanoid()
    if hum and LT2.Speed > 16 then
        hum.WalkSpeed = LT2.Speed
    end
    if LT2.Noclip then
        local char = getCharacter()
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if LT2.InfJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Simple fly (CFrame)
local flying = false
local flyBV, flyBG
local function startFly()
    local root = getRoot()
    if not root or flying then return end
    flying = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 9e4
    flyBG.Parent = root
    RunService:BindToRenderStep("LT2Fly", Enum.RenderPriority.Camera.Value, function()
        if not LT2.Fly or not root.Parent then
            stopFly()
            return
        end
        local cam = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        flyBV.Velocity = dir.Unit * 80
        flyBG.CFrame = cam
    end)
end

function stopFly()
    flying = false
    RunService:UnbindFromRenderStep("LT2Fly")
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
end

-- Auto chop nearest tree
local function getNearestTree()
    local root = getRoot()
    if not root then return nil end
    local closest, dist = nil, 200
    for _, tree in pairs(workspace:GetDescendants()) do
        if tree.Name:match("Tree") or tree.Name:match("Wood") or tree:FindFirstChild("CutEvent") then
            local part = tree:IsA("BasePart") and tree or tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")
            if part then
                local d = (part.Position - root.Position).Magnitude
                if d < dist then
                    closest = tree
                    dist = d
                end
            end
        end
    end
    return closest
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if LT2.AutoChop then
            local tree = getNearestTree()
            local root = getRoot()
            if tree and root then
                local part = tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")
                if part then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
                    -- Fire common cut remotes
                    pcall(function()
                        if tree:FindFirstChild("CutEvent") then
                            tree.CutEvent:FireServer()
                        end
                        ReplicatedStorage.Remotes.Cut:FireServer(tree)
                    end)
                end
            end
        end
    end
end)

-- Auto sell (walk to sell point + fire)
task.spawn(function()
    while true do
        task.wait(3)
        if LT2.AutoSell then
            pcall(function()
                ReplicatedStorage.Remotes.SellWood:FireServer()
                -- alternate path used by some LT2 versions
                local plot = workspace:FindFirstChild("PlayerPlots") and workspace.PlayerPlots:FindFirstChild(LocalPlayer.Name)
                if plot then
                    for _, v in pairs(plot:GetDescendants()) do
                        if v.Name:lower():find("sell") and v:IsA("ClickDetector") then
                            fireclickdetector(v)
                        end
                    end
                end
            end)
        end
    end
end)

-- ESP trees / rare wood
local drawings = {}
local function clearESP()
    for _, d in pairs(drawings) do
        pcall(function() d:Remove() end)
    end
    drawings = {}
end

RunService.RenderStepped:Connect(function()
    clearESP()
    if not LT2.ESP then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:match("Tree") or obj.Name:match("Wood") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and pos.Z > 0 then
                    local t = Drawing.new("Text")
                    t.Text = obj.Name
                    t.Size = 13
                    t.Center = true
                    t.Outline = true
                    t.Color = Color3.fromRGB(80, 255, 120)
                    t.Position = Vector2.new(pos.X, pos.Y)
                    t.Visible = true
                    table.insert(drawings, t)
                end
            end
        end
    end
end)

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LT2Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 260)
Frame.Position = UDim2.new(0, 20, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
Title.Text = "LT2 Cheat | INSERT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

local function makeToggle(name, y, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 26)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    btn.TextColor3 = Color3.fromRGB(200, 220, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Text = name .. ": OFF"
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(function()
        LT2[key] = not LT2[key]
        btn.Text = name .. ": " .. (LT2[key] and "ON" or "OFF")
        btn.BackgroundColor3 = LT2[key] and Color3.fromRGB(40, 90, 40) or Color3.fromRGB(30, 40, 30)
        if key == "Fly" then
            if LT2.Fly then startFly() else stopFly() end
        end
    end)
end

makeToggle("Auto Chop", 40, "AutoChop")
makeToggle("Auto Sell", 70, "AutoSell")
makeToggle("Fly", 100, "Fly")
makeToggle("ESP", 130, "ESP")
makeToggle("Inf Jump", 160, "InfJump")
makeToggle("Noclip", 190, "Noclip")

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Frame.Visible = not Frame.Visible
    end
end)

print("[LT2] loaded — INSERT to toggle menu")
