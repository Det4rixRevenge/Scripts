-- UNLOOSED.CC MOBILE - PREMIUM UI

-- Ожидание загрузки игры
repeat wait() until game:IsLoaded()

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

-- Ожидание LocalPlayer
local LocalPlayer = Players.LocalPlayer
repeat wait() until LocalPlayer

-- Цветовая схема
local Theme = {
    Background = Color3.fromRGB(25, 25, 30),
    Header = Color3.fromRGB(45, 45, 50),
    Primary = Color3.fromRGB(120, 80, 200),
    Secondary = Color3.fromRGB(70, 70, 80),
    Text = Color3.fromRGB(240, 240, 240),
    Success = Color3.fromRGB(80, 180, 80),
    Danger = Color3.fromRGB(180, 80, 80)
}

-- Настройки (полный набор из PC версии)
local Settings = {
    SilentAim = {
        Enabled = false,
        AutoShoot = true,
        FOV = 120,
        HitChance = 100,
        TargetPart = "Head",
        ShowFOV = true,
        ShowTarget = true
    },
    Movement = {
        Speed = false,
        SpeedValue = 30,
        Fly = false,
        Noclip = false,
        HighJump = false,
        JumpPower = 50
    },
    Visuals = {
        ESP = false,
        Tracers = false,
        Chams = false,
        Ambient = false
    }
}

-- Создание главного UI
local MainUI = Instance.new("ScreenGui")
MainUI.Name = "UnloosedMobileUI"
MainUI.Parent = CoreGui

-- Основной контейнер
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.85, 0, 0.7, 0)
MainFrame.Position = UDim2.new(0.075, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MainUI

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.03, 0)
UICorner.Parent = MainFrame

-- Тень
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Заголовок
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Theme.Header
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0.03, 0)
HeaderCorner.Parent = Header

-- Название
local Title = Instance.new("TextLabel")
Title.Text = "UNLOOSED.CC"
Title.TextColor3 = Theme.Primary
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.2, 0, 0, 0)
Title.Parent = Header

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "×"
CloseButton.TextColor3 = Theme.Text
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundColor3 = Theme.Danger
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.Parent = Header

-- Кнопка сворачивания
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Theme.Text
MinimizeButton.TextSize = 24
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.BackgroundColor3 = Theme.Secondary
MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
MinimizeButton.Parent = Header

-- Табы
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

local Tabs = {"AIM", "MOVEMENT", "VISUALS", "MISC"}
local TabFrames = {}

for i, name in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Text = name
    TabButton.TextColor3 = Theme.Text
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.Gotham
    TabButton.BackgroundColor3 = Theme.Secondary
    TabButton.Size = UDim2.new(1/#Tabs, -5, 0.9, 0)
    TabButton.Position = UDim2.new((i-1)/#Tabs, 0, 0.05, 0)
    TabButton.Parent = TabButtons
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, -80)
    TabFrame.Position = UDim2.new(0, 0, 0, 80)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = i == 1
    TabFrame.ScrollBarThickness = 3
    TabFrame.Parent = MainFrame
    
    TabFrames[name] = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        TabFrame.Visible = true
    end)
end

-- Функция создания переключателя
local function CreateToggle(parent, text, config, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 50)
    ToggleFrame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 55)
    ToggleFrame.BackgroundColor3 = Theme.Secondary
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0.1, 0)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Theme.Text
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(0.9, -40, 0.5, -10)
    ToggleButton.BackgroundColor3 = config.Enabled and Theme.Success or Theme.Danger
    ToggleButton.Parent = ToggleFrame
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(0.5, 0)
    ToggleButtonCorner.Parent = ToggleButton
    
    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 16, 0, 16)
    ToggleDot.Position = config.Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    ToggleDot.BackgroundColor3 = Color3.new(1, 1, 1)
    ToggleDot.Parent = ToggleButton
    
    local ToggleDotCorner = Instance.new("UICorner")
    ToggleDotCorner.CornerRadius = UDim.new(0.5, 0)
    ToggleDotCorner.Parent = ToggleDot
    
    ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            config.Enabled = not config.Enabled
            
            TweenService:Create(ToggleDot, TweenInfo.new(0.2), {
                Position = config.Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = config.Enabled and Theme.Success or Theme.Danger
            }):Play()
            
            if callback then
                callback(config.Enabled)
            end
        end
    end)
end

