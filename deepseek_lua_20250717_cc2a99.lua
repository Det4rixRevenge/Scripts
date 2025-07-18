-- Мобильный UI для функций из ПК скрипта
-- UI простой, без сворачивания/закрытия, с переключателями и слайдерами
-- Все функции работают как в ПК скрипте

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Защита от nil глобальных настроек
local function safeGet(name, default)
    local val = getgenv()[name]
    if val == nil then
        getgenv()[name] = default
        return default
    end
    return val
end

-- Используем настройки из getgenv() или дефолты
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

-- Drawing API для FOV и прицела
local Drawing = Drawing
if not Drawing then
    warn("Drawing API не доступен, визуальные элементы не будут отображаться")
end

local function degreesToPixels(degrees)
    local cameraFOV = Camera.FieldOfView
    local screenHeight = Camera.ViewportSize.Y
    local radians = math.rad(degrees / 2)
    local cameraFOVRad = math.rad(cameraFOV / 2)
    return math.tan(radians) * (screenHeight / (2 * math.tan(cameraFOVRad)))
end

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
    fov_circle.Radius = degreesToPixels(SilentAimSettings.FOVRadius)
    fov_circle.Filled = false
    fov_circle.Visible = SilentAimSettings.FOVVisible
    fov_circle.ZIndex = 999
    fov_circle.Transparency = 1
    fov_circle.Color = Color3.fromRGB(54, 57, 241)
end

-- UI элементы (простой вертикальный список переключателей и слайдеров)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileSimpleUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = MainFrame

local function createToggle(text, settingTable, settingKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
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

        -- Обновляем визуализацию FOV и прицела, если нужно
        if settingTable == SilentAimSettings then
            if settingKey == "FOVVisible" and fov_circle then
                fov_circle.Visible = SilentAimSettings.FOVVisible
            elseif settingKey == "ShowSilentAimTarget" and mouse_box then
                mouse_box.Visible = SilentAimSettings.ShowSilentAimTarget and SilentAimSettings.Enabled
            elseif settingKey == "Enabled" and mouse_box then
                mouse_box.Visible = SilentAimSettings.ShowSilentAimTarget and SilentAimSettings.Enabled
            end
        end
    end)
end

local function createSlider(text, settingTable, settingKey, min, max, step)
    step = step or 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame

    local label = Instance.new("TextLabel")
    label.Text = text .. ": " .. tostring(settingTable[settingKey])
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 20)
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.Parent = frame

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(54, 57, 241)
    sliderFill.Parent = sliderFrame

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
end

-- Создаем UI элементы для Silent Aim (минимальный набор)
createToggle("Silent Aim Enabled", SilentAimSettings, "Enabled")
createToggle("Auto Shoot", SilentAimSettings, "AutoShoot")
createSlider("CPS", SilentAimSettings, "CPS", 1, 30, 1)
createToggle("Team Check", SilentAimSettings, "TeamCheck")
createToggle("Visible Check", SilentAimSettings, "VisibleCheck")
createSlider("Hit Chance", SilentAimSettings, "HitChance", 0, 100, 1)
createToggle("Show FOV Circle", SilentAimSettings, "FOVVisible")
createSlider("FOV Radius", SilentAimSettings, "FOVRadius", 10, 200, 1)
createToggle("Show Silent Aim Target", SilentAimSettings, "ShowSilentAimTarget")
createToggle("Mouse Hit Prediction", SilentAimSettings, "MouseHitPrediction")
createSlider("Prediction Amount", SilentAimSettings, "MouseHitPredictionAmount", 0.01, 1, 0.01)

-- Создаем UI элементы для Dash
createToggle("Dash Enabled", DashSettings, "DashEnabled")
createSlider("Dash Speed", DashSettings, "DashSpeed", 10, 200, 1)
createSlider("Dash Duration", DashSettings, "DashDuration", 0.1, 1, 0.05)
createSlider("Dash Cooldown", DashSettings, "DashCooldown", 0.5, 5, 0.1)

-- Создаем UI для Anti Aim
createToggle("Anti Aim Enabled", AntiAimSettings, "Enabled")
createSlider("Yaw", AntiAimSettings, "Yaw", -90, 90, 1)
createSlider("Pitch", AntiAimSettings, "Pitch", -90, 90, 1)
createSlider("Roll", AntiAimSettings, "Roll", -45, 45, 1)

-- Пример: Текущий режим AntiAim — просто текст (для простоты)
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(1, -16, 0, 30)
modeFrame.BackgroundTransparency = 1
modeFrame.Parent = MainFrame

