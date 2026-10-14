--[[
    ===========================================================
              ZERASER UI LIBRARY v2.0.2
                by ry-zeen & renxx
    ===========================================================
    
    v2.0.2 Changelog:
    [FIX] Watermark reset edge case (knob & visibility sync)
    [FIX] Extract applySearchHighlight() - DRY
    
    v2.0.1 Changelog:
    [FIX] Reset button (semua element, gak cuma toggle)
    [FIX] Search highlight reset pas theme ganti
    [FIX] Key pattern match pakai sub()
    [FIX] REMOVED: False Tooltip claim
    
    v2.0 Features:
    - Section collapse/expand
    - Notification types (success/error/warn/info)
    - Reset to default button
    - Toggle watermark
    - Debug mode
    - Search highlight
    - Smooth theme tween
    - Dropdown smart flip
    - HSV color picker
    - Config save/load
    - Keybind registry
    - 10 theme preset
]]

local ZeraserUI = {}
ZeraserUI.__index = ZeraserUI
ZeraserUI.Version = "2.0.2"
ZeraserUI.Author = "ry-zeen & renxx"
ZeraserUI.Debug = false

-- ==================== SERVICES ====================
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")
local RunService   = game:GetService("RunService")
local Stats        = game:GetService("Stats")
local LocalPlayer  = Players.LocalPlayer

-- ==================== HELPERS ====================
local function log(msg, isError)
    if isError then
        warn("[ZERASER UI] " .. tostring(msg))
    elseif ZeraserUI.Debug then
        print("[ZERASER UI] " .. tostring(msg))
    end
end

local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Color3.fromRGB(30, 64, 175),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent,
    })
end

local function Tween(obj, time, props, style, dir)
    if not obj or not obj.Parent then return end
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function HexToRGB(hex)
    hex = tostring(hex):gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 0,
        tonumber(hex:sub(3, 4), 16) or 0,
        tonumber(hex:sub(5, 6), 16) or 0
    )
end

local function RGBToHex(c)
    return string.format("#%02X%02X%02X", c.R * 255, c.G * 255, c.B * 255)
end

local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end
    return Color3.new(r, g, b)
end

local function RGBtoHSV(c)
    local r, g, b = c.R, c.G, c.B
    local max_ = math.max(r, g, b)
    local min_ = math.min(r, g, b)
    local h, s, v = 0, 0, max_
    local d = max_ - min_
    s = max_ == 0 and 0 or d / max_
    if max_ == min_ then
        h = 0
    elseif max_ == r then
        h = (g - b) / d + (g < b and 6 or 0)
    elseif max_ == g then
        h = (b - r) / d + 2
    else
        h = (r - g) / d + 4
    end
    h = h / 6
    return h, s, v
end

local function SafeGUID()
    return tostring(math.floor(tick() * 1000)) .. tostring(math.random(10000, 99999))
end

local hasFileAPI = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local hasJSON = pcall(function() return game:GetService("HttpService"):JSONEncode({}) end)

