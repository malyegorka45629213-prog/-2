-- ═══════════════════════════════════════════════════════════
--  MM2 Coin Autofarm  ·  [egor745top6]  
--  С КНОПКОЙ ВЫБОРА ЛИМИТА: 40 / 50 МОНЕТ
-- ═══════════════════════════════════════════════════════════

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- VARIABLES
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local visitedPositions = {}
local isActive = false
local flySpeed = 15
local collected = 0
local startTime = 0
local antiAFK = false
local isMurderer = false
local isSheriff = false
local bagFull = false
local isKilling = false

-- ════════════════════════════════════════════
--  ЛИМИТ МЕШКА (ПО УМОЛЧАНИЮ 40)
-- ════════════════════════════════════════════
local MAX_BAG = 40
local BAG_OPTIONS = {40, 50}

local function setBagLimit(value)
    MAX_BAG = value
    updateBagUI()
    print("📦 Лимит мешка изменён на:", MAX_BAG)
end

-- Проверка роли
local function checkRole()
    isMurderer = player:FindFirstChild("Murderer") ~= nil
    isSheriff = player:FindFirstChild("Sheriff") ~= nil
end
checkRole()

player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    visitedPositions = {}
    wait(0.5)
    checkRole()
end)

-- ─────────────────────────────────────────────
--  THEME + HELPERS (PURPLE THEME)
-- ─────────────────────────────────────────────
local COL = {
    bg      = Color3.fromRGB(15, 10, 25),
    card    = Color3.fromRGB(28, 18, 45),
    cardHov = Color3.fromRGB(38, 25, 60),
    off     = Color3.fromRGB(40, 30, 55),
    border  = Color3.fromRGB(60, 40, 80),
    text    = Color3.fromRGB(230, 220, 245),
    muted   = Color3.fromRGB(140, 120, 170),
    white   = Color3.fromRGB(255, 255, 255),
}
local ACCENT = {
    base  = Color3.fromRGB(155, 60, 255),
    dim   = Color3.fromRGB(60, 20, 100),
    light = Color3.fromRGB(200, 140, 255),
}

local function corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stroke(obj, color, th)
    local s = Instance.new("UIStroke", obj)
    s.Color = color
    s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function tw(obj, props, t, style)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- clean up
do
    local pg = player:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("AutoFarmGui")
    if old then old:Destroy() end
end

-- ─────────────────────────────────────────────
--  WINDOW
-- ─────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local collectSound = Instance.new("Sound")
collectSound.SoundId = "rbxassetid://12221967"
collectSound.Volume = 1
collectSound.Parent = gui

local killSound = Instance.new("Sound")
killSound.SoundId = "rbxassetid://9120392731"
killSound.Volume = 0.8
killSound.Parent = gui

local deathSound = Instance.new("Sound")
deathSound.SoundId = "rbxassetid://9120392731"
deathSound.Volume = 0.6
deathSound.Parent = gui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 520)
frame.Position = UDim2.new(0.5, -170, 0.5, -260)
frame.BackgroundColor3 = COL.bg
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui
corner(frame, 14)
stroke(frame, COL.border, 1.5)

-- top glow (PURPLE)
local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.new(1, 0, 0, 64)
topGlow.BackgroundColor3 = ACCENT.base
topGlow.BorderSizePixel = 0
topGlow.ZIndex = 0
topGlow.Parent = frame
corner(topGlow, 14)
do
    local g = Instance.new("UIGradient", topGlow)
    g.Rotation = 90
    g.Color = ColorSequence.new(ACCENT.base, COL.bg)
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.82),
        NumberSequenceKeypoint.new(1, 1),
    })
end

-- title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.ZIndex = 2
titleBar.Parent = frame

local dotColors = {Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}
local redDot
for i = 1, 3 do
    local d = Instance.new("Frame")
    d.Size = UDim2.new(0, 12, 0, 12)
    d.Position = UDim2.new(0, 14 + (i - 1) * 20, 0, 15)
    d.BackgroundColor3 = dotColors[i]
    d.BorderSizePixel = 0
    d.ZIndex = 3
    d.Parent = titleBar
    corner(d, 6)
    if i == 1 then redDot = d end
