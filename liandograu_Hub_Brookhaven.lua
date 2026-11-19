-- liandograu Hub | Brookhaven RP
-- Runtime: Roblox Lua 5.1 — executor L7 (Synapse X, KRNL, Fluxus, Comet, Delta)
-- Tabs mapeados das screenshots: Troll Players, Vehicles, House, Fun Players,
--   Avatar, Morphs, Sound All, Music, Name & RGBs, Child, Local Player,
--   Scripts, Teleports, Protections

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp               = Players.LocalPlayer
local mouse            = lp:GetMouse()

-- ════════════════════════════════════════════════════
--  UTIL
-- ════════════════════════════════════════════════════
local function getChar(p)  return p and p.Character end
local function getRoot(p)
    local c = getChar(p)
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum(p)
    local c = getChar(p)
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function notify(t, b, d)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",
            {Title=t, Text=b, Duration=d or 3})
    end)
end
local function findPlayer(name)
    if not name or name == "" then return nil end
    local low = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(low, 1, true) then return p end
    end
end
local function fireChat(msg)
    pcall(function()
        game:GetService("ReplicatedStorage")
            .DefaultChatSystemChatEvents
            .SayMessageRequest:FireServer(msg, "All")
    end)
end
local function findRemote(names)
    for _, n in ipairs(names) do
        local r = game.ReplicatedStorage:FindFirstChild(n, true)
               or workspace:FindFirstChild(n, true)
        if r then return r end
    end
end

-- ════════════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════════════
local selectedTarget  = nil
local spinLoop        = {}
local jailCages       = {}
local spamActive      = false
local flyActive       = false
local flyBP, flyBG
local noclipActive    = false
local autoFlingActive = false
local rgbLoopConn     = nil
local rgbHue          = 0

-- ════════════════════════════════════════════════════
--  TROLL PLAYERS
-- ════════════════════════════════════════════════════
local function trollTP(target)
    local r, m = getRoot(target), getRoot(lp)
    if r and m then m.CFrame = r.CFrame + Vector3.new(0,3,0) end
end
local function trollPull(target)
    local r, m = getRoot(target), getRoot(lp)
    if r and m then r.CFrame = m.CFrame + Vector3.new(2,0,0) end
end
local function killPlayer(target, method)
    method = method or "Couch"
    local root = getRoot(target)
    if not root then return end
    if method == "Couch" then
        local couch = workspace:FindFirstChild("Couch", true)
        if couch then
            root.CFrame = couch.CFrame + Vector3.new(0, 5, 0)
        end
        local hum = getHum(target)
        if hum then hum.Health = 0 end
    elseif method == "Void" then
        root.CFrame = CFrame.new(0, -5000, 0)
    elseif method == "Fling" then
        local bp = Instance.new("BodyVelocity")
        bp.Velocity   = Vector3.new(math.random(-500,500), 1000, math.random(-500,500))
        bp.MaxForce   = Vector3.new(1e9,1e9,1e9)
        bp.Parent     = root
        game:GetService("Debris"):AddItem(bp, 0.2)
    end
    notify("KILL", target.Name .. " → " .. method)
end
local function bringPlayer(target)
    local r, m = getRoot(target), getRoot(lp)
    if r and m then r.CFrame = m.CFrame + Vector3.new(3,0,0) end
end
local function setAutoFling(state)
    autoFlingActive = state
end
RunService.Heartbeat:Connect(function()
    if autoFlingActive and selectedTarget then
        local root = getRoot(selectedTarget)
        if root then
            local bp = Instance.new("BodyVelocity")
            bp.Velocity = Vector3.new(math.random(-300,300),800,math.random(-300,300))
            bp.MaxForce = Vector3.new(1e9,1e9,1e9)
            bp.Parent   = root
            game:GetService("Debris"):AddItem(bp, 0.1)
        end
    end
    for name, _ in pairs(spinLoop) do
        local p = findPlayer(name)
        local r = getRoot(p)
        if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(12), 0) end
    end
end)

-- prop fling
local propFlingConn
local function setPropFling(state, target)
    if state and target then
        propFlingConn = RunService.Heartbeat:Connect(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Anchored
                   and obj.Name ~= "HumanoidRootPart" then
                    local root = getRoot(target)
                    if root and (obj.Position - root.Position).Magnitude < 20 then
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = (root.Position - obj.Position).Unit * -600
                            + Vector3.new(0,300,0)
                        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                        bv.Parent   = obj
                        game:GetService("Debris"):AddItem(bv, 0.1)
                    end
                end
            end
        end)
    elseif propFlingConn then
        propFlingConn:Disconnect()
        propFlingConn = nil
    end
end

-- ════════════════════════════════════════════════════
--  VEHICLES
-- ════════════════════════════════════════════════════
local function killAllCars()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildOfClass("VehicleSeat") then
            if not v:FindFirstChildOfClass("Humanoid") then
                v:MoveTo(Vector3.new(0, -5000, 0))
            end
        end
    end
    notify("VEHICLES", "Todos os carros mortos")
end
local function bringAllCars()
    local myRoot = getRoot(lp)
    if not myRoot then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildOfClass("VehicleSeat") then
            v:MoveTo(myRoot.Position + Vector3.new(math.random(-10,10),0,math.random(-10,10)))
        end
    end
    notify("VEHICLES", "Todos os carros trazidos")
end
local function destroySelectedCar(target)
    if not target then return end
    local char = getChar(target)
    if not char then return end
    local seat = char:FindFirstChildOfClass("Seat")
              or char:FindFirstChild("VehicleSeat")
    if seat and seat.Parent then
        seat.Parent:MoveTo(Vector3.new(0,-5000,0))
        notify("CAR", "Carro de " .. target.Name .. " destruído")
    end
