-- liandograu Hub v2.0 - Brookhaven RP
-- Versao sem a funcao Gamepass.
-- Inclui apenas controles locais e utilitarios; nao altera outros jogadores.
-- Para uso em uma experiencia Roblox sua ou com permissao do criador.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local config = {walkSpeed = 16, jumpPower = 50}
local state = {noclip = false}
local noclipConnection

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "liandograu Hub",
            Text = message,
            Duration = 3
        })
    end)
end

RunService.Heartbeat:Connect(function()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = config.walkSpeed
        hum.JumpPower = config.jumpPower
    end
end)

local function setNoclip(enabled)
    state.noclip = enabled
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = getCharacter()
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    notify("NoClip " .. (enabled and "ON" or "OFF"))
end

local function setTime(hour)
    Lighting.TimeOfDay = string.format("%02d:00:00", hour)
    notify("Horario local alterado")
end

local locations = {
    Spawn = CFrame.new(0, 5, 0),
    Hospital = CFrame.new(120, 5, -80),
    Police = CFrame.new(-90, 5, 100),
    School = CFrame.new(200, 5, 60),
    Airport = CFrame.new(-200, 5, -150),
    Bank = CFrame.new(50, 5, 150),
    Park = CFrame.new(-50, 5, -60),
    Beach = CFrame.new(300, 5, 200),
    Church = CFrame.new(-30, 5, -200),
    Garage = CFrame.new(160, 5, 120)
}

local old = game:GetService("CoreGui"):FindFirstChild("liandograuHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "liandograuHub"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(340, 440)
window.Position = UDim2.new(0.5, -170, 0.5, -220)
window.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -45, 0, 42)
header.Position = UDim2.fromOffset(12, 0)
header.BackgroundTransparency = 1
header.Text = "🔥 liandograu Hub v2.0"
header.TextColor3 = Color3.fromRGB(255, 215, 0)
header.Font = Enum.Font.GothamBold
header.TextSize = 16
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = window

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -38, 0, 6)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
close.Parent = window
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -52)
scroll.Position = UDim2.fromOffset(6, 46)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = window

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)
padding.PaddingTop = UDim.new(0, 5)
padding.Parent = scroll

local function addButton(label, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(28, 28, 45)
    button.TextColor3 = Color3.fromRGB(235, 235, 235)
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.Text = label
    button.Parent = scroll
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    button.MouseButton1Click:Connect(callback)
    return button
end

local function addSlider(label, minValue, maxValue, initial, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 34)
    frame.Parent = scroll
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -16, 0, 22)
    text.Position = UDim2.fromOffset(8, 2)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(230, 230, 230)
    text.Font = Enum.Font.Gotham
    text.TextSize = 12
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Text = label .. ": " .. initial
    text.Parent = frame

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -20, 0, 12)
    bar.Position = UDim2.fromOffset(10, 32)
    bar.BackgroundColor3 = Color3.fromRGB(75, 75, 95)
    bar.Text = ""
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initial - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(x)
        local ratio = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(minValue + ratio * (maxValue - minValue))
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        text.Text = label .. ": " .. value
        callback(value)
    end

    bar.MouseButton1Down:Connect(function()
        dragging = true
        update(UserInputService:GetMouseLocation().X)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

addSlider("Walk Speed", 16, 100, 16, function(value)
    config.walkSpeed = value
end)

addSlider("Jump Power", 50, 150, 50, function(value)
    config.jumpPower = value
end)

addButton("NoClip ON/OFF", function()
    setNoclip(not state.noclip)
end)

addButton("Dia (12:00)", function() setTime(12) end)
addButton("Pôr do sol (18:00)", function() setTime(18) end)
addButton("Nascer do sol (06:00)", function() setTime(6) end)
addButton("Noite (00:00)", function() setTime(0) end)

for name, cframe in pairs(locations) do
    addButton("TP: " .. name, function()
        local hrp = getRoot()
        if hrp then
            hrp.CFrame = cframe
            notify("Teleportado para " .. name)
        end
    end)
end

addButton("Rejoin", function()
    TeleportService:Teleport(game.PlaceId, player)
end)

addButton("Copiar UserID", function()
    local copied = pcall(function()
        setclipboard(tostring(player.UserId))
    end)
    notify(copied and "UserID copiado" or ("UserID: " .. player.UserId))
end)

addButton("Ocultar / mostrar GUI (tecla ])", function()
    window.Visible = not window.Visible
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightBracket then
        window.Visible = not window.Visible
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = config.walkSpeed
        hum.JumpPower = config.jumpPower
    end
end)

notify("liandograu Hub carregado")
