-- ============================================
-- RENXX UI v2.0
-- By: DEEP & RENXX
-- Style: Dark Purple Modern
-- Purpose: UI Library Framework
-- ============================================

local RENXX = {}
RENXX.__index = RENXX

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==================== THEME ====================
RENXX.Theme = {
    Background      = Color3.fromRGB(12, 8, 20),
    Surface         = Color3.fromRGB(22, 16, 35),
    SurfaceLight    = Color3.fromRGB(35, 25, 50),
    SurfaceDark     = Color3.fromRGB(15, 10, 25),
    
    TextPrimary     = Color3.fromRGB(240, 235, 250),
    TextSecondary   = Color3.fromRGB(150, 140, 170),
    TextDisabled    = Color3.fromRGB(90, 85, 105),
    
    Accent          = Color3.fromRGB(138, 80, 220),
    AccentHover     = Color3.fromRGB(160, 100, 250),
    AccentGlow      = Color3.fromRGB(138, 80, 220),
    
    Success         = Color3.fromRGB(80, 220, 130),
    Warning         = Color3.fromRGB(250, 200, 80),
    Danger          = Color3.fromRGB(240, 70, 90),
    
    Border          = Color3.fromRGB(60, 40, 90),
    BorderLight     = Color3.fromRGB(90, 60, 130),
    
    Font            = Enum.Font.Gotham,
    FontBold        = Enum.Font.GothamBold,
    FontMedium      = Enum.Font.GothamMedium,
    
    FontSize        = 14,
    FontSizeSmall   = 12,
    FontSizeTitle   = 18,
    
    Radius          = 10,
    RadiusSmall     = 8,
    RadiusPill      = 999,
}

-- ==================== TWEEN HELPER ====================
local function tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- ==================== CREATE WINDOW ====================
function RENXX:CreateWindow(config)
    config = config or {}
    
    local self = setmetatable({}, RENXX)
    self.Name = config.Name or "RENXX UI"
    self.Subtitle = config.Subtitle or "LEGACY"
    self.Size = config.Size or UDim2.new(0, 600, 0, 400)
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsMinimized = false
    
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "RENXX_UI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    self:_createMain()
    self:_createGlow()
    self:_createTopBar()
    self:_createSidebar()
    self:_createContentArea()
    self:_createFloatingButton()
    self:_enableDrag()
    
    return self
end

-- ==================== MAIN ====================
function RENXX:_createMain()
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = self.Size
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = self.Theme.Background
    main.BorderSizePixel = 0
    main.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.Radius)
    corner.Parent = main
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.Accent
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = main
    
    self.Main = main
end

-- ==================== GLOW ====================
function RENXX:_createGlow()
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 50, 1, 50)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = self.Theme.AccentGlow
    glow.ImageTransparency = 0.7
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 276, 276)
    glow.ZIndex = -1
    glow.Parent = self.Main
    
    task.spawn(function()
        while glow.Parent do
            tween(glow, 2, {ImageTransparency = 0.5})
            task.wait(2)
            tween(glow, 2, {ImageTransparency = 0.75})
            task.wait(2)
        end
    end)
end

