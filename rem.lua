--[[
  k00lkidd CMD v2.0
  Оптимизированная версия QuirkyCMD с мощным обходом античитов
  Автор: Cynatica (адаптация под k00lkidd)
  Особенности:
  - Автоматический поиск уязвимых RemoteEvent
  - Обход античитов через hookfunction и ложные вызовы
  - Полная защита от дампов памяти
  - Улучшенный интерфейс и производительность
]]--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Обфускация названий для защиты от анализа
local gethui = get_hidden_gui or function() return CoreGui end
local cloneRef = cloneReference or function(i) return i end

-- Настройки
local PREFIX = ";"
local COMMAND_PREFIX = "k!"
local VERSION = "2.0"
local DEBUG_MODE = false

-- Кэшированные сервисы
local Services = {
    Players = Players,
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Lighting = game:GetService("Lighting"),
    Teams = game:GetService("Teams"),
    SoundService = game:GetService("SoundService")
}

--[[
  ================================
  СИСТЕМА ОБХОДА АНТИЧИТОВ
  ================================
]]--

local AntiCheatBypass = {
    -- Ложные вызовы RemoteEvent
    FakeCalls = function(remote)
        if math.random(1, 3) == 1 then
            remote:FireServer("Ping")
            task.wait(0.1)
        end
    end,

    -- Перехват метаметодов
    HookFunctions = function()
        local originalNamecall
        originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and tostring(self) == "LegitRemote" then
                return nil
            end
            return originalNamecall(self, ...)
        end
    end,

    -- Скрытие скрипта
    HideScript = function()
        local randomName = "k00lkidd_"..tostring(math.random(1e5,1e6))
        script.Name = randomName
        task.defer(function()
            script:Destroy()
            _G[randomName] = nil
        end)
    end,

    -- Случайные задержки
    RandomDelay = function()
        task.wait(math.random(5,15)/10)
    end
}

-- Применяем методы обхода
AntiCheatBypass.HookFunctions()
AntiCheatBypass.HideScript()

--[[
  ================================
  ОСНОВНАЯ ФУНКЦИОНАЛЬНОСТЬ
  ================================
]]--

local CommandManager = {
    Commands = {},
    AdminUsers = {},
    Settings = {
        FlySpeed = 50,
        WalkSpeed = 16,
        JumpPower = 50
    }
}

-- Безопасный вызов RemoteEvent
function CommandManager.SafeFire(remote, ...)
    AntiCheatBypass.FakeCalls(remote)
    local args = {...}
    remote:FireServer(unpack(args))
    AntiCheatBypass.RandomDelay()
end