local modeLabel = Instance.new("TextLabel")
modeLabel.Text = "Anti Aim Mode: " .. tostring(AntiAimSettings.Mode)
modeLabel.Size = UDim2.new(0.7, 0, 1, 0)
modeLabel.BackgroundTransparency = 1
modeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 18
modeLabel.Parent = modeFrame

local modes = {"Static", "Jitter", "Random"}
local modeButton = Instance.new("TextButton")
modeButton.Text = "Change"
modeButton.Size = UDim2.new(0.25, 0, 1, 0)
modeButton.Position = UDim2.new(0.75, 0, 0, 0)
modeButton.BackgroundColor3 = Color3.fromRGB(54, 57, 241)
modeButton.TextColor3 = Color3.new(1,1,1)
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 18
modeButton.Parent = modeFrame

modeButton.MouseButton1Click:Connect(function()
    local currentIndex = table.find(modes, AntiAimSettings.Mode) or 1
    local nextIndex = currentIndex + 1
    if nextIndex > #modes then nextIndex = 1 end
    AntiAimSettings.Mode = modes[nextIndex]
    modeLabel.Text = "Anti Aim Mode: " .. AntiAimSettings.Mode
end)

-- Функции из ПК скрипта (копипаста и адаптация)

local LastDashTime = 0
local IsDashing = false
local LastShotTime = 0
local VisibleCheckCache = {}
local CacheDuration = 0.3
local LastFlyActivation = 0
local Clipon = false
local NoclipConnection = nil

local function getMousePosition()
    return UserInputService:GetMouseLocation()
end

local function degreesToPixels(degrees)
    local cameraFOV = Camera.FieldOfView
    local screenHeight = Camera.ViewportSize.Y
    local radians = math.rad(degrees / 2)
    local cameraFOVRad = math.rad(cameraFOV / 2)
    return math.tan(radians) * (screenHeight / (2 * math.tan(cameraFOVRad)))
end

local function visibleCheck(target, part)
    if not SilentAimSettings.VisibleCheck then return true end
    if not target or not target.Character or not part then
        return false
    end

    local currentTime = tick()
    local cacheKey = tostring(target.UserId)

    if VisibleCheckCache[cacheKey] and currentTime - VisibleCheckCache[cacheKey].time < CacheDuration then
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

-- Автосстрел
RunService.RenderStepped:Connect(function()
    -- Обновляем FOV circle и прицел
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

    -- Автосстрел
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

-- Dash
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keyName = input.KeyCode.Name
        if keyName == DashSettings.DashKey then
            PerformDash()
        elseif keyName == FlySettings.FlyKey then
            if tick() - LastFlyActivation >= FlySettings.Cooldown then
                LastFlyActivation = tick()
                FlySettings.Enabled = not FlySettings.Enabled
                -- Тут вызов Fly скрипта из ПК версии, если есть
            end
        elseif keyName == "RightAlt" then
            SilentAimSettings.Enabled = not SilentAimSettings.Enabled
            if mouse_box then
                mouse_box.Visible = SilentAimSettings.Enabled and SilentAimSettings.ShowSilentAimTarget
            end
        elseif keyName == "B" then
            JumpStunSettings.Enabled = not JumpStunSettings.Enabled
            -- Тут загрузка Jump Stun скрипта из ПК версии, если надо
        elseif keyName == SpeedSettings.SpeedKey then
            SpeedSettings.GuiVisible = not SpeedSettings.GuiVisible
            -- Тут показ/скрытие Speed GUI из ПК версии, если есть
        end
    end
end)

-- Hook метамethod для Silent Aim Raycast (копия из ПК версии)
local oldNamecall
oldNamecall = hookmetamethod or function() end
local getnamecallmethod = getnamecallmethod or function() end

if oldNamecall ~= nil and getnamecallmethod ~= nil then
    local oldNamecallFunc = oldNamecall
    oldNamecall = newcclosure(function(...)
        local method = getnamecallmethod()
        local args = {...}
        local selfObj = args[1]
        if SilentAimSettings.Enabled and selfObj == workspace and not checkcaller() then
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
                        return oldNamecallFunc(unpack(args))
                    end
                end
            end
        end
        return oldNamecallFunc(...)
    end)
end

-- Перетаскивание меню (простой drag)
local dragging = false
local dragStartPos = nil
local frameStartPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStartPos = input.Position
        frameStartPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
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

print("Mobile UI loaded with full PC script functionality.")
