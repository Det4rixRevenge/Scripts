-- Мобильная версия скрипта UNLOOSED.CC

-- Настройки цветовой схемы
local ColorScheme = {
    Primary = Color3.fromRGB(147, 112, 219),
    Secondary = Color3.fromRGB(40, 40, 40),
    Background = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(255, 255, 255),
    Success = Color3.fromRGB(0, 200, 0),
    Danger = Color3.fromRGB(200, 0, 0)
}

-- Основные настройки
local Settings = {
    Aim = {
        SilentAim = false,
        AutoShoot = false,
        HitChance = 100,
        FOV = 70,
        WallCheck = false,
        ShowFOV = true,
        ShowTarget = true,
        Prediction = false,
        PredictionAmount = 0.165
    },
    Movement = {
        Speed = false,
        SpeedValue = 30,
        HighJump = false,
        JumpPower = 50,
        NoClip = false,
        Fly = false,
        Dash = false,
        DashSpeed = 50,
        DashDuration = 0.3,
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
local Tabs = {"Aim", "Movement", "Visuals", "Misc"}
local LastShotTime = 0
local LastDashTime = 0
local IsDashing = false
local FlyInstance = nil
local ESPInstance = nil
local NoclipConnection = nil
local TrailInstance = nil
local FOVConnection = nil
local SnowPart = nil
local SnowEmitter = nil
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Создание UI
local MobileUI = Instance.new("ScreenGui")
MobileUI.Name = "MobileUI"
MobileUI.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = ColorScheme.Background
MainFrame.Parent = MobileUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
HeaderFrame.BackgroundColor3 = ColorScheme.Primary
HeaderFrame.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = HeaderFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "UNLOOSED.CC MOBILE"
TitleLabel.TextColor3 = ColorScheme.Text
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.15, 0, 0, 0)
TitleLabel.Parent = HeaderFrame

-- Кнопка закрытия/свертывания
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.TextColor3 = ColorScheme.Text
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundColor3 = ColorScheme.Danger
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.Parent = HeaderFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Кнопка свернуть/развернуть
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = ColorScheme.Text
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.BackgroundColor3 = ColorScheme.Secondary
MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
MinimizeButton.Parent = HeaderFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

-- Табы
local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -80)
ContentFrame.Position = UDim2.new(0, 0, 0, 80)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ContentScrolling = Instance.new("ScrollingFrame")
ContentScrolling.Size = UDim2.new(1, 0, 1, 0)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.ScrollBarThickness = 4
ContentScrolling.Parent = ContentFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = ContentScrolling

-- Функция создания кнопки вкладки
local function CreateTabButton(name)
    local button = Instance.new("TextButton")
    button.Text = name
    button.TextColor3 = ColorScheme.Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.BackgroundColor3 = ColorScheme.Secondary
    button.Size = UDim2.new(1/#Tabs, 0, 1, 0)
    button.Position = UDim2.new((table.find(Tabs, name)-1)/#Tabs, 0, 0, 0)
    button.Parent = TabButtonsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        for _, child in ipairs(ContentScrolling:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = child.Name == name
            end
        end
    end)
    
    return button
end

-- Функция создания контента вкладки
local function CreateTabContent(name)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.Visible = name == "Aim"
    frame.Parent = ContentScrolling
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = frame
    
    return frame
end

-- Функция создания переключателя
local function CreateToggle(parent, name, tab, setting, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = ColorScheme.Secondary
    frame.BackgroundTransparency = 0.7
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = ColorScheme.Text
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
    toggle.BackgroundColor3 = ColorScheme.Background
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 20, 0, 20)
    toggleBtn.Position = Settings[tab][setting] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    toggleBtn.BackgroundColor3 = Settings[tab][setting] and ColorScheme.Success or ColorScheme.Danger
    toggleBtn.Parent = toggle
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            Settings[tab][setting] = not Settings[tab][setting]
            
            local tween = TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                Position = Settings[tab][setting] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Settings[tab][setting] and ColorScheme.Success or ColorScheme.Danger
            })
            tween:Play()
            
            if callback then
                callback(Settings[tab][setting])
            end
        end
    end)