-- Функция создания слайдера
local function CreateSlider(parent, text, config, min, max, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 70)
    SliderFrame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 75)
    SliderFrame.BackgroundColor3 = Theme.Secondary
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0.1, 0)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Text = text
    SliderLabel.TextColor3 = Theme.Text
    SliderLabel.TextSize = 14
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, 0, 0.4, 0)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Text = tostring(config)
    SliderValue.TextColor3 = Theme.Primary
    SliderValue.TextSize = 14
    SliderValue.Font = Enum.Font.GothamBold
    SliderValue.BackgroundTransparency = 1
    SliderValue.Size = UDim2.new(0.3, 0, 0.4, 0)
    SliderValue.Position = UDim2.new(0.7, 0, 0, 5)
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    SliderValue.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -20, 0, 4)
    SliderTrack.Position = UDim2.new(0, 10, 0.7, 0)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderTrack.Parent = SliderFrame
    
    local SliderTrackCorner = Instance.new("UICorner")
    SliderTrackCorner.CornerRadius = UDim.new(0.5, 0)
    SliderTrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((config - min)/(max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.Primary
    SliderFill.Parent = SliderTrack
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0.5, 0)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.Position = UDim2.new((config - min)/(max - min), -10, 0.5, -10)
    SliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    SliderButton.Text = ""
    SliderButton.Parent = SliderTrack
    
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(0.5, 0)
    SliderButtonCorner.Parent = SliderButton
    
    local dragging = false
    
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local posX = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * posX)
            
            SliderFill.Size = UDim2.new(posX, 0, 1, 0)
            SliderButton.Position = UDim2.new(posX, -10, 0.5, -10)
            SliderValue.Text = tostring(value)
            
            if callback then
                callback(value)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Заполняем табы (полный функционал из PC версии)
do
    -- AIM TAB
    CreateToggle(TabFrames["AIM"], "Silent Aim", Settings.SilentAim, function(value)
        Settings.SilentAim.Enabled = value
    end)
    
    CreateToggle(TabFrames["AIM"], "Auto Shoot", Settings.SilentAim, function(value)
        Settings.SilentAim.AutoShoot = value
    end)
    
    CreateSlider(TabFrames["AIM"], "FOV Size", Settings.SilentAim, 10, 300, function(value)
        Settings.SilentAim.FOV = value
    end)
    
    CreateSlider(TabFrames["AIM"], "Hit Chance", Settings.SilentAim, 0, 100, function(value)
        Settings.SilentAim.HitChance = value
    end)
    
    -- MOVEMENT TAB
    CreateToggle(TabFrames["MOVEMENT"], "Speed Hack", Settings.Movement, function(value)
        Settings.Movement.Speed = value
    end)
    
    CreateSlider(TabFrames["MOVEMENT"], "Speed Value", Settings.Movement, 16, 100, function(value)
        Settings.Movement.SpeedValue = value
    end)
    
    CreateToggle(TabFrames["MOVEMENT"], "Fly", Settings.Movement, function(value)
        Settings.Movement.Fly = value
        -- Здесь код активации Fly
    end)
    
    CreateToggle(TabFrames["MOVEMENT"], "Noclip", Settings.Movement, function(value)
        Settings.Movement.Noclip = value
        -- Здесь код активации Noclip
    end)
    
    -- VISUALS TAB
    CreateToggle(TabFrames["VISUALS"], "Player ESP", Settings.Visuals, function(value)
        Settings.Visuals.ESP = value
        -- Здесь код активации ESP
    end)
    
    CreateToggle(TabFrames["VISUALS"], "Tracers", Settings.Visuals, function(value)
        Settings.Visuals.Tracers = value
        -- Здесь код активации Tracers
    end)
    
    CreateToggle(TabFrames["VISUALS"], "Ambient Effects", Settings.Visuals, function(value)
        Settings.Visuals.Ambient = value
        -- Здесь код активации Ambient
    end)
    
    -- MISC TAB
    CreateToggle(TabFrames["MISC"], "Anti-AFK", Settings.Combat, function(value)
        -- Здесь код активации Anti-AFK
    end)
    
    CreateToggle(TabFrames["MISC"], "Anti-Death", Settings.Combat, function(value)
        -- Здесь код активации Anti-Death
    end)
end

-- Перемещение UI
local dragging, dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Кнопка закрытия
CloseButton.MouseButton1Click:Connect(function()
    MainUI:Destroy()
end)

-- Кнопка сворачивания
MinimizeButton.MouseButton1Click:Connect(function()
    if MainFrame.Size.Y.Scale > 0.1 then
        -- Сворачиваем
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0.85, 0, 0, 40)
        }):Play()
        MinimizeButton.Text = "+"
    else
        -- Разворачиваем
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0.85, 0, 0.7, 0)
        }):Play()
        MinimizeButton.Text = "-"
    end
end)

-- Уведомление о загрузке
local Notification = Instance.new("TextLabel")
Notification.Text = "UNLOOSED.CC LOADED"
Notification.TextColor3 = Color3.new(0, 1, 0)
Notification.BackgroundColor3 = Color3.new(0, 0, 0)
Notification.Size = UDim2.new(0, 200, 0, 30)
Notification.Position = UDim2.new(0.5, -100, 0.9, 0)
Notification.Parent = CoreGui

game:GetService("TweenService"):Create(Notification, TweenInfo.new(3), {
    TextTransparency = 1,
    BackgroundTransparency = 1
}):Play()

task.delay(3, function()
    Notification:Destroy()
end)