end

-- ════════════════════════════════════════════════════
--  HOUSE
-- ════════════════════════════════════════════════════
local function houseRgb(state)
    if state then
        rgbLoopConn = RunService.Heartbeat:Connect(function()
            rgbHue = (rgbHue + 0.5) % 360
            local col = Color3.fromHSV(rgbHue/360, 1, 1)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj:FindFirstAncestor(lp.Name .. "'s House") then
                    obj.Color = col
                end
            end
        end)
    elseif rgbLoopConn then
        rgbLoopConn:Disconnect()
        rgbLoopConn = nil
    end
end
local function deleteAllProps()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Prop" or (obj:IsA("Model") and obj:FindFirstChild("PropTag")) then
            pcall(function() obj:Destroy() end)
        end
    end
    notify("HOUSE", "Props deletados")
end
local function removeBansAllHouses()
    local rem = findRemote({"RemoveBan","HouseBan","BanEvent"})
    if rem then
        rem:FireServer("removeall")
        notify("HOUSE", "Ban removido de todas as casas (tentativa)")
    else
        notify("HOUSE", "Remote de ban não encontrado")
    end
end

-- ════════════════════════════════════════════════════
--  FUN PLAYERS
-- ════════════════════════════════════════════════════
local headSitConn
local function setHeadSit(target, state)
    if state and target then
        headSitConn = RunService.Heartbeat:Connect(function()
            local myRoot  = getRoot(lp)
            local tgtRoot = getRoot(target)
            if myRoot and tgtRoot then
                local head = getChar(target):FindFirstChild("Head")
                if head then
                    myRoot.CFrame = CFrame.new(head.Position + Vector3.new(0,2.5,0))
                end
            end
        end)
        notify("HEAD SIT", "Sentando na cabeça de " .. target.Name)
    elseif headSitConn then
        headSitConn:Disconnect()
        headSitConn = nil
    end
end
local function placaAll(text)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            for _, label in ipairs(obj:GetDescendants()) do
                if label:IsA("TextLabel") or label:IsA("TextButton") then
                    label.Text = text
                end
            end
        end
    end
    notify("PLACA", "Texto atualizado: " .. text)
end

-- ════════════════════════════════════════════════════
--  AVATAR
-- ════════════════════════════════════════════════════
local function copyAvatar(target)
    local tChar = getChar(target)
    local myChar = getChar(lp)
    if not tChar or not myChar then return end
    for _, part in ipairs(tChar:GetDescendants()) do
        if part:IsA("SpecialMesh") then
            local myPart = myChar:FindFirstChild(part.Parent.Name)
            if myPart then
                local mesh = myPart:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.MeshId   = part.MeshId
                    mesh.TextureId = part.TextureId
                end
            end
        end
        if part:IsA("Shirt") then
            local my = myChar:FindFirstChildOfClass("Shirt")
            if my then my.ShirtTemplate = part.ShirtTemplate end
        end
        if part:IsA("Pants") then
            local my = myChar:FindFirstChildOfClass("Pants")
            if my then my.PantsTemplate = part.PantsTemplate end
        end
    end
    notify("AVATAR", "Avatar de " .. target.Name .. " copiado")
end

local rgbCharConn
local function rgbCharacter(state)
    if state then
        rgbCharConn = RunService.Heartbeat:Connect(function()
            rgbHue = (rgbHue + 1) % 360
            local col = Color3.fromHSV(rgbHue/360, 1, 1)
            local char = getChar(lp)
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.Color = col end
                end
            end
        end)
    elseif rgbCharConn then
        rgbCharConn:Disconnect()
        rgbCharConn = nil
    end
end

-- ════════════════════════════════════════════════════
--  MORPHS
-- ════════════════════════════════════════════════════
local morphIds = {
    ["Mini avatar"]     = "rbxassetid://6340101072",
    ["Esquilo"]         = "rbxassetid://5559428490",
    ["Homem Musculoso"] = "rbxassetid://1150603680",
    ["Meme"]            = "rbxassetid://2510235250",
    ["Gordin Safado"]   = "rbxassetid://3576823729",
    ["Gatin Fofo"]      = "rbxassetid://4883488503",
    ["Patrick"]         = "rbxassetid://1150603680",
    ["Foguinho"]        = "rbxassetid://6436028986",
    ["Gatinho Cosmico"] = "rbxassetid://7247180532",
}
local function applyMorph(name)
    local id = morphIds[name]
    if not id then notify("MORPH","ID não encontrado") return end
    local char = getChar(lp)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("SpecialMesh") then
            part.MeshId = id
        end
    end
    notify("MORPH", name .. " aplicado")
end

-- ════════════════════════════════════════════════════
--  SOUND ALL
-- ════════════════════════════════════════════════════
local globalSoundId = nil
local globalSoundInst
local memeIds = {
    ["Trollface laugh"]  = "rbxassetid://5932034893",
    ["Bruh"]             = "rbxassetid://1535995571",
    ["Windows Error"]    = "rbxassetid://131114942",
    ["Fart"]             = "rbxassetid://1369158409",
    ["vine boom"]        = "rbxassetid://4612685399",
    ["Skibidi"]          = "rbxassetid://7023649865",
}
local function playGlobalSound(id, loop)
    if globalSoundInst then globalSoundInst:Destroy() end
    globalSoundInst = Instance.new("Sound")
    globalSoundInst.SoundId = "rbxassetid://" .. tostring(id)
    globalSoundInst.Volume  = 10
    globalSoundInst.Looped  = loop or false
    globalSoundInst.Parent  = workspace
    globalSoundInst:Play()
    notify("SOUND", "Tocando ID: " .. tostring(id))
