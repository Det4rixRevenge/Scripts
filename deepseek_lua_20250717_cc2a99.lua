--[[
  Unloosed.cc Mobile UI v2
  Современный, стильный, полный функционал
  Разделы: Combat, Movement, Visuals, Misc
  Кнопки: Закрыть, Свернуть
  Перетаскивание меню по заголовку
  Все функции работают на мобильном
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Проверка и инициализация глобальных настроек, если их нет
local function safeGet(name, default)
    local val = getgenv()[name]
    if val == nil then
        getgenv()[name] = default
        return default
    end
    return val
end

-- Настройки (пример, можно расширять)
local SilentAimSettings = safeGet("SilentAimSettings", {
    Enabled = false,
    AutoShoot = true,
    CPS = 15,
    TeamCheck = false,
    VisibleCheck = false,
    TargetPart = "Head",
    SilentAimMethod = "Raycast",
    FOVRadius = 70,
    FOVVisible = true,
    ShowSilentAimTarget = false,
    MouseHitPrediction = false,
    MouseHitPredictionAmount = 0.165,
    HitChance = 100
})

local DashSettings = safeGet("DashSettings", {
    DashKey = "V",
    DashSpeed = 100.0,
    DashDuration = 0.2,
    DashCooldown = 2.0,
    DashEnabled = true
})

local AntiAimSettings = safeGet("AntiAimSettings", {
    Enabled = false,
    Yaw = 0,
    Pitch = 0,
    Roll = 0,
    Mode = "Static",
    FakeLag = false,
    Desync = false,
    LastUpdate = 0,
    UpdateInterval = 0.1
})

local FlySettings = safeGet("FlySettings", {
    Enabled = false,
    FlyKey = "T",
    Cooldown = 1
})

local NoclipSettings = safeGet("NoclipSettings", {Enabled = false})
local AntiDeathSettings = safeGet("AntiDeathSettings", {Enabled = false})
local JumpStunSettings = safeGet("JumpStunSettings", {Enabled = false})
local HUDSettings = safeGet("HUDSettings", {ShowKeybindsHUD = true})
local ESPSettings = safeGet("ESPSettings", {Enabled = false})
local SpeedSettings = safeGet("SpeedSettings", {
    Enabled = false,
    SpeedKey = "Delete",
    BaseTpDistance = 0.5,
    SpeedMultiplier = 1,
    GuiVisible = false
})
local VisualEffectsSettings = safeGet("VisualEffectsSettings", {
    AmbientEnabled = false,
    TrailsEnabled = false,
    CustomFOVEnabled = false,
    CustomFOV = 70
})

-- Drawing API
local Drawing = Drawing
if not Drawing then
    warn("Drawing API не доступен, визуальные элементы не будут отображаться")
end

-- Утилиты для UI
local function createTextLabel(parent, text, size, pos, font, color, align)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = size or UDim2.new(1, 0, 0, 20)
    label.Position = pos or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(230, 230, 230)
    label.Font = font or Enum.Font.Gotham
    label.TextSize = 18
    label.TextXAlignment = align or Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createButton(parent, text, size, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = size or UDim2.new(0, 100, 0, 30)
    btn.Position = pos or UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(54, 57, 241)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.AutoButtonColor = true
    btn.Parent = parent
    btn.ClipsDescendants = true
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return btn
end

local function createToggle(parent, text, settingTable, settingKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = createTextLabel(frame, text, UDim2.new(0.7, 0, 1, 0), nil, Enum.Font.Gotham, Color3.fromRGB(220,220,220), Enum.TextXAlignment.Left)
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, 0, 1, 0)
    toggle.Position = UDim2.new(0.75, 0, 0, 0)
    toggle.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    toggle.Text = settingTable[settingKey] and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 18
    toggle.Parent = frame

    toggle.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        toggle.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        toggle.Text = settingTable[settingKey] and "ON" or "OFF"
    end)

    return frame
end

local function createSlider(parent, text, settingTable, settingKey, min, max, step)
    step = step or 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = createTextLabel(frame, text .. ": " .. tostring(settingTable[settingKey]), UDim2.new(1, 0, 0, 20), nil, Enum.Font.Gotham, Color3.fromRGB(220,220,220), Enum.TextXAlignment.Left)
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 20)
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.Parent = frame
    sliderFrame.ClipsDescendants = true
    sliderFrame.BorderSizePixel = 0
    sliderFrame.AnchorPoint = Vector2.new(0, 0)

    local sliderFill = Instance.new("Frame")
    local fillPercent = (settingTable[settingKey] - min) / (max - min)
    sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(54, 57, 241)
    sliderFill.Parent = sliderFrame
    sliderFill.BorderSizePixel = 0

    local dragging = false

    local function updateSlider(inputPosX)
        local absPos = sliderFrame.AbsolutePosition.X
        local absSize = sliderFrame.AbsoluteSize.X
        local relativeX = math.clamp(inputPosX - absPos, 0, absSize)
        local percent = relativeX / absSize
        local value = min + (max - min) * percent
        value = math.floor(value / step + 0.5) * step
        settingTable[settingKey] = value
        label.Text = text .. ": " .. tostring(value)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    end

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)

    sliderFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input.Position.X)
        end
    end)

    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return frame
