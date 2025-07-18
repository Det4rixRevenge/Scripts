local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Твои игровые настройки (ссылки на основной скрипт)
local SilentAimSettings = getgenv().SilentAimSettings
local AntiAimSettings = getgenv().AntiAimSettings
local DashSettings = getgenv().DashSettings
local FlySettings = getgenv().FlySettings
local NoclipSettings = getgenv().NoclipSettings
local AntiDeathSettings = getgenv().AntiDeathSettings
local JumpStunSettings = getgenv().JumpStunSettings
local HUDSettings = getgenv().HUDSettings
local ESPSettings = getgenv().ESPSettings
local SpeedSettings = getgenv().SpeedSettings
local VisualEffectsSettings = getgenv().VisualEffectsSettings

-- Вспомогательные переменные
local LastShotTime = 0
local SnowPart = nil
local SnowEmitter = nil
local TrailInstance = nil
local FOVConnection = nil
local NoclipConnection = nil
local Clipon = false
local FlyInstance = nil
local ESPInstance = nil

-- Цветовая схема (пример)
local ColorScheme = {
    Background = Color3.fromRGB(20, 20, 20),
    Secondary = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(220, 220, 220),
    Primary = Color3.fromRGB(100, 100, 255),
    Success = Color3.fromRGB(50, 200, 50),
    Danger = Color3.fromRGB(200, 50, 50),
}

-- Таблицы настроек для UI
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
        JumpPower = 50, -- по умолчанию, можно менять
        NoClip = NoclipSettings.Enabled,
        Fly = FlySettings.Enabled,
        Dash = DashSettings.DashEnabled,
        DashSpeed = DashSettings.DashSpeed,
        DashDuration = DashSettings.DashDuration,
        DashCooldown = DashSettings.DashCooldown,
    },
    Visuals = {
        ESP = ESPSettings.Enabled,
        Tracers = false, -- нет в основном скрипте, можно добавить если есть
        Ambient = VisualEffectsSettings.AmbientEnabled,
        Trails = VisualEffectsSettings.TrailsEnabled,
        CustomFOV = VisualEffectsSettings.CustomFOVEnabled,
        FOVValue = VisualEffectsSettings.CustomFOV,
    },
    Misc = {
        AntiAFK = false, -- если есть
        AntiDeath = AntiDeathSettings.Enabled,
        JumpStun = JumpStunSettings.Enabled,
        Notifications = true,
    }
}

-- Функции включения/выключения функций из основного скрипта

local function ToggleSilentAim(state)
    SilentAimSettings.Enabled = state
    -- Визуализация
    -- mouse_box.Visible = state and Settings.Aim.ShowTarget
end

local function ToggleAutoShoot(state)
    SilentAimSettings.AutoShoot = state
end

local function ToggleWallCheck(state)
    SilentAimSettings.VisibleCheck = state
end

local function ToggleShowFOV(state)
    SilentAimSettings.FOVVisible = state
end

local function ToggleShowTarget(state)
    SilentAimSettings.ShowSilentAimTarget = state
    -- mouse_box.Visible = state and SilentAimSettings.Enabled
end

local function TogglePrediction(state)
    SilentAimSettings.MouseHitPrediction = state
end

local function UpdatePredictionAmount(value)
    SilentAimSettings.MouseHitPredictionAmount = value
end

local function UpdateHitChance(value)
    SilentAimSettings.HitChance = value
end

local function UpdateFOV(value)
    SilentAimSettings.FOVRadius = value
    -- FOVCircle.Radius = degreesToPixels(value) -- если есть
end

-- Movement

local function ToggleSpeed(state)
    SpeedSettings.Enabled = state
end

local function UpdateSpeedValue(value)
    SpeedSettings.SpeedMultiplier = value
end

local function ToggleHighJump(state)
    JumpStunSettings.Enabled = state
    if state and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = Settings.Movement.JumpPower or 50
        end
    end
end

local function UpdateJumpPower(value)
    Settings.Movement.JumpPower = value
    if JumpStunSettings.Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = value
        end
    end
end

