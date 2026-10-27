-- AznoCheats
-- Velvet-style auth · Panel opens after key

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

-- ===================== VELVET-STYLE AUTH ===================== --
local AuthGui = Instance.new("ScreenGui")
AuthGui.Name = "AznoAuth"
AuthGui.ResetOnSpawn = false
AuthGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AuthGui.Parent = game:GetService("CoreGui")

-- Full dim overlay
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel = 0
Overlay.Parent = AuthGui
tween(Overlay, {BackgroundTransparency = 0.45}, 0.35)

-- Main card
local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 420, 0, 280)
Card.Position = UDim2.new(0.5, 0, 0.5, 0)
Card.AnchorPoint = Vector2.new(0.5, 0.5)
Card.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
Card.BorderSizePixel = 0
Card.BackgroundTransparency = 1
Card.Parent = AuthGui
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 14)
local CardStroke = Instance.new("UIStroke")
CardStroke.Color = Color3.fromRGB(50, 54, 70)
CardStroke.Thickness = 1
CardStroke.Transparency = 1
CardStroke.Parent = Card
tween(Card, {BackgroundTransparency = 0}, 0.35)
tween(CardStroke, {Transparency = 0}, 0.4)

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = Card
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 16)
TopFix.Position = UDim2.new(0, 0, 1, -16)
TopFix.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Brand = Instance.new("TextLabel")
Brand.Size = UDim2.new(0, 160, 1, 0)
Brand.Position = UDim2.new(0, 16, 0, 0)
Brand.BackgroundTransparency = 1
Brand.Text = "AZNOCHEATS"
Brand.TextColor3 = Color3.fromRGB(225, 29, 46)
Brand.Font = Enum.Font.GothamBold
Brand.TextSize = 14
Brand.TextXAlignment = Enum.TextXAlignment.Left
Brand.Parent = TopBar

local HomeLbl = Instance.new("TextLabel")
HomeLbl.Size = UDim2.new(0, 80, 1, 0)
HomeLbl.Position = UDim2.new(0, 150, 0, 0)
HomeLbl.BackgroundTransparency = 1
HomeLbl.Text = "Home"
HomeLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
HomeLbl.Font = Enum.Font.GothamMedium
HomeLbl.TextSize = 13
HomeLbl.TextXAlignment = Enum.TextXAlignment.Left
HomeLbl.Parent = TopBar

local Welcome = Instance.new("TextLabel")
Welcome.Size = UDim2.new(1, -24, 0, 18)
Welcome.Position = UDim2.new(0, 16, 0, 54)
Welcome.BackgroundTransparency = 1
Welcome.Text = "Welcome back. Enter your key to continue."
Welcome.TextColor3 = Color3.fromRGB(130, 135, 155)
Welcome.Font = Enum.Font.Gotham
Welcome.TextSize = 11
Welcome.TextXAlignment = Enum.TextXAlignment.Left
Welcome.Parent = Card

-- Status cards row
local StatusRow = Instance.new("Frame")
StatusRow.Size = UDim2.new(1, -32, 0, 52)
StatusRow.Position = UDim2.new(0, 16, 0, 78)
StatusRow.BackgroundTransparency = 1
StatusRow.Parent = Card

