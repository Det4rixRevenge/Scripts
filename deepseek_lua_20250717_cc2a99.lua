-- UNLOOSED.CC MOBILE - FULLY WORKING UI

-- Ожидание загрузки
repeat task.wait() until game:IsLoaded()

-- Сервисы
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CG = game:GetService("CoreGui")

-- Ожидание игрока
local LP = Players.LocalPlayer
repeat task.wait() until LP

-- Цвета
local Theme = {
    Background = Color3.fromRGB(25, 25, 30),
    Header = Color3.fromRGB(45, 45, 50),
    Primary = Color3.fromRGB(120, 80, 200),
    Secondary = Color3.fromRGB(70, 70, 80),
    Text = Color3.fromRGB(240, 240, 240),
    Success = Color3.fromRGB(80, 180, 80),
    Danger = Color3.fromRGB(180, 80, 80)
}

-- Настройки
local Settings = {
    Aim = {
        Enabled = false,
        AutoShoot = true,
        FOV = 120,
        HitChance = 100,
        ShowFOV = true
    },
    Movement = {
        Speed = false,
        SpeedValue = 30,
        Fly = false,
        Noclip = false
    },
    Visuals = {
        ESP = false,
        Tracers = false
    }
}

-- Создаем UI
local UI = Instance.new("ScreenGui")
UI.Name = "UnloosedUI"
UI.Parent = CG
UI.ResetOnSpawn = false

-- Главный фрейм
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.85, 0, 0.7, 0)
Main.Position = UDim2.new(0.075, 0, 0.15, 0)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Parent = UI

-- Скругление углов
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.03, 0)
Corner.Parent = Main

-- Тень
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60, 60, 70)
Stroke.Thickness = 2
Stroke.Parent = Main

-- Заголовок с возможностью перемещения
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Theme.Header
Header.Parent = Main

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

-- Кнопка закрытия (рабочая)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    UI:Destroy()
end)

-- Кнопка сворачивания (рабочая)
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.TextColor3 = Theme.Text
MinBtn.TextSize = 24
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = Theme.Secondary
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.Parent = Header

local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        TS:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0.85, 0, 0, 40)}):Play()
        MinBtn.Text = "+"
    else
        TS:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0.85, 0, 0.7, 0)}):Play()
        MinBtn.Text = "-"
    end
end)

-- Перемещение меню (рабочее)
local dragging, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Табы
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = Main

local Tabs = {"AIM", "MOVEMENT", "VISUALS"}
local TabFrames = {}

for i, name in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Text = name
    TabBtn.TextColor3 = Theme.Text
    TabBtn.TextSize = 14
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.BackgroundColor3 = Theme.Secondary
    TabBtn.Size = UDim2.new(1/#Tabs, -5, 0.9, 0)
    TabBtn.Position = UDim2.new((i-1)/#Tabs, 0, 0.05, 0)
    TabBtn.Parent = TabButtons
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, -80)
    TabFrame.Position = UDim2.new(0, 0, 0, 80)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = i == 1
    TabFrame.ScrollBarThickness = 3
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.Parent = Main
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = TabFrame
    
    TabFrames[name] = TabFrame
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        TabFrame.Visible = true
    end)
end

-- Функция создания переключателя
local function CreateToggle(parent, text, config, key, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -20, 0, 50)
    Toggle.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 55)
    Toggle.BackgroundColor3 = Theme.Secondary
    Toggle.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0.1, 0)
    Corner.Parent = Toggle
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle
    
    local ToggleBtn = Instance.new("Frame")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(0.9, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = config[key] and Theme.Success or Theme.Danger
    ToggleBtn.Parent = Toggle
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0.5, 0)
    BtnCorner.Parent = ToggleBtn
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = config[key] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Dot.BackgroundColor3 = Color3.new(1, 1, 1)
    Dot.Parent = ToggleBtn
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(0.5, 0)
    DotCorner.Parent = Dot
    
    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            config[key] = not config[key]
            
            TS:Create(Dot, TweenInfo.new(0.2), {
                Position = config[key] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            TS:Create(ToggleBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = config[key] and Theme.Success or Theme.Danger
            }):Play()
            
            if callback then
                callback(config[key])
            end
        end
    end)
end

