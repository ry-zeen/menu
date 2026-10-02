-- ========================================
-- RENXX UI v1.0 R2
-- By: RENXX
-- github.com/renxx-xiterz
-- ========================================

local RENXX = {}
RENXX.__index = RENXX
_G.RENXX = RENXX
RENXX.Flags = {}

RENXX.Config = {
    Name = "RENXX UI",
    Badge = "UI V1.0",
    Accent = Color3.fromRGB(59,130,246),
    Size = UDim2.new(0,340,0,480),
    Keybind = Enum.KeyCode.RightShift,
    ShowSplash = true,
    LogoAssetId = "101291766104464",
}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local T = {
    Bg = Color3.fromRGB(12,12,14), Panel = Color3.fromRGB(22,22,26),
    Card = Color3.fromRGB(30,30,36), Hover = Color3.fromRGB(40,40,48),
    Border = Color3.fromRGB(45,45,55), Text = Color3.fromRGB(240,240,245),
    Dim = Color3.fromRGB(150,150,160), Accent = RENXX.Config.Accent,
    Cyan = Color3.fromRGB(0,220,255), Pink = Color3.fromRGB(255,64,192),
}

local function getParent()
    if gethui then local ok,h=pcall(gethui) if ok and h then return h end end
    local ok,cg = pcall(function() return CoreGui end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end
local function protectGui(g)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(g) end end)
    pcall(function() if protect_gui then protect_gui(g) end end)
end
local function tween(o,t,p,s,d)
    if not o or not o.Parent then return end -- BUG #10 FIX: guard
    local tw = TweenService:Create(o,TweenInfo.new(t or 0.2, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out),p)
    tw:Play() return tw
end
local function corner(o,r)
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,r or 8) c.Parent = o return c
end
local function stroke(o,c,th,tr)
    local s = Instance.new("UIStroke") s.Color = c or T.Border s.Thickness = th or 1 s.Transparency = tr or 0 s.Parent = o return s
end
local function pad(o,t,r,b,l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0,t or 0) p.PaddingRight = UDim.new(0,r or 0)
    p.PaddingBottom = UDim.new(0,b or 0) p.PaddingLeft = UDim.new(0,l or 0)
    p.Parent = o return p
end
local function new(cl,pr)
    local o = Instance.new(cl)
    for k,v in pairs(pr or {}) do if k ~= "Parent" then o[k] = v end end
    if pr and pr.Parent then o.Parent = pr.Parent end
    return o
end

-- BUG #2 FIX: Track notif GUI
local NotifHolder
local NotifGui

function RENXX:CleanupNotifs()
    if NotifHolder then pcall(function() NotifHolder:ClearAllChildren() end) end
    if NotifGui then pcall(function() NotifGui:Destroy() end) end
    NotifHolder = nil
    NotifGui = nil
end