local function statusCard(x, iconText, title, value, valueColor)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.48, 0, 1, 0)
    f.Position = UDim2.new(x, 0, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    f.BorderSizePixel = 0
    f.Parent = StatusRow
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(0, 32, 0, 32)
    icon.Position = UDim2.new(0, 10, 0.5, -16)
    icon.BackgroundColor3 = Color3.fromRGB(225, 29, 46)
    icon.BorderSizePixel = 0
    icon.Parent = f
    Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 8)
    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(1, 0, 1, 0)
    iconL.BackgroundTransparency = 1
    iconL.Text = iconText
    iconL.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconL.Font = Enum.Font.GothamBold
    iconL.TextSize = 12
    iconL.Parent = icon

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -52, 0, 14)
    t.Position = UDim2.new(0, 48, 0, 10)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Color3.fromRGB(120, 125, 145)
    t.Font = Enum.Font.Gotham
    t.TextSize = 10
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = f

    local v = Instance.new("TextLabel")
    v.Name = "Value"
    v.Size = UDim2.new(1, -52, 0, 16)
    v.Position = UDim2.new(0, 48, 0, 26)
    v.BackgroundTransparency = 1
    v.Text = value
    v.TextColor3 = valueColor
    v.Font = Enum.Font.GothamBold
    v.TextSize = 12
    v.TextXAlignment = Enum.TextXAlignment.Left
    v.Parent = f
    return f
end

local LicCard = statusCard(0, "KEY", "LICENSE", "Not validated", Color3.fromRGB(255, 100, 110))
local RobloxCard = statusCard(0.52, "R", "ROBLOX", "Found", Color3.fromRGB(80, 220, 140))

-- Activation section
local ActLabel = Instance.new("TextLabel")
ActLabel.Size = UDim2.new(1, -32, 0, 16)
ActLabel.Position = UDim2.new(0, 16, 0, 140)
ActLabel.BackgroundTransparency = 1
ActLabel.Text = "  ACTIVATION"
ActLabel.TextColor3 = Color3.fromRGB(225, 29, 46)
ActLabel.Font = Enum.Font.GothamBold
ActLabel.TextSize = 10
ActLabel.TextXAlignment = Enum.TextXAlignment.Left
ActLabel.Parent = Card

-- Steps
local Steps = Instance.new("Frame")
Steps.Size = UDim2.new(1, -32, 0, 20)
Steps.Position = UDim2.new(0, 16, 0, 158)
Steps.BackgroundTransparency = 1
Steps.Parent = Card

local function step(x, text, active)
    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(0.3, 0, 1, 0)
    s.Position = UDim2.new(x, 0, 0, 0)
    s.BackgroundTransparency = 1
    s.Text = (active and "● " or "○ ") .. text
    s.TextColor3 = active and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(100, 105, 125)
    s.Font = Enum.Font.GothamMedium
    s.TextSize = 11
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.Parent = Steps
end
step(0, "License", true)
step(0.33, "Roblox", true)
step(0.66, "Attach", false)

-- Key input
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -32, 0, 36)
KeyBox.Position = UDim2.new(0, 16, 0, 184)
KeyBox.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
KeyBox.TextColor3 = Color3.fromRGB(230, 230, 240)
KeyBox.PlaceholderText = "Paste your Auth Key..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(90, 95, 115)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 13
KeyBox.ClearTextOnFocus = false
KeyBox.Text = ""
KeyBox.Parent = Card
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)
local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(225, 29, 46)
KeyStroke.Thickness = 1
KeyStroke.Transparency = 0.5
KeyStroke.Parent = KeyBox

KeyBox.Focused:Connect(function()
    tween(KeyStroke, {Transparency = 0, Color = Color3.fromRGB(225, 29, 46)}, 0.15)
end)
KeyBox.FocusLost:Connect(function()
    tween(KeyStroke, {Transparency = 0.5}, 0.15)
end)

-- Remember checkbox (visual only)
local Remember = Instance.new("TextLabel")
Remember.Size = UDim2.new(1, -32, 0, 16)
Remember.Position = UDim2.new(0, 16, 0, 226)
Remember.BackgroundTransparency = 1
Remember.Text = "☑  Remember this key on this PC"
Remember.TextColor3 = Color3.fromRGB(140, 145, 165)
Remember.Font = Enum.Font.Gotham
Remember.TextSize = 11
Remember.TextXAlignment = Enum.TextXAlignment.Left
Remember.Parent = Card

