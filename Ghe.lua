local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Lighting = game:GetService("Lighting")

local Camera = workspace.CurrentCamera

-- Создаем мобильный интерфейс

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "MobileCheatMenu"

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Основной фрейм

local MainFrame = Instance.new("Frame")

MainFrame.Name = "MainFrame"

MainFrame.Size = UDim2.new(0.8, 0, 0.7, 0)

MainFrame.Position = UDim2.new(0.1, 0, 0.15, 0)

MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

MainFrame.Visible = false

MainFrame.Parent = ScreenGui

-- Кнопка открытия меню

local OpenButton = Instance.new("TextButton")

OpenButton.Name = "OpenButton"

OpenButton.Text = "MENU"

OpenButton.Size = UDim2.new(0.15, 0, 0.07, 0)

OpenButton.Position = UDim2.new(0.02, 0, 0.02, 0)

OpenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)

OpenButton.Font = Enum.Font.GothamBold

OpenButton.TextSize = 16

OpenButton.Parent = ScreenGui

OpenButton.MouseButton1Click:Connect(function()

    MainFrame.Visible = not MainFrame.Visible

end)

-- Прокручиваемый фрейм

local ScrollFrame = Instance.new("ScrollingFrame")

ScrollFrame.Name = "ScrollFrame"

ScrollFrame.Size = UDim2.new(0.95, 0, 0.95, 0)

ScrollFrame.Position = UDim2.new(0.025, 0, 0.05, 0)

ScrollFrame.BackgroundTransparency = 1

ScrollFrame.ScrollBarThickness = 6

ScrollFrame.CanvasSize = UDim2.new(0, 0, 2.5, 0)

ScrollFrame.Parent = MainFrame

-- Переменные для эффектов

local VisualEffects = {

    AmbientEnabled = false,

    TrailsEnabled = false,

    SnowEnabled = false,

    CustomFOVEnabled = false,

    CustomFOV = 70,

    ESPEnabled = false,

    AimbotEnabled = false

}

local SnowPart, SnowEmitter, TrailInstance, FOVConnection

-- Функции визуальных эффектов

local function ApplyAmbientEffects()

    for _, child in pairs(Lighting:GetChildren()) do

        if child:IsA("Sky") or child:IsA("PostEffect") or child:IsA("Atmosphere") then

            child:Destroy()

        end

    end

    

    local sky = Instance.new("Sky")

    sky.SkyboxBk = "rbxassetid://0"

    sky.SkyboxDn = "rbxassetid://0"

    sky.SkyboxFt = "rbxassetid://0"

    sky.SkyboxLf = "rbxassetid://0"

    sky.SkyboxRt = "rbxassetid://0"

    sky.SkyboxUp = "rbxassetid://0"

    sky.StarCount = 0

    sky.Parent = Lighting

    

    local atmosphere = Instance.new("Atmosphere")

    atmosphere.Density = 0.3

    atmosphere.Offset = 0

    atmosphere.Color = Color3.fromRGB(0, 0, 0)

    atmosphere.Decay = Color3.fromRGB(0, 0, 0)

    atmosphere.Glare = 0

    atmosphere.Haze = 0

    atmosphere.Parent = Lighting

    

    local purpleColor = Color3.fromRGB(128, 0, 255)

    Lighting.Ambient = Color3.fromRGB(50, 50, 50)

    Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)

    Lighting.ColorShift_Top = purpleColor

    Lighting.ColorShift_Bottom = purpleColor

    Lighting.FogColor = purpleColor

    Lighting.FogEnd = 500

    Lighting.FogStart = 0

end

