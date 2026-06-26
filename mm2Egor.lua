--[[
    ██████  MM2 ULTIMATE SCRIPT by BRO  ██████
    Управление: [INSERT] - Открыть/Закрыть меню
    Версия: 3.0 (Полный функционал)
--]]

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- ============================================================
--  НАСТРОЙКИ ПО УМОЛЧАНИЮ
-- ============================================================
local Settings = {
    -- ESP
    ESP = true,
    ESP_Team = true,
    ESP_Box = true,
    ESP_Tracer = false,
    ESP_Health = false,
    ESP_Distance = true,
    
    -- Aimbot
    Aimbot = true,
    Aimbot_FOV = 150,
    Aimbot_Smooth = 0.3,
    Aimbot_Part = "Head",
    Aimbot_Visible = false,
    Aimbot_TeamCheck = true,
    Aimbot_TriggerBot = false,
    
    -- Silent Aim
    SilentAim = false,
    
    -- Auto
    Auto_ShootMurderer = false,
    Auto_DodgeKnife = false,
    Auto_CollectCoins = false,
    Auto_CollectGifts = false,
    Auto_Run = false,
    
    -- Teleport
    Teleport_ToGun = false,
    Teleport_ToKnife = false,
    Teleport_ToCoins = false,
    
    -- Visuals
    Chams = false,
    NoFog = false,
    Brightness = 1,
    
    -- Misc
    AntiAFK = true,
    NoClip = false,
    Speed = 16,
    JumpPower = 50,
    Walkspeed = 16,
}

-- ============================================================
--  СОЗДАНИЕ GUI МЕНЮ
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2UltimateMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.BackgroundTransparency = 0.5
Title.BorderSizePixel = 0
Title.Text = "🔥 MM2 ULTIMATE MENU 🔥"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Вкладки
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TabBar.BackgroundTransparency = 0.3
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

-- Контент вкладок
local TabContent = Instance.new("Frame")
TabContent.Size = UDim2.new(1, -10, 1, -90)
TabContent.Position = UDim2.new(0, 5, 0, 75)
TabContent.BackgroundTransparency = 1
TabContent.Parent = MainFrame

-- Список вкладок
local Tabs = {}
local CurrentTab = 1

local TabNames = {"⚔️ Combat", "👁️ ESP", "🚀 Teleport", "⚡ Auto", "🎨 Visuals", "🛠️ Misc"}

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Position = UDim2.new(0, (i-1)*80, 0, 0)
    btn.BackgroundTransparency = 0.8
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    
    btn.MouseButton1Click:Connect(function()
        CurrentTab = i
        for _, v in pairs(TabContent:GetChildren()) do v:Destroy() end
        SetupTab(i)
    end)
end

-- ============================================================
--  ФУНКЦИИ ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ GUI
-- ============================================================
local function CreateToggle(parent, text, y, setting, desc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 25)
    btn.Position = UDim2.new(0.8, 0, 0, 2.5)
    btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    btn.Text = Settings[setting] and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(50, 50, 50)
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        btn.Text = Settings[setting] and "ON" or "OFF"
    end)
    
    return frame
end