local function ToggleNoClip(state)
    NoclipSettings.Enabled = state
    Clipon = state
    if state then
        if not NoclipConnection then
            NoclipConnection = RunService.Stepped:Connect(function()
                if Clipon and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
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
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function ToggleFly(state)
    FlySettings.Enabled = state
    if state then
        -- Подгрузить и запустить FlyV2
        local success, err = pcall(function()
            FlyInstance = loadstring(game:HttpGet("https://pastebin.com/raw/5HvNBUec"))()
        end)
        if not success then
            warn("FlyV2 failed: "..tostring(err))
            FlySettings.Enabled = false
        end
    else
        if FlyInstance and FlyInstance.Destroy then
            FlyInstance:Destroy()
            FlyInstance = nil
        end
    end
end

local function ToggleDash(state)
    DashSettings.DashEnabled = state
end

local function UpdateDashSpeed(value)
    DashSettings.DashSpeed = value
end

local function UpdateDashDuration(value)
    DashSettings.DashDuration = value
end

local function UpdateDashCooldown(value)
    DashSettings.DashCooldown = value
end

-- Visuals

local function ToggleESP(state)
    ESPSettings.Enabled = state
    if state then
        local success, err = pcall(function()
            ESPInstance = loadstring(game:HttpGet("https://pastebin.com/raw/BCCzQZ4s"))()
        end)
        if not success then
            warn("ESP load failed: "..tostring(err))
            ESPSettings.Enabled = false
        end
    else
        if ESPInstance and ESPInstance.Destroy then
            ESPInstance:Destroy()
            ESPInstance = nil
        end
    end
end

local function ToggleAmbient(state)
    VisualEffectsSettings.AmbientEnabled = state
    if state then
        -- Вызвать ambient() из основного скрипта
        local success, err = pcall(function()
            -- ambient() -- если она доступна глобально
            -- Или повторить код ambient тут
        end)
        if not success then
            warn("Ambient failed: "..tostring(err))
            VisualEffectsSettings.AmbientEnabled = false
        end
    else
        if SnowPart then
            SnowPart:Destroy()
            SnowPart = nil
            SnowEmitter = nil
        end
        -- Очистить освещение
        game:GetService("Lighting"):ClearAllChildren()
    end
end

local function ToggleTrails(state)
    VisualEffectsSettings.TrailsEnabled = state
    if state then
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- trails(rootPart) из основного скрипта
                local success, err = pcall(function()
                    TrailInstance = trails(rootPart)
                end)
                if not success then
                    warn("Trails failed: "..tostring(err))
                    VisualEffectsSettings.TrailsEnabled = false
                end
            end
        end
    else
        if TrailInstance then
            TrailInstance:Destroy()
            TrailInstance = nil
        end
    end
end

local function ToggleCustomFOV(state)
    VisualEffectsSettings.CustomFOVEnabled = state
    if state then
        if FOVConnection then FOVConnection:Disconnect() end
        FOVConnection = RunService.RenderStepped:Connect(function()
            Camera.FieldOfView = VisualEffectsSettings.CustomFOV
        end)
    else
        if FOVConnection then
            FOVConnection:Disconnect()
            FOVConnection = nil
        end
        Camera.FieldOfView = 70 -- стандартное значение
    end
end

local function UpdateCustomFOV(value)
    VisualEffectsSettings.CustomFOV = value
    if VisualEffectsSettings.CustomFOVEnabled then
        Camera.FieldOfView = value
    end
end

-- Misc

local function ToggleAntiDeath(state)
    AntiDeathSettings.Enabled = state
    if state then
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/zesZdxrN"))()
        end)
        if not success then
            warn("AntiDeath failed: "..tostring(err))
            AntiDeathSettings.Enabled = false
        end
    end
end

local function ToggleJumpStun(state)
    JumpStunSettings.Enabled = state
    if state then
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/hACHbZ1T"))()
        end)
        if not success then
            warn("JumpStun failed: "..tostring(err))
            JumpStunSettings.Enabled = false
        end
    end
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

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
HeaderFrame.BackgroundColor3 = ColorScheme.Secondary
HeaderFrame.Parent = MainFrame

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Text = "UNLOOSED.CC Mobile"
HeaderLabel.Size = UDim2.new(1, -60, 1, 0)
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
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
        -- Скрыть все вкладки
        for _, frame in pairs(TabContents) do
            frame.Visible = false
        end
        -- Показать выбранную
        TabContents[tabName].Visible = true
        CurrentTab = tabName
    end)
end

-- Функции создания элементов UI

local function CreateToggle(parent, name, tab, setting, callback)
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
        Settings[tab][setting] = not Settings[tab][setting]
        toggleBtn.BackgroundColor3 = Settings[tab][setting] and ColorScheme.Success or ColorScheme.Danger
        toggleBtn.Text = Settings[tab][setting] and "ON" or "OFF"
        if callback then
            callback(Settings[tab][setting])
        end
    end)