-- ==================== TOP BAR ====================
function RENXX:_createTopBar()
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundColor3 = self.Theme.Surface
    topBar.BorderSizePixel = 0
    topBar.Parent = self.Main
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.Radius)
    corner.Parent = topBar
    
    -- Fix bottom corner
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, self.Theme.Radius)
    fix.Position = UDim2.new(0, 0, 1, -self.Theme.Radius)
    fix.BackgroundColor3 = self.Theme.Surface
    fix.BorderSizePixel = 0
    fix.Parent = topBar
    
    -- Border bottom
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 0, 1)
    border.Position = UDim2.new(0, 0, 1, -1)
    border.BackgroundColor3 = self.Theme.Border
    border.BorderSizePixel = 0
    border.Parent = topBar
    
    -- ICON (R)
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 28, 0, 28)
    iconFrame.Position = UDim2.new(0, 15, 0.5, -14)
    iconFrame.BackgroundColor3 = self.Theme.Accent
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = topBar
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconFrame
    
    -- Icon stroke (glow)
    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = self.Theme.AccentGlow
    iconStroke.Thickness = 2
    iconStroke.Transparency = 0.5
    iconStroke.Parent = iconFrame
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "R"
    iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconText.TextSize = 16
    iconText.Font = self.Theme.FontBold
    iconText.Parent = iconFrame
    
    -- TITLE
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -250, 1, 0)
    titleLabel.Position = UDim2.new(0, 55, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Name
    titleLabel.TextColor3 = self.Theme.TextPrimary
    titleLabel.TextSize = self.Theme.FontSizeTitle
    titleLabel.Font = self.Theme.FontBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Icon button creator
    local function createIconBtn(symbol, posX, callback, isDanger)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.Position = UDim2.new(1, posX, 0.5, -16)
        btn.BackgroundColor3 = self.Theme.SurfaceLight
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = symbol
        btn.TextColor3 = self.Theme.TextSecondary
        btn.TextSize = 16
        btn.Font = self.Theme.FontBold
        btn.AutoButtonColor = false
        btn.Parent = topBar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, self.Theme.RadiusSmall)
        btnCorner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            tween(btn, 0.15, {
                BackgroundTransparency = 0,
                BackgroundColor3 = isDanger and self.Theme.Danger or self.Theme.SurfaceLight,
                TextColor3 = isDanger and Color3.fromRGB(255,255,255) or self.Theme.TextPrimary
            })
        end)
        
        btn.MouseLeave:Connect(function()
            tween(btn, 0.15, {
                BackgroundTransparency = 1,
                TextColor3 = self.Theme.TextSecondary
            })
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- SEARCH
    createIconBtn("🔍", -150, function()
        self:Notify({Title = "Search", Content = "Coming soon", Duration = 2})
    end, false)
    
    -- MENU
    createIconBtn("⋮", -115, function()
        self:Notify({Title = "Menu", Content = "Coming soon", Duration = 2})
    end, false)
    
    -- MINIMIZE
    self.MinBtn = createIconBtn("—", -80, function()
        self.IsMinimized = not self.IsMinimized
        if self.IsMinimized then
            self.OriginalSize = self.Main.Size
            tween(self.Main, 0.25, {Size = UDim2.new(0, 600, 0, 45)})
            self.Sidebar.Visible = false
            self.Content.Visible = false
            self.MinBtn.Text = "□"
        else
            tween(self.Main, 0.25, {Size = self.OriginalSize or UDim2.new(0, 600, 0, 400)})
            task.wait(0.15)
            self.Sidebar.Visible = true
            self.Content.Visible = true
            self.MinBtn.Text = "—"
        end
    end, false)
    
    -- CLOSE
    createIconBtn("⏻", -45, function()
        tween(self.Main, 0.2, {Size = UDim2.new(0, 0, 0, 0)})
        task.wait(0.25)
        self.ScreenGui.Enabled = false
    end, true)
    
    self.TopBar = topBar
end

-- ==================== SIDEBAR ====================
function RENXX:_createSidebar()
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 160, 1, -70)
    sidebar.Position = UDim2.new(0, 15, 0, 60)
    sidebar.BackgroundTransparency = 1
    sidebar.Parent = self.Main
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = sidebar
    
    self.Sidebar = sidebar
end

-- ==================== CONTENT AREA ====================
function RENXX:_createContentArea()
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -190, 1, -70)
    content.Position = UDim2.new(0, 180, 0, 60)
    content.BackgroundColor3 = self.Theme.Surface
    content.BorderSizePixel = 0
    content.Parent = self.Main
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.Radius)
    corner.Parent = content
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = content
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.Size = UDim2.new(1, -20, 1, -20)
    scroll.Position = UDim2.new(0, 10, 0, 10)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = self.Theme.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = content
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    
    self.Content = content
    self.Scroll = scroll
end

