-- AznoCheats
-- Press INSERT to open the panel

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
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera

local function tween(obj, props, t, style, dir)
    local ti = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- AUTH
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
AuthBg.BackgroundTransparency = 1
AuthBg.Parent = AuthGui
Instance.new("UICorner", AuthBg).CornerRadius = UDim.new(0, 10)
local AuthStroke = Instance.new("UIStroke")
AuthStroke.Color = Color3.fromRGB(225, 29, 46)
AuthStroke.Thickness = 1
AuthStroke.Transparency = 1
AuthStroke.Parent = AuthBg
task.spawn(function()
    while AuthGui.Parent do
        tween(AuthStroke, {Transparency = 0.3}, 0.8) task.wait(0.8)
        tween(AuthStroke, {Transparency = 0.7}, 0.8) task.wait(0.8)
    end
end)
tween(AuthBg, {BackgroundTransparency = 0}, 0.35)
tween(AuthStroke, {Transparency = 0.5}, 0.4)

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 36)
AuthTitle.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
AuthTitle.Text = "  AZNOCHEATS"
AuthTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.TextSize = 13
AuthTitle.TextXAlignment = Enum.TextXAlignment.Left
AuthTitle.TextTransparency = 1
AuthTitle.Parent = AuthBg
Instance.new("UICorner", AuthTitle).CornerRadius = UDim.new(0, 10)
tween(AuthTitle, {TextTransparency = 0}, 0.4)

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
AuthBox.BackgroundTransparency = 1
AuthBox.TextTransparency = 1
AuthBox.Parent = AuthBg
Instance.new("UICorner", AuthBox).CornerRadius = UDim.new(0, 6)
task.delay(0.1, function() tween(AuthBox, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3) end)

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
AuthBtn.BackgroundTransparency = 1
AuthBtn.TextTransparency = 1
AuthBtn.Parent = AuthBg
Instance.new("UICorner", AuthBtn).CornerRadius = UDim.new(0, 6)
task.delay(0.15, function() tween(AuthBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3) end)
AuthBtn.MouseEnter:Connect(function() tween(AuthBtn, {BackgroundColor3 = Color3.fromRGB(255, 42, 61)}, 0.12) end)
AuthBtn.MouseLeave:Connect(function() tween(AuthBtn, {BackgroundColor3 = Color3.fromRGB(225, 29, 46)}, 0.12) end)

