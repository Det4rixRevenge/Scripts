-- UNLOOSED.CC MOBILE (PREMIUM UI)

-- Ожидаем загрузку игры
repeat wait() until game:IsLoaded()

-- Основная функция
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
    repeat wait() until LocalPlayer
    
    -- Получаем камеру
    local Camera = workspace.CurrentCamera
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        Camera = workspace.CurrentCamera
    end)

    -- Стиль интерфейса
    local Theme = {
        MainColor = Color3.fromRGB(25, 25, 30),
        SecondaryColor = Color3.fromRGB(35, 35, 45),
        AccentColor = Color3.fromRGB(140, 110, 220),
        TextColor = Color3.fromRGB(240, 240, 240),
        SuccessColor = Color3.fromRGB(100, 220, 100),
        DangerColor = Color3.fromRGB(220, 100, 100)
    }

    -- Настройки
    local Settings = {
        Aim = {
            SilentAim = false,
            AutoShoot = false,
            HitChance = 100,
            FOV = 80,
            WallCheck = true,
            ShowFOV = true,
            ShowTarget = true
        },
        Movement = {
            Speed = false,
            SpeedValue = 30,
            JumpBoost = false,
            JumpPower = 50,
            Fly = false
        },
        Visuals = {
            ESP = false,
            Tracers = false,
            Chams = false
        }
    }

    -- Создаем интерфейс
    local MobileUI = Instance.new("ScreenGui")
    MobileUI.Name = "UNLOOSED_MOBILE"
    MobileUI.ResetOnSpawn = false
    MobileUI.Parent = CoreGui

    -- Главный контейнер
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.MainColor
    MainFrame.Parent = MobileUI

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.AccentColor
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame

    -- Хедер
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Theme.SecondaryColor
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Text = "UNLOOSED.CC"
    Title.TextColor3 = Theme.AccentColor
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0.2, 0, 0, 0)
    Title.Parent = Header

    -- Кнопка закрытия
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.DangerColor
    CloseBtn.TextSize = 30
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Size = UDim2.new(0.15, 0, 1, 0)
    CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
    CloseBtn.Parent = Header

    -- Кнопка сворачивания
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Theme.TextColor
    MinimizeBtn.TextSize = 30
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Size = UDim2.new(0.15, 0, 1, 0)
    MinimizeBtn.Position = UDim2.new(0.7, 0, 0, 0)
    MinimizeBtn.Parent = Header

    -- Табы
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 40)
    TabsContainer.Position = UDim2.new(0, 0, 0, 50)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Parent = MainFrame

    local TabsList = Instance.new("UIListLayout")
    TabsList.FillDirection = Enum.FillDirection.Horizontal
    TabsList.Parent = TabsContainer

    -- Контент
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -90)
    ContentFrame.Position = UDim2.new(0, 0, 0, 90)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = Theme.AccentColor
    ContentFrame.Parent = MainFrame

    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 8)
    ContentList.Parent = ContentFrame

    -- Создаем табы
    local TabNames = {"AIM", "MOVEMENT", "VISUALS"}
    local TabFrames = {}

    for i, name in ipairs(TabNames) do
        -- Кнопка таба
        local TabBtn = Instance.new("TextButton")
        TabBtn.Text = name
        TabBtn.TextColor3 = Theme.TextColor
        TabBtn.TextSize = 14
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.BackgroundColor3 = Theme.SecondaryColor
        TabBtn.Size = UDim2.new(1/#TabNames, -4, 1, 0)
        TabBtn.Parent = TabsContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabBtn
        
        -- Контент таба
        local TabContent = Instance.new("Frame")
        TabContent.Size = UDim2.new(1, 0, 0, 0)
        TabContent.AutomaticSize = Enum.AutomaticSize.Y
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = i == 1
        TabContent.Parent = ContentFrame
        
        TabFrames[name] = TabContent
        
        -- Обработчик нажатия
        TabBtn.MouseButton1Click:Connect(function()
            for _, frame in pairs(TabFrames) do
                frame.Visible = false
            end
            TabContent.Visible = true
        end)
    end

    -- Функция создания переключателя
    local function CreateToggle(parent, name, settingTable, settingName, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -20, 0, 50)
        ToggleFrame.BackgroundColor3 = Theme.SecondaryColor
        ToggleFrame.Parent = parent
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Theme.TextColor
        ToggleLabel.TextSize = 16
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.Position = UDim2.new(0.1, 0, 0, 0)
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleBtn = Instance.new("Frame")
        ToggleBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
        ToggleBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
        ToggleBtn.BackgroundColor3 = Settings[settingTable][settingName] and Theme.SuccessColor or Theme.DangerColor
        ToggleBtn.Parent = ToggleFrame
        
        local ToggleBtnCorner = Instance.new("UICorner")
        ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
        ToggleBtnCorner.Parent = ToggleBtn
        
        -- Обработчик нажатия
        ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                Settings[settingTable][settingName] = not Settings[settingTable][settingName]
                
                local tween = TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Settings[settingTable][settingName] and Theme.SuccessColor or Theme.DangerColor
                })
                tween:Play()
                
                if callback then
                    callback(Settings[settingTable][settingName])
                end
            end
        end)
    end

    -- Функция создания слайдера
    local function CreateSlider(parent, name, settingTable, settingName, min, max, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -20, 0, 70)
        SliderFrame.BackgroundColor3 = Theme.SecondaryColor
        SliderFrame.Parent = parent
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Text = name
        SliderLabel.TextColor3 = Theme.TextColor
        SliderLabel.TextSize = 16
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Size = UDim2.new(1, -20, 0, 20)
        SliderLabel.Position = UDim2.new(0.1, 0, 0, 5)
        SliderLabel.Parent = SliderFrame
        
        local SliderValue = Instance.new("TextLabel")
        SliderValue.Text = tostring(Settings[settingTable][settingName])
        SliderValue.TextColor3 = Theme.AccentColor
        SliderValue.TextSize = 16
        SliderValue.Font = Enum.Font.GothamMedium
        SliderValue.TextXAlignment = Enum.TextXAlignment.Right
        SliderValue.BackgroundTransparency = 1
        SliderValue.Size = UDim2.new(1, -20, 0, 20)
        SliderValue.Position = UDim2.new(0, 10, 0, 5)
        SliderValue.Parent = SliderFrame
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Size = UDim2.new(1, -20, 0, 6)
        SliderTrack.Position = UDim2.new(0, 10, 0, 40)
        SliderTrack.BackgroundColor3 = Theme.MainColor
        SliderTrack.Parent = SliderFrame
        
        local SliderTrackCorner = Instance.new("UICorner")
        SliderTrackCorner.CornerRadius = UDim.new(1, 0)
        SliderTrackCorner.Parent = SliderTrack
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((Settings[settingTable][settingName] - min)/(max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = Theme.AccentColor
        SliderFill.Parent = SliderTrack
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill
        
        local SliderBtn = Instance.new("Frame")
        SliderBtn.Size = UDim2.new(0, 16, 0, 16)
        SliderBtn.Position = UDim2.new((Settings[settingTable][settingName] - min)/(max - min), -8, 0.5, -8)
        SliderBtn.BackgroundColor3 = Theme.TextColor
        SliderBtn.Parent = SliderTrack
        
        local SliderBtnCorner = Instance.new("UICorner")
        SliderBtnCorner.CornerRadius = UDim.new(1, 0)
        SliderBtnCorner.Parent = SliderBtn
        
        local dragging = false
        
        local function UpdateSlider(input)
            local sliderPos = (input.Position.X - SliderTrack.AbsolutePosition.X)/SliderTrack.AbsoluteSize.X
            sliderPos = math.clamp(sliderPos, 0, 1)
            local value = math.floor(min + (max - min) * sliderPos)
            
            Settings[settingTable][settingName] = value
            SliderValue.Text = tostring(value)
            SliderFill.Size = UDim2.new(sliderPos, 0, 1, 0)
            SliderBtn.Position = UDim2.new(sliderPos, -8, 0.5, -8)
            
            if callback then
                callback(value)
            end
        end
        
        SliderBtn.InputBegan:Connect(function(input)
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

    -- AIM TAB
    CreateToggle(TabFrames["AIM"], "Silent Aim", "Aim", "SilentAim")
    CreateToggle(TabFrames["AIM"], "Auto Shoot", "Aim", "AutoShoot")
    CreateSlider(TabFrames["AIM"], "Hit Chance", "Aim", "HitChance", 0, 100)
    CreateSlider(TabFrames["AIM"], "FOV Size", "Aim", "FOV", 10, 200)
    CreateToggle(TabFrames["AIM"], "Wall Check", "Aim", "WallCheck")
    CreateToggle(TabFrames["AIM"], "Show FOV", "Aim", "ShowFOV")
    CreateToggle(TabFrames["AIM"], "Show Target", "Aim", "ShowTarget")

    -- MOVEMENT TAB
    CreateToggle(TabFrames["MOVEMENT"], "Speed Hack", "Movement", "Speed", function(value)
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value and Settings.Movement.SpeedValue or 16
            end
        end
    end)
    
    CreateSlider(TabFrames["MOVEMENT"], "Speed Value", "Movement", "SpeedValue", 16, 100, function(value)
        if Settings.Movement.Speed and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end)
    
    CreateToggle(TabFrames["MOVEMENT"], "Jump Boost", "Movement", "JumpBoost", function(value)
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = value and Settings.Movement.JumpPower or 50
            end
        end
    end)
    
    CreateSlider(TabFrames["MOVEMENT"], "Jump Power", "Movement", "JumpPower", 20, 200)
    CreateToggle(TabFrames["MOVEMENT"], "Fly", "Movement", "Fly")

    -- VISUALS TAB
    CreateToggle(TabFrames["VISUALS"], "ESP", "Visuals", "ESP")
    CreateToggle(TabFrames["VISUALS"], "Tracers", "Visuals", "Tracers")
    CreateToggle(TabFrames["VISUALS"], "Chams", "Visuals", "Chams")

    -- Обработчики кнопок
    CloseBtn.MouseButton1Click:Connect(function()
        MobileUI:Destroy()
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Size = UDim2.new(0.9, 0, 0, 50)
        MinimizeBtn.Text = "+"
        MinimizeBtn.MouseButton1Click:Connect(function()
            MainFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
            MinimizeBtn.Text = "-"
        end)
    end)

    -- Перемещение интерфейса
    local draggingUI = false
    local dragStart, startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            draggingUI = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingUI and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            draggingUI = false
        end
    end)

    -- Уведомление о загрузке
    local Notification = Instance.new("TextLabel")
    Notification.Text = "UNLOOSED.CC LOADED!"
    Notification.TextColor3 = Color3.fromRGB(0, 255, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Notification.Size = UDim2.new(0, 200, 0, 40)
    Notification.Position = UDim2.new(0.5, -100, 0.8, 0)
    Notification.AnchorPoint = Vector2.new(0.5, 0.5)
    Notification.Parent = CoreGui

    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = Notification

    TweenService:Create(Notification, TweenInfo.new(3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    task.delay(3, function() Notification:Destroy() end)
end

-- Запускаем с защитой от ошибок
local success, err = pcall(Main)
if not success then
    warn("Script error: " .. tostring(err))
    local ErrorNotif = Instance.new("TextLabel")
    ErrorNotif.Text = "ERROR: " .. tostring(err)
    ErrorNotif.TextColor3 = Color3.fromRGB(255, 50, 50)
    ErrorNotif.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ErrorNotif.Size = UDim2.new(0.8, 0, 0, 60)
    ErrorNotif.Position = UDim2.new(0.5, 0, 0.5, 0)
    ErrorNotif.AnchorPoint = Vector2.new(0.5, 0.5)
    ErrorNotif.Parent = game:GetService("CoreGui")
    
    task.delay(5, function() ErrorNotif:Destroy() end)
end
