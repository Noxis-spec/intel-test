-- ==========================================
-- INTEL TEST - Simple Button (Timer TP)
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- ==========================================
-- НАСТРОЙКИ
-- ==========================================
local SAFE_ZONE_POS = Vector3.new(588.46, 769.85, 144.69)
local TP_DELAY = 10 -- Раз в 10 секунд возвращать в сейф (поставь 60, если хочешь минуту)
local platform = nil
local isFarming = false
local lastTPTime = 0

-- Создаем невидимый пол
local function createFloor()
    if platform and platform.Parent then return end
    platform = Instance.new("Part")
    platform.Name = "SafeZoneFloor"
    platform.Size = Vector3.new(20, 1, 20) 
    platform.Position = SAFE_ZONE_POS - Vector3.new(0, 3, 0)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Parent = Workspace
end

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function getBriefcase(name)
    local map = Workspace:FindFirstChild("Map")
    local briefcases = map and map:FindFirstChild("Briefcases")
    return briefcases and briefcases:FindFirstChild(name)
end

local function pressE()
    VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, "E", false, game)
end

-- ==========================================
-- ЛОГИКА ЦИКЛА
-- ==========================================
local function doOneCycle()
    local blueIntel = getBriefcase("Blue")
    local redIntel = getBriefcase("Red")
    if not blueIntel or not redIntel then return false end

    -- 1. ТП к синему
    teleportTo(blueIntel.Position + Vector3.new(0, 5, 0))
    task.wait(0.8)
    pressE()
    task.wait(0.8)
    
    -- 2. ТП к красному (сдача)
    teleportTo(redIntel.Position + Vector3.new(0, 2, 0))
    task.wait(1.5)
    
    -- 3. СРАЗУ ТП В СЕЙФ
    teleportTo(SAFE_ZONE_POS)
    task.wait(0.5)
    return true
end

-- ==========================================
-- ТАЙМЕР (Раз в 10 сек - ТП в сейф)
-- ==========================================
RunService.Heartbeat:Connect(function()
    if isFarming then
        local currentTime = tick()
        if currentTime - lastTPTime >= TP_DELAY then
            -- Время вышло, принудительно тп в сейф
            teleportTo(SAFE_ZONE_POS)
            lastTPTime = currentTime
        end
    end
end)

-- ==========================================
-- ПРОСТОЕ МЕНЮ
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IntelMenu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 150, 0, 50)
Button.Position = UDim2.new(0, 20, 0, 100)
Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Button.Text = "START FARM"
Button.TextColor3 = Color3.fromRGB(0, 255, 0)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 16
Button.Parent = ScreenGui
Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

Button.MouseButton1Click:Connect(function()
    if isFarming then
        -- Остановка
        isFarming = false
        Button.Text = "START FARM"
        Button.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        -- Запуск
        isFarming = true
        Button.Text = "STOP FARM"
        Button.TextColor3 = Color3.fromRGB(255, 50, 50)
        lastTPTime = tick() -- Сбрасываем таймер
        
        task.spawn(function()
            createFloor()
            local successCount = 0
            
            for i = 1, 3 do
                while not getBriefcase("Blue") do
                    task.wait(0.5)
                end
                
                local success = doOneCycle()
                if success then successCount = successCount + 1 end
                task.wait(1)
            end
            
            -- По окончании 3 циклов останавливаем
            isFarming = false
            Button.Text = "START FARM"
            Button.TextColor3 = Color3.fromRGB(0, 255, 0)
        end)
    end
end)

print("[+] INTEL TEST (Timer TP) Loaded.")