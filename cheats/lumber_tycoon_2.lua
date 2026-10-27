-- AznoCheats · Lumber Tycoon 2
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

local function startCheat()
    AuthGui:Destroy()

    getgenv().AznoLT2 = getgenv().AznoLT2 or {
        AutoChop = false, AutoSell = false, Fly = false,
        ESP = true, Speed = 40, InfJump = false, Noclip = false,
    }
    local CFG = getgenv().AznoLT2

    local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
    local function getRoot() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
    local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

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

    local flying, flyBV, flyBG = false, nil, nil
    local function startFly()
        local root = getRoot()
        if not root or flying then return end
        flying = true
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = root
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        flyBG.P = 9e4
        flyBG.Parent = root
        RunService:BindToRenderStep("AznoFly", Enum.RenderPriority.Camera.Value, function()
            if not CFG.Fly or not root.Parent then stopFly() return end
            local cam = Camera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * 80 or Vector3.zero
            flyBG.CFrame = cam
        end)
    end
    function stopFly()
        flying = false
        pcall(function() RunService:UnbindFromRenderStep("AznoFly") end)
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
    end

    local function getNearestTree()
        local root = getRoot() if not root then return nil end
        local closest, dist = nil, 200
        for _, tree in pairs(workspace:GetDescendants()) do
            if tree.Name:match("Tree") or tree.Name:match("Wood") or tree:FindFirstChild("CutEvent") then
                local part = tree:IsA("BasePart") and tree or tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")
                if part then
                    local d = (part.Position - root.Position).Magnitude
                    if d < dist then closest = tree dist = d end
                end
            end
        end
        return closest
    end

    task.spawn(function()
        while true do
            task.wait(0.15)
            if CFG.AutoChop then
                local tree, root = getNearestTree(), getRoot()
                if tree and root then
                    local part = tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")
                    if part then
                        root.CFrame = CFrame.new(part.Position + Vector3.new(0,5,0))
                        pcall(function()
                            if tree:FindFirstChild("CutEvent") then tree.CutEvent:FireServer() end
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
            if CFG.AutoSell then
                pcall(function()
                    if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SellWood") then
                        ReplicatedStorage.Remotes.SellWood:FireServer()
                    end
                end)
            end
        end
    end)

    local drawings = {}
    RunService.RenderStepped:Connect(function()
        for _,d in pairs(drawings) do pcall(function() d:Remove() end) end
        drawings = {}
        if not CFG.ESP then return end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:match("Tree") or obj.Name:match("Wood") then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local pos, on = Camera:WorldToViewportPoint(part.Position)
                    if on and pos.Z > 0 then
                        local t = Drawing.new("Text")
                        t.Text=obj.Name t.Size=13 t.Center=true t.Outline=true
                        t.Color=Color3.fromRGB(80,255,120) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                        table.insert(drawings,t)
                    end
                end
            end
        end
    end)

    -- PRO UI
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "AznoCheats"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
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

    local tabs = {"FARM", "VISUALS", "PLAYER", "SETTINGS"}
    local tabBtns, pages = {}, {}

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
        p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        p.CanvasSize = UDim2.new(0,0,0,0)
        p.Visible = false
        p.Parent = Content
        Instance.new("UIListLayout", p).Padding = UDim.new(0, 6)
        pages[name] = p
        return p
    end
    for _,n in ipairs(tabs) do makePage(n) end
    pages["FARM"].Visible = true

    local function switchTab(name)
        for n,p in pairs(pages) do p.Visible = (n==name) end
        for n,b in pairs(tabBtns) do
            b.BackgroundColor3 = (n==name) and Color3.fromRGB(225,29,46) or Color3.fromRGB(12,12,16)
            b.TextColor3 = (n==name) and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,155)
        end
    end

    for i,name in ipairs(tabs) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -16, 0, 32)
        b.Position = UDim2.new(0, 8, 0, 44+(i-1)*38)
        b.BackgroundColor3 = (i==1) and Color3.fromRGB(225,29,46) or Color3.fromRGB(12,12,16)
        b.Text = "  "..name
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

    local function section(page, title)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -8, 0, 22)
        f.BackgroundTransparency = 1
        f.Parent = page
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,0,1,0)
        l.BackgroundTransparency = 1
        l.Text = title
        l.TextColor3 = Color3.fromRGB(225, 29, 46)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
    end

    local function toggle(page, label, key, onChange)
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
        knob.Position = CFG[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.BorderSizePixel = 0
        knob.Parent = sw
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        sw.MouseButton1Click:Connect(function()
            CFG[key] = not CFG[key]
            sw.BackgroundColor3 = CFG[key] and Color3.fromRGB(225,29,46) or Color3.fromRGB(50,50,62)
            TweenService:Create(knob, TweenInfo.new(0.12), {
                Position = CFG[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
            }):Play()
            if onChange then onChange(CFG[key]) end
        end)
    end

    section(pages["FARM"], "AUTO")
    toggle(pages["FARM"], "Auto Chop", "AutoChop")
    toggle(pages["FARM"], "Auto Sell", "AutoSell")

    section(pages["VISUALS"], "ESP")
    toggle(pages["VISUALS"], "Tree ESP", "ESP")

    section(pages["PLAYER"], "MOVEMENT")
    toggle(pages["PLAYER"], "Fly", "Fly", function(v) if v then startFly() else stopFly() end end)
    toggle(pages["PLAYER"], "Infinite Jump", "InfJump")
    toggle(pages["PLAYER"], "Noclip", "Noclip")

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
    local function sBtn(txt, dx, delta)
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
    sBtn("-", -64, -5)
    sBtn("+", -32, 5)

    section(pages["SETTINGS"], "INFO")
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -8, 0, 60)
    info.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    info.Text = "AznoCheats LT2\nAuthKey protected\nINSERT to toggle menu"
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

    print("[AznoCheats] LT2 pro UI loaded — INSERT to toggle")
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