end

-- Функция создания слайдера
local function CreateSlider(parent, name, tab, setting, min, max, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = ColorScheme.Secondary
    frame.BackgroundTransparency = 0.7
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = ColorScheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0.05, 0, 0, 5)
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(Settings[tab][setting])
    valueLabel.TextColor3 = ColorScheme.Primary
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(1, -10, 0, 20)
    valueLabel.Position = UDim2.new(0, 5, 0, 5)
    valueLabel.Parent = frame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.BackgroundColor3 = ColorScheme.Background
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 10, 0, 35)
    sliderTrack.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = ColorScheme.Primary
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
    
    UserInputService.InputChanged:Connect(function(input)
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
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- Визуализация FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.Aim.ShowFOV
FOVCircle.Thickness = 1
FOVCircle.Color = ColorScheme.Primary
FOVCircle.Radius = 70
FOVCircle.Transparency = 1
FOVCircle.Filled = false

-- Индикатор цели
local TargetIndicator = Drawing.new("Square")
TargetIndicator.Visible = false
TargetIndicator.Size = Vector2.new(10, 10)
TargetIndicator.Color = ColorScheme.Primary
TargetIndicator.Filled = true
TargetIndicator.Thickness = 1

-- Функция преобразования градусов в пиксели
local function degreesToPixels(degrees)
    local cameraFOV = Camera.FieldOfView
    local screenHeight = Camera.ViewportSize.Y
    local radians = math.rad(degrees / 2)
    local cameraFOVRad = math.rad(cameraFOV / 2)
    return math.tan(radians) * (screenHeight / (2 * math.tan(cameraFOVRad)))
end

-- Функция получения ближайшего игрока
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)
                    
                    if distance.Magnitude < shortestDistance and distance.Magnitude <= FOVCircle.Radius then
                        if Settings.Aim.WallCheck then
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                            local raycastResult = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
                            
                            if not raycastResult then
                                closestPlayer = player
                                shortestDistance = distance.Magnitude
                            end
                        else
                            closestPlayer = player
                            shortestDistance = distance.Magnitude
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Функции для переключателей
local function ToggleHighJump(value)
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = value and Settings.Movement.JumpPower or 50
        end
    end
end

local function ToggleNoClip(value)
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    if value then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function ToggleFly(value)
    if FlyInstance then
        if FlyInstance.Destroy then
            FlyInstance:Destroy()
        end
        FlyInstance = nil
    end
    
    if value then
        FlyInstance = loadstring(game:HttpGet("https://pastebin.com/raw/5HvNBUec"))()
    end
end

local function ToggleESP(value)
    if ESPInstance then
        if ESPInstance.Destroy then
            ESPInstance:Destroy()
        end
        ESPInstance = nil
    end
    
    if value then
        ESPInstance = loadstring(game:HttpGet("https://pastebin.com/raw/BCCzQZ4s"))()
    end
end