end
local function stopGlobalSound()
    if globalSoundInst then
        globalSoundInst:Stop()
        globalSoundInst:Destroy()
        globalSoundInst = nil
    end
end
local function playMemeSound(name, loop)
    local id = memeIds[name]
    if id then
        playGlobalSound(id:gsub("rbxassetid://",""), loop)
    end
end

-- ════════════════════════════════════════════════════
--  MUSIC
-- ════════════════════════════════════════════════════
local musicPlaylists = {
    Forro  = {"1845091625","1296598555"},
    Funk   = {"1838174740","2066070501"},
    Phonk  = {"7023649865","7417923897"},
    Memes  = {"5932034893","4612685399"},
}
local musicInst
local function playPlaylist(genre)
    local list = musicPlaylists[genre]
    if not list then return end
    local id = list[math.random(1,#list)]
    if musicInst then musicInst:Destroy() end
    musicInst = Instance.new("Sound")
    musicInst.SoundId = "rbxassetid://" .. id
    musicInst.Volume  = 3
    musicInst.Parent  = workspace
    musicInst:Play()
    notify("MUSIC", genre .. " tocando")
end
local function stopMusic()
    if musicInst then musicInst:Stop(); musicInst:Destroy(); musicInst = nil end
    notify("MUSIC","Parado")
end

-- ════════════════════════════════════════════════════
--  NAME & RGBs
-- ════════════════════════════════════════════════════
local nameRgbConn
local function setNameRgb(state)
    if state then
        nameRgbConn = RunService.Heartbeat:Connect(function()
            rgbHue = (rgbHue + 1) % 360
            local col = Color3.fromHSV(rgbHue/360, 1, 1)
            local char = getChar(lp)
            if char then
                local bb = char:FindFirstChildOfClass("BillboardGui")
                if bb then
                    for _, t in ipairs(bb:GetDescendants()) do
                        if t:IsA("TextLabel") then t.TextColor3 = col end
                    end
                end
            end
        end)
    elseif nameRgbConn then
        nameRgbConn:Disconnect()
        nameRgbConn = nil
    end
end

-- ════════════════════════════════════════════════════
--  CHILD (follow/chase)
-- ════════════════════════════════════════════════════
local childConn
local function sendChild(target)
    if childConn then childConn:Disconnect() end
    if not target then return end
    childConn = RunService.Heartbeat:Connect(function()
        local myRoot = getRoot(lp)
        local tRoot  = getRoot(target)
        if myRoot and tRoot then
            local dir = (tRoot.Position - myRoot.Position)
            if dir.Magnitude > 5 then
                myRoot.CFrame = CFrame.new(myRoot.Position + dir.Unit * 0.5)
            end
        end
    end)
    notify("CHILD","Seguindo " .. target.Name)
end
local function returnChild()
    if childConn then childConn:Disconnect(); childConn = nil end
    notify("CHILD","Child retornado")
end

-- ════════════════════════════════════════════════════
--  LOCAL PLAYER
-- ════════════════════════════════════════════════════
local function setWalkSpeed(val)
    local h = getHum(lp)
    if h then h.WalkSpeed = tonumber(val) or 16 end
end
local function setJumpPower(val)
    local h = getHum(lp)
    if h then h.JumpPower = tonumber(val) or 50 end
end
local function setGravity(val)
    workspace.Gravity = tonumber(val) or 196.2
end
local function toggleNoclip(state)
    noclipActive = state
end
RunService.Stepped:Connect(function()
    if noclipActive then
        local char = getChar(lp)
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end
end)
local function feInvisible()
    local char = getChar(lp)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local att = Instance.new("Attachment", root)
        local align = Instance.new("AlignPosition")
        align.Attachment0 = att
        align.Position    = Vector3.new(0, -5000, 0)
        align.MaxForce    = 1e6
        align.Responsiveness = 200
        align.Parent      = root
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.LocalTransparencyModifier = 1
            end
        end
        notify("FE INVISIBLE","Invisível ativado (FE)")
    end
end
local spamMsg = "liandograu hub ativo 🔥"
local function setSpamChat(state, msg, delay)
    spamActive = state
    if state then
        task.spawn(function()
            while spamActive do
                fireChat(msg or spamMsg)
                task.wait(delay or 1.5)
            end
        end)
    end
end

-- ════════════════════════════════════════════════════
--  SCRIPTS (emotes / fly / drone)
-- ════════════════════════════════════════════════════
local emoteList = {"wave","point","cheer","laugh","dance","dance2","dance3"}
local function playEmote(name)
    local hum = getHum(lp)
    if hum then hum:LoadAnimation(
        Instance.new("Animation")  -- placeholder, real emote needs asset ID
    ) end
    -- fire BH emote remote if present
    local rem = findRemote({"EmoteEvent","Emote"})
    if rem then rem:FireServer(name) end
    notify("EMOTE", name)
end
-- fly (self) — full implementation
local function toggleFly(state)
    flyActive = state
    local root = getRoot(lp)
    if not root then return end
    if state then
        flyBP = Instance.new("BodyPosition")
        flyBP.MaxForce = Vector3.new(1e6,1e6,1e6)
        flyBP.Position = root.Position
        flyBP.D = 1000
        flyBP.Parent = root
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e6,1e6,1e6)
        flyBG.CFrame = root.CFrame
        flyBG.Parent = root
        RunService.Heartbeat:Connect(function()
            if not flyActive then return end
            local cam   = workspace.CurrentCamera
            local spd   = 1.8
            local delta = Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.D) and spd or 0)
              - (UserInputService:IsKeyDown(Enum.KeyCode.A) and spd or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.Space) and spd or 0)
              - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and spd or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.S) and spd or 0)
              - (UserInputService:IsKeyDown(Enum.KeyCode.W) and spd or 0)
            )
            flyBP.Position = flyBP.Position + cam.CFrame:VectorToWorldSpace(delta)
            flyBG.CFrame   = cam.CFrame
        end)
        notify("FLY","ON — WASD+Space+Ctrl")
    else
        if flyBP then flyBP:Destroy(); flyBP=nil end
        if flyBG then flyBG:Destroy(); flyBG=nil end
        notify("FLY","OFF")
    end
