if not game:IsLoaded() then game.Loaded:Wait() end

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- 0. ตั้งค่าระบบโปร (Config)
-- ==========================================
local Config = {
    SilentAimEnabled = false, ShowFOV = false, FOVRadius = 150, TargetPart = "HumanoidRootPart", TargetType = "Players",
    NoFogEnabled = false, ZoomEnabled = false,
    ESPTextEnabled = false, ESPChamsEnabled = false,
    SpeedEnabled = false, SpeedValue = 50,
    JumpEnabled = false, JumpValue = 100
}

-- ลบ UI เก่าออกถ้ามี
local oldGui = CoreGui:FindFirstChild("TonCustomUI")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TonCustomUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- แก้บัคพิกัดเพี้ยนเวลาตั้งจอ 125% และแก้ UI ไหล

-- สีหลักของ UI
local Colors = {
    MainBg = Color3.fromRGB(160, 210, 255), 
    Border = Color3.fromRGB(40, 160, 60),   
    TabBg = Color3.fromRGB(180, 240, 180),  
    Text = Color3.fromRGB(20, 100, 160),
    ElementBg = Color3.fromRGB(140, 190, 235),
    Active = Color3.fromRGB(50, 200, 100)
}

-- ฟังก์ชันทำให้ลากได้
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
            dragInput = input 
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- 1. สร้าง UI โครงสร้างหลัก (T Button & Main Frame)
-- ==========================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Colors.MainBg
ToggleBtn.Text = "T"
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.FredokaOne
ToggleBtn.TextColor3 = Colors.Text
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color = Colors.Border
tStroke.Thickness = 2
MakeDraggable(ToggleBtn)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 380)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -190)
MainFrame.BackgroundColor3 = Colors.MainBg
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", MainFrame)
mStroke.Color = Colors.Border
mStroke.Thickness = 2
MakeDraggable(MainFrame)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 10)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame
local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -20, 1, -56)
ContentArea.Position = UDim2.new(0, 10, 0, 48)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Pages = {}

local function CreateTab(name, text)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Size = UDim2.new(0, 95, 1, 0)
    TabBtn.BackgroundColor3 = Colors.TabBg
    TabBtn.Text = text
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 13
    TabBtn.TextColor3 = Colors.Text
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    local tst = Instance.new("UIStroke", TabBtn)
    tst.Color = Colors.Text
    tst.Thickness = 0.8
    tst.Transparency = 0.5
    
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.Visible = false
    Page.Parent = ContentArea
    local pLayout = Instance.new("UIListLayout", Page)
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 8)
    
    Pages[name] = Page
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
    end)
    return Page
end

local AimPage = CreateTab("Aim", "AIM")
local EpsPage = CreateTab("Eps", "EPS")
local MovemanPage = CreateTab("Moveman", "MOVEMAN")
local VisionPage = CreateTab("Vision", "VISION")
AimPage.Visible = true

-- ==========================================
-- 2. ฟังก์ชันสร้างชิ้นส่วน UI (ปุ่มกด, ตัวเลื่อน)
-- ==========================================
local function CreateToggle(parent, text, default, callback)
    local state = default
    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundColor3 = Colors.ElementBg
    ToggleFrame.Text = "  " .. text
    ToggleFrame.TextXAlignment = Enum.TextXAlignment.Left
    ToggleFrame.Font = Enum.Font.GothamMedium
    ToggleFrame.TextSize = 13
    ToggleFrame.TextColor3 = Colors.Text
    ToggleFrame.Parent = parent
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    
    local Status = Instance.new("Frame")
    Status.Size = UDim2.new(0, 20, 0, 20)
    Status.Position = UDim2.new(1, -25, 0.5, -10)
    Status.BackgroundColor3 = state and Colors.Active or Color3.fromRGB(200, 50, 50)
    Status.Parent = ToggleFrame
    Instance.new("UICorner", Status).CornerRadius = UDim.new(1, 0)
    
    ToggleFrame.MouseButton1Click:Connect(function()
        state = not state
        Status.BackgroundColor3 = state and Colors.Active or Color3.fromRGB(200, 50, 50)
        callback(state)
    end)
end

-- 🔴 แก้ไขตรงนี้: ปรับ Slider ให้หลอดอ้วนขึ้น กดยากน้อยลง 🔴
local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 48) -- ขยายกรอบให้สูงขึ้นรับกับหลอดที่อ้วนขึ้น
    SliderFrame.BackgroundColor3 = Colors.ElementBg
    SliderFrame.Parent = parent
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0.4, 0)
    Label.Position = UDim2.new(0, 5, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextColor3 = Colors.Text
    Label.Parent = SliderFrame
    
    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -20, 0, 14) -- ปรับหลอดให้อ้วนขึ้น (จาก 6 เป็น 14)
    BarBg.Position = UDim2.new(0, 10, 0.55, 0) -- จัดให้อยู่ตรงกลางพอดี
    BarBg.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    BarBg.Parent = SliderFrame
    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
    
    local BarFill = Instance.new("Frame")
    local pct = (default - min) / (max - min)
    BarFill.Size = UDim2.new(pct, 0, 1, 0)
    BarFill.BackgroundColor3 = Colors.Active
    BarFill.Parent = BarBg
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
        BarFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + ((max - min) * pos))
        Label.Text = text .. ": " .. val
        callback(val)
    end
    
    BarBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
end