local function ToggleAmbient(value)
    if SnowPart then
        SnowPart:Destroy()
        SnowPart = nil
        SnowEmitter = nil
    end
    
    if value then
        -- Clear existing Sky, PostEffect, and Atmosphere
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Sky") or child:IsA("PostEffect") or child:IsA("Atmosphere") then
                child:Destroy()
            end
        end
        
        -- Create Sky for black background
        local sky = Instance.new("Sky")
        sky.Name = "BlackSky"
        sky.SkyboxBk = "rbxassetid://0"
        sky.SkyboxDn = "rbxassetid://0"
        sky.SkyboxFt = "rbxassetid://0"
        sky.SkyboxLf = "rbxassetid://0"
        sky.SkyboxRt = "rbxassetid://0"
        sky.SkyboxUp = "rbxassetid://0"
        sky.StarCount = 0
        sky.CelestialBodiesShown = false
        sky.MoonAngularSize = 0
        sky.SunAngularSize = 0
        sky.Parent = Lighting
        
        -- Atmosphere for black background
        local atmosphere = Instance.new("Atmosphere")
        atmosphere.Density = 0.3
        atmosphere.Offset = 0
        atmosphere.Color = Color3.fromRGB(0, 0, 0)
        atmosphere.Decay = Color3.fromRGB(0, 0, 0)
        atmosphere.Glare = 0
        atmosphere.Haze = 0
        atmosphere.Parent = Lighting
        
        -- Purple accents
        local purpleColor = Color3.fromRGB(128, 0, 255)
        Lighting.Ambient = Color3.fromRGB(50, 50, 50)
        Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
        Lighting.ColorShift_Top = purpleColor
        Lighting.ColorShift_Bottom = purpleColor
        Lighting.FogColor = purpleColor
        Lighting.FogEnd = 500
        Lighting.FogStart = 0
        
        -- Create snowfall with ParticleEmitter
        SnowEmitter = Instance.new("ParticleEmitter")
        SnowEmitter.Name = "SnowEffect"
        SnowEmitter.Texture = "rbxassetid://258123448"
        SnowEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))
        SnowEmitter.Size = NumberSequence.new(0.5, 0.2)
        SnowEmitter.Transparency = NumberSequence.new(0, 0.8)
        SnowEmitter.Lifetime = NumberRange.new(3, 6)
        SnowEmitter.Rate = 100
        SnowEmitter.Speed = NumberRange.new(4, 6)
        SnowEmitter.SpreadAngle = Vector2.new(45, 45)
        SnowEmitter.VelocitySpread = 20
        SnowEmitter.Acceleration = Vector3.new(0, -4, 0)
        SnowEmitter.EmissionDirection = Enum.NormalId.Top
        SnowEmitter.Enabled = true
        
        -- Create invisible part for snow
        SnowPart = Instance.new("Part")
        SnowPart.Name = "SnowEmitterPart"
        SnowPart.Size = Vector3.new(200, 0.1, 200)
        SnowPart.Anchored = true
        SnowPart.CanCollide = false
        SnowPart.Transparency = 1
        SnowPart.Parent = workspace
        SnowEmitter.Parent = SnowPart
        
        -- Track player position
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and SnowPart then
                local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    SnowPart.Position = rootPart.Position + Vector3.new(0, 30, 0)
                end
            else
                connection:Disconnect()
            end
        end)
    else
        Lighting:ClearAllChildren()
    end
end

local function ToggleTrails(value)
    if TrailInstance then
        TrailInstance:Destroy()
        TrailInstance = nil
    end
    
    if value and LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local trail = Instance.new("Trail")
            trail.Name = "PurpleTrail"
            trail.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
            })
            trail.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            trail.WidthScale = NumberSequence.new(1, 1)
            trail.Lifetime = 0.5
            trail.Enabled = true
            
            local attachment0 = Instance.new("Attachment")
            attachment0.Name = "TrailAttachment0"
            attachment0.Position = Vector3.new(0, 1.5, 0)
            attachment0.Parent = rootPart
            
            local attachment1 = Instance.new("Attachment")
            attachment1.Name = "TrailAttachment1"
            attachment1.Position = Vector3.new(0, -2, 0)
            attachment1.Parent = rootPart
            
            trail.Attachment0 = attachment0
            trail.Attachment1 = attachment1
            trail.Parent = rootPart
            
            TrailInstance = trail
        end
    end
end

local function ToggleCustomFOV(value)
    if FOVConnection then
        FOVConnection:Disconnect()
        FOVConnection = nil
    end
    
    if value then
        Camera.FieldOfView = Settings.Visuals.FOVValue
        FOVConnection = RunService.RenderStepped:Connect(function()
            Camera.FieldOfView = Settings.Visuals.FOVValue
        end)
    else
        Camera.FieldOfView = 70
    end
