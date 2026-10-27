-- AznoCheats · Lumber Tycoon 2
-- Private build with AuthKey

--[[
    ======================== AUTH KEY ========================
    Change this key to whatever you want.
]]
local AUTH_KEY = "CHANGE_ME_TO_YOUR_PRIVATE_KEY"
local REMOTE_KEY_URL = ""

local function checkKey(input)
    if type(input) ~= "string" or input == "" then return false end
    if input == AUTH_KEY then return true end
    if REMOTE_KEY_URL ~= "" then
        local ok, body = pcall(function()
            return game:HttpGet(REMOTE_KEY_URL)
        end)
        if ok and body then
            for line in body:gmatch("[^\r\n]+") do
                if line:match("^%s*(.-)%s*$") == input then
                    return true
                end
            end
        end
    end
    return false
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AznoAuth"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 140)
Frame.Position = UDim2.new(0.5, -160, 0.5, -70)
Frame.BackgroundColor3 = Color3.fromRGB(14, 18, 14)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(26, 36, 26)
Title.Text = "AznoCheats · LT2 · Enter Key"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

local Box = Instance.new("TextBox")
Box.Size = UDim2.new(1, -24, 0, 32)
Box.Position = UDim2.new(0, 12, 0, 48)
Box.BackgroundColor3 = Color3.fromRGB(22, 30, 22)
Box.TextColor3 = Color3.fromRGB(220, 220, 220)
Box.PlaceholderText = "Auth Key..."
Box.Font = Enum.Font.Gotham
Box.TextSize = 14
Box.ClearTextOnFocus = false
Box.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -24, 0, 20)
Status.Position = UDim2.new(0, 12, 0, 86)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(200, 80, 80)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Frame

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1, -24, 0, 28)
Btn.Position = UDim2.new(0, 12, 0, 108)
Btn.BackgroundColor3 = Color3.fromRGB(40, 90, 45)
Btn.Text = "Unlock"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 13
Btn.Parent = Frame

local unlocked = false

local function startCheat()
    if unlocked then return end
    unlocked = true
    ScreenGui:Destroy()

    getgenv().LT2 = getgenv().LT2 or {
        AutoChop = false,
        AutoSell = false,
        Fly = false,
        Speed = 40,
        Noclip = false,
        ESP = true,
        InfJump = false,
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

    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

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
            if dir.Magnitude > 0 then
                flyBV.Velocity = dir.Unit * 80
            else
                flyBV.Velocity = Vector3.zero
            end
            flyBG.CFrame = cam
        end)
    end

    function stopFly()
        flying = false
        pcall(function() RunService:UnbindFromRenderStep("LT2Fly") end)
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
    end

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
                        pcall(function()
                            if tree:FindFirstChild("CutEvent") then
                                tree.CutEvent:FireServer()
                            end
                            if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Cut") then
                                ReplicatedStorage.Remotes.Cut:FireServer(tree)
                            end
                        end)
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(3)
            if LT2.AutoSell then
                pcall(function()
                    if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SellWood") then
                        ReplicatedStorage.Remotes.SellWood:FireServer()
                    end
                end)
            end
        end
    end)

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

    local Menu = Instance.new("ScreenGui")
    Menu.Name = "AznoLT2"
    Menu.ResetOnSpawn = false
    Menu.Parent = game:GetService("CoreGui")

    local MFrame = Instance.new("Frame")
    MFrame.Size = UDim2.new(0, 220, 0, 260)
    MFrame.Position = UDim2.new(0, 20, 0.35, 0)
    MFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 16)
    MFrame.BorderSizePixel = 0
    MFrame.Active = true
    MFrame.Draggable = true
    MFrame.Parent = Menu

    local MTitle = Instance.new("TextLabel")
    MTitle.Size = UDim2.new(1, 0, 0, 28)
    MTitle.BackgroundColor3 = Color3.fromRGB(28, 48, 28)
    MTitle.Text = "AznoCheats LT2 | INSERT"
    MTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MTitle.Font = Enum.Font.GothamBold
    MTitle.TextSize = 13
    MTitle.Parent = MFrame

    local function makeToggle(name, y, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 26)
        btn.Position = UDim2.new(0, 8, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(28, 38, 28)
        btn.TextColor3 = Color3.fromRGB(200, 220, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Text = name .. ": OFF"
        btn.Parent = MFrame
        btn.MouseButton1Click:Connect(function()
            LT2[key] = not LT2[key]
            btn.Text = name .. ": " .. (LT2[key] and "ON" or "OFF")
            btn.BackgroundColor3 = LT2[key] and Color3.fromRGB(40, 90, 40) or Color3.fromRGB(28, 38, 28)
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
            MFrame.Visible = not MFrame.Visible
        end
    end)

    print("[AznoCheats] LT2 unlocked — INSERT to toggle menu")
end

Btn.MouseButton1Click:Connect(function()
    local key = Box.Text
    if checkKey(key) then
        Status.TextColor3 = Color3.fromRGB(80, 200, 100)
        Status.Text = "Key accepted"
        task.wait(0.4)
        startCheat()
    else
        Status.TextColor3 = Color3.fromRGB(200, 80, 80)
        Status.Text = "Invalid key"
    end
end)

Box.FocusLost:Connect(function(enter)
    if enter then Btn.MouseButton1Click:Fire() end
end)