local function CreateCycle(parent, text, options, defaultIdx, callback)
    local idx = defaultIdx
    local CycleBtn = Instance.new("TextButton")
    CycleBtn.Size = UDim2.new(1, 0, 0, 30)
    CycleBtn.BackgroundColor3 = Colors.ElementBg
    CycleBtn.Text = string.format("  %s: [ %s ]", text, options[idx])
    CycleBtn.TextXAlignment = Enum.TextXAlignment.Left
    CycleBtn.Font = Enum.Font.GothamMedium
    CycleBtn.TextSize = 13
    CycleBtn.TextColor3 = Colors.Text
    CycleBtn.Parent = parent
    Instance.new("UICorner", CycleBtn).CornerRadius = UDim.new(0, 6)
    
    CycleBtn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        CycleBtn.Text = string.format("  %s: [ %s ]", text, options[idx])
        callback(options[idx])
    end)
end

-- ==========================================
-- 3. ยัดเมนูเข้าหน้าต่างๆ (ตามสคริปต์โปร)
-- ==========================================
-- AIM PAGE
CreateCycle(AimPage, "Aim Target", {"Players", "Mobs"}, 1, function(val) Config.TargetType = val end)
CreateToggle(AimPage, "Show FOV (วงกลมล็อคเป้า)", false, function(val) Config.ShowFOV = val end)
CreateToggle(AimPage, "Enable Silent Aim", false, function(val) Config.SilentAimEnabled = val end)
CreateSlider(AimPage, "FOV Size", 50, 800, 150, function(val) Config.FOVRadius = val end)

-- ESP PAGE
CreateToggle(EpsPage, "ESP Text (ชื่อ, เลือด, ระยะ)", false, function(val) Config.ESPTextEnabled = val end)
CreateToggle(EpsPage, "ESP Chams (ไฮไลท์ทะลุกำแพง)", false, function(val) Config.ESPChamsEnabled = val end)

-- MOVEMENT PAGE
CreateToggle(MovemanPage, "Enable Fast Walk", false, function(val) Config.SpeedEnabled = val end)
CreateSlider(MovemanPage, "Speed Value", 16, 250, 50, function(val) Config.SpeedValue = val end)
CreateToggle(MovemanPage, "Enable High Jump", false, function(val) Config.JumpEnabled = val end)
CreateSlider(MovemanPage, "Jump Value", 50, 300, 100, function(val) Config.JumpValue = val end)

-- VISION PAGE
CreateToggle(VisionPage, "Enable No Fog (ลบหมอก)", false, function(val) Config.NoFogEnabled = val end)
CreateToggle(VisionPage, "Enable Infinite Zoom", false, function(val) Config.ZoomEnabled = val end)

-- ==========================================
-- 4. โค้ดระบบโปร (Aimbot, ESP, ฯลฯ ของจริง)
-- ==========================================
local FOVring = Drawing.new("Circle")
FOVring.Thickness = 1.5
FOVring.Filled = false

local function getClosestTargetToMouse()
    local closestTarget, shortestDistance = nil, Config.FOVRadius
    -- ดึงพิกัดจากเมาส์โดยตรงแทนจุดกึ่งกลางจอ
    local mousePos = UserInputService:GetMouseLocation()
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
                -- คำนวณระยะห่างระหว่างเป้าหมายกับเมาส์แทนจอ
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    closestTarget = char
                    shortestDistance = distance
                end
            end
        end
    end
    return closestTarget
end

-- Silent Aim Hooking
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, key)
    if Config.SilentAimEnabled and not checkcaller() and (key == "Hit" or key == "Target") then
        if typeof(self) == "Instance" and self:IsA("Mouse") then
            local targetChar = getClosestTargetToMouse()
            if targetChar and targetChar:FindFirstChild(Config.TargetPart) then
                return key == "Hit" and targetChar[Config.TargetPart].CFrame or targetChar[Config.TargetPart]
            end
        end
    end
    return oldIndex(self, key)
end)
setreadonly(mt, true)

-- Loop การทำงานหลัก
RunService.RenderStepped:Connect(function()
    -- FOV
    local mousePos = UserInputService:GetMouseLocation()
    FOVring.Position = mousePos -- วงกลมล็อกตามพิกัดเมาส์ 100%
    FOVring.Radius = Config.FOVRadius
    FOVring.Visible = Config.ShowFOV
    FOVring.Color = Config.TargetType == "Players" and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)

    -- No Fog
    if Config.NoFogEnabled then
        Lighting.FogEnd = 1000000
        Lighting.ClockTime = 12
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then v:Destroy() end
        end
    end
    
    -- Zoom
    if Config.ZoomEnabled then
        LocalPlayer.CameraMaxZoomDistance = 100000
        LocalPlayer.CameraMinZoomDistance = 0.5
    else
        LocalPlayer.CameraMaxZoomDistance = 400
    end

    -- Movement (Speed & Jump)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if Config.SpeedEnabled then char.Humanoid.WalkSpeed = Config.SpeedValue end
        if Config.JumpEnabled then char.Humanoid.JumpPower = Config.JumpValue end
    end

    -- ESP System
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pChar = player.Character
            local hum = pChar:FindFirstChild("Humanoid")
            
            -- Chams
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

            -- Text
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
                bgGui.Label.Text = string.format("%s\nHP: %d\n[%dm]", player.Name, hum.Health, dist)
            else
                if bgGui then bgGui:Destroy() end
            end
        end
    end
end)

-- ==========================================
-- 5. ระบบคีย์ลัด
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    -- K = เปิด-ปิด ทุกอย่าง (เนียนๆ)
    if input.KeyCode == Enum.KeyCode.K then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
    -- T = เปิด-ปิด เฉพาะหน้าต่างหลัก
    if input.KeyCode == Enum.KeyCode.T then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