end

local function ToggleAntiAFK(value)
    if value then
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

local function ToggleAntiDeath(value)
    if value then
        loadstring(game:HttpGet("https://pastebin.com/raw/zesZdxrN"))()
    end
end

local function ToggleJumpStun(value)
    if value then
        loadstring(game:HttpGet("https://pastebin.com/raw/hACHbZ1T"))()
    end
end

-- Функция для управления скоростью
local function UpdateSpeed()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.Movement.Speed and Settings.Movement.SpeedValue or 16
        end
    end
end

-- Функция для выполнения рывка
local function PerformDash()
    local currentTime = tick()
    if Settings.Movement.Dash and not IsDashing and currentTime - LastDashTime >= Settings.Movement.DashCooldown then
        IsDashing = true
        LastDashTime = currentTime
        local Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = Character.HumanoidRootPart
            local Humanoid = Character:FindFirstChild("Humanoid")
            if Humanoid then
                local MoveDirection = Humanoid.MoveDirection
                if MoveDirection.Magnitude == 0 then
                    MoveDirection = RootPart.CFrame.LookVector
                end
                local StartTime = tick()
                local DashDistance = 0
                local MaxDistance = Settings.Movement.DashSpeed * Settings.Movement.DashDuration
                local Connection
                Connection = RunService.Heartbeat:Connect(function(deltaTime)
                    if tick() - StartTime >= Settings.Movement.DashDuration or not Character or not Humanoid or Humanoid.Health <= 0 then
                        IsDashing = false
                        Connection:Disconnect()
                        return
                    end
                    local StepDistance = Settings.Movement.DashSpeed * deltaTime
                    DashDistance = DashDistance + StepDistance
                    if DashDistance <= MaxDistance then
                        local DashVector = MoveDirection * StepDistance
                        RootPart.CFrame = RootPart.CFrame + DashVector
                    end
                end)
            end
        end
    end
end

-- Создание вкладок и элементов
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
            if Settings.Movement.HighJump and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
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

-- Закрытие интерфейса
CloseButton.MouseButton1Click:Connect(function()
    MobileUI:Destroy()
end)

-- Свертывание/развертывание интерфейса
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 300, 0, 40)
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 300, 0, 400)
        MinimizeButton.Text = "_"
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

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    -- Обновление визуализации сайлент аима
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local screenPoint = Camera:WorldToViewportPoint(head.Position)
        TargetIndicator.Position = Vector2.new(screenPoint.X, screenPoint.Y)
    end
    
    TargetIndicator.Visible = Settings.Aim.ShowTarget and Settings.Aim.SilentAim and target ~= nil
    
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
    
    -- Обновление позиции снега для Ambient эффектов
    if Settings.Visuals.Ambient and SnowPart and LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            SnowPart.Position = rootPart.Position + Vector3.new(0, 30, 0)
        end
    end
end)

-- Обработчик добавления персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
    if Settings.Movement.HighJump then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.JumpPower = Settings.Movement.JumpPower
    end
    
    if Settings.Visuals.Trails then
        local rootPart = character:WaitForChild("HumanoidRootPart")
        ToggleTrails(true)
    end
    
    if Settings.Movement.NoClip then
        ToggleNoClip(true)
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
local notification = Instance.new("TextLabel")
notification.Text = "UNLOOSED.CC MOBILE LOADED!"
notification.TextColor3 = Color3.fromRGB(0, 255, 0)
notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notification.Size = UDim2.new(0, 200, 0, 30)
notification.Position = UDim2.new(0.5, -100, 0.8, 0)
notification.Parent = game:GetService("CoreGui")

game:GetService("TweenService"):Create(notification, TweenInfo.new(3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
task.delay(3, function() notification:Destroy() end)
