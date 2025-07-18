-- UNLOOSED.CC MOBILE VERSION (FULLY PROTECTED)

-- Ожидаем загрузку игры
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Основная функция с защитой от ошибок
local function Main()
    -- Получаем сервисы
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local CoreGui = game:GetService("CoreGui")
    
    -- Ожидаем появление LocalPlayer
    local LocalPlayer = Players.LocalPlayer
    while not LocalPlayer do
        wait(1)
        LocalPlayer = Players.LocalPlayer
    end

    -- Получаем камеру
    local Camera = workspace.CurrentCamera
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        Camera = workspace.CurrentCamera
    end)

    -- Цветовая схема
    local ColorScheme = {
        Primary = Color3.fromRGB(147, 112, 219),
        Secondary = Color3.fromRGB(40, 40, 40),
        Background = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 200, 0),
        Danger = Color3.fromRGB(200, 0, 0)
    }

    -- Настройки
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
    local renderSteppedConnection = nil

    -- Создаем интерфейс
    local MobileUI = Instance.new("ScreenGui")
    MobileUI.Name = "MobileUI"
    MobileUI.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = ColorScheme.Background
    MainFrame.Parent = MobileUI

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Header
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

    -- Кнопки управления
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.TextColor3 = ColorScheme.Text
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BackgroundColor3 = ColorScheme.Danger
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Parent = HeaderFrame

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = ColorScheme.Text
    MinimizeButton.TextSize = 18
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BackgroundColor3 = ColorScheme.Secondary
    MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
    MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
    MinimizeButton.Parent = HeaderFrame

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

    -- Визуализация
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Settings.Aim.ShowFOV
    FOVCircle.Thickness = 1
    FOVCircle.Color = ColorScheme.Primary
    FOVCircle.Radius = 70
    FOVCircle.Transparency = 1
    FOVCircle.Filled = false

    local TargetIndicator = Drawing.new("Square")
    TargetIndicator.Visible = false
    TargetIndicator.Size = Vector2.new(10, 10)
    TargetIndicator.Color = ColorScheme.Primary
    TargetIndicator.Filled = true
    TargetIndicator.Thickness = 1

    -- Функции
    local function degreesToPixels(degrees)
        if not Camera then return degrees end
        local screenHeight = Camera.ViewportSize.Y
        local radians = math.rad(degrees / 2)
        local cameraFOVRad = math.rad(Camera.FieldOfView / 2)
        return math.tan(radians) * (screenHeight / (2 * math.tan(cameraFOVRad)))
    end

    local function SafeGetClosestPlayer()
        if not Camera or not LocalPlayer or not LocalPlayer.Character then return nil end
        
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
                        local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y))
                        
                        if distance.Magnitude < shortestDistance and distance.Magnitude <= FOVCircle.Radius then
                            closestPlayer = player
                            shortestDistance = distance.Magnitude
                        end
                    end
                end
            end
        end
        
        return closestPlayer
    end

    local function UpdateSpeed()
        if LocalPlayer and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Settings.Movement.Speed and Settings.Movement.SpeedValue or 16
            end
        end
    end

    local function PerformDash()
        local currentTime = tick()
        if Settings.Movement.Dash and not IsDashing and currentTime - LastDashTime >= Settings.Movement.DashCooldown then
            IsDashing = true
            LastDashTime = currentTime
            
            if LocalPlayer and LocalPlayer.Character then
                local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                
                if rootPart and humanoid then
                    local moveDirection = humanoid.MoveDirection
                    if moveDirection.Magnitude == 0 then
                        moveDirection = rootPart.CFrame.LookVector
                    end
                    
                    local startTime = tick()
                    local dashConnection
                    dashConnection = RunService.Heartbeat:Connect(function(deltaTime)
                        if tick() - startTime >= Settings.Movement.DashDuration or not LocalPlayer.Character then
                            IsDashing = false
                            if dashConnection then dashConnection:Disconnect() end
                            return
                        end
                        
                        if rootPart then
                            rootPart.CFrame = rootPart.CFrame + (moveDirection * Settings.Movement.DashSpeed * deltaTime)
                        end
                    end)
                end
            end
        end
    end

    -- Создаем элементы интерфейса
    for _, tabName in ipairs(Tabs) do
        -- Создаем кнопки табов
        local tabButton = Instance.new("TextButton")
        tabButton.Text = tabName
        tabButton.TextColor3 = ColorScheme.Text
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.BackgroundColor3 = ColorScheme.Secondary
        tabButton.Size = UDim2.new(1/#Tabs, 0, 1, 0)
        tabButton.Position = UDim2.new((table.find(Tabs, tabName)-1)/#Tabs, 0, 0, 0)
        tabButton.Parent = TabButtonsFrame
        
        -- Создаем контент табов
        local tabContent = Instance.new("Frame")
        tabContent.Name = tabName
        tabContent.Size = UDim2.new(1, 0, 0, 0)
        tabContent.AutomaticSize = Enum.AutomaticSize.Y
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = tabName == "Aim"
        tabContent.Parent = ContentScrolling
        
        -- Добавляем элементы для каждого таба
        if tabName == "Aim" then
            -- Здесь будут элементы для Aim таба
        elseif tabName == "Movement" then
            -- Здесь будут элементы для Movement таба
        elseif tabName == "Visuals" then
            -- Здесь будут элементы для Visuals таба
        elseif tabName == "Misc" then
            -- Здесь будут элементы для Misc таба
        end
    end

    -- Основной цикл
    renderSteppedConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            -- Обновляем FOV круг
            if FOVCircle then
                FOVCircle.Position = UserInputService:GetMouseLocation()
                FOVCircle.Radius = degreesToPixels(Settings.Aim.FOV)
                FOVCircle.Visible = Settings.Aim.ShowFOV
            end
            
            -- Получаем цель
            local target = SafeGetClosestPlayer()
            
            -- Обновляем индикатор цели
            if TargetIndicator then
                TargetIndicator.Visible = Settings.Aim.ShowTarget and Settings.Aim.SilentAim and target ~= nil
                if target and target.Character then
                    local head = target.Character:FindFirstChild("Head")
                    if head then
                        local screenPoint = Camera:WorldToViewportPoint(head.Position)
                        TargetIndicator.Position = Vector2.new(screenPoint.X, screenPoint.Y)
                    end
                end
            end
            
            -- Auto Shoot
            if Settings.Aim.SilentAim and Settings.Aim.AutoShoot then
                local currentTime = tick()
                if currentTime - LastShotTime >= (1 / 10) then -- 10 CPS
                    if target and math.random(1, 100) <= Settings.Aim.HitChance then
                        pcall(function()
                            mouse1press()
                            mouse1release()
                        end)
                        LastShotTime = currentTime
                    end
                end
            end
            
            -- Обновляем скорость
            if Settings.Movement.Speed then
                UpdateSpeed()
            end
        end)
    end)

    -- Обработчики событий
    CloseButton.MouseButton1Click:Connect(function()
        MobileUI:Destroy()
        if renderSteppedConnection then
            renderSteppedConnection:Disconnect()
        end
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Size = UDim2.new(0, 300, 0, 40)
        MinimizeButton.Text = "+"
        MinimizeButton.MouseButton1Click:Connect(function()
            MainFrame.Size = UDim2.new(0, 300, 0, 400)
            MinimizeButton.Text = "_"
        end)
    end)

    -- Очистка при закрытии
    game:BindToClose(function()
        if renderSteppedConnection then
            renderSteppedConnection:Disconnect()
        end
        pcall(function()
            if FOVCircle then FOVCircle:Remove() end
            if TargetIndicator then TargetIndicator:Remove() end
            MobileUI:Destroy()
        end)
    end)

    -- Уведомление о загрузке
    local notification = Instance.new("TextLabel")
    notification.Text = "UNLOOSED.CC LOADED!"
    notification.TextColor3 = Color3.fromRGB(0, 255, 0)
    notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notification.Size = UDim2.new(0, 200, 0, 30)
    notification.Position = UDim2.new(0.5, -100, 0.8, 0)
    notification.Parent = CoreGui

    game:GetService("TweenService"):Create(notification, TweenInfo.new(3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    task.delay(3, function() notification:Destroy() end)
end

-- Запускаем с защитой от ошибок
local success, err = pcall(Main)
if not success then
    warn("Script error: " .. tostring(err))
    local errorNotification = Instance.new("TextLabel")
    errorNotification.Text = "Error: " .. tostring(err)
    errorNotification.TextColor3 = Color3.fromRGB(255, 0, 0)
    errorNotification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    errorNotification.Size = UDim2.new(0, 300, 0, 50)
    errorNotification.Position = UDim2.new(0.5, -150, 0.5, -25)
    errorNotification.Parent = game:GetService("CoreGui")
    task.delay(5, function() errorNotification:Destroy() end)
end
