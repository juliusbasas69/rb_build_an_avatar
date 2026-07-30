local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function GetMainGui()
    local gui = playerGui:FindFirstChild("MainGui")

    while not gui do
        playerGui.ChildAdded:Wait()
        gui = playerGui:FindFirstChild("MainGui")
    end

    return gui
end

return GetMainGui