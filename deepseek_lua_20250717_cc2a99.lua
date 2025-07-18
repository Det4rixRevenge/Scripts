-- UNLOOSED.CC MOBILE - ПОЛНАЯ ВЕРСИЯ

-- Ожидание загрузки игры
repeat task.wait() until game:IsLoaded()

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CG = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- Ожидание LocalPlayer
local LP = Players.LocalPlayer
repeat task.wait() until LP

-- Проверка на мобильное устройство
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled and not UIS.MouseEnabled
if not IsMobile then return end

-- Цветовая схема
local Theme = {
    Background = Color3.fromRGB(28, 28, 36),
    Header = Color3.fromRGB(20, 20, 28),
    Primary = Color3.fromRGB(0, 170, 255),
    Secondary = Color3.fromRGB(40, 40, 50),
    Text = Color3.fromRGB(240, 240, 240),
    Success = Color3.fromRGB(0, 255, 127),
    Danger = Color3.fromRGB(255, 60, 60)
}

-- Настройки
local Settings = {
    Aim = {
        SilentAim = false,
        AutoShoot = false,
        HitChance = 100,
        FOV = 70,
        WallCheck = false,
        TargetPart = "Head",
        ShowFOV = true,
        FOVColor = Color3.fromRGB(54, 57, 241),
        Prediction = true,
        PredictionAmount = 0.165,
        ShowTarget = true
    },
    Movement = {
        Speed = false,
        SpeedValue = 24,
        HighJump = false,
        JumpPower = 50,
        NoClip = false,
        Fly = false,
        Dash = false,
        DashSpeed = 100,
        DashDuration = 0.2,
        DashCooldown = 2.0
    },
    Visuals = {
        ESP = false,
        Tracers = false,
        Ambient = false,
        Trails = false,
        CustomFOV = false,
        FOVValue = 70
    },
    Misc = {
        AntiAFK = false,
        AntiDeath = false,
        JumpStun = false,
        Notifications = true
    }
}

-- Переменные
local LastDashTime = 0
local IsDashing = false
local LastShotTime = 0
local FlyInstance = nil
local ESPInstance = nil
local NoclipConnection = nil
local TrailInstance = nil
local FOVConnection = nil
local SnowPart = nil
local Minimized = false
local OriginalJumpPower = 50

-- Визуализация
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.Aim.ShowFOV
FOVCircle.Transparency = 1
FOVCircle.Color = Settings.Aim.FOVColor
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false

local TargetIndicator = Drawing.new("Circle")
TargetIndicator.Visible = false
TargetIndicator.Transparency = 1
TargetIndicator.Color = Color3.fromRGB(255, 0, 0)
TargetIndicator.Thickness = 2
TargetIndicator.NumSides = 100
TargetIndicator.Radius = 15
TargetIndicator.Filled = false

-- Функции
local function degreesToPixels(degrees)
    return math.tan(math.rad(degrees / 2)) * (Camera.ViewportSize.Y / (2 * math.tan(math.rad(Camera.FieldOfView / 2))))
end

local function visibleCheck(target, part)
    if not Settings.Aim.WallCheck then return true end
    if not target or not target.Character or not part then return false end

    local LocalPlayerCharacter = LP.Character
    if not LocalPlayerCharacter then return false end

    local LocalPlayerRoot = LocalPlayerCharacter:FindFirstChild("HumanoidRootPart")
    if not LocalPlayerRoot then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayerCharacter, target.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true

    local raycastResult = workspace:Raycast(
        LocalPlayerRoot.Position,
        (part.Position - LocalPlayerRoot.Position).Unit * 1000,
        raycastParams
    )

    return not raycastResult or raycastResult.Instance:IsDescendantOf(target.Character)
end

local function getClosestPlayer()
    if not Settings.Aim.SilentAim then return nil end
    
    local closestTarget = nil
    local closestDistance = Settings.Aim.FOV
    local mousePos = UIS:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local targetPart = player.Character:FindFirstChild(Settings.Aim.TargetPart)
        if not targetPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        local distanceInDegrees = distance / degreesToPixels(1)
        
        if distanceInDegrees < closestDistance then
            if Settings.Aim.WallCheck and not visibleCheck(player, targetPart) then continue end
            
            closestDistance = distanceInDegrees
            closestTarget = {
                Player = player,
                Part = targetPart,
                ScreenPosition = Vector2.new(screenPos.X, screenPos.Y),
                Position = targetPart.Position
            }
        end
    end
    
    return closestTarget