-- ==================== THEMES ====================
ZeraserUI.Themes = {
    ["Ocean Blue"]    = { Accent = HexToRGB("3b82f6"), Border = HexToRGB("1e40af"), Background = HexToRGB("0a0a0a"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("c7d5ee"), TextDim = HexToRGB("5a7db8"), Footer = HexToRGB("ffffff"), Handle = HexToRGB("ffffff") },
    ["Crimson Red"]   = { Accent = HexToRGB("ef4444"), Border = HexToRGB("7f1d1d"), Background = HexToRGB("0a0505"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("fecaca"), TextDim = HexToRGB("b91c1c"), Footer = HexToRGB("ef4444"), Handle = HexToRGB("ef4444") },
    ["Neon Green"]    = { Accent = HexToRGB("22c55e"), Border = HexToRGB("166534"), Background = HexToRGB("050a05"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("bbf7d0"), TextDim = HexToRGB("15803d"), Footer = HexToRGB("22c55e"), Handle = HexToRGB("22c55e") },
    ["Purple Haze"]   = { Accent = HexToRGB("a855f7"), Border = HexToRGB("6b21a8"), Background = HexToRGB("0a0510"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("e9d5ff"), TextDim = HexToRGB("7e22ce"), Footer = HexToRGB("a855f7"), Handle = HexToRGB("a855f7") },
    ["Sunset Orange"] = { Accent = HexToRGB("f97316"), Border = HexToRGB("9a3412"), Background = HexToRGB("0a0500"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("fed7aa"), TextDim = HexToRGB("c2410c"), Footer = HexToRGB("f97316"), Handle = HexToRGB("f97316") },
    ["Cyan Ice"]      = { Accent = HexToRGB("06b6d4"), Border = HexToRGB("0e7490"), Background = HexToRGB("000a0a"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("a5f3fc"), TextDim = HexToRGB("0891b2"), Footer = HexToRGB("06b6d4"), Handle = HexToRGB("06b6d4") },
    ["Pink Sakura"]   = { Accent = HexToRGB("ec4899"), Border = HexToRGB("9d174d"), Background = HexToRGB("0a0005"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("fbcfe8"), TextDim = HexToRGB("be185d"), Footer = HexToRGB("ec4899"), Handle = HexToRGB("ec4899") },
    ["Matrix Green"]  = { Accent = HexToRGB("00ff41"), Border = HexToRGB("008f11"), Background = HexToRGB("000000"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("86efac"), TextDim = HexToRGB("00ff41"), Footer = HexToRGB("00ff41"), Handle = HexToRGB("00ff41") },
    ["Blood Moon"]    = { Accent = HexToRGB("dc2626"), Border = HexToRGB("450a0a"), Background = HexToRGB("000000"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("fca5a5"), TextDim = HexToRGB("991b1b"), Footer = HexToRGB("dc2626"), Handle = HexToRGB("dc2626") },
    ["Gold Luxury"]   = { Accent = HexToRGB("facc15"), Border = HexToRGB("a16207"), Background = HexToRGB("0a0800"), Sidebar = HexToRGB("000000"), HeaderBg = HexToRGB("000000"), Text = HexToRGB("ffffff"), TextLight = HexToRGB("fde68a"), TextDim = HexToRGB("ca8a04"), Footer = HexToRGB("facc15"), Handle = HexToRGB("facc15") },
}

-- ==================== NOTIFICATION ====================
local NOTIF_ICONS = {
    success = "OK",
    error = "X",
    warn = "!",
    info = "i",
}
local NOTIF_COLORS = {
    success = Color3.fromRGB(34, 197, 94),
    error = Color3.fromRGB(239, 68, 68),
    warn = Color3.fromRGB(250, 204, 21),
    info = Color3.fromRGB(59, 130, 246),
}

function ZeraserUI:Notify(cfg, windowRef)
    cfg = cfg or {}
    local container = (windowRef and windowRef.NotifContainer) or self.ActiveNotifContainer
    if not container or not container.Parent then return end
    local T = self.CurrentTheme or self.Themes["Ocean Blue"]
    local notifType = cfg.Type or "info"
    local iconColor = NOTIF_COLORS[notifType] or NOTIF_COLORS.info
    local icon = NOTIF_ICONS[notifType] or NOTIF_ICONS.info
    
    local notif = Create("Frame", {
        Size = UDim2.new(0, 290, 0, 62),
        Position = UDim2.new(1, 340, 0, 0),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        Parent = container,
    })
    Corner(notif, 6)
    Stroke(notif, T.Border, 1)
    
    Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = iconColor,
        BorderSizePixel = 0,
        Parent = notif,
    })
    
    local iconCircle = Create("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundColor3 = iconColor,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = notif,
    })
    Corner(iconCircle, 11)
    
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = iconCircle,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -45, 0, 18),
        Position = UDim2.new(0, 40, 0, 8),
        BackgroundTransparency = 1,
        Text = cfg.Title or "ZERASER UI",
        TextColor3 = T.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -45, 0, 30),
        Position = UDim2.new(0, 40, 0, 26),
        BackgroundTransparency = 1,
        Text = cfg.Text or "",
        TextColor3 = T.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notif,
    })
    
    Tween(notif, 0.3, { Position = UDim2.new(1, -310, 0, 0) })
    task.delay(cfg.Duration or 4, function()
        if notif and notif.Parent then
            local t = Tween(notif, 0.3, { Position = UDim2.new(1, 340, 0, 0) })
            if t then t.Completed:Connect(function() if notif then notif:Destroy() end end) end
        end
    end)
end

-- ==================== CREATE WINDOW ====================
function ZeraserUI:CreateWindow(cfg)
    cfg = cfg or {}
    log("Creating window...")
    
    local Window = {
        Tabs = {},
        AllElements = {},
        ThemeBindings = {},
        Connections = {},
        KeybindRegistry = {},
        IsLocked = false,
        SavedSize = UDim2.new(0, 750, 0, 450),
        ConfigName = cfg.ConfigName or "default",
        WatermarkVisible = cfg.ShowWatermark ~= false,
    }
    Window.UI = self
    
    local themeName = cfg.Theme or "Ocean Blue"
    self.CurrentTheme = self.Themes[themeName] or self.Themes["Ocean Blue"]
    Window.CurrentThemeName = themeName
    local T = self.CurrentTheme
    
    local parent = (gethui and gethui()) or CoreGui
    local screenGui = Create("ScreenGui", {
        Name = "ZeraserUI_" .. SafeGUID(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    local ok = pcall(function() screenGui.Parent = parent end)
    if not ok then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    Window.ScreenGui = screenGui
    self.ActiveNotifContainer = nil
    
    -- NOTIF CONTAINER
    local notifContainer = Create("Frame", {
        Name = "NotifContainer",
        Size = UDim2.new(0, 320, 1, -40),
        Position = UDim2.new(1, -340, 0, 20),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notifContainer,
    })
    Window.NotifContainer = notifContainer
    self.ActiveNotifContainer = notifContainer
    
    -- WATERMARK
    local watermark = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 340, 0, 26),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = T.Background,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Visible = Window.WatermarkVisible,
        Parent = screenGui,
    })
    Corner(watermark, 6)
    local wmStroke = Stroke(watermark, T.Border, 1)
    Window.Watermark = watermark
    
    local wmLogo = Create("TextLabel", {
        Size = UDim2.new(0, 90, 0, 26),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "ZERASER",
        TextColor3 = T.Text,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = watermark,
    })
    
    local fpsLabel = Create("TextLabel", {
        Size = UDim2.new(0, 55, 0, 26),
        Position = UDim2.new(0, 95, 0, 0),
        BackgroundTransparency = 1,
        Text = "FPS: 0",
        TextColor3 = T.Accent,
        TextSize = 11,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = watermark,
    })
    
    local pingLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 26),
        Position = UDim2.new(0, 155, 0, 0),
        BackgroundTransparency = 1,
        Text = "PING: 0",
        TextColor3 = T.Accent,
        TextSize = 11,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = watermark,
    })
    
    local creditLabel = Create("TextLabel", {
        Size = UDim2.new(0, 130, 0, 26),
        Position = UDim2.new(0, 210, 0, 0),
        BackgroundTransparency = 1,
        Text = "by ry-zeen & renxx",
        TextColor3 = T.TextDim,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = watermark,
    })
    
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = watermark, Property = "BackgroundColor3", ThemeKey = "Background"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = wmStroke, Property = "Color", ThemeKey = "Border"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = wmLogo, Property = "TextColor3", ThemeKey = "Text"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = fpsLabel, Property = "TextColor3", ThemeKey = "Accent"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = pingLabel, Property = "TextColor3", ThemeKey = "Accent"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = creditLabel, Property = "TextColor3", ThemeKey = "TextDim"}
    
    -- FPS/Ping loop
    local fpsBuffer = {}
    local wmConn = RunService.RenderStepped:Connect(function(dt)
        if not Window.WatermarkVisible then return end
        table.insert(fpsBuffer, dt)
        if #fpsBuffer > 20 then table.remove(fpsBuffer, 1) end
        local totalTime = 0
        for _, v in ipairs(fpsBuffer) do totalTime = totalTime + v end
        if totalTime > 0 and fpsLabel and fpsLabel.Parent then
            fpsLabel.Text = "FPS: " .. math.round(#fpsBuffer / totalTime)
        end
        local ok2, ping = pcall(function()
            return math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if ok2 and pingLabel and pingLabel.Parent then
            pingLabel.Text = "PING: " .. ping
        end
    end)
    table.insert(Window.Connections, wmConn)
    
    -- MAIN FRAME
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = Window.SavedSize,
        Position = UDim2.new(0.5, -375, 0.5, -225),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        Visible = false,
        Parent = screenGui,
    })
    Corner(mainFrame, 10)
    local mainStroke = Stroke(mainFrame, T.Border, 1)
    Window.MainFrame = mainFrame
    
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = mainFrame, Property = "BackgroundColor3", ThemeKey = "Background"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = mainStroke, Property = "Color", ThemeKey = "Border"}
    
    -- HEADER
    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = T.HeaderBg,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    local headerLine = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel = 0,
        Parent = header,
    })
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = header, Property = "BackgroundColor3", ThemeKey = "HeaderBg"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = headerLine, Property = "BackgroundColor3", ThemeKey = "Border"}
    
    local iconFrame = Create("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 15, 0.5, -14),
        BackgroundColor3 = T.Border,
        BorderSizePixel = 0,
        Parent = header,
    })
    Corner(iconFrame, 6)
    local iconLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Z",
        TextColor3 = T.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = iconFrame,
    })
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = iconFrame, Property = "BackgroundColor3", ThemeKey = "Border"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = iconLabel, Property = "TextColor3", ThemeKey = "Text"}
    
    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(0, 250, 0, 16),
        Position = UDim2.new(0, 52, 0, 12),
        BackgroundTransparency = 1,
        Text = cfg.Title or "ZERASER UI",
        TextColor3 = T.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    local subtitleLabel = Create("TextLabel", {
        Size = UDim2.new(0, 250, 0, 12),
        Position = UDim2.new(0, 52, 0, 30),
        BackgroundTransparency = 1,
        Text = cfg.Subtitle or ("by ry-zeen & renxx  |  v" .. self.Version),
        TextColor3 = T.TextDim,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = titleLabel, Property = "TextColor3", ThemeKey = "Text"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = subtitleLabel, Property = "TextColor3", ThemeKey = "TextDim"}
    
    local searchBox = Create("TextBox", {
        Size = UDim2.new(0, 180, 0, 26),
        Position = UDim2.new(1, -400, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(15, 23, 41),
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Search features...",
        PlaceholderColor3 = T.TextDim,
        TextColor3 = T.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = header,
    })
    Corner(searchBox, 5)
    local searchStroke = Stroke(searchBox, T.Border, 1)
    Window.SearchBox = searchBox
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = searchBox, Property = "TextColor3", ThemeKey = "Text"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = searchBox, Property = "PlaceholderColor3", ThemeKey = "TextDim"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = searchStroke, Property = "Color", ThemeKey = "Border"}
    
    -- LOCK BUTTON
    local lockBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -112, 0.5, -16),
        BackgroundColor3 = Color3.fromRGB(34, 197, 94),
        BorderSizePixel = 0,
        Text = "U",
        TextColor3 = T.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = header,
    })
    Corner(lockBtn, 5)
    local lockStroke = Stroke(lockBtn, Color3.fromRGB(34, 197, 94), 1)
    
    -- MINIMIZE BUTTON
    local minBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -74, 0.5, -16),
        BackgroundColor3 = Color3.fromRGB(26, 26, 26),
        BorderSizePixel = 0,
        Text = "-",
        TextColor3 = T.TextDim,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = header,
    })
    Corner(minBtn, 5)
    local minStroke = Stroke(minBtn, T.Border, 1)
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = minBtn, Property = "TextColor3", ThemeKey = "TextDim"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = minStroke, Property = "Color", ThemeKey = "Border"}
    
    -- CLOSE BUTTON
    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -36, 0.5, -16),
        BackgroundColor3 = Color3.fromRGB(26, 26, 26),
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = T.TextDim,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = header,
    })
    Corner(closeBtn, 5)
    local closeStroke = Stroke(closeBtn, T.Border, 1)
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = closeBtn, Property = "TextColor3", ThemeKey = "TextDim"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = closeStroke, Property = "Color", ThemeKey = "Border"}
    
    -- BODY
    local body = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -88),
        Position = UDim2.new(0, 0, 0, 54),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    })
    Window.Body = body
    
    -- SIDEBAR
    local sidebar = Create("Frame", {
        Size = UDim2.new(0, 130, 1, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel = 0,
        Parent = body,
    })
    local sideBorder = Create("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(1, -2, 0, 0),
        BackgroundColor3 = T.Border,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = sidebar, Property = "BackgroundColor3", ThemeKey = "Sidebar"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = sideBorder, Property = "BackgroundColor3", ThemeKey = "Border"}
    
    local tabContainer = Create("ScrollingFrame", {
        Size = UDim2.new(1, -2, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabContainer})
    Window.TabContainer = tabContainer
    
    -- CONTENT AREA
    local contentArea = Create("ScrollingFrame", {
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, 130, 0, 0),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = T.Border,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = body,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        Parent = contentArea,
    })
    Window.ContentArea = contentArea
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = contentArea, Property = "BackgroundColor3", ThemeKey = "Background"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = contentArea, Property = "ScrollBarImageColor3", ThemeKey = "Border"}
    
    -- HANDLE
    local handleWrapper = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 1, -34),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    local handle = Create("Frame", {
        Size = UDim2.new(0, 120, 0, 6),
        Position = UDim2.new(0.5, -60, 0.5, -3),
        BackgroundColor3 = T.Handle,
        BorderSizePixel = 0,
        Parent = handleWrapper,
    })
    Corner(handle, 4)
    Window.Handle = handle
    Window.HandleWrapper = handleWrapper
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = handleWrapper, Property = "BackgroundColor3", ThemeKey = "Background"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = handle, Property = "BackgroundColor3", ThemeKey = "Handle"}
    
    -- FOOTER
    local footer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = T.Footer,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = footer, Property = "BackgroundColor3", ThemeKey = "Footer"}
    
    -- TOGGLE BUTTON (Floating)
    local toggleBtn = Create("TextButton", {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(1, -80, 0, 20),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        Text = cfg.ToggleText or "ZR",
        TextColor3 = T.Accent,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = screenGui,
    })
    Corner(toggleBtn, 8)
    local toggleStroke = Stroke(toggleBtn, T.Border, 2)
    Window.ToggleBtn = toggleBtn
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = toggleBtn, Property = "BackgroundColor3", ThemeKey = "Background"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = toggleBtn, Property = "TextColor3", ThemeKey = "Accent"}
    Window.ThemeBindings[#Window.ThemeBindings+1] = {Element = toggleStroke, Property = "Color", ThemeKey = "Border"}
    
    -- ==================== LOGIC ====================
    
    -- Floating button drag
    do
        local btnDragging = false
        local btnDragStart, btnStartPos
        local moveConn, endConn
        
        local ibConn
        ibConn = toggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 
               or input.UserInputType == Enum.UserInputType.Touch then
                btnDragging = false
                btnDragStart = input.Position
                btnStartPos = toggleBtn.Position
                
                moveConn = UIS.InputChanged:Connect(function(mInput)
                    if btnDragStart and (mInput.UserInputType == Enum.UserInputType.MouseMovement 
                                         or mInput.UserInputType == Enum.UserInputType.Touch) then
                        local delta = mInput.Position - btnDragStart
                        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                            btnDragging = true
                            toggleBtn.Position = UDim2.new(
                                btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
                                btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
                            )
                        end
                    end
                end)
                
                endConn = UIS.InputEnded:Connect(function(eInput)
                    if eInput.UserInputType == Enum.UserInputType.MouseButton1 
                       or eInput.UserInputType == Enum.UserInputType.Touch then
                        if moveConn then moveConn:Disconnect(); moveConn = nil end
                        if endConn then endConn:Disconnect(); endConn = nil end
                        if not btnDragging then
                            mainFrame.Visible = not mainFrame.Visible
                            toggleBtn.Visible = not mainFrame.Visible
                        end
                        btnDragStart = nil
                    end
                end)
                
                table.insert(Window.Connections, moveConn)
                table.insert(Window.Connections, endConn)
            end
        end)
        table.insert(Window.Connections, ibConn)
    end
    
    -- Lock
    local lockConn = lockBtn.MouseButton1Click:Connect(function()
        Window.IsLocked = not Window.IsLocked
        if Window.IsLocked then
            lockBtn.Text = "L"
            lockBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
            lockStroke.Color = Color3.fromRGB(239, 68, 68)
            self:Notify({Title = "ZERASER UI", Text = "UI Locked", Type = "warn", Duration = 2}, Window)
        else
            lockBtn.Text = "U"
            lockBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
            lockStroke.Color = Color3.fromRGB(34, 197, 94)
            self:Notify({Title = "ZERASER UI", Text = "UI Unlocked", Type = "success", Duration = 2}, Window)
        end
    end)
    table.insert(Window.Connections, lockConn)
    
    -- Minimize
    local isMinimized = false
    local minConn = minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Window.SavedSize = mainFrame.Size
            body.Visible = false
            handleWrapper.Visible = false
            minBtn.Text = "[]"
            Tween(mainFrame, 0.2, {Size = UDim2.new(0, 300, 0, 54)})
        else
            body.Visible = true
            handleWrapper.Visible = true
            minBtn.Text = "-"
            Tween(mainFrame, 0.2, {Size = Window.SavedSize})
        end
    end)
    table.insert(Window.Connections, minConn)
    Window.IsMinimized = function() return isMinimized end
    
    -- Close
    local closeConn = closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        toggleBtn.Visible = true
    end)
    table.insert(Window.Connections, closeConn)
    
    -- Drag function
    local function MakeDraggable(frame, handleObj)
        local dragging = false
        local dragStart, startPos
        local moveConn, endConn
        
        local ibConn
        ibConn = handleObj.InputBegan:Connect(function(input)
            if Window.IsLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 
               or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                moveConn = UIS.InputChanged:Connect(function(mInput)
                    if not dragging then return end
                    if Window.IsLocked then dragging = false; return end
                    if mInput.UserInputType == Enum.UserInputType.MouseMovement 
                       or mInput.UserInputType == Enum.UserInputType.Touch then
                        local delta = mInput.Position - dragStart
                        frame.Position = UDim2.new(
                            startPos.X.Scale, startPos.X.Offset + delta.X,
                            startPos.Y.Scale, startPos.Y.Offset + delta.Y
                        )
                    end
                end)
                
                endConn = UIS.InputEnded:Connect(function(eInput)
                    if eInput.UserInputType == Enum.UserInputType.MouseButton1 
                       or eInput.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        if moveConn then moveConn:Disconnect(); moveConn = nil end
                        if endConn then endConn:Disconnect(); endConn = nil end
                    end
                end)
                
                table.insert(Window.Connections, moveConn)
                table.insert(Window.Connections, endConn)
            end
        end)
        table.insert(Window.Connections, ibConn)
    end
    
    MakeDraggable(mainFrame, header)
    MakeDraggable(mainFrame, handle)
    
    -- Register Element
    local function RegisterElement(row, title, get, set, type, key, default)
        table.insert(Window.AllElements, {
            Row = row, Title = title, Get = get, Set = set, Type = type,
            Key = key or (type .. "_" .. title),
            Default = default,
        })
    end
    
    local function RegisterTheme(el, prop, themeKey)
        table.insert(Window.ThemeBindings, {Element = el, Property = prop, ThemeKey = themeKey})
    end
    Window.RegisterTheme = RegisterTheme
    
    -- Keybind registry
    Window.KeybindRegistry = {}
    local function FireKeybinds(code, isPressed)
        local list = Window.KeybindRegistry[code]
        if not list then return end
        for _, cb in ipairs(list) do
            pcall(cb, isPressed)
        end
    end
    
    local kbConn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        FireKeybinds(input.KeyCode, true)
    end)
    table.insert(Window.Connections, kbConn)
    
    local kbConn2 = UIS.InputEnded:Connect(function(input, gp)
        if gp then return end
        FireKeybinds(input.KeyCode, false)
    end)
    table.insert(Window.Connections, kbConn2)
    
    -- ==================== CREATE TAB ====================
    local tabCount = 0
    function Window:CreateTab(name)
        tabCount = tabCount + 1
        local Tab = {Name = name, Sections = {}, OrderCounter = 0}
        local order = tabCount
        
        local function nextOrder()
            Tab.OrderCounter = Tab.OrderCounter + 1
            return Tab.OrderCounter
        end
        
        local tabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = T.Sidebar,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = tabContainer,
        })
        local leftBar = Create("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = T.Sidebar,
            BorderSizePixel = 0,
            Parent = tabBtn,
        })
        Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Color3.fromRGB(20, 42, 82),
            BorderSizePixel = 0,
            Parent = tabBtn,
        })
        local tabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -15, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = T.TextDim,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabBtn,
        })
        
        local page = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = contentArea,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = page,
        })
        Tab.Page = page
        Tab.Btn = tabBtn
        Tab.LeftBar = leftBar
        Tab.Label = tabLabel
        
        function Tab:Select()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                Tween(t.Btn, 0.15, {BackgroundColor3 = T.Sidebar})
                t.LeftBar.BackgroundColor3 = T.Sidebar
                t.Label.TextColor3 = T.TextDim
            end
            page.Visible = true
            Tween(tabBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(15, 37, 71)})
            leftBar.BackgroundColor3 = T.Accent
            tabLabel.TextColor3 = T.Text
            Window.CurrentTab = Tab
        end
        
        local selConn = tabBtn.MouseButton1Click:Connect(function() Tab:Select() end)
        table.insert(Window.Connections, selConn)
        
        -- ========== CREATE SECTION ==========
        function Tab:CreateSection(title)
            local Section = {Collapsed = false}
            
            local headerBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = nextOrder(),
                Parent = page,
            })
            
            local collapseArrow = Create("TextLabel", {
                Size = UDim2.new(0, 14, 1, 0),
                Position = UDim2.new(0, -2, 0, 0),
                BackgroundTransparency = 1,
                Text = "v",
                TextColor3 = T.Accent,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = headerBtn,
            })
            
            local titleLbl = Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = T.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = headerBtn,
            })
            
            local divider = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = T.Border,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                Parent = page,
            })
            
            RegisterTheme(titleLbl, "TextColor3", "Text")
            RegisterTheme(collapseArrow, "TextColor3", "Accent")
            RegisterTheme(divider, "BackgroundColor3", "Border")
            
            local sectionFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = nextOrder(),
                Parent = page,
            })
            Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = sectionFrame})
            Section.Frame = sectionFrame
            
            -- Collapse
            local collapseConn = headerBtn.MouseButton1Click:Connect(function()
                Section.Collapsed = not Section.Collapsed
                sectionFrame.Visible = not Section.Collapsed
                Tween(collapseArrow, 0.2, {
                    Rotation = Section.Collapsed and -90 or 0
                })
            end)
            table.insert(Window.Connections, collapseConn)
            
            -- Row helpers
            local rowCounter = 0
            local function makeRow(height)
                rowCounter = rowCounter + 1
                local row = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 50),
                    BackgroundTransparency = 1,
                    LayoutOrder = rowCounter,
                    Parent = sectionFrame,
                })
                local rl = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, -1),
                    BackgroundColor3 = Color3.fromRGB(20, 42, 82),
                    BorderSizePixel = 0,
                    Parent = row,
                })
                RegisterTheme(rl, "BackgroundColor3", "Border")
                return row
            end
            
            local function makeText(row, title, desc)
                local tl = Create("TextLabel", {
                    Size = UDim2.new(0.65, 0, 0, 14),
                    Position = UDim2.new(0, 0, 0, 10),
                    BackgroundTransparency = 1,
                    Text = title,
                    TextColor3 = T.TextLight,
                    TextSize = 13,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
                local dl = Create("TextLabel", {
                    Size = UDim2.new(0.65, 0, 0, 12),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = desc or "",
                    TextColor3 = T.TextDim,
                    TextSize = 9,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
                RegisterTheme(tl, "TextColor3", "TextLight")
                RegisterTheme(dl, "TextColor3", "TextDim")
            end
            
            -- ===== TOGGLE =====
            function Section:CreateToggle(cfg)
                cfg = cfg or {}
                local state = cfg.Default or false
                local row = makeRow(50)
                makeText(row, cfg.Title or "Toggle", cfg.Desc)
                
                local track = Create("TextButton", {
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -40, 0.5, -11),
                    BackgroundColor3 = state and T.Border or Color3.fromRGB(26, 26, 26),
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = row,
                })
                Corner(track, 4)
                local trackStroke = Stroke(track, state and T.Accent or T.Border, 1)
                
                local knob = Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = state and T.Text or T.TextDim,
                    BorderSizePixel = 0,
                    Parent = track,
                })
                Corner(knob, 2)
                
                local function applyTheme()
                    local TT = self.CurrentTheme
                    Tween(track, 0.3, {BackgroundColor3 = state and TT.Border or Color3.fromRGB(26, 26, 26)})
                    Tween(trackStroke, 0.3, {Color = state and TT.Accent or TT.Border})
                    Tween(knob, 0.3, {BackgroundColor3 = state and TT.Text or TT.TextDim})
                end
                table.insert(Window.ThemeBindings, {CustomApply = applyTheme})
                
                local function setState(v)
                    state = v
                    local TT = self.CurrentTheme
                    if state then
                        Tween(track, 0.2, {BackgroundColor3 = TT.Border})
                        Tween(trackStroke, 0.2, {Color = TT.Accent})
                        Tween(knob, 0.2, {
                            Position = UDim2.new(1, -17, 0.5, -7),
                            BackgroundColor3 = TT.Text,
                        })
                    else
                        Tween(track, 0.2, {BackgroundColor3 = Color3.fromRGB(26, 26, 26)})
                        Tween(trackStroke, 0.2, {Color = TT.Border})
                        Tween(knob, 0.2, {
                            Position = UDim2.new(0, 3, 0.5, -7),
                            BackgroundColor3 = TT.TextDim,
                        })
                    end
                    if cfg.Callback then pcall(cfg.Callback, state) end
                end
                
                local clickConn = track.MouseButton1Click:Connect(function() setState(not state) end)
                table.insert(Window.Connections, clickConn)
                
                local obj = { Set = setState, Get = function() return state end }
                RegisterElement(row, cfg.Title or "Toggle", obj.Get, obj.Set, "toggle", cfg.Key, cfg.Default or false)
                return obj
            end
            
            -- ===== SLIDER =====
            function Section:CreateSlider(cfg)
                cfg = cfg or {}
                local min = cfg.Min or 0
                local max = cfg.Max or 100
                local value = math.clamp(cfg.Default or min, min, max)
                local callback = cfg.Callback or function() end
                local suffix = cfg.Suffix or ""
                
                local row = makeRow(50)
                makeText(row, cfg.Title or "Slider", cfg.Desc)
                
                local valueBox = Create("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 22),
                    Position = UDim2.new(1, -50, 0.5, -11),
                    BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                    BorderSizePixel = 0,
                    Text = tostring(value) .. suffix,
                    TextColor3 = T.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    Parent = row,
                })
                Corner(valueBox, 4)
                local vbStroke = Stroke(valueBox, T.Border, 1)
                
                local barBg = Create("Frame", {
                    Size = UDim2.new(0, 120, 0, 4),
                    Position = UDim2.new(1, -180, 0.5, -2),
                    BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                    BorderSizePixel = 0,
                    Parent = row,
                })
                Corner(barBg, 4)
                
                local initRatio = (value - min) / (max - min)
                local fill = Create("Frame", {
                    Size = UDim2.new(initRatio, 0, 1, 0),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel = 0,
                    Parent = barBg,
                })
                Corner(fill, 4)
                
                local knobSlider = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(initRatio, -6, 0.5, -6),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel = 0,
                    Parent = barBg,
                })
                Corner(knobSlider, 2)
                
                RegisterTheme(valueBox, "TextColor3", "Text")
                RegisterTheme(vbStroke, "Color", "Border")
                RegisterTheme(fill, "BackgroundColor3", "Accent")
                RegisterTheme(knobSlider, "BackgroundColor3", "Accent")
                
                local dragging = false
                local moveConn, endConn
                
                local function update(input)
                    local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * rel)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knobSlider.Position = UDim2.new(rel, -6, 0.5, -6)
                    valueBox.Text = tostring(value) .. suffix
                    pcall(callback, value)
                end
                
                local ibConn
                ibConn = barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 
                       or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input)
                        
                        moveConn = UIS.InputChanged:Connect(function(mInput)
                            if dragging and (mInput.UserInputType == Enum.UserInputType.MouseMovement 
                                             or mInput.UserInputType == Enum.UserInputType.Touch) then
                                update(mInput)
                            end
                        end)
                        
                        endConn = UIS.InputEnded:Connect(function(eInput)
                            if eInput.UserInputType == Enum.UserInputType.MouseButton1
                               or eInput.UserInputType == Enum.UserInputType.Touch then
                                dragging = false
                                if moveConn then moveConn:Disconnect(); moveConn = nil end
                                if endConn then endConn:Disconnect(); endConn = nil end
                            end
                        end)
                        
                        table.insert(Window.Connections, moveConn)
                        table.insert(Window.Connections, endConn)
                    end
                end)
                table.insert(Window.Connections, ibConn)
                
                local obj = {
                    Set = function(v)
                        value = math.clamp(v, min, max)
                        local rel = (value - min) / (max - min)
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        knobSlider.Position = UDim2.new(rel, -6, 0.5, -6)
                        valueBox.Text = tostring(value) .. suffix
                        pcall(callback, value)
                    end,
                    Get = function() return value end,
                }
                RegisterElement(row, cfg.Title or "Slider", obj.Get, obj.Set, "slider", cfg.Key, cfg.Default or min)
                return obj
            end
            
            -- ===== DROPDOWN =====
            function Section:CreateDropdown(cfg)
                cfg = cfg or {}
                local options = cfg.Options or {"None"}
                local current = cfg.Default or options[1]
                local callback = cfg.Callback or function() end
                local dropOpen = false
                
                local row = makeRow(50)
                makeText(row, cfg.Title or "Dropdown", cfg.Desc)
                
                local btn = Create("TextButton", {
                    Size = UDim2.new(0, 120, 0, 26),
                    Position = UDim2.new(1, -120, 0.5, -13),
                    BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = row,
                })
                Corner(btn, 4)
                local btnStroke = Stroke(btn, T.Border, 1)
                
                local btnText = Create("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(current),
                    TextColor3 = T.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = btn,
                })
                
                local arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 12, 1, 0),
                    Position = UDim2.new(1, -16, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "v",
                    TextColor3 = T.TextDim,
                    TextSize = 9,
                    Font = Enum.Font.GothamBold,
                    Parent = btn,
                })
                
                RegisterTheme(btnText, "TextColor3", "Text")
                RegisterTheme(arrow, "TextColor3", "TextDim")
                RegisterTheme(btnStroke, "Color", "Border")
                
                local listFrame = Create("Frame", {
                    Size = UDim2.new(0, 120, 0, 0),
                    Position = UDim2.new(1, -120, 0, 36),
                    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                    BorderSizePixel = 0,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 500,
                    Parent = row,
                })
                Corner(listFrame, 5)
                local listStroke = Stroke(listFrame, T.Border, 1)
                RegisterTheme(listStroke, "Color", "Border")
                RegisterTheme(listFrame, "BackgroundColor3", "Sidebar")
                
                local listScroll = Create("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = T.Border,
                    CanvasSize = UDim2.new(),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = listFrame,
                })
                Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0), Parent = listScroll})
                
                for i, opt in ipairs(options) do
                    local optBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex = 501,
                        Parent = listScroll,
                    })
                    local optLabel = Create("TextLabel", {
                        Size = UDim2.new(1, -10, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(opt),
                        TextColor3 = T.TextLight,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 502,
                        Parent = optBtn,
                    })
                    RegisterTheme(optLabel, "TextColor3", "TextLight")
                    
                    local enterConn = optBtn.MouseEnter:Connect(function()
                        Tween(optBtn, 0.1, {BackgroundTransparency = 0.7})
                    end)
                    local leaveConn = optBtn.MouseLeave:Connect(function()
                        Tween(optBtn, 0.1, {BackgroundTransparency = 1})
                    end)
                    local clickConn = optBtn.MouseButton1Click:Connect(function()
                        current = opt
                        btnText.Text = tostring(opt)
                        pcall(callback, opt)
                        dropOpen = false
                        Tween(listFrame, 0.2, {Size = UDim2.new(0, 120, 0, 0)})
                        task.delay(0.21, function() listFrame.Visible = false end)
                    end)
                    table.insert(Window.Connections, enterConn)
                    table.insert(Window.Connections, leaveConn)
                    table.insert(Window.Connections, clickConn)
                end
                
                local mainConn = btn.MouseButton1Click:Connect(function()
                    dropOpen = not dropOpen
                    if dropOpen then
                        listFrame.Visible = true
                        listFrame.Size = UDim2.new(0, 120, 0, 0)
                        
                        local h = math.min(#options * 24, 120)
                        local btnAbsY = btn.AbsolutePosition.Y
                        local btnH = btn.AbsoluteSize.Y
                        local screenH = contentArea.AbsoluteSize.Y
                        local contentTop = contentArea.AbsolutePosition.Y
                        local spaceBelow = (contentTop + screenH) - (btnAbsY + btnH)
                        
                        if spaceBelow < h + 10 then
                            listFrame.Position = UDim2.new(1, -120, 0, -h - 10)
                            Tween(arrow, 0.2, {Rotation = 180})
                        else
                            listFrame.Position = UDim2.new(1, -120, 0, 36)
                            Tween(arrow, 0.2, {Rotation = 0})
                        end
                        
                        Tween(listFrame, 0.25, {Size = UDim2.new(0, 120, 0, h)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    else
                        Tween(listFrame, 0.2, {Size = UDim2.new(0, 120, 0, 0)})
                        task.delay(0.21, function() listFrame.Visible = false end)
                    end
                end)
                table.insert(Window.Connections, mainConn)
                
                local obj = {
                    Set = function(v) current = v; btnText.Text = tostring(v); pcall(callback, v) end,
                    Get = function() return current end,
                }
                RegisterElement(row, cfg.Title or "Dropdown", obj.Get, obj.Set, "dropdown", cfg.Key, cfg.Default or options[1])
                return obj
            end
            
            -- ===== KEYBIND =====
            function Section:CreateKeybind(cfg)
                cfg = cfg or {}
                local currentKey = cfg.Default or "None"
                local callback = cfg.Callback or function() end
                local binding = false
                local currentCode = nil
                local keyRegistered = nil
                
                local row = makeRow(50)
                makeText(row, cfg.Title or "Keybind", cfg.Desc)
                
                local keyBtn = Create("TextButton", {
                    Size = UDim2.new(0, 60, 0, 24),
                    Position = UDim2.new(1, -60, 0.5, -12),
                    BackgroundColor3 = Color3.fromRGB(15, 23, 41),
                    BorderSizePixel = 0,
                    Text = currentKey,
                    TextColor3 = T.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    AutoButtonColor = false,
                    Parent = row,
                })
                Corner(keyBtn, 4)
                local kbStroke = Stroke(keyBtn, T.Border, 1)
                RegisterTheme(keyBtn, "TextColor3", "TextDim")
                RegisterTheme(kbStroke, "Color", "Border")
                
                local function unregisterKey()
                    if keyRegistered and currentCode and Window.KeybindRegistry[currentCode] then
                        local list = Window.KeybindRegistry[currentCode]
                        for idx, cb in ipairs(list) do
                            if cb == keyRegistered then
                                table.remove(list, idx)
                                break
                            end
                        end
                        if #list == 0 then
                            Window.KeybindRegistry[currentCode] = nil
                        end
                    end
                    keyRegistered = nil
                end
                
                local function registerKey(code)
                    unregisterKey()
                    currentCode = code
                    if not code then return end
                    keyRegistered = callback
                    if not Window.KeybindRegistry[code] then
                        Window.KeybindRegistry[code] = {}
                    end
                    table.insert(Window.KeybindRegistry[code], callback)
                end
                
                if currentKey ~= "None" then
                    local okc, code = pcall(function() return Enum.KeyCode[currentKey] end)
                    if okc and code then registerKey(code) end
                end
                
                local btnConn = keyBtn.MouseButton1Click:Connect(function()
                    if binding then
                        binding = false
                        keyBtn.Text = currentKey
                        keyBtn.TextColor3 = self.CurrentTheme.TextDim
                        return
                    end
                    binding = true
                    keyBtn.Text = "..."
                    keyBtn.TextColor3 = self.CurrentTheme.Text
                end)
                table.insert(Window.Connections, btnConn)
                
                local inputConn
                inputConn = UIS.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if not binding then return end
                    binding = false
                    if input.KeyCode == Enum.KeyCode.Escape then
                        keyBtn.Text = currentKey
                        keyBtn.TextColor3 = self.CurrentTheme.TextDim
                        return
                    end
                    local keyName = input.KeyCode.Name
                    currentKey = keyName
                    keyBtn.Text = keyName
                    keyBtn.TextColor3 = self.CurrentTheme.Text
                    registerKey(input.KeyCode)
                    pcall(callback, keyName)
                end)
                table.insert(Window.Connections, inputConn)
                
                local obj = {
                    Set = function(v)
                        currentKey = v
                        keyBtn.Text = v
                        local okc, code = pcall(function() return Enum.KeyCode[v] end)
                        if okc and code then registerKey(code) end
                    end,
                    Get = function() return currentKey end,
                }
                RegisterElement(row, cfg.Title or "Keybind", obj.Get, obj.Set, "keybind", cfg.Key, cfg.Default or "None")
                return obj
            end
            
            -- ===== BUTTON =====
            function Section:CreateButton(cfg)
                cfg = cfg or {}
                local callback = cfg.Callback or function() end
                local row = makeRow(46)
                makeText(row, cfg.Title or "Button", cfg.Desc)
                
                local btn = Create("TextButton", {
                    Size = UDim2.new(0, 80, 0, 26),
                    Position = UDim2.new(1, -80, 0.5, -13),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel = 0,
                    Text = cfg.ButtonText or "Click",
                    TextColor3 = T.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    AutoButtonColor = false,
                    Parent = row,
                })
                Corner(btn, 4)
                RegisterTheme(btn, "BackgroundColor3", "Border")
                RegisterTheme(btn, "TextColor3", "Text")
                
                local enterConn = btn.MouseEnter:Connect(function()
                    Tween(btn, 0.15, {BackgroundColor3 = self.CurrentTheme.Accent})
                end)
                local leaveConn = btn.MouseLeave:Connect(function()
                    Tween(btn, 0.15, {BackgroundColor3 = self.CurrentTheme.Border})
                end)
                local clickConn = btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
                table.insert(Window.Connections, enterConn)
                table.insert(Window.Connections, leaveConn)
                table.insert(Window.Connections, clickConn)
                return btn
            end
            
            -- ===== TEXTBOX =====
            function Section:CreateTextbox(cfg)
                cfg = cfg or {}
                local callback = cfg.Callback or function() end
                local row = makeRow(50)
                makeText(row, cfg.Title or "Input", cfg.Desc)
                
                local box = Create("TextBox", {
                    Size = UDim2.new(0, 120, 0, 26),
                    Position = UDim2.new(1, -120, 0.5, -13),
                    BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                    BorderSizePixel = 0,
                    Text = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "Type...",
                    PlaceholderColor3 = T.TextDim,
                    TextColor3 = T.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    Parent = row,
                })
                Corner(box, 4)
                local boxStroke = Stroke(box, T.Border, 1)
                RegisterTheme(box, "TextColor3", "Text")
                RegisterTheme(box, "PlaceholderColor3", "TextDim")
                RegisterTheme(boxStroke, "Color", "Border")
                
                local flConn = box.FocusLost:Connect(function()
                    pcall(callback, box.Text)
                end)
                table.insert(Window.Connections, flConn)
                
                local obj = {
                    Set = function(v) box.Text = v; pcall(callback, v) end,
                    Get = function() return box.Text end,
                }
                RegisterElement(row, cfg.Title or "Input", obj.Get, obj.Set, "textbox", cfg.Key, cfg.Default or "")
                return obj
            end
            
            -- ===== LABEL =====
            function Section:CreateLabel(text, height)
                rowCounter = rowCounter + 1
                local label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, height or 20),
                    BackgroundTransparency = 1,
                    Text = text or "",
                    TextColor3 = T.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    LayoutOrder = rowCounter,
                    Parent = sectionFrame,
                })
                RegisterTheme(label, "TextColor3", "TextDim")
                return label
            end
            
            -- ===== HSV COLORPICKER =====
            function Section:CreateColorPicker(cfg)
                cfg = cfg or {}
                local currentColor = cfg.Default or Color3.fromRGB(59, 130, 246)
                local callback = cfg.Callback or function() end
                local h, s, v = RGBtoHSV(currentColor)
                
                local row = makeRow(50)
                makeText(row, cfg.Title or "Color", cfg.Desc)
                
                local colorBtn = Create("TextButton", {
                    Size = UDim2.new(0, 30, 0, 30),
                    Position = UDim2.new(1, -30, 0.5, -15),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = row,
                })
                Corner(colorBtn, 5)
                local cbStroke = Stroke(colorBtn, T.Border, 1)
                RegisterTheme(cbStroke, "Color", "Border")
                
                local popup = Create("Frame", {
                    Size = UDim2.new(0, 220, 0, 0),
                    Position = UDim2.new(1, -250, 0, 36),
                    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                    BorderSizePixel = 0,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 600,
                    Parent = row,
                })
                Corner(popup, 6)
                local popupStroke = Stroke(popup, T.Border, 1)
                RegisterTheme(popupStroke, "Color", "Border")
                RegisterTheme(popup, "BackgroundColor3", "Sidebar")
                
                local content = Create("Frame", {
                    Size = UDim2.new(1, -20, 0, 0),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = popup,
                })
                Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content})
                
                local cTitle = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = "Color Picker",
                    TextColor3 = T.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 1,
                    Parent = content,
                })
                RegisterTheme(cTitle, "TextColor3", "Text")
                
                local svSquare = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 100),
                    BackgroundColor3 = HSVtoRGB(h, 1, 1),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    LayoutOrder = 2,
                    Parent = content,
                })
                Corner(svSquare, 5)
                
                local svWhiteGrad = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    Parent = svSquare,
                })
                Create("UIGradient", {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    }),
                    Parent = svWhiteGrad,
                })
                
                local svBlackGrad = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 3,
                    Parent = svSquare,
                })
                Create("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    }),
                    Parent = svBlackGrad,
                })
                
                local svCursor = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(s, -6, 1 - v, -6),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = svSquare,
                })
                Corner(svCursor, 6)
                Stroke(svCursor, Color3.new(1, 1, 1), 2, 0)
                
                local hueSlider = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundColor3 = Color3.new(1, 0, 0),
                    BorderSizePixel = 0,
                    LayoutOrder = 3,
                    Parent = content,
                })
                Corner(hueSlider, 4)
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
                    }),
                    Parent = hueSlider,
                })
                
                local hueCursor = Create("Frame", {
                    Size = UDim2.new(0, 4, 0, 20),
                    Position = UDim2.new(h, -2, 0.5, -10),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = hueSlider,
                })
                Corner(hueCursor, 2)
                Stroke(hueCursor, Color3.new(0, 0, 0), 1, 0)
                
                local bottomRow = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    LayoutOrder = 4,
                    Parent = content,
                })
                
                local hexPreview = Create("Frame", {
                    Size = UDim2.new(0, 30, 1, 0),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Parent = bottomRow,
                })
                Corner(hexPreview, 4)
                
                local hexBox = Create("TextBox", {
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 36, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                    BorderSizePixel = 0,
                    Text = RGBToHex(currentColor),
                    TextColor3 = T.Text,
                    TextSize = 11,
                    Font = Enum.Font.Code,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Parent = bottomRow,
                })
                Corner(hexBox, 4)
                local hexStroke = Stroke(hexBox, T.Border, 1)
                RegisterTheme(hexBox, "TextColor3", "Text")
                RegisterTheme(hexStroke, "Color", "Border")
                
                local function applyColor(fireCallback)
                    currentColor = HSVtoRGB(h, s, v)
                    colorBtn.BackgroundColor3 = currentColor
                    hexPreview.BackgroundColor3 = currentColor
                    hexBox.Text = RGBToHex(currentColor)
                    svSquare.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                    if fireCallback then pcall(callback, currentColor) end
                end
                
                local svDragging, hueDragging = false, false
                local svMoveConn, hueMoveConn, svEndConn, hueEndConn
                
                local function updateSV(input)
                    local relX = math.clamp((input.Position.X - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1)
                    local relY = math.clamp((input.Position.Y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
                    s = relX
                    v = 1 - relY
                    svCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                    applyColor(true)
                end
                
                local function updateHue(input)
                    local rel = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                    h = rel
                    hueCursor.Position = UDim2.new(h, -2, 0.5, -10)
                    applyColor(true)
                end
                
                local svIbConn = svSquare.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 
                       or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = true
                        updateSV(input)
                        svMoveConn = UIS.InputChanged:Connect(function(m)
                            if svDragging and (m.UserInputType == Enum.UserInputType.MouseMovement 
                                              or m.UserInputType == Enum.UserInputType.Touch) then
                                updateSV(m)
                            end
                        end)
                        svEndConn = UIS.InputEnded:Connect(function(e)
                            if e.UserInputType == Enum.UserInputType.MouseButton1
                               or e.UserInputType == Enum.UserInputType.Touch then
                                svDragging = false
                                if svMoveConn then svMoveConn:Disconnect(); svMoveConn = nil end
                                if svEndConn then svEndConn:Disconnect(); svEndConn = nil end
                            end
                        end)
                        table.insert(Window.Connections, svMoveConn)
                        table.insert(Window.Connections, svEndConn)
                    end
                end)
                table.insert(Window.Connections, svIbConn)
                
                local hueIbConn = hueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 
                       or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = true
                        updateHue(input)
                        hueMoveConn = UIS.InputChanged:Connect(function(m)
                            if hueDragging and (m.UserInputType == Enum.UserInputType.MouseMovement 
                                               or m.UserInputType == Enum.UserInputType.Touch) then
                                updateHue(m)
                            end
                        end)
                        hueEndConn = UIS.InputEnded:Connect(function(e)
                            if e.UserInputType == Enum.UserInputType.MouseButton1
                               or e.UserInputType == Enum.UserInputType.Touch then
                                hueDragging = false
                                if hueMoveConn then hueMoveConn:Disconnect(); hueMoveConn = nil end
                                if hueEndConn then hueEndConn:Disconnect(); hueEndConn = nil end
                            end
                        end)
                        table.insert(Window.Connections, hueMoveConn)
                        table.insert(Window.Connections, hueEndConn)
                    end
                end)
                table.insert(Window.Connections, hueIbConn)
                
                local hexConn = hexBox.FocusLost:Connect(function()
                    local hx = hexBox.Text:gsub("#", "")
                    if #hx == 6 then
                        local newC = HexToRGB(hx)
                        local nh, ns, nv = RGBtoHSV(newC)
                        h, s, v = nh, ns, nv
                        svCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                        hueCursor.Position = UDim2.new(h, -2, 0.5, -10)
                        applyColor(true)
                    end
                end)
                table.insert(Window.Connections, hexConn)
                
                local openConn = colorBtn.MouseButton1Click:Connect(function()
                    if popup.Visible then
                        Tween(popup, 0.2, {Size = UDim2.new(0, 220, 0, 0)})
                        task.delay(0.21, function() popup.Visible = false end)
                    else
                        popup.Visible = true
                        popup.Size = UDim2.new(0, 220, 0, 0)
                        task.wait(0.05)
                        local totalH = content.AbsoluteSize.Y + 20
                        Tween(popup, 0.25, {Size = UDim2.new(0, 220, 0, totalH)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    end
                end)
                table.insert(Window.Connections, openConn)
                
                applyColor(false)
                
                local obj = {
                    Set = function(c)
                        local nh, ns, nv = RGBtoHSV(c)
                        h, s, v = nh, ns, nv
                        svCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                        hueCursor.Position = UDim2.new(h, -2, 0.5, -10)
                        applyColor(true)
                    end,
                    Get = function() return currentColor end,
                }
                RegisterElement(row, cfg.Title or "Color", obj.Get, obj.Set, "colorpicker", cfg.Key, cfg.Default or Color3.fromRGB(59, 130, 246))
                return obj
            end
            
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Select() end
        return Tab
    end
    
    -- ==================== SEARCH ====================
    local function applySearchHighlight()
        local q = searchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        
        for _, el in ipairs(Window.AllElements) do
            if el.Row and el.Title then
                local match = (q == "" or el.Title:lower():find(q, 1, true) ~= nil)
                el.Row.Visible = match
                
                local titleLabel = el.Row:FindFirstChild("TextLabel")
                if titleLabel and titleLabel.Text == el.Title then
                    if q ~= "" and match then
                        titleLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
                    else
                        titleLabel.TextColor3 = self.CurrentTheme.TextLight
                    end
                end
            end
        end
    end
    Window.ApplySearchHighlight = applySearchHighlight
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        applySearchHighlight()
        
        local q = searchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        if q ~= "" then
            for _, tab in ipairs(Window.Tabs) do
                for _, el in ipairs(Window.AllElements) do
                    if el.Row and el.Row.Visible and el.Row:IsDescendantOf(tab.Page) then
                        tab:Select()
                        return
                    end
                end
            end
        end
    end)
    
    -- ==================== THEME CHANGER ====================
    function Window:SetTheme(themeName)
        local newT = self.UI.Themes[themeName]
        if not newT then return end
        self.UI.CurrentTheme = newT
        self.CurrentThemeName = themeName
        
        for _, binding in ipairs(Window.ThemeBindings) do
            if binding.CustomApply then
                pcall(binding.CustomApply)
            elseif binding.Element and binding.Element.Parent and binding.ThemeKey then
                local col = newT[binding.ThemeKey]
                if col then
                    pcall(function() binding.Element[binding.Property] = col end)
                end
            end
        end
        
        if Window.ApplySearchHighlight then
            Window.ApplySearchHighlight()
        end
        
        self.UI:Notify({Title = "Theme", Text = "Theme: " .. themeName, Type = "success", Duration = 3}, self)
    end
    
    function Window:GetThemeList()
        local list = {}
        for name, _ in pairs(self.UI.Themes) do
            table.insert(list, name)
        end
        table.sort(list)
        return list
    end
    
    -- ==================== CONFIG ====================
    local function configPath()
        return "ZeraserUI_" .. Window.ConfigName .. ".json"
    end
    
    function Window:SaveConfig(name)
        if not hasFileAPI or not hasJSON then 
            self.UI:Notify({Title = "Config", Text = "File API tidak tersedia", Type = "error", Duration = 3}, self)
            return 
        end
        name = name or Window.ConfigName
        Window.ConfigName = name
        local data = {}
        for _, el in ipairs(Window.AllElements) do
            if el.Key and el.Get then
                local ok2, val = pcall(el.Get)
                if ok2 then
                    if typeof(val) == "Color3" then
                        data[el.Key] = {__type = "Color3", r = val.R, g = val.G, b = val.B}
                    else
                        data[el.Key] = val
                    end
                end
            end
        end
        data.__theme = Window.CurrentThemeName
        local ok2, encoded = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
        if ok2 then
            pcall(writefile, configPath(), encoded)
            self.UI:Notify({Title = "Config", Text = "Saved: " .. name, Type = "success", Duration = 2}, self)
        end
    end
    
    function Window:LoadConfig(name)
        if not hasFileAPI or not hasJSON then return end
        name = name or Window.ConfigName
        Window.ConfigName = name
        if not isfile(configPath()) then
            self.UI:Notify({Title = "Config", Text = "File tidak ada: " .. name, Type = "error", Duration = 2}, self)
            return
        end
        local ok2, content = pcall(readfile, configPath())
        if not ok2 then return end
        local dok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(content) end)
        if not dok or type(data) ~= "table" then return end
        for _, el in ipairs(Window.AllElements) do
            if el.Key and data[el.Key] ~= nil then
                local val = data[el.Key]
                if type(val) == "table" and val.__type == "Color3" then
                    val = Color3.new(val.r, val.g, val.b)
                end
                pcall(el.Set, val)
            end
        end
        if data.__theme then
            Window:SetTheme(data.__theme)
        end
        self.UI:Notify({Title = "Config", Text = "Loaded: " .. name, Type = "success", Duration = 2}, self)
    end
    
    -- ==================== SETTINGS TAB (AUTO) ====================
    task.defer(function()
        local ok2, err = pcall(function()
            local SettingsTab = Window:CreateTab("Settings")
            
            local ThemeSec = SettingsTab:CreateSection("Theme Preset")
            ThemeSec:CreateDropdown({
                Title = "Select Theme",
                Desc = "Ganti tema UI",
                Options = Window:GetThemeList(),
                Default = Window.CurrentThemeName,
                Callback = function(v) Window:SetTheme(v) end,
                Key = "settings_theme",
            })
            
            local SizeSec = SettingsTab:CreateSection("UI Size")
            local baseW = 750
            local baseH = 450
            
            SizeSec:CreateSlider({
                Title = "UI Width",
                Desc = "Lebar UI (px)",
                Min = 500, Max = 1200, Default = 750,
                Key = "settings_ui_width",
                Callback = function(v)
                    baseW = v
                    if not isMinimized then
                        mainFrame.Size = UDim2.new(0, baseW, 0, baseH)
                    end
                    Window.SavedSize = UDim2.new(0, baseW, 0, baseH)
                end,
            })
            
            SizeSec:CreateSlider({
                Title = "UI Height",
                Desc = "Tinggi body (px)",
                Min = 300, Max = 700, Default = 450,
                Key = "settings_ui_height",
                Callback = function(v)
                    baseH = v
                    if not isMinimized then
                        mainFrame.Size = UDim2.new(0, baseW, 0, baseH)
                    end
                    Window.SavedSize = UDim2.new(0, baseW, 0, baseH)
                end,
            })
            
            local HandleSec = SettingsTab:CreateSection("Drag Handle")
            HandleSec:CreateSlider({
                Title = "Handle Width",
                Desc = "Lebar handle (px)",
                Min = 40, Max = 300, Default = 120,
                Key = "settings_handle_width",
                Callback = function(v)
                    handle.Size = UDim2.new(0, v, 0, handle.Size.Y.Offset)
                    handle.Position = UDim2.new(0.5, -v/2, 0.5, -handle.Size.Y.Offset/2)
                end,
            })
            HandleSec:CreateSlider({
                Title = "Handle Height",
                Desc = "Tebal handle (px)",
                Min = 3, Max = 20, Default = 6,
                Key = "settings_handle_height",
                Callback = function(v)
                    handle.Size = UDim2.new(0, handle.Size.X.Offset, 0, v)
                    handle.Position = UDim2.new(0.5, -handle.Size.X.Offset/2, 0.5, -v/2)
                end,
            })
            
            local DisplaySec = SettingsTab:CreateSection("Display")
            DisplaySec:CreateToggle({
                Title = "Show Watermark",
                Desc = "Tampilkan FPS/Ping overlay",
                Default = Window.WatermarkVisible,
                Key = "settings_watermark",
                Callback = function(v)
                    Window.WatermarkVisible = v
                    watermark.Visible = v
                end,
            })
            
            local DebugSec = SettingsTab:CreateSection("Advanced")
            DebugSec:CreateToggle({
                Title = "Debug Mode",
                Desc = "Print log ke console",
                Default = false,
                Key = "settings_debug",
                Callback = function(v) ZeraserUI.Debug = v end,
            })
            
            local ConfigSec = SettingsTab:CreateSection("Config")
            ConfigSec:CreateTextbox({
                Title = "Config Name",
                Desc = "Nama config file",
                Default = Window.ConfigName,
                Placeholder = "default",
                Key = "settings_config_name",
                Callback = function(v) Window.ConfigName = v end,
            })
            ConfigSec:CreateButton({
                Title = "Save Config",
                Desc = "Simpan setting sekarang",
                ButtonText = "Save",
                Callback = function() Window:SaveConfig() end,
            })
            ConfigSec:CreateButton({
                Title = "Load Config",
                Desc = "Load setting terakhir",
                ButtonText = "Load",
                Callback = function() Window:LoadConfig() end,
            })
            
            local ResetSec = SettingsTab:CreateSection("Reset")
            ResetSec:CreateButton({
                Title = "Reset to Default",
                Desc = "Balikin semua setting ke default",
                ButtonText = "Reset",
                Callback = function()
                    for _, el in ipairs(Window.AllElements) do
                        if el.Set and el.Default ~= nil and el.Key ~= "settings_watermark" then
                            pcall(el.Set, el.Default)
                        end
                    end
                    
                    Window:SetTheme("Ocean Blue")
                    
                    baseW = 750
                    baseH = 450
                    mainFrame.Size = UDim2.new(0, 750, 0, 450)
                    Window.SavedSize = UDim2.new(0, 750, 0, 450)
                    
                    handle.Size = UDim2.new(0, 120, 0, 6)
                    handle.Position = UDim2.new(0.5, -60, 0.5, -3)
                    
                    Window.WatermarkVisible = true
                    watermark.Visible = true
                    for _, el in ipairs(Window.AllElements) do
                        if el.Key == "settings_watermark" and el.Set then
                            el.Set(true)
                        end
                    end
                    
                    ZeraserUI:Notify({Title = "Reset", Text = "All settings reset to default", Type = "success", Duration = 3}, Window)
                end,
            })
        end)
        if not ok2 then log("Settings tab error: " .. tostring(err), true) end
    end)
    
    -- ==================== DESTROY ====================
    function Window:Destroy()
        for code, list in pairs(self.KeybindRegistry) do
            self.KeybindRegistry[code] = nil
        end
        self.KeybindRegistry = {}
        
        for _, conn in ipairs(self.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        self.Connections = {}
        
        self.AllElements = {}
        self.ThemeBindings = {}
        
        if self.ScreenGui then
            self.ScreenGui:Destroy()
            self.ScreenGui = nil
        end
        
        if self.UI.ActiveNotifContainer == self.NotifContainer then
            self.UI.ActiveNotifContainer = nil
        end
        
        log("Window destroyed")
    end
    
    function Window:Unload()
        self:Destroy()
    end
    
    -- Welcome
    task.delay(0.5, function()
        self:Notify({
            Title = "ZERASER UI v" .. self.Version,
            Text = "by ry-zeen & renxx - Let's go!",
            Type = "success",
            Duration = 4,
        }, Window)
    end)
    
    log("Window created successfully")
    return Window
end

return ZeraserUI