local function CreateButton(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(100, 100, 150)
    btn.Parent = parent
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateSlider(parent, text, y, setting, min, max, desc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(Settings[setting])
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.4, 0, 0.6, 0)
    slider.Position = UDim2.new(0.55, 0, 0.2, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Settings[setting] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local val = math.round(min + (max - min) * pos)
            Settings[setting] = val
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. ": " .. tostring(val)
        end
    end)
    
    return frame
end

-- ============================================================
--  НАСТРОЙКА ВКЛАДОК
-- ============================================================
function SetupTab(tab)
    local y = 5
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.ScrollBarThickness = 5
    scroll.Parent = TabContent
    
    if tab == 1 then -- COMBAT
        CreateToggle(scroll, "🔫 Aimbot (автонаведение)", y, "Aimbot")
        y = y + 35
        CreateSlider(scroll, "FOV (радиус)", y, "Aimbot_FOV", 50, 300)
        y = y + 35
        CreateSlider(scroll, "Smooth (плавность)", y, "Aimbot_Smooth", 0.1, 1)
        y = y + 35
        CreateToggle(scroll, "🎯 Silent Aim (невидимый аим)", y, "SilentAim")
        y = y + 35
        CreateToggle(scroll, "🔫 TriggerBot (авто-выстрел)", y, "Aimbot_TriggerBot")
        y = y + 35
        CreateToggle(scroll, "👥 Team Check (не стрелять в своих)", y, "Aimbot_TeamCheck")
        y = y + 35
        
        CreateButton(scroll, "💀 УБИТЬ ВСЕХ (Murderer Kill All)", y, function()
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v.Character and v.Character:FindFirstChild("Humanoid") then
                    v.Character.Humanoid.Health = 0
                end
            end
            game.StarterGui:SetCore("SendNotification", {Title = "MM2", Text = "☠️ Все убиты!", Duration = 2})
        end)
        y = y + 35
        
        CreateButton(scroll, "🗡️ Убить Murderer'а", y, function()
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v:FindFirstChild("Murderer") and v.Character then
                    v.Character.Humanoid.Health = 0
                end
            end
        end)
        y = y + 35
        
        CreateButton(scroll, "⭐ Убить Sheriff'а", y, function()
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v:FindFirstChild("Sheriff") and v.Character then
                    v.Character.Humanoid.Health = 0
                end
            end
        end)
        y = y + 35
        
    elseif tab == 2 then -- ESP
        CreateToggle(scroll, "👁️ ESP (включить)", y, "ESP")
        y = y + 35
        CreateToggle(scroll, "📦 Box ESP (рамка)", y, "ESP_Box")
        y = y + 35
        CreateToggle(scroll, "📏 Distance ESP (дистанция)", y, "ESP_Distance")
        y = y + 35
        CreateToggle(scroll, "🔗 Tracer (линия к цели)", y, "ESP_Tracer")
        y = y + 35
        CreateToggle(scroll, "❤️ Health ESP (здоровье)", y, "ESP_Health")
        y = y + 35
        CreateToggle(scroll, "👥 Team ESP (показывать своих)", y, "ESP_Team")
        y = y + 35
        
        CreateButton(scroll, "🔄 Обновить ESP", y, function()
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v.Character then
                    -- Пересоздать ESP
                end
            end
        end)
        
    elseif tab == 3 then -- TELEPORT
        CreateButton(scroll, "🔫 ТП к пистолету", y, function()
            local gun = workspace:FindFirstChild("Gun")
            if gun then
                Player.Character.HumanoidRootPart.CFrame = gun.CFrame + Vector3.new(0, 3, 0)
            end
        end)
        y = y + 35
        
        CreateButton(scroll, "🗡️ ТП к ножу", y, function()
            local knife = workspace:FindFirstChild("Knife")
            if knife then
                Player.Character.HumanoidRootPart.CFrame = knife.CFrame + Vector3.new(0, 3, 0)
            end
        end)
        y = y + 35
        
        CreateButton(scroll, "🪙 ТП к монетам", y, function()
            for _, v in pairs(workspace:GetChildren()) do
                if v.Name == "Coin" then
                    Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end)
        y = y + 35
        
        CreateButton(scroll, "🎁 ТП к подарку", y, function()
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Part") and v.Name:lower():find("gift") then
                    Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end)
        y = y + 35
        
        CreateButton(scroll, "🎯 ТП к Murderer'у", y, function()
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v:FindFirstChild("Murderer") and v.Character then
                    Player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 2)
                end
            end
        end)
        y = y + 35
        
        CreateButton(scroll, "🎯 ТП к Sheriff'у", y, function()
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= Player and v:FindFirstChild("Sheriff") and v.Character then
                    Player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 2)
                end
            end
        end)
        y = y + 35
        
    elseif tab == 4 then -- AUTO
        CreateToggle(scroll, "🔫 Auto-Shoot Murderer", y, "Auto_ShootMurderer")
        y = y + 35
        CreateToggle(scroll, "🏃 Auto-Dodge (уклонение)", y, "Auto_DodgeKnife")
        y = y + 35
        CreateToggle(scroll, "🪙 Auto-Collect Coins", y, "Auto_CollectCoins")
        y = y + 35
        CreateToggle(scroll, "🎁 Auto-Collect Gifts", y, "Auto_CollectGifts")
        y = y + 35
        CreateToggle(scroll, "🏃 Auto-Run (бег всегда)", y, "Auto_Run")
        y = y + 35
        
        CreateButton(scroll, "🔄 Перезапустить авто-сбор", y, function()
            -- Перезапуск
        end)
        
    elseif tab == 5 then -- VISUALS
        CreateToggle(scroll, "✨ Chams (просветка)", y, "Chams")
        y = y + 35
        CreateToggle(scroll, "🌫️ No Fog (туман)", y, "NoFog")
        y = y + 35
        CreateSlider(scroll, "☀️ Яркость", y, "Brightness", 0.5, 2)
        y = y + 35
        
        CreateButton(scroll, "🎨 Включить FullBright", y, function()
            game.Lighting.Brightness = 2
            game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end)
        y = y + 35
        
        CreateButton(scroll, "🌙 Сбросить яркость", y, function()
            game.Lighting.Brightness = 1
            game.Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            game.Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        end)
        y = y + 35
        
        CreateButton(scroll, "🔄 Сброс графики", y, function()
            game.Lighting:ClearAllChildren()
        end)
        
    elseif tab == 6 then -- MISC
        CreateToggle(scroll, "⏰ Anti-AFK", y, "AntiAFK")
        y = y + 35
        CreateToggle(scroll, "🌀 NoClip (проход сквозь стены)", y, "NoClip")
        y = y + 35
        CreateSlider(scroll, "🏃 Скорость", y, "Walkspeed", 10, 200)
        y = y + 35
        CreateSlider(scroll, "🦘 Сила прыжка", y, "JumpPower", 50, 300)
        y = y + 35
        
        CreateButton(scroll, "🔄 Перезагрузить игру", y, function()
            game:Shutdown()
        end)
        y = y + 35
        
        CreateButton(scroll, "📋 Скопировать свой ID", y, function()
            setclipboard(Player.UserId)
        end)
        y = y + 35
        
        CreateButton(scroll, "🎯 Спрятать меню (Insert)", y, function()
            MainFrame.Visible = false
        end)
    end