end

local function CreateSlider(parent, name, tab, setting, min, max, callback)
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

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            local percent = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            local value = math.floor(min + (max - min) * percent + 0.5)
            Settings[tab][setting] = value
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            if callback then callback(value) end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.Touch then
            local percent = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            local value = math.floor(min + (max - min) * percent + 0.5)
            Settings[tab][setting] = value
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            if callback then callback(value) end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- Создаем вкладки и их содержимое

for _, tabName in ipairs(Tabs) do
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 6
    content.Visible = (tabName == "Aim") -- по умолчанию показываем Aim
    content.Parent = TabContentFrame
    TabContents[tabName] = content

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = content

    -- Наполняем вкладки элементами с колбэками

    if tabName == "Aim" then
        CreateToggle(content, "Silent Aim", "Aim", "SilentAim", ToggleSilentAim)
        CreateToggle(content, "Auto Shoot", "Aim", "AutoShoot", ToggleAutoShoot)
        CreateSlider(content, "Hit Chance", "Aim", "HitChance", 0, 100, UpdateHitChance)
        CreateSlider(content, "FOV", "Aim", "FOV", 10, 500, UpdateFOV)
        CreateToggle(content, "Wall Check", "Aim", "WallCheck", ToggleWallCheck)
        CreateToggle(content, "Show FOV", "Aim", "ShowFOV", ToggleShowFOV)
        CreateToggle(content, "Show Target", "Aim", "ShowTarget", ToggleShowTarget)
        CreateToggle(content, "Prediction", "Aim", "Prediction", TogglePrediction)
        CreateSlider(content, "Prediction Amount", "Aim", "PredictionAmount", 10, 50, function(v) UpdatePredictionAmount(v/100) end)
    elseif tabName == "Movement" then
        CreateToggle(content, "Speed Hack", "Movement", "Speed", ToggleSpeed)
        CreateSlider(content, "Speed Value", "Movement", "SpeedValue", 16, 100, UpdateSpeedValue)
        CreateToggle(content, "High Jump", "Movement", "HighJump", ToggleHighJump)
        CreateSlider(content, "Jump Power", "Movement", "JumpPower", 20, 200, UpdateJumpPower)
        CreateToggle(content, "NoClip", "Movement", "NoClip", ToggleNoClip)
        CreateToggle(content, "Fly", "Movement", "Fly", ToggleFly)
        CreateToggle(content, "Dash", "Movement", "Dash", ToggleDash)
        CreateSlider(content, "Dash Speed", "Movement", "DashSpeed", 10, 100, UpdateDashSpeed)
        CreateSlider(content, "Dash Duration", "Movement", "DashDuration", 1, 10, function(v) UpdateDashDuration(v/10) end)
        CreateSlider(content, "Dash Cooldown", "Movement", "DashCooldown", 5, 50, function(v) UpdateDashCooldown(v/10) end)
    elseif tabName == "Visuals" then
        CreateToggle(content, "Player ESP", "Visuals", "ESP", ToggleESP)
        CreateToggle(content, "Tracers", "Visuals", "Tracers", function(state) 
            -- Реализация если есть
        end)
        CreateToggle(content, "Ambient Effects", "Visuals", "Ambient", ToggleAmbient)
        CreateToggle(content, "Purple Trails", "Visuals", "Trails", ToggleTrails)
        CreateToggle(content, "Custom FOV", "Visuals", "CustomFOV", ToggleCustomFOV)
        CreateSlider(content, "FOV Value", "Visuals", "FOVValue", 30, 120, UpdateCustomFOV)
    elseif tabName == "Misc" then
        CreateToggle(content, "Anti-AFK", "Misc", "AntiAFK", function(state) 
            -- Реализация если есть
        end)
        CreateToggle(content, "Anti-Death", "Misc", "AntiDeath", ToggleAntiDeath)
        CreateToggle(content, "Jump Stun", "Misc", "JumpStun", ToggleJumpStun)
        CreateToggle(content, "Notifications", "Misc", "Notifications", function(state)
            -- Реализация если есть
        end)
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
        -- Скрыть содержимое кроме заголовка
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

-- Перемещение меню (dragging)

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
        MainFrame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X, frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y)
    end
end)

-- Возвращаем UI
return MobileUI