end

-- Хук для Raycast
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Settings.Aim.SilentAim and not checkcaller() and method == "Raycast" and self == workspace then
        local target = getClosestPlayer()
        if target and math.random(1, 100) <= Settings.Aim.HitChance then
            local origin = args[2]
            local direction = (target.Part.Position - origin).Unit * 1000
            
            if Settings.Aim.Prediction then
                local humanoid = target.Player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    direction = (target.Part.Position + (humanoid.MoveDirection * Settings.Aim.PredictionAmount) - origin).Unit * 1000
                end
            end
            
            args[3] = direction
            return oldNamecall(self, unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Функции для функций
local function ToggleFly()
    if Settings.Movement.Fly then
        FlyInstance = loadstring(game:HttpGet("https://pastebin.com/raw/5HvNBUec"))()
    else
        if FlyInstance then
            pcall(function() FlyInstance:Destroy() end)
            FlyInstance = nil
        end
    end
end

local function ToggleESP()
    if Settings.Visuals.ESP then
        ESPInstance = loadstring(game:HttpGet("https://pastebin.com/raw/BCCzQZ4s"))()
    else
        if ESPInstance then
            pcall(function() ESPInstance:Destroy() end)
            ESPInstance = nil
        end
    end
end

local function ToggleNoClip()
    if Settings.Movement.NoClip then
        if not NoclipConnection then
            NoclipConnection = RunService.Stepped:Connect(function()
                if LP.Character then
                    for _, part in pairs(LP.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end

local function ToggleAmbient()
    if Settings.Visuals.Ambient then
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Sky") or child:IsA("Atmosphere") then
                child:Destroy()
            end
        end

        local sky = Instance.new("Sky")
        sky.SkyboxBk = "rbxassetid://0"
        sky.SkyboxDn = "rbxassetid://0"
        sky.SkyboxFt = "rbxassetid://0"
        sky.SkyboxLf = "rbxassetid://0"
        sky.SkyboxRt = "rbxassetid://0"
        sky.SkyboxUp = "rbxassetid://0"
        sky.Parent = Lighting

        Lighting.Ambient = Color3.fromRGB(50, 50, 50)
        Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
        Lighting.ColorShift_Top = Color3.fromRGB(128, 0, 255)
        
        SnowPart = Instance.new("Part")
        SnowPart.Size = Vector3.new(200, 0.1, 200)
        SnowPart.Anchored = true
        SnowPart.CanCollide = false
        SnowPart.Transparency = 1
        SnowPart.Parent = workspace

        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = "rbxassetid://258123448"
        emitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))
        emitter.Size = NumberSequence.new(0.5)
        emitter.Lifetime = NumberRange.new(3, 6)
        emitter.Rate = 100
        emitter.Speed = NumberRange.new(4, 6)
        emitter.EmissionDirection = Enum.NormalId.Top
        emitter.Parent = SnowPart
    else
        Lighting:ClearAllChildren()
        if SnowPart then
            SnowPart:Destroy()
            SnowPart = nil
        end
    end
end

local function ToggleTrails()
    if Settings.Visuals.Trails then
        if LP.Character then
            local rootPart = LP.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                TrailInstance = Instance.new("Trail")
                TrailInstance.Color = ColorSequence.new(Color3.fromRGB(128, 0, 255))
                TrailInstance.Lifetime = 0.5
                TrailInstance.Enabled = true
                
                local attachment0 = Instance.new("Attachment")
                attachment0.Position = Vector3.new(0, 1, 0)
                attachment0.Parent = rootPart
                
                local attachment1 = Instance.new("Attachment")
                attachment1.Position = Vector3.new(0, -1, 0)
                attachment1.Parent = rootPart
                
                TrailInstance.Attachment0 = attachment0
                TrailInstance.Attachment1 = attachment1
                TrailInstance.Parent = rootPart
            end
        end
    else
        if TrailInstance then
            TrailInstance:Destroy()
            TrailInstance = nil
        end
    end
end

local function ToggleCustomFOV()
    if Settings.Visuals.CustomFOV then
        Camera.FieldOfView = Settings.Visuals.FOVValue
        if FOVConnection then FOVConnection:Disconnect() end
        FOVConnection = RunService.RenderStepped:Connect(function()
            Camera.FieldOfView = Settings.Visuals.FOVValue
        end)
    else
        if FOVConnection then
            FOVConnection:Disconnect()
            FOVConnection = nil
        end
    end
end

local function ToggleHighJump()
    if LP.Character then
        local humanoid = LP.Character:FindFirstChild("Humanoid")
        if humanoid then
            if Settings.Movement.HighJump then
                OriginalJumpPower = humanoid.JumpPower
                humanoid.JumpPower = Settings.Movement.JumpPower
            else
                humanoid.JumpPower = OriginalJumpPower
            end
        end
    end
end

local function PerformDash()
    local currentTime = tick()
    if Settings.Movement.Dash and not IsDashing and currentTime - LastDashTime >= Settings.Movement.DashCooldown then
        IsDashing = true
        LastDashTime = currentTime
        
        local character = LP.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude == 0 then
            moveDirection = rootPart.CFrame.LookVector
        end
        
        local startTime = tick()
        local dashConnection
        dashConnection = RunService.Heartbeat:Connect(function(delta)
            if tick() - startTime >= Settings.Movement.DashDuration or not character or not humanoid or humanoid.Health <= 0 then
                IsDashing = false
                dashConnection:Disconnect()
                return
            end
            
            local dashStep = Settings.Movement.DashSpeed * delta
            rootPart.CFrame = rootPart.CFrame + (moveDirection * dashStep)
        end)
    end
end

local function UpdateSpeed()
    if not LP.Character then return end
    
    local humanoid = LP.Character:FindFirstChild("Humanoid")
    local rootPart = LP.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    if Settings.Movement.Speed and humanoid.MoveDirection.Magnitude > 0 then
        local direction = humanoid.MoveDirection.Unit
        local newPos = rootPart.Position + (direction * (Settings.Movement.SpeedValue / 20))
        humanoid:MoveTo(newPos)
    end
end

local function ToggleAntiAFK()
    if Settings.Misc.AntiAFK then
        local VirtualUser = game:GetService("VirtualUser")
        LP.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

local function ToggleAntiDeath()
    if Settings.Misc.AntiDeath then
        loadstring(game:HttpGet("https://pastebin.com/raw/zesZdxrN"))()
    end
end

local function ToggleJumpStun()
    if Settings.Misc.JumpStun then
        loadstring(game:HttpGet("https://pastebin.com/raw/hACHbZ1T"))()
    end
end

-- Создание интерфейса
local MobileUI = Instance.new("ScreenGui")
MobileUI.Name = "UnLoosed.cc"
MobileUI.ResetOnSpawn = false
if syn and syn.protect_gui then
    syn.protect_gui(MobileUI)
end
MobileUI.Parent = CG

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MobileUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.Primary
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Header
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 30)
HeaderFrame.BackgroundColor3 = Theme.Header
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = HeaderFrame