end

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -98, 1, 0)
titleLbl.Position = UDim2.new(0, 84, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "[egor745top6] Coin Farm"
titleLbl.TextColor3 = COL.text
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 14
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 2
titleLbl.Parent = titleBar

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -28, 0, 1)
sep.Position = UDim2.new(0, 14, 0, 42)
sep.BackgroundColor3 = COL.border
sep.BorderSizePixel = 0
sep.ZIndex = 2
sep.Parent = frame

-- drag
do
    local dragging, dragStart, startPos = false, nil, nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local delta = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- body
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -42)
body.Position = UDim2.new(0, 0, 0, 42)
body.BackgroundTransparency = 1
body.ZIndex = 2
body.Parent = frame
do
    local p = Instance.new("UIPadding", body)
    p.PaddingLeft = UDim.new(0, 14)
    p.PaddingRight = UDim.new(0, 14)
    p.PaddingTop = UDim.new(0, 8)
    p.PaddingBottom = UDim.new(0, 8)
    local l = Instance.new("UIListLayout", body)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 8)
end

-- ─────────────────────────────────────────────
--  COMPONENT BUILDERS
-- ─────────────────────────────────────────────
local function toggleCard(order, label)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = COL.card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 2
    card.Parent = body
    corner(card, 10)
    local cs = stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -90, 1, 0)
    t.Position = UDim2.new(0, 14, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = label
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 52, 0, 24)
    pill.Position = UDim2.new(1, -66, 0.5, -12)
    pill.BackgroundColor3 = COL.off
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = card
    corner(pill, 12)
    local ps = stroke(pill, COL.border, 1)

    local pl = Instance.new("TextLabel")
    pl.Size = UDim2.new(1, 0, 1, 0)
    pl.BackgroundTransparency = 1
    pl.Text = "OFF"
    pl.TextColor3 = COL.muted
    pl.Font = Enum.Font.GothamBold
    pl.TextSize = 11
    pl.ZIndex = 2
    pl.Parent = pill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = card

    local function setState(on)
        if on then
            tw(card, {BackgroundColor3 = ACCENT.dim})
            tw(cs, {Color = ACCENT.base})
            tw(pill, {BackgroundColor3 = ACCENT.base})
            tw(ps, {Color = ACCENT.base})
            pl.Text = "ON"
            tw(pl, {TextColor3 = COL.white})
        else
            tw(card, {BackgroundColor3 = COL.card})
            tw(cs, {Color = COL.border})
            tw(pill, {BackgroundColor3 = COL.off})
            tw(ps, {Color = COL.border})
            pl.Text = "OFF"
            tw(pl, {TextColor3 = COL.muted})
        end
    end

    btn.MouseEnter:Connect(function() if pl.Text == "OFF" then tw(card, {BackgroundColor3 = COL.cardHov}) end end)
    btn.MouseLeave:Connect(function() if pl.Text == "OFF" then tw(card, {BackgroundColor3 = COL.card}) end end)

    return btn, setState
end

