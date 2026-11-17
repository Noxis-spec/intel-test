-- ==========================================
-- БАЗОВЫЙ ФУНКЦИОНАЛ (твой код)
-- ==========================================
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
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, "E", false, game)
end

-- ==========================================
-- НОВЫЕ ФУНКЦИИ: Платформа и NoClip
-- ==========================================

-- Переменная для хранения нашей платформы, чтобы удалить её потом
local hidePlatform = nil
local noclipConnection = nil

-- Создание невидимой платформы под ногами
local function createHidePlatform()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Удаляем старую, если есть
    if hidePlatform then hidePlatform:Destroy() end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Создаем парт
    hidePlatform = Instance.new("Part")
    hidePlatform.Name = "AutoFarmPlatform"
    hidePlatform.Size = Vector3.new(10, 1, 10) -- Размер платформы
    hidePlatform.Position = hrp.Position - Vector3.new(0, 3, 0) -- Чуть ниже ног
    hidePlatform.Anchored = true -- Чтобы не падала
    hidePlatform.CanCollide = true -- Чтобы на ней можно было стоять
    hidePlatform.Transparency = 1 -- Невидимая
    hidePlatform.Parent = Workspace
end

-- Включение NoClip (проход сквозь стены)
local function enableNoClip(state)
    local RunService = game:GetService("RunService")
    local player = LocalPlayer
    
    if state then
        -- Если NoClip уже включен, не дублируем
        if noclipConnection then return end
        
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        -- Выключаем NoClip
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- ==========================================
-- ЛОГИКА АВТО-ФАРМА С ПЛАТФОРМОЙ И NOCLIP
-- ==========================================

local isFarming = false

local function StartAutoFarm()
    if isFarming then return end
    isFarming = true
    
    local farmCount = 0
    local maxFarms = 3

    -- Включаем NoClip, чтобы свободно летать под полом
    enableNoClip(true)

    task.spawn(function()
        while isFarming and farmCount < maxFarms do
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            
            if char and humanoid and humanoid.Health > 0 then
                -- 1. Ищем синий интел
                local enemyIntel = getBriefcase("Blue")
                if enemyIntel and enemyIntel.Parent.Name == "Briefcases" then
                    teleportTo(enemyIntel.Position + Vector3.new(0, 2, 0))
                    task.wait(0.3)
                    pressE()
                    task.wait(0.5)
                    
                    -- 2. Несем на красный
                    local dropZone = getBriefcase("Red")
                    if dropZone then
                        teleportTo(dropZone.Position + Vector3.new(0, 2, 0))
                        task.wait(1) -- Ждем сдачу
                        
                        -- 3. УХОДИМ ПОД ПОЛ (в минус по Y)
                        -- Уходим на 10 метров вниз от точки сдачи
                        local hidePos = dropZone.Position - Vector3.new(0, 10, 0)
                        teleportTo(hidePos)
                        
                        -- Создаем платформу, чтобы не падать в пустоту
                        task.wait(0.2) -- Даем время телепорту сработать
                        createHidePlatform()
                        
                        -- Ждем здесь, пока респавнится интел
                        -- Можно поставить паузу, чтобы подождать
                        task.wait(2) 
                    end
                    
                    farmCount = farmCount + 1
                    print("[Auto-Farm] Сдано интелов: " .. farmCount)
                end
            else
                print("[Auto-Farm] Персонаж мертв или не найден.")
            end
            
            task.wait(1)
        end
        
        -- Когда закончили — убираем платформу и выключаем NoClip
        isFarming = false
        if hidePlatform then hidePlatform:Destroy() end
        enableNoClip(false)
        print("[Auto-Farm] Завершено. Сдано " .. farmCount .. " раз.")
    end)
end

local function StopAutoFarm()
    isFarming = false
    if hidePlatform then hidePlatform:Destroy() end
    enableNoClip(false)
    print("[Auto-Farm] Принудительно остановлен.")
end

-- ==========================================
-- ПРИМЕР ВЫЗОВА (для теста)
-- ==========================================
-- Напиши в консоли: StartAutoFarm()