local function CreateSnow()

    if SnowPart then SnowPart:Destroy() end

    

    SnowEmitter = Instance.new("ParticleEmitter")

    SnowEmitter.Texture = "rbxassetid://258123448"

    SnowEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))

    SnowEmitter.Size = NumberSequence.new(0.5)

    SnowEmitter.Lifetime = NumberRange.new(5)

    SnowEmitter.Rate = 100

    SnowEmitter.Speed = NumberRange.new(5)

    SnowEmitter.SpreadAngle = Vector2.new(45, 45)

    

    SnowPart = Instance.new("Part")

    SnowPart.Size = Vector3.new(200, 0.1, 200)

    SnowPart.Anchored = true

    SnowPart.CanCollide = false

    SnowPart.Transparency = 1

    SnowPart.Parent = workspace

    SnowEmitter.Parent = SnowPart

    

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    local rootPart = character:WaitForChild("HumanoidRootPart")

    

    local connection

    connection = game:GetService("RunService").Heartbeat:Connect(function()

        if SnowPart and rootPart then

            SnowPart.Position = rootPart.Position + Vector3.new(0, 30, 0)

        else

            connection:Disconnect()

        end

    end)

    

    LocalPlayer.CharacterAdded:Connect(function(newCharacter)

        rootPart = newCharacter:WaitForChild("HumanoidRootPart")

    end)

end

local function CreateTrails(parent)

    if TrailInstance then TrailInstance:Destroy() end

    

    TrailInstance = Instance.new("Trail")

    TrailInstance.Color = ColorSequence.new(Color3.fromRGB(128, 0, 255))

    TrailInstance.Lifetime = 0.5

    TrailInstance.Enabled = true

    

    local attachment0 = Instance.new("Attachment")

    attachment0.Position = Vector3.new(0, 1.5, 0)

    attachment0.Parent = parent

    

    local attachment1 = Instance.new("Attachment")

    attachment1.Position = Vector3.new(0, -1.5, 0)

    attachment1.Parent = parent

    

    TrailInstance.Attachment0 = attachment0

    TrailInstance.Attachment1 = attachment1

    TrailInstance.Parent = parent

end

-- Функции ESP и Aimbot

local function ToggleESP()

    VisualEffects.ESPEnabled = not VisualEffects.ESPEnabled

    if VisualEffects.ESPEnabled then

        loadstring(game:HttpGet("https://pastefy.app/u4SCGOhs/raw", true))()

    else

        -- Выключение ESP

        for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do

            if v.Name == "ESP" then

                v:Destroy()

            end

        end

    end

end

local function ToggleAimbot()

    VisualEffects.AimbotEnabled = not VisualEffects.AimbotEnabled

    if VisualEffects.AimbotEnabled then

        loadstring(game:HttpGet("https://raw.githubusercontent.com/D0LLYNHO/AIMBOT-FOV/main/MOBILE-BETA-0.2", true))()

    else

        _G.SilentAimEnabled = false

    end

end

local function UpdateFOV(value)

    VisualEffects.CustomFOV = value

    if VisualEffects.CustomFOVEnabled then

        Camera.FieldOfView = value

    end

end

-- Создаем элементы интерфейса

local yPosition = 0

local buttonHeight = 0.1

-- Атмосфера

local ambientButton = Instance.new("TextButton")

ambientButton.Name = "AmbientButton"

ambientButton.Text = "АТМОСФЕРА: ВЫКЛ"

ambientButton.Size = UDim2.new(1, 0, 0, 45)

ambientButton.Position = UDim2.new(0, 0, yPosition, 0)

ambientButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

ambientButton.TextColor3 = Color3.fromRGB(255, 255, 255)

ambientButton.Font = Enum.Font.Gotham

ambientButton.TextSize = 16

ambientButton.Parent = ScrollFrame

ambientButton.MouseButton1Click:Connect(function()

    VisualEffects.AmbientEnabled = not VisualEffects.AmbientEnabled

    ambientButton.Text = "АТМОСФЕРА: " .. (VisualEffects.AmbientEnabled and "ВКЛ" or "ВЫКЛ")

    ambientButton.BackgroundColor3 = VisualEffects.AmbientEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)

    

    if VisualEffects.AmbientEnabled then

        ApplyAmbientEffects()

    else

        Lighting:ClearAllChildren()

    end

end)

yPosition = yPosition + buttonHeight

-- Снег

local snowButton = Instance.new("TextButton")

snowButton.Name = "SnowButton"