local function statRow(order, name)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.ZIndex = 2
    row.Parent = body

    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0.62, 0, 1, 0)
    n.Position = UDim2.new(0, 2, 0, 0)
    n.BackgroundTransparency = 1
    n.Text = name
    n.TextColor3 = COL.muted
    n.Font = Enum.Font.Gotham
    n.TextSize = 13
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.ZIndex = 2
    n.Parent = row

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.38, -2, 1, 0)
    v.Position = UDim2.new(0.62, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.TextColor3 = ACCENT.light
    v.Font = Enum.Font.GothamBold
    v.TextSize = 13
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.ZIndex = 2
    v.Parent = row
    return v
end

local function sectionLabel(order, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 18)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = COL.muted
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order
    l.ZIndex = 2
    l.Parent = body
    return l
end

-- ── КНОПКА ДЛЯ ВЫБОРА ЛИМИТА ──
local function limitButton(order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = COL.card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 2
    card.Parent = body
    corner(card, 10)
    stroke(card, COL.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(0.6, 0, 1, 0)
    t.Position = UDim2.new(0, 14, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "Bag Limit:"
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 72, 0, 30)
    pill.Position = UDim2.new(0.75, 0, 0.5, -15)
    pill.BackgroundColor3 = ACCENT.base
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = card
    corner(pill, 8)
    stroke(pill, ACCENT.light, 1)

    local pillLabel = Instance.new("TextLabel")
    pillLabel.Size = UDim2.new(1, 0, 1, 0)
    pillLabel.BackgroundTransparency = 1
    pillLabel.Text = tostring(MAX_BAG) .. " 🪙"
    pillLabel.TextColor3 = COL.white
    pillLabel.Font = Enum.Font.GothamBold
    pillLabel.TextSize = 14
    pillLabel.ZIndex = 2
    pillLabel.Parent = pill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = card

    btn.MouseButton1Click:Connect(function()
        -- Переключаем лимит
        if MAX_BAG == 40 then
            setBagLimit(50)
        else
            setBagLimit(40)
        end
        pillLabel.Text = tostring(MAX_BAG) .. " 🪙"
        
        -- Анимация
        tw(pill, {Size = UDim2.new(0, 80, 0, 34)}, 0.1)
        task.wait(0.1)
        tw(pill, {Size = UDim2.new(0, 72, 0, 30)}, 0.1)
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "📦 Лимит изменён",
            Text = "Теперь: " .. tostring(MAX_BAG) .. " монет",
            Duration = 2
        })
    end)

    return card
end

-- controls
local farmBtn, farmSet = toggleCard(1, "Auto Farm")
local afkBtn,  afkSet  = toggleCard(2, "Anti-AFK")

-- speed
local speedCard = Instance.new("Frame")
speedCard.Size = UDim2.new(1, 0, 0, 44)
speedCard.BackgroundColor3 = COL.card
speedCard.BorderSizePixel = 0
speedCard.LayoutOrder = 3
speedCard.ZIndex = 2
speedCard.Parent = body
corner(speedCard, 10)
stroke(speedCard, COL.border, 1)
do
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -90, 1, 0)
    t.Position = UDim2.new(0, 14, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "Tween Speed"
    t.TextColor3 = COL.text
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 2
    t.Parent = speedCard
end

local speedPillLbl
do
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 52, 0, 24)
    pill.Position = UDim2.new(1, -66, 0.5, -12)
    pill.BackgroundColor3 = ACCENT.dim
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.Parent = speedCard
    corner(pill, 12)
    stroke(pill, ACCENT.base, 1)
    speedPillLbl = Instance.new("TextLabel")
    speedPillLbl.Size = UDim2.new(1, 0, 1, 0)
    speedPillLbl.BackgroundTransparency = 1
    speedPillLbl.Text = tostring(flySpeed)
    speedPillLbl.TextColor3 = ACCENT.light
    speedPillLbl.Font = Enum.Font.GothamBold
    speedPillLbl.TextSize = 12
    speedPillLbl.ZIndex = 2
    speedPillLbl.Parent = pill
end

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, 0, 1, 0)
speedBtn.BackgroundTransparency = 1
speedBtn.Text = ""
speedBtn.ZIndex = 3
speedBtn.Parent = speedCard

-- stats
sectionLabel(4, "STATS")
local counterVal = statRow(5, "Coins Collected")
local timerVal   = statRow(6, "Time Active")
local rateVal    = statRow(7, "Coins / Hour")

-- role info
sectionLabel(8, "ROLE INFO")
local roleVal = statRow(9, "Your Role")

-- bag status
sectionLabel(10, "BAG STATUS")
local bagVal = statRow(11, "Bag Full")

-- КНОПКА ЛИМИТА (вместо статичной строки)
limitButton(12)

-- reset
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 38)
resetBtn.BackgroundColor3 = COL.card
resetBtn.Text = "Reset Counter"
resetBtn.TextColor3 = COL.text
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 13
resetBtn.AutoButtonColor = false
resetBtn.LayoutOrder = 13
resetBtn.ZIndex = 2
resetBtn.Parent = body
corner(resetBtn, 10)
stroke(resetBtn, COL.border, 1)
resetBtn.MouseEnter:Connect(function() tw(resetBtn, {BackgroundColor3 = COL.cardHov}) end)
resetBtn.MouseLeave:Connect(function() tw(resetBtn, {BackgroundColor3 = COL.card}) end)

local function updateRoleUI()
    checkRole()
    if isMurderer then
        roleVal.Text = "🔪 Murderer"
        roleVal.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif isSheriff then
        roleVal.Text = "⭐ Sheriff"
        roleVal.TextColor3 = Color3.fromRGB(50, 150, 255)
    else
        roleVal.Text = "👤 Innocent"
        roleVal.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end
updateRoleUI()

local function updateBagUI()
    bagVal.Text = bagFull and "✅ FULL" or "❌ Empty"
    bagVal.TextColor3 = bagFull and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(100, 100, 100)