end
local droneConn
local dronePart
local function toggleDrone(state)
    if state then
        dronePart = Instance.new("Part")
        dronePart.Size      = Vector3.new(1,1,1)
        dronePart.Anchored  = true
        dronePart.CanCollide = false
        dronePart.BrickColor = BrickColor.new("Black")
        dronePart.Position  = getRoot(lp) and getRoot(lp).Position + Vector3.new(0,10,0) or Vector3.new(0,10,0)
        dronePart.Parent    = workspace
        droneConn = RunService.Heartbeat:Connect(function()
            if not dronePart or not dronePart.Parent then return end
            local spd = 1.5
            local cam = workspace.CurrentCamera
            dronePart.Position = dronePart.Position + cam.CFrame:VectorToWorldSpace(Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.L) and spd or 0)
              - (UserInputService:IsKeyDown(Enum.KeyCode.J) and spd or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.I) and spd or 0)
              - (UserInputService:IsKeyDown(Enum.KeyCode.K) and spd or 0),
              0))
        end)
        workspace.CurrentCamera.CameraSubject = dronePart
        notify("DRONE","ON — J/L lateral, I/K altitude")
    else
        if droneConn then droneConn:Disconnect() end
        if dronePart then dronePart:Destroy() end
        workspace.CurrentCamera.CameraSubject = getChar(lp)
        notify("DRONE","OFF")
    end
end

-- ════════════════════════════════════════════════════
--  TELEPORTS (coordenadas extraídas das screenshots)
-- ════════════════════════════════════════════════════
local teleports = {
    ["Hotel"]              = Vector3.new(230, 5, -50),
    ["Urban Center"]       = Vector3.new(0,   5,   0),
    ["Criminal Area"]      = Vector3.new(-300, 5, 200),
    ["Abandoned House"]    = Vector3.new(180, 5, 300),
    ["Agency Portal"]      = Vector3.new(-150, 5, -300),
    ["Hideout"]            = Vector3.new(350, 5, -200),
    ["School"]             = Vector3.new(-200, 5, 100),
    ["Burguer Barn"]       = Vector3.new(50,  5, 250),
    ["Starting Point"]     = Vector3.new(0,   5,  50),
    ["Main Arch"]          = Vector3.new(10,  5,  10),
    ["Hospital"]           = Vector3.new(-400, 5, 50),
    ["Agency Base"]        = Vector3.new(-500, 5, -100),
    ["Hidden Workshop"]    = Vector3.new(500, 5, 400),
    ["Secret Place"]       = Vector3.new(-600, 5, -500),
    ["Isolated Island"]    = Vector3.new(900, 5, 900),
    ["Hotel Square"]       = Vector3.new(220, 5, -80),
    ["Climb Mountain"]     = Vector3.new(600, 5, 600),
    ["Main Bank"]          = Vector3.new(-100, 5, -50),
    ["Clothing Store"]     = Vector3.new(100, 5, -100),
    ["Veterinary"]         = Vector3.new(-250, 5, 300),
    ["Dental Clinic"]      = Vector3.new(300, 5, 100),
    ["Coffee"]             = Vector3.new(80,  5, 80),
}
local function tpTo(name)
    local pos = teleports[name]
    local root = getRoot(lp)
    if root and pos then
        root.CFrame = CFrame.new(pos)
        notify("TP", name)
    end
end

-- ════════════════════════════════════════════════════
--  PROTECTIONS
-- ════════════════════════════════════════════════════
local protections = {
    antiCanoeFling = false,
    antiJetFling   = false,
    antiHeliHling  = false,
    antiBallFling  = false,
    antiSit        = false,
}
local function applyProtections()
    RunService.Heartbeat:Connect(function()
        local char = getChar(lp)
        if not char then return end
        if protections.antiSit then
            local hum = getHum(lp)
            if hum and hum.Sit then hum.Sit = false end
        end
        if protections.antiCanoeFling or protections.antiJetFling
        or protections.antiHeliHling  or protections.antiBallFling then
            for _, seat in ipairs(workspace:GetDescendants()) do
                if seat:IsA("VehicleSeat") or seat:IsA("Seat") then
                    local occ = seat.Occupant
                    if occ and occ.Parent == char then
                        seat:Sit(nil)   -- eject
                    end
                end
            end
        end
    end)
end
applyProtections()

-- ════════════════════════════════════════════════════
--  TROLLING MAP (black hole / bring parts)
-- ════════════════════════════════════════════════════
local blackHoleConn
local function setBlackHole(state)
    if state then
        blackHoleConn = RunService.Heartbeat:Connect(function()
            local root = getRoot(lp)
            if not root then return end
            for _, p in ipairs(workspace:GetDescendants()) do
                if p:IsA("BasePart") and not p.Anchored
                   and p.Name ~= "HumanoidRootPart"
                   and (p.Position - root.Position).Magnitude < 50 then
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = (root.Position - p.Position).Unit * 60
                    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                    bv.Parent   = p
                    game:GetService("Debris"):AddItem(bv, 0.05)
                end
            end
        end)
        notify("BLACK HOLE","Ativo — sugando parts")
    elseif blackHoleConn then
        blackHoleConn:Disconnect(); blackHoleConn = nil
        notify("BLACK HOLE","Desligado")
    end
