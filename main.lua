-- Функция одного цикла
local function doOneCycle()
    -- Ждем появления синего кейса в Workspace
    while not getBriefcase("Blue") do
        task.wait(0.5)
    end
    
    -- Когда синий появился, запоминаем его координаты
    local blueIntel = getBriefcase("Blue")
    local redIntel = getBriefcase("Red")
    
    -- Если синий есть, но красного нет, ждем
    while not redIntel do
        task.wait(0.5)
        redIntel = getBriefcase("Red")
    end

    -- 1. ТП к Синему (падаем на него)
    teleportTo(blueIntel.Position + Vector3.new(0, 5, 0))
    task.wait(0.6)
    pressE()
    task.wait(0.4)
    
    -- 2. ТП к Красному (сдача)
    teleportTo(redIntel.Position + Vector3.new(0, 2, 0))
    task.wait(1)
    
    -- 3. ТП в безопасную зону
    teleportTo(SAFE_ZONE_POS)
    task.wait(0.5)
    
    -- 4. Проверка через 2 секунды
    ensureInSafeZone()
    
    return true
end