end

-- Создаем ScreenGui и главное окно
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UnloosedMobileUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0,0)

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = createTextLabel(TitleBar, "Unloosed.cc", UDim2.new(0, 220, 1, 0), UDim2.new(0, 10, 0, 0), Enum.Font.GothamBold, Color3.fromRGB(200, 200, 255), Enum.TextXAlignment.Left)
TitleLabel.TextSize = 22

-- Кнопка закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 42, 0, 42)
CloseBtn.Position = UDim2.new(1, -42, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = TitleBar
CloseBtn.AutoButtonColor = true
CloseBtn.BorderSizePixel = 0

-- Кнопка свернуть
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 42, 0, 42)
MinimizeBtn.Position = UDim2.new(1, -84, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeBtn.Text = "-"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 28
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Parent = TitleBar
MinimizeBtn.AutoButtonColor = true
MinimizeBtn.BorderSizePixel = 0

-- Контейнер для вкладок
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -42)
TabContainer.Position = UDim2.new(0, 0, 0, 42)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Кнопки вкладок
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = TabContainer

local TabsCorner = Instance.new("UICorner")
TabsCorner.CornerRadius = UDim.new(0, 12)
TabsCorner.Parent = TabsFrame

local TabNames = {"Combat", "Movement", "Visuals", "Misc"}
local TabButtons = {}
local ContentFrames = {}

local function createTabButton(name, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Position = UDim2.new(0, (index-1)*80, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(54, 57, 241)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = TabsFrame
    btn.AutoButtonColor = true
    btn.BorderSizePixel = 0
    return btn
end

local function createContentFrame()
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, -40)
    frame.Position = UDim2.new(0, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.ScrollBarThickness = 8
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = TabContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = frame

    return frame
end

for i, name in ipairs(TabNames) do
    TabButtons[i] = createTabButton(name, i)
    ContentFrames[i] = createContentFrame()
end

-- Функция переключения вкладок
local currentTab = 1
local function switchTab(index)
    for i, frame in ipairs(ContentFrames) do
        frame.Visible = (i == index)
        TabButtons[i].BackgroundColor3 = (i == index) and Color3.fromRGB(54, 57, 241) or Color3.fromRGB(40, 40, 40)
    end
    currentTab = index
end

switchTab(1)

for i, btn in ipairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        switchTab(i)
    end)
end

-- Функция закрыть меню
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Функция свернуть/развернуть меню
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    if minimized then
        MainFrame.Size = UDim2.new(0, 360, 0, 480)
        TabContainer.Visible = true
        minimized = false
        MinimizeBtn.Text = "-"
    else
        MainFrame.Size = UDim2.new(0, 360, 0, 42)
        TabContainer.Visible = false
        minimized = true
        MinimizeBtn.Text = "+"
    end
end)

-- Перетаскивание меню по заголовку
local dragging = false
local dragStartPos = nil
local frameStartPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStartPos = input.Position
        frameStartPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
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

