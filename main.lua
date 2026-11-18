-- ==========================================
-- INTEL TEST - Main Menu (Script Hub)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "INTEL TEST - Map Selector",
    LoadingTitle = "Loading Menu...",
    LoadingSubtitle = "by Noxis",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Maps", 4483362458)

-- Ссылки на скрипты карт (они лежат в папке maps)
local URL_DOUBLECROSS = "https://raw.githubusercontent.com/Noxis-spec/intel-test/main/maps/doublecross.lua"
local URL_2FORT = "https://raw.githubusercontent.com/Noxis-spec/intel-test/main/maps/2fort.lua"

MainTab:CreateButton({
    Name = "Load Doublecross Script",
    Callback = function()
        Rayfield:Notify({ Title = "Loading", Content = "Loading Doublecross...", Duration = 2 })
        task.wait(0.5)
        -- Загружаем скрипт из папки maps
        loadstring(game:HttpGet(URL_DOUBLECROSS))()
    end,
})

MainTab:CreateButton({
    Name = "Load 2Fort Script",
    Callback = function()
        Rayfield:Notify({ Title = "Loading", Content = "Loading 2Fort...", Duration = 2 })
        task.wait(0.5)
        -- Загружаем скрипт из папки maps
        loadstring(game:HttpGet(URL_2FORT))()
    end,
})

print("[+] Main Menu Loaded.")