local Title = Instance.new("TextLabel")
Title.Text = "UNLOOSED.CC MOBILE"
Title.TextColor3 = Theme.Primary
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HeaderFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundTransparency = 1
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0.9, 0, 0, 0)
CloseButton.Parent = HeaderFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Theme.Text
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(0.85, 0, 0, 0)
MinimizeButton.Parent = HeaderFrame

-- Tabs
local Tabs = {"Aim", "Movement", "Visuals", "Misc"}
local CurrentTab = "Aim"

local TabButtons = {}
local TabContents = {}

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -10, 1, -40)
TabContainer.Position = UDim2.new(0, 5, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = TabContainer

local TabButtonsLayout = Instance.new("UIListLayout")
TabButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
TabButtonsLayout.Padding = UDim.new(0, 5)
TabButtonsLayout.Parent = TabButtonsFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = TabContainer

-- Функции интерфейса
local function CreateTabButton(name)
    local button = Instance.new("TextButton")
    button.Text = name
    button.TextColor3 = name == CurrentTab and Theme.Primary or Theme.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.BackgroundTransparency = 1
    button.Size = UDim2.new(0.2, 0, 1, 0)
    button.Parent = TabButtonsFrame
    
    button.MouseButton1Click:Connect(function()
        CurrentTab = name
        for _, tab in pairs(TabContents) do
            tab.Visible = false
        end
        TabContents[name].Visible = true
        
        for _, btn in pairs(TabButtons) do
            btn.TextColor3 = btn.Text == name and Theme.Primary or Theme.Text
        end
    end)
    
    table.insert(TabButtons, button)
end

local function CreateTabContent(name)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Theme.Primary
    scrollFrame.Visible = name == CurrentTab
    scrollFrame.Parent = ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame
    
    TabContents[name] = scrollFrame
    return scrollFrame
end

local function CreateToggle(parent, name, tab, setting, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.Secondary
    frame.BackgroundTransparency = 0.7
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 50, 0, 24)
    toggle.Position = UDim2.new(0.85, -50, 0.5, -12)
    toggle.BackgroundColor3 = Theme.Background
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 20, 0, 20)
    toggleBtn.Position = Settings[tab][setting] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    toggleBtn.BackgroundColor3 = Settings[tab][setting] and Theme.Success or Theme.Danger
    toggleBtn.Parent = toggle
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            Settings[tab][setting] = not Settings[tab][setting]
            
            local tween = TS:Create(toggleBtn, TweenInfo.new(0.2), {
                Position = Settings[tab][setting] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Settings[tab][setting] and Theme.Success or Theme.Danger
            })
            tween:Play()
            
            if callback then
                callback(Settings[tab][setting])
            end
        end
    end)