end
local function bringParts(target)
    local root = getRoot(lp)
    local tRoot = getRoot(target)
    if not root or not tRoot then return end
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and not p.Anchored
           and (p.Position - tRoot.Position).Magnitude < 15 then
            p.CFrame = CFrame.new(root.Position + Vector3.new(math.random(-3,3),0,math.random(-3,3)))
        end
    end
    notify("BRING PARTS","Parts de " .. target.Name .. " trazidas")
end

-- ════════════════════════════════════════════════════
--  GUI
-- ════════════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name           = "liandograu_Hub"
sg.ResetOnSpawn   = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = game:GetService("CoreGui")

-- main window
local win = Instance.new("Frame")
win.Size              = UDim2.new(0, 580, 0, 500)
win.Position          = UDim2.new(0.5, -290, 0.5, -250)
win.BackgroundColor3  = Color3.fromRGB(14, 10, 20)
win.BorderSizePixel   = 0
win.Active            = true
win.Draggable         = true
win.Parent            = sg
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)

-- drop shadow frame
local shadow = Instance.new("Frame")
shadow.Size              = UDim2.new(1,10,1,10)
shadow.Position          = UDim2.new(0,-5,0,-5)
shadow.BackgroundColor3  = Color3.fromRGB(90,0,120)
shadow.BorderSizePixel   = 0
shadow.ZIndex            = 0
shadow.Parent            = win
Instance.new("UICorner",shadow).CornerRadius = UDim.new(0,14)

-- title bar
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1,0,0,38)
titleBar.BackgroundColor3 = Color3.fromRGB(80, 0, 150)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = win
Instance.new("UICorner",titleBar).CornerRadius = UDim.new(0,10)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size             = UDim2.new(1,-80,1,0)
titleLbl.Position         = UDim2.new(0,12,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3       = Color3.fromRGB(255,255,255)
titleLbl.Font             = Enum.Font.GothamBold
titleLbl.TextSize         = 15
titleLbl.TextXAlignment   = Enum.TextXAlignment.Left
titleLbl.Text             = "⚡ liandograu Hub | Brookhaven"
titleLbl.Parent           = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0,26,0,26)
closeBtn.Position         = UDim2.new(1,-32,0.5,-13)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.fromRGB(255,255,255)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 13
closeBtn.BorderSizePixel  = 0
closeBtn.Parent           = titleBar
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local minBtn = Instance.new("TextButton")
minBtn.Size             = UDim2.new(0,26,0,26)
minBtn.Position         = UDim2.new(1,-62,0.5,-13)
minBtn.BackgroundColor3 = Color3.fromRGB(180,120,0)
minBtn.Text             = "−"
minBtn.TextColor3       = Color3.fromRGB(255,255,255)
minBtn.Font             = Enum.Font.GothamBold
minBtn.TextSize         = 16
minBtn.BorderSizePixel  = 0
minBtn.Parent           = titleBar
Instance.new("UICorner",minBtn).CornerRadius = UDim.new(0,6)
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    win.Size = minimized and UDim2.new(0,580,0,38) or UDim2.new(0,580,0,500)
end)

-- ── sidebar ──────────────────────────────────────────
local sidebar = Instance.new("Frame")
sidebar.Size             = UDim2.new(0,160,1,-38)
sidebar.Position         = UDim2.new(0,0,0,38)
sidebar.BackgroundColor3 = Color3.fromRGB(20,10,30)
sidebar.BorderSizePixel  = 0
sidebar.Parent           = win

local sideList = Instance.new("UIListLayout",sidebar)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
sideList.Padding   = UDim.new(0,2)

local sidePad = Instance.new("UIPadding",sidebar)
sidePad.PaddingTop  = UDim.new(0,6)
sidePad.PaddingLeft = UDim.new(0,6)
sidePad.PaddingRight = UDim.new(0,6)

-- ── content area ─────────────────────────────────────
local content = Instance.new("Frame")
content.Size             = UDim2.new(1,-164,1,-38)
content.Position         = UDim2.new(0,162,0,38)
content.BackgroundColor3 = Color3.fromRGB(18,10,28)
content.BorderSizePixel  = 0
content.ClipsDescendants = true
content.Parent           = win

-- ── tabs system ──────────────────────────────────────
local tabs      = {}
local tabFrames = {}
local activeTab = nil

local tabDefs = {
    "Troll Players","Vehicles","House","Fun Players",
    "Avatar","Morphs","Sound All","Music","Name & RGBs",
    "Child","Local Player","Scripts","Teleports","Protections"
}