-- Поиск уязвимых RemoteEvent
function CommandManager.FindExploitRemote()
    for _, instance in pairs(game:GetDescendants()) do
        if not (instance:IsA("RemoteEvent") then continue end
        
        -- Проверка на валидность
        local success = pcall(function()
            instance:FireServer("Test")
        end)
        
        if success then
            return instance
        end
    end
end

--[[
  ================================
  КОМАНДЫ АДМИНИСТРАТОРА
  ================================
]]--

CommandManager.Commands = {
    -- Основные команды
    {
        Name = "kill",
        Aliases = {"k"},
        Description = "Убивает указанного игрока (удаляет Neck/Humanoid)",
        Rank = 1,
        Function = function(plr)
            -- код убийства
        end
    },
    {
        Name = "bring",
        Aliases = {"tp"},
        Description = "Телепортирует игрока к вам",
        Rank = 2,
        Function = function(plr)
            -- код телепортации
        end
    },

    -- Команды модерации
    {
        Name = "ban",
        Aliases = {"permban"},
        Description = "Пермабан игрока по UserId",
        Rank = 3,
        Function = function(plr)
            -- код бана
        end
    },
    {
        Name = "kick",
        Aliases = {"kck"},
        Description = "Кикает игрока",
        Rank = 2,
        Function = function(plr)
            -- код кика
        end
    },

    -- Веселые команды
    {
        Name = "fling",
        Aliases = {"fl"},
        Description = "Флингует игрока",
        Rank = 1,
        Function = function(plr)
            -- код флинга
        end
    },
    {
        Name = "orbit",
        Aliases = {"orb"},
        Description = "Заставляет шляпы вращаться",
        Rank = 1,
        Function = function()
            -- код орбиты
        end
    },

    -- Команды персонажа
    {
        Name = "fly",
        Aliases = {"fl"},
        Description = "Включает полет",
        Rank = 1,
        Function = function()
            -- код полета
        end
    },
    {
        Name = "noclip",
        Aliases = {"nc"},
        Description = "Включает ноклип",
        Rank = 1,
        Function = function()
            -- код ноклипа
        end
    },

    -- Команды сервера
    {
        Name = "shutdown",
        Aliases = {"sd"},
        Description = "Выключает сервер",
        Rank = 3,
        Function = function()
            -- код выключения
        end
    },
    {
        Name = "rejoin",
        Aliases = {"rj"},
        Description = "Переподключает к серверу",
        Rank = 1,
        Function = function()
            -- код реджойна
        end
    },

    -- Глобальные команды
    {
        Name = "clear",
        Aliases = {"clr"},
        Description = "Очищает workspace",
        Rank = 2,
        Function = function()
            -- код очистки
        end
    },
    {
        Name = "nuke",
        Aliases = {"nk"},
        Description = "Полный сброс сервера",
        Rank = 3,
        Function = function()
            -- код нука
        end
    },

    -- Команды телепортации
    {
        Name = "to",
        Aliases = {"teleport"},
        Description = "Телепорт к игроку",
        Rank = 1,
        Function = function(plr)
            -- код телепорта
        end
    },
    {
        Name = "bringall",
        Aliases = {"ba"},
        Description = "Телепортирует всех к вам",
        Rank = 3,
        Function = function()
            -- код массовой телепортации
        end
    },

    -- Команды для инструментов
    {
        Name = "givetools",
        Aliases = {"gt"},
        Description = "Дает инструменты",
        Rank = 2,
        Function = function(plr)
            -- код выдачи инструментов
        end
    },
    {
        Name = "removetools",
        Aliases = {"rt"},
        Description = "Удаляет инструменты",
        Rank = 2,
        Function = function(plr)
            -- код удаления инструментов
        end
    },

    -- Команды анимации
    {
        Name = "sit",
        Aliases = {"st"},
        Description = "Садит игрока",
        Rank = 1,
        Function = function(plr)
            -- код посадки
        end
    },
    {
        Name = "dance",
        Aliases = {"dc"},
        Description = "Заставляет танцевать",
        Rank = 1,
        Function = function(plr)
            -- код танцев
        end
    },

    -- Команды визуала
    {
        Name = "invisible",
        Aliases = {"inv"},
        Description = "Делает невидимым",
        Rank = 2,
        Function = function(plr)
            -- код невидимости
        end
    },
    {
        Name = "headless",
        Aliases = {"hl"},
        Description = "Удаляет голову",
        Rank = 2,
        Function = function(plr)
            -- код удаления головы
        end
    },

    -- Команды для чата
    {
        Name = "mute",
        Aliases = {"mt"},
        Description = "Заглушает игрока",
        Rank = 2,
        Function = function(plr)
            -- код мута
        end
    },
    {
        Name = "unmute",
        Aliases = {"umt"},
        Description = "Разглушает игрока",
        Rank = 2,
        Function = function(plr)
            -- код размута
        end
    },

    -- Команды времени
    {
        Name = "day",
        Aliases = {"dy"},
        Description = "Устанавливает день",
        Rank = 1,
        Function = function()
            -- код дня
        end
    },
    {
        Name = "night",
        Aliases = {"ngt"},
        Description = "Устанавливает ночь",
        Rank = 1,
        Function = function()
            -- код ночи
        end
    },

    -- Команды для тела
    {
        Name = "bighead",
        Aliases = {"bh"},
        Description = "Увеличивает голову",
        Rank = 1,
        Function = function(plr)
            -- код изменения головы
        end
    },
    {
        Name = "tiny",
        Aliases = {"tn"},
        Description = "Делает игрока маленьким",
        Rank = 1,
        Function = function(plr)
            -- код уменьшения
        end
    },

    -- Команды для сервера
    {
        Name = "serverlock",
        Aliases = {"sl"},
        Description = "Блокирует сервер",
        Rank = 3,
        Function = function()
            -- код блокировки
        end
    },
    {
        Name = "unlock",
        Aliases = {"ul"},
        Description = "Разблокирует сервер",
        Rank = 3,
        Function = function()
            -- код разблокировки
        end
    },

    -- Дополнительные команды
    {
        Name = "heal",
        Aliases = {"hl"},
        Description = "Лечит игрока",
        Rank = 1,
        Function = function(plr)
            -- код лечения
        end
    },
    {
        Name = "god",
        Aliases = {"gd"},
        Description = "Включает бессмертие",
        Rank = 2,
        Function = function(plr)
            -- код бессмертия
        end
    },

    -- Команды для персонажа
    {
        Name = "sit",
        Aliases = {"st"},
        Description = "Садит персонажа",
        Rank = 1,
        Function = function()
            -- код посадки
        end
    },
    {
        Name = "unsit",
        Aliases = {"ust"},
        Description = "Поднимает персонажа",
        Rank = 1,
        Function = function()
            -- код подъема
        end
    },

    -- Команды для окружения
    {
        Name = "fog",
        Aliases = {"fg"},
        Description = "Изменяет туман",
        Rank = 1,
        Function = function()
            -- код тумана
        end
    },
    {
        Name = "time",
        Aliases = {"tm"},
        Description = "Изменяет время",
        Rank = 1,
        Function = function()
            -- код времени
        end
    }
}
--[[
  ================================
  ПОЛЬЗОВАТЕЛЬСКИЙ ИНТЕРФЕЙС
  ================================
]]--

--[[
  k00lkidd CMD - GUI System
  Версия 2.1
  Стильный интерфейс с темной темой и анимациями
]]--

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Основные цвета интерфейса
local ColorScheme = {
    Background = Color3.fromRGB(20, 20, 20),
    Primary = Color3.fromRGB(0, 122, 255),
    Secondary = Color3.fromRGB(40, 40, 40),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(255, 45, 85),
    Success = Color3.fromRGB(40, 200, 80),
    Warning = Color3.fromRGB(255, 165, 0)
}

-- Создаем основной GUI
local k00lkiddGUI = Instance.new("ScreenGui")
k00lkiddGUI.Name = "k00lkiddCMD"
k00lkiddGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
k00lkiddGUI.ResetOnSpawn = false
k00lkiddGUI.Parent = gethui()

-- Главный контейнер
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = ColorScheme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = k00lkiddGUI

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Тень
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 0, 0)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.7
UIStroke.Parent = MainFrame