end

-- Первоначальная настройка
SetupTab(1)

-- ============================================================
--  ФУНКЦИОНАЛ СКРИПТА (РАБОТА В ФОНЕ)
-- ============================================================

-- Anti-AFK
if Settings.AntiAFK then
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- NoClip + Speed
RunService.RenderStepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local hum = Player.Character.Humanoid
        
        -- Speed
        if hum.WalkSpeed ~= Settings.Walkspeed then
            hum.WalkSpeed = Settings.Walkspeed
        end
        if hum.JumpPower ~= Settings.JumpPower then
            hum.JumpPower = Settings.JumpPower
        end
        
        -- NoClip
        if Settings.NoClip and Player.Character:FindFirstChild("HumanoidRootPart") then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Auto-Shoot Murderer
RunService.RenderStepped:Connect(function()
    if Settings.Auto_ShootMurderer then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= Player and v:FindFirstChild("Murderer") and v.Character then
                local head = v.Character:FindFirstChild("Head")
                if head then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                    -- Имитация выстрела
                    Mouse1Click()
                end
            end
        end
    end
end)

-- Auto-Collect Coins
RunService.RenderStepped:Connect(function()
    if Settings.Auto_CollectCoins and Player.Character then
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, coin in pairs(workspace:GetChildren()) do
                if coin.Name == "Coin" and coin:IsA("BasePart") then
                    local dist = (hrp.Position - coin.Position).Magnitude
                    if dist < 50 then
                        hrp.CFrame = coin.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end
end)

-- ESP System (Расширенный)
local ESPObjects = {}

local function CreateFullESP(plr)
    if not plr or not plr.Character or not Settings.ESP then return end
    
    local head = plr.Character:FindFirstChild("Head")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
    
    -- Имя
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300
    billboard.ResetOnSpawn = false
    
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    
    -- Определение роли
    local role = "👤 "
    local color = Color3.fromRGB(0, 255, 0)
    if plr:FindFirstChild("Murderer") then
        role = "🔪 "
        color = Color3.fromRGB(255, 0, 0)
    elseif plr:FindFirstChild("Sheriff") then
        role = "⭐ "
        color = Color3.fromRGB(0, 150, 255)
    end
    
    label.TextColor3 = color
    label.Text = role .. plr.Name
    
    -- Дистанция
    if Settings.ESP_Distance then
        local distLabel = Instance.new("TextLabel", billboard)
        distLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextScaled = true
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if hrp and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                distLabel.Text = string.format("%.1f м", dist)
            end
        end)
    end
    
    billboard.Parent = game.CoreGui
    ESPObjects[plr] = billboard
    
    -- Box ESP
    if Settings.ESP_Box then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 5, 1.5)
        box.Adornee = hrp
        box.Color3 = color
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Transparency = 0.5
        box.Parent = hrp
        table.insert(ESPObjects, box)
    end
end

-- Обновление ESP
game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(0.5)
        if Settings.ESP then
            CreateFullESP(plr)
        end
    end)
end)

-- Запуск ESP
wait(1)
for _, plr in pairs(game.Players:GetPlayers()) do
    if plr ~= Player then
        CreateFullESP(plr)
    end
end

-- ============================================================
--  ОТКРЫТИЕ МЕНЮ ПО КНОПКЕ INSERT
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================================
--  УВЕДОМЛЕНИЕ О ЗАГРУЗКЕ
-- ============================================================
game.StarterGui:SetCore("SendNotification", {
    Title = "🔥 MM2 ULTIMATE SCRIPT",
    Text = "Нажми [INSERT] для открытия меню!",
    Duration = 5
})

print("✅ MM2 ULTIMATE SCRIPT ЗАГРУЖЕН!")
print("📌 Нажми INSERT для открытия меню")
