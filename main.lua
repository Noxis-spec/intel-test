local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

task.spawn(function()
    while task.wait(0.1) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
            local blueIntel = getBriefcase("Blue")
            if blueIntel and blueIntel.Parent.Name == "Briefcases" then
                -- ТП к синему (сверху)
                teleportTo(blueIntel.Position + Vector3.new(0, 7, 0))
                task.wait(0.8)
                pressE()
                task.wait(0.5)
                
                -- ТП к красному
                local redIntel = getBriefcase("Red")
                if redIntel then
                    teleportTo(redIntel.Position + Vector3.new(0, 2, 0))
                    task.wait(0.5)
                end
                task.wait(1)
            end
        end
    end
end)