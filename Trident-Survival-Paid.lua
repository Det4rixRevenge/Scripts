-- Modules
loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Trident-survival-stuff/refs/heads/main/Modules%20v2",true))()
local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
--
local window = DrRayLibrary:Load("defensow.xyz|PAID", "Default")
--
local tab = DrRayLibrary.newTab("⚔️Combat⚔️", "ImageIdHere")
-- Silent Aim
tab.newButton("Silent aim", "", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Ak.lol/refs/heads/main/Loadstring%20obfuscated",true))()
  end)
  -- Hitbox
tab.newButton("hitbox", "", function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Trident-survival-stuff/refs/heads/main/Hitbox",true))()
end)
--
local tab = DrRayLibrary.newTab("👀Visuals 1👀", "ImageIdHere")
-- Esp
tab.newButton("Esp", "", function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Trident-survival-stuff/refs/heads/main/Esp",true))()
end)
-- Chams
tab.newButton("chams", "", function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Trident-survival-stuff/refs/heads/main/Esp%20chams",true))()
end)
  -- Ambient
  tab.newButton("Full bright", "", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Trident-survival-stuff/refs/heads/main/Ambient%20v2",true))()
  end)
  -- 120 Fov changer
tab.newButton("120 fov", "", function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Trident-survival-stuff/refs/heads/main/120%20fov%20v2",true))()
end)
  -- Arms changer
  tab.newButton("Arms changer", "", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Trident-survival-stuff/refs/heads/main/Arms%20Colour%20changer%20v2",true))()
  end)
  local tab = DrRayLibrary.newTab("👀Visuals 2👀", "ImageIdHere")
-- crosshair
  tab.newButton("crosshair", "", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/milo22-ux/Trident-survival-stuff/refs/heads/main/Cross%20hair",true))()
  end)
  local tab = DrRayLibrary.newTab("Extra 1", "ImageIdHere")
--
local ScreenGui = Instance.new("ScreenGui")
local AutoRunButton = Instance.new("TextButton")
local Frame = Instance.new("Frame")
--
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "AutoRunGui"
--
Frame.Size = UDim2.new(0, 100, 0, 80)
Frame.Position = UDim2.new(0, 10, 1, -150)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
--
AutoRunButton.Size = UDim2.new(1, 0, 1, 0)
AutoRunButton.Text = "Auto slide jump run"
AutoRunButton.Parent = Frame
AutoRunButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AutoRunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoRunButton.BorderSizePixel = 0
--
Frame.Visible = false
--
tab.newToggle("Slide Jump Toggle", "Toggle slide jump UI", true, function(toggleState)
    Frame.Visible = toggleState
end)

local isAutoRunning = false
local stopAutoRun = false
--
local function AutoRunAndJumpCrouch()
    while isAutoRunning do
        if stopAutoRun then break end
        keypress(0x57)
        keypress(0x10)
        task.wait(0.05)
        keypress(0x43)
        keypress(0x20)
        keyrelease(0x20)
        task.wait(0.5)
        keyrelease(0x43)
        keyrelease(0x10)
        wait(1.2)
    end
end
--
AutoRunButton.MouseButton1Click:Connect(function()
    if not isAutoRunning then
        isAutoRunning = true
        stopAutoRun = false
        AutoRunButton.Text = "Stop slide jump run"
        task.spawn(AutoRunAndJumpCrouch)
    else
        isAutoRunning = false
        stopAutoRun = true
        keyrelease(0x57)
        keyrelease(0x10)
        keyrelease(0x43)
        AutoRunButton.Text = "Auto slide jump run"
    end
end)
--
local function createDraggableButton(name, position, callback)
    local gui = Instance.new("ScreenGui")
    local button = Instance.new("TextButton")
    local dragging, dragInput, dragStart, startPos
--
    gui.Parent = game.CoreGui
    gui.Name = name .. "Gui"
    gui.ResetOnSpawn = false
--
    button.Parent = gui
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = name
    button.Visible = false
--
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
--
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
--
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
--
    button.MouseButton1Click:Connect(callback)
--
    return button
