-- ==========================================
-- MAP: 2Fort (Day, Night, Wartorn)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Координаты для 2Fort
local SAFE_ZONE_POS = Vector3.new(91.76, 60.05, 36.07) 

-- Создаем невидимый пол
local platform = nil
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

local function doOneCycle()
    local blueIntel = getBriefcase("Blue")
    local redIntel = getBriefcase("Red")
    if not blueIntel or not redIntel then return false end

    teleportTo(blueIntel.Position + Vector3.new(0, 5, 0))
    task.wait(0.6)
    pressE()
    task.wait(0.4)
    
    teleportTo(redIntel.Position + Vector3.new(0, 2, 0))
    task.wait(1)
    
    teleportTo(SAFE_ZONE_POS)
    task.wait(0.5)
    return true
end

local Window = Rayfield:CreateWindow({
    Name = "INTEL: 2Fort",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Noxis",
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateButton({
    Name = "Start Auto Farm (3 Cycles)",
    Callback = function()
        task.spawn(function()
            createFloor()
            local successCount = 0
            for i = 1, 3 do
                Rayfield:Notify({ Title = "2Fort", Content = "Cycle " .. i .. " started...", Duration = 2 })
                while not getBriefcase("Blue") do task.wait(0.5) end
                
                local success = doOneCycle()
                if success then successCount = successCount + 1 end
                task.wait(1)
            end
            Rayfield:Notify({ Title = "2Fort", Content = "Finished " .. successCount .. "/3", Duration = 3 })
        end)
    end,
})

print("[+] Map: 2Fort Loaded.")