-- Validate button
local ValBtn = Instance.new("TextButton")
ValBtn.Size = UDim2.new(1, -32, 0, 38)
ValBtn.Position = UDim2.new(0, 16, 0, 248)
ValBtn.BackgroundColor3 = Color3.fromRGB(225, 29, 46)
ValBtn.Text = "Validate key  →"
ValBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ValBtn.Font = Enum.Font.GothamBold
ValBtn.TextSize = 13
ValBtn.Parent = Card
Instance.new("UICorner", ValBtn).CornerRadius = UDim.new(0, 8)

ValBtn.MouseEnter:Connect(function()
    tween(ValBtn, {BackgroundColor3 = Color3.fromRGB(255, 45, 65)}, 0.12)
end)
ValBtn.MouseLeave:Connect(function()
    tween(ValBtn, {BackgroundColor3 = Color3.fromRGB(225, 29, 46)}, 0.12)
end)

local ErrLbl = Instance.new("TextLabel")
ErrLbl.Size = UDim2.new(1, -32, 0, 14)
ErrLbl.Position = UDim2.new(0, 16, 1, -18)
ErrLbl.BackgroundTransparency = 1
ErrLbl.Text = ""
ErrLbl.TextColor3 = Color3.fromRGB(255, 90, 100)
ErrLbl.Font = Enum.Font.Gotham
ErrLbl.TextSize = 10
ErrLbl.TextXAlignment = Enum.TextXAlignment.Left
ErrLbl.Parent = Card

-- ===================== MAIN MENU ===================== --
local function openMenu()
    -- success state on cards
    local licVal = LicCard:FindFirstChild("Value")
    if licVal then
        licVal.Text = "Validated"
        licVal.TextColor3 = Color3.fromRGB(80, 220, 140)
    end
    tween(KeyStroke, {Color = Color3.fromRGB(80, 220, 140), Transparency = 0}, 0.2)
    ValBtn.Text = "Validated ✓"
    tween(ValBtn, {BackgroundColor3 = Color3.fromRGB(40, 160, 80)}, 0.2)
    task.wait(0.55)

    tween(Card, {BackgroundTransparency = 1}, 0.25)
    tween(Overlay, {BackgroundTransparency = 1}, 0.3)
    task.wait(0.3)
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

    -- Main panel (opens immediately)
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "AznoCheats"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Parent = Gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(225, 29, 46)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 1
    Stroke.Parent = Main

    tween(Main, {Size = UDim2.new(0, 560, 0, 380)}, 0.4, Enum.EasingStyle.Back)
    tween(Stroke, {Transparency = 0.5}, 0.4)

    task.spawn(function()
        while Main.Parent do
            if Main.Visible then
                tween(Stroke, {Transparency = 0.3, Color = Color3.fromRGB(255, 55, 75)}, 1.1)
                task.wait(1.1)
                tween(Stroke, {Transparency = 0.6, Color = Color3.fromRGB(225, 29, 46)}, 1.1)
                task.wait(1.1)
            else task.wait(0.4) end
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

    local menuOpen = true
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

    print("[AznoCheats] panel open — INSERT to toggle")
end

local function tryValidate()
    if checkKey(KeyBox.Text) then
        ErrLbl.Text = ""
        openMenu()
    else
        ErrLbl.Text = "No active key / invalid license"
        tween(KeyStroke, {Color = Color3.fromRGB(255, 80, 90), Transparency = 0}, 0.1)
        local orig = Card.Position
        for i = 1, 4 do
            Card.Position = orig + UDim2.new(0, (i % 2 == 0 and 5 or -5), 0, 0)
            task.wait(0.035)
        end
        Card.Position = orig
        task.delay(0.6, function()
            tween(KeyStroke, {Color = Color3.fromRGB(225, 29, 46), Transparency = 0.5}, 0.25)
        end)
    end
end

ValBtn.MouseButton1Click:Connect(tryValidate)
KeyBox.FocusLost:Connect(function(enter) if enter then tryValidate() end end)
