-- AznoCheats · Bee Swarm Simulator
-- Pro UI (Ghost-style) + AuthKey

local AUTH_KEY = "CHANGE_ME_TO_YOUR_PRIVATE_KEY"
local REMOTE_KEY_URL = ""

local function checkKey(input)
    if type(input) ~= "string" or input == "" then return false end
    if input == AUTH_KEY then return true end
    if REMOTE_KEY_URL ~= "" then
        local ok, body = pcall(function() return game:HttpGet(REMOTE_KEY_URL) end)
        if ok and body then
            for line in body:gmatch("[^\r\n]+") do
                if line:match("^%s*(.-)%s*$") == input then return true end
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
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera

-- ========== AUTH ========== --
local AuthGui = Instance.new("ScreenGui")
AuthGui.Name = "AznoAuth"
AuthGui.ResetOnSpawn = false
AuthGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AuthGui.Parent = game:GetService("CoreGui")

local AuthBg = Instance.new("Frame")
AuthBg.Size = UDim2.new(0, 340, 0, 160)
AuthBg.Position = UDim2.new(0.5, -170, 0.5, -80)
AuthBg.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
AuthBg.BorderSizePixel = 0
AuthBg.Parent = AuthGui
Instance.new("UICorner", AuthBg).CornerRadius = UDim.new(0, 10)

local AuthStroke = Instance.new("UIStroke")
AuthStroke.Color = Color3.fromRGB(225, 29, 46)
AuthStroke.Thickness = 1
AuthStroke.Transparency = 0.6
AuthStroke.Parent = AuthBg

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 36)
AuthTitle.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
AuthTitle.Text = "  AZNOCHEATS  ·  AUTH"
AuthTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.TextSize = 13
AuthTitle.TextXAlignment = Enum.TextXAlignment.Left
AuthTitle.Parent = AuthBg
Instance.new("UICorner", AuthTitle).CornerRadius = UDim.new(0, 10)

local AuthBox = Instance.new("TextBox")
AuthBox.Size = UDim2.new(1, -28, 0, 34)
AuthBox.Position = UDim2.new(0, 14, 0, 52)
AuthBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
AuthBox.TextColor3 = Color3.fromRGB(230, 230, 235)
AuthBox.PlaceholderText = "Enter Auth Key..."
AuthBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
AuthBox.Font = Enum.Font.Gotham
AuthBox.TextSize = 13
AuthBox.ClearTextOnFocus = false
AuthBox.Parent = AuthBg
Instance.new("UICorner", AuthBox).CornerRadius = UDim.new(0, 6)

local AuthStatus = Instance.new("TextLabel")
AuthStatus.Size = UDim2.new(1, -28, 0, 18)
AuthStatus.Position = UDim2.new(0, 14, 0, 92)
AuthStatus.BackgroundTransparency = 1
AuthStatus.Text = ""
AuthStatus.TextColor3 = Color3.fromRGB(225, 29, 46)
AuthStatus.Font = Enum.Font.Gotham
AuthStatus.TextSize = 11
AuthStatus.TextXAlignment = Enum.TextXAlignment.Left
AuthStatus.Parent = AuthBg

local AuthBtn = Instance.new("TextButton")
AuthBtn.Size = UDim2.new(1, -28, 0, 32)
AuthBtn.Position = UDim2.new(0, 14, 0, 114)
AuthBtn.BackgroundColor3 = Color3.fromRGB(225, 29, 46)
AuthBtn.Text = "Unlock"
AuthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthBtn.Font = Enum.Font.GothamBold
AuthBtn.TextSize = 13
AuthBtn.Parent = AuthBg
Instance.new("UICorner", AuthBtn).CornerRadius = UDim.new(0, 6)

