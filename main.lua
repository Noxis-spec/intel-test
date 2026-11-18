-- ==========================================
-- INTEL TEST - Auto Farm (Smart Map Detection)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ==========================================
-- ТАБЛИЦА СЕЙФ-ЗОН
-- ==========================================
local SAFE_ZONES = {
    -- Doublecross (День и Ночь)
    ["ctf_doublecrossday"] = Vector3.new(-145.08, 910.79, 20.61),
    ["ctf_doublecross"] = Vector3.new(-145.08, 910.79, 20.61),
    
    -- 2Fort (Обычный, Ночь, Разрушенный)
    ["ctf_2fort"] = Vector3.new(91.76, 60.05, 36.07),
    ["ctf_2fortnight"] = Vector3.new(91.76, 60.05, 36.07),
    ["ctf_wartorn2fort"] = Vector3.new(91.76, 60.05, 36.07),
}

-- ==========================================
-- УМНОЕ ОПРЕДЕЛЕНИЕ КАРТЫ
-- ==========================================
local function getCurrentMapName()
    -- Сканируем ВСЁ, что есть в Workspace, чтобы найти название карты
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("ctf_") or name:find("pl_") or name:find("cp_") or name:find("koth_") then
            return obj.Name 
        end
    end
    return "unknown"
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
    task.wait(1)
    
    -- 3. ТП в безопасную зону
    local currentMap = getCurrentMapName()
    local safePos = SAFE_ZONES[currentMap]
    
    if safePos then
        teleportTo(safePos)
    else
        teleportTo(Vector3.new(0, 50, 0)) 
        Rayfield:Notify({ Title = "Warning", Content = "No safe zone for map: " .. currentMap, Duration = 3 })
    end
    
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
            local currentMap = getCurrentMapName()
            
            -- Показываем, какую карту нашел скрипт
            Rayfield:Notify({ Title = "Map Detected", Content = currentMap, Duration = 5 })

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

print("[+] INTEL TEST Loaded. Map detection is now aggressive.")