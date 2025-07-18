--[[
    Самодостаточный UI скрипт для Roblox
    Работает с глобальными настройками из getgenv(), если они есть,
    Иначе использует дефолтные значения (чтобы не было nil ошибок).
    Можно запускать отдельно без ошибок.
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Безопасное получение глобальной таблицы с дефолтом
local function safeGetSetting(name, default)
    local val = getgenv()[name]
    if val == nil then
        return default
    else
        return val
    end
end

-- Инициализация настроек с дефолтами
local SilentAimSettings = safeGetSetting("SilentAimSettings", {
    Enabled = false,
    AutoShoot = false,
    HitChance = 100,
    FOVRadius = 150,
    VisibleCheck = true,
    FOVVisible = true,
    ShowSilentAimTarget = false,
    MouseHitPrediction = false,
    MouseHitPredictionAmount = 0.15,
})

local AntiAimSettings = safeGetSetting("AntiAimSettings", {Enabled = false})
local DashSettings = safeGetSetting("DashSettings", {
    DashEnabled = false,
    DashSpeed = 60,
    DashDuration = 0.5,
    DashCooldown = 2,
})
local FlySettings = safeGetSetting("FlySettings", {Enabled = false})
local NoclipSettings = safeGetSetting("NoclipSettings", {Enabled = false})
local AntiDeathSettings = safeGetSetting("AntiDeathSettings", {Enabled = false})
local JumpStunSettings = safeGetSetting("JumpStunSettings", {Enabled = false})
local HUDSettings = safeGetSetting("HUDSettings", {})
local ESPSettings = safeGetSetting("ESPSettings", {Enabled = false})
local SpeedSettings = safeGetSetting("SpeedSettings", {Enabled = false, SpeedMultiplier = 16})
local VisualEffectsSettings = safeGetSetting("VisualEffectsSettings", {
    AmbientEnabled = false,
    TrailsEnabled = false,
    CustomFOVEnabled = false,
    CustomFOV = 70,
})

-- Цвета интерфейса
local ColorScheme = {
    Background = Color3.fromRGB(20, 20, 20),
    Secondary = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(220, 220, 220),
    Primary = Color3.fromRGB(100, 100, 255),
    Success = Color3.fromRGB(50, 200, 50),
    Danger = Color3.fromRGB(200, 50, 50),
}

-- Локальные настройки UI (копии из глобальных, чтобы UI отражал состояние)
local Settings = {
    Aim = {
        SilentAim = SilentAimSettings.Enabled,
        AutoShoot = SilentAimSettings.AutoShoot,
        HitChance = SilentAimSettings.HitChance,
        FOV = SilentAimSettings.FOVRadius,
        WallCheck = SilentAimSettings.VisibleCheck,
        ShowFOV = SilentAimSettings.FOVVisible,
        ShowTarget = SilentAimSettings.ShowSilentAimTarget,
        Prediction = SilentAimSettings.MouseHitPrediction,
        PredictionAmount = SilentAimSettings.MouseHitPredictionAmount,
    },
    Movement = {
        Speed = SpeedSettings.Enabled,
        SpeedValue = SpeedSettings.SpeedMultiplier,
        HighJump = JumpStunSettings.Enabled,
        JumpPower = 50,
        NoClip = NoclipSettings.Enabled,
        Fly = FlySettings.Enabled,
        Dash = DashSettings.DashEnabled,
        DashSpeed = DashSettings.DashSpeed,
        DashDuration = DashSettings.DashDuration,
        DashCooldown = DashSettings.DashCooldown,
    },
    Visuals = {
        ESP = ESPSettings.Enabled,
        Ambient = VisualEffectsSettings.AmbientEnabled,
        Trails = VisualEffectsSettings.TrailsEnabled,
        CustomFOV = VisualEffectsSettings.CustomFOVEnabled,
        FOVValue = VisualEffectsSettings.CustomFOV,
    },
    Misc = {
        AntiDeath = AntiDeathSettings.Enabled,
        JumpStun = JumpStunSettings.Enabled,
    }
}

-- Функция синхронизации локальных настроек в глобальные
local function syncSettings()
    SilentAimSettings.Enabled = Settings.Aim.SilentAim
    SilentAimSettings.AutoShoot = Settings.Aim.AutoShoot
    SilentAimSettings.HitChance = Settings.Aim.HitChance
    SilentAimSettings.FOVRadius = Settings.Aim.FOV
    SilentAimSettings.VisibleCheck = Settings.Aim.WallCheck
    SilentAimSettings.FOVVisible = Settings.Aim.ShowFOV
    SilentAimSettings.ShowSilentAimTarget = Settings.Aim.ShowTarget
    SilentAimSettings.MouseHitPrediction = Settings.Aim.Prediction
    SilentAimSettings.MouseHitPredictionAmount = Settings.Aim.PredictionAmount

    SpeedSettings.Enabled = Settings.Movement.Speed
    SpeedSettings.SpeedMultiplier = Settings.Movement.SpeedValue
    JumpStunSettings.Enabled = Settings.Movement.HighJump
    NoclipSettings.Enabled = Settings.Movement.NoClip
    FlySettings.Enabled = Settings.Movement.Fly
    DashSettings.DashEnabled = Settings.Movement.Dash
    DashSettings.DashSpeed = Settings.Movement.DashSpeed
    DashSettings.DashDuration = Settings.Movement.DashDuration
    DashSettings.DashCooldown = Settings.Movement.DashCooldown

    ESPSettings.Enabled = Settings.Visuals.ESP
    VisualEffectsSettings.AmbientEnabled = Settings.Visuals.Ambient
    VisualEffectsSettings.TrailsEnabled = Settings.Visuals.Trails
    VisualEffectsSettings.CustomFOVEnabled = Settings.Visuals.CustomFOV
    VisualEffectsSettings.CustomFOV = Settings.Visuals.FOVValue

    AntiDeathSettings.Enabled = Settings.Misc.AntiDeath
    JumpStunSettings.Enabled = Settings.Misc.JumpStun
end

-- Функции переключения и обновления настроек с синхронизацией

local function updateSetting(tab, key, value)
    Settings[tab][key] = value
    syncSettings()
end

-- Создание UI

local MobileUI = Instance.new("ScreenGui")
MobileUI.Name = "MobileUI"
MobileUI.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = ColorScheme.Background
MainFrame.Parent = MobileUI
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = false -- Мы сделаем свой drag

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
HeaderFrame.BackgroundColor3 = ColorScheme.Secondary
HeaderFrame.Parent = MainFrame

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Text = "UNLOOSED.CC Mobile"
HeaderLabel.Size = UDim2.new(1, -80, 1, 0)
HeaderLabel.Position = UDim2.new(0, 10, 0, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.TextColor3 = ColorScheme.Text
HeaderLabel.Font = Enum.Font.GothamBold
HeaderLabel.TextSize = 18
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Parent = HeaderFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 40, 1, 0)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = ColorScheme.Danger
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = HeaderFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "–"
MinimizeButton.Size = UDim2.new(0, 40, 1, 0)
MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeButton.TextColor3 = Color3.new(1,1,1)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 24
MinimizeButton.Parent = HeaderFrame

local Tabs = {"Aim", "Movement", "Visuals", "Misc"}

local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
TabButtonsFrame.BackgroundColor3 = ColorScheme.Secondary
TabButtonsFrame.Parent = MainFrame

local TabContentFrame = Instance.new("Frame")
TabContentFrame.Size = UDim2.new(1, 0, 1, -80)
TabContentFrame.Position = UDim2.new(0, 0, 0, 80)
TabContentFrame.BackgroundColor3 = ColorScheme.Secondary
TabContentFrame.Parent = MainFrame

local TabContents = {}
local CurrentTab = "Aim"

-- Создаем кнопки вкладок
for i, tabName in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#Tabs, 0, 1, 0)
    btn.Position = UDim2.new((i-1)/#Tabs, 0, 0, 0)
    btn.Text = tabName
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = ColorScheme.Background
    btn.TextColor3 = ColorScheme.Text
    btn.Parent = TabButtonsFrame

    btn.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabContents) do
            frame.Visible = false
        end
        TabContents[tabName].Visible = true
        CurrentTab = tabName
    end)
end

-- Вспомогательные функции для UI элементов

local function CreateToggle(parent, name, tab, setting)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = ColorScheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 24)
    toggleBtn.Position = UDim2.new(0.85, -50, 0.5, -12)
    toggleBtn.BackgroundColor3 = Settings[tab][setting] and ColorScheme.Success or ColorScheme.Danger
    toggleBtn.Text = Settings[tab][setting] and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame

    toggleBtn.MouseButton1Click:Connect(function()
        local newValue = not Settings[tab][setting]
        updateSetting(tab, setting, newValue)
        toggleBtn.BackgroundColor3 = newValue and ColorScheme.Success or ColorScheme.Danger
        toggleBtn.Text = newValue and "ON" or "OFF"
    end)