-- ========== MAIN CHEAT ========== --
local function startCheat()
    AuthGui:Destroy()

    getgenv().AznoBSS = getgenv().AznoBSS or {
        AutoFarm = false, AutoDig = false, AutoConvert = false,
        CollectTokens = true, KillBugs = true,
        ESP = true, ESP_Tokens = true, ESP_Bugs = true,
        Speed = 35, InfJump = false, Noclip = false,
    }
    local CFG = getgenv().AznoBSS

    local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
    local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
    local function getRoot() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end

    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    RunService.Heartbeat:Connect(function()
        local hum = getHum()
        if hum and CFG.Speed > 16 then hum.WalkSpeed = CFG.Speed end
        if CFG.Noclip then
            local c = getChar()
            if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if CFG.InfJump then local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
    end)

    local function dig()
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("ClickEvent") then pcall(function() tool.ClickEvent:FireServer() end) end
    end

    RunService.Heartbeat:Connect(function() if CFG.AutoDig then dig() end end)

    task.spawn(function()
        while true do
            task.wait(1.5)
            if CFG.AutoConvert then
                pcall(function() ReplicatedStorage.Events.PlayerActivesCommand:FireServer({["Name"]="Convert Pollens"}) end)
            end
        end
    end)

    local function collectTokens()
        if not CFG.CollectTokens then return end
        local root = getRoot() if not root then return end
        local folder = workspace:FindFirstChild("Collectibles") if not folder then return end
        for _,v in pairs(folder:GetChildren()) do
            local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle")
            if part and (part.Position-root.Position).Magnitude < 40 then
                root.CFrame = CFrame.new(part.Position + Vector3.new(0,3,0))
                task.wait(0.05)
            end
        end
    end

    local function killBugs()
        if not CFG.KillBugs then return end
        local root = getRoot() if not root then return end
        local monsters = workspace:FindFirstChild("Monsters") if not monsters then return end
        for _,mob in pairs(monsters:GetChildren()) do
            local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
            if hrp and (hrp.Position-root.Position).Magnitude < 80 then
                root.CFrame = CFrame.new(hrp.Position + Vector3.new(0,8,0))
                dig() task.wait(0.08)
            end
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.2)
            if CFG.AutoFarm then collectTokens() killBugs() end
        end
    end)

    local drawings = {}
    RunService.RenderStepped:Connect(function()
        for _,d in pairs(drawings) do pcall(function() d:Remove() end) end
        drawings = {}
        if not CFG.ESP then return end
        if CFG.ESP_Tokens and workspace:FindFirstChild("Collectibles") then
            for _,v in pairs(workspace.Collectibles:GetChildren()) do
                local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle")
                if part then
                    local pos, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local t = Drawing.new("Text")
                        t.Text=v.Name t.Size=14 t.Center=true t.Outline=true
                        t.Color=Color3.fromRGB(255,220,50) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                        table.insert(drawings,t)
                    end
                end
            end
        end
        if CFG.ESP_Bugs and workspace:FindFirstChild("Monsters") then
            for _,mob in pairs(workspace.Monsters:GetChildren()) do
                local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                if hrp then
                    local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                    if on then
                        local t = Drawing.new("Text")
                        t.Text=mob.Name t.Size=14 t.Center=true t.Outline=true
                        t.Color=Color3.fromRGB(255,80,80) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                        table.insert(drawings,t)
                    end
                end
            end
        end
    end)

    -- ========== PRO UI ========== --
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "AznoCheats"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 520, 0, 340)
    Main.Position = UDim2.new(0.5, -260, 0.5, -170)
    Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = Gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 52)
    Stroke.Thickness = 1
    Stroke.Parent = Main

    -- Sidebar
    local Side = Instance.new("Frame")
    Side.Size = UDim2.new(0, 140, 1, 0)
    Side.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Side.BorderSizePixel = 0
    Side.Parent = Main
    Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 10)

    local SideFix = Instance.new("Frame")
    SideFix.Size = UDim2.new(0, 12, 1, 0)
    SideFix.Position = UDim2.new(1, -12, 0, 0)
    SideFix.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    SideFix.BorderSizePixel = 0
    SideFix.Parent = Side

    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(1, 0, 0, 44)
    Logo.BackgroundTransparency = 1
    Logo.Text = "AZNOCHEATS"
    Logo.TextColor3 = Color3.fromRGB(225, 29, 46)
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 12
    Logo.Parent = Side

    local tabs = {"COMBAT", "VISUALS", "PLAYER", "SETTINGS"}
    local tabBtns = {}
    local pages = {}
    local currentTab = "COMBAT"

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -150, 1, -16)
    Content.Position = UDim2.new(0, 148, 0, 8)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local function makePage(name)
        local p = Instance.new("ScrollingFrame")
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.BorderSizePixel = 0
        p.ScrollBarThickness = 3
        p.ScrollBarImageColor3 = Color3.fromRGB(225, 29, 46)
        p.CanvasSize = UDim2.new(0, 0, 0, 0)
        p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        p.Visible = false
        p.Parent = Content
        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0, 6)
        lay.Parent = p
        pages[name] = p
        return p
    end

    for _, name in ipairs(tabs) do makePage(name) end
    pages["COMBAT"].Visible = true

    local function switchTab(name)
        currentTab = name
        for n, p in pairs(pages) do p.Visible = (n == name) end
        for n, b in pairs(tabBtns) do
            if n == name then
                b.BackgroundColor3 = Color3.fromRGB(225, 29, 46)
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                b.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
                b.TextColor3 = Color3.fromRGB(140, 140, 155)
            end
        end
    end

    for i, name in ipairs(tabs) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -16, 0, 32)
        b.Position = UDim2.new(0, 8, 0, 44 + (i-1)*38)
        b.BackgroundColor3 = (i==1) and Color3.fromRGB(225,29,46) or Color3.fromRGB(12,12,16)
        b.Text = "  " .. name
        b.TextColor3 = (i==1) and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,155)
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.BorderSizePixel = 0
        b.Parent = Side
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function() switchTab(name) end)
        tabBtns[name] = b
    end

    -- Section header
    local function section(page, title)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -8, 0, 22)
        f.BackgroundTransparency = 1
        f.Parent = page
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Text = title
        l.TextColor3 = Color3.fromRGB(225, 29, 46)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
    end

    -- Toggle row
    local function toggle(page, label, key)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 30)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        row.BorderSizePixel = 0
        row.Parent = page
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -56, 1, 0)
        name.Position = UDim2.new(0, 12, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = label
        name.TextColor3 = Color3.fromRGB(210, 210, 220)
        name.Font = Enum.Font.Gotham
        name.TextSize = 12
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = row

        local sw = Instance.new("TextButton")
        sw.Size = UDim2.new(0, 36, 0, 18)
        sw.Position = UDim2.new(1, -46, 0.5, -9)
        sw.BackgroundColor3 = CFG[key] and Color3.fromRGB(225,29,46) or Color3.fromRGB(50,50,62)
        sw.Text = ""
        sw.BorderSizePixel = 0
        sw.Parent = row
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = CFG[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.BorderSizePixel = 0
        knob.Parent = sw
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        sw.MouseButton1Click:Connect(function()
            CFG[key] = not CFG[key]
            sw.BackgroundColor3 = CFG[key] and Color3.fromRGB(225,29,46) or Color3.fromRGB(50,50,62)
            TweenService:Create(knob, TweenInfo.new(0.12), {
                Position = CFG[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            }):Play()
        end)
    end

    -- Build pages
    section(pages["COMBAT"], "FARM")
    toggle(pages["COMBAT"], "Auto Farm", "AutoFarm")
    toggle(pages["COMBAT"], "Auto Dig", "AutoDig")
    toggle(pages["COMBAT"], "Auto Convert", "AutoConvert")
    toggle(pages["COMBAT"], "Collect Tokens", "CollectTokens")
    toggle(pages["COMBAT"], "Kill Bugs", "KillBugs")

    section(pages["VISUALS"], "ESP")
    toggle(pages["VISUALS"], "Enable ESP", "ESP")
    toggle(pages["VISUALS"], "Token ESP", "ESP_Tokens")
    toggle(pages["VISUALS"], "Bug ESP", "ESP_Bugs")

    section(pages["PLAYER"], "MOVEMENT")
    toggle(pages["PLAYER"], "Infinite Jump", "InfJump")
    toggle(pages["PLAYER"], "Noclip", "Noclip")

    -- Speed slider-like buttons
    local speedRow = Instance.new("Frame")
    speedRow.Size = UDim2.new(1, -8, 0, 30)
    speedRow.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    speedRow.BorderSizePixel = 0
    speedRow.Parent = pages["PLAYER"]
    Instance.new("UICorner", speedRow).CornerRadius = UDim.new(0, 6)
    local speedLbl = Instance.new("TextLabel")
    speedLbl.Size = UDim2.new(0.5, 0, 1, 0)
    speedLbl.Position = UDim2.new(0, 12, 0, 0)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "Speed: " .. CFG.Speed
    speedLbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    speedLbl.Font = Enum.Font.Gotham
    speedLbl.TextSize = 12
    speedLbl.TextXAlignment = Enum.TextXAlignment.Left
    speedLbl.Parent = speedRow
    local function speedBtn(txt, dx, delta)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, dx, 0.5, -11)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        b.Text = txt
        b.TextColor3 = Color3.fromRGB(220,220,230)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.Parent = speedRow
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function()
            CFG.Speed = math.clamp(CFG.Speed + delta, 16, 120)
            speedLbl.Text = "Speed: " .. CFG.Speed
        end)
    end
    speedBtn("-", -64, -5)
    speedBtn("+", -32, 5)

    section(pages["SETTINGS"], "INFO")
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -8, 0, 60)
    info.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    info.Text = "AznoCheats BSS\nAuthKey protected\nINSERT to toggle menu"
    info.TextColor3 = Color3.fromRGB(140, 140, 155)
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.Parent = pages["SETTINGS"]
    Instance.new("UICorner", info).CornerRadius = UDim.new(0, 6)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            Main.Visible = not Main.Visible
        end
    end)

    print("[AznoCheats] BSS pro UI loaded — INSERT to toggle")
end

AuthBtn.MouseButton1Click:Connect(function()
    if checkKey(AuthBox.Text) then
        AuthStatus.TextColor3 = Color3.fromRGB(34, 197, 94)
        AuthStatus.Text = "Key accepted"
        task.wait(0.35)
        startCheat()
    else
        AuthStatus.TextColor3 = Color3.fromRGB(225, 29, 46)
        AuthStatus.Text = "Invalid key"
    end
end)
AuthBox.FocusLost:Connect(function(e) if e then AuthBtn.MouseButton1Click:Fire() end end)
