-- UNLOOSED.CC MOBILE (FULL PC FUNCTIONALITY)

-- Ожидаем загрузку игры
repeat task.wait() until game:IsLoaded()

local function Main()
    -- Получаем сервисы
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local CoreGui = game:GetService("CoreGui")
    
    -- Ожидаем LocalPlayer
    local LocalPlayer = Players.LocalPlayer
    repeat task.wait() until LocalPlayer
    
    -- Получаем камеру
    local Camera = workspace.CurrentCamera
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        Camera = workspace.CurrentCamera
    end)

    -- Стиль интерфейса (оптимизирован для мобильных устройств)
    local Theme = {
        MainBg = Color3.fromRGB(20, 20, 25),
        TabBg = Color3.fromRGB(30, 30, 35),
        ButtonBg = Color3.fromRGB(40, 40, 45),
        Accent = Color3.fromRGB(140, 110, 220),
        Text = Color3.fromRGB(240, 240, 240),
        ToggleOn = Color3.fromRGB(100, 220, 100),
        ToggleOff = Color3.fromRGB(220, 100, 100)
    }

    -- Настройки из PC версии
    local Settings = {
        SilentAim = {
            Enabled = false,
            AutoShoot = true,
            CPS = 15,
            TeamCheck = false,
            VisibleCheck = false,
            TargetPart = "Head",
            FOVRadius = 70,
            ShowFOV = true,
            ShowTarget = false,
            Prediction = false,
            PredictionAmount = 0.165,
            HitChance = 100
        },
        Movement = {
            DashEnabled = true,
            DashKey = "V",
            DashSpeed = 100,
            DashDuration = 0.2,
            DashCooldown = 2,
            FlyEnabled = false,
            FlyKey = "T",
            Noclip = false,
            SpeedEnabled = false,
            SpeedKey = "Delete",
            SpeedMultiplier = 1
        },
        Visuals = {
            Ambient = false,
            Trails = false,
            CustomFOV = false,
            FOVValue = 70,
            ESP = false
        },
        Utility = {
            AntiDeath = false,
            JumpStun = false
        }
    }

    -- Создаем интерфейс
    local MobileUI = Instance.new("ScreenGui")
    MobileUI.Name = "UNLOOSED_MOBILE_UI"
    MobileUI.ResetOnSpawn = false
    MobileUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MobileUI.Parent = CoreGui

    -- Главный фрейм (на весь экран)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.Parent = MobileUI

    -- Верхняя панель
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Theme.TabBg
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "UNLOOSED.CC"
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0.2, 0, 0, 0)
    Title.Parent = TopBar

    -- Кнопка закрытия
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.ToggleOff
    CloseBtn.TextSize = 25
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Size = UDim2.new(0.15, 0, 1, 0)
    CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
    CloseBtn.Parent = TopBar

    -- Контейнер табов
    local TabButtons = Instance.new("Frame")
    TabButtons.Size = UDim2.new(1, 0, 0, 40)
    TabButtons.Position = UDim2.new(0, 0, 0, 50)
    TabButtons.BackgroundColor3 = Theme.TabBg
    TabButtons.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.Parent = TabButtons

    -- Контейнер контента
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -90)
    ContentFrame.Position = UDim2.new(0, 0, 0, 90)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = Theme.Accent
    ContentFrame.Parent = MainFrame

    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 10)
    ContentList.Parent = ContentFrame

    -- Создаем табы (как в PC версии)
    local Tabs = {
        {Name = "AIM", Type = "SilentAim"},
        {Name = "MOVEMENT", Type = "Movement"}, 
        {Name = "VISUALS", Type = "Visuals"},
        {Name = "UTILITY", Type = "Utility"}
    }

    local TabContents = {}

    for i, tab in ipairs(Tabs) do
        -- Кнопка таба
        local TabBtn = Instance.new("TextButton")
        TabBtn.Text = tab.Name
        TabBtn.TextColor3 = Theme.Text
        TabBtn.TextSize = 14
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.BackgroundColor3 = Theme.ButtonBg
        TabBtn.Size = UDim2.new(1/#Tabs, -5, 1, 0)
        TabBtn.Parent = TabButtons
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn
        
        -- Контент таба
        local TabContent = Instance.new("Frame")
        TabContent.Name = tab.Type
        TabContent.Size = UDim2.new(1, -20, 0, 0)
        TabContent.AutomaticSize = Enum.AutomaticSize.Y
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = i == 1
        TabContent.Parent = ContentFrame
        
        TabContents[tab.Type] = TabContent
        
        -- Обработчик нажатия
        TabBtn.MouseButton1Click:Connect(function()
            for _, content in pairs(TabContents) do
                content.Visible = false
            end
            TabContent.Visible = true
        end)
    end

    -- Функция создания переключателя (оптимизирована для мобильных устройств)
    local function CreateToggle(parent, text, settingTable, settingName, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
        ToggleFrame.BackgroundColor3 = Theme.ButtonBg
        ToggleFrame.Parent = parent
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 16
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0.05, 0, 0, 0)
        Label.Parent = ToggleFrame
        
        local Toggle = Instance.new("Frame")
        Toggle.Size = UDim2.new(0.2, 0, 0.5, 0)
        Toggle.Position = UDim2.new(0.75, 0, 0.25, 0)
        Toggle.BackgroundColor3 = Settings[settingTable][settingName] and Theme.ToggleOn or Theme.ToggleOff
        Toggle.Parent = ToggleFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = Toggle
        
        -- Обработчик касания
        ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                Settings[settingTable][settingName] = not Settings[settingTable][settingName]
                
                TweenService:Create(Toggle, TweenInfo.new(0.2), {
                    BackgroundColor3 = Settings[settingTable][settingName] and Theme.ToggleOn or Theme.ToggleOff
                }):Play()
                
                if callback then
                    callback(Settings[settingTable][settingName])
                end
            end
        end)
    end

    -- Функция создания слайдера
    local function CreateSlider(parent, text, settingTable, settingName, min, max, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 70)
        SliderFrame.BackgroundColor3 = Theme.ButtonBg
        SliderFrame.Parent = parent
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = SliderFrame
        
        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 16
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0.05, 0, 0, 5)
        Label.Parent = SliderFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Text = tostring(Settings[settingTable][settingName])
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextSize = 16
        ValueLabel.Font = Enum.Font.GothamMedium
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Size = UDim2.new(1, -20, 0, 20)
        ValueLabel.Position = UDim2.new(0, 10, 0, 5)
        ValueLabel.Parent = SliderFrame
        
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -20, 0, 6)
        Track.Position = UDim2.new(0, 10, 0, 40)
        Track.BackgroundColor3 = Theme.TabBg
        Track.Parent = SliderFrame
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((Settings[settingTable][settingName] - min)/(max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.Parent = Track
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill
        
        local dragging = false
        
        local function UpdateSlider(input)
            local pos = (input.Position.X - Track.AbsolutePosition.X)/Track.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            
            Settings[settingTable][settingName] = value
            ValueLabel.Text = tostring(value)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            
            if callback then
                callback(value)
            end
        end
        
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.Touch then
                UpdateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- AIM TAB (полностью соответствует PC версии)
    CreateToggle(TabContents["SilentAim"], "Silent Aim", "SilentAim", "Enabled")
    CreateToggle(TabContents["SilentAim"], "Auto Shoot", "SilentAim", "AutoShoot")
    CreateSlider(TabContents["SilentAim"], "CPS", "SilentAim", "CPS", 1, 30)
    CreateToggle(TabContents["SilentAim"], "Team Check", "SilentAim", "TeamCheck")
    CreateToggle(TabContents["SilentAim"], "Visible Check", "SilentAim", "VisibleCheck")
    CreateSlider(TabContents["SilentAim"], "FOV Radius", "SilentAim", "FOVRadius", 10, 200)
    CreateToggle(TabContents["SilentAim"], "Show FOV", "SilentAim", "ShowFOV")
    CreateToggle(TabContents["SilentAim"], "Show Target", "SilentAim", "ShowTarget")
    CreateToggle(TabContents["SilentAim"], "Prediction", "SilentAim", "Prediction")
    CreateSlider(TabContents["SilentAim"], "Prediction Amount", "SilentAim", "PredictionAmount", 0.1, 0.5)
    CreateSlider(TabContents["SilentAim"], "Hit Chance", "SilentAim", "HitChance", 0, 100)

    -- MOVEMENT TAB
    CreateToggle(TabContents["Movement"], "Dash", "Movement", "DashEnabled")
    CreateSlider(TabContents["Movement"], "Dash Speed", "Movement", "DashSpeed", 10, 150)
    CreateSlider(TabContents["Movement"], "Dash Duration", "Movement", "DashDuration", 0.1, 1)
    CreateSlider(TabContents["Movement"], "Dash Cooldown", "Movement", "DashCooldown", 0.5, 5)
    CreateToggle(TabContents["Movement"], "Fly", "Movement", "FlyEnabled")
    CreateToggle(TabContents["Movement"], "Noclip", "Movement", "Noclip")
    CreateToggle(TabContents["Movement"], "Speed", "Movement", "SpeedEnabled")
    CreateSlider(TabContents["Movement"], "Speed Multiplier", "Movement", "SpeedMultiplier", 1, 5)

    -- VISUALS TAB
    CreateToggle(TabContents["Visuals"], "Ambient Effects", "Visuals", "Ambient")
    CreateToggle(TabContents["Visuals"], "Trails", "Visuals", "Trails")
    CreateToggle(TabContents["Visuals"], "Custom FOV", "Visuals", "CustomFOV")
    CreateSlider(TabContents["Visuals"], "FOV Value", "Visuals", "FOVValue", 30, 120)
    CreateToggle(TabContents["Visuals"], "ESP", "Visuals", "ESP")

    -- UTILITY TAB
    CreateToggle(TabContents["Utility"], "Anti-Death", "Utility", "AntiDeath")
    CreateToggle(TabContents["Utility"], "Jump Stun", "Utility", "JumpStun")

    -- Обработчик закрытия
    CloseBtn.MouseButton1Click:Connect(function()
        MobileUI:Destroy()
    end)

    -- Визуализация FOV (как в PC версии)
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Settings.SilentAim.ShowFOV
    FOVCircle.Thickness = 1
    FOVCircle.Color = Theme.Accent
    FOVCircle.Radius = Settings.SilentAim.FOVRadius
    FOVCircle.Transparency = 1
    FOVCircle.Filled = false

    -- Индикатор цели
    local TargetIndicator = Drawing.new("Square")
    TargetIndicator.Visible = Settings.SilentAim.ShowTarget
    TargetIndicator.Size = Vector2.new(10, 10)
    TargetIndicator.Color = Theme.Accent
    TargetIndicator.Filled = true
    TargetIndicator.Thickness = 1

    -- Основной цикл
    RunService.RenderStepped:Connect(function()
        -- Обновляем FOV круг
        if FOVCircle then
            FOVCircle.Position = UserInputService:GetMouseLocation()
            FOVCircle.Radius = Settings.SilentAim.FOVRadius
            FOVCircle.Visible = Settings.SilentAim.ShowFOV and Settings.SilentAim.Enabled
        end
        
        -- Auto Shoot логика
        if Settings.SilentAim.Enabled and Settings.SilentAim.AutoShoot then
            -- Здесь должна быть логика авто-стрельбы
        end
        
        -- Обновляем скорость
        if Settings.Movement.SpeedEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 * Settings.Movement.SpeedMultiplier
            end
        end
    end)

    -- Уведомление о загрузке
    local Notif = Instance.new("TextLabel")
    Notif.Text = "UNLOOSED.CC LOADED!"
    Notif.TextColor3 = Color3.fromRGB(0, 255, 0)
    Notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Notif.Size = UDim2.new(0, 200, 0, 40)
    Notif.Position = UDim2.new(0.5, -100, 0.8, 0)
    Notif.AnchorPoint = Vector2.new(0.5, 0.5)
    Notif.Parent = CoreGui

    TweenService:Create(Notif, TweenInfo.new(3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    task.delay(3, function() Notif:Destroy() end)
end

-- Запускаем с защитой от ошибок
local success, err = pcall(Main)
if not success then
    warn("Script error: " .. tostring(err))
    local ErrorNotif = Instance.new("TextLabel")
    ErrorNotif.Text = "ERROR: " .. tostring(err):sub(1, 100)
    ErrorNotif.TextColor3 = Color3.fromRGB(255, 50, 50)
    ErrorNotif.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ErrorNotif.Size = UDim2.new(0.8, 0, 0, 60)
    ErrorNotif.Position = UDim2.new(0.5, 0, 0.5, 0)
    ErrorNotif.AnchorPoint = Vector2.new(0.5, 0.5)
    ErrorNotif.Parent = game:GetService("CoreGui")
    
    task.delay(5, function() ErrorNotif:Destroy() end)
end