-- ==================== CREATE TAB ====================
function RENXX:CreateTab(name)
    local tabData = {
        Name = name,
        IsActive = false,
        Components = {},
    }
    
    -- Tab button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "Tab"
    tabBtn.Size = UDim2.new(1, 0, 0, 48)
    tabBtn.BackgroundColor3 = self.Theme.Surface
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.RadiusSmall)
    corner.Parent = tabBtn
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = tabBtn
    
    -- Accent bar (kiri)
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 3, 0, 0)
    accentBar.Position = UDim2.new(0, 0, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = self.Theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Visible = false
    accentBar.Parent = tabBtn
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = accentBar
    
    -- Tab text (atas)
    local tabText = Instance.new("TextLabel")
    tabText.Size = UDim2.new(1, -15, 0, 22)
    tabText.Position = UDim2.new(0, 15, 0, 5)
    tabText.BackgroundTransparency = 1
    tabText.Text = name
    tabText.TextColor3 = self.Theme.TextSecondary
    tabText.TextSize = self.Theme.FontSize
    tabText.Font = self.Theme.FontBold
    tabText.TextXAlignment = Enum.TextXAlignment.Left
    tabText.Parent = tabBtn
    
    -- Status text (bawah)
    local tabStatus = Instance.new("TextLabel")
    tabStatus.Size = UDim2.new(1, -15, 0, 14)
    tabStatus.Position = UDim2.new(0, 15, 0, 26)
    tabStatus.BackgroundTransparency = 1
    tabStatus.Text = "Inactive"
    tabStatus.TextColor3 = self.Theme.TextDisabled
    tabStatus.TextSize = 10
    tabStatus.Font = self.Theme.Font
    tabStatus.TextXAlignment = Enum.TextXAlignment.Left
    tabStatus.Parent = tabBtn
    
    -- Content page
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Parent = self.Scroll
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page
    
    tabData.Page = page
    tabData.Button = tabBtn
    tabData.AccentBar = accentBar
    tabData.TabText = tabText
    tabData.TabStatus = tabStatus
    tabData.Stroke = stroke
    
    -- Tab API
    local tabAPI = {_data = tabData, Frame = page}
    
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)
    
    tabBtn.MouseEnter:Connect(function()
        if not tabData.IsActive then
            tween(tabBtn, 0.15, {BackgroundColor3 = self.Theme.SurfaceLight})
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if not tabData.IsActive then
            tween(tabBtn, 0.15, {BackgroundColor3 = self.Theme.Surface})
        end
    end)
    
    if not self.ActiveTab then
        self:SelectTab(tabData)
    end
    
    table.insert(self.Tabs, tabData)
    
    -- Component methods
    tabAPI.CreateToggle = function(_, config) return self:_createToggle(page, config) end
    tabAPI.CreateSlider = function(_, config) return self:_createSlider(page, config) end
    tabAPI.CreateDropdown = function(_, config) return self:_createDropdown(page, config) end
    tabAPI.CreateButton = function(_, config) return self:_createButton(page, config) end
    tabAPI.CreateInput = function(_, config) return self:_createInput(page, config) end
    tabAPI.CreateColorPicker = function(_, config) return self:_createColorPicker(page, config) end
    tabAPI.CreateSection = function(_, title) return self:_createSection(page, title) end
    
    return tabAPI
end

-- ==================== SELECT TAB ====================
function RENXX:SelectTab(tabData)
    for _, tab in ipairs(self.Tabs) do
        tab.IsActive = false
        tab.Page.Visible = false
        tween(tab.Button, 0.15, {BackgroundColor3 = self.Theme.Surface})
        tween(tab.TabText, 0.15, {TextColor3 = self.Theme.TextSecondary})
        tab.AccentBar.Visible = false
        tab.AccentBar.Size = UDim2.new(0, 3, 0, 0)
        tab.TabStatus.Text = "Inactive"
        tab.TabStatus.TextColor3 = self.Theme.TextDisabled
        tween(tab.Stroke, 0.15, {Color = self.Theme.Border})
    end
    
    tabData.IsActive = true
    tabData.Page.Visible = true
    tween(tabData.Button, 0.15, {BackgroundColor3 = self.Theme.SurfaceLight})
    tween(tabData.TabText, 0.15, {TextColor3 = self.Theme.TextPrimary})
    tween(tabData.Stroke, 0.15, {Color = self.Theme.Accent})
    tabData.AccentBar.Visible = true
    tween(tabData.AccentBar, 0.2, {Size = UDim2.new(0, 3, 0, 30)})
    tabData.TabStatus.Text = "ACTIVE"
    tabData.TabStatus.TextColor3 = self.Theme.Accent
end

-- ==================== SECTION ====================
function RENXX:_createSection(parent, title)
    local section = Instance.new("TextLabel")
    section.Name = "Section"
    section.Size = UDim2.new(1, 0, 0, 20)
    section.BackgroundTransparency = 1
    section.Text = title
    section.TextColor3 = self.Theme.TextDisabled
    section.TextSize = 11
    section.Font = self.Theme.FontBold
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = parent
    return section
end

