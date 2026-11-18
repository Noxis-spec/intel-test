-- ==========================================
-- INTEL TEST - Auto Farm (Safe Platform + Noclip)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- ==========================================
-- НАСТРОЙКИ СЕЙФ-ЗОНЫ (Твои координаты)
-- ==========================================
local SAFE_ZONE_POS = Vector3.new(588.46, 769.85, 144.69)
local noclipEnabled = false
local platform = nil

-- Создаем платформу в воздухе (чтобы было на что встать)
local function createPlatform()
    if platform and platform.Parent then return end
    platform = Instance.new("Part")
    platform.Name = "AutoFarmSafePlatform"
    platform.Size = Vector3.new(20, 1, 20) -- 20х20 юнитов, чтобы точно не упасть
    platform.Position = SAFE_ZONE_POS - Vector3.new(0, 3, 0) -- Чуть ниже точки ТП
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1 -- Невидимая (или поставь 0, если хочешь видеть)
    platform.Material = Enum.Material.SmoothPlastic
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
-- ЛОГИКА NOCLIP (Прохождение сквозь стены)
-- ==========================================
local function toggleNoclip(state)
    noclipEnabled = state
    if state then
        RunService.Stepped:Connect(function()
            if noclipEnabled and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- ==========================================
-- ФУНКЦИЯ ОДНОГО ЦИКЛА
-- ==========================================
local function doOneCycle()
    local blueIntel = getBriefcase("Blue")
    local redIntel = getBriefcase("Red")
    
    if not blueIntel or not redIntel then return false end

    -- 1. ТП к Синему
    teleportTo(blueIntel.Position + Vector3.new(0, 5, 0))
    task.wait(0.6)
    pressE()
    task.wait(0.4)
    
    -- 2. ТП к Красному (сдача)
    teleportTo(redIntel.Position + Vector3.new(0, 2, 0))
    task.wait(1) -- Ждем сдачи
    
    -- 3. ТП на безопасную платформу
    createPlatform() -- Создаем платформу (если ее еще нет)
    teleportTo(SAFE_ZONE_POS)
    task.wait(0.5)
    
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

MainTab:CreateToggle({
    Name = "Enable Noclip (Fly through walls)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(state)
        toggleNoclip(state)
        if state then
            Rayfield:Notify({ Title = "Noclip", Content = "Noclip Enabled", Duration = 2 })
        end
    end,
})

MainTab:CreateButton({
    Name = "Start Auto Farm (3 Cycles)",
    Callback = function()
        task.spawn(function()
            createPlatform() -- Создаем платформу сразу при запуске
            local successCount = 0
            
            for i = 1, 3 do
                Rayfield:Notify({ Title = "Auto Farm", Content = "Cycle " .. i .. " started...", Duration = 2 })
                
                while not getBriefcase("Blue") do
                    task.wait(0.5)
                end
                
                local success = doOneCycle()
                if success then successCount = successCount + 1 end
                
                task.wait(1)
            end
            Rayfield:Notify({ Title = "Auto Farm", Content = "Finished " .. successCount .. "/3 cycles!", Duration = 3 })
        end)
    end,
})

print("[+] INTEL TEST Loaded (Safe Platform + Noclip).")