end

local function CreateSlider(parent, name, tab, setting, min, max, step)
    step = step or 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = ColorScheme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0.05, 0, 0, 5)
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(Settings[tab][setting])
    valueLabel.TextColor3 = ColorScheme.Primary
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0.2, -10, 0, 20)
    valueLabel.Position = UDim2.new(0.75, 0, 0, 5)
    valueLabel.Parent = frame

    local sliderTrack = Instance.new("Frame")
    sliderTrack.BackgroundColor3 = ColorScheme.Secondary
    sliderTrack.Size = UDim2.new(0.9, 0, 0, 8)
    sliderTrack.Position = UDim2.new(0.05, 0, 0, 35)
    sliderTrack.Parent = frame

    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = ColorScheme.Primary
    sliderFill.Size = UDim2.new((Settings[tab][setting] - min) / (max - min), 0, 1, 0)
    sliderFill.Parent = sliderTrack

    local sliding = false

    local function updateSlider(inputPosX)
        local absPos = sliderTrack.AbsolutePosition.X
        local absSize = sliderTrack.AbsoluteSize.X
        local relativeX = inputPosX - absPos
        local percent = math.clamp(relativeX / absSize, 0, 1)
        local value = math.floor(min + (max - min) * percent + 0.5)
        -- округление по шагу
        value = math.floor(value / step + 0.5) * step
        updateSetting(tab, setting, value)
        valueLabel.Text = tostring(value)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- Создаем содержимое вкладок