-- ==================== COMPONENT: TOGGLE ====================
function RENXX:_createToggle(parent, config)
    config = config or {}
    local state = config.CurrentValue or false
    
    local frame = Instance.new("Frame")
    frame.Name = "Toggle"
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Toggle"
    label.TextColor3 = self.Theme.TextPrimary
    label.TextSize = self.Theme.FontSize
    label.Font = self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 48, 0, 24)
    toggle.Position = UDim2.new(1, -53, 0.5, -12)
    toggle.BackgroundColor3 = state and self.Theme.Accent or self.Theme.SurfaceLight
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local function update()
        tween(toggle, 0.2, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.SurfaceLight})
        tween(knob, 0.2, {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
    end
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        update()
        if config.Callback then pcall(config.Callback, state) end
    end)
    
    return {
        Set = function(_, v) state = v update() end,
        Get = function() return state end,
    }
end

-- ==================== COMPONENT: SLIDER ====================
function RENXX:_createSlider(parent, config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.CurrentValue or min
    local suffix = config.Suffix or ""
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Slider"
    label.TextColor3 = self.Theme.TextPrimary
    label.TextSize = self.Theme.FontSize
    label.Font = self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 70, 0, 20)
    valueLabel.Position = UDim2.new(1, -75, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value) .. suffix
    valueLabel.TextColor3 = self.Theme.TextPrimary
    valueLabel.TextSize = self.Theme.FontSize
    valueLabel.Font = self.Theme.FontBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -10, 0, 6)
    barBg.Position = UDim2.new(0, 5, 0, 30)
    barBg.BackgroundColor3 = self.Theme.SurfaceLight
    barBg.BorderSizePixel = 0
    barBg.Parent = frame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = barBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = barBg
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    local dragging = false
    
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouseX = input.Position.X
            local barPos = barBg.AbsolutePosition.X
            local barSize = barBg.AbsoluteSize.X
            local relative = math.clamp((mouseX - barPos) / barSize, 0, 1)
            value = math.floor(min + (max - min) * relative)
            
            fill.Size = UDim2.new(relative, 0, 1, 0)
            dot.Position = UDim2.new(relative, 0, 0.5, 0)
            valueLabel.Text = tostring(value) .. suffix
            
            if config.Callback then pcall(config.Callback, value) end
        end
    end)
    
    return {
        Set = function(_, v)
            value = math.clamp(v, min, max)
            local rel = (value - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            dot.Position = UDim2.new(rel, 0, 0.5, 0)
            valueLabel.Text = tostring(value) .. suffix
        end,
    }
end

-- ==================== COMPONENT: DROPDOWN ====================
function RENXX:_createDropdown(parent, config)
    config = config or {}
    local options = config.Options or {}
    local selected = config.CurrentOption or options[1] or "None"
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -130, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Dropdown"
    label.TextColor3 = self.Theme.TextPrimary
    label.TextSize = self.Theme.FontSize
    label.Font = self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 28)
    btn.Position = UDim2.new(1, -115, 0.5, -14)
    btn.BackgroundColor3 = self.Theme.SurfaceLight
    btn.BorderSizePixel = 0
    btn.Text = selected .. "  ▼"
    btn.TextColor3 = self.Theme.TextPrimary
    btn.TextSize = self.Theme.FontSizeSmall
    btn.Font = self.Theme.Font
    btn.AutoButtonColor = false
    btn.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.RadiusSmall)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    -- Options
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(0, 110, 0, #options * 28)
    optionsFrame.Position = UDim2.new(1, -115, 1, 5)
    optionsFrame.BackgroundColor3 = self.Theme.SurfaceLight
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.Parent = frame
    
    local optCorner = Instance.new("UICorner")
    optCorner.CornerRadius = UDim.new(0, self.Theme.RadiusSmall)
    optCorner.Parent = optionsFrame
    
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, -8, 0, 26)
        optBtn.Position = UDim2.new(0, 4, 0, (i-1) * 28 + 1)
        optBtn.BackgroundColor3 = self.Theme.Surface
        optBtn.BorderSizePixel = 0
        optBtn.Text = opt
        optBtn.TextColor3 = self.Theme.TextSecondary
        optBtn.TextSize = self.Theme.FontSizeSmall
        optBtn.Font = self.Theme.Font
        optBtn.ZIndex = 11
        optBtn.Parent = optionsFrame
        
        local oCorner = Instance.new("UICorner")
        oCorner.CornerRadius = UDim.new(0, 4)
        oCorner.Parent = optBtn
        
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            btn.Text = opt .. "  ▼"
            optionsFrame.Visible = false
            if config.Callback then pcall(config.Callback, opt) end
        end)
    end
    
    btn.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
    end)
    
    return {
        Set = function(_, v)
            selected = v
            btn.Text = v .. "  ▼"
        end,
    }
end

-- ==================== COMPONENT: BUTTON ====================
function RENXX:_createButton(parent, config)
    config = config or {}
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = self.Theme.Accent
    btn.BorderSizePixel = 0
    btn.Text = config.Name or "Button"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = self.Theme.FontSize
    btn.Font = self.Theme.FontBold
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.RadiusSmall)
    corner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, {BackgroundColor3 = self.Theme.AccentHover})
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, {BackgroundColor3 = self.Theme.Accent})
    end)
    
    btn.MouseButton1Click:Connect(function()
        if config.Callback then pcall(config.Callback) end
    end)