function RENXX:Splash()
    if not RENXX.Config.ShowSplash then return end
    local parent = getParent()
    local sg = new("ScreenGui",{Name="RXSplash"..math.random(1000,9999),ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=9999,Parent=parent})
    protectGui(sg)
    local bg = new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Parent=sg})
    
    local logo = new("ImageLabel",{Size=UDim2.new(0,80,0,80),Position=UDim2.new(0.5,-40,0.5,-50),BackgroundTransparency=1,Image="",ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,Parent=bg})
    
    -- BUG #1 FIX: pcall asset loading
    pcall(function()
        logo.Image = "rbxassetid://"..tostring(RENXX.Config.LogoAssetId)
    end)
    
    local fb = new("TextLabel",{Size=UDim2.new(0,150,0,60),Position=UDim2.new(0.5,-75,0.5,-30),BackgroundTransparency=1,Text="RX",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBlack,TextSize=50,TextTransparency=1,Visible=false,Parent=bg})
    
    -- BUG #1 FIX: Robust timeout fallback
    task.delay(1, function()
        if logo.Parent and (not logo.IsLoaded or logo.Image == "") then
            logo.Visible = false
            fb.Visible = true
        end
    end)
    
    local barBg = new("Frame",{Size=UDim2.new(0,160,0,3),Position=UDim2.new(0.5,-80,0.5,80),BackgroundColor3=T.Card,BorderSizePixel=0,BackgroundTransparency=1,Parent=bg})
    corner(barBg,2)
    local bf = new("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=barBg})
    corner(bf,2)
    new("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.Cyan),ColorSequenceKeypoint.new(0.5,T.Accent),ColorSequenceKeypoint.new(1,T.Pink)}),Parent=bf})
    tween(bg,0.3,{BackgroundTransparency=0})
    tween(logo,0.5,{Size=UDim2.new(0,180,0,180),Position=UDim2.new(0.5,-90,0.5,-100),ImageTransparency=0},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    tween(fb,0.5,{TextTransparency=0},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    task.wait(0.4) tween(barBg,0.2,{BackgroundTransparency=0}) task.wait(0.1)
    tween(bf,1.0,{Size=UDim2.new(1,0,1,0)})
    task.wait(1.3)
    if sg and sg.Parent then
        tween(bg,0.4,{BackgroundTransparency=1}) tween(logo,0.4,{ImageTransparency=1}) tween(fb,0.4,{TextTransparency=1}) tween(barBg,0.3,{BackgroundTransparency=1})
    end
    task.wait(0.5)
    if sg and sg.Parent then sg:Destroy() end
end

function RENXX:Notify(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "RENXX UI"
    local text = cfg.Text or ""
    local dur = cfg.Duration or 3
    if not NotifHolder or not NotifHolder.Parent then
        NotifGui = new("ScreenGui",{Name="RXNotify"..math.random(1000,9999),ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=1000,Parent=getParent()})
        protectGui(NotifGui)
        NotifHolder = new("Frame",{Size=UDim2.new(0,280,1,0),Position=UDim2.new(1,-300,0,40),BackgroundTransparency=1,Parent=NotifGui})
        new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=NotifHolder})
    end
    local n = new("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=T.Panel,BorderSizePixel=0,BackgroundTransparency=1,Position=UDim2.new(0,300,0,0),Parent=NotifHolder})
    corner(n,10)
    local ns = stroke(n,T.Accent,1,1)
    local bar = new("Frame",{Size=UDim2.new(0,4,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,BackgroundTransparency=1,Parent=n})
    corner(bar,2)
    new("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.Cyan),ColorSequenceKeypoint.new(1,T.Pink)}),Rotation=90,Parent=bar})
    local ic = new("TextLabel",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,12,0,10),BackgroundColor3=T.Accent,Text="✓",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=14,BorderSizePixel=0,BackgroundTransparency=1,Parent=n})
    corner(ic,14)
    local tl = new("TextLabel",{Size=UDim2.new(1,-55,0,18),Position=UDim2.new(0,48,0,8),BackgroundTransparency=1,Text=title,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1,Parent=n})
    local xl = new("TextLabel",{Size=UDim2.new(1,-55,0,26),Position=UDim2.new(0,48,0,26),BackgroundTransparency=1,Text=text,TextColor3=T.Dim,Font=Enum.Font.Gotham,TextSize=9,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextTransparency=1,Parent=n})
    tween(n,0.3,{Position=UDim2.new(0,0,0,0),BackgroundTransparency=0},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
    tween(ns,0.3,{Transparency=0.4}) tween(bar,0.3,{BackgroundTransparency=0}) tween(ic,0.3,{BackgroundTransparency=0}) tween(tl,0.3,{TextTransparency=0}) tween(xl,0.3,{TextTransparency=0})
    task.delay(dur,function()
        if not n or not n.Parent then return end
        tween(n,0.3,{Position=UDim2.new(0,300,0,0),BackgroundTransparency=1},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        tween(ns,0.3,{Transparency=1}) tween(bar,0.3,{BackgroundTransparency=1}) tween(ic,0.3,{BackgroundTransparency=1}) tween(tl,0.3,{TextTransparency=1}) tween(xl,0.3,{TextTransparency=1})
        task.wait(0.4)
        if n and n.Parent then n:Destroy() end
    end)
end

local Window = {}
Window.__index = Window
RENXX.Window = Window

function RENXX:CreateWindow(cfg)
    cfg = cfg or {}
    local config = {
        Name = cfg.Name or RENXX.Config.Name,
        Badge = cfg.Badge ~= nil and cfg.Badge or RENXX.Config.Badge,
        Accent = cfg.Accent or RENXX.Config.Accent,
        Size = cfg.Size or RENXX.Config.Size,
        Keybind = cfg.Keybind or RENXX.Config.Keybind,
        LogoAssetId = cfg.LogoAssetId or RENXX.Config.LogoAssetId,
    }
    T.Accent = config.Accent
    if RENXX.Config.ShowSplash then task.spawn(function() RENXX:Splash() end) end

    local parent = getParent()
    local gui = new("ScreenGui",{Name="RENXX_UI_"..math.random(1000,9999),ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999,Parent=parent})
    protectGui(gui)

    local floatBtn = new("TextButton",{Size=UDim2.new(0,46,0,46),Position=UDim2.new(1,-60,1,-60),BackgroundColor3=T.Accent,Text="RX",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBlack,TextSize=15,BorderSizePixel=0,AutoButtonColor=false,Visible=false,Draggable=true,Parent=gui})
    corner(floatBtn,23)
    stroke(floatBtn,T.Accent,2,0.5)

    local main = new("Frame",{Size=config.Size,Position=UDim2.new(0.5,-config.Size.X.Offset/2,0.5,-config.Size.Y.Offset/2),BackgroundColor3=T.Bg,BorderSizePixel=0,ClipsDescendants=true,Parent=gui})
    corner(main,12)
    stroke(main,T.Border,1,0.4)

    local hdr = new("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.Panel,BorderSizePixel=0,Parent=main})
    corner(hdr,12)
    new("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BackgroundColor3=T.Panel,BorderSizePixel=0,Parent=hdr})
    new("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=hdr})
    new("TextLabel",{Size=UDim2.new(0,120,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=config.Name,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=hdr})

    if config.Badge then
        local bdg = new("Frame",{Size=UDim2.new(0,44,0,16),Position=UDim2.new(0,140,0.5,-8),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=hdr})
        corner(bdg,4)
        new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=config.Badge,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=8,Parent=bdg})
    end

    local function wBtn(txt,xo,hc,cb)
        local b = new("TextButton",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,xo,0.5,-11),BackgroundColor3=T.Card,Text=txt,TextColor3=T.Dim,Font=Enum.Font.GothamBold,TextSize=11,BorderSizePixel=0,AutoButtonColor=false,Parent=hdr})
        corner(b,5)
        b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3=hc,TextColor3=Color3.new(1,1,1)}) end)
        b.MouseLeave:Connect(function() tween(b,0.15,{BackgroundColor3=T.Card,TextColor3=T.Dim}) end)
        b.MouseButton1Click:Connect(cb)
    end

    wBtn("─",-58,T.Accent,function()
        if main.Size.Y.Offset > 60 then
            tween(main,0.3,{Size=UDim2.new(0,main.Size.X.Offset,0,42)},Enum.EasingStyle.Back,Enum.EasingDirection.InOut)
        else
            tween(main,0.3,{Size=UDim2.new(0,main.Size.X.Offset,0,config.Size.Y.Offset)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        end
    end)

    wBtn("✕",-30,Color3.fromRGB(255,82,82),function()
        tween(main,0.25,{Size=UDim2.new(0,main.Size.X.Offset,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        task.wait(0.3)
        if main and main.Parent then
            main.Visible=false main.Size=config.Size floatBtn.Visible=true
        end
    end)

    floatBtn.MouseButton1Click:Connect(function()
        if not main or not main.Parent then return end
        main.Visible=true main.Size=UDim2.new(0,config.Size.X.Offset,0,0)
        tween(main,0.35,{Size=config.Size},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        floatBtn.Visible=false
    end)

    local dg,ds,sp
    hdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true ds=i.Position sp=main.Position end
    end)
    UIS.InputChanged:Connect(function(i)
        if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            if not main or not main.Parent then return end
            local d = i.Position-ds
            main.Position = UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    hdr.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end
    end)

    local sidebar = new("Frame",{Size=UDim2.new(0,100,1,-42),Position=UDim2.new(0,0,0,42),BackgroundColor3=T.Panel,BorderSizePixel=0,Parent=main})
    local sidebarScroll = new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=sidebar})
    new("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=sidebarScroll})
    pad(sidebarScroll,6,6,6,6)

    local content = new("Frame",{Size=UDim2.new(1,-100,1,-42),Position=UDim2.new(0,100,0,42),BackgroundColor3=T.Bg,BorderSizePixel=0,Parent=main})

    local searchF = new("Frame",{Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,8),BackgroundColor3=T.Panel,BorderSizePixel=0,Parent=content})
    corner(searchF,6)
    new("TextLabel",{Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Text="🔍",TextSize=10,Parent=searchF})
    local searchBox = new("TextBox",{Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,24,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Search...",PlaceholderColor3=T.Dim,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=searchF})

    local pageHolder = new("Frame",{Size=UDim2.new(1,-16,1,-44),Position=UDim2.new(0,8,0,40),BackgroundTransparency=1,Parent=content})

    local winObj = setmetatable({
        Gui=gui, Main=main, Header=hdr, Sidebar=sidebar, SidebarScroll=sidebarScroll,
        Content=content, PageHolder=pageHolder, Tabs={}, TabOrder={}, ActiveTab=nil,
        Config=config, FloatBtn=floatBtn, SearchBox=searchBox, _parent=parent,
    }, Window)

    -- BUG #9 FIX: Functional search
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        for _, tab in pairs(winObj.Tabs) do
            for _, comp in ipairs(tab.Components) do
                if comp._row then
                    if query == "" or (comp.Name and comp.Name:lower():find(query, 1, true)) then
                        comp._row.Visible = true
                    else
                        comp._row.Visible = false
                    end
                end
            end
        end
    end)

    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode == config.Keybind then
            if not main or not main.Parent then return end
            if main.Visible then
                tween(main,0.25,{Size=UDim2.new(0,config.Size.X.Offset,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
                task.wait(0.3)
                if main and main.Parent then
                    main.Visible=false main.Size=config.Size floatBtn.Visible=true
                end
            else
                main.Visible=true main.Size=UDim2.new(0,config.Size.X.Offset,0,0)
                tween(main,0.35,{Size=config.Size},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
                floatBtn.Visible=false
            end
        end
    end)

    return winObj
end

function Window:CreateTab(name, icon)
    icon = icon or ""
    name = tostring(name)
    if self.Tabs[name] then return self.Tabs[name] end

    local page = new("ScrollingFrame",{Name="Page_"..name,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=self.PageHolder})
    new("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,Parent=page})

    local btn = new("TextButton",{Name="TabBtn_"..name,Size=UDim2.new(1,0,0,28),BackgroundColor3=T.Panel,Text="",AutoButtonColor=false,BorderSizePixel=0,Parent=self.SidebarScroll})
    corner(btn,5)

    local btnLbl = new("TextLabel",{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text=(icon~="" and icon.." " or "")..name,TextColor3=T.Dim,Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=btn})

    local tabObj = {Name=name, Page=page, Button=btn, Label=btnLbl, Components={}, _window=self}

    btn.MouseButton1Click:Connect(function() self:SelectTab(name) end)
    btn.MouseEnter:Connect(function() if self.ActiveTab~=name then tween(btn,0.1,{BackgroundColor3=T.Hover}) end end)
    btn.MouseLeave:Connect(function() if self.ActiveTab~=name then tween(btn,0.1,{BackgroundColor3=T.Panel}) end end)

    self.Tabs[name] = tabObj
    table.insert(self.TabOrder, name)
    if not self.ActiveTab then self:SelectTab(name) end

    RENXX._attachTabMethods(tabObj)
    return tabObj
end

function Window:SelectTab(name)
    local tab = self.Tabs[name]
    if not tab then return end
    for n,t in pairs(self.Tabs) do
        t.Page.Visible = (n==name)
        local act = (n==name)
        tween(t.Button,0.15,{BackgroundColor3=act and T.Accent or T.Panel})
        tween(t.Label,0.15,{TextColor3=act and Color3.new(1,1,1) or T.Dim})
    end
    self.ActiveTab = name
end

-- BUG #7 + #8 FIX
function Window:RemoveTab(name)
    local tab = self.Tabs[name]
    if not tab then return end
    tab.Page:Destroy()
    tab.Button:Destroy()
    self.Tabs[name] = nil
    for i,n in ipairs(self.TabOrder) do
        if n==name then table.remove(self.TabOrder,i) break end
    end
    if self.ActiveTab==name then
        self.ActiveTab = nil
        local nextTab = self.TabOrder[1]
        if nextTab then self:SelectTab(nextTab) end
    end
    if self.SidebarScroll then
        self.SidebarScroll.CanvasPosition = Vector2.new(0,0)
    end
end

function Window:Destroy()
    RENXX:CleanupNotifs()
    if self.Gui then self.Gui:Destroy() end
end

RENXX._attachTabMethods = function(tab)
    local function makeRow(parent,height)
        local r = new("Frame",{Size=UDim2.new(1,0,0,height or 28),BackgroundColor3=T.Card,BorderSizePixel=0,Parent=parent})
        corner(r,6)
        return r
    end

    -- BUG #3 FIX: Canvas updater
    local function updateCanvas()
        task.defer(function()
            if tab.Page and tab.Page.Parent then
                local layout = tab.Page:FindFirstChildOfClass("UIListLayout")
                if layout then
                    tab.Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
                end
            end
        end)
    end

    function tab:CreateSection(title)
        local s = new("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Parent=self.Page})
        new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="▸ "..tostring(title),TextColor3=T.Dim,Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=s})
        return s
    end

    function tab:CreateLabel(text)
        local r = new("Frame",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Card,BorderSizePixel=0,Parent=self.Page})
        corner(r,6)
        new("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text=tostring(text),TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
        return r
    end

    function tab:CreateDivider()
        return new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Border,BorderSizePixel=0,Parent=self.Page})
    end

    function tab:CreateToggle(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Toggle"
        local state = cfg.Default or false
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local r = makeRow(self.Page, 28)
        new("TextLabel",{Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=name,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
        local sw = new("TextButton",{Size=UDim2.new(0,34,0,18),Position=UDim2.new(1,-42,0.5,-9),BackgroundColor3=state and T.Accent or T.Hover,Text="",AutoButtonColor=false,BorderSizePixel=0,Parent=r})
        corner(sw,9)
        local kn = new("Frame",{Size=UDim2.new(0,14,0,14),Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=sw})
        corner(kn,7)
        local obj = {Name=name,Type="Toggle",Flag=flag,_row=r}
        local function setState(v,call)
            state = v
            tween(sw,0.2,{BackgroundColor3=state and T.Accent or T.Hover})
            tween(kn,0.2,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            if flag then RENXX.Flags[flag]=state end
            if call then task.spawn(function() pcall(callback,state) end) end
        end
        sw.MouseButton1Click:Connect(function() setState(not state,true) end)
        obj.Set = function(v) setState(v,true) end
        obj.Get = function() return state end
        table.insert(self.Components,obj)
        return obj
    end

    function tab:CreateSlider(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Slider"
        local minV = cfg.Min or 0
        local maxV = cfg.Max or 100
        local default = cfg.Default or minV
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local suffix = cfg.Suffix or ""
        local decimals = cfg.Decimals or 0
        local c = new("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=T.Card,BorderSizePixel=0,Parent=self.Page})
        corner(c,6)
        new("TextLabel",{Size=UDim2.new(1,-55,0,14),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,Text=name,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=c})
        local vl = new("TextLabel",{Size=UDim2.new(0,50,0,14),Position=UDim2.new(1,-58,0,3),BackgroundTransparency=1,Text=tostring(default)..suffix,TextColor3=T.Accent,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,Parent=c})
        local bar = new("Frame",{Size=UDim2.new(1,-20,0,5),Position=UDim2.new(0,10,0,24),BackgroundColor3=T.Hover,BorderSizePixel=0,Parent=c})
        corner(bar,3)
        local rel = (default-minV)/(maxV-minV)
        local fl = new("Frame",{Size=UDim2.new(rel,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=bar})
        corner(fl,3)
        local kn = new("Frame",{Size=UDim2.new(0,11,0,11),Position=UDim2.new(rel,-5.5,0.5,-5.5),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=bar})
        corner(kn,6)
        local drag = false
        local currentVal = default
        local function up(i,call)
            if not bar or not bar.Parent then return end
            local r = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local v = minV+(maxV-minV)*r
            if decimals==0 then v = math.floor(v+0.5) else local m=10^decimals v=math.floor(v*m+0.5)/m end
            currentVal = v
            fl.Size = UDim2.new(r,0,1,0)
            kn.Position = UDim2.new(r,-5.5,0.5,-5.5)
            vl.Text = tostring(v)..suffix
            if flag then RENXX.Flags[flag]=v end
            if call then task.spawn(function() pcall(callback,v) end) end
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true up(i,true) end
        end)
        bar.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
        end)
        -- BUG #5 FIX: Better touch support
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then up(i,true) end
        end)
        bar.InputChanged:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch then up(i,true) end
        end)
        local obj = {Name=name,Type="Slider",Flag=flag,_row=c}
        obj.Set = function(v)
            local rr = math.clamp((v-minV)/(maxV-minV),0,1)
            currentVal=v fl.Size=UDim2.new(rr,0,1,0) kn.Position=UDim2.new(rr,-5.5,0.5,-5.5) vl.Text=tostring(v)..suffix
        end
        obj.Get = function() return currentVal end
        table.insert(self.Components,obj)
        return obj
    end

    function tab:CreateButton(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Button"
        local callback = cfg.Callback or function() end
        local b = new("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=T.Card,Text=name,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,BorderSizePixel=0,AutoButtonColor=false,Parent=self.Page})
        corner(b,6)
        b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3=T.Accent,TextColor3=Color3.new(1,1,1)}) end)
        b.MouseLeave:Connect(function() tween(b,0.15,{BackgroundColor3=T.Card,TextColor3=T.Text}) end)
        b.MouseButton1Click:Connect(function() task.spawn(function() pcall(callback) end) end)
        return {Name=name,Type="Button",_row=b}
    end

    function tab:CreateCheckbox(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Checkbox"
        local state = cfg.Default or false
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local r = makeRow(self.Page, 28)
        local bx = new("TextButton",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,10,0.5,-8),BackgroundColor3=state and T.Accent or T.Hover,Text=state and "✓" or "",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=10,BorderSizePixel=0,AutoButtonColor=false,Parent=r})
        corner(bx,4)
        new("TextLabel",{Size=UDim2.new(1,-36,1,0),Position=UDim2.new(0,34,0,0),BackgroundTransparency=1,Text=name,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
        local function setState(v,call)
            state = v
            tween(bx,0.15,{BackgroundColor3=state and T.Accent or T.Hover})
            bx.Text = state and "✓" or ""
            if flag then RENXX.Flags[flag]=state end
            if call then task.spawn(function() pcall(callback,state) end) end
        end
        bx.MouseButton1Click:Connect(function() setState(not state,true) end)
        local obj = {Name=name,Type="Checkbox",Flag=flag,_row=r}
        obj.Set = function(v) setState(v,true) end
        obj.Get = function() return state end
        table.insert(self.Components,obj)
        return obj
    end

    function tab:CreateInput(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Input"
        local placeholder = cfg.Placeholder or "Enter..."
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local c = new("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.Card,BorderSizePixel=0,Parent=self.Page})
        corner(c,6)
        new("TextLabel",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,Text=name,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=c})
        local tb = new("TextBox",{Size=UDim2.new(1,-20,0,18),Position=UDim2.new(0,10,0,20),BackgroundColor3=T.Bg,Text="",PlaceholderText=placeholder,PlaceholderColor3=T.Dim,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=9,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=c})
        corner(tb,4)
        pad(tb,0,0,0,6)
        tb.FocusLost:Connect(function(enter)
            if enter and tb.Text~="" then
                if flag then RENXX.Flags[flag]=tb.Text end
                task.spawn(function() pcall(callback,tb.Text) end)
            end
        end)
        local obj = {Name=name,Type="Input",Flag=flag,_row=c}
        obj.Set = function(v) tb.Text = tostring(v) end
        obj.Get = function() return tb.Text end
        table.insert(self.Components,obj)
        return obj
    end

    function tab:CreateDropdown(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Dropdown"
        local options = cfg.Options or {}
        local default = cfg.Default or (options[1] or "None")
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local c = new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.Card,BorderSizePixel=0,ClipsDescendants=true,Parent=self.Page})
        corner(c,6)
        new("TextLabel",{Size=UDim2.new(1,-85,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=name,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=c})
        local sel = new("TextButton",{Size=UDim2.new(0,75,0,20),Position=UDim2.new(1,-83,0.5,-10),BackgroundColor3=T.Bg,Text=tostring(default).." ▾",TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=9,BorderSizePixel=0,AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd,Parent=c})
        corner(sel,4)
        local list = new("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1,ClipsDescendants=true,Parent=c})
        new("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder,Parent=list})
        local isOpen = false
        local curVal = default
        for i,opt in ipairs(options) do
            local ob = new("TextButton",{Size=UDim2.new(1,-12,0,22),Position=UDim2.new(0,6,0,(i-1)*25+3),BackgroundColor3=T.Bg,Text=tostring(opt),TextColor3=opt==default and T.Accent or T.Text,Font=Enum.Font.Gotham,TextSize=9,BorderSizePixel=0,AutoButtonColor=false,Parent=list})
            corner(ob,4)
            ob.MouseEnter:Connect(function() tween(ob,0.1,{BackgroundColor3=T.Hover}) end)
            ob.MouseLeave:Connect(function() tween(ob,0.1,{BackgroundColor3=T.Bg}) end)
            ob.MouseButton1Click:Connect(function()
                curVal = opt
                sel.Text = tostring(opt).." ▾"
                isOpen = false
                tween(c,0.2,{Size=UDim2.new(1,0,0,28)})
                tween(list,0.2,{Size=UDim2.new(1,0,0,0)})
                for _,ch in ipairs(list:GetChildren()) do
                    if ch:IsA("TextButton") then ch.TextColor3 = ch.Text==tostring(opt) and T.Accent or T.Text end
                end
                if flag then RENXX.Flags[flag]=opt end
                task.spawn(function() pcall(callback,opt) end)
                updateCanvas()
            end)
        end
        sel.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                tween(c,0.2,{Size=UDim2.new(1,0,0,32+#options*25)})
                tween(list,0.2,{Size=UDim2.new(1,0,0,#options*25+6)})
                sel.Text = tostring(curVal).." ▴"
            else
                tween(c,0.2,{Size=UDim2.new(1,0,0,28)})
                tween(list,0.2,{Size=UDim2.new(1,0,0,0)})
                sel.Text = tostring(curVal).." ▾"
            end
            updateCanvas()
        end)
        local obj = {Name=name,Type="Dropdown",Flag=flag,_row=c}
        obj.Set = function(v) curVal=v sel.Text=tostring(v).." ▾" end
        obj.Get = function() return curVal end
        table.insert(self.Components,obj)
        return obj
    end

    -- BUG #4 FIX: Keybind unbind (right-click)
    function tab:CreateKeybind(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Keybind"
        local default = cfg.Default or "K"
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local r = makeRow(self.Page, 28)
        new("TextLabel",{Size=UDim2.new(1,-75,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=name,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
        local kb = new("TextButton",{Size=UDim2.new(0,60,0,20),Position=UDim2.new(1,-68,0.5,-10),BackgroundColor3=T.Bg,Text=tostring(default),TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=9,BorderSizePixel=0,AutoButtonColor=false,Parent=r})
        corner(kb,4)
        local listening = false
        local currentKey = default
        kb.MouseButton1Click:Connect(function() listening=true kb.Text="..." kb.TextColor3=T.Accent end)
        kb.MouseButton2Click:Connect(function()
            currentKey = "None"
            kb.Text = "None"
            kb.TextColor3 = T.Dim
            if flag then RENXX.Flags[flag]=nil end
        end)
        UIS.InputBegan:Connect(function(i,gp)
            if gp then return end
            if listening and i.UserInputType==Enum.UserInputType.Keyboard then
                currentKey = i.KeyCode.Name
                kb.Text = currentKey
                kb.TextColor3 = T.Text
                listening = false
                if flag then RENXX.Flags[flag]=currentKey end
                task.spawn(function() pcall(callback,currentKey) end)
            elseif not listening and i.UserInputType==Enum.UserInputType.Keyboard then
                if i.KeyCode.Name==currentKey then task.spawn(function() pcall(callback,currentKey,true) end) end
            end
        end)
        local obj = {Name=name,Type="Keybind",Flag=flag,_row=r}
        obj.Set = function(v) currentKey=v kb.Text=v end
        obj.Get = function() return currentKey end
        table.insert(self.Components,obj)
        return obj
    end

    -- BUG #6 FIX: ColorPicker auto-scroll
    function tab:CreateColorPicker(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Color"
        local default = cfg.Default or Color3.fromRGB(255,82,82)
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local c = new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.Card,BorderSizePixel=0,ClipsDescendants=true,Parent=self.Page})
        corner(c,6)
        new("TextLabel",{Size=UDim2.new(1,-55,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=name,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=c})
        local sw = new("TextButton",{Size=UDim2.new(0,40,0,18),Position=UDim2.new(1,-48,0.5,-9),BackgroundColor3=default,Text="",BorderSizePixel=0,AutoButtonColor=false,Parent=c})
        corner(sw,4)
        stroke(sw,T.Border,1)
        local palette = {
            Color3.fromRGB(59,130,246),Color3.fromRGB(0,210,106),Color3.fromRGB(255,82,82),
            Color3.fromRGB(123,104,238),Color3.fromRGB(255,184,0),Color3.fromRGB(255,64,192),
            Color3.fromRGB(0,220,255),Color3.fromRGB(255,255,255),Color3.fromRGB(150,150,160),
            Color3.fromRGB(233,30,99),Color3.fromRGB(76,175,80),Color3.fromRGB(0,188,212),
            Color3.fromRGB(156,39,176),Color3.fromRGB(121,85,72),Color3.fromRGB(33,33,33),
            Color3.fromRGB(0,0,0),
        }
        local grid = new("Frame",{Size=UDim2.new(1,-12,0,0),Position=UDim2.new(0,6,0,32),BackgroundTransparency=1,Parent=c})
        new("UIGridLayout",{CellSize=UDim2.new(0,26,0,26),CellPadding=UDim2.new(0,4,0,4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=grid})
        local open = false
        local curColor = default
        for _,color in ipairs(palette) do
            local cb = new("TextButton",{BackgroundColor3=color,Text="",BorderSizePixel=0,AutoButtonColor=false,Parent=grid})
            corner(cb,4)
            cb.MouseButton1Click:Connect(function()
                curColor = color
                sw.BackgroundColor3 = color
                open = false
                tween(c,0.2,{Size=UDim2.new(1,0,0,28)})
                if flag then RENXX.Flags[flag]=color end
                task.spawn(function() pcall(callback,color) end)
                updateCanvas()
            end)
        end
        sw.MouseButton1Click:Connect(function()
            open = not open
            if open then
                tween(c,0.2,{Size=UDim2.new(1,0,0,32+4*30)})
                task.defer(function()
                    if tab.Page and tab.Page.Parent then
                        local targetY = c.AbsolutePosition.Y - tab.Page.AbsolutePosition.Y - 100
                        tab.Page.CanvasPosition = Vector2.new(0, math.max(0, targetY))
                    end
                end)
            else
                tween(c,0.2,{Size=UDim2.new(1,0,0,28)})
            end
            updateCanvas()
        end)
        local obj = {Name=name,Type="ColorPicker",Flag=flag,_row=c}
        obj.Set = function(v) curColor=v sw.BackgroundColor3=v end
        obj.Get = function() return curColor end
        table.insert(self.Components,obj)
        return obj
    end

    function tab:CreateParagraph(cfg)
        cfg = cfg or {}
        local title = cfg.Title or "Info"
        local content = cfg.Content or ""
        local c = new("Frame",{Size=UDim2.new(1,0,0,60),BackgroundColor3=T.Card,BorderSizePixel=0,Parent=self.Page})
        corner(c,6)
        new("TextLabel",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text=title,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=c})
        new("TextLabel",{Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,Text=content,TextColor3=T.Dim,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,Parent=c})
        return c
    end
end

function RENXX:SaveConfig(name)
    name = name or "renxx_config.json"
    if not writefile then warn("[RENXX] writefile not supported") return false end
    local data = {}
    for k,v in pairs(RENXX.Flags) do
        if typeof(v)=="Color3" then data[k]={_type="Color3",r=v.R,g=v.G,b=v.B}
        else data[k]=v end
    end
    local HttpService = game:GetService("HttpService")
    local ok,enc = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then pcall(writefile,name,enc) return true end
    return false
end

function RENXX:LoadConfig(name)
    name = name or "renxx_config.json"
    if not (isfile and readfile) then return false end
    if not isfile(name) then return false end
    local HttpService = game:GetService("HttpService")
    local ok,content = pcall(readfile,name)
    if not ok then return false end
    local ok2,data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 then return false end
    for k,v in pairs(data) do
        if type(v)=="table" and v._type=="Color3" then RENXX.Flags[k]=Color3.new(v.r,v.g,v.b)
        else RENXX.Flags[k]=v end
    end
    return true
end

function RENXX:GetFlag(flag) return RENXX.Flags[flag] end
function RENXX:SetFlag(flag,v) RENXX.Flags[flag]=v end

print("[RENXX UI v1.0 R2] Library loaded!")