end
updateBagUI()

-- ─────────────────────────────────────────────
--  КНОПКА ДЛЯ ПЛАНШЕТА (💎)
-- ─────────────────────────────────────────────
local menuButton = Instance.new("TextButton")
menuButton.Size = UDim2.new(0, 65, 0, 65)
menuButton.Position = UDim2.new(0, 15, 1, -85)
menuButton.BackgroundColor3 = ACCENT.base
menuButton.Text = "💎"
menuButton.TextColor3 = COL.white
menuButton.TextSize = 28
menuButton.Font = Enum.Font.GothamBold
menuButton.ZIndex = 10
menuButton.Parent = gui
corner(menuButton, 32)
stroke(menuButton, ACCENT.light, 2)

menuButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ─────────────────────────────────────────────
--  КИНЕМАТОГРАФИЧНЫЕ ЭФФЕКТЫ
-- ─────────────────────────────────────────────

-- ЭФФЕКТ: Убийца достаёт меч и убивает всех
local function cinematicMurdererKill()
    if isKilling then return end
    isKilling = true
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not hrp or not hum then isKilling = false return end
    
    local center = Vector3.new(0, 5, 0)
    local players = Players:GetPlayers()
    
    hrp.CFrame = CFrame.new(center)
    wait(0.3)
    
    local sword = Instance.new("Tool")
    sword.Name = "MurdererSword"
    sword.TextureId = "rbxassetid://189130411"
    sword.GripPos = Vector3.new(0, -0.5, 0)
    sword.Parent = character
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {CFrame = CFrame.new(center + Vector3.new(0, 8, 0))}
    TweenService:Create(hrp, tweenInfo, goal):Play()
    wait(0.5)
    
    for _, v in pairs(players) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = v.Character.HumanoidRootPart
            local targetHum = v.Character:FindFirstChild("Humanoid")
            if targetHum then
                targetHum.PlatformStand = true
                targetHum.WalkSpeed = 0
            end
            targetHrp.CFrame = CFrame.new(targetHrp.Position, hrp.Position)
        end
    end
    
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(50, 50, 50)
    flash.Position = center
    flash.Anchored = true
    flash.CanCollide = false
    flash.Material = Enum.Material.Neon
    flash.BrickColor = BrickColor.new("Really black")
    flash.Transparency = 0.5
    flash.Parent = workspace
    Debris:AddItem(flash, 1)
    
    local light = Instance.new("PointLight")
    light.Brightness = 10
    light.Range = 50
    light.Color = Color3.fromRGB(155, 60, 255)
    light.Parent = flash
    
    wait(0.3)
    
    killSound:Play()
    for _, v in pairs(players) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") then
            v.Character.Humanoid.Health = 0
            local part = Instance.new("Part")
            part.Size = Vector3.new(3, 3, 3)
            part.Position = v.Character.HumanoidRootPart.Position
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new("Bright red")
            part.Transparency = 0.3
            part.Parent = workspace
            Debris:AddItem(part, 0.5)
        end
    end
    
    wait(0.5)
    hrp.CFrame = CFrame.new(center + Vector3.new(0, 0, 0))
    hum.PlatformStand = true
    
    wait(1)
    sword:Destroy()
    
    bagFull = false
    collected = 0
    counterVal.Text = "0"
    updateBagUI()
    
    hum.PlatformStand = false
    isKilling = false
end

-- ЭФФЕКТ: Шериф / Мирный умирает
local function cinematicDeath()
    if isKilling then return end
    isKilling = true
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not hrp or not hum then isKilling = false return end
    
    local center = Vector3.new(0, 5, 0)
    hrp.CFrame = CFrame.new(center)
    wait(0.3)
    
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(20, 20, 20)
    flash.Position = center
    flash.Anchored = true
    flash.CanCollide = false
    flash.Material = Enum.Material.Neon
    flash.BrickColor = BrickColor.new("Bright gold")
    flash.Transparency = 0.5
    flash.Parent = workspace
    Debris:AddItem(flash, 1)
    
    local light = Instance.new("PointLight")
    light.Brightness = 15
    light.Range = 40
    light.Color = Color3.fromRGB(255, 215, 0)
    light.Parent = flash
    
    deathSound:Play()
    
    wait(0.3)
    hum.Health = 0
    
    for i = 1, 20 do
        local coin = Instance.new("Part")
        coin.Size = Vector3.new(0.5, 0.1, 0.5)
        coin.Position = center + Vector3.new(
            math.random(-5, 5),
            math.random(0, 10),
            math.random(-5, 5)
        )
        coin.Anchored = false
        coin.CanCollide = false
        coin.Material = Enum.Material.Neon
        coin.BrickColor = BrickColor.new("Bright gold")
        coin.Parent = workspace
        
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVel.Velocity = Vector3.new(
            math.random(-20, 20),
            math.random(10, 30),
            math.random(-20, 20)
        )
        bodyVel.Parent = coin
        
        Debris:AddItem(coin, 2)
    end
    
    bagFull = false
    collected = 0
    counterVal.Text = "0"
    updateBagUI()
    
    isKilling = false