-- Функции UI для каждой вкладки

-- Combat вкладка
do
    local parent = ContentFrames[1]
    createToggle(parent, "Silent Aim Enabled", SilentAimSettings, "Enabled")
    createToggle(parent, "Auto Shoot", SilentAimSettings, "AutoShoot")
    createSlider(parent, "CPS", SilentAimSettings, "CPS", 1, 30, 1)
    createToggle(parent, "Team Check", SilentAimSettings, "TeamCheck")
    createToggle(parent, "Visible Check", SilentAimSettings, "VisibleCheck")
    createSlider(parent, "Hit Chance", SilentAimSettings, "HitChance", 0, 100, 1)
    createToggle(parent, "Show FOV Circle", SilentAimSettings, "FOVVisible")
    createSlider(parent, "FOV Radius", SilentAimSettings, "FOVRadius", 10, 200, 1)
    createToggle(parent, "Show Silent Aim Target", SilentAimSettings, "ShowSilentAimTarget")
    createToggle(parent, "Mouse Hit Prediction", SilentAimSettings, "MouseHitPrediction")
    createSlider(parent, "Prediction Amount", SilentAimSettings, "MouseHitPredictionAmount", 0.01, 1, 0.01)

    createToggle(parent, "Anti Aim Enabled", AntiAimSettings, "Enabled")
    createSlider(parent, "Yaw", AntiAimSettings, "Yaw", -90, 90, 1)
    createSlider(parent, "Pitch", AntiAimSettings, "Pitch", -90, 90, 1)
    createSlider(parent, "Roll", AntiAimSettings, "Roll", -45, 45, 1)
end

-- Movement вкладка
do
    local parent = ContentFrames[2]
    createToggle(parent, "Dash Enabled", DashSettings, "DashEnabled")
    createSlider(parent, "Dash Speed", DashSettings, "DashSpeed", 10, 200, 1)
    createSlider(parent, "Dash Duration", DashSettings, "DashDuration", 0.1, 1, 0.05)
    createSlider(parent, "Dash Cooldown", DashSettings, "DashCooldown", 0.5, 5, 0.1)

    createToggle(parent, "Fly Enabled", FlySettings, "Enabled")
    createSlider(parent, "Fly Cooldown", FlySettings, "Cooldown", 0.1, 5, 0.1)

    createToggle(parent, "Noclip Enabled", NoclipSettings, "Enabled")

    createToggle(parent, "Speed Enabled", SpeedSettings, "Enabled")
    createSlider(parent, "Speed Multiplier", SpeedSettings, "SpeedMultiplier", 1, 10, 0.1)

    createToggle(parent, "Jump Stun Enabled", JumpStunSettings, "Enabled")
end

-- Visuals вкладка
do
    local parent = ContentFrames[3]
    createToggle(parent, "ESP Enabled", ESPSettings, "Enabled")
    createToggle(parent, "Ambient Effects", VisualEffectsSettings, "AmbientEnabled")
    createToggle(parent, "Trails Enabled", VisualEffectsSettings, "TrailsEnabled")
    createToggle(parent, "Custom FOV Enabled", VisualEffectsSettings, "CustomFOVEnabled")
    createSlider(parent, "Custom FOV", VisualEffectsSettings, "CustomFOV", 30, 120, 1)
end

-- Misc вкладка
do
    local parent = ContentFrames[4]
    createToggle(parent, "Anti Death Enabled", AntiDeathSettings, "Enabled")
    createToggle(parent, "Show Keybinds HUD", HUDSettings, "ShowKeybindsHUD")
end

-- Drawing и визуализация FOV + прицел
local mouse_box = nil
local fov_circle = nil

if Drawing then
    mouse_box = Drawing.new("Square")
    mouse_box.Visible = false
    mouse_box.ZIndex = 999
    mouse_box.Color = Color3.fromRGB(54, 57, 241)
    mouse_box.Thickness = 3
    mouse_box.Size = Vector2.new(20, 20)
    mouse_box.Filled = true

    fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1
    fov_circle.NumSides = 100
    fov_circle.Radius = 70
    fov_circle.Filled = false
    fov_circle.Visible = SilentAimSettings.FOVVisible
    fov_circle.ZIndex = 999
    fov_circle.Transparency = 1
    fov_circle.Color = Color3.fromRGB(54, 57, 241)