for _, tabName in ipairs(Tabs) do
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 6
    content.Parent = TabContentFrame
    content.Visible = (tabName == "Aim")
    TabContents[tabName] = content

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = content

    if tabName == "Aim" then
        CreateToggle(content, "Silent Aim", "Aim", "SilentAim")
        CreateToggle(content, "Auto Shoot", "Aim", "AutoShoot")
        CreateSlider(content, "Hit Chance", "Aim", "HitChance", 0, 100, 5)
        CreateSlider(content, "FOV", "Aim", "FOV", 10, 500, 10)
        CreateToggle(content, "Wall Check", "Aim", "WallCheck")
        CreateToggle(content, "Show FOV", "Aim", "ShowFOV")
        CreateToggle(content, "Show Target", "Aim", "ShowTarget")
        CreateToggle(content, "Prediction", "Aim", "Prediction")
        CreateSlider(content, "Prediction Amount", "Aim", "PredictionAmount", 10, 50, 1)
    elseif tabName == "Movement" then
        CreateToggle(content, "Speed Hack", "Movement", "Speed")
        CreateSlider(content, "Speed Value", "Movement", "SpeedValue", 16, 100, 1)
        CreateToggle(content, "High Jump", "Movement", "HighJump")
        CreateSlider(content, "Jump Power", "Movement", "JumpPower", 20, 200, 5)
        CreateToggle(content, "NoClip", "Movement", "NoClip")
        CreateToggle(content, "Fly", "Movement", "Fly")
        CreateToggle(content, "Dash", "Movement", "Dash")
        CreateSlider(content, "Dash Speed", "Movement", "DashSpeed", 10, 100, 1)
        CreateSlider(content, "Dash Duration", "Movement", "DashDuration", 1, 10, 1)
        CreateSlider(content, "Dash Cooldown", "Movement", "DashCooldown", 5, 50, 1)
    elseif tabName == "Visuals" then
        CreateToggle(content, "Player ESP", "Visuals", "ESP")
        CreateToggle(content, "Ambient Effects", "Visuals", "Ambient")
        CreateToggle(content, "Purple Trails", "Visuals", "Trails")
        CreateToggle(content, "Custom FOV", "Visuals", "CustomFOV")
        CreateSlider(content, "FOV Value", "Visuals", "FOVValue", 30, 120, 1)
    elseif tabName == "Misc" then
        CreateToggle(content, "Anti-Death", "Misc", "AntiDeath")
        CreateToggle(content, "Jump Stun", "Misc", "JumpStun")
    end
end

-- Кнопка закрытия меню
CloseButton.MouseButton1Click:Connect(function()
    MobileUI:Destroy()
end)

-- Кнопка сворачивания меню
local menuMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    menuMinimized = not menuMinimized
    if menuMinimized then
        TabButtonsFrame.Visible = false
        TabContentFrame.Visible = false
        MinimizeButton.Text = "+"
        MainFrame.Size = UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, HeaderFrame.Size.Y.Offset + 10)
    else
        TabButtonsFrame.Visible = true
        TabContentFrame.Visible = true
        MinimizeButton.Text = "–"
        MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
    end
end)

-- Перетаскивание меню

local dragging = false
local dragStartPos = nil
local frameStartPos = nil

HeaderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStartPos = input.Position
        frameStartPos = MainFrame.Position
    end
end)

HeaderFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStartPos
        MainFrame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Возвращаем UI для дальнейшего использования, если надо
return MobileUI
