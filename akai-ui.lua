-- ============================================
--  AKAI UI Library v3.0
--  by Ry-Zeen | Adaptive Edition
--  Theme: Ice Blue | PC + Mobile Optimized
-- ============================================

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local GuiService        = game:GetService("GuiService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== DEVICE DETECTION ====================
local Device = {}
Device.TouchEnabled    = UserInputService.TouchEnabled
Device.KeyboardEnabled = UserInputService.KeyboardEnabled
Device.MouseEnabled    = UserInputService.MouseEnabled
Device.GamepadEnabled  = UserInputService.GamepadEnabled

-- Prioritas: kalo ada keyboard+mouse = PC, selain itu mobile/tablet
Device.IsPC     = Device.KeyboardEnabled and Device.MouseEnabled
Device.IsMobile = Device.TouchEnabled and not Device.IsPC
Device.IsTablet = Device.IsMobile and workspace.CurrentCamera.ViewportSize.X >= 700

-- Layout config per device
if Device.IsPC then
    Device.Layout = {
        windowSize      = Vector2.new(760, 420),
        navWidth        = 160,
        minTouch        = 28,
        fontSize        = 14,
        titleSize       = 17,
        subtitleSize    = 10,
        rowHeight       = 32,
        toggleSize      = Vector2.new(40, 22),
        toggleThumb     = 18,
        snowCount       = 25,
        padding         = 14,
        useHover        = true,
    }
elseif Device.IsTablet then
    Device.Layout = {
        windowSize      = Vector2.new(620, 460),
        navWidth        = 130,
        minTouch        = 40,
        fontSize        = 14,
        titleSize       = 16,
        subtitleSize    = 11,
        rowHeight       = 42,
        toggleSize      = Vector2.new(46, 26),
        toggleThumb     = 22,
        snowCount       = 15,
        padding         = 12,
        useHover        = false,
    }
else -- HP
    Device.Layout = {
        windowSize      = Vector2.new(340, 500),
        navWidth        = 74,
        minTouch        = 44,
        fontSize        = 13,
        titleSize       = 15,
        subtitleSize    = 10,
        rowHeight       = 46,
        toggleSize      = Vector2.new(50, 28),
        toggleThumb     = 24,
        snowCount       = 8,
        padding         = 10,
        useHover        = false,
    }
end

-- Print info
print(("[AKAI] Device: %s | Layout: %dx%d"):format(
    Device.IsPC and "PC" or (Device.IsTablet and "Tablet" or "Mobile"),
    Device.Layout.windowSize.X, Device.Layout.windowSize.Y
))

-- ==================== THEME ====================
local Theme = {
    bgPanel      = Color3.fromRGB(12, 18, 24),
    bgCard       = Color3.fromRGB(16, 24, 34),
    bgNav        = Color3.fromRGB(20, 28, 40),
    bgNavActive  = Color3.fromRGB(26, 38, 55),
    bgTopbar     = Color3.fromRGB(14, 22, 32),
    border       = Color3.fromRGB(40, 64, 90),
    accent       = Color3.fromRGB(140, 200, 255),
    accentHi     = Color3.fromRGB(200, 230, 255),
    accentBright = Color3.fromRGB(224, 242, 255),
    text         = Color3.fromRGB(235, 245, 255),
    textMuted    = Color3.fromRGB(130, 160, 190),
    textDim      = Color3.fromRGB(80, 105, 135),
    switchOff    = Color3.fromRGB(45, 60, 80),
    white        = Color3.fromRGB(255, 255, 255),
    red          = Color3.fromRGB(239, 68, 68),
    green        = Color3.fromRGB(74, 222, 128),
    yellow       = Color3.fromRGB(250, 204, 21),
}

-- ==================== HELPERS ====================
local Helpers = {}

function Helpers.new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

function Helpers.corner(p, r)
    return Helpers.new("UICorner", { CornerRadius = UDim.new(0, r) }, p)
end

function Helpers.stroke(p, c, t, tr)
    return Helpers.new("UIStroke", {
        Color = c, Thickness = t or 1, Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, p)
end

function Helpers.padding(p, t, r, b, l)
    return Helpers.new("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft   = UDim.new(0, l or r or t or 0),
    }, p)
end

function Helpers.tween(i, t, g, style)
    if not i or not i.Parent then return end
    TweenService:Create(i, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad), g):Play()
end

function Helpers.safeDestroy(inst)
    if inst and inst.Parent then inst:Destroy() end
end

-- Detect "tap" vs "drag" (mobile helper)
function Helpers.isTouch(input)
    return input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1
end

-- ==================== NOTIFICATION ====================
local Notify = {}
local notifyContainer

