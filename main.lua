-- ==========================================
-- INTEL TEST - Auto Farm (Wait for Blue Spawn)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ==========================================
-- НАСТРОЙКИ
-- ==========================================
local SAFE_ZONE_POS = Vector3.new(588.46, 769.85, 144.69)
local platform = nil

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
-- ФУНКЦИЯ ОДНОГО ЦИКЛА
-- ==========================================
local function doOneCycle()
    -- Жесткая проверка: ждем, пока синий кейс появится на карте
    while not getBriefcase("Blue") do
        task.wait(0.5)
    end
    
    -- Как только синий появился, берем координаты обоих
    local blueIntel = getBriefcase("Blue")
    local redIntel = getBriefcase("Red")
    
    -- Если красного почему-то нет (баг игры), ждем
    while not redIntel do
        task.wait(0.5)
        redIntel = getBriefcase("Red")
    end

    -- 1. ТП к Синему
    teleportTo(blueIntel.Position + Vector3.new(0, 5, 0))
    task.wait(0.6)
    pressE()
    task.wait(0.4)
    
    -- 2. ТП к Красному (сдача)
    teleportTo(redIntel.Position + Vector3.new(0, 2, 0))
    task.wait(1.5) -- Даем время на сдачу
    
    -- 3. ТП в сейф-зону
    teleportTo(SAFE_ZONE_POS)
    task.wait(1) 
    
    return true
end

-- ==========================================
-- UI (Rayfield)
-- ==========================================
local Window = Rayfield:CreateWindow({
    Name = "INTEL TEST",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Noxis",
    ConfigurationSaving = { Enabled = true, FolderName = "IntelTest", FileName = "Config" },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateButton({
    Name = "Start Auto Farm (3 Cycles)",
    Callback = function()
        task.spawn(function()
            createFloor() -- Создаем пол перед стартом
            local successCount = 0
            
            for i = 1, 3 do
                Rayfield:Notify({ Title = "Auto Farm", Content = "Waiting for Blue Intel (" .. i .. "/3)...", Duration = 2 })
                
                -- Запускаем цикл (он сам будет ждать появления синего)
                local success = doOneCycle()
                if success then successCount = successCount + 1 end
                
                task.wait(1)
            end
            Rayfield:Notify({ Title = "Auto Farm", Content = "Finished " .. successCount .. "/3 cycles!", Duration = 3 })
        end)
    end,
})

print("[+] INTEL TEST Loaded (Wait for Blue Spawn).")