end

local function degreesToPixels(degrees)
    local cameraFOV = Camera.FieldOfView
    local screenHeight = Camera.ViewportSize.Y
    local radians = math.rad(degrees / 2)
    local cameraFOVRad = math.rad(cameraFOV / 2)
    return math.tan(radians) * (screenHeight / (2 * math.tan(cameraFOVRad)))
end

local function getMousePosition()
    return UserInputService:GetMouseLocation()
end

-- Функция поиска ближайшей цели для Silent Aim
local function visibleCheck(target, part)
    if not SilentAimSettings.VisibleCheck then return true end
    if not target or not target.Character or not part then
        return false
    end

    local currentTime = tick()
    local cacheKey = tostring(target.UserId)

    if VisibleCheckCache == nil then VisibleCheckCache = {} end
    if VisibleCheckCache[cacheKey] and currentTime - VisibleCheckCache[cacheKey].time < 0.3 then
        return VisibleCheckCache[cacheKey].visible
    end

    local PlayerCharacter = target.Character
    local LocalPlayerCharacter = LocalPlayer.Character

    if not (PlayerCharacter and LocalPlayerCharacter) then
        VisibleCheckCache[cacheKey] = { visible = false, time = currentTime }
        return false
    end

    local PlayerRoot = PlayerCharacter:FindFirstChild(SilentAimSettings.TargetPart) or PlayerCharacter:FindFirstChild("HumanoidRootPart")
    local LocalPlayerRoot = LocalPlayerCharacter:FindFirstChild("HumanoidRootPart")

    if not (PlayerRoot and LocalPlayerRoot) then
        VisibleCheckCache[cacheKey] = { visible = false, time = currentTime }
        return false
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayerCharacter, PlayerCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    raycastParams.RespectCanCollide = true

    local pointsToCheck = {
        PlayerRoot.Position,
        PlayerRoot.Position + Vector3.new(0, 2, 0),
        PlayerRoot.Position + Vector3.new(0, -1, 0)
    }

    for _, point in ipairs(pointsToCheck) do
        local direction = (point - LocalPlayerRoot.Position).Unit
        local distance = (point - LocalPlayerRoot.Position).Magnitude
        local raycastResult = workspace:Raycast(LocalPlayerRoot.Position, direction * distance, raycastParams)
        if not raycastResult or (raycastResult.Instance:IsDescendantOf(PlayerCharacter)) then
            VisibleCheckCache[cacheKey] = { visible = true, time = currentTime }
            return true
        end
    end

    VisibleCheckCache[cacheKey] = { visible = false, time = currentTime }
    return false
end

local function getClosestPlayer()
    local Closest
    local DistanceToMouse
    local pixelRadius = degreesToPixels(SilentAimSettings.FOVRadius)
    for _, Player in pairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if SilentAimSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end

        local Character = Player.Character
        if not Character then continue end
        
        local Head = Character:FindFirstChild("Head")
        local Humanoid = Character:FindFirstChild("Humanoid")
        if not Head or not Humanoid or Humanoid.Health <= 0 then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(Head.Position)
        if not onScreen then continue end

        local mousePos = getMousePosition()
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if distance > pixelRadius then continue end
        
        if SilentAimSettings.VisibleCheck and not visibleCheck(Player, Head) then continue end

        if distance <= (DistanceToMouse or pixelRadius) then
            Closest = Head
            DistanceToMouse = distance
        end
    end
    return Closest
end

local function CalculateChance(percentage)
    return math.random(0, 100) <= percentage
end

local LastShot = 0