local function ensureNotifyContainer()
    if notifyContainer and notifyContainer.Parent then return notifyContainer end
    local w = Device.IsMobile and 240 or 300
    notifyContainer = Helpers.new("Frame", {
        Name = "AKAI_Notifs",
        Size = UDim2.new(0, w, 1, -40),
        Position = UDim2.new(1, -20, 0, 20),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        ZIndex = 9999,
    }, playerGui)
    Helpers.new("UIListLayout", {
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, notifyContainer)
    return notifyContainer
end

function Notify.show(title, msg, duration, kind)
    local container = ensureNotifyContainer()
    kind = kind or "info"
    local accent = (kind == "error" and Theme.red)
        or (kind == "success" and Theme.green)
        or (kind == "warning" and Theme.yellow)
        or Theme.accent

    local h = Device.IsMobile and 54 or 60
    local card = Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, h),
        BackgroundColor3 = Theme.bgCard,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 10000,
    }, container)
    Helpers.corner(card, 8)
    Helpers.stroke(card, accent, 1, 0.2)

    Helpers.new("Frame", {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 10001,
    }, card)

    Helpers.new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = Device.IsMobile and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10001,
    }, card)

    Helpers.new("TextLabel", {
        Size = UDim2.new(1, -20, 1, -26),
        Position = UDim2.new(0, 14, 0, 24),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = Theme.textMuted,
        Font = Enum.Font.GothamMedium,
        TextSize = Device.IsMobile and 10 or 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 10001,
    }, card)

    card.Position = UDim2.new(1, 40, 0, 0)
    Helpers.tween(card, 0.3, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)

    task.delay(duration or 3, function()
        if not card.Parent then return end
        Helpers.tween(card, 0.25, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 })
        task.wait(0.3)
        Helpers.safeDestroy(card)
    end)
end

-- ==================== CORE ====================
local AKAI = {}
AKAI.Theme = Theme
AKAI.Notify = Notify
AKAI.Device = Device
AKAI.Version = "3.0"

local windows = {}

-- ==================== WINDOW ====================
local Window = {}
Window.__index = Window

