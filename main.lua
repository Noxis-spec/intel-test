-- ==========================================
-- INTEL TEST - Auto Farm (3 Cycles) with GUI
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ==========================================
-- НАСТРОЙКИ
-- ==========================================
local SAFE_ZONE_POS = Vector3.new(-145.08, 910.79, 20.61) -- Твоя сейф-зона

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

-- Функция одного цикла
local function doOneCycle()
    local blueIntel = getBriefcase("Blue")
    local redIntel = getBriefcase("Red")
    
    if not blueIntel or not redIntel then return false end

    -- 1. ТП к Синему (падаем на него)
    teleportTo(blueIntel.Position + Vector3.new(0, 5, 0))
    task.wait(0.6)
    pressE()
    task.wait(0.4)
    
    -- 2. ТП к Красному (сдача)
    teleportTo(redIntel.Position + Vector3.new(0, 2, 0))
    task.wait(1) -- Ждем 1 секунду для регистрации сдачи
    
    -- 3. ТП в безопасную зону
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

MainTab:CreateButton({
    Name = "Start Auto Farm (3 Cycles)",
    Callback = function()
        task.spawn(function()
            local successCount = 0
            for i = 1, 3 do
                Rayfield:Notify({ Title = "Auto Farm", Content = "Cycle " .. i .. " started...", Duration = 2 })
                
                -- Ждем, пока появится синий кейс
                while not getBriefcase("Blue") do
                    task.wait(0.5)
                end
                
                local success = doOneCycle()
                if success then
                    successCount = successCount + 1
                end
                
                task.wait(1)
            end
            
            Rayfield:Notify({ Title = "Auto Farm", Content = "Finished " .. successCount .. "/3 cycles!", Duration = 3 })
        end)
    end,
})

print("[+] INTEL TEST (Safe Zone added) Loaded.")