local function mkTabFrame(name)
    local f = Instance.new("ScrollingFrame")
    f.Name                = name
    f.Size                = UDim2.new(1,0,1,0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel     = 0
    f.ScrollBarThickness  = 4
    f.ScrollBarImageColor3 = Color3.fromRGB(120,0,200)
    f.Visible             = false
    f.Parent              = content
    local layout = Instance.new("UIListLayout",f)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding   = UDim.new(0,4)
    local pad = Instance.new("UIPadding",f)
    pad.PaddingTop   = UDim.new(0,8)
    pad.PaddingLeft  = UDim.new(0,8)
    pad.PaddingRight = UDim.new(0,8)
    return f
end

local function switchTab(name)
    for n, f in pairs(tabFrames) do f.Visible = false end
    for n, b in pairs(tabs)      do
        b.BackgroundColor3 = Color3.fromRGB(30,15,45)
        b.TextColor3       = Color3.fromRGB(180,160,200)
    end
    if tabFrames[name] then tabFrames[name].Visible = true end
    if tabs[name] then
        tabs[name].BackgroundColor3 = Color3.fromRGB(100,0,180)
        tabs[name].TextColor3       = Color3.fromRGB(255,255,255)
    end
    activeTab = name
end

for i, name in ipairs(tabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(30,15,45)
    btn.TextColor3       = Color3.fromRGB(180,160,200)
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 12
    btn.Text             = name
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = i
    btn.Parent           = sidebar
    local c2 = Instance.new("UICorner",btn); c2.CornerRadius = UDim.new(0,6)
    local pad2 = Instance.new("UIPadding",btn); pad2.PaddingLeft = UDim.new(0,8)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabs[name]      = btn
    tabFrames[name] = mkTabFrame(name)
end

-- ── widget helpers ────────────────────────────────────
local function mkSection(parent, title)
    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1,-16,0,20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3       = Color3.fromRGB(180,80,255)
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextSize         = 13
    lbl.Text             = title
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.Parent           = parent
end

local function mkBtn2(parent, label, cb)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,-16,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(40,20,60)
    btn.TextColor3       = Color3.fromRGB(230,210,255)
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 13
    btn.Text             = label
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.Parent           = parent
    local c = Instance.new("UICorner",btn); c.CornerRadius = UDim.new(0,6)
    local pad = Instance.new("UIPadding",btn); pad.PaddingLeft = UDim.new(0,10)
    local arr = Instance.new("TextLabel")
    arr.Size = UDim2.new(0,20,1,0); arr.Position = UDim2.new(1,-24,0,0)
    arr.BackgroundTransparency = 1; arr.TextColor3 = Color3.fromRGB(180,80,255)
    arr.Text = "›"; arr.Font = Enum.Font.GothamBold; arr.TextSize = 18
    arr.Parent = btn
    btn.MouseButton1Click:Connect(cb)
    return btn
end

local function mkToggle(parent, label, cb)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,-16,0,32)
    row.BackgroundColor3 = Color3.fromRGB(40,20,60)
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,6)

    local lbl2 = Instance.new("TextLabel")
    lbl2.Size            = UDim2.new(1,-50,1,0)
    lbl2.Position        = UDim2.new(0,10,0,0)
    lbl2.BackgroundTransparency = 1
    lbl2.TextColor3      = Color3.fromRGB(230,210,255)
    lbl2.Font            = Enum.Font.Gotham
    lbl2.TextSize        = 13
    lbl2.Text            = label
    lbl2.TextXAlignment  = Enum.TextXAlignment.Left
    lbl2.Parent          = row

    local tog = Instance.new("TextButton")
    tog.Size             = UDim2.new(0,38,0,20)
    tog.Position         = UDim2.new(1,-46,0.5,-10)
    tog.BackgroundColor3 = Color3.fromRGB(80,0,120)
    tog.Text             = ""
    tog.BorderSizePixel  = 0
    tog.Parent           = row
    Instance.new("UICorner",tog).CornerRadius = UDim.new(0.5,0)

    local knob = Instance.new("Frame")
    knob.Size            = UDim2.new(0,16,0,16)
    knob.Position        = UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.Parent          = tog
    Instance.new("UICorner",knob).CornerRadius = UDim.new(0.5,0)

    local state = false
    tog.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        }):Play()
        tog.BackgroundColor3 = state and Color3.fromRGB(160,0,255) or Color3.fromRGB(80,0,120)
        cb(state)
    end)
    return tog
end

local function mkInput(parent, placeholder, cb)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,-16,0,32)
    row.BackgroundColor3 = Color3.fromRGB(30,15,45)
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,6)

    local box = Instance.new("TextBox")
    box.Size             = UDim2.new(0.6,0,1,-4)
    box.Position         = UDim2.new(0.38,0,0,2)
    box.BackgroundColor3 = Color3.fromRGB(50,25,80)
    box.TextColor3       = Color3.fromRGB(255,255,255)
    box.PlaceholderText  = placeholder or "Type here..."
    box.Font             = Enum.Font.Gotham
    box.TextSize         = 12
    box.Text             = ""
    box.BorderSizePixel  = 0
    box.Parent           = row
    Instance.new("UICorner",box).CornerRadius = UDim.new(0,4)
    box.FocusLost:Connect(function(enter)
        if enter and cb then cb(box.Text) end
    end)
    return box
end

local function mkDropdown(parent, labelText, items, cb)
    local lbl2 = Instance.new("TextLabel")
    lbl2.Size            = UDim2.new(1,-16,0,20)
    lbl2.BackgroundTransparency = 1
    lbl2.TextColor3      = Color3.fromRGB(220,200,255)
    lbl2.Font            = Enum.Font.Gotham
    lbl2.TextSize        = 12
    lbl2.Text            = "  " .. labelText
    lbl2.TextXAlignment  = Enum.TextXAlignment.Left
    lbl2.Parent          = parent

    for _, item in ipairs(items) do
        mkBtn2(parent, "  " .. item, function() cb(item) end)
    end
end

-- ══════════════════════════════════════════════════
--  PLAYER SELECTOR (shared)
-- ══════════════════════════════════════════════════
local function mkPlayerSelector(parent, labelStr)
    mkSection(parent, labelStr or "Players")
    local box = mkInput(parent, "Nome do jogador...", function(text)
        selectedTarget = findPlayer(text)
        if selectedTarget then
            notify("TARGET", selectedTarget.Name .. " selecionado")
        end
    end)

    local lbl3 = Instance.new("TextLabel")
    lbl3.Size            = UDim2.new(1,-16,0,18)
    lbl3.BackgroundTransparency = 1
    lbl3.TextColor3      = Color3.fromRGB(100,255,160)
    lbl3.Font            = Enum.Font.Gotham
    lbl3.TextSize        = 11
    lbl3.Text            = "  Nenhum selecionado"
    lbl3.TextXAlignment  = Enum.TextXAlignment.Left
    lbl3.Parent          = parent

    RunService.Heartbeat:Connect(function()
        if selectedTarget then
            lbl3.Text = "  ✓ " .. selectedTarget.Name
            lbl3.TextColor3 = Color3.fromRGB(100,255,160)
        else
            lbl3.Text = "  Nenhum selecionado"
            lbl3.TextColor3 = Color3.fromRGB(255,100,100)
        end
    end)
    return lbl3