snowButton.Text = "СНЕГ: ВЫКЛ"

snowButton.Size = UDim2.new(1, 0, 0, 45)

snowButton.Position = UDim2.new(0, 0, yPosition, 0)

snowButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

snowButton.TextColor3 = Color3.fromRGB(255, 255, 255)

snowButton.Font = Enum.Font.Gotham

snowButton.TextSize = 16

snowButton.Parent = ScrollFrame

snowButton.MouseButton1Click:Connect(function()

    VisualEffects.SnowEnabled = not VisualEffects.SnowEnabled

    snowButton.Text = "СНЕГ: " .. (VisualEffects.SnowEnabled and "ВКЛ" or "ВЫКЛ")

    snowButton.BackgroundColor3 = VisualEffects.SnowEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)

    

    if VisualEffects.SnowEnabled then

        CreateSnow()

    elseif SnowPart then

        SnowPart:Destroy()

        SnowPart = nil

    end

end)

yPosition = yPosition + buttonHeight

-- Шлейф

local trailsButton = Instance.new("TextButton")

trailsButton.Name = "TrailsButton"

trailsButton.Text = "ШЛЕЙФ: ВЫКЛ"

trailsButton.Size = UDim2.new(1, 0, 0, 45)

trailsButton.Position = UDim2.new(0, 0, yPosition, 0)

trailsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

trailsButton.TextColor3 = Color3.fromRGB(255, 255, 255)

trailsButton.Font = Enum.Font.Gotham

trailsButton.TextSize = 16

trailsButton.Parent = ScrollFrame

trailsButton.MouseButton1Click:Connect(function()

    VisualEffects.TrailsEnabled = not VisualEffects.TrailsEnabled

    trailsButton.Text = "ШЛЕЙФ: " .. (VisualEffects.TrailsEnabled and "ВКЛ" or "ВЫКЛ")

    trailsButton.BackgroundColor3 = VisualEffects.TrailsEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)

    

    if VisualEffects.TrailsEnabled then

        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        CreateTrails(character:WaitForChild("HumanoidRootPart"))

        

        LocalPlayer.CharacterAdded:Connect(function(newCharacter)

            if VisualEffects.TrailsEnabled then

                CreateTrails(newCharacter:WaitForChild("HumanoidRootPart"))

            end

        end)

    elseif TrailInstance then

        TrailInstance:Destroy()

        TrailInstance = nil

    end

end)

yPosition = yPosition + buttonHeight

-- Кастомный FOV

local fovButton = Instance.new("TextButton")

fovButton.Name = "FOVButton"

fovButton.Text = "КАСТОМ FOV: ВЫКЛ"

fovButton.Size = UDim2.new(1, 0, 0, 45)

fovButton.Position = UDim2.new(0, 0, yPosition, 0)

fovButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

fovButton.TextColor3 = Color3.fromRGB(255, 255, 255)

fovButton.Font = Enum.Font.Gotham

fovButton.TextSize = 16

fovButton.Parent = ScrollFrame

fovButton.MouseButton1Click:Connect(function()

    VisualEffects.CustomFOVEnabled = not VisualEffects.CustomFOVEnabled

    fovButton.Text = "КАСТОМ FOV: " .. (VisualEffects.CustomFOVEnabled and "ВКЛ" or "ВЫКЛ")

    fovButton.BackgroundColor3 = VisualEffects.CustomFOVEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)

    

    if VisualEffects.CustomFOVEnabled then

        if FOVConnection then FOVConnection:Disconnect() end

        Camera.FieldOfView = VisualEffects.CustomFOV

        FOVConnection = game:GetService("RunService").RenderStepped:Connect(function()

            Camera.FieldOfView = VisualEffects.CustomFOV

        end)

    elseif FOVConnection then

        FOVConnection:Disconnect()

        FOVConnection = nil

        Camera.FieldOfView = 70

    end

end)

yPosition = yPosition + buttonHeight

-- Кнопка ESP

local espButton = Instance.new("TextButton")

espButton.Name = "ESPButton"