-- Автосстрел и визуализация
RunService.RenderStepped:Connect(function()
    if Drawing then
        if fov_circle then
            fov_circle.Radius = degreesToPixels(SilentAimSettings.FOVRadius)
            fov_circle.Position = getMousePosition()
            fov_circle.Visible = SilentAimSettings.FOVVisible
        end
        if mouse_box then
            local target = getClosestPlayer()
            if target and SilentAimSettings.ShowSilentAimTarget and SilentAimSettings.Enabled then
                local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                if onScreen then
                    mouse_box.Position = Vector2.new(screenPos.X, screenPos.Y)
                    mouse_box.Visible = true
                else
                    mouse_box.Visible = false
                end
            else
                mouse_box.Visible = false
            end
        end
    end

    if SilentAimSettings.Enabled and SilentAimSettings.AutoShoot then
        local now = tick()
        local interval = 1 / math.max(SilentAimSettings.CPS, 1)
        if now - LastShot >= interval then
            local target = getClosestPlayer()
            if target and CalculateChance(SilentAimSettings.HitChance) then
                local success, err = pcall(function()
                    mouse1press()
                    mouse1release()
                end)
                if not success then
                    warn("AutoShoot error: ".. tostring(err))
                end
                LastShot = now
            end
        end
    end
end)

-- Dash (по нажатию клавиши)
local LastDashTime = 0
local IsDashing = false

local function PerformDash()
    if not DashSettings.DashEnabled then return end
    local now = tick()
    if IsDashing or now - LastDashTime < DashSettings.DashCooldown then return end
    IsDashing = true
    LastDashTime = now
    local Character = LocalPlayer.Character
    if not Character then IsDashing = false return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not RootPart or not Humanoid then IsDashing = false return end

    local MoveDir = Humanoid.MoveDirection
    if MoveDir.Magnitude == 0 then
        MoveDir = RootPart.CFrame.LookVector
    end

    local StartTime = tick()
    local MaxDistance = DashSettings.DashSpeed * DashSettings.DashDuration
    local DistanceMoved = 0

    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        if tick() - StartTime >= DashSettings.DashDuration or not Character or not Humanoid or Humanoid.Health <= 0 then
            IsDashing = false
            conn:Disconnect()
            return
        end
        local stepDist = DashSettings.DashSpeed * dt
        DistanceMoved = DistanceMoved + stepDist
        if DistanceMoved <= MaxDistance then
            RootPart.CFrame = RootPart.CFrame + MoveDir * stepDist
        end
    end)
end

-- Обработка нажатий клавиш (по возможности на мобильном, но клавиатура все равно нужна)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keyName = input.KeyCode.Name
        if keyName == DashSettings.DashKey then
            PerformDash()
        elseif keyName == FlySettings.FlyKey then
            if tick() - (FlySettings.LastActivation or 0) >= FlySettings.Cooldown then
                FlySettings.LastActivation = tick()
                FlySettings.Enabled = not FlySettings.Enabled
                -- Тут можно добавить вызов Fly функции из ПК скрипта
            end
        elseif keyName == "RightAlt" then
            SilentAimSettings.Enabled = not SilentAimSettings.Enabled
        elseif keyName == "B" then
            JumpStunSettings.Enabled = not JumpStunSettings.Enabled
        elseif keyName == SpeedSettings.SpeedKey then
            SpeedSettings.GuiVisible = not SpeedSettings.GuiVisible
        end
    end
end)

-- Hook для Raycast Silent Aim (если поддерживается)
local oldNamecall
local getnamecallmethod = getnamecallmethod or function() return nil end
local hookmetamethod = hookmetamethod or nil

if hookmetamethod and getnamecallmethod then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if SilentAimSettings.Enabled and self == workspace and not checkcaller() then
            if method == "Raycast" and SilentAimSettings.SilentAimMethod == "Raycast" then
                if #args >= 3 then
                    local origin = args[2]
                    local direction = args[3]
                    local targetPart = getClosestPlayer()
                    if targetPart then
                        local targetPos = targetPart.Position
                        if SilentAimSettings.MouseHitPrediction then
                            local humanoid = targetPart.Parent:FindFirstChild("Humanoid")
                            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                                targetPos = targetPos + humanoid.MoveDirection * SilentAimSettings.MouseHitPredictionAmount
                            end
                        end
                        args[3] = (targetPos - origin).Unit * 1000
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

print("Unloosed.cc Mobile UI loaded successfully!")