end
--
local lootButton = createDraggableButton("Loot All", UDim2.new(0, 100, 1, -100), function()
    for i = 1, 20 do
        game:GetService("Players").LocalPlayer.RemoteEvent:FireServer(12, i, true)
        wait(0.03)
    end
end)
--
tab.newToggle("Loot All Toggle", "Show/hide Loot All button", false, function(toggleState)
    lootButton.Visible = toggleState
end)
--
local depositButton = createDraggableButton("Deposit All", UDim2.new(0, 210, 1, -100), function()
    for i = 1, 20 do
        game:GetService("Players").LocalPlayer.RemoteEvent:FireServer(12, i, false)
        wait(0.03)
    end
end)
--
tab.newToggle("Deposit All Toggle", "Show/hide Deposit All button", false, function(toggleState)
    depositButton.Visible = toggleState
end)
--
local tab = DrRayLibrary.newTab("Extra 2", "ImageIdHere")
--
local position = "down"
local hopping = false
--
_G.speedy = false
_G.speed = 10
_G.speedy_k = true
local speedhack = false
-- 
tab.newToggle("Slide Speed", "Toggle slide speed", false, function(toggleState)
    speedhack = toggleState
end)
--
tab.newSlider("Speed", "Set slide speed", 12, false, function(value)
    _G.speed = value
end)
--
game:GetService("UserInputService").InputBegan:Connect(function(input, g)
    if input.KeyCode == Enum.KeyCode.U and not g then
        _G.h_press = not _G.h_press
        _G.speedy_k = not _G.h_press
    end
end)
--
game:GetService("UserInputService").InputBegan:Connect(function(input, g)
    if input.KeyCode == Enum.KeyCode.C and _G.speedy_k and not g then
        _G.speedy = true
    end
end)
--
game:GetService("UserInputService").InputEnded:Connect(function(input, g)
    if input.KeyCode == Enum.KeyCode.C and not g then
        _G.speedy = false
    end
end)
--
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.speedy and speedhack then
        for _, v in pairs(game.Workspace.Ignore.LocalCharacter:GetChildren()) do
            v.Velocity = v.Velocity + workspace.Camera.CFrame.LookVector * _G.speed
        end
    end
end)
--
game:GetService("RunService").RenderStepped:Connect(function()
    local character = workspace.Ignore.LocalCharacter
    local middle = character.Middle
    local ray_origin = middle.Position
    local ray_direction = character.Bottom.CFrame.LookVector.Unit * 3 + Vector3.new(0, -2, 0)
    local raycast_params = RaycastParams.new()
    raycast_params.FilterType = Enum.RaycastFilterType.Blacklist
    raycast_params.FilterDescendantsInstances = {character}
    local ray_result = workspace:Raycast(ray_origin, ray_direction, raycast_params)
    if not ray_result and speedhack then
        if middle.LinearVelocity.MaxAxesForce == Vector3.new(0, 0, 0) and middle.Velocity.Y <= 0.2 then
            if not hopping then
                hopping = true
                speedy_k = true
                position = "up"
                task.wait(0.15)
                position = "down"
                speedy_k = false
                task.wait(0.09)
                hopping = false
            end
        end
    end
end)
--
local check = {}
game:GetService("RunService").Heartbeat:Connect(function()
    if speedy_k == true and speedhack then
        local character = game.Workspace.Ignore.LocalCharacter
        local middle = character.Middle
        check[1] = middle.CFrame
        local spoof_this = middle.CFrame
--
        if position == "up" then
            spoof_this = spoof_this + Vector3.new(0, 5, 0)
        end
--
        middle.CFrame = spoof_this
        game:GetService("RunService").RenderStepped:Wait()
        middle.CFrame = check[1]
    end
end)
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoKeyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui
--
local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.Size = UDim2.new(0, 160, 0, 50)
button.Position = UDim2.new(0, 20, 0, 20)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 20
button.Text = "Hold W + C"
button.Visible = false
button.Parent = screenGui
--
local autoHold = false
--
button.MouseButton1Click:Connect(function()
    autoHold = not autoHold
    if autoHold then
        button.Text = "Release W + C"
        button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    else
        button.Text = "Hold W + C"
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    end
end)
--
tab.newToggle("Auto Hold Button", "Toggle GUI for holding W + C", false, function(toggleState)
    button.Visible = toggleState
end)