espButton.Text = "ESP: ВЫКЛ"

espButton.Size = UDim2.new(1, 0, 0, 45)

espButton.Position = UDim2.new(0, 0, yPosition, 0)

espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

espButton.TextColor3 = Color3.fromRGB(255, 255, 255)

espButton.Font = Enum.Font.Gotham

espButton.TextSize = 16

espButton.Parent = ScrollFrame

espButton.MouseButton1Click:Connect(function()

    ToggleESP()

    espButton.Text = "ESP: " .. (VisualEffects.ESPEnabled and "ВКЛ" or "ВЫКЛ")

    espButton.BackgroundColor3 = VisualEffects.ESPEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)

end)

yPosition = yPosition + buttonHeight

-- Кнопка Aimbot

local aimbotButton = Instance.new("TextButton")

aimbotButton.Name = "AimbotButton"

aimbotButton.Text = "АИМБОТ: ВЫКЛ"

aimbotButton.Size = UDim2.new(1, 0, 0, 45)

aimbotButton.Position = UDim2.new(0, 0, yPosition, 0)

aimbotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)

aimbotButton.Font = Enum.Font.Gotham

aimbotButton.TextSize = 16

aimbotButton.Parent = ScrollFrame

aimbotButton.MouseButton1Click:Connect(function()

    ToggleAimbot()

    aimbotButton.Text = "АИМБОТ: " .. (VisualEffects.AimbotEnabled and "ВКЛ" or "ВЫКЛ")

    aimbotButton.BackgroundColor3 = VisualEffects.AimbotEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)

end)

yPosition = yPosition + buttonHeight * 1.5

-- Слайдер FOV (теперь в самом низу)

local sliderFrame = Instance.new("Frame")

sliderFrame.Name = "FOVSlider"

sliderFrame.Size = UDim2.new(1, 0, 0, 60)

sliderFrame.Position = UDim2.new(0, 0, yPosition, 0)

sliderFrame.BackgroundTransparency = 1

sliderFrame.Parent = ScrollFrame

local label = Instance.new("TextLabel")

label.Name = "Label"

label.Text = "FOV: " .. VisualEffects.CustomFOV

label.Size = UDim2.new(1, 0, 0, 20)

label.Position = UDim2.new(0, 0, 0, 0)

label.BackgroundTransparency = 1

label.TextColor3 = Color3.fromRGB(200, 200, 200)

label.Font = Enum.Font.Gotham

label.TextSize = 14

label.TextXAlignment = Enum.TextXAlignment.Left

label.Parent = sliderFrame

local sliderBar = Instance.new("Frame")

sliderBar.Name = "SliderBar"

sliderBar.Size = UDim2.new(1, 0, 0, 10)

sliderBar.Position = UDim2.new(0, 0, 0, 30)

sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

sliderBar.Parent = sliderFrame

local sliderFill = Instance.new("Frame")

sliderFill.Name = "SliderFill"

sliderFill.Size = UDim2.new((VisualEffects.CustomFOV - 30) / 90, 0, 1, 0)

sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)

sliderFill.Parent = sliderBar

sliderBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch then

        local absoluteX = input.Position.X

        local sliderAbsoluteX = sliderBar.AbsolutePosition.X

        local sliderWidth = sliderBar.AbsoluteSize.X

        

        local relativeX = math.clamp((absoluteX - sliderAbsoluteX) / sliderWidth, 0, 1)

        local value = math.floor(30 + relativeX * 90)

        

        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)

        label.Text = "FOV: " .. value

        UpdateFOV(value)

    end

end)

-- Обновляем размер прокрутки

ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition * 80)

-- Обработка переподключения персонажа

LocalPlayer.CharacterAdded:Connect(function(newCharacter)

    if VisualEffects.TrailsEnabled then

        CreateTrails(newCharacter:WaitForChild("HumanoidRootPart"))

    end

    if VisualEffects.SnowEnabled then

        CreateSnow()

    end

    if VisualEffects.ESPEnabled then

        ToggleESP() -- Перезагружаем ESP при респавне

    end

end)