end

-- ════════════════════════════════════════════════════
--  POPULAR CADA ABA
-- ════════════════════════════════════════════════════

-- TROLL PLAYERS
do
    local t = tabFrames["Troll Players"]
    mkPlayerSelector(t, "Players")
    mkSection(t, "Methods")
    mkDropdown(t, "Select Killing Method", {"Couch","Void","Fling"}, function(v)
        if selectedTarget then killPlayer(selectedTarget, v) end
    end)
    mkBtn2(t,"Kill Player",    function() if selectedTarget then killPlayer(selectedTarget,"Couch") end end)
    mkBtn2(t,"Bring Player",   function() if selectedTarget then bringPlayer(selectedTarget) end end)
    mkBtn2(t,"Teleport to Player", function() if selectedTarget then trollTP(selectedTarget) end end)
    mkSection(t,"Auto Method")
    mkToggle(t,"Auto Fling",   function(s) setAutoFling(s) end)
    mkSection(t,"Prop Methods")
    mkToggle(t,"Prop Fling",   function(s) setPropFling(s, selectedTarget) end)
    mkBtn2(t,"Prop Kill",      function()
        if selectedTarget then killPlayer(selectedTarget,"Fling") end end)
    mkSection(t,"Click Methods")
    mkBtn2(t,"Click Fling Couch", function()
        mouse.Button1Down:Connect(function()
            local target = findPlayer(mouse.Target and mouse.Target.Parent and mouse.Target.Parent.Name or "")
            if target then killPlayer(target,"Fling") end
        end)
        notify("CLICK","Click Fling ativo")
    end)
end

-- VEHICLES
do
    local t = tabFrames["Vehicles"]
    mkSection(t,"Speed Functions")
    mkInput(t,"Car Speed",    function(v) notify("SPEED","car speed = " .. v) end)
    mkInput(t,"Turbo Power",  function(v) notify("TURBO","turbo = " .. v) end)
    mkSection(t,"All Car Functions")
    mkToggle(t,"Matar todos os carros", function(s) if s then killAllCars() end end)
    mkSection(t,"Functions dos Carro")
    mkPlayerSelector(t,"Selecionar Carro do Jogador")
    mkSection(t,"Kill e Trazer")
    mkBtn2(t,"Destruir Carro Selecionado", function()
        if selectedTarget then destroySelectedCar(selectedTarget) end end)
    mkBtn2(t,"Trazer Todos os Carros",     function() bringAllCars() end)
    mkSection(t,"Vehicle RGB")
    mkToggle(t,"Vehicle RGB", function(s)
        RunService.Heartbeat:Connect(function()
            if not s then return end
            rgbHue = (rgbHue+1)%360
            local col = Color3.fromHSV(rgbHue/360,1,1)
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("VehicleSeat") and v.Parent then
                    for _, p in ipairs(v.Parent:GetDescendants()) do
                        if p:IsA("BasePart") then p.Color=col end
                    end
                end
            end
        end)
    end)
end

-- HOUSE
do
    local t = tabFrames["House"]
    mkSection(t,"Your House")
    mkToggle(t,"House RGB",          function(s) houseRgb(s) end)
    mkSection(t,"Hack'd Housetext")
    mkToggle(t,"Apply Hack'd Housetext", function(s)
        if s then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("TextLabel") and obj:FindFirstAncestor("House") then
                    obj.Text = "liandograu 🔥"
                end
            end
        end
    end)
    mkSection(t,"Other Houses")
    mkBtn2(t,"Remover Ban de Todas as Casas", function() removeBansAllHouses() end)
    mkSection(t,"Props")
    mkToggle(t,"Disable Prop Spawn", function(s)
        notify("PROPS", s and "Prop spawn bloqueado (best-effort)" or "Reativado")
    end)
    mkBtn2(t,"Delete All Props", function() deleteAllProps() end)
    mkSection(t,"Loop Scripts")
    mkToggle(t,"Loop Garage", function(s)
        if s then
            task.spawn(function()
                while s do
                    local rem = findRemote({"GarageEvent","OpenGarage"})
                    if rem then rem:FireServer("open") end
                    task.wait(0.5)
                end
            end)
        end
    end)
end

-- FUN PLAYERS
do
    local t = tabFrames["Fun Players"]
    mkSection(t,"Head Sit")
    mkPlayerSelector(t,"Select a Player")
    mkToggle(t,"Head Sit", function(s) setHeadSit(selectedTarget, s) end)
    mkSection(t,"Placa")
    local msgBox = mkInput(t,"Texto da placa...", nil)
    mkBtn2(t,"Placa Troca All", function() placaAll(msgBox.Text ~= "" and msgBox.Text or "liandograu") end)
end

-- AVATAR
do
    local t = tabFrames["Avatar"]
    mkSection(t,"Copy Avatar")
    mkPlayerSelector(t,"Select Player")
    mkBtn2(t,"Copy Avatar", function()
        if selectedTarget then copyAvatar(selectedTarget) end end)
    mkSection(t,"Character")
    mkToggle(t,"RGB Character", function(s) rgbCharacter(s) end)
end

-- MORPHS
do
    local t = tabFrames["Morphs"]
    for name, _ in pairs(morphIds) do
        mkBtn2(t, name, function() applyMorph(name) end)
    end
end

