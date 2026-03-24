-- LOAD UI LIBRARY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Feluan/teste-script/main/hab.lua"))()

-- WINDOW
local Window = Library.CreateLib("Luanzao Hub", "DarkTheme")

-- TABS
local MainTab = Window:NewTab("Main")
local TeleportTab = Window:NewTab("Teleport")
local MiscTab = Window:NewTab("Misc")

-- SECTIONS
local MainSection = MainTab:NewSection("Main Controls")
local TpSection = TeleportTab:NewSection("Teleport System")
local MiscSection = MiscTab:NewSection("Extras")

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer

-- VARIABLES
local targetPositions = {}
local moveSpeed = 50
local isLooping = false
local isRunning = false
local instantTp = false
local delayTime = 1

-- MOVEMENT FUNCTION
local function moveToTarget(index)
    if not isRunning then return end

    local character = lp.Character or lp.CharacterAdded:Wait()

    if not character:FindFirstChild("HumanoidRootPart") then
        task.wait(0.1)
        moveToTarget(index)
        return
    end

    local target = targetPositions[index]
    if not target then return end

    local root = character.HumanoidRootPart
    local cf = CFrame.new(target)

    if instantTp then
        root.CFrame = cf
    else
        local distance = (target - root.Position).Magnitude
        local tweenInfo = TweenInfo.new(distance / moveSpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = cf})
        tween:Play()
        tween.Completed:Wait()
    end

    task.wait(delayTime)

    if index < #targetPositions then
        moveToTarget(index + 1)
    elseif isLooping then
        moveToTarget(1)
    else
        isRunning = false
    end
end

-- MAIN CONTROLS
MainSection:NewButton("Start", "Start moving", function()
    if #targetPositions > 0 then
        isRunning = true
        moveToTarget(1)
    end
end)

MainSection:NewButton("Stop", "Stop movement", function()
    isRunning = false
end)

-- TELEPORT SYSTEM
TpSection:NewButton("Add Position", "Save current position", function()
    local character = lp.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        table.insert(targetPositions, character.HumanoidRootPart.Position)
    end
end)

TpSection:NewButton("Reset Positions", "Clear all", function()
    targetPositions = {}
end)

TpSection:NewSlider("Move Speed", "Speed", 1, 300, function(value)
    moveSpeed = value
end)

TpSection:NewSlider("Delay", "Delay between points", 0, 5, function(value)
    delayTime = value
end)

TpSection:NewToggle("Loop", "Loop positions", function(state)
    isLooping = state
end)

TpSection:NewToggle("Instant TP", "Teleport instantly", function(state)
    instantTp = state
end)

TpSection:NewButton("Copy Positions", "Copy to clipboard", function()
    if #targetPositions > 0 then
        local str = ""
        for _, pos in ipairs(targetPositions) do
            str = str .. string.format("Vector3.new(%f, %f, %f),\n", pos.X, pos.Y, pos.Z)
        end
        setclipboard(str)
    end
end)

TpSection:NewTextBox("Paste Positions", "Paste saved positions", function(text)
    local newPositions = {}
    for line in text:gmatch("[^\r\n]+") do
        local x, y, z = line:match("Vector3.new%((.-), (.-), (.-)%)")
        if x and y and z then
            table.insert(newPositions, Vector3.new(tonumber(x), tonumber(y), tonumber(z)))
        end
    end
    targetPositions = newPositions
end)

-- MISC
MiscSection:NewButton("Anti AFK", "Stay online", function()
    lp.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

MiscSection:NewButton("Rejoin", "Rejoin server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
end)