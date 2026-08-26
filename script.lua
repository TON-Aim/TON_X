if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "TON HUB | ULTIMATE PRO",
    LoadingTitle = "Loading TON HUB...",
    LoadingSubtitle = "By Ton",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TonHub",
        FileName = "Config"
    },
    KeySystem = true, 
    KeySettings = {
        Title = "TON HUB - Key System",
        Subtitle = "กรุณาใส่คีย์เพื่อใช้งาน",
        Note = "คีย์สำหรับใช้งานคือ: TONVIP2026",
        FileName = "TonHubKey",
        SaveKey = true, 
        GrabKeyFromSite = false,
        Key = {"TONVIP2026", "TONFREE"}
    }
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

local Config = {
    SilentAimEnabled = false, ShowFOV = false, FOVRadius = 150, TargetPart = "HumanoidRootPart", TargetType = "Players",
    OffsetX = 0, OffsetY = 0, -- เพิ่มการตั้งค่า Offset X และ Y
    NoFogEnabled = false, ZoomEnabled = false,
    ESPTextEnabled = false, ESPChamsEnabled = false,
    SpeedEnabled = false, SpeedValue = 50,
    JumpEnabled = false, JumpValue = 50
}

local FOVring = Drawing.new("Circle")
FOVring.Thickness = 1.5
FOVring.Filled = false

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    local guiInset = GuiService:GetGuiInset()
    
    -- วาดวง FOV โดยบวกค่า Offset X และ Y ที่เราตั้งในเมนูเข้าไป
    FOVring.Position = Vector2.new(mousePos.X + Config.OffsetX, mousePos.Y - guiInset.Y + Config.OffsetY)
    FOVring.Radius = Config.FOVRadius
    FOVring.Visible = Config.ShowFOV
    FOVring.Color = Config.TargetType == "Players" and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
end)

local function getClosestTargetToCursor()
    local closestTarget, shortestDistance = nil, Config.FOVRadius
    local mousePos = UserInputService:GetMouseLocation()
    local guiInset = GuiService:GetGuiInset()
    -- คำนวณจุดศูนย์กลางของวง FOV ที่รวมค่า Offset แล้ว เพื่อให้ Aimbot เล็งตรงกับวงที่ตาเห็นเป๊ะๆ
    local fovCenter = Vector2.new(mousePos.X + Config.OffsetX, mousePos.Y - guiInset.Y + Config.OffsetY)
    local targetList = {}
    
    if Config.TargetType == "Players" then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then table.insert(targetList, v.Character) end
        end
    elseif Config.TargetType == "Mobs" then
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        local list = enemiesFolder and enemiesFolder:GetChildren() or workspace:GetChildren()
        for _, v in pairs(list) do
            if v:IsA("Model") and not Players:GetPlayerFromCharacter(v) then table.insert(targetList, v) end
        end
    end

    for _, char in pairs(targetList) do
        if char:FindFirstChild(Config.TargetPart) and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(char[Config.TargetPart].Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - fovCenter).Magnitude
                if distance < shortestDistance then
                    closestTarget = char
                    shortestDistance = distance
                end
            end
        end
    end
    return closestTarget
end

local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, key)
    if Config.SilentAimEnabled and not checkcaller() and (key == "Hit" or key == "Target") then
        if typeof(self) == "Instance" and self:IsA("Mouse") then
            local targetChar = getClosestTargetToCursor()
            if targetChar and targetChar:FindFirstChild(Config.TargetPart) then
                return key == "Hit" and targetChar[Config.TargetPart].CFrame or targetChar[Config.TargetPart]
            end
        end
    end
    return oldIndex(self, key)
end)
setreadonly(mt, true)