local function openMenu()
    tween(AuthBg, {BackgroundTransparency = 1}, 0.25)
    tween(AuthStroke, {Transparency = 1}, 0.25)
    task.wait(0.28)
    AuthGui:Destroy()

    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    getgenv().Azno = getgenv().Azno or {
        Fullbright=false, NoFog=false, XRay=false, Gravity=false,
        Speed=16, InfJump=false, Noclip=false, Fly=false, GodMode=false, InfStamina=false,
        Aimbot=false, SilentAim=false, FOV=120, Smooth=5, TeamCheck=true, VisibleCheck=true, Triggerbot=false,
        ESP=false, BoxESP=false, NameESP=false, DistESP=false, Tracer=false, Chams=false,
        BSS={AutoFarm=false,AutoDig=false,AutoConvert=false,CollectTokens=true,KillBugs=true,ESP=true,Loaded=false},
        LT2={AutoChop=false,AutoSell=false,Fly=false,ESP=true,Loaded=false},
    }
    local C = getgenv().Azno

    local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
    local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
    local function getRoot() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
    local oldAmbient, oldBrightness, oldFog = Lighting.Ambient, Lighting.Brightness, Lighting.FogEnd

    RunService.Heartbeat:Connect(function()
        if C.Fullbright then Lighting.Ambient=Color3.new(1,1,1) Lighting.Brightness=2 end
        if C.NoFog then Lighting.FogEnd=1e6 end
        if C.Gravity then workspace.Gravity=20 end
        local hum = getHum()
        if hum and C.Speed > 16 then hum.WalkSpeed = C.Speed end
        if C.Noclip then
            local c = getChar()
            if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end
        if C.GodMode and hum then hum.Health = hum.MaxHealth end
    end)

    UserInputService.JumpRequest:Connect(function()
        if C.InfJump then local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
    end)

    local flying, flyBV, flyBG = false, nil, nil
    local function stopFly()
        flying=false
        pcall(function() RunService:UnbindFromRenderStep("AznoFly") end)
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
    end
    local function startFly()
        local root=getRoot()
        if not root or flying then return end
        flying=true
        flyBV=Instance.new("BodyVelocity") flyBV.MaxForce=Vector3.new(9e9,9e9,9e9) flyBV.Velocity=Vector3.zero flyBV.Parent=root
        flyBG=Instance.new("BodyGyro") flyBG.MaxTorque=Vector3.new(9e9,9e9,9e9) flyBG.P=9e4 flyBG.Parent=root
        RunService:BindToRenderStep("AznoFly", Enum.RenderPriority.Camera.Value, function()
            if not C.Fly or not root.Parent then stopFly() return end
            local cam=Camera.CFrame local dir=Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
            flyBV.Velocity = dir.Magnitude>0 and dir.Unit*80 or Vector3.zero
            flyBG.CFrame=cam
        end)
    end

    local pDraws={}
    RunService.RenderStepped:Connect(function()
        for _,d in pairs(pDraws) do pcall(function() d:Remove() end) end
        pDraws={}
        if not C.ESP then return end
        for _,plr in pairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
                local hum=plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health>0 then
                    local pos,on=Camera:WorldToViewportPoint(hrp.Position)
                    if on then
                        if C.NameESP then
                            local t=Drawing.new("Text") t.Text=plr.Name t.Size=13 t.Center=true t.Outline=true
                            t.Color=Color3.fromRGB(255,80,80) t.Position=Vector2.new(pos.X,pos.Y-20) t.Visible=true
                            table.insert(pDraws,t)
                        end
                        if C.DistESP then
                            local dist=math.floor((hrp.Position-(getRoot() and getRoot().Position or hrp.Position)).Magnitude)
                            local t=Drawing.new("Text") t.Text=dist.."m" t.Size=12 t.Center=true t.Outline=true
                            t.Color=Color3.fromRGB(200,200,200) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                            table.insert(pDraws,t)
                        end
                        if C.Tracer then
                            local line=Drawing.new("Line")
                            line.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                            line.To=Vector2.new(pos.X,pos.Y)
                            line.Color=Color3.fromRGB(225,29,46) line.Thickness=1 line.Visible=true
                            table.insert(pDraws,line)
                        end
                    end
                end
            end
        end
    end)

    local function loadBSS()
        if C.BSS.Loaded then return end
        C.BSS.Loaded=true
        local function dig()
            local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("ClickEvent") then pcall(function() tool.ClickEvent:FireServer() end) end
        end
        RunService.Heartbeat:Connect(function() if C.BSS.AutoDig then dig() end end)
        task.spawn(function()
            while C.BSS.Loaded do task.wait(1.5)
                if C.BSS.AutoConvert then pcall(function() ReplicatedStorage.Events.PlayerActivesCommand:FireServer({["Name"]="Convert Pollens"}) end) end
            end
        end)
        task.spawn(function()
            while C.BSS.Loaded do task.wait(0.2)
                if C.BSS.AutoFarm then
                    local root=getRoot()
                    if root and C.BSS.CollectTokens then
                        local folder=workspace:FindFirstChild("Collectibles")
                        if folder then
                            for _,v in pairs(folder:GetChildren()) do
                                local part=v:IsA("BasePart") and v or v:FindFirstChild("Handle")
                                if part and (part.Position-root.Position).Magnitude<40 then
                                    root.CFrame=CFrame.new(part.Position+Vector3.new(0,3,0)) task.wait(0.05)
                                end
                            end
                        end
                    end
                    if root and C.BSS.KillBugs then
                        local monsters=workspace:FindFirstChild("Monsters")
                        if monsters then
                            for _,mob in pairs(monsters:GetChildren()) do
                                local hrp=mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                                if hrp and (hrp.Position-root.Position).Magnitude<80 then
                                    root.CFrame=CFrame.new(hrp.Position+Vector3.new(0,8,0)) dig() task.wait(0.08)
                                end
                            end
                        end
                    end
                end
            end
        end)
        local d={}
        RunService.RenderStepped:Connect(function()
            for _,x in pairs(d) do pcall(function() x:Remove() end) end d={}
            if not C.BSS.ESP then return end
            if workspace:FindFirstChild("Collectibles") then
                for _,v in pairs(workspace.Collectibles:GetChildren()) do
                    local part=v:IsA("BasePart") and v or v:FindFirstChild("Handle")
                    if part then
                        local pos,on=Camera:WorldToViewportPoint(part.Position)
                        if on then
                            local t=Drawing.new("Text") t.Text=v.Name t.Size=14 t.Center=true t.Outline=true
                            t.Color=Color3.fromRGB(255,220,50) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                            table.insert(d,t)
                        end
                    end
                end
            end
        end)
    end

    local function loadLT2()
        if C.LT2.Loaded then return end
        C.LT2.Loaded=true
        task.spawn(function()
            while C.LT2.Loaded do task.wait(0.15)
                if C.LT2.AutoChop then
                    local root=getRoot()
                    if root then
                        local closest,dist=nil,200
                        for _,tree in pairs(workspace:GetDescendants()) do
                            if tree.Name:match("Tree") or tree.Name:match("Wood") or tree:FindFirstChild("CutEvent") then
                                local part=tree:IsA("BasePart") and tree or tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")
                                if part then local dd=(part.Position-root.Position).Magnitude if dd<dist then closest=tree dist=dd end end
                            end
                        end
                        if closest then
                            local part=closest.PrimaryPart or closest:FindFirstChildWhichIsA("BasePart")
                            if part then
                                root.CFrame=CFrame.new(part.Position+Vector3.new(0,5,0))
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
            while C.LT2.Loaded do task.wait(3)
                if C.LT2.AutoSell then
                    pcall(function()
                        if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SellWood") then
                            ReplicatedStorage.Remotes.SellWood:FireServer()
                        end
                    end)
                end
            end
        end)
        local d={}
        RunService.RenderStepped:Connect(function()
            for _,x in pairs(d) do pcall(function() x:Remove() end) end d={}
            if not C.LT2.ESP then return end
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj.Name:match("Tree") or obj.Name:match("Wood") then
                    local part=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local pos,on=Camera:WorldToViewportPoint(part.Position)
                        if on and pos.Z>0 then
                            local t=Drawing.new("Text") t.Text=obj.Name t.Size=13 t.Center=true t.Outline=true
                            t.Color=Color3.fromRGB(80,255,120) t.Position=Vector2.new(pos.X,pos.Y) t.Visible=true
                            table.insert(d,t)
                        end
                    end
                end
            end
        end)
    end

    -- UI
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "AznoCheats"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = game:GetService("CoreGui")

    -- Toast: Press INSERT
    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(0, 280, 0, 40)
    Toast.Position = UDim2.new(0.5, -140, 0, -50)
    Toast.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Toast.BorderSizePixel = 0
    Toast.Parent = Gui
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 8)
    local ToastStroke = Instance.new("UIStroke")
    ToastStroke.Color = Color3.fromRGB(225, 29, 46)
    ToastStroke.Thickness = 1
    ToastStroke.Transparency = 0.4
    ToastStroke.Parent = Toast
    local ToastText = Instance.new("TextLabel")
    ToastText.Size = UDim2.new(1, 0, 1, 0)
    ToastText.BackgroundTransparency = 1
    ToastText.Text = "Press INSERT to open AznoCheats"
    ToastText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToastText.Font = Enum.Font.GothamBold
    ToastText.TextSize = 13
    ToastText.Parent = Toast
    tween(Toast, {Position = UDim2.new(0.5, -140, 0, 20)}, 0.4, Enum.EasingStyle.Back)
    task.delay(3.5, function()
        tween(Toast, {Position = UDim2.new(0.5, -140, 0, -50)}, 0.3)
        task.delay(0.35, function() Toast:Destroy() end)
    end)

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 560, 0, 380)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Visible = false
    Main.Parent = Gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(225, 29, 46)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.5
    Stroke.Parent = Main

    task.spawn(function()
        while Main.Parent do
            if Main.Visible then
                tween(Stroke, {Transparency = 0.3, Color = Color3.fromRGB(255, 55, 75)}, 1.1)
                task.wait(1.1)
                tween(Stroke, {Transparency = 0.6, Color = Color3.fromRGB(225, 29, 46)}, 1.1)
                task.wait(1.1)
            else
                task.wait(0.5)
            end
        end
    end)

    local Side = Instance.new("Frame")
    Side.Size = UDim2.new(0, 130, 1, 0)
    Side.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Side.BorderSizePixel = 0
    Side.Parent = Main
    Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 12)
    local SideFix = Instance.new("Frame")
    SideFix.Size = UDim2.new(0, 14, 1, 0)
    SideFix.Position = UDim2.new(1, -14, 0, 0)
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

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 64, 0, 2)
    Accent.Position = UDim2.new(0.5, 0, 0, 40)
    Accent.AnchorPoint = Vector2.new(0.5, 0)
    Accent.BackgroundColor3 = Color3.fromRGB(225, 29, 46)
    Accent.BorderSizePixel = 0
    Accent.Parent = Side
    Instance.new("UICorner", Accent).CornerRadius = UDim.new(1, 0)

    local tabs = {"World", "Character", "Aim", "Visuals", "Games"}
    local tabBtns, pages = {}, {}
    local tabIndicator = Instance.new("Frame")
    tabIndicator.Size = UDim2.new(0, 3, 0, 24)
    tabIndicator.Position = UDim2.new(0, 0, 0, 52)
    tabIndicator.BackgroundColor3 = Color3.fromRGB(225, 29, 46)
    tabIndicator.BorderSizePixel = 0
    tabIndicator.Parent = Side
    Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(1, 0)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -140, 1, -12)
    Content.Position = UDim2.new(0, 136, 0, 6)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
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
    pages["World"].Visible = true

    local function switchTab(name, idx)
        for n, p in pairs(pages) do p.Visible = (n == name) end
        for n, b in pairs(tabBtns) do
            if n == name then
                tween(b, {BackgroundColor3 = Color3.fromRGB(225,29,46), TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
            else
                tween(b, {BackgroundColor3 = Color3.fromRGB(12,12,16), TextColor3 = Color3.fromRGB(140,140,155)}, 0.15)
            end
        end
        tween(tabIndicator, {Position = UDim2.new(0, 0, 0, 52 + (idx-1)*38)}, 0.22, Enum.EasingStyle.Quint)
    end

    for i, name in ipairs(tabs) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -14, 0, 32)
        b.Position = UDim2.new(0, 7, 0, 48+(i-1)*38)
        b.BackgroundColor3 = (i==1) and Color3.fromRGB(225,29,46) or Color3.fromRGB(12,12,16)
        b.Text = "  "..name
        b.TextColor3 = (i==1) and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,155)
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.BorderSizePixel = 0
        b.Parent = Side
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseEnter:Connect(function()
            if not pages[name].Visible then tween(b, {BackgroundColor3 = Color3.fromRGB(28,28,36)}, 0.1) end
        end)
        b.MouseLeave:Connect(function()
            if not pages[name].Visible then tween(b, {BackgroundColor3 = Color3.fromRGB(12,12,16)}, 0.1) end
        end)
        b.MouseButton1Click:Connect(function() switchTab(name, i) end)
        tabBtns[name] = b
    end

    local function section(page, title)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -6, 0, 20)
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

    local function toggle(page, cfg, label, key, onChange)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 30)
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
        row.MouseEnter:Connect(function() tween(row, {BackgroundColor3 = Color3.fromRGB(30, 30, 42)}, 0.12) end)
        row.MouseLeave:Connect(function() tween(row, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}, 0.12) end)
        sw.MouseButton1Click:Connect(function()
            cfg[key] = not cfg[key]
            tween(sw, {BackgroundColor3 = cfg[key] and Color3.fromRGB(225,29,46) or Color3.fromRGB(50,50,62)}, 0.15)
            tween(knob, {Position = cfg[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}, 0.18, Enum.EasingStyle.Back)
            if onChange then onChange(cfg[key]) end
        end)
    end

    local function numRow(page, cfg, label, key, minV, maxV, step)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 30)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        row.BorderSizePixel = 0
        row.Parent = page
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label .. ": " .. tostring(cfg[key])
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
            b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = Color3.fromRGB(225,29,46)}, 0.1) end)
            b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = Color3.fromRGB(40,40,52)}, 0.1) end)
            b.MouseButton1Click:Connect(function()
                cfg[key] = math.clamp(cfg[key] + d, minV, maxV)
                lbl.Text = label .. ": " .. tostring(cfg[key])
            end)
        end
        mk("-", -64, -step)
        mk("+", -32, step)
    end

    section(pages["World"], "ENVIRONMENT")
    toggle(pages["World"], C, "Fullbright", "Fullbright", function(v) if not v then Lighting.Ambient=oldAmbient Lighting.Brightness=oldBrightness end end)
    toggle(pages["World"], C, "No Fog", "NoFog", function(v) if not v then Lighting.FogEnd=oldFog end end)
    toggle(pages["World"], C, "X-Ray (translucent)", "XRay")
    toggle(pages["World"], C, "Low Gravity", "Gravity", function(v) workspace.Gravity = v and 20 or 196.2 end)

    section(pages["Character"], "MOVEMENT")
    toggle(pages["Character"], C, "Fly", "Fly", function(v) if v then startFly() else stopFly() end end)
    toggle(pages["Character"], C, "Infinite Jump", "InfJump")
    toggle(pages["Character"], C, "Noclip", "Noclip")
    numRow(pages["Character"], C, "Speed", "Speed", 16, 150, 5)
    section(pages["Character"], "PROTECTION")
    toggle(pages["Character"], C, "God Mode", "GodMode")
    toggle(pages["Character"], C, "Inf Stamina", "InfStamina")

    section(pages["Aim"], "AIMBOT")
    toggle(pages["Aim"], C, "Aimbot", "Aimbot")
    toggle(pages["Aim"], C, "Silent Aim", "SilentAim")
    toggle(pages["Aim"], C, "Triggerbot", "Triggerbot")
    toggle(pages["Aim"], C, "Team Check", "TeamCheck")
    toggle(pages["Aim"], C, "Visible Check", "VisibleCheck")
    numRow(pages["Aim"], C, "FOV", "FOV", 20, 360, 10)
    numRow(pages["Aim"], C, "Smooth", "Smooth", 1, 20, 1)

    section(pages["Visuals"], "PLAYER ESP")
    toggle(pages["Visuals"], C, "Enable ESP", "ESP")
    toggle(pages["Visuals"], C, "Box ESP", "BoxESP")
    toggle(pages["Visuals"], C, "Name ESP", "NameESP")
    toggle(pages["Visuals"], C, "Distance ESP", "DistESP")
    toggle(pages["Visuals"], C, "Tracers", "Tracer")
    toggle(pages["Visuals"], C, "Chams", "Chams")

    section(pages["Games"], "BEE SWARM SIMULATOR")
    toggle(pages["Games"], C.BSS, "Load BSS", "Loaded", function(v) if v then loadBSS() end end)
    toggle(pages["Games"], C.BSS, "Auto Farm", "AutoFarm")
    toggle(pages["Games"], C.BSS, "Auto Dig", "AutoDig")
    toggle(pages["Games"], C.BSS, "Auto Convert", "AutoConvert")
    toggle(pages["Games"], C.BSS, "Collect Tokens", "CollectTokens")
    toggle(pages["Games"], C.BSS, "Kill Bugs", "KillBugs")
    toggle(pages["Games"], C.BSS, "BSS ESP", "ESP")

    section(pages["Games"], "LUMBER TYCOON 2")
    toggle(pages["Games"], C.LT2, "Load LT2", "Loaded", function(v) if v then loadLT2() end end)
    toggle(pages["Games"], C.LT2, "Auto Chop", "AutoChop")
    toggle(pages["Games"], C.LT2, "Auto Sell", "AutoSell")
    toggle(pages["Games"], C.LT2, "Tree ESP", "ESP")

    -- INSERT to open / close panel
    local menuOpen = false
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            menuOpen = not menuOpen
            if menuOpen then
                Main.Visible = true
                Main.Size = UDim2.new(0, 0, 0, 0)
                tween(Main, {Size = UDim2.new(0, 560, 0, 380)}, 0.32, Enum.EasingStyle.Back)
                tween(Stroke, {Transparency = 0.5}, 0.3)
            else
                tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
                tween(Stroke, {Transparency = 1}, 0.2)
                task.delay(0.22, function() Main.Visible = false end)
            end
        end
    end)

    print("[AznoCheats] unlocked — press INSERT to open the panel")
end

AuthBtn.MouseButton1Click:Connect(function()
    if checkKey(AuthBox.Text) then
        AuthStatus.TextColor3 = Color3.fromRGB(34, 197, 94)
        AuthStatus.Text = "Key accepted"
        tween(AuthStroke, {Color = Color3.fromRGB(34,197,94), Transparency = 0.2}, 0.2)
        task.wait(0.4)
        openMenu()
    else
        AuthStatus.TextColor3 = Color3.fromRGB(225, 29, 46)
        AuthStatus.Text = "Invalid key"
        local orig = AuthBg.Position
        for i=1,4 do
            AuthBg.Position = orig + UDim2.new(0, (i%2==0 and 6 or -6), 0, 0)
            task.wait(0.04)
        end
        AuthBg.Position = orig
    end
end)
AuthBox.FocusLost:Connect(function(e) if e then AuthBtn.MouseButton1Click:Fire() end end)