function AKAI:CreateWindow(config)
    config = config or {}
    local title     = config.Title or "AKAI UI"
    local subtitle  = config.Subtitle or "by Ry-Zeen"
    local size      = config.Size or Device.Layout.windowSize
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local L         = Device.Layout

    -- === ROOT ===
    local gui = Helpers.new("ScreenGui", {
        Name = "AKAI_UI_" .. tostring(math.random(1000, 9999)),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, playerGui)

    -- === MENU ===
    local menu = Helpers.new("Frame", {
        Name = "Menu",
        Size = UDim2.fromOffset(size.X, size.Y),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.bgPanel,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, gui)
    Helpers.corner(menu, 14)
    Helpers.stroke(menu, Theme.accent, 1, 0.2)
    Helpers.stroke(menu, Theme.accentHi, 4, 0.85)

    -- === RESPONSIVE ===
    local function fitToScreen()
        local vp = workspace.CurrentCamera.ViewportSize
        if vp.X <= 0 or vp.Y <= 0 then return end
        -- Mobile: pakai 92% width biar ada margin
        local maxW = vp.X * (Device.IsMobile and 0.92 or 1) - 20
        local maxH = vp.Y * (Device.IsMobile and 0.90 or 1) - 20
        local s = math.min(math.min(1, maxW / size.X), math.min(1, maxH / size.Y))
        local newW = size.X * s
        local newH = menu:GetAttribute("Minimized") and (52 * s) or (size.Y * s)
        menu.Size = UDim2.fromOffset(newW, newH)
    end
    fitToScreen()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToScreen)

    -- === CRYSTALS ===
    local crystalSize = Device.IsMobile and 16 or 20
    local crystalOffset = Device.IsMobile and 6 or 8
    local function makeCrystal(pos, anchor)
        local c = Helpers.new("Frame", {
            Size = UDim2.fromOffset(crystalSize, crystalSize),
            Position = pos,
            AnchorPoint = anchor,
            BackgroundColor3 = Theme.accent,
            BorderSizePixel = 0,
            Rotation = 45,
            ZIndex = 5,
        }, menu)
        Helpers.corner(c, 3)
        Helpers.new("UIGradient", {
            Color = ColorSequence.new(Theme.accentHi, Theme.accent),
            Rotation = 135,
        }, c)
        Helpers.stroke(c, Theme.accentBright, 1, 0.3)
    end

    makeCrystal(UDim2.new(0, crystalOffset, 0, crystalOffset), Vector2.new(0, 0))
    makeCrystal(UDim2.new(1, -crystalOffset, 0, crystalOffset), Vector2.new(1, 0))
    makeCrystal(UDim2.new(0, crystalOffset, 1, -crystalOffset), Vector2.new(0, 1))
    makeCrystal(UDim2.new(1, -crystalOffset, 1, -crystalOffset), Vector2.new(1, 1))

    -- === TOPBAR ===
    local topbarH = Device.IsMobile and 46 or 52
    local topbar = Helpers.new("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, topbarH),
        BackgroundColor3 = Theme.bgTopbar,
        BorderSizePixel = 0,
    }, menu)
    Helpers.corner(topbar, 14)
    Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.bgTopbar,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, topbar)
    Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.border,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, topbar)
    Helpers.padding(topbar, 0, L.padding, 0, L.padding)

    -- Logo
    local logoSize = Device.IsMobile and 26 or 30
    local logo = Helpers.new("Frame", {
        Size = UDim2.fromOffset(logoSize, logoSize),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.accent,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, topbar)
    Helpers.corner(logo, logoSize / 2)
    Helpers.new("UIGradient", { Color = ColorSequence.new(Theme.accent, Theme.accentHi), Rotation = 45 }, logo)
    Helpers.new("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "A",
        TextColor3 = Color3.fromRGB(10, 14, 20),
        TextScaled = true,
        Font = Enum.Font.GothamBlack,
        ZIndex = 4,
    }, logo)

    -- Title
    local titleX = logoSize + 10
    Helpers.new("TextLabel", {
        Size = UDim2.new(0, 260, 0, 18),
        Position = UDim2.new(0, titleX, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = L.titleSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, topbar)

    -- Subtitle (hide di mobile kalo layar sempit)
    if not (Device.IsMobile and size.X < 380) then
        Helpers.new("TextLabel", {
            Size = UDim2.new(0, 260, 0, 14),
            Position = UDim2.new(0, titleX, 0, 26),
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = Theme.textDim,
            Font = Enum.Font.GothamMedium,
            TextSize = L.subtitleSize,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, topbar)
    end

    -- === WINDOW CONTROLS ===
    local btnSize = Device.IsMobile and 26 or 28
    local controls = Helpers.new("Frame", {
        Size = UDim2.new(0, btnSize * 3 + 12, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
    }, topbar)
    Helpers.new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, controls)

    local function winBtn(sym, order, accentColor)
        local b = Helpers.new("TextButton", {
            Size = UDim2.fromOffset(btnSize, btnSize),
            BackgroundColor3 = Theme.bgPanel,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Text = sym,
            TextColor3 = accentColor or Theme.textMuted,
            Font = Enum.Font.GothamBold,
            TextSize = Device.IsMobile and 12 or 14,
            AutoButtonColor = false,
            LayoutOrder = order,
        }, controls)
        Helpers.corner(b, 6)
        Helpers.stroke(b, accentColor or Theme.border, 1, 0.4)
        if L.useHover then
            b.MouseEnter:Connect(function()
                Helpers.tween(b, 0.15, {
                    BackgroundTransparency = 0,
                    BackgroundColor3 = accentColor or Theme.accent,
                    TextColor3 = Theme.white,
                })
            end)
            b.MouseLeave:Connect(function()
                Helpers.tween(b, 0.15, {
                    BackgroundTransparency = 0.4,
                    BackgroundColor3 = Theme.bgPanel,
                    TextColor3 = accentColor or Theme.textMuted,
                })
            end)
        end
        return b
    end

    local minBtn    = winBtn("—", 1, Theme.accent)
    local toggleBtn = winBtn("¤", 2, Theme.accent)
    local killBtn   = winBtn("⏻", 3, Theme.red)

    -- === BODY ===
    local bodyPad = Device.IsMobile and 8 or L.padding
    local body = Helpers.new("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -topbarH),
        Position = UDim2.new(0, 0, 0, topbarH),
        BackgroundTransparency = 1,
    }, menu)
    Helpers.padding(body, bodyPad, bodyPad, bodyPad, bodyPad)

    -- === SIDEBAR ===
    local navH = Device.IsMobile and 46 or 50
    local navGap = Device.IsMobile and 5 or 8

    local nav = Helpers.new("Frame", {
        Size = UDim2.new(0, L.navWidth, 1, 0),
        BackgroundTransparency = 1,
    }, body)
    Helpers.new("UIListLayout", {
        Padding = UDim.new(0, navGap),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, nav)

    -- === CONTENT ===
    local contentGap = L.navWidth + (Device.IsMobile and 8 or 14)
    local contentWrapper = Helpers.new("Frame", {
        Size = UDim2.new(1, -contentGap, 1, 0),
        Position = UDim2.new(0, contentGap, 0, 0),
        BackgroundColor3 = Theme.bgCard,
        BorderSizePixel = 0,
    }, body)
    Helpers.corner(contentWrapper, 10)
    Helpers.stroke(contentWrapper, Theme.border, 1, 0)
    local contentPad = Device.IsMobile and 10 or 16
    Helpers.padding(contentWrapper, contentPad, contentPad, contentPad, contentPad)

    -- === WINDOW OBJECT ===
    local window = setmetatable({
        Gui = gui,
        Menu = menu,
        Body = body,
        Nav = nav,
        ContentWrapper = contentWrapper,
        Tabs = {},
        ActiveTab = nil,
        Minimized = false,
        Hidden = false,
        ToggleKey = toggleKey,
        Size = size,
        _reopenBtn = nil,
        _fitToScreen = fitToScreen,
        _topbarH = topbarH,
        _hotkeyConn = nil,
    }, Window)

    table.insert(windows, window)

    -- === REOPEN BUTTON ===
    local fabSize = Device.IsMobile and 52 or 46
    local reopenBtn = Helpers.new("TextButton", {
        Name = "ReopenBtn",
        Size = UDim2.fromOffset(fabSize, fabSize),
        Position = UDim2.new(1, -20, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.bgPanel,
        BorderSizePixel = 0,
        Text = "✦",
        TextColor3 = Theme.accent,
        Font = Enum.Font.GothamBold,
        TextSize = Device.IsMobile and 22 or 20,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 100,
    }, gui)
    Helpers.corner(reopenBtn, fabSize / 2)
    Helpers.stroke(reopenBtn, Theme.accent, 2, 0.2)
    Helpers.new("UIGradient", { Color = ColorSequence.new(Theme.accent, Theme.accentHi), Rotation = 45 }, reopenBtn)

    if L.useHover then
        reopenBtn.MouseEnter:Connect(function()
            Helpers.tween(reopenBtn, 0.15, { BackgroundColor3 = Theme.accent, TextColor3 = Theme.white })
        end)
        reopenBtn.MouseLeave:Connect(function()
            Helpers.tween(reopenBtn, 0.15, { BackgroundColor3 = Theme.bgPanel, TextColor3 = Theme.accent })
        end)
    end
    window._reopenBtn = reopenBtn

    -- === DRAG MENU (topbar) ===
    do
        local dragging, dragStart, startPos, moved = false, nil, nil, false
        topbar.InputBegan:Connect(function(input)
            if Helpers.isTouch(input) then
                dragging = true
                moved = false
                dragStart = input.Position
                startPos = menu.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
                menu.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
    end

    -- === DRAG + TAP REOPEN BTN ===
    do
        local dragging, dragStart, startPos, moved = false, nil, nil, false
        reopenBtn.InputBegan:Connect(function(input)
            if Helpers.isTouch(input) then
                dragging = true
                moved = false
                dragStart = input.Position
                startPos = reopenBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then moved = true end
                reopenBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if Helpers.isTouch(input) then
                if dragging and not moved then
                    window:Show()
                end
                dragging = false
            end
        end)
    end

    -- === CONTROLS ===
    minBtn.MouseButton1Click:Connect(function() window:ToggleMinimize() end)
    toggleBtn.MouseButton1Click:Connect(function() window:Hide() end)
    killBtn.MouseButton1Click:Connect(function()
        window:Destroy()
        Notify.show("AKAI UI", "Window closed.", 2, "info")
    end)

    -- === HOTKEY (PC only) ===
    if Device.KeyboardEnabled then
        window._hotkeyConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == window.ToggleKey then
                if menu.Visible then window:Hide() else window:Show() end
            end
        end)
    end

    -- === FADE IN ===
    menu.BackgroundTransparency = 1
    topbar.BackgroundTransparency = 1
    Helpers.tween(menu, 0.35, { BackgroundTransparency = 0 })
    Helpers.tween(topbar, 0.35, { BackgroundTransparency = 0 })

    return window
end

-- ==================== WINDOW METHODS ====================
function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    self.Menu:SetAttribute("Minimized", self.Minimized)

    for _, v in ipairs(self.Menu:GetDescendants()) do
        if v:IsA("TextButton") and v.Text == "—" then v.Text = "▢"
        elseif v:IsA("TextButton") and v.Text == "▢" then v.Text = "—" end
    end

    if self.Minimized then
        Helpers.tween(self.Body, 0.25, { Size = UDim2.new(1, 0, 0, 0) })
        task.wait(0.25)
        self.Body.Visible = false
        self.Menu.Size = UDim2.fromOffset(self.Menu.AbsoluteSize.X, self._topbarH)
    else
        self.Menu.Size = UDim2.fromOffset(self.Menu.AbsoluteSize.X, self._topbarH)
        self.Body.Visible = true
        self.Body.Size = UDim2.new(1, 0, 1, -self._topbarH)
        task.wait(0.05)
        self._fitToScreen()
    end
end

function Window:Hide()
    self.Hidden = true
    self.Menu.Visible = false
    self._reopenBtn.Visible = true
    local targetSize = Device.IsMobile and 52 or 46
    self._reopenBtn.Size = UDim2.fromOffset(0, 0)
    Helpers.tween(self._reopenBtn, 0.25, { Size = UDim2.fromOffset(targetSize, targetSize) })
end

function Window:Show()
    self.Hidden = false
    self._reopenBtn.Visible = false
    self.Menu.Visible = true
    local target = UDim2.fromOffset(self.Size.X, self.Minimized and self._topbarH or self.Size.Y)
    self.Menu.Size = UDim2.fromOffset(0, 0)
    Helpers.tween(self.Menu, 0.25, { Size = target })
    task.wait(0.05)
    self._fitToScreen()
end

function Window:Destroy()
    if self._hotkeyConn then self._hotkeyConn:Disconnect() end
    Helpers.safeDestroy(self.Gui)
    for i, w in ipairs(windows) do
        if w == self then table.remove(windows, i); break end
    end
end

function Window:Toggle()
    if self.Hidden then self:Show() else self:Hide() end
end

-- ==================== TAB ====================
function Window:CreateTab(config)
    config = config or {}
    local title = config.Title or "TAB"
    local icon  = config.Icon or "◆"
    local L     = Device.Layout

    local navH = Device.IsMobile and 46 or 50

    local item = Helpers.new("TextButton", {
        Size = UDim2.new(1, 0, 0, navH),
        BackgroundColor3 = Theme.bgNav,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #self.Tabs + 1,
    }, self.Nav)
    Helpers.corner(item, 8)

    local leftBar = Helpers.new("Frame", {
        Size = UDim2.new(0, 3, 0, navH * 0.6),
        Position = UDim2.new(0, -1, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.accentHi,
        BorderSizePixel = 0,
        Visible = false,
    }, item)
    Helpers.corner(leftBar, 3)

    -- Mobile: icon di tengah, text di bawah. PC: icon + text horizontal
    if Device.IsMobile then
        Helpers.new("TextLabel", {
            Size = UDim2.new(1, 0, 0.55, 0),
            Position = UDim2.new(0, 0, 0.08, 0),
            BackgroundTransparency = 1,
            Text = icon,
            TextColor3 = Theme.accent,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, item)
        Helpers.new("TextLabel", {
            Size = UDim2.new(1, -4, 0.4, 0),
            Position = UDim2.new(0, 2, 0.55, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Theme.text,
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, item)
    else
        Helpers.new("TextLabel", {
            Size = UDim2.new(1, -40, 0, 18),
            Position = UDim2.new(0, 30, 0, 10),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Theme.text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, item)

        Helpers.new("TextLabel", {
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Text = icon,
            TextColor3 = Theme.accent,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
        }, item)
    end

    -- Page (ScrollingFrame)
    local page = Helpers.new("ScrollingFrame", {
        Name = "Page_" .. title,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = Device.IsMobile and 3 or 4,
        ScrollBarImageColor3 = Theme.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ElasticsBehavior = Enum.ElasticBehavior.WhenScrollable,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, self.ContentWrapper)
    Helpers.new("UIListLayout", {
        Padding = UDim.new(0, Device.IsMobile and 8 or 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    Helpers.new("UIPadding", {
        PaddingRight = UDim.new(0, 4),
    }, page)

    local tab = setmetatable({
        Title = title,
        Item = item,
        LeftBar = leftBar,
        Page = page,
        Window = self,
        ElementCount = 0,
    }, { __index = TabMeta })

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then self:SelectTab(tab) end

    item.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

    if L.useHover then
        item.MouseEnter:Connect(function()
            if self.ActiveTab ~= tab then
                Helpers.tween(item, 0.15, { BackgroundColor3 = Theme.bgNavActive })
            end
        end)
        item.MouseLeave:Connect(function()
            if self.ActiveTab ~= tab then
                Helpers.tween(item, 0.15, { BackgroundColor3 = Theme.bgNav })
            end
        end)
    end

    return tab
end

function Window:SelectTab(targetTab)
    for _, tab in ipairs(self.Tabs) do
        if tab == targetTab then
            tab.Item.BackgroundColor3 = Theme.bgNavActive
            tab.LeftBar.Visible = true
            tab.Page.Visible = true
        else
            tab.Item.BackgroundColor3 = Theme.bgNav
            tab.LeftBar.Visible = false
            tab.Page.Visible = false
        end
    end
    self.ActiveTab = targetTab
end

-- ==================== ELEMENTS ====================
local Elements = {}
local L = Device.Layout

-- Helper: press feedback buat mobile (ganti hover)
local function addPressFeedback(btn, normalColor, pressColor)
    if Device.Layout.useHover then return end -- PC udah ada hover
    btn.InputBegan:Connect(function(input)
        if Helpers.isTouch(input) then
            Helpers.tween(btn, 0.1, { BackgroundColor3 = pressColor })
        end
    end)
    btn.InputEnded:Connect(function(input)
        if Helpers.isTouch(input) then
            task.wait(0.08)
            Helpers.tween(btn, 0.15, { BackgroundColor3 = normalColor })
        end
    end)
end

-- ---------- TOGGLE ----------
function Elements.Toggle(tab, config)
    config = config or {}
    local label    = config.Label or "Toggle"
    local default  = config.Default or false
    local callback = config.Callback or function() end

    tab.ElementCount = tab.ElementCount + 1
    local rowH = L.rowHeight

    local row = Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, rowH),
        BackgroundTransparency = 1,
        LayoutOrder = tab.ElementCount,
    }, tab.Page)

    Helpers.new("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = L.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)

    local stateTxt = Helpers.new("TextLabel", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -78, 0, 0),
        BackgroundTransparency = 1,
        Text = default and "ON" or "OFF",
        TextColor3 = default and Theme.accent or Theme.textDim,
        Font = Enum.Font.GothamBold,
        TextSize = Device.IsMobile and 10 or 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    local trackSize = L.toggleSize
    local track = Helpers.new("TextButton", {
        Size = UDim2.fromOffset(trackSize.X, trackSize.Y),
        Position = UDim2.new(1, -trackSize.X, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = default and Theme.accent or Theme.switchOff,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, row)
    Helpers.corner(track, trackSize.Y / 2)

    local thumbSize = L.toggleThumb
    local thumbOffX = 2
    local thumbOnX = trackSize.X - thumbSize - 2

    local thumb = Helpers.new("Frame", {
        Size = UDim2.fromOffset(thumbSize, thumbSize),
        Position = default and UDim2.new(0, thumbOnX, 0.5, 0) or UDim2.new(0, thumbOffX, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.white,
        BorderSizePixel = 0,
    }, track)
    Helpers.corner(thumb, thumbSize / 2)

    local state = default

    local function setState(v, silent)
        state = v
        Helpers.tween(track, 0.2, { BackgroundColor3 = state and Theme.accent or Theme.switchOff })
        Helpers.tween(thumb, 0.2, {
            Position = state and UDim2.new(0, thumbOnX, 0.5, 0) or UDim2.new(0, thumbOffX, 0.5, 0)
        })
        stateTxt.Text = state and "ON" or "OFF"
        stateTxt.TextColor3 = state and Theme.accent or Theme.textDim
        if not silent then callback(state) end
    end

    track.MouseButton1Click:Connect(function() setState(not state) end)

    return {
        Set = function(v) setState(v, true) end,
        Get = function() return state end,
        Instance = row,
    }
end

-- ---------- SLIDER ----------
function Elements.Slider(tab, config)
    config = config or {}
    local label    = config.Label or "Slider"
    local min      = config.Min or 0
    local max      = config.Max or 100
    local default  = config.Default or min
    local suffix   = config.Suffix or ""
    local decimals = config.Decimals or 0
    local step     = config.Step or 0
    local callback = config.Callback or function() end

    tab.ElementCount = tab.ElementCount + 1
    local blockH = Device.IsMobile and 56 or 50

    local block = Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, blockH),
        BackgroundTransparency = 1,
        LayoutOrder = tab.ElementCount,
    }, tab.Page)

    Helpers.new("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = L.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, block)

    local valLbl = Helpers.new("TextLabel", {
        Size = UDim2.new(0.4, 0, 0, 20),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = Device.IsMobile and 13 or 15,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, block)

    -- Track (posisi lebih ke bawah di mobile buat touch target gede)
    local trackY = Device.IsMobile and 40 or 34
    local trackThickness = Device.IsMobile and 5 or 4
    local track = Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, trackThickness),
        Position = UDim2.new(0, 0, 0, trackY),
        BackgroundColor3 = Theme.switchOff,
        BorderSizePixel = 0,
    }, block)
    Helpers.corner(track, trackThickness / 2)

    local function toRel(v) return (v - min) / (max - min) end

    local fill = Helpers.new("Frame", {
        Size = UDim2.fromScale(toRel(default), 1),
        BackgroundColor3 = Theme.accent,
        BorderSizePixel = 0,
    }, track)
    Helpers.corner(fill, trackThickness / 2)

    local thumbSize = Device.IsMobile and 22 or 16
    local thumb = Helpers.new("Frame", {
        Size = UDim2.fromOffset(thumbSize, thumbSize),
        Position = UDim2.new(toRel(default), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.white,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, track)
    Helpers.corner(thumb, thumbSize / 2)
    Helpers.stroke(thumb, Theme.accent, 1, 0.3)

    -- Touch hitbox — lebih gede buat mobile
    local hitH = Device.IsMobile and 40 or 30
    local hit = Helpers.new("TextButton", {
        Size = UDim2.new(1, 20, 0, hitH),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 10,
    }, track)

    local value = default
    local dragging = false

    local function formatValue(v)
        if decimals > 0 then return string.format("%." .. decimals .. "f", v) .. suffix end
        return tostring(math.floor(v + 0.5)) .. suffix
    end

    local function setValue(v, silent)
        v = math.clamp(v, min, max)
        if step > 0 then v = math.floor(v / step + 0.5) * step end
        value = v
        local rel = toRel(v)
        Helpers.tween(fill, 0.05, { Size = UDim2.fromScale(rel, 1) })
        Helpers.tween(thumb, 0.05, { Position = UDim2.new(rel, 0, 0.5, 0) })
        valLbl.Text = formatValue(v)
        if not silent then callback(v) end
    end

    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        setValue(min + rel * (max - min))
    end

    hit.InputBegan:Connect(function(input)
        if Helpers.isTouch(input) then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if Helpers.isTouch(input) then dragging = false end
    end)

    return {
        Set = function(v) setValue(v, true) end,
        Get = function() return value end,
        Instance = block,
    }
end

-- ---------- DROPDOWN ----------
function Elements.Dropdown(tab, config)
    config = config or {}
    local label    = config.Label or "Dropdown"
    local options  = config.Options or {}
    local default  = config.Default or (options[1] or "")
    local callback = config.Callback or function() end

    tab.ElementCount = tab.ElementCount + 1

    local ddW = Device.IsMobile and 90 or 100
    local ddH = Device.IsMobile and 32 or 28

    local row = Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, L.rowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = tab.ElementCount,
    }, tab.Page)

    Helpers.new("TextLabel", {
        Size = UDim2.new(1, -(ddW + 12), 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = L.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)

    local dd = Helpers.new("TextButton", {
        Size = UDim2.fromOffset(ddW, ddH),
        Position = UDim2.new(1, -ddW, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.bgNav,
        BorderSizePixel = 0,
        Text = default,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = Device.IsMobile and 11 or 12,
        AutoButtonColor = false,
    }, row)
    Helpers.corner(dd, 6)
    Helpers.stroke(dd, Theme.border, 1, 0)

    local value = default
    local open = false
    local list, backdrop

    local function closeList()
        if list then list:Destroy(); list = nil end
        if backdrop then backdrop:Destroy(); backdrop = nil end
        open = false
    end

    local function openList()
        if open then return end
        open = true

        -- Backdrop transparan buat nangkep tap di luar (mobile friendly)
        backdrop = Helpers.new("TextButton", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 19,
        }, tab.Page)
        backdrop.MouseButton1Click:Connect(function() closeList() end)

        local itemH = Device.IsMobile and 32 or 26
        local listH = #options * itemH + 8

        -- === AUTO-FLIP ===
        local screenH = workspace.CurrentCamera.ViewportSize.Y
        local ddAbs = dd.AbsolutePosition
        local ddHeight = dd.AbsoluteSize.Y
        local spaceBelow = screenH - (ddAbs.Y + ddHeight)
        local spaceAbove = ddAbs.Y

        local openDown = spaceBelow >= listH or spaceBelow >= spaceAbove

        list = Helpers.new("Frame", {
            Size = UDim2.fromOffset(ddW, listH),
            Position = openDown and UDim2.new(0, 0, 1, 4) or UDim2.new(0, 0, 0, -(listH + 4)),
            BackgroundColor3 = Theme.bgNav,
            BorderSizePixel = 0,
            ZIndex = 20,
        }, dd)
        Helpers.corner(list, 6)
        Helpers.stroke(list, Theme.accent, 1, 0.3)
        Helpers.padding(list, 4, 4, 4, 4)
        Helpers.new("UIListLayout", { Padding = UDim.new(0, 2) }, list)

        for i, opt in ipairs(options) do
            local b = Helpers.new("TextButton", {
                Size = UDim2.new(1, 0, 0, itemH - 2),
                BackgroundColor3 = Theme.bgNav,
                BackgroundTransparency = opt == value and 0.5 or 1,
                BorderSizePixel = 0,
                Text = opt,
                TextColor3 = opt == value and Theme.accent or Theme.text,
                Font = Enum.Font.GothamBold,
                TextSize = Device.IsMobile and 12 or 12,
                AutoButtonColor = false,
                LayoutOrder = i,
            }, list)
            Helpers.corner(b, 4)

            if Device.Layout.useHover then
                b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.7 end)
                b.MouseLeave:Connect(function()
                    b.BackgroundTransparency = opt == value and 0.5 or 1
                end)
            else
                addPressFeedback(b, opt == value and Theme.bgNav or Theme.bgNavActive, Theme.accent)
            end

            b.MouseButton1Click:Connect(function()
                value = opt
                dd.Text = opt
                callback(opt)
                closeList()
            end)
        end
    end

    dd.MouseButton1Click:Connect(function()
        if open then closeList() else openList() end
    end)

    return {
        Set = function(v) value = v; dd.Text = v; callback(v) end,
        Get = function() return value end,
        Instance = row,
    }
end

-- ---------- BUTTON ----------
function Elements.Button(tab, config)
    config = config or {}
    local label    = config.Label or "Button"
    local callback = config.Callback or function() end

    tab.ElementCount = tab.ElementCount + 1

    local btn = Helpers.new("TextButton", {
        Size = UDim2.new(1, 0, 0, Device.IsMobile and 42 or 34),
        BackgroundColor3 = Theme.bgNav,
        BorderSizePixel = 0,
        Text = label,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = L.fontSize - 1,
        AutoButtonColor = false,
        LayoutOrder = tab.ElementCount,
    }, tab.Page)
    Helpers.corner(btn, 8)
    Helpers.stroke(btn, Theme.accent, 1, 0.5)

    if Device.Layout.useHover then
        btn.MouseEnter:Connect(function()
            Helpers.tween(btn, 0.15, { BackgroundColor3 = Theme.bgNavActive, TextColor3 = Theme.accent })
        end)
        btn.MouseLeave:Connect(function()
            Helpers.tween(btn, 0.15, { BackgroundColor3 = Theme.bgNav, TextColor3 = Theme.text })
        end)
    end
    btn.MouseButton1Click:Connect(callback)

    return { Instance = btn }
end

-- ---------- TEXTBOX ----------
function Elements.Textbox(tab, config)
    config = config or {}
    local label       = config.Label or "Input"
    local placeholder = config.Placeholder or "Type here..."
    local default     = config.Default or ""
    local callback    = config.Callback or function() end

    tab.ElementCount = tab.ElementCount + 1

    local row = Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, L.rowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = tab.ElementCount,
    }, tab.Page)

    Helpers.new("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = L.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)

    local boxH = Device.IsMobile and 34 or 28
    local box = Helpers.new("TextBox", {
        Size = UDim2.new(0.6, 0, 0, boxH),
        Position = UDim2.new(0.4, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.bgNav,
        BorderSizePixel = 0,
        Text = default,
        PlaceholderText = placeholder,
        TextColor3 = Theme.text,
        PlaceholderColor3 = Theme.textDim,
        Font = Enum.Font.GothamMedium,
        TextSize = Device.IsMobile and 11 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, row)
    Helpers.corner(box, 6)
    Helpers.stroke(box, Theme.border, 1, 0)
    Helpers.padding(box, 0, 8, 0, 8)

    box.Focused:Connect(function()
        Helpers.tween(box, 0.15, { BackgroundColor3 = Theme.bgNavActive })
        if box:FindFirstChildOfClass("UIStroke") then
            Helpers.tween(box:FindFirstChildOfClass("UIStroke"), 0.15, { Transparency = 0, Color = Theme.accent })
        end
    end)
    box.FocusLost:Connect(function(enterPressed)
        Helpers.tween(box, 0.15, { BackgroundColor3 = Theme.bgNav })
        if box:FindFirstChildOfClass("UIStroke") then
            Helpers.tween(box:FindFirstChildOfClass("UIStroke"), 0.15, { Transparency = 0.7 })
        end
        callback(box.Text, enterPressed)
    end)

    return {
        Set = function(v) box.Text = v end,
        Get = function() return box.Text end,
        Instance = row,
    }
end

-- ---------- COLOR PICKER ----------
function Elements.ColorPicker(tab, config)
    config = config or {}
    local label    = config.Label or "Color"
    local default  = config.Default or Theme.accent
    local callback = config.Callback or function() end

    tab.ElementCount = tab.ElementCount + 1

    local row = Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, L.rowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = tab.ElementCount,
    }, tab.Page)

    Helpers.new("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = L.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)

    local btnW = Device.IsMobile and 46 or 40
    local btnH = Device.IsMobile and 32 or 28

    local btn = Helpers.new("TextButton", {
        Size = UDim2.fromOffset(btnW, btnH),
        Position = UDim2.new(1, -btnW, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Text = "✦",
        TextColor3 = Theme.white,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
    }, row)
    Helpers.corner(btn, 6)
    Helpers.stroke(btn, Theme.accentHi, 1, 0.3)

    local color = default

    btn.MouseButton1Click:Connect(function()
        local colors = {
            Theme.accent, Theme.green, Theme.yellow,
            Theme.red, Color3.fromRGB(200, 140, 255),
            Color3.fromRGB(255, 140, 200),
        }
        local idx = 1
        for i, c in ipairs(colors) do
            if c == color then idx = (i % #colors) + 1; break end
        end
        color = colors[idx]
        btn.BackgroundColor3 = color
        callback(color)
    end)

    return {
        Set = function(c) color = c; btn.BackgroundColor3 = c; callback(c) end,
        Get = function() return color end,
        Instance = row,
    }
end

-- ---------- DIVIDER ----------
function Elements.Divider(tab, config)
    tab.ElementCount = tab.ElementCount + 1
    local wrap = Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, Device.IsMobile and 24 or 20),
        BackgroundTransparency = 1,
        LayoutOrder = tab.ElementCount,
    }, tab.Page)

    Helpers.new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.border,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.3,
    }, wrap)

    if config and config.Label then
        Helpers.new("TextLabel", {
            Size = UDim2.fromOffset(120, 16),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.bgCard,
            BorderSizePixel = 0,
            Text = config.Label,
            TextColor3 = Theme.textMuted,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
        }, wrap)
    end

    return { Instance = wrap }
end

-- ==================== TAB META ====================
TabMeta = {}
TabMeta.__index = TabMeta

function TabMeta:Toggle(cfg)      return Elements.Toggle(self, cfg) end
function TabMeta:Slider(cfg)      return Elements.Slider(self, cfg) end
function TabMeta:Dropdown(cfg)    return Elements.Dropdown(self, cfg) end
function TabMeta:Button(cfg)      return Elements.Button(self, cfg) end
function TabMeta:Textbox(cfg)     return Elements.Textbox(self, cfg) end
function TabMeta:ColorPicker(cfg) return Elements.ColorPicker(self, cfg) end
function TabMeta:Divider(cfg)     return Elements.Divider(self, cfg) end

-- ==================== SNOW ====================
local function attachSnow(gui)
    local count = Device.Layout.snowCount
    if count <= 0 then return function() end end

    local container = Helpers.new("Frame", {
        Name = "Snow",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = -1,
        ClipsDescendants = true,
    }, gui)

    local flakes = {}
    for i = 1, count do
        local s = math.random(2, 4)
        local f = Helpers.new("Frame", {
            Size = UDim2.fromOffset(s, s),
            Position = UDim2.new(math.random(), 0, -0.05, 0),
            BackgroundColor3 = Theme.accentHi,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            ZIndex = -1,
        }, container)
        Helpers.corner(f, s / 2)
        table.insert(flakes, {
            inst = f,
            speed = 0.02 + math.random() * 0.04,
            drift = (math.random() - 0.5) * 0.02,
        })
    end

    local conn = RunService.RenderStepped:Connect(function(dt)
        for _, s in ipairs(flakes) do
            if s.inst and s.inst.Parent then
                local p = s.inst.Position
                local ny = p.Y.Scale + s.speed * dt * 3
                local nx = p.X.Scale + s.drift * dt
                if ny > 1.05 then ny = -0.05; nx = math.random() end
                if nx < 0 then nx = 1 end
                if nx > 1 then nx = 0 end
                s.inst.Position = UDim2.new(nx, 0, ny, 0)
            end
        end
    end)

    return function() conn:Disconnect(); Helpers.safeDestroy(container) end
end

AKAI.Snow = attachSnow

return AKAI