RunService.RenderStepped:Connect(function()
    if Config.NoFogEnabled then
        Lighting.FogEnd = 1000000
        Lighting.ClockTime = 12
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then v:Destroy() end
        end
    end
    
    if Config.ZoomEnabled then
        LocalPlayer.CameraMaxZoomDistance = 100000
        LocalPlayer.CameraMinZoomDistance = 0.5
    else
        LocalPlayer.CameraMaxZoomDistance = 400
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if Config.SpeedEnabled then char.Humanoid.WalkSpeed = Config.SpeedValue end
        if Config.JumpEnabled then char.Humanoid.JumpPower = Config.JumpValue end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pChar = player.Character
            local hum = pChar:FindFirstChild("Humanoid")
            
            local highlight = pChar:FindFirstChild("ESP_Chams")
            if Config.ESPChamsEnabled and hum and hum.Health > 0 then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Chams"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = pChar
                end
            else
                if highlight then highlight:Destroy() end
            end

            local bgGui = pChar:FindFirstChild("ESP_Text")
            if Config.ESPTextEnabled and hum and hum.Health > 0 then
                if not bgGui then
                    bgGui = Instance.new("BillboardGui")
                    bgGui.Name = "ESP_Text"
                    bgGui.AlwaysOnTop = true
                    bgGui.Size = UDim2.new(0, 100, 0, 50)
                    bgGui.ExtentsOffset = Vector3.new(0, 3, 0)
                    local txt = Instance.new("TextLabel")
                    txt.Name = "Label"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                    txt.TextStrokeTransparency = 0
                    txt.TextSize = 12
                    txt.Parent = bgGui
                    bgGui.Parent = pChar
                end
                
                local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = myPos and math.floor((pChar.HumanoidRootPart.Position - myPos.Position).Magnitude) or 0
                local level = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Level")
                local lvlText = level and level.Value or "?"
                
                bgGui.Label.Text = string.format("%s\nLv: %s | HP: %d\n[%dm]", player.Name, tostring(lvlText), hum.Health, dist)
            else
                if bgGui then bgGui:Destroy() end
            end
        end
    end
end)

local AimTab = Window:CreateTab("Aimbot", 4483362458)
AimTab:CreateDropdown({Name = "Aim Target", Options = {"Players", "Mobs"}, CurrentOption = {"Players"}, Callback = function(v) Config.TargetType = v[1] end})
AimTab:CreateToggle({Name = "Show FOV", CurrentValue = false, Callback = function(v) Config.ShowFOV = v end})
AimTab:CreateSlider({Name = "FOV Size", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) Config.FOVRadius = v end})

-- เพิ่ม Slider สำหรับปรับตำแหน่งวง FOV ให้ตรงกับเมาส์
AimTab:CreateSlider({Name = "ปรับตำแหน่งวง X (ซ้าย-ขวา)", Range = {-200, 200}, Increment = 1, CurrentValue = 0, Callback = function(v) Config.OffsetX = v end})
AimTab:CreateSlider({Name = "ปรับตำแหน่งวง Y (บน-ล่าง)", Range = {-200, 200}, Increment = 1, CurrentValue = 0, Callback = function(v) Config.OffsetY = v end})

AimTab:CreateToggle({Name = "Enable Silent Aim", CurrentValue = false, Callback = function(v) Config.SilentAimEnabled = v end})

local ESPTab = Window:CreateTab("ESP System", 4483362458)
ESPTab:CreateToggle({Name = "ESP Text (แสดงชื่อ เลือด ระยะ)", CurrentValue = false, Callback = function(v) Config.ESPTextEnabled = v end})
ESPTab:CreateToggle({Name = "ESP Chams (ไฮไลท์ตัวสีๆ มองทะลุกำแพง)", CurrentValue = false, Callback = function(v) Config.ESPChamsEnabled = v end})

local MoveTab = Window:CreateTab("Movement", 4483362458)
MoveTab:CreateSlider({Name = "Speed Value", Range = {16, 250}, Increment = 5, CurrentValue = 50, Callback = function(v) Config.SpeedValue = v end})
MoveTab:CreateToggle({Name = "Enable Fast Walk", CurrentValue = false, Callback = function(v) Config.SpeedEnabled = v end})
MoveTab:CreateSlider({Name = "Jump Value", Range = {50, 300}, Increment = 10, CurrentValue = 100, Callback = function(v) Config.JumpValue = v end})
MoveTab:CreateToggle({Name = "Enable High Jump", CurrentValue = false, Callback = function(v) Config.JumpEnabled = v end})

local VisualsTab = Window:CreateTab("Visuals", 4483362458)
VisualsTab:CreateToggle({Name = "Enable No Fog", CurrentValue = false, Callback = function(v) Config.NoFogEnabled = v end})
VisualsTab:CreateToggle({Name = "Enable Infinite Zoom", CurrentValue = false, Callback = function(v) Config.ZoomEnabled = v end})