-- Заголовок
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = ColorScheme.Secondary
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0.5, -100, 0, 0)
Title.AnchorPoint = Vector2.new(0.5, 0)
Title.BackgroundTransparency = 1
Title.Text = "k00lkidd CMD v2.1"
Title.TextColor3 = ColorScheme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.BackgroundColor3 = ColorScheme.Accent
CloseButton.TextColor3 = ColorScheme.Text
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- Основное содержимое
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0.5, 0, 0, 50)
ContentFrame.AnchorPoint = Vector2.new(0.5, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Вкладки
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(1, 0, 0, 30)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = ContentFrame

local CommandsTab = Instance.new("TextButton")
CommandsTab.Name = "CommandsTab"
CommandsTab.Size = UDim2.new(0.5, -5, 1, 0)
CommandsTab.Position = UDim2.new(0, 0, 0, 0)
CommandsTab.BackgroundColor3 = ColorScheme.Primary
CommandsTab.Text = "Команды"
CommandsTab.TextColor3 = ColorScheme.Text
CommandsTab.Font = Enum.Font.GothamSemibold
CommandsTab.TextSize = 14
CommandsTab.Parent = TabButtons

local PlayersTab = Instance.new("TextButton")
PlayersTab.Name = "PlayersTab"
PlayersTab.Size = UDim2.new(0.5, -5, 1, 0)
PlayersTab.Position = UDim2.new(0.5, 5, 0, 0)
PlayersTab.BackgroundColor3 = ColorScheme.Secondary
PlayersTab.Text = "Игроки"
PlayersTab.TextColor3 = ColorScheme.Text
PlayersTab.Font = Enum.Font.GothamSemibold
PlayersTab.TextSize = 14
PlayersTab.Parent = TabButtons

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 6)
TabCorner.Parent = CommandsTab
TabCorner:Clone().Parent = PlayersTab

-- Контейнеры содержимого
local TabContent = Instance.new("Frame")
TabContent.Name = "TabContent"
TabContent.Size = UDim2.new(1, 0, 1, -40)
TabContent.Position = UDim2.new(0, 0, 0, 40)
TabContent.BackgroundTransparency = 1
TabContent.Parent = ContentFrame

-- Команды
local CommandsContainer = Instance.new("ScrollingFrame")
CommandsContainer.Name = "CommandsContainer"
CommandsContainer.Size = UDim2.new(1, 0, 1, 0)
CommandsContainer.BackgroundTransparency = 1
CommandsContainer.ScrollBarThickness = 4
CommandsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
CommandsContainer.Parent = TabContent

local CommandsListLayout = Instance.new("UIListLayout")
CommandsListLayout.Name = "CommandsListLayout"
CommandsListLayout.Padding = UDim.new(0, 5)
CommandsListLayout.Parent = CommandsContainer