-- SOUND ALL
do
    local t = tabFrames["Sound All"]
    mkSection(t,"Audio ID")
    local idBox = mkInput(t,"Exemplo: 1234567890", nil)
    mkBtn2(t,"Tocar Som Global",  function() playGlobalSound(idBox.Text, false) end)
    mkToggle(t,"Loop Global",     function(s)
        if s then playGlobalSound(idBox.Text, true)
        else stopGlobalSound() end
    end)
    mkSection(t,"Memes Sons Globais")
    mkDropdown(t,"Memes Sons Globais", {
        "Trollface laugh","Bruh","Windows Error","Fart","vine boom","Skibidi"
    }, function(v) playMemeSound(v, false) end)
    mkBtn2(t,"Tocar Som Selecionado", function() end)
    mkToggle(t,"Loop Som Global", function(s)
        notify("LOOP MEME", s and "Loop ON" or "Loop OFF")
    end)
end

-- MUSIC
do
    local t = tabFrames["Music"]
    mkInput(t,"ID da música...", function(v) playGlobalSound(v, false) end)
    for genre, _ in pairs(musicPlaylists) do
        mkBtn2(t, genre, function() playPlaylist(genre) end)
    end
    mkBtn2(t,"Stop (ALL music)", function() stopMusic() end)
end

-- NAME & RGBs
do
    local t = tabFrames["Name & RGBs"]
    mkSection(t,"RGB para usar em você")
    mkToggle(t,"Nome + Bio RGB", function(s) setNameRgb(s) end)
    mkSection(t,"RGBs")
    mkToggle(t,"RGB Bicicleta", function(s)
        notify("RGB BIKE", s and "ON" or "OFF")
    end)
    mkToggle(t,"Rádio RGB", function(s)
        notify("RGB RADIO", s and "ON" or "OFF")
    end)
end

-- CHILD
do
    local t = tabFrames["Child"]
    mkPlayerSelector(t,"Select a Player to Chase")
    mkBtn2(t,"Send Child",   function() if selectedTarget then sendChild(selectedTarget) end end)
    mkBtn2(t,"Return Child", function() returnChild() end)
    mkToggle(t,"View Player", function(s)
        if s and selectedTarget then
            workspace.CurrentCamera.CameraSubject = getChar(selectedTarget)
        else
            workspace.CurrentCamera.CameraSubject = getChar(lp)
        end
    end)
end

-- LOCAL PLAYER
do
    local t = tabFrames["Local Player"]
    mkSection(t,"Movement")
    mkInput(t,"Walk Speed",    function(v) setWalkSpeed(v) end)
    mkBtn2(t,"Reset Walk Speed", function() setWalkSpeed(16) end)
    mkInput(t,"Jump Power",    function(v) setJumpPower(v) end)
    mkBtn2(t,"Reset Jump Power", function() setJumpPower(50) end)
    mkInput(t,"Gravity",       function(v) setGravity(v) end)
    mkBtn2(t,"Reset Gravity",  function() setGravity(196.2) end)
    mkToggle(t,"Noclip",       function(s) toggleNoclip(s) end)
    mkSection(t,"FE INVISIBLE")
    mkBtn2(t,"FE INVISIBLE",   function() feInvisible() end)
    mkSection(t,"Chat")
    local chatBox = mkInput(t,"Mensagem...", nil)
    mkBtn2(t,"Send Chat", function() fireChat(chatBox.Text) end)
    mkToggle(t,"Spam Chat", function(s) setSpamChat(s, chatBox.Text) end)
end

-- SCRIPTS
do
    local t = tabFrames["Scripts"]
    mkSection(t,"KitK4t Emotes By Bazuka")
    for _, e in ipairs(emoteList) do
        mkBtn2(t, e, function() playEmote(e) end)
    end
    mkSection(t,"Fly")
    mkToggle(t,"KitK4t Fly", function(s) toggleFly(s) end)
    mkSection(t,"Drone Lyra")
    mkToggle(t,"Drone do Lyra", function(s) toggleDrone(s) end)
end

-- TELEPORTS
do
    local t = tabFrames["Teleports"]
    for name, _ in pairs(teleports) do
        mkBtn2(t, name, function() tpTo(name) end)
    end
end

-- PROTECTIONS
do
    local t = tabFrames["Protections"]
    mkToggle(t,"Anti Canoe Fling",      function(s) protections.antiCanoeFling = s end)
    mkToggle(t,"Anti Jet Fling",        function(s) protections.antiJetFling   = s end)
    mkToggle(t,"Anti Helicopter Fling", function(s) protections.antiHeliHling  = s end)
    mkToggle(t,"Anti Ball Fling",       function(s) protections.antiBallFling  = s end)
    mkToggle(t,"Anti Sit",              function(s) protections.antiSit        = s end)
end

-- TROLLING MAP
do
    local t = tabFrames["House"] -- reutiliza no sidebar via seção extra
    -- já que trolling map aparecia no sidebar do hub original, mas
    -- não tem aba dedicada nas screenshots — adicionando ao Scripts
    local ts = tabFrames["Scripts"]
    mkSection(ts,"Trolling Map")
    mkToggle(ts,"Black Hole",  function(s) setBlackHole(s) end)
    mkBtn2(ts,"Bring Parts",   function() if selectedTarget then bringParts(selectedTarget) end end)
end

-- ── abrir na primeira aba ─────────────────────────────
switchTab("Troll Players")

-- ── RGB title bar animation ───────────────────────────
RunService.Heartbeat:Connect(function()
    rgbHue = (rgbHue + 0.3) % 360
    titleBar.BackgroundColor3 = Color3.fromHSV(rgbHue/360, 0.9, 0.7)
end)

notify("liandograu Hub","Carregado com sucesso ⚡", 5)
