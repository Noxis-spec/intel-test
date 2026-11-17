-- ==========================================
-- INTEL TEST - Rayfield Library
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local Window = Rayfield:CreateWindow({
    Name = "INTEL TEST",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Noxis",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "IntelTest",
        FileName = "Config"
    },
    KeySystem = false
})

-- ==========================================
-- ВКЛАДКА "MAIN"
-- ==========================================
local MainTab = Window:CreateTab("Main", 4483362458)

-- Функция, которую будет вызывать кнопка
local function testIntelFunction()
    -- Тут ты можешь написать любой тестовый код.
    -- Пока что она просто ищет кейс Blue и телепортирует к нему.
    
    local map = Workspace:FindFirstChild("Map")
    local briefcases = map and map:FindFirstChild("Briefcases")
    local intel = briefcases and briefcases:FindFirstChild("Blue")
    
    if intel then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(intel.Position + Vector3.new(0, 3, 0))
            Rayfield:Notify({
                Title = "Success",
                Content = "Teleported to Blue Intel",
                Duration = 3,
                Image = 4483362458,
            })
        end
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "Intel not found on map!",
            Duration = 3,
            Image = 4483362458,
        })
    end
end

-- Сама кнопка
MainTab:CreateButton({
    Name = "Test Intel (Teleport to Blue)",
    Callback = function()
        testIntelFunction()
    end,
})

print("[+] Intel Test Loaded.")