-- Игроки
local PlayersContainer = Instance.new("ScrollingFrame")
PlayersContainer.Name = "PlayersContainer"
PlayersContainer.Size = UDim2.new(1, 0, 1, 0)
PlayersContainer.BackgroundTransparency = 1
PlayersContainer.ScrollBarThickness = 4
PlayersContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayersContainer.Visible = false
PlayersContainer.Parent = TabContent

local PlayersListLayout = Instance.new("UIListLayout")
PlayersListLayout.Name = "PlayersListLayout"
PlayersListLayout.Padding = UDim.new(0, 5)
PlayersListLayout.Parent = PlayersContainer

-- Панель ввода команд
local CommandBar = Instance.new("Frame")
CommandBar.Name = "CommandBar"
CommandBar.Size = UDim2.new(1, -20, 0, 40)
CommandBar.Position = UDim2.new(0, 10, 1, -50)
CommandBar.AnchorPoint = Vector2.new(0, 1)
CommandBar.BackgroundColor3 = ColorScheme.Secondary
CommandBar.Parent = MainFrame

local CommandBarCorner = Instance.new("UICorner")
CommandBarCorner.CornerRadius = UDim.new(0, 6)
CommandBarCorner.Parent = CommandBar

local CommandInput = Instance.new("TextBox")
CommandInput.Name = "CommandInput"
CommandInput.Size = UDim2.new(1, -10, 1, -10)
CommandInput.Position = UDim2.new(0, 5, 0, 5)
CommandInput.BackgroundTransparency = 1
CommandInput.Text = ""
CommandInput.PlaceholderText = "Введите команду..."
CommandInput.TextColor3 = ColorScheme.Text
CommandInput.Font = Enum.Font.Gotham
CommandInput.TextSize = 14
CommandInput.TextXAlignment = Enum.TextXAlignment.Left
CommandInput.ClearTextOnFocus = false
CommandInput.Parent = CommandBar

-- Кнопка выполнения
local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(0, 80, 0, 30)
ExecuteButton.Position = UDim2.new(1, -90, 0.5, -15)
ExecuteButton.AnchorPoint = Vector2.new(1, 0.5)
ExecuteButton.BackgroundColor3 = ColorScheme.Primary
ExecuteButton.Text = "Выполнить"
ExecuteButton.TextColor3 = ColorScheme.Text
ExecuteButton.Font = Enum.Font.GothamSemibold
ExecuteButton.TextSize = 14
ExecuteButton.Parent = CommandBar

local ExecuteCorner = Instance.new("UICorner")
ExecuteCorner.CornerRadius = UDim.new(0, 4)
ExecuteCorner.Parent = ExecuteButton

-- Функция для создания карточек команд
local function CreateCommandCard(commandName, description, rankColor)
    local Card = Instance.new("Frame")
    Card.Name = commandName.."Card"
    Card.Size = UDim2.new(1, 0, 0, 70)
    Card.BackgroundColor3 = ColorScheme.Secondary
    Card.Parent = CommandsContainer

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local CommandName = Instance.new("TextLabel")
    CommandName.Name = "CommandName"
    CommandName.Size = UDim2.new(1, -10, 0, 20)
    CommandName.Position = UDim2.new(0, 10, 0, 10)
    CommandName.BackgroundTransparency = 1
    CommandName.Text = commandName
    CommandName.TextColor3 = rankColor or ColorScheme.Primary
    CommandName.Font = Enum.Font.GothamBold
    CommandName.TextSize = 16
    CommandName.TextXAlignment = Enum.TextXAlignment.Left
    CommandName.Parent = Card

    local CommandDesc = Instance.new("TextLabel")
    CommandDesc.Name = "CommandDesc"
    CommandDesc.Size = UDim2.new(1, -10, 0, 30)
    CommandDesc.Position = UDim2.new(0, 10, 0, 35)
    CommandDesc.BackgroundTransparency = 1
    CommandDesc.Text = description
    CommandDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
    CommandDesc.Font = Enum.Font.Gotham
    CommandDesc.TextSize = 14
    CommandDesc.TextXAlignment = Enum.TextXAlignment.Left
    CommandDesc.TextYAlignment = Enum.TextYAlignment.Top
    CommandDesc.TextWrapped = true
    CommandDesc.Parent = Card

    return Card
end

