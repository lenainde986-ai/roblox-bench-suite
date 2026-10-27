-- AznoCheats
-- Unified loader · Games tab · BSS + LT2

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

-- ===================== AUTH ===================== --
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
AuthStroke.Transparency = 0.55
AuthStroke.Parent = AuthBg

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 36)
AuthTitle.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
AuthTitle.Text = "  AZNOCHEATS"
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

-- ===================== MAIN ===================== --
local function openMenu()
    AuthGui:Destroy()

    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    -- Configs
    getgenv().Azno = getgenv().Azno or {
        BSS = {
            AutoFarm=false, AutoDig=false, AutoConvert=false,
            CollectTokens=true, KillBugs=true,
            ESP=true, ESP_Tokens=true, ESP_Bugs=true,
            Speed=35, InfJump=false, Noclip=false, Loaded=false,
        },
        LT2 = {
            AutoChop=false, AutoSell=false, Fly=false,
            ESP=true, Speed=40, InfJump=false, Noclip=false, Loaded=false,
        },
    }
    local BSS = getgenv().Azno.BSS
    local LT2 = getgenv().Azno.LT2

    local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
    local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
    local function getRoot() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end

    -- ===== BSS logic =====
    local function loadBSS()
        if BSS.Loaded then return end
        BSS.Loaded = true

        RunService.Heartbeat:Connect(function()
            if not BSS.Loaded then return end
            local hum = getHum()
            if hum and BSS.Speed > 16 then hum.WalkSpeed = BSS.Speed end
            if BSS.Noclip then
                local c = getChar()
                if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
            end
        end)

        UserInputService.JumpRequest:Connect(function()
            if BSS.InfJump then local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end)

        local function dig()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("ClickEvent") then pcall(function() tool.ClickEvent:FireServer() end) end
        end

        RunService.Heartbeat:Connect(function() if BSS.AutoDig then dig() end end)

        task.spawn(function()
            while BSS.Loaded do
                task.wait(1.5)
                if BSS.AutoConvert then
                    pcall(function() ReplicatedStorage.Events.PlayerActivesCommand:FireServer({["Name"]="Convert Pollens"}) end)
                end
            end
        end)

        task.spawn(function()
            while BSS.Loaded do
                task.wait(0.2)
                if BSS.AutoFarm then
                    local root = getRoot()
                    if root and BSS.CollectTokens then
                        local folder = workspace:FindFirstChild("Collectibles")
                        if folder then
                            for _,v in pairs(folder:GetChildren()) do
                                local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle")
                                if part and (part.Position-root.Position).Magnitude < 40 then
                                    root.CFrame = CFrame.new(part.Position + Vector3.new(0,3,0))
                                    task.wait(0.05)
                                end
                            end
                        end
                    end
                    if root and BSS.KillBugs then
                        local monsters = workspace:FindFirstChild("Monsters")
                        if monsters then
                            for _,mob in pairs(monsters:GetChildren()) do
                                local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                                if hrp and (hrp.Position-root.Position).Magnitude < 80 then
                                    root.CFrame = CFrame.new(hrp.Position + Vector3.new(0,8,0))
                                    dig() task.wait(0.08)
                                end
                            end
                        end
                    end
                end
            end
        end)

        local drawings = {}
        RunService.RenderStepped:Connect(function()
            for _,d in pairs(drawings) do pcall(function() d:Remove() end) end
            drawings = {}
            if not BSS.ESP then return end
            if BSS.ESP_Tokens and workspace:FindFirstChild("Collectibles") then
                for _,v in pairs(workspace.Collectibles:GetChildren()) do
                    local part = v:IsA("BasePart") and v or v:FindFirstChild("Handle")
                    if part then
                        local pos,on = Camera:WorldToViewportPoint(part.Position)
                        if on then
                            local t=Drawing.new("Text") t.Text=v.Name t.Size=14 t.Center=true t.Outline=true
                            t.Color=Color3.fromRGB(255,220,50) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                            table.insert(drawings,t)
                        end
                    end
                end
            end
            if BSS.ESP_Bugs and workspace:FindFirstChild("Monsters") then
                for _,mob in pairs(workspace.Monsters:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                    if hrp then
                        local pos,on = Camera:WorldToViewportPoint(hrp.Position)
                        if on then
                            local t=Drawing.new("Text") t.Text=mob.Name t.Size=14 t.Center=true t.Outline=true
                            t.Color=Color3.fromRGB(255,80,80) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                            table.insert(drawings,t)
                        end
                    end
                end
            end
        end)
    end

    -- ===== LT2 logic =====
    local flying, flyBV, flyBG = false, nil, nil
    local function stopFly()
        flying = false
        pcall(function() RunService:UnbindFromRenderStep("AznoFly") end)
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
    end
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
            if not LT2.Fly or not root.Parent then stopFly() return end
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

    local function loadLT2()
        if LT2.Loaded then return end
        LT2.Loaded = true

        RunService.Heartbeat:Connect(function()
            if not LT2.Loaded then return end
            local hum = getHum()
            if hum and LT2.Speed > 16 then hum.WalkSpeed = LT2.Speed end
            if LT2.Noclip then
                local c = getChar()
                if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
            end
        end)

        UserInputService.JumpRequest:Connect(function()
            if LT2.InfJump then local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end)

        task.spawn(function()
            while LT2.Loaded do
                task.wait(0.15)
                if LT2.AutoChop then
                    local root = getRoot()
                    if root then
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
                        if closest then
                            local part = closest.PrimaryPart or closest:FindFirstChildWhichIsA("BasePart")
                            if part then
                                root.CFrame = CFrame.new(part.Position + Vector3.new(0,5,0))
                                pcall(function()
                                    if closest:FindFirstChild("CutEvent") then closest.CutEvent:FireServer() end
                                    if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Cut") then
                                        ReplicatedStorage.Remotes.Cut:FireServer(closest)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end)

        task.spawn(function()
            while LT2.Loaded do
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
        RunService.RenderStepped:Connect(function()
            for _,d in pairs(drawings) do pcall(function() d:Remove() end) end
            drawings = {}
            if not LT2.ESP then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:match("Tree") or obj.Name:match("Wood") then
                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local pos,on = Camera:WorldToViewportPoint(part.Position)
                        if on and pos.Z > 0 then
                            local t=Drawing.new("Text") t.Text=obj.Name t.Size=13 t.Center=true t.Outline=true
                            t.Color=Color3.fromRGB(80,255,120) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                            table.insert(drawings,t)
                        end
                    end
                end
            end
        end)
    end

    -- ===================== UI ===================== --
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "AznoCheats"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 540, 0, 360)
    Main.Position = UDim2.new(0.5, -270, 0.5, -180)
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
    SideFix.Size = UDim2.new(0, 14, 1, 0)
    SideFix.Position = UDim2.new(1, -14, 0, 0)
    SideFix.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    SideFix.BorderSizePixel = 0
    SideFix.Parent = Side

    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(1, 0, 0, 48)
    Logo.BackgroundTransparency = 1
    Logo.Text = "AZNOCHEATS"
    Logo.TextColor3 = Color3.fromRGB(225, 29, 46)
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 13
    Logo.Parent = Side

    -- Only one tab: Games
    local GamesBtn = Instance.new("TextButton")
    GamesBtn.Size = UDim2.new(1, -16, 0, 34)
    GamesBtn.Position = UDim2.new(0, 8, 0, 52)
    GamesBtn.BackgroundColor3 = Color3.fromRGB(225, 29, 46)
    GamesBtn.Text = "  Games"
    GamesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GamesBtn.Font = Enum.Font.GothamMedium
    GamesBtn.TextSize = 13
    GamesBtn.TextXAlignment = Enum.TextXAlignment.Left
    GamesBtn.BorderSizePixel = 0
    GamesBtn.Parent = Side
    Instance.new("UICorner", GamesBtn).CornerRadius = UDim.new(0, 6)

    -- Content
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -156, 1, -16)
    Content.Position = UDim2.new(0, 148, 0, 8)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(225, 29, 46)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.CanvasSize = UDim2.new(0,0,0,0)
    Content.Parent = Main
    local Lay = Instance.new("UIListLayout")
    Lay.Padding = UDim.new(0, 8)
    Lay.Parent = Content

    local function section(title)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -6, 0, 20)
        f.BackgroundTransparency = 1
        f.Parent = Content
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

    local function toggle(cfg, label, key, onChange)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 30)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        row.BorderSizePixel = 0
        row.Parent = Content
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
        sw.BackgroundColor3 = cfg[key] and Color3.fromRGB(225,29,46) or Color3.fromRGB(50,50,62)
        sw.Text = ""
        sw.BorderSizePixel = 0
        sw.Parent = row
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = cfg[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.BorderSizePixel = 0
        knob.Parent = sw
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        sw.MouseButton1Click:Connect(function()
            cfg[key] = not cfg[key]
            sw.BackgroundColor3 = cfg[key] and Color3.fromRGB(225,29,46) or Color3.fromRGB(50,50,62)
            TweenService:Create(knob, TweenInfo.new(0.12), {
                Position = cfg[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
            }):Play()
            if onChange then onChange(cfg[key]) end
        end)
    end

    local function speedRow(cfg, label)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 30)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        row.BorderSizePixel = 0
        row.Parent = Content
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label .. ": " .. cfg.Speed
        lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        local function mk(txt, dx, d)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 28, 0, 22)
            b.Position = UDim2.new(1, dx, 0.5, -11)
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
            b.Text = txt
            b.TextColor3 = Color3.fromRGB(220,220,230)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 14
            b.Parent = row
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(function()
                cfg.Speed = math.clamp(cfg.Speed + d, 16, 120)
                lbl.Text = label .. ": " .. cfg.Speed
            end)
        end
        mk("-", -64, -5)
        mk("+", -32, 5)
    end

    -- Games content
    section("BEE SWARM SIMULATOR")
    toggle(BSS, "Load BSS", "Loaded", function(v) if v then loadBSS() end end)
    toggle(BSS, "Auto Farm", "AutoFarm")
    toggle(BSS, "Auto Dig", "AutoDig")
    toggle(BSS, "Auto Convert", "AutoConvert")
    toggle(BSS, "Collect Tokens", "CollectTokens")
    toggle(BSS, "Kill Bugs", "KillBugs")
    toggle(BSS, "ESP", "ESP")
    toggle(BSS, "Token ESP", "ESP_Tokens")
    toggle(BSS, "Bug ESP", "ESP_Bugs")
    toggle(BSS, "Infinite Jump", "InfJump")
    toggle(BSS, "Noclip", "Noclip")
    speedRow(BSS, "Speed")

    section("LUMBER TYCOON 2")
    toggle(LT2, "Load LT2", "Loaded", function(v) if v then loadLT2() end end)
    toggle(LT2, "Auto Chop", "AutoChop")
    toggle(LT2, "Auto Sell", "AutoSell")
    toggle(LT2, "Fly", "Fly", function(v) if v then startFly() else stopFly() end end)
    toggle(LT2, "Tree ESP", "ESP")
    toggle(LT2, "Infinite Jump", "InfJump")
    toggle(LT2, "Noclip", "Noclip")
    speedRow(LT2, "Speed")

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            Main.Visible = not Main.Visible
        end
    end)

    print("[AznoCheats] loaded — Games tab · INSERT to toggle")
end

AuthBtn.MouseButton1Click:Connect(function()
    if checkKey(AuthBox.Text) then
        AuthStatus.TextColor3 = Color3.fromRGB(34, 197, 94)
        AuthStatus.Text = "Key accepted"
        task.wait(0.35)
        openMenu()
    else
        AuthStatus.TextColor3 = Color3.fromRGB(225, 29, 46)
        AuthStatus.Text = "Invalid key"
    end
end)
AuthBox.FocusLost:Connect(function(e) if e then AuthBtn.MouseButton1Click:Fire() end end)
