-- UNLOOSED.CC MOBILE (FULL PC FUNCTIONALITY)

-- Ожидание загрузки игры
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

-- Ожидание LocalPlayer
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    wait(1)
    LocalPlayer = Players.LocalPlayer
end

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
        Speed = false,
        SpeedMultiplier = 1,
        DashEnabled = true,
        DashKey = "V",
        DashSpeed = 100,
        DashDuration = 0.2,
        DashCooldown = 2.0,
        FlyEnabled = false,
        FlyKey = "T",
        Noclip = false,
        HighJump = false,
        JumpPower = 50
    },
    Visuals = {
        ESP = false,
        Tracers = false,
        Ambient = false,
        Trails = false,
        CustomFOV = false,
        FOVValue = 70
    },
    Combat = {
        AntiAim = false,
        AntiDeath = false,
        JumpStun = false
    }
}

-- Переменные
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
local UIEnabled = true
local Minimized = false

-- Создаем адаптивное меню
local MobileUI = Instance.new("ScreenGui")
MobileUI.Name = "UnloosedMobileUI"
MobileUI.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MobileUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.05, 0)
UICorner.Parent = MainFrame

-- Header с возможностью перемещения
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
Header.Parent = MainFrame

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

-- Кнопки управления
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.Parent = Header

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeButton.Parent = Header

-- Табы
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

local Tabs = {"Aim", "Movement", "Visuals", "Combat"}
for i, name in ipairs(Tabs) do
    local tab = Instance.new("TextButton")
    tab.Text = name
    tab.Size = UDim2.new(1/#Tabs, 0, 1, 0)
    tab.Position = UDim2.new((i-1)/#Tabs, 0, 0, 0)
    tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tab.TextColor3 = Color3.new(1, 1, 1)
    tab.Parent = TabButtons
end

-- Контент табов
local TabContent = Instance.new("Frame")
TabContent.Size = UDim2.new(1, 0, 1, -80)
TabContent.Position = UDim2.new(0, 0, 0, 80)
TabContent.BackgroundTransparency = 1
TabContent.Parent = MainFrame

-- Функции из PC версии
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local head = character:FindFirstChild("Head")
                
                if humanoid and humanoid.Health > 0 and head then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distance = (UserInputService:GetMouseLocation() - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                        if distance < shortestDistance and distance <= Settings.SilentAim.FOVRadius then
                            closest = head
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

local function AutoShoot()
    if Settings.SilentAim.Enabled and Settings.SilentAim.AutoShoot then
        local currentTime = tick()
        if currentTime - LastShotTime >= (1 / Settings.SilentAim.CPS) then
            local target = GetClosestPlayer()
            if target and math.random(1, 100) <= Settings.SilentAim.HitChance then
                mouse1press()
                mouse1release()
                LastShotTime = currentTime
            end
        end
    end
end

local function PerformDash()
    if Settings.Movement.DashEnabled and not IsDashing and tick() - LastDashTime >= Settings.Movement.DashCooldown then
        IsDashing = true
        LastDashTime = tick()
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                local direction = humanoid.MoveDirection.Magnitude > 0 and humanoid.MoveDirection or rootPart.CFrame.LookVector
                local startTime = tick()
                
                local connection
                connection = RunService.Heartbeat:Connect(function(delta)
                    if tick() - startTime >= Settings.Movement.DashDuration then
                        IsDashing = false
                        connection:Disconnect()
                        return
                    end
                    
                    rootPart.CFrame = rootPart.CFrame + (direction * Settings.Movement.DashSpeed * delta)
                end)
            end
        end
    end
end

-- Обработчики кнопок
CloseButton.MouseButton1Click:Connect(function()
    MobileUI:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        MainFrame.Size = UDim2.new(0.3, 0, 0, 40)
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
        MinimizeButton.Text = "_"
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    AutoShoot()
    
    -- Обновление скорости
    if Settings.Movement.Speed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * Settings.Movement.SpeedMultiplier
        end
    end
end)

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode[Settings.Movement.DashKey] then
            PerformDash()
        elseif input.KeyCode == Enum.KeyCode[Settings.Movement.FlyKey] then
            Settings.Movement.FlyEnabled = not Settings.Movement.FlyEnabled
            if Settings.Movement.FlyEnabled then
                FlyInstance = loadstring(game:HttpGet("https://pastebin.com/raw/5HvNBUec"))()
            elseif FlyInstance then
                FlyInstance:Destroy()
            end
        end
    end
end)

-- Уведомление о загрузке
local notification = Instance.new("TextLabel")
notification.Text = "UNLOOSED.CC MOBILE LOADED"
notification.TextColor3 = Color3.new(0, 1, 0)
notification.BackgroundColor3 = Color3.new(0, 0, 0)
notification.Size = UDim2.new(0, 200, 0, 30)
notification.Position = UDim2.new(0.5, -100, 0.9, 0)
notification.Parent = CoreGui

game:GetService("TweenService"):Create(notification, TweenInfo.new(3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
task.delay(3, function() notification:Destroy() end)