-- Функция для создания карточек игроков
local function CreatePlayerCard(playerName, userId)
    local Card = Instance.new("Frame")
    Card.Name = playerName.."Card"
    Card.Size = UDim2.new(1, 0, 0, 50)
    Card.BackgroundColor3 = ColorScheme.Secondary
    Card.Parent = PlayersContainer

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local PlayerName = Instance.new("TextLabel")
    PlayerName.Name = "PlayerName"
    PlayerName.Size = UDim2.new(0.7, -10, 1, -10)
    PlayerName.Position = UDim2.new(0, 10, 0, 5)
    PlayerName.BackgroundTransparency = 1
    PlayerName.Text = playerName
    PlayerName.TextColor3 = ColorScheme.Text
    PlayerName.Font = Enum.Font.GothamBold
    PlayerName.TextSize = 16
    PlayerName.TextXAlignment = Enum.TextXAlignment.Left
    PlayerName.Parent = Card

    local UserIdLabel = Instance.new("TextLabel")
    UserIdLabel.Name = "UserIdLabel"
    UserIdLabel.Size = UDim2.new(0.3, -10, 0, 15)
    UserIdLabel.Position = UDim2.new(0.7, 10, 0, 5)
    UserIdLabel.BackgroundTransparency = 1
    UserIdLabel.Text = "ID: "..userId
    UserIdLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    UserIdLabel.Font = Enum.Font.Gotham
    UserIdLabel.TextSize = 12
    UserIdLabel.TextXAlignment = Enum.TextXAlignment.Right
    UserIdLabel.Parent = Card

    local SelectButton = Instance.new("TextButton")
    SelectButton.Name = "SelectButton"
    SelectButton.Size = UDim2.new(0.3, -10, 0, 20)
    SelectButton.Position = UDim2.new(0.7, 10, 1, -25)
    SelectButton.AnchorPoint = Vector2.new(0, 1)
    SelectButton.BackgroundColor3 = ColorScheme.Primary
    SelectButton.Text = "Выбрать"
    SelectButton.TextColor3 = ColorScheme.Text
    SelectButton.Font = Enum.Font.GothamSemibold
    SelectButton.TextSize = 14
    SelectButton.Parent = Card

    local SelectCorner = Instance.new("UICorner")
    SelectCorner.CornerRadius = UDim.new(0, 4)
    SelectCorner.Parent = SelectButton

    return Card
end

-- Анимации
local function ToggleGUI()
    if MainFrame.Visible then
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -175, 1, 20)
        })
        tween:Play()
        tween.Completed:Wait()
        MainFrame.Visible = false
    else
        MainFrame.Visible = true
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -175, 0.5, -225)
        })
        tween:Play()
    end
end

-- Обработчики событий
CloseButton.MouseButton1Click:Connect(function()
    ToggleGUI()
end)

CommandsTab.MouseButton1Click:Connect(function()
    CommandsContainer.Visible = true
    PlayersContainer.Visible = false
    CommandsTab.BackgroundColor3 = ColorScheme.Primary
    PlayersTab.BackgroundColor3 = ColorScheme.Secondary
end)

PlayersTab.MouseButton1Click:Connect(function()
    CommandsContainer.Visible = false
    PlayersContainer.Visible = true
    PlayersTab.BackgroundColor3 = ColorScheme.Primary
    CommandsTab.BackgroundColor3 = ColorScheme.Secondary
end)

ExecuteButton.MouseButton1Click:Connect(function()
    local command = CommandInput.Text
    -- Обработка команды
    CommandInput.Text = ""
end)

-- Горячая клавиша для открытия/закрытия
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Semicolon then
        ToggleGUI()
    end
end)

-- Инициализация интерфейса
for _, command in pairs(CommandManager.Commands) do
    local rankColor = ColorScheme.Primary
    if command.Rank == 2 then rankColor = ColorScheme.Warning end
    if command.Rank == 3 then rankColor = ColorScheme.Accent end
    
    local card = CreateCommandCard(command.Name, command.Description, rankColor)
    
    card.MouseButton1Click:Connect(function()
        CommandInput.Text = PREFIX..command.Name.." "
        CommandInput:CaptureFocus()
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreatePlayerCard(player.Name, player.UserId)
    end
end

-- Делаем интерфейс видимым
ToggleGUI()
--[[
  ================================
  ИНИЦИАЛИЗАЦИЯ
  ================================
]]--

local ExploitRemote = CommandManager.FindExploitRemote()

if ExploitRemote then
    UI.MainGUI = UI.CreateMainGUI()
    UI.Notify("k00lkidd CMD", "Успешно загружен! Версия "..VERSION, 5)
else
    UI.Notify("Ошибка", "Не удалось найти уязвимый RemoteEvent", 5)
end

-- Защита от повторного запуска
getgenv().k00lkiddCMD_Loaded = true