end

local function CreateSlider(parent, name, tab, setting, min, max, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Theme.Secondary
    frame.BackgroundTransparency = 0.7
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0.05, 0, 0, 5)
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(Settings[tab][setting])
    valueLabel.TextColor3 = Theme.Primary
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(1, -10, 0, 20)
    valueLabel.Position = UDim2.new(0, 5, 0, 5)
    valueLabel.Parent = frame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.BackgroundColor3 = Theme.Background
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 10, 0, 35)
    sliderTrack.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = Theme.Primary
    sliderFill.Size = UDim2.new((Settings[tab][setting] - min)/(max - min), 0, 1, 0)
    sliderFill.Parent = sliderTrack
    
    local sliderCorner2 = Instance.new("UICorner")
    sliderCorner2.CornerRadius = UDim.new(1, 0)
    sliderCorner2.Parent = sliderFill
    
    local sliding = false
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            local percent = (input.Position.X - sliderTrack.AbsolutePosition.X)/sliderTrack.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            local value = math.floor(min + (max - min)*percent)
            Settings[tab][setting] = value
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            
            if callback then
                callback(value)
            end
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.Touch then
            local percent = (input.Position.X - sliderTrack.AbsolutePosition.X)/sliderTrack.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            local value = math.floor(min + (max - min)*percent)
            Settings[tab][setting] = value
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            
            if callback then
                callback(value)
            end
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- Создание вкладок
for _, tabName in ipairs(Tabs) do
    CreateTabButton(tabName)
    local content = CreateTabContent(tabName)
    
    -- Aim Tab
    if tabName == "Aim" then
        CreateToggle(content, "Silent Aim", "Aim", "SilentAim")
        CreateToggle(content, "Auto Shoot", "Aim", "AutoShoot")
        CreateSlider(content, "Hit Chance", "Aim", "HitChance", 0, 100)
        CreateSlider(content, "FOV", "Aim", "FOV", 10, 500, function(value)
            FOVCircle.Radius = degreesToPixels(value)
        end)
        CreateToggle(content, "Wall Check", "Aim", "WallCheck")
        CreateToggle(content, "Show FOV", "Aim", "ShowFOV", function(value)
            FOVCircle.Visible = value
        end)
        CreateToggle(content, "Show Target", "Aim", "ShowTarget", function(value)
            TargetIndicator.Visible = value and Settings.Aim.SilentAim
        end)
        CreateToggle(content, "Prediction", "Aim", "Prediction")
        CreateSlider(content, "Prediction Amount", "Aim", "PredictionAmount", 0.1, 0.5)
    end
    
    -- Movement Tab
    if tabName == "Movement" then
        CreateToggle(content, "Speed Hack", "Movement", "Speed", UpdateSpeed)
        CreateSlider(content, "Speed Value", "Movement", "SpeedValue", 16, 100, UpdateSpeed)
        CreateToggle(content, "High Jump", "Movement", "HighJump", ToggleHighJump)
        CreateSlider(content, "Jump Power", "Movement", "JumpPower", 20, 200, function(value)
            if Settings.Movement.HighJump and LP.Character then
                local humanoid = LP.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpPower = value
                end
            end
        end)
        CreateToggle(content, "NoClip", "Movement", "NoClip", ToggleNoClip)
        CreateToggle(content, "Fly", "Movement", "Fly", ToggleFly)
        CreateToggle(content, "Dash", "Movement", "Dash")
        CreateSlider(content, "Dash Speed", "Movement", "DashSpeed", 10, 100)
        CreateSlider(content, "Dash Duration", "Movement", "DashDuration", 0.1, 1.0)
        CreateSlider(content, "Dash Cooldown", "Movement", "DashCooldown", 0.5, 5.0)
    end
    
    -- Visuals Tab
    if tabName == "Visuals" then
        CreateToggle(content, "Player ESP", "Visuals", "ESP", ToggleESP)
        CreateToggle(content, "Tracers", "Visuals", "Tracers")
        CreateToggle(content, "Ambient Effects", "Visuals", "Ambient", ToggleAmbient)
        CreateToggle(content, "Purple Trails", "Visuals", "Trails", ToggleTrails)
        CreateToggle(content, "Custom FOV", "Visuals", "CustomFOV", ToggleCustomFOV)
        CreateSlider(content, "FOV Value", "Visuals", "FOVValue", 30, 120, function(value)
            if Settings.Visuals.CustomFOV then
                Camera.FieldOfView = value
            end
        end)
    end
    
    -- Misc Tab
    if tabName == "Misc" then
        CreateToggle(content, "Anti-AFK", "Misc", "AntiAFK", ToggleAntiAFK)
        CreateToggle(content, "Anti-Death", "Misc", "AntiDeath", ToggleAntiDeath)
        CreateToggle(content, "Jump Stun", "Misc", "JumpStun", ToggleJumpStun)
        CreateToggle(content, "Notifications", "Misc", "Notifications")
    end