end

-- ==================== COMPONENT: INPUT ====================
function RENXX:_createInput(parent, config)
    config = config or {}
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -160, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Input"
    label.TextColor3 = self.Theme.TextPrimary
    label.TextSize = self.Theme.FontSize
    label.Font = self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 150, 0, 28)
    box.Position = UDim2.new(1, -155, 0.5, -14)
    box.BackgroundColor3 = self.Theme.SurfaceLight
    box.BorderSizePixel = 0
    box.Text = config.CurrentValue or ""
    box.PlaceholderText = config.PlaceholderText or "Type..."
    box.TextColor3 = self.Theme.TextPrimary
    box.PlaceholderColor3 = self.Theme.TextDisabled
    box.TextSize = self.Theme.FontSizeSmall
    box.Font = self.Theme.Font
    box.ClearTextOnFocus = false
    box.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.RadiusSmall)
    corner.Parent = box
    
    box.FocusLost:Connect(function()
        if config.Callback then pcall(config.Callback, box.Text) end
    end)
    
    return {
        Set = function(_, v) box.Text = v end,
        Get = function() return box.Text end,
    }
end

-- ==================== COMPONENT: COLOR PICKER ====================
function RENXX:_createColorPicker(parent, config)
    config = config or {}
    local currentColor = config.Default or Color3.fromRGB(255, 255, 255)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Color"
    label.TextColor3 = self.Theme.TextPrimary
    label.TextSize = self.Theme.FontSize
    label.Font = self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 36, 0, 28)
    btn.Position = UDim2.new(1, -41, 0.5, -14)
    btn.BackgroundColor3 = self.Theme.Accent
    btn.BorderSizePixel = 0
    btn.Text = "🎨"
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.RadiusSmall)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentColor = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))
        btn.BackgroundColor3 = currentColor
        if config.Callback then pcall(config.Callback, currentColor) end
    end)
end

-- ==================== FLOATING BUTTON ====================
function RENXX:_createFloatingButton()
    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "FloatingButton"
    floatBtn.Size = UDim2.new(0, 50, 0, 50)
    floatBtn.Position = UDim2.new(1, -70, 1, -70)
    floatBtn.BackgroundColor3 = self.Theme.Accent
    floatBtn.BorderSizePixel = 0
    floatBtn.Text = "R"
    floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.TextSize = 22
    floatBtn.Font = self.Theme.FontBold
    floatBtn.AutoButtonColor = false
    floatBtn.ZIndex = 100
    floatBtn.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = floatBtn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.AccentGlow
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = floatBtn
    
    floatBtn.MouseEnter:Connect(function()
        tween(floatBtn, 0.15, {BackgroundColor3 = self.Theme.AccentHover})
    end)
    
    floatBtn.MouseLeave:Connect(function()
        tween(floatBtn, 0.15, {BackgroundColor3 = self.Theme.Accent})
    end)
    
    floatBtn.MouseButton1Click:Connect(function()
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end)
    
    -- Drag
    local dragging, dragStart, startPos, dragInput
    
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    floatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    self.FloatingButton = floatBtn
end

-- ==================== DRAG ====================
function RENXX:_enableDrag()
    local dragging, dragStart, startPos, dragInput
    
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    self.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==================== NOTIFICATION ====================
function RENXX:Notify(config)
    config = config or {}
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 60)
    notif.Position = UDim2.new(1, 20, 0, 100)
    notif.BackgroundColor3 = self.Theme.Surface
    notif.BorderSizePixel = 0
    notif.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Theme.Radius)
    corner.Parent = notif
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = notif
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 22)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "⚡ " .. (config.Title or "RENXX")
    title.TextColor3 = self.Theme.Accent
    title.TextSize = self.Theme.FontSize
    title.Font = self.Theme.FontBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notif
    
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -20, 0, 20)
    content.Position = UDim2.new(0, 12, 0, 30)
    content.BackgroundTransparency = 1
    content.Text = config.Content or "Notification"
    content.TextColor3 = self.Theme.TextSecondary
    content.TextSize = self.Theme.FontSizeSmall
    content.Font = self.Theme.Font
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.Parent = notif
    
    tween(notif, 0.3, {Position = UDim2.new(1, -300, 0, 100)})
    
    task.delay(config.Duration or 3, function()
        tween(notif, 0.3, {Position = UDim2.new(1, 20, 0, 100)})
        task.wait(0.3)
        notif:Destroy()
    end)
end

return RENXX