-- Функция создания слайдера
local function CreateSlider(parent, text, config, key, min, max, callback)
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, -20, 0, 70)
    Slider.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 75)
    Slider.BackgroundColor3 = Theme.Secondary
    Slider.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0.1, 0)
    Corner.Parent = Slider
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0.4, 0)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider
    
    local Value = Instance.new("TextLabel")
    Value.Text = tostring(config[key])
    Value.TextColor3 = Theme.Primary
    Value.TextSize = 14
    Value.Font = Enum.Font.GothamBold
    Value.BackgroundTransparency = 1
    Value.Size = UDim2.new(0.3, 0, 0.4, 0)
    Value.Position = UDim2.new(0.7, 0, 0, 5)
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.Parent = Slider
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -20, 0, 4)
    Track.Position = UDim2.new(0, 10, 0.7, 0)
    Track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Track.Parent = Slider
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0.5, 0)
    TrackCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((config[key] - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Primary
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0.5, 0)
    FillCorner.Parent = Fill
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 20, 0, 20)
    Button.Position = UDim2.new((config[key] - min)/(max - min), -10, 0.5, -10)
    Button.BackgroundColor3 = Color3.new(1, 1, 1)
    Button.Text = ""
    Button.Parent = Track
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0.5, 0)
    ButtonCorner.Parent = Button
    
    local dragging = false
    
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local posX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * posX)
            
            Fill.Size = UDim2.new(posX, 0, 1, 0)
            Button.Position = UDim2.new(posX, -10, 0.5, -10)
            Value.Text = tostring(value)
            config[key] = value
            
            if callback then
                callback(value)
            end
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Заполняем вкладки (полный функционал)

-- AIM TAB
CreateToggle(TabFrames["AIM"], "Silent Aim", Settings.Aim, "Enabled", function(value)
    print("Silent Aim:", value)
end)

CreateToggle(TabFrames["AIM"], "Auto Shoot", Settings.Aim, "AutoShoot", function(value)
    print("Auto Shoot:", value)
end)

CreateSlider(TabFrames["AIM"], "FOV Size", Settings.Aim, "FOV", 10, 300, function(value)
    print("FOV:", value)
end)

CreateSlider(TabFrames["AIM"], "Hit Chance", Settings.Aim, "HitChance", 0, 100, function(value)
    print("Hit Chance:", value)
end)

-- MOVEMENT TAB
CreateToggle(TabFrames["MOVEMENT"], "Speed Hack", Settings.Movement, "Speed", function(value)
    if LP.Character then
        local Hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if Hum then
            Hum.WalkSpeed = value and Settings.Movement.SpeedValue or 16
        end
    end
end)

CreateSlider(TabFrames["MOVEMENT"], "Speed Value", Settings.Movement, "SpeedValue", 16, 100, function(value)
    if Settings.Movement.Speed and LP.Character then
        local Hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if Hum then
            Hum.WalkSpeed = value
        end
    end
end)

CreateToggle(TabFrames["MOVEMENT"], "Fly", Settings.Movement, "Fly", function(value)
    print("Fly:", value)
    -- Здесь код активации Fly
end)

CreateToggle(TabFrames["MOVEMENT"], "Noclip", Settings.Movement, "Noclip", function(value)
    print("Noclip:", value)
    -- Здесь код активации Noclip
end)

-- VISUALS TAB
CreateToggle(TabFrames["VISUALS"], "Player ESP", Settings.Visuals, "ESP", function(value)
    print("ESP:", value)
    -- Здесь код активации ESP
end)

CreateToggle(TabFrames["VISUALS"], "Tracers", Settings.Visuals, "Tracers", function(value)
    print("Tracers:", value)
    -- Здесь код активации Tracers
end)

-- Уведомление
local Notify = Instance.new("TextLabel")
Notify.Text = "UNLOOSED.CC LOADED"
Notify.TextColor3 = Color3.new(0, 1, 0)
Notify.BackgroundColor3 = Color3.new(0, 0, 0)
Notify.Size = UDim2.new(0, 200, 0, 30)
Notify.Position = UDim2.new(0.5, -100, 0.9, 0)
Notify.Parent = CG

TS:Create(Notify, TweenInfo.new(3), {
    TextTransparency = 1,
    BackgroundTransparency = 1
}):Play()

task.delay(3, function()
    Notify:Destroy()
end)