end

-- Обработчики интерфейса
CloseButton.MouseButton1Click:Connect(function()
    MobileUI:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        TS:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 350, 0, 40)}):Play()
    else
        TS:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 350, 0, 400)}):Play()
    end
end)

-- Перемещение интерфейса
local dragging = false
local dragStart, startPos

HeaderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

HeaderFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    -- Обновление визуализации
    FOVCircle.Position = UIS:GetMouseLocation()
    
    local target = getClosestPlayer()
    TargetIndicator.Visible = Settings.Aim.ShowTarget and Settings.Aim.SilentAim and target ~= nil
    
    if TargetIndicator.Visible then
        TargetIndicator.Position = target.ScreenPosition
    end
    
    -- Auto Shoot
    if Settings.Aim.SilentAim and Settings.Aim.AutoShoot then
        local currentTime = tick()
        if currentTime - LastShotTime >= (1 / 10) then -- 10 CPS
            if target and math.random(1, 100) <= Settings.Aim.HitChance then
                mouse1press()
                mouse1release()
                LastShotTime = currentTime
            end
        end
    end
    
    -- Speed
    if Settings.Movement.Speed then
        UpdateSpeed()
    end
    
    -- Dash
    if Settings.Movement.Dash then
        PerformDash()
    end
    
    -- Обновление позиции снега
    if Settings.Visuals.Ambient and SnowPart and LP.Character then
        local rootPart = LP.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            SnowPart.Position = rootPart.Position + Vector3.new(0, 30, 0)
        end
    end
end)

-- Обработчик добавления персонажа
LP.CharacterAdded:Connect(function(character)
    if Settings.Movement.HighJump then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.JumpPower = Settings.Movement.JumpPower
    end
    
    if Settings.Visuals.Trails then
        local rootPart = character:WaitForChild("HumanoidRootPart")
        ToggleTrails()
    end
    
    if Settings.Movement.NoClip then
        ToggleNoClip()
    end
    
    if Settings.Movement.Speed then
        UpdateSpeed()
    end
end)

-- Очистка при закрытии
game:BindToClose(function()
    pcall(function()
        FOVCircle:Remove()
        TargetIndicator:Remove()
        if FlyInstance then FlyInstance:Destroy() end
        if ESPInstance then ESPInstance:Destroy() end
        if NoclipConnection then NoclipConnection:Disconnect() end
        if TrailInstance then TrailInstance:Destroy() end
        if FOVConnection then FOVConnection:Disconnect() end
        Lighting:ClearAllChildren()
    end)
end)

-- Уведомление о загрузке
