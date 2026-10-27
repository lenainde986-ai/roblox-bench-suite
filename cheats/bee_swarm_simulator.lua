-- AznoCheats · Bee Swarm Simulator
-- Private build with AuthKey

--[[
    ======================== AUTH KEY ========================
    Change this key to whatever you want.
    Only people who put the exact same key will be able to run the script.
]]
local AUTH_KEY = "CHANGE_ME_TO_YOUR_PRIVATE_KEY"

-- Optional: remote key list (raw text file, one key per line)
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
Frame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
Title.Text = "AznoCheats · BSS · Enter Key"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

local Box = Instance.new("TextBox")
Box.Size = UDim2.new(1, -24, 0, 32)
Box.Position = UDim2.new(0, 12, 0, 48)
Box.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
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
Btn.BackgroundColor3 = Color3.fromRGB(45, 95, 55)
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

    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

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

    local function dig()
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("ClickEvent") then
            pcall(function() tool.ClickEvent:FireServer() end)
        end
    end

    RunService.Heartbeat:Connect(function()
        if BSS.AutoDig then dig() end
    end)

    task.spawn(function()
        while true do
            task.wait(1.5)
            if BSS.AutoConvert then
                pcall(function()
                    ReplicatedStorage.Events.PlayerActivesCommand:FireServer({["Name"] = "Convert Pollens"})
                end)
            end
        end
    end)

    local function collectTokens()
        if not BSS.CollectTokens then return end
        local root = getRoot()
        if not root then return end
        local folder = workspace:FindFirstChild("Collectibles")
        if not folder then return end
        for _, v in pairs(folder:GetChildren()) do
            local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle")
            if part and (part.Position - root.Position).Magnitude < 40 then
                root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                task.wait(0.05)
            end
        end
    end

    local function killBugs()
        if not BSS.KillBugs then return end
        local root = getRoot()
        if not root then return end
        local monsters = workspace:FindFirstChild("Monsters")
        if not monsters then return end
        for _, mob in pairs(monsters:GetChildren()) do
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

    local drawings = {}
    local function clearESP()
        for _, d in pairs(drawings) do
            pcall(function() d:Remove() end)
        end
        drawings = {}
    end

    RunService.RenderStepped:Connect(function()
        clearESP()
        if not BSS.ESP then return end
        if workspace:FindFirstChild("Collectibles") then
            for _, v in pairs(workspace.Collectibles:GetChildren()) do
                local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle")
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local t = Drawing.new("Text")
                        t.Text = v.Name
                        t.Size = 14
                        t.Center = true
                        t.Outline = true
                        t.Color = Color3.fromRGB(255, 220, 50)
                        t.Position = Vector2.new(pos.X, pos.Y)
                        t.Visible = true
                        table.insert(drawings, t)
                    end
                end
            end
        end
        if workspace:FindFirstChild("Monsters") then
            for _, mob in pairs(workspace.Monsters:GetChildren()) do
                local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                if hrp then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local t = Drawing.new("Text")
                        t.Text = mob.Name
                        t.Size = 14
                        t.Center = true
                        t.Outline = true
                        t.Color = Color3.fromRGB(255, 80, 80)
                        t.Position = Vector2.new(pos.X, pos.Y)
                        t.Visible = true
                        table.insert(drawings, t)
                    end
                end
            end
        end
    end)

    local Menu = Instance.new("ScreenGui")
    Menu.Name = "AznoBSS"
    Menu.ResetOnSpawn = false
    Menu.Parent = game:GetService("CoreGui")

    local MFrame = Instance.new("Frame")
    MFrame.Size = UDim2.new(0, 220, 0, 280)
    MFrame.Position = UDim2.new(0, 20, 0.3, 0)
    MFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    MFrame.BorderSizePixel = 0
    MFrame.Active = true
    MFrame.Draggable = true
    MFrame.Parent = Menu

    local MTitle = Instance.new("TextLabel")
    MTitle.Size = UDim2.new(1, 0, 0, 28)
    MTitle.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
    MTitle.Text = "AznoCheats BSS | INSERT"
    MTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MTitle.Font = Enum.Font.GothamBold
    MTitle.TextSize = 13
    MTitle.Parent = MFrame

    local function makeToggle(name, y, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 26)
        btn.Position = UDim2.new(0, 8, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Text = name .. ": OFF"
        btn.Parent = MFrame
        btn.MouseButton1Click:Connect(function()
            BSS[key] = not BSS[key]
            btn.Text = name .. ": " .. (BSS[key] and "ON" or "OFF")
            btn.BackgroundColor3 = BSS[key] and Color3.fromRGB(30, 85, 45) or Color3.fromRGB(32, 32, 42)
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
            MFrame.Visible = not MFrame.Visible
        end
    end)

    print("[AznoCheats] BSS unlocked — INSERT to toggle menu")
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