end

-- ─────────────────────────────────────────────
--  ANTI-AFK + NOCLIP
-- ─────────────────────────────────────────────
afkBtn.MouseButton1Click:Connect(function()
    antiAFK = not antiAFK
    afkSet(antiAFK)
end)

player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

RunService.Stepped:Connect(function()
    if isActive and character and not isKilling then
        for _, v in ipairs(character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- ─────────────────────────────────────────────
--  SPEED CYCLE
-- ─────────────────────────────────────────────
speedBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 1
    if flySpeed > 25 then flySpeed = 10 end
    speedPillLbl.Text = tostring(flySpeed)
end)

-- ─────────────────────────────────────────────
--  FLY TO
-- ─────────────────────────────────────────────
local function flyTo(pos, speed)
    if not rootPart or isKilling then return end
    local distance = (pos - rootPart.Position).Magnitude
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(pos)}
    local tween = TweenService:Create(rootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- ─────────────────────────────────────────────
--  RESET
-- ─────────────────────────────────────────────
resetBtn.MouseButton1Click:Connect(function()
    collected = 0
    startTime = tick()
    counterVal.Text = "0"
    timerVal.Text = "0s"
    rateVal.Text = "0"
    bagFull = false
    updateBagUI()
end)

-- ─────────────────────────────────────────────
--  MAIN FARM LOOP
-- ─────────────────────────────────────────────
farmBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    farmSet(isActive)
    
    if isActive then
        collected = 0
        startTime = tick()
        visitedPositions = {}
        bagFull = false
        counterVal.Text = "0"
        updateRoleUI()
        updateBagUI()
        
        task.spawn(function()
            while isActive do
                local elapsed = tick() - startTime
                timerVal.Text = math.floor(elapsed) .. "s"
                local rate = elapsed > 0 and math.floor((collected / elapsed) * 3600) or 0
                rateVal.Text = tostring(rate)
                task.wait(0.1)
            end
        end)
        
        task.spawn(function()
            while isActive do
                if isKilling then 
                    task.wait(1)
                    continue 
                end
                
                character = player.Character or player.CharacterAdded:Wait()
                rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    checkRole()
                    
                    local closest, shortest = nil, math.huge
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
                            local dist = (obj.Position - rootPart.Position).Magnitude
                            if dist < shortest and dist < 250 and not visitedPositions[obj] then
                                closest = obj
                                shortest = dist
                            end
                        end
                    end
                    
                    if closest and closest.Parent and closest:IsDescendantOf(workspace) then
                        flyTo(closest.Position, flySpeed)
                        if closest and closest.Parent and closest:IsDescendantOf(workspace) then
                            visitedPositions[closest] = true
                            collected = collected + 1
                            collectSound:Play()
                            counterVal.Text = tostring(collected)
                            
                            -- ═══════════════════════════════════════
                            --  ПРОВЕРКА ЛИМИТА (40 или 50 монет)
                            -- ═══════════════════════════════════════
                            if collected >= MAX_BAG and not bagFull and not isKilling then
                                bagFull = true
                                updateBagUI()
                                
                                checkRole()
                                if isMurderer then
                                    cinematicMurdererKill()
                                else
                                    cinematicDeath()
                                end
                                bagFull = false
                                updateBagUI()
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

print("✅ [egor745top6] Coin Farm loaded!")
print("📱 Планшет: кнопка 💎 в левом нижнем углу")
print("🎒 Лимит мешка:", MAX_BAG, "монет (нажми кнопку Bag Limit чтобы сменить)")
print("🎯 Role:", isMurderer and "Murderer" or isSheriff and "Sheriff" or "Innocent")
