-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer


local ESPEnabled = true
local SkeletonColor = Color3.fromRGB(255, 255, 255)
local NameColor = Color3.fromRGB(255, 255, 255)


local ESPPlayers = {}

local function createESP(player)
    local esp = {skeleton = {}, nameText = nil}

    
    local bones = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},
        {"LowerTorso","RightUpperLeg"},{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"}
    }
    for _, bone in pairs(bones) do
        local line = Drawing.new("Line")
        line.Color = SkeletonColor
        line.Thickness = 1.5
        line.Visible = ESPEnabled
        table.insert(esp.skeleton, {from=bone[1], to=bone[2], line=line})
    end

  
    local nameText = Drawing.new("Text")
    nameText.Text = player.Name
    nameText.Size = 16
    nameText.Color = NameColor
    nameText.Center = true
    nameText.Visible = ESPEnabled
    nameText.Outline = true
    esp.nameText = nameText

    ESPPlayers[player] = esp
end

local function removeESP(player)
    local esp = ESPPlayers[player]
    if esp then
        for _, b in pairs(esp.skeleton) do if b.line then pcall(function() b.line:Remove() end) end end
        if esp.nameText then pcall(function() esp.nameText:Remove() end) end
        ESPPlayers[player] = nil
    end
end


Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then createESP(player) end
end)
Players.PlayerRemoving:Connect(removeESP)
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.End then
        ESPEnabled = not ESPEnabled
        for _, esp in pairs(ESPPlayers) do
            for _, b in pairs(esp.skeleton) do b.line.Visible = ESPEnabled end
            if esp.nameText then esp.nameText.Visible = ESPEnabled end
        end
    end
end)


RunService.Heartbeat:Connect(function()
    for player, esp in pairs(ESPPlayers) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if ESPEnabled and char and hum and hum.Health > 0 then
            -- Skeleton
            for _, b in pairs(esp.skeleton) do
                local part0 = char:FindFirstChild(b.from)
                local part1 = char:FindFirstChild(b.to)
                if part0 and part1 then
                    local pos0, vis0 = Camera:WorldToViewportPoint(part0.Position)
                    local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                    if vis0 and vis1 then
                        b.line.From = Vector2.new(pos0.X, pos0.Y)
                        b.line.To = Vector2.new(pos1.X, pos1.Y)
                        b.line.Visible = true
                    else
                        b.line.Visible = false
                    end
                else
                    b.line.Visible = false
                end
            end

            -- Name
            local head = char:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                esp.nameText.Position = Vector2.new(pos.X, pos.Y)
                esp.nameText.Visible = onScreen
            end
        else
            -- Hide when player dead or ESP off
            for _, b in pairs(esp.skeleton) do b.line.Visible = false end
            if esp.nameText then esp.nameText.Visible = false end
        end
    end
end)
