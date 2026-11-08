local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

-- Roblox's own interface (top bar, menu button, settings, chat...) already lives in CoreGui at this point.
-- "All Font" uses this snapshot to leave it alone.
local CoreGuiBaseline = {}
pcall(function()
    for _, Child in CoreGui:GetChildren() do
        CoreGuiBaseline[Child] = true
    end
end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,

    Window = nil,
    WindowContainer = nil,

    --// Search \\--
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    PreviousTab = nil,
    Tabs = {},
    TabButtons = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},
    KeybindMenu = nil,

    --// Notifications \\--
    Notifications = {},
    NotifySide = "Right",
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Context Menu \\--
    ContextMenus = {}, 

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = true,
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Pop Out \\--
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 16,

    --// Liquid Glass \\--
    SmoothDrag = true,       -- windows / draggable UI glide to the cursor instead of snapping
    SmoothDragSpeed = 11,    -- lower = floatier & later to catch up, higher = tighter
    RimSpinSpeed = 100,      -- degrees per second the shining border travels on draggable buttons/labels

    GlassBlur = true,      -- blur the 3D world behind the window (set before CreateWindow)
    GlassBlurSize = 18,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(12, 16, 30),   -- panels / group boxes: deep smoky glass
        MainColor = Color3.fromRGB(62, 70, 104),        -- buttons, toggles, inputs: lighter slate glass
        AccentColor = Color3.fromRGB(200, 80, 255),     -- ON / selected / sliders: vivid violet-magenta
        OutlineColor = Color3.fromRGB(255, 255, 255),   -- rim light
        FontColor = Color3.fromRGB(245, 246, 255),
        Font = Font.fromEnum(Enum.Font.GothamMedium),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
    Scales = {},
    ScalesOffset = {},

    --// Mouse \\--
    OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
    ShowCursorBinding = string.sub(tostring({}), 10),

    --// Image Manager \\--
    ImageManager = CustomImageManager,
    MaxSpriteIconSize = 24,

    --// Misc \\--
    Notify = nil, Toggle = nil -- we love luau lsp
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600),
        IconSize = UDim2.fromOffset(30, 30),

        AutoShow = true,
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,

        --// Window Snapping \\--
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,

        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,

        CornerRadius = 20,
        NotifySide = "Right",
        ShowCustomCursor = true,

        Font = Enum.Font.GothamMedium,
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animated content background (GIF as sprite sheet) \\--
        -- ContentBackground = {
        --     Image = "rbxassetid://123" or "folder/sheet.png" (executor workspace file),
        --     Columns = 4, Rows = 4,          -- grid of the sprite sheet
        --     Frames = 16,                    -- how many frames are used (<= Columns * Rows)
        --     FrameSize = Vector2.new(256, 256), -- pixel size of ONE frame in the sheet
        --     FPS = 12,
        --     Transparency = 0.3,             -- 0 = fully visible, 1 = invisible
        -- }
        -- Default: built-in rotating light (kaitenhikari.png). Set ContentBackground = { Enabled = false } to turn off.
        -- Extra keys: Rotate = true, RotationSpeed = 20 (deg/sec), Scale = 1.1
        -- Url = "https://.../bg.mp4"  -> downloaded at startup. Supported: mp4 / webm (real animation, looped),
        --                                png / jpg (static, or sprite sheet with Columns/Rows/Frames/FrameSize/FPS).
        --                                GIF can't be played by Roblox -> convert it to mp4/webm first.
        --                                If the download/format fails, the built-in rotating light stays.
        -- VideoDim = 0.45 (0 = no dimming .. 1 = fully dark overlay on top of a video, keeps text readable)
        ContentBackground = { Enabled = true },

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false,
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom",
        TabButtonsStyle = {
            Gap = 0,
            Padding = 0,
            CornerRadius = 0,
            Indicator = false,
            IndicatorWidth = 2,
            IndicatorHeight = 20,
        },
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        MaxHeight = nil,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        MaxHeight = nil,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Settings = {
        Width = nil,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,
        KeepDisabledValuePosition = false,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Resizable = true,

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

local function GetTextStrokeColor(): Color3
    local Color = Library.Scheme.FontColor
    return (Color.R * 0.299 + Color.G * 0.587 + Color.B * 0.114) > 0.5 and Library.Scheme.DarkColor or Library.Scheme.WhiteColor
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function IsSequentialArray(Table: { [any]: any })
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end

    return true
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

--// Fuzzy Search \\--
local function LowerText(Text: string): string
    return (Text:lower():gsub("[\195\206\208][\128-\191]", function(Char)
        local Code = utf8.codepoint(Char)
        if (Code >= 0xC0 and Code <= 0xDE and Code ~= 0xD7) or (Code >= 0x391 and Code <= 0x3AB) or (Code >= 0x410 and Code <= 0x42F) then
            return utf8.char(Code + 32)
        elseif Code >= 0x400 and Code <= 0x40F then
            return utf8.char(Code + 80)
        end

        return Char
    end))
end

local function FuzzyScore(Text: string, Search: string): (boolean, number)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    --// Fast path: literal substring match (also the best possible score) \\--
    local ExactIdx = Text:find(Search, 1, true)
    if ExactIdx then
        local PrevChar = ExactIdx > 1 and Text:sub(ExactIdx - 1, ExactIdx - 1) or ""
        local AtBoundary = ExactIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

        return true, 1e5 - ExactIdx + (AtBoundary and 500 or 0) + (Search:len() * 5)
    end

    --// Fallback: fuzzy, in-order, non-consecutive character matching \\--
    local TextChars, SearchChars = {}, {}
    for Char in Text:gmatch(utf8.charpattern) do table.insert(TextChars, Char) end
    for Char in Search:gmatch(utf8.charpattern) do table.insert(SearchChars, Char) end

    local TextLen, SearchLen = #TextChars, #SearchChars
    if SearchLen > TextLen then
        return false, 0
    end

    local SearchIdx = 1
    local Score = 0
    local RunLength = 0
    local LastMatchIdx = 0

    for TextIdx = 1, TextLen do
        if SearchIdx > SearchLen then
            break
        end

        if TextChars[TextIdx] == SearchChars[SearchIdx] then
            local PrevChar = TextIdx > 1 and TextChars[TextIdx - 1] or ""
            local AtBoundary = TextIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

            RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
            Score += 1 + (AtBoundary and 6 or 0) + math.min(RunLength - 1, 5) * 3

            LastMatchIdx = TextIdx
            SearchIdx += 1
        end
    end

    if SearchIdx <= SearchLen then
        return false, 0 --// Not every Search character was found, in order
    end

    Score -= (LastMatchIdx - SearchLen) * 0.05 --// Slightly favour tighter matches
    return true, Score
end

local function NormalizeSearch(Search: string): string
    return (Search:gsub("%s+", ""))
end

local function TryFuzzyMatch(Text: any, Search: string): (boolean, number)
    if typeof(Text) ~= "string" or Text == "" then
        return false, 0
    end

    return FuzzyScore(LowerText(Text), Search)
end

local function FuzzyMatchScore(Text: any, Search: string): number
    if typeof(Text) ~= "string" or Text == "" then
        return 0
    end

    local Normalized = NormalizeSearch(LowerText(Text))
    local Matched, Score = FuzzyScore(Normalized, Search)
    if not Matched then
        return 0
    end

    if Normalized == Search then
        Score += 1000
    end

    return Score
end

local function MatchesSearch(ElementInfo, Search: string, ForceMatch: boolean?): boolean
    if not ElementInfo then
        return false
    end
    if ForceMatch then
        return true
    end

    if TryFuzzyMatch(ElementInfo.Text, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Tooltip, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.DisabledTooltip, Search) then
        return true
    end

    --// Optional: search inside Dropdown value lists, so e.g. searching a specific option name reveals the Dropdown that contains it \\--
    if typeof(ElementInfo.Values) == "table" then
        local Checked = 0
        for Key, Value in ElementInfo.Values do
            Checked += 1
            if Checked > 200 then
                break
            end

            if TryFuzzyMatch(Value, Search) or (typeof(Value) ~= "string" and TryFuzzyMatch(tostring(Value), Search)) then
                return true
            end
            if typeof(Key) == "string" and TryFuzzyMatch(Key, Search) then
                return true
            end
        end
    end

    return false
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

function Library:UpdateAddons(Parent)
    if not Parent or not Parent.Addons then
        return
    end

    for _, Addon in Parent.Addons do
        Addon:Update()
    end
end

local function CheckDepbox(Box, Search, ForceVisible: boolean?)
    local VisibleElements = 0
    local BestScore = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Base.Visible = false
            end
            if MatchesSearch(ElementInfo.SubButton, Search, ForceVisible) and ElementInfo.SubButton.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
            BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        local DepVisible, DepScore = CheckDepbox(Depbox, Search, ForceVisible)
        VisibleElements += DepVisible
        if DepScore > BestScore then
            BestScore = DepScore
        end
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements, BestScore
end
local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        RestoreDepbox(Depbox)
    end

    Box.Holder.Visible = Box.Visible
    if Box.Visible then
        Box:Resize()
    end
end

--// Pop Out
function SyncPopOutVisibility(Box: any)
    if not Box.PopOutFloat then
        return
    end

    Box.PopOutFloat.Visible = Box.BoxHolder.Visible ~= false and Box.Visible ~= false
end

local function RegisterPopOutClone(Source: Instance, Clone: Instance)
    local SourceProps = Library.Registry[Source]
    if SourceProps then
        local CloneProps = {}
        for Property, Index in SourceProps do
            if Property ~= "FontFace" then
                CloneProps[Property] = Index
            end
        end
        if next(CloneProps) then
            Library.Registry[Clone] = CloneProps
        end
    end

    local SourceChildren = Source:GetChildren()
    local CloneChildren = Clone:GetChildren()
    for Index = 1, math.min(#SourceChildren, #CloneChildren) do
        RegisterPopOutClone(SourceChildren[Index], CloneChildren[Index])
    end
end

local function DimPopOutClone(Root: GuiObject)
    for _, Descendant in Root:QueryDescendants("TextLabel, TextButton, TextBox") do
        Descendant.TextTransparency = math.max(Descendant.TextTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("ImageLabel, ImageButton") do
        Descendant.ImageTransparency = math.max(Descendant.ImageTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("GuiButton") do
        Descendant.Active = false
        Descendant.AutoButtonColor = false
    end
end

local function IsScreenPointOutsideMain(Point: Vector2): boolean
    local MainFrame = Library.Window and Library.Window.MainFrame
    if not MainFrame or not Library.Toggled or not MainFrame.Visible then
        return true
    end

    return not Library:MouseIsOverFrame(MainFrame, Point)
end

local function GetTopFloatAt(Point: Vector2): GuiObject?
    local Best: GuiObject? = nil
    local BestOrder = -math.huge
    local Floats = Library.Floats

    for _, Surface in Library.DraggableElements do
        if not Surface or not Surface.Parent or not Surface.Visible then
            continue
        end
        if Floats and Surface.Parent ~= Floats then
            continue
        end
        if not Library:MouseIsOverFrame(Surface, Point) then
            continue
        end

        local SiblingIndex = tonumber(select(2, pcall(function() return Surface:GetSiblingIndex() end))) or 0
        local Order = Surface.ZIndex * 100000 + SiblingIndex
        if Order >= BestOrder then
            BestOrder = Order
            Best = Surface
        end
    end

    return Best
end

local function GetPopOutBodyMaxHeight(Box: any, Reserved: number): number
    local Float = Box.PopOutFloat
    local ScreenGui = Library.ScreenGui
    if not Float or not ScreenGui then
        return math.huge
    end

    local Gap = 12 * Library.DPIScale
    local MaxBottom = ScreenGui.AbsolutePosition.Y + ScreenGui.AbsoluteSize.Y - Gap
    local Available = math.min(MaxBottom - Float.AbsolutePosition.Y, ScreenGui.AbsoluteSize.Y * 0.9)
    local ScreenMax = math.max(0, Available / Library.DPIScale - Reserved)

    local CustomMax = Box.PopOutMaxHeight
    if typeof(CustomMax) == "number" then
        return math.min(ScreenMax, math.max(0, CustomMax))
    end

    return ScreenMax
end

--// Search
local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return false, 0
    end

    local HasVisible = false
    local BestScore = 0

    --// If the Tab itself matches Search (by name/description), don't filter out its contents -- pull everything in the Tab along with it \\--
    local TabMatches = TryFuzzyMatch(Tab.Name, Search) or TryFuzzyMatch(Tab.Description, Search)
    BestScore = math.max(BestScore, FuzzyMatchScore(Tab.Name, Search), FuzzyMatchScore(Tab.Description, Search))

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        --// Optional: matching the Groupbox's own name/description reveals every element inside it, without needing each one to match too
        local GroupboxMatches = TabMatches or (TryFuzzyMatch(Groupbox.Name, Search) or TryFuzzyMatch(Groupbox.Description, Search))
        BestScore = math.max(BestScore, FuzzyMatchScore(Groupbox.Name, Search), FuzzyMatchScore(Groupbox.Description, Search))

        local VisibleElements = 0
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                --// Check if any of the Buttons Name matches with Search
                local Visible = false
                if MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
                else
                    ElementInfo.Base.Visible = false
                end

                if MatchesSearch(ElementInfo.SubButton, Search, GroupboxMatches) and ElementInfo.SubButton.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
                else
                    ElementInfo.SubButton.Base.Visible = false
                end

                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text and MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            local DepVisible, DepScore = CheckDepbox(Depbox, Search, GroupboxMatches)
            VisibleElements += DepVisible
            if DepScore > BestScore then
                BestScore = DepScore
            end
        end

        --// Update Groupbox Size and Visibility if found any element
        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}
        local SubTabScores = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            --// Optional: matching a Tabbox sub-tab's own name reveals every element inside it, without needing each one to match too
            local SubTabMatches = TabMatches or TryFuzzyMatch(SubTab.Name, Search)
            local SubScore = FuzzyMatchScore(SubTab.Name, Search)
            BestScore = math.max(BestScore, SubScore)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    --// Check if any of the Buttons Name matches with Search
                    local Visible = false
                    if MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.Base.Visible = false
                    end

                    if MatchesSearch(ElementInfo.SubButton, Search, SubTabMatches) and ElementInfo.SubButton.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.SubButton.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end

                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text and MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                    local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                    SubScore = math.max(SubScore, ElementScore)
                    BestScore = math.max(BestScore, ElementScore)
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                local DepVisible, DepScore = CheckDepbox(Depbox, Search, SubTabMatches)
                VisibleElements[SubTab] += DepVisible
                SubScore = math.max(SubScore, DepScore)
                BestScore = math.max(BestScore, DepScore)
            end

            SubTabScores[SubTab] = SubScore
        end

        local BestSubTab = nil
        local BestSubScore = -1

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                local SubScore = SubTabScores[SubTab] or 0
                if SubScore > BestSubScore then
                    BestSubScore = SubScore
                    BestSubTab = SubTab
                end
            end
        end

        local ActiveSubTab = Tabbox.ActiveTab
        local ActiveSubVisible = ActiveSubTab and (VisibleElements[ActiveSubTab] or 0) > 0
        local ActiveSubScore = ActiveSubTab and (SubTabScores[ActiveSubTab] or -1) or -1

        if ActiveSubVisible and ActiveSubScore >= BestSubScore then
            ActiveSubTab:Resize()
        elseif BestSubTab then
            BestSubTab:Show()
        end

        --// Update Tabbox Visibility if any visible
        Tabbox.BoxHolder.Visible = VisibleTabs > 0
        SyncPopOutVisibility(Tabbox)
    end

    return HasVisible, BestScore
end

local function ResetTab(Tab)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            RestoreDepbox(Depbox)
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
        SyncPopOutVisibility(Tabbox)
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText

    local TabsToSearch = {}
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and not Tab.IsKeyTab and not Tab.IsCustomTab then
            table.insert(TabsToSearch, Tab)
        end
    end

    for _, Tab in TabsToSearch do
        ResetTab(Tab)
    end

    local Search = NormalizeSearch(LowerText(SearchText))
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local BestTab = nil
    local BestScore = -1
    local ActiveScore = -1
    local ActiveHasVisible = false

    for _, Tab in TabsToSearch do
        local HasVisible, Score = ApplySearchToTab(Tab, Search)
        if not HasVisible then
            continue
        end

        if Tab == Library.ActiveTab then
            ActiveHasVisible = true
            ActiveScore = Score
        end
        if Score > BestScore then
            BestScore = Score
            BestTab = Tab
        end
    end

    if not Library.GlobalSearch then
        for _, Tab in TabsToSearch do
            if Tab ~= BestTab then
                ResetTab(Tab)
            end
        end
    end

    local StayOnActive = ActiveHasVisible and ActiveScore >= BestScore
    if StayOnActive and Library.ActiveTab then
        Library.ActiveTab:RefreshSides()
    elseif BestTab then
        local SearchMarker = SearchText
        task.defer(function()
            if Library.SearchText ~= SearchMarker then
                return
            end

            if Library.ActiveTab ~= BestTab then
                BestTab:Show()
            elseif Library.ActiveTab then
                Library.ActiveTab:RefreshSides()
            end
        end)
    end

    Library.LastSearchTab = nil
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale: number)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
            Option:RefreshPool()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon: string, IncludeAssetId: boolean)
    return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
    FontFace: Font?,
    Text: string?,
    Custom: boolean?,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons = false
local Icons: IconModule | nil = nil

function Library:GetIcon(IconName: string): Icon?
    if not FetchIcons or not Icons then
        return nil
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    return if Success then Icon else nil
end

function Library:GetCustomIcon(IconName: string): any
    if not IconName then
        return nil
    end

    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    if IsCustomAssetIcon(IconName, true) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif IsValidCustomIcon(IconName) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    return nil
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

--// Icon Instances \\--
local IconTextProperties = { ImageColor3 = "TextColor3", ImageTransparency = "TextTransparency" }
local IconSharedProperties = { "Name", "AnchorPoint", "Position", "Size", "SizeConstraint", "LayoutOrder", "ZIndex", "Visible", "Rotation", "ImageColor3", "ImageTransparency" }

local function IconProperties(ClassName: string, Properties: { [string]: any }): { [string]: any }
    if ClassName ~= "TextLabel" and ClassName ~= "TextButton" then
        return Properties
    end

    local Mapped: { [string]: any } = {}
    for Property, Value in Properties do
        Mapped[IconTextProperties[Property] or Property] = Value
    end

    return Mapped
end

local function IsFontIcon(Icon: Icon?, Size: UDim2?, Parent: Instance?): boolean
    if Icon == nil or Icon.FontFace == nil or Size == nil then
        return false
    end

    local Height = Size.Y.Offset
    if Size.Y.Scale ~= 0 then
        if not (Parent and Parent:IsA("GuiObject")) then
            return false
        end

        Height += Parent.AbsoluteSize.Y / Library.DPIScale * Size.Y.Scale
    end

    return Height > Library.MaxSpriteIconSize
end

local function ImageContent(Icon: Icon?): { [string]: any }
    return {
        Image = Icon and Icon.Url or "",
        ImageRectOffset = Icon and Icon.ImageRectOffset or Vector2.zero,
        ImageRectSize = Icon and Icon.ImageRectSize or Vector2.zero,
    }
end

local function SetIconProperties(Target: GuiObject, Properties: { [string]: any })
    FillInstance(IconProperties(Target.ClassName, Properties), Target)
end

local function TweenIcon(Target: GuiObject, Properties: { [string]: any }): Tween
    local Tween = TweenService:Create(Target, Library.TweenInfo, IconProperties(Target.ClassName, Properties))
    Tween:Play()

    return Tween
end

function Library:CreateIcon(Icon: Icon?, Properties: { [string]: any }?, IsButton: boolean?): GuiObject
    local IsFont = IsFontIcon(Icon, Properties and Properties.Size, Properties and Properties.Parent)
    local ClassName = (if IsFont then "Text" else "Image") .. (if IsButton then "Button" else "Label")

    local Merged: { [string]: any } = {
        BackgroundTransparency = 1,
        ImageColor3 = Color3.new(1, 1, 1),
    }

    if not IsFont then
        Merged.ScaleType = Enum.ScaleType.Fit
    end

    if Properties then
        for Property, Value in Properties do
            Merged[Property] = Value
        end
    end

    return Library:ApplyIcon(New(ClassName, IconProperties(ClassName, Merged)), Icon)
end

function Library:ApplyIcon(Target: GuiObject, Icon: Icon?): GuiObject
    local IsFont = IsFontIcon(Icon, Target.Size, Target.Parent)
    local IsText = Target:IsA("TextLabel") or Target:IsA("TextButton")

    if IsFont ~= IsText then
        local Theme = Library.Registry[Target] or {}
        local Properties: { [string]: any } = { Parent = Target.Parent }

        for _, Property in IconSharedProperties do
            local Source = if IsText then IconTextProperties[Property] or Property else Property
            Properties[Property] = if Theme[Source] ~= nil then Theme[Source] else (Target :: any)[Source]
        end

        local Replacement = Library:CreateIcon(Icon, Properties, Target:IsA("GuiButton"))
        Library:RemoveFromRegistry(Target)
        Target:Destroy()

        return Replacement
    end

    if IsFont and Icon then
        FillInstance({
            FontFace = Icon.FontFace,
            RichText = false,
            Text = Icon.Text,
            TextScaled = true,
        }, Target)

        if not Target:FindFirstChild("IconPadding") then
            New("UIPadding", {
                Name = "IconPadding",
                PaddingLeft = UDim.new(-0.5, 0),
                PaddingRight = UDim.new(-0.5, 0),
                Parent = Target,
            })
        end
    else
        FillInstance(ImageContent(Icon), Target)
    end

    return Target
end

--// DEPRECATED
function Library:ApplyLucideIcon(ImageGui: ImageLabel | ImageButton, Icon: Icon, Rotation: number?)
    warn("Obsidian:ApplyLucideIcon is deprecated, please use Obsidian:CreateIcon or Obsidian:ApplyIcon instead.")

    ImageGui.Rotation = Rotation or ImageGui.Rotation
    FillInstance(ImageContent(Icon), ImageGui)
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(Gui: ScreenGui, Enabled: boolean)
    if not Gui then
        return
    end

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Gui, "OnTopOfCoreBlur", Enabled)
        elseif setscriptable then
            setscriptable(Gui, "OnTopOfCoreBlur", true)
            Gui.OnTopOfCoreBlur = Enabled
            setscriptable(Gui, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "Obsidian",
    DisplayOrder = 998,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    task.defer(function()
        if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
            return
        end

        Library:RemoveFromRegistry(Instance)
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Floats and Overlays
local Floats = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 10,
    Active = false,
    Parent = ScreenGui,
})

local Overlay = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
    Active = false,
    Parent = ScreenGui,
})

Library.Floats = Floats
Library.Overlay = Overlay

--// Cursor
local Cursor
local CursorCross
local InnerCross = {}
local CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(1, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })

    CursorCross = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        Parent = Cursor,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -2, 0, 1),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 1, 1, -2),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    CursorCustomImage = Library:CreateIcon(nil, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 3,
        Visible = false,
        Parent = Cursor,
    })
end

local function RestoreMouseIcon()
    pcall(function() 
        RunService:UnbindFromRenderStep(Library.ShowCursorBinding)
        RunService.RenderStepped:Wait()
    end)

    UserInputService.MouseIconEnabled = Library.OriginalMouseIconEnabled
    if Cursor then Cursor.Visible = false end
end

--// Notification \\--
local NotificationArea
local NotifyOrder = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 200,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

--// Icons \\--
local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon, CloseIcon, SettingsIcon
function Library:SetIconModule(module: IconModule)
    FetchIcons = true
    Icons = module

    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
    PopOutIcon = Library:GetIcon("square-arrow-down-left")
    CloseIcon = Library:GetIcon("x")
    SettingsIcon = Library:GetIcon("settings")
end

local OnlineFetchIcons, OnlineIcons = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/notpoiu/Molto/refs/heads/main/source.lua")
    ) :: () -> IconModule)()
end)
do
    if OnlineFetchIcons and OnlineIcons then
        OnlineIcons.SetProvider("lucide")
        Library:SetIconModule(OnlineIcons)
    else
        OnlineFetchIcons, OnlineIcons = pcall(function()
            return (loadstring(
                game:HttpGet("https://raw.githubusercontent.com/notpoiu/lucide-roblox-direct/refs/heads/main/source.lua")
            ) :: () -> IconModule)()
        end)
        
        if OnlineFetchIcons and OnlineIcons then
            Library:SetIconModule(OnlineIcons)
        end
    end
end

--// Lib Functions \\--
Library.Cursor = {}

function Library.Cursor:ResetCross()
    for _, Inner in InnerCross do
        Library.Registry[Inner].BackgroundColor3 = "WhiteColor"
        Inner.BackgroundColor3 = Library.Scheme.WhiteColor
    end
end

function Library.Cursor:ResetIcon()
    CursorCross.Visible = true
    CursorCustomImage.Visible = false
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
    SetIconProperties(CursorCustomImage, { ImageColor3 = Color3.new(1, 1, 1) })
end

function Library.Cursor:ResetCursor()
    Library.Cursor:ResetCross()
    Library.Cursor:ResetIcon()
end

function Library.Cursor:ChangeCrossColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    for _, Inner in InnerCross do
        Inner.BackgroundColor3 = Color
        Library.Registry[Inner].BackgroundColor3 = nil
    end
end

function Library.Cursor:ChangeIcon(ImageId: string)
    if not ImageId or ImageId == "" then
        Library.Cursor:ResetIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCross.Visible = false
    CursorCustomImage = Library:ApplyIcon(CursorCustomImage, Icon)
    CursorCustomImage.Visible = true
end

function Library.Cursor:ChangeIconColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    SetIconProperties(CursorCustomImage, { ImageColor3 = Color })
end

function Library.Cursor:ChangeIconSize(Size: UDim2)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

--// DEPRECATED
function Library:ChangeCursorCrossColor(Color: Color3)
    warn("Obsidian:ChangeCursorCrossColor is deprecated, please use Obsidian.Cursor:ChangeCrossColor instead.")
    Library.Cursor:ChangeCrossColor(Color)
end

--// DEPRECATED
function Library:ResetCursorCross()
    warn("Obsidian:ResetCursorCross is deprecated, please use Obsidian.Cursor:ResetCross instead.")
    Library.Cursor:ResetCross()
end

--// DEPRECATED
function Library:ChangeCursorIcon(ImageId: string)
    warn("Obsidian:ChangeCursorIcon is deprecated, please use Obsidian.Cursor:ChangeIcon instead.")
    Library.Cursor:ChangeIcon(ImageId)
end

--// DEPRECATED
function Library:ChangeCursorIconColor(Color: Color3)
    warn("Obsidian:ChangeCursorIconColor is deprecated, please use Obsidian.Cursor:ChangeIconColor instead.")
    Library.Cursor:ChangeIconColor(Color)
end

--// DEPRECATED
function Library:ChangeCursorIconSize(Size: UDim2)
    warn("Obsidian:ChangeCursorIconSize is deprecated, please use Obsidian.Cursor:ChangeIconSize instead.")
    Library.Cursor:ChangeIconSize(Size)
end

--// DEPRECATED
function Library:ResetCursorIcon()
    warn("Obsidian:ResetCursorIcon is deprecated, please use Obsidian.Cursor:ResetIcon instead.")
    Library.Cursor:ResetIcon()
end

--// Colors \\--
function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Scale = Library.DPIScale
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size * Scale
    if Width then
        Params.Width = Width * Scale
    else
        Params.Width = workspace.CurrentCamera.ViewportSize.X - 32
    end

    local Bounds = TextService:GetTextBoundsAsync(Params)
    return math.ceil(Bounds.X / Scale), math.ceil(Bounds.Y / Scale)
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame: GuiObject, Frame: GuiObject)
    local GuiPos = Frame.AbsolutePosition
    local GuiSize = Frame.AbsoluteSize

    local FramePos = ParentFrame.AbsolutePosition
    local FrameSize = ParentFrame.AbsoluteSize

    return GuiPos.X >= FramePos.X
        and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
        and GuiPos.Y >= FramePos.Y
        and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError and Library.Notify then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function GetOverlappingDraggable(UI: GuiObject, TargetPos: Vector2?)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize

    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end

        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize

        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end

    return nil
end

function GetNonOverlappingPosition(UI: GuiObject, StartPos: UDim2?)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6

    local CurrentX = Start.X
    local CurrentY = Start.Y

    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end

    if Size.X == 0 then Size = Vector2.new(150, 40) end

    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end

        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end

        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding

            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end

            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end

    return UDim2.fromOffset(CurrentX, CurrentY)
end

function PositionDraggable(UI: GuiObject, StartPos: UDim2?)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

--// Window Snapping \\--
local function GetCoreGuiInset(): (Vector2, Vector2)
    local Success, TopLeft, BottomRight = pcall(function()
        return GuiService:GetGuiInset()
    end)

    if Success and TopLeft and BottomRight then
        return TopLeft, BottomRight
    end

    return Vector2.zero, Vector2.zero
end

local function GetSnapEdges(ElemSize: Vector2, ViewportSize: Vector2, Margin: number, AvoidCoreGui: boolean)
    local SafeMin, SafeMax = Vector2.zero, ViewportSize

    if AvoidCoreGui then
        local TopLeftInset, BottomRightInset = GetCoreGuiInset()
        SafeMin = TopLeftInset
        SafeMax = ViewportSize - BottomRightInset
    end

    local TargetsX = {
        LeftEdge = SafeMin.X + Margin,
        Center = SafeMin.X + (SafeMax.X - SafeMin.X - ElemSize.X) / 2,
        RightEdge = SafeMax.X - ElemSize.X - Margin,
    }
    local TargetsY = {
        TopEdge = SafeMin.Y + Margin,
        Center = SafeMin.Y + (SafeMax.Y - SafeMin.Y - ElemSize.Y) / 2,
        BottomEdge = SafeMax.Y - ElemSize.Y - Margin,
    }

    return TargetsX, TargetsY
end

local function GetClosestSnapTarget(Value: number, Targets: { [string]: number }, Distance: number): (number?, string?)
    local ClosestName, ClosestValue, ClosestDist = nil, nil, Distance

    for Name, Target in Targets do
        local Dist = math.abs(Value - Target)
        if Dist <= ClosestDist then
            ClosestDist = Dist
            ClosestName = Name
            ClosestValue = Target
        end
    end

    return ClosestValue, ClosestName
end

local function GetSnapGuideOffset(Name: string, SnappedValue: number, ElemDimension: number): number
    if Name == "RightEdge" or Name == "BottomEdge" then
        return SnappedValue + ElemDimension
    elseif Name == "Center" then
        return SnappedValue + ElemDimension / 2
    end

    return SnappedValue -- LeftEdge / TopEdge
end

function Library:MakeDraggable(
    UI: GuiObject,
    DragFrame: GuiObject,
    IgnoreToggled: boolean?,
    IsMainWindow: boolean?,
    SnapConfig: { Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean? }?
)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    local SnapGuideX, SnapGuideY

    -- smooth follow: the cursor sets a target, the UI eases toward it every frame
    local TargetPos: UDim2? = nil
    local SmoothConn = RunService.RenderStepped:Connect(function(Delta)
        if not TargetPos or not UI.Parent then
            return
        end

        local Current = UI.Position
        local Alpha = 1 - math.exp(-Delta * (Library.SmoothDragSpeed or 11))
        local Next = Current:Lerp(TargetPos, Alpha)

        if
            math.abs(TargetPos.X.Offset - Next.X.Offset) < 0.4
            and math.abs(TargetPos.Y.Offset - Next.Y.Offset) < 0.4
            and not Dragging
        then
            UI.Position = TargetPos
            TargetPos = nil
        else
            UI.Position = Next
        end
    end)
    Library:GiveSignal(SmoothConn)

    local function GetSnapGuides()
        if not SnapGuideX then
            SnapGuideX = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 2, 1, 0),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        if not SnapGuideY then
            SnapGuideY = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        return SnapGuideX, SnapGuideY
    end

    local function HideSnapGuides()
        if SnapGuideX then
            SnapGuideX.Visible = false
        end
        if SnapGuideY then
            SnapGuideY.Visible = false
        end
    end

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            local NewX = FramePos.X.Offset + Delta.X
            local NewY = FramePos.Y.Offset + Delta.Y

            if SnapConfig and SnapConfig.Enabled then
                local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local Distance = SnapConfig.Distance or 28
                local Margin = SnapConfig.Margin or 8

                local AbsX = FramePos.X.Scale * ViewportSize.X + NewX
                local AbsY = FramePos.Y.Scale * ViewportSize.Y + NewY

                local ElemSize = UI.AbsoluteSize
                local TargetsX, TargetsY = GetSnapEdges(ElemSize, ViewportSize, Margin, SnapConfig.AvoidCoreGui ~= false)
                local SnappedX, SnappedXName = GetClosestSnapTarget(AbsX, TargetsX, Distance)
                local SnappedY, SnappedYName = GetClosestSnapTarget(AbsY, TargetsY, Distance)

                if SnappedX then
                    NewX = SnappedX - FramePos.X.Scale * ViewportSize.X
                end
                if SnappedY then
                    NewY = SnappedY - FramePos.Y.Scale * ViewportSize.Y
                end

                local GuideX, GuideY = GetSnapGuides()
                GuideX.Visible = SnappedX ~= nil
                if SnappedX then
                    GuideX.Position = UDim2.fromOffset(GetSnapGuideOffset(SnappedXName, SnappedX, ElemSize.X), 0)
                end

                GuideY.Visible = SnappedY ~= nil
                if SnappedY then
                    GuideY.Position = UDim2.fromOffset(0, GetSnapGuideOffset(SnappedYName, SnappedY, ElemSize.Y))
                end
            end

            local Goal = UDim2.new(FramePos.X.Scale, NewX, FramePos.Y.Scale, NewY)
            if Library.SmoothDrag then
                TargetPos = Goal
            else
                UI.Position = Goal
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if SmoothConn and SmoothConn.Connected then
            SmoothConn:Disconnect()
        end

        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        if SnapGuideX then
            SnapGuideX:Destroy()
        end
        if SnapGuideY then
            SnapGuideY:Destroy()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        LayoutOrder = Info.LayoutOrder or 0,
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

--// Travelling shine on borders (used by the draggable buttons / labels / menus) \\--
local SpinningRims = {}
local RimLoop
function Library:SpinRim(Gradient: UIGradient?)
    if not Gradient then
        return
    end

    table.insert(SpinningRims, Gradient)
    if RimLoop then
        return
    end

    RimLoop = RunService.RenderStepped:Connect(function(Delta)
        local Step = (Library.RimSpinSpeed or 100) * Delta
        for Index = #SpinningRims, 1, -1 do
            local Rim = SpinningRims[Index]
            if not Rim.Parent then
                table.remove(SpinningRims, Index)
            else
                Rim.Rotation = (Rim.Rotation + Step) % 360
            end
        end
    end)
    Library:GiveSignal(RimLoop)
end

function Library:AddOutline(Frame: GuiObject)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1.5,
        Transparency = 0,
        ZIndex = 2,
        Parent = Frame,
    })
    -- Liquid Glass specular rim: light catches the opposite corners, edges stay almost clear
    local RimGradient = New("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.02),
            NumberSequenceKeypoint.new(0.18, 0.62),
            NumberSequenceKeypoint.new(0.5, 0.9),
            NumberSequenceKeypoint.new(0.82, 0.62),
            NumberSequenceKeypoint.new(1, 0.08),
        }),
        Rotation = 45,
        Parent = OutlineStroke,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1.5,
        Transparency = 0.82,
        ZIndex = 1,
        Parent = Frame,
    })
    -- glass body: lit from above, thicker/darker toward the bottom edge
    if not Frame:FindFirstChildOfClass("UIGradient") then
        New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(215, 225, 245)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 165, 195)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0.1),
            }),
            Rotation = 90,
            Parent = Frame,
        })
    end
    return OutlineStroke, ShadowStroke, RimGradient
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Animations \\--
local TransparencyCache = {}
local ActiveTabTweens = setmetatable({}, { __mode = "k" })

function Library:PlayTabAnimation(Tab, Showing: boolean, OnComplete: (() -> ())?)
    if type(Tab) ~= "table" or not Tab.Container then
        if OnComplete then
            OnComplete()
        end

        return
    end

    local TabContainer = Tab.Container :: Frame
    local Existing = ActiveTabTweens[TabContainer]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabContainer] = nil
    end

    local BaseZIndex = TabContainer.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabContainer.Visible = Showing
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end

        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition
        local StartingPositions = {
            Left = UDim2.fromOffset(-Offset, 0),
            Right = UDim2.fromOffset(Offset, 0),
            Top = UDim2.fromOffset(0, -Offset),
            Bottom = UDim2.fromOffset(0, Offset),
        }

        if SwipeFrom == "auto" and Library.PreviousTab then
            local CurrentOrder = Tab.Button.LayoutOrder
            local PreviousOrder = Library.PreviousTab.Button.LayoutOrder
            if CurrentOrder and PreviousOrder then -- this may be unnecessary but oh well
                StartPosition = CurrentOrder > PreviousOrder and StartingPositions.Top or StartingPositions.Bottom -- bigger order means its under the current button
            else
                StartPosition = StartingPositions.Bottom
            end
        elseif SwipeFrom == "left" then
            StartPosition = StartingPositions.Left
        elseif SwipeFrom == "top" then
            StartPosition = StartingPositions.Top
        elseif SwipeFrom == "right" then
            StartPosition = StartingPositions.Right
        else -- bottom (Default)
            StartPosition = StartingPositions.Bottom
        end

        TabContainer.ZIndex = BaseZIndex + 1
        TabContainer.Position = StartPosition
        TabContainer.Visible = true

        local Tween = TweenService:Create(TabContainer, TweenInfo, {
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabContainer] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            if Connection then
                Connection:Disconnect()
            end

            if ActiveTabTweens[TabContainer] == Tween then
                ActiveTabTweens[TabContainer] = nil
            end

            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end

            TabContainer.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabContainer.Visible = false
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end
    end
end

--// Pop Out \\--
function Library:MakeBoxPopOut(Box: any, Options: {
    Enabled: boolean?,
    Header: GuiObject?,
    Children: (() -> { GuiObject })?,
    Before: (() -> ())?,
    After: (() -> ())?,
    MaxPopOutHeight: number?,
    PopOutWidth: number?,
})
    Box.PoppedOut = false
    Box.PopOutEnabled = Options.Enabled ~= false
    Box.PopOutFloat = nil
    Box.PopOutPlaceholder = nil
    Box.PopOutMaxHeight = if typeof(Options.MaxPopOutHeight) == "number" then Options.MaxPopOutHeight else nil
    Box.PopOutWidth = if typeof(Options.PopOutWidth) == "number" then Options.PopOutWidth else nil

    if not Box.PopOutEnabled then
        function Box:SetPoppedOut(_Value: boolean, _SetPoppedOut: UDim2) end
        function Box:TogglePoppedOut() end
        function Box:RefreshPopOutPlaceholder() end
        function Box:SetMaxPopOutHeight(_Height: number?) end
        function Box:SetPopOutWidth(_Width: number?) end
        return
    end

    local BoxHolder = Box.BoxHolder
    local Holder = Box.Holder
    local Header = Options.Header

    local Placeholder
    local PlaceholderHeader
    local Float
    local FloatScale

    local HandledChildren: { GuiObject } = {}
    local OriginalParents: { [GuiObject]: Instance? } = {}
    local OriginalLayoutOrders: { [GuiObject]: number } = {}

    local DragState: "Idle" | "Holding" | "Dragging" = "Idle"
    local DragInput: InputObject?
    local PressMouse: Vector2?

    local DragStartPos: UDim2?
    local DragChanged: RBXScriptConnection?
    local DragDidMove = false

    --// UI Handler
    local function GetPopOutWidth(): number
        if typeof(Box.PopOutWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutWidth + 0.5))
        end

        if typeof(Box.PopOutDockedWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutDockedWidth + 0.5))
        end

        local Width = Holder.AbsoluteSize.X / Library.DPIScale
        if Width < 50 then
            Width = 200
        end

        return math.max(50, math.floor(Width + 0.5))
    end

    local function ApplyPopOutWidth()
        if not (Box.PoppedOut and Float) then
            return
        end

        Float.Size = UDim2.fromOffset(GetPopOutWidth(), Float.Size.Y.Offset)
        if Box.Resize then
            Box:Resize()
        end
    end

    local function RaiseFloat()
        if not Float or not Floats then
            return
        end

        local MaxZ = Float.ZIndex
        for _, Child in Floats:GetChildren() do
            if Child:IsA("GuiObject") and Child ~= Float then
                MaxZ = math.max(MaxZ, Child.ZIndex)
            end
        end

        Float.ZIndex = MaxZ + 1
        if Float.Parent == Floats then
            Float.Parent = Overlay
        end
        Float.Parent = Floats
    end

    local function CreatePlaceholder()
        local Frame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = BoxHolder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Frame
        RegisterPopOutClone(Header, PlaceholderHeader)
        DimPopOutClone(PlaceholderHeader)

        if PopOutIcon then
            local PlaceholderDockIcon = Library:CreateIcon(PopOutIcon, {
                AnchorPoint = Vector2.new(1, 0.5),
                ImageColor3 = "WhiteColor",
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                ZIndex = PlaceholderHeader.ZIndex + 1,
                Parent = Frame,
            }, true)
            PlaceholderDockIcon.MouseButton1Click:Connect(function()
                Box:SetPoppedOut(false)
            end)
        end

        return Frame
    end

    function Box:RefreshPopOutPlaceholder()
        if not Box.PoppedOut or not Placeholder or not Header then
            return
        end

        if PlaceholderHeader then
            PlaceholderHeader:Destroy()
            PlaceholderHeader = nil
        end

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Placeholder
        RegisterPopOutClone(Header, PlaceholderHeader)
        DimPopOutClone(PlaceholderHeader)
    end

    function Box:SetPoppedOut(Value: boolean, FloatPosition: UDim2?)
        if not Box.PopOutEnabled or Box.Destroyed then
            return
        end

        Value = Value == true
        if Box.PoppedOut == Value then
            if Value and FloatPosition and Float then
                Float.Position = FloatPosition
            end
            return
        end

        if Value then
            if Options.Before then
                Options.Before()
            end

            local BoxChildren = if Options.Children then Options.Children() else { Holder }
            HandledChildren = {}

            table.clear(OriginalParents)
            table.clear(OriginalLayoutOrders)

            for _, Child in BoxChildren do
                if not Child or not Child.Parent then
                    continue
                end

                table.insert(HandledChildren, Child)
                OriginalParents[Child] = Child.Parent
                OriginalLayoutOrders[Child] = Child.LayoutOrder
            end

            if #HandledChildren == 0 then
                return
            end

            local DockedWidth = Holder.AbsoluteSize.X / Library.DPIScale
            if DockedWidth < 50 then
                DockedWidth = 200
            end
            Box.PopOutDockedWidth = math.max(50, math.floor(DockedWidth + 0.5))

            local Width = GetPopOutWidth()

            local AbsolutePosition = Holder.AbsolutePosition
            Placeholder = CreatePlaceholder()
            Box.PopOutPlaceholder = Placeholder

            Float = New("Frame", {
                Active = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = FloatPosition or UDim2.fromOffset(
                    AbsolutePosition.X / Library.DPIScale,
                    AbsolutePosition.Y / Library.DPIScale
                ),
                Size = UDim2.fromOffset(Width, 0),
                ZIndex = 1,
                Parent = Floats,
            })
            FloatScale = New("UIScale", {
                Parent = Float,
            })
            table.insert(Library.Scales, FloatScale)
            FloatScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[FloatScale]) or 0)

            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = Float,
            })

            for _, Child in HandledChildren do
                Child.Parent = Float
            end

            if not table.find(Library.DraggableElements, Float) then
                table.insert(Library.DraggableElements, Float)
            end

            Box.PopOutFloat = Float
            Box.PoppedOut = true
            SyncPopOutVisibility(Box)
            RaiseFloat()

            Float:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                Box:Resize()
            end)

            if Options.After then
                Options.After()
            end

            return
        end

        if Float then
            local DraggableIndex = table.find(Library.DraggableElements, Float)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end
        end

        if FloatScale then
            local ScaleIndex = table.find(Library.Scales, FloatScale)
            if ScaleIndex then
                table.remove(Library.Scales, ScaleIndex)
            end

            FloatScale = nil
        end

        for _, Child in HandledChildren do
            if not Child or not Child.Parent then
                continue
            end

            Child.Parent = OriginalParents[Child] or BoxHolder
            Child.LayoutOrder = OriginalLayoutOrders[Child] or 0
        end

        if Placeholder then
            Placeholder:Destroy()
            Placeholder = nil
        end
        
        PlaceholderHeader = nil

        if Float then
            Float:Destroy()
            Float = nil
        end

        Box.PopOutFloat = nil
        Box.PopOutPlaceholder = nil
        Box.PopOutDockedWidth = nil
        Box.PoppedOut = false

        table.clear(HandledChildren)
        table.clear(OriginalParents)
        table.clear(OriginalLayoutOrders)

        if Options.After then
            Options.After()
        end
    end

    function Box:TogglePoppedOut()
        Box:SetPoppedOut(not Box.PoppedOut)
    end

    function Box:SetMaxPopOutHeight(Height: number?)
        if Height ~= nil then
            assert(typeof(Height) == "number", "Height must be a number or nil")
            assert(Height >= 0, "Height must be higher than 0")
        end

        Box.PopOutMaxHeight = Height
        if Box.PoppedOut and Box.Resize then
            Box:Resize()
        end
    end

    function Box:SetPopOutWidth(Width: number?)
        if Width ~= nil then
            assert(typeof(Width) == "number", "Width must be a number or nil")
            assert(Width >= 0, "Width must be higher than 0")
        end

        Box.PopOutWidth = Width
        ApplyPopOutWidth()
    end

    --// Drag Handler
    local function StopDrag()
        if DragState == "Idle" then
            return
        end

        local WasDragging = DragState == "Dragging"
        local DidMove = DragDidMove
        DragState = "Idle"
        DragInput = nil
        PressMouse = nil
        DragStartPos = nil
        DragDidMove = false

        if DragChanged and DragChanged.Connected then
            DragChanged:Disconnect()
            DragChanged = nil
        end

        if not WasDragging or not Box.PoppedOut or not Float then
            return
        end

        local FloatCenter = Float.AbsolutePosition + (Float.AbsoluteSize * 0.5)
        local NearPlaceholder = false
        if Library.Toggled and Placeholder and Placeholder.Parent then
            local PlaceholderCenter = Placeholder.AbsolutePosition + (Placeholder.AbsoluteSize * 0.5)
            NearPlaceholder = (FloatCenter - PlaceholderCenter).Magnitude <= Library.PopOutSnapDistance
        end

        if NearPlaceholder or (DidMove and not IsScreenPointOutsideMain(FloatCenter)) then
            Box:SetPoppedOut(false)
        end
    end

    local function BeginDrag(Input: InputObject)
        if DragState ~= "Idle" or Box.Destroyed or not (ScreenGui and ScreenGui.Parent) then
            return
        end

        local Point = Vector2.new(Input.Position.X, Input.Position.Y)
        local Top = GetTopFloatAt(Point)
        if Box.PoppedOut then
            if not Float or Top ~= Float then
                return
            end
        elseif Top ~= nil and not Header:IsDescendantOf(Top) then
            return
        end

        DragState = "Holding"
        DragInput = Input
        PressMouse = Vector2.new(Input.Position.X, Input.Position.Y)
        DragStartPos = nil
        DragDidMove = false

        if Box.PoppedOut and Float then
            RaiseFloat()
        end

        DragChanged = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)

        task.delay(Library.PopOutHoldTime, function()
            if (DragState :: any) ~= "Holding" or DragInput ~= Input then
                return
            end

            DragState = "Dragging"
            if Box.PoppedOut and Float then
                RaiseFloat()
                DragStartPos = Float.Position
            end
        end)
    end

    local function UpdateDrag(Input: InputObject)
        if DragState ~= "Dragging" or not PressMouse then
            return
        end
        if not (ScreenGui and ScreenGui.Parent) then
            StopDrag()
            return
        end

        local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Delta = MousePosition - PressMouse

        if not Box.PoppedOut then
            if Delta.Magnitude < Library.PopOutDragThreshold then
                return
            end

            Box:SetPoppedOut(true)
            if not Float then
                return
            end

            RaiseFloat()
            DragStartPos = Float.Position
            DragDidMove = true
        elseif Delta.Magnitude >= Library.PopOutDragThreshold then
            DragDidMove = true
        end

        if Float and DragStartPos then
            Float.Position = UDim2.new(
                DragStartPos.X.Scale,
                DragStartPos.X.Offset + Delta.X,
                DragStartPos.Y.Scale,
                DragStartPos.Y.Offset + Delta.Y
            )
        end
    end

    local function BindDragSource(Gui: GuiObject)
        Library:GiveSignal(Gui.InputBegan:Connect(function(Input: InputObject)
            if IsClickInput(Input) then
                BeginDrag(Input)
            end
        end))
    end

    BindDragSource(Header)
    for _, Descendant in Header:QueryDescendants("GuiObject:not(ImageButton)") do
        BindDragSource(Descendant)
    end

    Library:GiveSignal(Header.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("GuiObject") and not Descendant:IsA("ImageButton") then
            BindDragSource(Descendant)
        end
    end))

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if IsHoverInput(Input) then
            UpdateDrag(Input)
        end
    end))
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end

    IconPosition = string.lower(IconPosition)
    assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.6,
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:SpinRim(select(3, Library:AddOutline(Label)))
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(Text: string)
        Label.Text = Text
    end

    function DraggableLabel:SetIcon(NewIcon: string)
        Icon = NewIcon

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            IconImage = if IconImage then Library:ApplyIcon(IconImage, CustomIcon) else Library:CreateIcon(CustomIcon, {
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 2,
                Parent = Label,
            })
        end

        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition: string)
        IconPosition = string.lower(NewPosition)
        assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)

        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end

    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end

    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        DraggableLabel.Destroyed = true

        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)

    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.6,
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:SpinRim(select(3, Library:AddOutline(Button)))

    local PressPosition
    Button.InputBegan:Connect(function(Input: InputObject)
        if IsMouseInput(Input) then
            PressPosition = Button.AbsolutePosition
        end
    end)
    Button.Activated:Connect(function()
        if PressPosition and (Button.AbsolutePosition - PressPosition).Magnitude > 10 then
            return
        end

        Library:SafeCallback(Func, DraggableButton)
    end)

    function DraggableButton:SetText(Text: string)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    if not ExcludeDragging then
        Library:MakeDraggable(Button, Button, true)
    end
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        DraggableButton.Destroyed = true

        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.6,
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:SpinRim(select(3, Library:AddOutline(Holder)))

    local DividerLine = Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    local LabelPadding = New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    PositionDraggable(Holder, Holder.Position)

    return Holder, Container, Label, DividerLine, LabelPadding
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)

    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.6,
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 1,
        Parent = Floats,
    })

    local IconImage = Library:CreateIcon(nil, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 2,
        Parent = Button,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:SpinRim(select(3, Library:AddOutline(Button)))

    local PressPosition
    Button.InputBegan:Connect(function(Input: InputObject)
        if IsMouseInput(Input) then
            PressPosition = Button.AbsolutePosition
        end
    end)
    Button.Activated:Connect(function()
        if PressPosition and (Button.AbsolutePosition - PressPosition).Magnitude > 10 then
            return
        end

        Library:SafeCallback(Func, DraggableImageButton)
    end)

    function DraggableImageButton:SetIcon(NewIcon: string)
        Icon = NewIcon or Icon

        local CustomIcon = Library:GetCustomIcon(Icon)
        assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        IconImage = Library:ApplyIcon(IconImage, CustomIcon)
    end

    function DraggableImageButton:SetIconSize(NewSize: number)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    if not ExcludeDragging then
        Library:MakeDraggable(Button, Button, true)
    end
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

--// Context Menu \\--
local CurrentMenu

local function CloseMenus(Until: any?, ShouldClose: ((Menu: any) -> boolean)?)
    local Closed = {}

    while CurrentMenu and CurrentMenu ~= Until and not Closed[CurrentMenu] do
        local Menu = CurrentMenu
        if ShouldClose and not ShouldClose(Menu) then
            break
        end

        Closed[Menu] = true
        Menu:Close()
    end
end

function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    IgnoreCornerRadius: boolean?,
    SpecificCornersOnly: ("top" | "bottom" | "no_left" | "no_top_left")?, -- stupid way of doing this
    AnimationType: ("Dropdown" | "KeyPicker" | "none")?
)
    local Menu
    local HolderGui = Holder:FindFirstAncestorOfClass("ScreenGui")
    local ParentGui = Overlay
    if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
        ParentGui = HolderGui
    end

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.05, -- popups sit on top of other text: keep them nearly solid
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.05, -- popups sit on top of other text: keep them nearly solid
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    end
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })

    local Corner;
    if IgnoreCornerRadius ~= true then
        if SpecificCornersOnly == "top" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "bottom" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_top_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        else
            Corner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.Corners, Corner)
        end
    end

    local Table = {
        Connections = {},
        Destroyed = false,

        Active = false,
        ActiveCallback = ActiveCallback,

        Holder = Holder,
        Menu = Menu,
        Corner = Corner,

        List = nil,
        Signal = nil,

        Size = Size,
        AutoSizeY = List == 1,

        OpenCloseTween = nil,
        Animated = function()
            if not AnimationType or AnimationType == "none" then
                return false
            end

            if not (Library.Animations and Library.Animations[AnimationType] == true) then
                return false
            end

            return true, Library[string.format("%sTransitionInfo", AnimationType)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if List == 1 then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        end

        local NestedParent = nil
        local Check = CurrentMenu
        while Check do
            if Holder:IsDescendantOf(Check.Menu) then
                NestedParent = Check
                break
            end
            Check = Check.ParentMenu
        end

        CloseMenus(NestedParent)

        Table.ParentMenu = NestedParent
        CurrentMenu = Table
        Table.Active = true
        Menu.ZIndex = NestedParent and NestedParent.Menu.ZIndex + 1 or 1

        local TargetParent = if ParentGui == Overlay then Overlay else ParentGui
        Menu.Parent = nil
        Menu.Parent = TargetParent

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end

        local TargetSize = typeof(Table.Size) == "function" and Table.Size() or Table.Size

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            local OpenSize = TargetSize
            if Table.AutoSizeY then
                local FullHeight = Menu.AbsoluteSize.Y

                Menu.AutomaticSize = Enum.AutomaticSize.None
                OpenSize = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, FullHeight)
            end

            Menu.Size = UDim2.new(OpenSize.X.Scale, OpenSize.X.Offset, 0, 0)
            Menu.Visible = true

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = OpenSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Size = TargetSize
            Menu.Visible = true
        end

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end

            local HolderAllowed = Table.ParentMenu ~= nil or Library:IsInsideFrame(Library.WindowContainer, Holder)
            if not HolderAllowed then
                for _, Surface in Library.DraggableElements do
                    if not (Surface and Library:IsInsideFrame(Surface, Holder)) then
                        continue
                    end

                    HolderAllowed = true
                    break
                end
            end

            if not HolderAllowed and Table.Active then
                Table:Close()
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end

        Table.Active = false
        CurrentMenu = Table.ParentMenu
        Table.ParentMenu = nil

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            if Table.AutoSizeY then
                Menu.AutomaticSize = Enum.AutomaticSize.None
            end

            local CurrentSize = Menu.Size
            local CollapsedSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0)

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = CollapsedSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function(PlaybackState)
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    Menu.Visible = false
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Visible = false
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    function Table:Destroy()
        Table.Destroyed = true

        if Table.Connections then
            for _, Connection in Table.Connections do
                Connection:Disconnect()
            end
        end

        if Table.Active then
            CloseMenus(Table)
            Table:Close()
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local MenuIndex = table.find(Library.ContextMenus, Table)
        if MenuIndex then
            table.remove(Library.ContextMenus, MenuIndex)
        end

        if Menu then
            Menu:Destroy()
        end
    end

    table.insert(Library.ContextMenus, Table)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        CloseMenus(nil, function(Menu)
            return not (Library:MouseIsOverFrame(Menu.Menu, Location) or Library:MouseIsOverFrame(Menu.Holder, Location))
        end)
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    BackgroundColor3 = "BackgroundColor",
    BackgroundTransparency = 0.1,
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 30,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)

local TooltipMeasureId = 0
local LastTooltipText = ""
local LastTooltipMaxWidth = 0

local function UpdateTooltipSize(Force: boolean?)
    if Library.Unloaded or not TooltipLabel.Visible then
        return
    end

    local MaxWidth = math.max(
        40,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    if
        not Force
        and TooltipLabel.Text == LastTooltipText
        and math.abs(MaxWidth - LastTooltipMaxWidth) < 1
        and TooltipLabel.Size.X.Offset > 0
    then
        return
    end

    TooltipMeasureId += 1
    local MeasureId = TooltipMeasureId
    local Text = TooltipLabel.Text

    local X, Y = Library:GetTextBounds(Text, TooltipLabel.FontFace, TooltipLabel.TextSize, MaxWidth)
    if MeasureId ~= TooltipMeasureId or TooltipLabel.Text ~= Text then
        return
    end

    LastTooltipText = Text
    LastTooltipMaxWidth = MaxWidth
    TooltipLabel.Size = UDim2.fromOffset(X + 8, Y + 4)
end

TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    UpdateTooltipSize(false)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and not HoverInstance:IsDescendantOf(CurrentMenu.Menu) and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local HolderGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
            TooltipLabel.Parent = HolderGui
        else
            TooltipLabel.Parent = ScreenGui
        end

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Position = UDim2.fromOffset(
            Mouse.X + (Library.ShowCustomCursor and 8 or 14),
            Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
        )
        TooltipLabel.Visible = true
        UpdateTooltipSize(true)

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and not HoverInstance:IsDescendantOf(CurrentMenu.Menu) and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

local BaseAddons, BaseGroupbox = {}, {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            assert(Info.Mode == "Press", "KeyPicker on Buttons can only be applied with the 'Press' mode.")

            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},

            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            NoUI = Info.NoUI == true,
            MenuVisible = Info.NoUI ~= true,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
            Idx = Idx,
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label" or ParentObj.Type == "Button" or ParentObj.Type == "SubButton", "KeyPicker with the mode 'Press' can be only applied on Labels and Buttons.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local LastDisplayText = nil
        local MaxPickerWidth = 85
        local SlidingLabel

        local SlideForwardTween
        local SlideBackTween
        local HandleForwardTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideBackTween then
                SlideBackTween:Play()
            end
        end

        local HandleBackTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideForwardTween then
                SlideForwardTween:Play()
            end
        end

        local SlideForwardConn, SlideBackConn
        local CancelSlidingTweens = function()
            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end

            if SlideBackTween then
                StopTween(SlideBackTween, true)
                SlideBackTween = nil
            end

            RunService.RenderStepped:Wait()
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Size = UDim2.fromOffset(21, 21),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            TextTransparency = 0.4,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true

            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        }); table.insert(Library.SpecificCorners, PickerCorner)

        local PickerHoverTween = nil

        local function ApplyPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)
            PickerHoverTween = nil

            Picker.TextTransparency = Transparency
            if SlidingLabel then
                SlidingLabel.TextTransparency = Transparency
            end
        end

        local function TweenPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)

            PickerHoverTween = TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = Transparency,
            })
            PickerHoverTween:Play()

            if SlidingLabel then
                TweenService:Create(SlidingLabel, Library.TweenInfo, {
                    TextTransparency = Transparency,
                }):Play()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseEnter:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseLeave:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0.4)
        end))

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Parent = ToggleLabel.Parent,
            })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 6),
                Parent = Holder,
            })

            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Fill,
                Parent = ToggleLabel,
            })

            ToggleLabel.Parent = Holder
            Picker.Parent = Holder

            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Holder,
                })
            )
            local ButtonStroke = New("UIStroke", {
                Color = "OutlineColor",
                Enabled = false,
                Parent = Holder,
            })
            local ButtonPadding = New("UIPadding", {
                Parent = Holder,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.5,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = Library:CreateIcon(CheckIcon, {
                ImageColor3 = "FontColor",
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })

            function KeybindsToggle:Display(State)
                if KeyPicker.Mode == "Press" then
                    Label.TextTransparency = 0.4
                    SetIconProperties(CheckImage, { ImageTransparency = 1 })
                    return
                end

                Label.TextTransparency = State and 0 or 0.5
                SetIconProperties(CheckImage, { ImageTransparency = State and 0 or 1 })
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                local IsPress = KeyPicker.Mode == "Press"
                Holder.Active = not Normal or IsPress
                Checkbox.Visible = not Normal
                ButtonStroke.Enabled = IsPress
                Holder.BackgroundTransparency = IsPress and 0 or 1
                Holder.AutomaticSize = IsPress and Enum.AutomaticSize.X or Enum.AutomaticSize.None
                Holder.Size = IsPress and UDim2.fromOffset(0, 20) or UDim2.new(1, 0, 0, 16)
                ButtonPadding.PaddingLeft = UDim.new(0, IsPress and 8 or 0)
                ButtonPadding.PaddingRight = UDim.new(0, IsPress and 8 or 0)

                Label.AutomaticSize = Enum.AutomaticSize.X
                Label.Size = UDim2.fromScale(0, 1)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Position = (not IsPress and not Normal) and UDim2.fromOffset(22, 0) or UDim2.fromOffset(0, 0)
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            table.insert(KeyPicker.Connections, Holder.MouseButton1Click:Connect(function()
                if KeyPicker.Mode == "Press" then
                    KeyPicker:DoClick()
                    return
                end

                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
                KeyPicker:Update()
            end))
            table.insert(KeyPicker.Connections, Holder.MouseEnter:Connect(function()
                if KeyPicker.Mode == "Press" and not ParentObj.Disabled then
                    Label.TextTransparency = 0
                end
            end))
            table.insert(KeyPicker.Connections, Holder.MouseLeave:Connect(function()
                if KeyPicker.Mode == "Press" then
                    Label.TextTransparency = 0.4
                end
            end))

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local ModeCorners = {}
        local TotalModeButtons = GetTableSize(Info.Modes) + 1
        local MenuCornersOnly = if TotalModeButtons == 1 then "no_left" else "no_top_left"

        local MenuTable
        MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            PickerCorner.TopLeftRadius = Half
            PickerCorner.BottomLeftRadius = Half
            PickerCorner.TopRightRadius = Active and Zero or Half
            PickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = MenuTable and MenuTable.Corner
            if MenuCorner then
                if MenuCornersOnly == "no_left" then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.BottomLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                else
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end

            for _, Entry in ModeCorners do
                local Corner = Entry.Corner
                if Entry.Style == "single" then
                    Corner.TopLeftRadius = Zero
                    Corner.BottomLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomRightRadius = Half
                elseif Entry.Style == "first" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomLeftRadius = Zero
                    Corner.BottomRightRadius = Zero
                elseif Entry.Style == "last" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Zero
                    Corner.BottomLeftRadius = Half
                    Corner.BottomRightRadius = Half
                end
            end
        end, false, MenuCornersOnly, "KeyPicker")
        KeyPicker.Menu = MenuTable

        for Index, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            if Index == 1 and TotalModeButtons == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "single" })
            elseif Index == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "first" })
            elseif Index == TotalModeButtons then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "last" })
            end

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
                if KeyPicker.Update then
                    KeyPicker:Update()
                end
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            table.insert(KeyPicker.Connections, Button.MouseButton1Click:Connect(function()
                ModeButton:Select()
            end))

            table.insert(KeyPicker.Connections, Button.MouseEnter:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, Button.MouseLeave:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        do
            local RemoveButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                LayoutOrder = TotalModeButtons,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or 19),
                Text = "Remove",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RemoveButton,
            })
            table.insert(Library.SpecificCorners, Corner)
            table.insert(ModeCorners, { Corner = Corner, Style = "last" })

            table.insert(KeyPicker.Connections, RemoveButton.MouseButton1Click:Connect(function()
                MenuTable:Close()
                KeyPicker:SetValue({ "None", KeyPicker.Mode, {} })
            end))

            table.insert(KeyPicker.Connections, RemoveButton.MouseEnter:Connect(function()
                TweenService:Create(RemoveButton, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, RemoveButton.MouseLeave:Connect(function()
                TweenService:Create(RemoveButton, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))
        end

        local SetPickingState = function(State, SkipUpdate: boolean?)
            Picking = State
            Library.IsPicking = State

            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end

            if IsForButton then
                ToggleLabel.Visible = not Picking
                LastDisplayText = nil
                RunService.RenderStepped:Wait()
            end

            if SkipUpdate ~= true then
                (KeyPicker :: any):Update()
            end
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )

                local OffsetScale = X + 9
                local TextChanged = LastDisplayText ~= DisplayText
                local LabelWidth

                SlidingLabel.Text = DisplayText
                LastDisplayText = DisplayText

                if Picking then
                    Picker.Size = UDim2.new(1, 0, 1, 0)
                    RunService.RenderStepped:Wait()
                    LabelWidth = Picker.AbsoluteSize.X

                    if LabelWidth <= 0 then
                        LabelWidth = MaxPickerWidth
                    end
                else
                    LabelWidth = math.min(OffsetScale, MaxPickerWidth)
                    Picker.Size = UDim2.new(0, LabelWidth, 1, 0)
                end

                if OffsetScale > LabelWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)

                    local OverflowDistance = OffsetScale - LabelWidth - 4.5
                    if OverflowDistance > 0 then
                        if TextChanged or not SlideForwardTween then
                            SlidingLabel.Position = UDim2.fromOffset(4.5, 0)
                            CancelSlidingTweens()

                            local Duration = math.max(OverflowDistance / 25, 0.35)
                            local TweenInfo = TweenInfo.new(
                                Duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )

                            SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(-OverflowDistance, 0),
                            })

                            SlideBackTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(4.5, 0),
                            })

                            SlideForwardTween:Play()

                            if SlideForwardConn then
                                SlideForwardConn:Disconnect()
                            end

                            if SlideBackConn then
                                SlideBackConn:Disconnect()
                            end

                            SlideForwardConn = SlideForwardTween.Completed:Connect(HandleForwardTween)
                            SlideBackConn = SlideBackTween.Completed:Connect(HandleBackTween)
                        end
                    else
                        CancelSlidingTweens()

                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()

                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X / Library.DPIScale
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset(X + 9, 21)
            end
        end

        function KeyPicker:Update()
            local Disabled = ParentObj.Disabled == true

            if Disabled and Picking then
                SetPickingState(false, true)
            end

            KeyPicker:Display()

            Picker.Active = not Disabled
            ApplyPickerTextTransparency(Disabled and 0.8 or 0.4)

            if Disabled then
                if MenuTable.Active then
                    MenuTable:Close()
                end
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
                State = KeyPicker:GetState()
            end

            if Info.NoUI then
                return
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(KeyPicker.MenuVisible ~= false)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if Picking then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end

                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key] :: any) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if Picking or ParentObj.Disabled then
                return
            end

            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
            end

            if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            if ParentObj.Disabled then
                return
            end

            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    if KeyPicker.Value == "None" then
                        return nil
                    end

                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end

                    return SpecialKeys[KeyPicker.Value]
                end)
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            KeyPicker.Text = Text
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()

            local KeybindMenu = Library.KeybindMenu
            if KeybindMenu and KeybindMenu.SettingsOpen then
                KeybindMenu:RefreshSettings()
            end
        end

        function KeyPicker:SetMenuVisibility(Visible: boolean)
            assert(typeof(Visible) == "boolean", "Visible must be a boolean")

            KeyPicker.MenuVisible = Visible
            KeyPicker:Update()

            local KeybindMenu = Library.KeybindMenu
            if KeybindMenu and KeybindMenu.SettingsOpen then
                KeybindMenu:RefreshSettings()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseButton1Click:Connect(function()
            if Picking or Library.IsPicking or ParentObj.Disabled then
                return
            end

            SetPickingState(true)

            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 21)
            end

            -- Wait for any input --
            local ActiveModifiers = {}
            local CurrentInput = nil

            local IsValidInput = function(InputObj)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end

                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end

                return true
            end

            -- Wait for the first valid InputBegan --
            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end

                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            -- If it's a modifier key, we wait for either its release or another input --
            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Display the current state including the current modifier key --
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false

                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)

                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break -- Use modifier key as bind
                elseif NextInput then
                    -- Add another modifier or continue to normal key
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end

                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            MenuTable:Toggle()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                ParentObj.Disabled
                or KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if HoldingKey then
                if KeyPicker.Mode == "Toggle" then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Press" then
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Hold" then
                    InputChanged = Input.Changed:Connect(function()
                        if KeyPicker:GetState() then
                            return
                        end

                        KeyPicker:Update()
                        if InputChanged and InputChanged.Connected then
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end

                KeyPicker:Update()
            end
        end))

        KeyPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, KeyPicker)

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            KeyPicker.Destroyed = true

            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if IsForButton and SlideOverflow then
                if SlideForwardTween then
                    SlideForwardTween:Destroy()
                end

                if SlideBackTween then
                    SlideBackTween:Destroy()
                end
            end

            if Picker then
                Picker:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil

            local KeybindMenu = Library.KeybindMenu
            if KeybindMenu and KeybindMenu.SettingsOpen then
                KeybindMenu:RefreshSettings()
            end
        end

        Options[Idx] = KeyPicker

        local KeybindMenu = Library.KeybindMenu
        if KeybindMenu and KeybindMenu.SettingsOpen then
            KeybindMenu:RefreshSettings()
        end

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Connections = {},
            Destroyed = false,

            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(21, 21),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })

        local ColorPickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        }); table.insert(Library.SpecificCorners, ColorPickerCorner)

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        --// Color Menu \\--
        local MapSize = Library.IsMobile and 140 or 200
        local BarWidth = 16
        local MenuWidth = MapSize + BarWidth + 6 + 12
        if Info.Transparency then
            MenuWidth += BarWidth + 6
        end

        local ColorMenu
        local FooterCorner
        ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(MenuWidth, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1, function(Active: boolean)
                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                ColorPickerCorner.TopLeftRadius = Half
                ColorPickerCorner.TopRightRadius = Half
                ColorPickerCorner.BottomRightRadius = Active and Zero or Half
                ColorPickerCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = ColorMenu and ColorMenu.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end

                if FooterCorner then
                    FooterCorner.TopLeftRadius = Zero
                    FooterCorner.TopRightRadius = Zero
                    FooterCorner.BottomLeftRadius = Half
                    FooterCorner.BottomRightRadius = Half
                end
            end, false, "no_top_left")
        ColorMenu.List.Padding = UDim.new(0, 0)
        ColorPicker.ColorMenu = ColorMenu

        --// Content Holder \\--
        local ContentHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ContentHolder,
        })

        --// Footer \\--
        local FooterHeight = Library.IsMobile and 30 or 22

        local FooterBackground = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Size = UDim2.new(1, 0, 0, FooterHeight),
            Parent = ColorMenu.Menu,
        })
        FooterCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FooterBackground,
        })
        table.insert(Library.SpecificCorners, FooterCorner)
        Library:MakeLine(FooterBackground, {
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local FooterBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = FooterBackground,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, Info.Resizable and (FooterHeight + 4) or 6),
            Parent = FooterBar,
        })

        local FooterInfoLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = FooterBar,
        })

        local function RefreshFooterInfo()
            FooterInfoLabel.Text = string.format(
                "#%s • %d, %d, %d",
                ColorPicker.Value:ToHex(),
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255)
            )
        end
        RefreshFooterInfo()

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ContentHolder,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, MapSize),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(MapSize, MapSize),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(BarWidth, MapSize),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(BarWidth, MapSize),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        --// Resizing \\--
        local ResizeGrabber
        if Info.Resizable then
            local BaseMapSize = 200
            local BaseBarWidth = BarWidth
            local BasePadding = 6
            local MinMapSize = 140

            ColorPicker.MapWidth = MapSize
            ColorPicker.MapHeight = MapSize

            local function GetBarWidth(MapWidth)
                return math.clamp(math.floor((MapWidth / BaseMapSize) * BaseBarWidth + 0.5), 12, 24)
            end

            local function GetContentWidth(MapWidth)
                local CurrentBarWidth = GetBarWidth(MapWidth)
                local Width = MapWidth + CurrentBarWidth + BasePadding
                if Info.Transparency then
                    Width += (CurrentBarWidth + BasePadding)
                end

                return Width + 12
            end

            local FixedVerticalOverhead = 6 + 6 + 8 + 20 + 8 + 20 + FooterHeight
            if typeof(ColorPicker.Title) == "string" then
                FixedVerticalOverhead += 8 + 8
            end

            local function ClampToViewport(NewWidth, NewHeight)
                local Camera = workspace.CurrentCamera
                if not Camera then
                    return NewWidth, NewHeight
                end

                local ViewportSize = Camera.ViewportSize
                local ScreenMargin = 12

                local MaxWidth = ViewportSize.X - ColorMenu.Menu.AbsolutePosition.X - ScreenMargin
                local MaxHeight = ViewportSize.Y - ColorMenu.Menu.AbsolutePosition.Y - ScreenMargin - FixedVerticalOverhead

                while NewWidth > MinMapSize and GetContentWidth(NewWidth) > MaxWidth do
                    NewWidth -= 4
                end

                if NewHeight > MaxHeight then
                    NewHeight = math.max(MinMapSize, math.floor(MaxHeight))
                end

                return NewWidth, NewHeight
            end

            local function UpdateColorMenuSize(NewWidth, NewHeight)
                NewWidth = math.max(MinMapSize, math.floor(NewWidth + 0.5))
                NewHeight = math.max(MinMapSize, math.floor(NewHeight + 0.5))
                NewWidth, NewHeight = ClampToViewport(NewWidth, NewHeight)

                if NewWidth == ColorPicker.MapWidth and NewHeight == ColorPicker.MapHeight then
                    return
                end

                local CurrentBarWidth = GetBarWidth(NewWidth)
                local CursorSize = math.clamp(math.floor((math.min(NewWidth, NewHeight) / BaseMapSize) * 6 + 0.5), 4, 10)

                ColorHolder.Size = UDim2.new(1, 0, 0, NewHeight)
                SatVipMap.Size = UDim2.fromOffset(NewWidth, NewHeight)
                SatVibCursor.Size = UDim2.fromOffset(CursorSize, CursorSize)
                HueSelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)

                if TransparencySelector then
                    TransparencySelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)
                end

                ColorPicker.MapWidth = NewWidth
                ColorPicker.MapHeight = NewHeight
                ColorMenu:SetSize(UDim2.new(0, GetContentWidth(NewWidth), 0, 0))
            end

            ResizeGrabber = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = FooterBackground,
            })
            Library:CreateIcon(ResizeIcon, {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = ResizeGrabber,
            })

            table.insert(ColorPicker.Connections, ResizeGrabber.InputBegan:Connect(function(Input: InputObject)
                Library.CantDragForced = true
                local StartMouse = Vector2.new(Mouse.X, Mouse.Y)
                local StartWidth = ColorPicker.MapWidth
                local StartHeight = ColorPicker.MapHeight

                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartMouse
                    UpdateColorMenuSize(StartWidth + Delta.X, StartHeight + Delta.Y)

                    RunService.RenderStepped:Wait()
                end

                Library.CantDragForced = false
            end))
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local HueBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local RgbBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        --// Context Menu \\--
        local ContextMenu
        ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            ColorPickerCorner.TopLeftRadius = Half
            ColorPickerCorner.BottomLeftRadius = Half
            ColorPickerCorner.TopRightRadius = Active and Zero or Half
            ColorPickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = ContextMenu and ContextMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end
        end, false, "no_top_left")
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                table.insert(ColorPicker.Connections, Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end))

                table.insert(ColorPicker.Connections, Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 0.7,
                    }):Play()
                end))

                table.insert(ColorPicker.Connections, Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()
                end))
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            CreateButton("Paste color", function()
                if not Library.CopiedColor then
                    return
                end

                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)

                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// Copy/Paste Buttons \\--
        local ActionHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ActionHolder,
        })

        local CopyColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = CopyColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = CopyColorButton,
            })
        )

        local PasteColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = PasteColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = PasteColorButton,
            })
        )

        local CopyColorOriginalText = CopyColorButton.Text
        local PasteColorOriginalText = PasteColorButton.Text
        local CopyColorResetId = 0
        local PasteColorResetId = 0

        table.insert(ColorPicker.Connections, CopyColorButton.MouseEnter:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseLeave:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseEnter:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseLeave:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseButton1Click:Connect(function()
            Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }

            CopyColorResetId += 1
            local ThisResetId = CopyColorResetId
            CopyColorButton.Text = "Copied color"

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= CopyColorResetId then
                    return
                end

                CopyColorButton.Text = CopyColorOriginalText
            end)
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseButton1Click:Connect(function()
            PasteColorResetId += 1
            local ThisResetId = PasteColorResetId

            if not Library.CopiedColor then
                PasteColorButton.Text = "Nothing to paste"
            else
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                PasteColorButton.Text = "Pasted color"
            end

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= PasteColorResetId then
                    return
                end

                PasteColorButton.Text = PasteColorOriginalText
            end)
        end))

        --// End \\--
        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")

            RefreshFooterInfo()
        end

        local function ApplyHolderVisual(Disabled: boolean)
            Holder.Active = not Disabled
            HolderStroke.Transparency = Disabled and 0.5 or 0
            Holder.BackgroundTransparency = Disabled and 0.5 or 0

            if Disabled then
                Holder.BackgroundColor3 = ColorPicker.Value:Lerp(Library.Scheme.BackgroundColor, 0.5)
                HolderTransparency.ImageTransparency = math.clamp((1 - ColorPicker.Transparency) + 0.5, 0, 1)
            else
                Holder.BackgroundColor3 = ColorPicker.Value
                HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
                HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)
            end
        end

        function ColorPicker:RunChanged()
            if ParentObj.Disabled then
                return
            end

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:Update()
            ColorPicker:Display()

            local Disabled = ParentObj.Disabled == true
            ApplyHolderVisual(Disabled)

            if Disabled then
                if ColorMenu.Active then
                    ColorMenu:Close()
                end

                if ContextMenu.Active then
                    ContextMenu:Close()
                end
            end

            ColorPicker:RunChanged()
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        table.insert(ColorPicker.Connections, Holder.MouseButton1Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ColorMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, Holder.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ContextMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, SatVipMap.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(ColorPicker.Connections, HueSelector.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        if TransparencySelector then
            table.insert(ColorPicker.Connections, TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(ColorPicker.Connections, HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end))

        table.insert(ColorPicker.Connections, RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end))

        for _, BoxPair in {
            { HueBox, HueBoxStroke },
            { RgbBox, RgbBoxStroke }
        } do
            local TextBoxInstance, Stroke = BoxPair[1], BoxPair[2]

            table.insert(ColorPicker.Connections, TextBoxInstance.Focused:Connect(function()
                Library.Registry[Stroke].Color = "AccentColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(ColorPicker.Connections, TextBoxInstance.FocusLost:Connect(function()
                Library.Registry[Stroke].Color = "OutlineColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        ColorPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, ColorPicker)

        ColorPicker.Default = ColorPicker.Value

        function ColorPicker:Destroy()
            ColorPicker.Destroyed = true

            if ColorPicker.Connections then
                for _, Connection in ColorPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if ColorMenu then
                ColorMenu:Destroy()
            end

            if ResizeGrabber then
                ResizeGrabber:Destroy()
            end

            if ContextMenu then
                ContextMenu:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, ColorPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = ColorPicker

        return self
    end

    function Funcs:AddSettings(Info)
        if self.Destroyed then return nil end

        local ParentObj = self
        if ParentObj.Settings and not ParentObj.Settings.Destroyed then
            return ParentObj.Settings
        end

        Info = Library:Validate(Info, Templates.Settings)

        local Settings = {
            Connections = {},
            Destroyed = false,

            Elements = {},
            DependencyBoxes = {},

            Width = Info.Width,

            Type = "Settings",
            Parent = ParentObj,
        }

        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"
        local IsForContainer = ParentObj.Type == "Input" or ParentObj.Type == "Dropdown"
        local ParentContainer = IsForContainer and ParentObj.Container or nil

        local Gear = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Gear,
        })

        local GearCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Gear,
        }); table.insert(Library.SpecificCorners, GearCorner)

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 3),
            PaddingTop = UDim.new(0, 3),
            Parent = Gear,
        })

        local Icon = Library:CreateIcon(SettingsIcon, {
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            Parent = Gear,
        })

        if IsForButton then
            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.None,
                Parent = Gear,
            })

            Gear.LayoutOrder = ParentObj.Base.LayoutOrder + 1
            Gear.Size = UDim2.new(0, 21, 1, 0)
            Gear.Parent = ParentObj.Base.Parent
        elseif IsForContainer then
            local Height = ParentContainer.Size.Y.Offset
            ParentContainer.Size = UDim2.new(1, -(Height + 6), 0, Height)

            Gear.AnchorPoint = Vector2.new(1, 1)
            Gear.Position = UDim2.fromScale(1, 1)
            Gear.Size = UDim2.fromOffset(Height, Height)
            Gear.Parent = ParentObj.Holder
        else
            Gear.Size = UDim2.fromOffset(21, 21)
            Gear.Parent = ParentObj.TextLabel
        end

        local function GetMenuSize()
            if typeof(Settings.Width) == "number" then
                return UDim2.fromOffset(Settings.Width, 0)
            end

            if not Library.WindowContainer then
                return UDim2.fromOffset(200, 0)
            end

            local Width = (Library.WindowContainer.AbsoluteSize.X / Library.DPIScale - 12) / 2 - 7
            return UDim2.fromOffset(math.floor(Width), 0)
        end

        local SettingsMenu; SettingsMenu = Library:AddContextMenu(Gear, GetMenuSize, function()
            return { 0.5, Gear.AbsoluteSize.Y + 1.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            GearCorner.TopLeftRadius = Half
            GearCorner.TopRightRadius = Half
            GearCorner.BottomRightRadius = Active and Zero or Half
            GearCorner.BottomLeftRadius = Active and Zero or Half

            local MenuCorner = SettingsMenu and SettingsMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end

            if ParentObj.Disabled then
                return
            end

            SetIconProperties(Icon, { ImageTransparency = Active and 0 or 0.5 })
        end, false, "no_top_left")
        Settings.Menu = SettingsMenu

        local Container = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = SettingsMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = Container,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 7),
            PaddingLeft = UDim.new(0, 7),
            PaddingRight = UDim.new(0, 7),
            PaddingTop = UDim.new(0, 7),
            Parent = Container,
        })

        Settings.Holder = Container
        Settings.Container = Container
        Settings.Gear = Gear

        function Settings:Resize() end

        function Settings:SetWidth(Width: number?)
            if Width ~= nil then
                assert(typeof(Width) == "number", "Width must be a number or nil")
                assert(Width >= 0, "Width must be higher than 0")
            end

            Settings.Width = Width
            SettingsMenu:SetSize(GetMenuSize)
        end

        function Settings:Open()
            if ParentObj.Disabled then
                return
            end

            SettingsMenu:Open()
        end

        function Settings:Close()
            if not SettingsMenu.Active then
                return
            end

            CloseMenus(SettingsMenu)

            SettingsMenu:Close()
        end

        function Settings:Toggle()
            if SettingsMenu.Active then
                Settings:Close()
            else
                Settings:Open()
            end
        end

        function Settings:Update()
            local Disabled = ParentObj.Disabled == true

            Gear.Active = not Disabled
            Gear.BackgroundColor3 = Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Library.Registry[Gear].BackgroundColor3 = Disabled and "BackgroundColor" or "MainColor"
            SetIconProperties(Icon, { ImageTransparency = Disabled and 0.8 or (SettingsMenu.Active and 0 or 0.5) })

            if Disabled then
                Settings:Close()
            end
        end

        table.insert(Settings.Connections, Gear.MouseButton1Click:Connect(function()
            Settings:Toggle()
        end))

        table.insert(Settings.Connections, Gear.MouseEnter:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenIcon(Icon, { ImageTransparency = 0 })
        end))

        table.insert(Settings.Connections, Gear.MouseLeave:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenIcon(Icon, { ImageTransparency = SettingsMenu.Active and 0 or 0.5 })
        end))

        setmetatable(Settings, BaseGroupbox)

        function Settings:Destroy()
            Settings.Destroyed = true

            for _, Connection in Settings.Connections do
                Connection:Disconnect()
            end

            for Index = #Settings.Elements, 1, -1 do
                local Element = Settings.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end

            for Index = #Settings.DependencyBoxes, 1, -1 do
                local SubDepbox = Settings.DependencyBoxes[Index]
                if SubDepbox and SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            SettingsMenu:Destroy()

            if ParentContainer and ParentContainer.Parent then
                ParentContainer.Size = UDim2.new(1, 0, 0, ParentContainer.Size.Y.Offset)
            end

            if Gear then
                Gear:Destroy()
            end

            if ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, Settings)
                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            if ParentObj.Settings == Settings then
                ParentObj.Settings = nil
            end
        end

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, Settings)
        ParentObj.Settings = Settings

        Settings:Update()

        return Settings
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

do
    local Funcs = {}

    function Funcs:AddDivider(...)
        if self.Destroyed then return nil end

        local Params = select(1, ...)
        local Text
        local MarginTop = 0
        local MarginBottom = 0

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Text,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local X, _ = Library:GetTextBounds(Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X / Library.DPIScale)
            local SizeX = X // 2 + 10

            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.5,
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.5,
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.5,
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        local Divider = {
            Connections = {},
            Destroyed = false,

            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",

            Parent = Groupbox,
        }

        function Divider:SetVisible(Value)
            Holder.Visible = Value == true
            Groupbox:Resize()
        end

        function Divider:Destroy()
            Divider.Destroyed = true

            if Divider.Connections then
                for _, Connection in Divider.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Divider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
        end

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        if self.Destroyed then return nil end

        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Connections = {},
            Destroyed = false,

            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",

            Parent = Groupbox,
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Visible = Label.Visible,
            Parent = Container,
        })

        function Label:Display()
            if not Label.DoesWrap then
                return
            end

            local Width = TextLabel.AbsoluteSize.X / Library.DPIScale
            if Width <= 0 then return end

            local _, Y = Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, Width)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
        end

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            Label:Display()
            Groupbox:Resize()
        end

        if Label.DoesWrap then
            Label:Display()

            local Last = TextLabel.AbsoluteSize
            table.insert(Label.Connections, TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                Label:Display()
                Last = TextLabel.AbsoluteSize

                Groupbox:Resize()
            end))
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        function Label:Destroy()
            Label.Destroyed = true

            if Label.Connections then
                for _, Connection in Label.Connections do
                    Connection:Disconnect()
                end
            end

            if Label.Addons then
                for Index = #Label.Addons, 1, -1 do
                    local Addon = table.remove(Label.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if TextLabel then
                TextLabel:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Label)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Data.Idx then
                Labels[Data.Idx] = nil
            else
                local LblIdx = table.find(Labels, Label)

                if LblIdx then
                    table.remove(Labels, LblIdx)
                end
            end
        end

        return Label
    end

    function Funcs:AddButton(...)
        if self.Destroyed then return nil end

        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick
                Info.Icon = Params.Icon or Params.IconName

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false
                Info.Icon = nil

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,
            Icon = Info.Icon,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Locked = false,

            Base = nil,
            Stroke = nil,
            Content = nil,
            Label = nil,
            IconImage = nil,

            Addons = {},

            Tween = nil,
            Type = "Button",

            Parent = Groupbox,
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 6),
            Parent = Holder,
        })

        local function ApplyButtonIcon(Button, IconName)
            local Content = Button.Content
            if not Content then
                return
            end

            local ParsedIcon = Library:GetCustomIcon(IconName)
            if ParsedIcon then
                Button.IconImage = if Button.IconImage then Library:ApplyIcon(Button.IconImage, ParsedIcon) else Library:CreateIcon(ParsedIcon, {
                    LayoutOrder = 0,
                    Size = UDim2.fromOffset(14, 14),
                    Parent = Content,
                })

                Button.IconImage.Visible = true
                SetIconProperties(Button.IconImage, {
                    ImageColor3 = if Button.Risky then "RedColor" elseif ParsedIcon.Custom then "WhiteColor" else "FontColor",
                    ImageTransparency = Button.Disabled and 0.8 or 0.4,
                })
            elseif Button.IconImage then
                Button.IconImage.Visible = false
            end
        end

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                BackgroundTransparency = 0.25,
                LayoutOrder = Button.Type == "SubButton" and 2 or 0,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            local Content = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(0, 16),
                Parent = Base,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = Content,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Content,
            })

            Button.Content = Content
            Button.Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.fromOffset(0, 16),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = Button.Disabled and 0.8 or 0.4,
                Visible = Button.Text ~= "",
                Parent = Content,
            })

            if Button.Risky then
                Button.Label.TextColor3 = Library.Scheme.RedColor
                Library.Registry[Button.Label].TextColor3 = "RedColor"
            end

            ApplyButtonIcon(Button, Button.Icon)

            return Base, Stroke
        end

        local function InitEvents(Button)
            table.insert(Button.Connections, Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenIcon(Button.IconImage, { ImageTransparency = 0 })
                end
            end))
            table.insert(Button.Connections, Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenIcon(Button.IconImage, { ImageTransparency = 0.4 })
                end
            end))

            table.insert(Button.Connections, Button.Base.MouseButton1Click:Connect(function()
                if Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    local IconWasVisible = false
                    if Button.IconImage then
                        IconWasVisible = Button.IconImage.Visible
                        Button.IconImage.Visible = false
                    end

                    Button.Label.Text = "Are you sure?"
                    Button.Label.Visible = true
                    Button.Label.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Label].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Label.Text = Button.Text
                    Button.Label.Visible = Button.Text ~= ""
                    Button.Label.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Label].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Button.IconImage then
                        Button.IconImage.Visible = IconWasVisible
                    end

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait()
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end))
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Connections = {},
                Destroyed = false,

                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,
                Icon = Info.Icon,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,
                Locked = false,

                Base = nil,
                Stroke = nil,
                Content = nil,
                Label = nil,
                IconImage = nil,

                Addons = {},

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
                SubButton.Label.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                if SubButton.IconImage and SubButton.IconImage.Visible then
                    SetIconProperties(SubButton.IconImage, { ImageTransparency = SubButton.Disabled and 0.8 or 0.4 })
                end

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
                Library:UpdateAddons(SubButton)
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Label.Text = Text
                SubButton.Label.Visible = Text ~= ""
            end

            function SubButton:SetIcon(Icon: string?)
                SubButton.Icon = Icon
                ApplyButtonIcon(SubButton, Icon)
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            SubButton.AddKeyPicker = BaseAddons.__index.AddKeyPicker
            SubButton.AddSettings = BaseAddons.__index.AddSettings

            function SubButton:Destroy()
                SubButton.Destroyed = true

                if SubButton.Connections then
                    for _, Connection in SubButton.Connections do
                        Connection:Disconnect()
                    end
                end

                if SubButton.Addons then
                    for Index = #SubButton.Addons, 1, -1 do
                        local Addon = table.remove(SubButton.Addons, Index)
                        if Addon and Addon.Destroy then
                            Addon:Destroy()
                        end
                    end
                end

                if SubButton.TooltipTable then
                    SubButton.TooltipTable:Destroy()
                end

                if SubButton.Tween then
                    SubButton.Tween:Destroy()
                end

                if SubButton.Base then
                    SubButton.Base:Destroy()
                end

                if Info.Idx then
                    Buttons[Info.Idx] = nil
                else
                    local BIdx = table.find(Buttons, SubButton)

                    if BIdx then
                        table.remove(Buttons, BIdx)
                    end
                end
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Button.Label.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            if Button.IconImage and Button.IconImage.Visible then
                SetIconProperties(Button.IconImage, { ImageTransparency = Button.Disabled and 0.8 or 0.4 })
            end

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
            Library:UpdateAddons(Button)
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Label.Text = Text
            Button.Label.Visible = Text ~= ""
        end

        function Button:SetIcon(Icon: string?)
            Button.Icon = Icon
            ApplyButtonIcon(Button, Icon)
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        Button.AddKeyPicker = BaseAddons.__index.AddKeyPicker
        Button.AddSettings = BaseAddons.__index.AddSettings

        function Button:Destroy()
            Button.Destroyed = true

            if Button.Connections then
                for _, Connection in Button.Connections do
                    Connection:Disconnect()
                end
            end

            if Button.Addons then
                for Index = #Button.Addons, 1, -1 do
                    local Addon = table.remove(Button.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
            end

            if Button.Tween then
                Button.Tween:Destroy()
            end

            if Button.SubButton then
                Button.SubButton:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Button)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Info.Idx then
                Buttons[Info.Idx] = nil
            else
                local BIdx = table.find(Buttons, Button)

                if BIdx then
                    table.remove(Buttons, BIdx)
                end
            end
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Checkbox",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = Library:CreateIcon(CheckIcon, {
            ImageColor3 = "FontColor",
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                SetIconProperties(CheckImage, { ImageTransparency = Toggle.Value and 0.8 or 1 })

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenIcon(CheckImage, { ImageTransparency = Toggle.Value and 0 or 1 })

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if self.Destroyed then return nil end

        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Switch",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -38, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},

            Holder = nil,
            Label = nil,
            Container = nil,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local BoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
            BoxStroke.Transparency = Input.Disabled and 0.5 or 0

            Box.BackgroundColor3 = Input.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Library.Registry[Box].BackgroundColor3 = Input.Disabled and "BackgroundColor" or "MainColor"
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:RunChanged()
            if Input.Disabled then
                return
            end

            Library:SafeCallback(Input.Callback, Input.Value)
            Library:SafeCallback(Input.Changed, Input.Value)
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            Input:RunChanged()
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()

            Library:UpdateAddons(Input)
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            table.insert(Input.Connections, Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end))
        else
            table.insert(Input.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end

                Input:SetValue(Box.Text)
            end))
        end

        table.insert(Input.Connections, Box.Focused:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "AccentColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        table.insert(Input.Connections, Box.FocusLost:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "OutlineColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        Input.Label = Label
        Input.Container = Box

        Input.AddSettings = BaseAddons.__index.AddSettings
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end

        Input:UpdateColors()
        Options[Idx] = Input

        function Input:Destroy()
            Input.Destroyed = true

            if Input.Connections then
                for _, Connection in Input.Connections do
                    Connection:Disconnect()
                end
            end

            if Input.Addons then
                for Index = #Input.Addons, 1, -1 do
                    local Addon = table.remove(Input.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if Input.TooltipTable then
                Input.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Input)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 15),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = GetTextStrokeColor,
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local InputTextBox
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                TextSize = 14,
                ZIndex = Bar.ZIndex + 3,
                Visible = false,
                ClearTextOnFocus = false,
                Parent = Bar,
            })
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = GetTextStrokeColor,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = InputTextBox,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Bar,
            })
        )

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Fill,
            })
        )

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            if Info.AllowRightClickInput then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            if Slider.Disabled then
                return
            end

            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            local LastValidText = ""
            table.insert(Slider.Connections, InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local Text = InputTextBox.Text
                local AsNum = tonumber(Text)

                if #tostring(Text) > 0 and not AsNum and Text ~= "-" then
                    InputTextBox.Text = LastValidText
                else
                    if Slider.Rounding == 0 and Text:find("%.") then
                        InputTextBox.Text = LastValidText
                        return
                    end

                    local DecimalPos = Text:find("%.")
                    if DecimalPos and Slider.Rounding > 0 then
                        local Decimals = #Text - DecimalPos
                        if Decimals > Slider.Rounding then
                            InputTextBox.Text = LastValidText
                            return
                        end
                    end

                    LastValidText = Text
                end
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local Num = tonumber(InputTextBox.Text)
                if not Num then
                    return
                end

                Num = Round(Num, Slider.Rounding)
                Slider:SetValue(Num)
            end))
        end

        local LastTap = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            local ValidInput = IsClickInput(Input) or Input.UserInputType == Enum.UserInputType.MouseButton2
            if not ValidInput or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local IsRightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                local IsDoubleTap = false

                if Library.IsMobile and Input.UserInputType == Enum.UserInputType.Touch then
                    if tick() - LastTap < 0.3 then
                        IsDoubleTap = true
                    end

                    LastTap = tick()
                end

                if IsRightClick or IsDoubleTap then
                    InputTextBox.Text = tostring(Slider.Value)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(Input) then
                return
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    function Funcs:AddDropdown(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Dropdown)

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end

        local Dropdown = {
            Connections = {},
            Destroyed = false,

            Text = typeof(Info.Text) == "string" and Info.Text or nil,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,
            ValueImages = Info.ValueImages,

            Multi = Info.Multi,
            DragSelect = Info.Multi and not Library.IsMobile and Info.DragSelect == true,
            KeepDisabledValuePosition = Info.KeepDisabledValuePosition == true,

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            EnablePlayerImages = Info.EnablePlayerImages,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},

            Holder = nil,
            Label = nil,
            Container = nil,

            Type = "Dropdown",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
            Visible = Dropdown.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Dropdown.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not Info.Text,
            ZIndex = 3,
            Parent = Holder,
        })

        local DisplayContainer = New("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "",
            TextTransparency = 1,
            ZIndex = 2,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = DisplayContainer,
        })

        local DisplayStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = DisplayContainer,
        })

        local DropdownCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = DisplayContainer,
        }); table.insert(Library.SpecificCorners, DropdownCorner)

        local DisplayImage = Library:CreateIcon(nil, {
            Position = UDim2.fromOffset(-4, 3),
            Size = UDim2.fromOffset(16, 16),
            ImageTransparency = 1,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local DisplayButton = New("TextButton", {
            Active = not Dropdown.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local ArrowImage = Library:CreateIcon(ArrowIcon, {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Parent = DisplayContainer,
        })

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = DisplayButton,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })

            table.insert(Dropdown.Connections, SearchBox.Focused:Connect(function()
                Library.Registry[DisplayStroke].Color = "AccentColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Dropdown.Connections, SearchBox.FocusLost:Connect(function()
                Library.Registry[DisplayStroke].Color = "OutlineColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        local GetValueImage = function(Value, RawValue)
            if not Value then
                return nil
            end

            local ValueImage = nil
            if Dropdown.SpecialType == "Player" and Dropdown.EnablePlayerImages == true then
                local PlayerValue = Value
                if typeof(PlayerValue) ~= "Instance" and RawValue ~= nil then
                    PlayerValue = RawValue
                end

                if typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") then
                    ValueImage = { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(PlayerValue.UserId)) }
                end
            end

            if Dropdown.ValueImages then
                local IconRef = Dropdown.ValueImages[Value]
                if IconRef == nil and RawValue ~= nil then
                    IconRef = Dropdown.ValueImages[RawValue]
                end

                if IconRef then
                    ValueImage = Library:GetCustomIcon(IconRef)
                end
            end

            return ValueImage
        end

        local MenuTable
        MenuTable = Library:AddContextMenu(
            DisplayContainer,
            function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), 0)
            end,
            function()
                return { 0.5, DisplayContainer.AbsoluteSize.Y + 1.5 }
            end,
            2,
            function(Active: boolean)
                DisplayButton.TextTransparency = (Active and SearchBox) and 1 or 0

                SetIconProperties(ArrowImage, { ImageTransparency = Active and 0 or 0.5, Rotation = Active and 180 or 0 })

                if SearchBox then
                    SearchBox.Text = ""
                    SearchBox.Visible = Active
                end

                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                DropdownCorner.TopLeftRadius = Half
                DropdownCorner.TopRightRadius = Half
                DropdownCorner.BottomRightRadius = Active and Zero or Half
                DropdownCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = MenuTable and MenuTable.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Zero
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end,
            false,
            "bottom",
            "Dropdown"
        )
        Dropdown.Menu = MenuTable

        local ItemHeight = 21
        local PoolSize = math.max(1, Info.MaxVisibleDropdownItems + 2)
        local Pool = {}
        local FilteredEntries = {}

        function Dropdown:RecalculateListSize(Count)
            local ItemCount = Count or #FilteredEntries
            local Y = math.clamp(ItemCount * ItemHeight, 0, Info.MaxVisibleDropdownItems * ItemHeight)

            MenuTable.Menu.CanvasSize = UDim2.fromOffset(0, ItemCount * ItemHeight)

            MenuTable:SetSize(function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), Y)
            end)
        end

        function Dropdown:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8 or 0
            SetIconProperties(DisplayImage, { ImageTransparency = Dropdown.Disabled and 0.8 or 0 })
            SetIconProperties(ArrowImage, { ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5 })
        end

        function Dropdown:Display()
            if Library.Unloaded then
                return
            end

            local Str = ""
            local ValueImage = nil
            local IsDictionary = not IsSequentialArray(Dropdown.Values)

            if Info.Multi then
                for Key, RawValue in Dropdown.Values do
                    local Value = IsDictionary and Key or RawValue

                    if Dropdown.Value[Value] then
                        if not ValueImage then
                            ValueImage = GetValueImage(Value, RawValue)
                        end

                        Str = Str
                            .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(RawValue)) or tostring(RawValue))
                            .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                local DisplayValue = Dropdown.Value
                if IsDictionary and Dropdown.Value ~= nil then
                    DisplayValue = Dropdown.Values[Dropdown.Value]
                end

                ValueImage = GetValueImage(Dropdown.Value, DisplayValue)
                Str = DisplayValue and tostring(DisplayValue) or ""

                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Str))
                end
            end

            if #Str > 25 then
                Str = Str:sub(1, 22) .. "..."
            end

            DisplayButton.Text = (Str == "" and "---" or Str)

            DisplayImage = Library:ApplyIcon(DisplayImage, ValueImage)
            SetIconProperties(DisplayImage, { ImageTransparency = if ValueImage then 0 else 1 })

            DisplayButton.Size = ValueImage and UDim2.new(1, -8, 0, 21) or UDim2.new(1, 0, 0, 21)
            DisplayButton.Position = ValueImage and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues(ReturnCount)
            local Table = {}

            if Info.Multi then
                for Value, _ in Dropdown.Value do
                    table.insert(Table, Value)
                end
            else
                if Dropdown.Value then
                    table.insert(Table, Dropdown.Value)
                end
            end

            return ReturnCount == true and GetTableSize(Table) or Table
        end

        local DragSelecting = false
        local DragStartIndex = nil
        local DragPrevMin = nil
        local DragPrevMax = nil
        local DragLastIndex = nil
        local DragInitialValues = {}
        local DragInputEndedConn = nil
        local DragInputChangedConn = nil

        local function RecomputeFilteredEntries()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local IsDictionary = not IsSequentialArray(Values)

            --// Fuzzy-match dropdown values the same way the sidebar search
            --// does, so e.g. "clr" can find "Clear Inventory" in a list \\--
            local SearchQuery = SearchBox and NormalizeSearch(LowerText(SearchBox.Text)) or ""
            local IsSearching = SearchQuery ~= ""

            local EnabledList, DisabledList = {}, {}
            local Pending = {}

            for Key, RawValue in Values do
                local Value = IsDictionary and Key or RawValue

                local FormattedValue = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

                local MatchScore = 0
                if IsSearching then
                    local Matched, Score = FuzzyScore(LowerText(FormattedValue), SearchQuery)
                    if not Matched then
                        continue
                    end
                    MatchScore = Score
                end

                local IsDisabled = table.find(DisabledValues, Value) ~= nil
                    or (RawValue ~= nil and RawValue ~= Value and table.find(DisabledValues, RawValue) ~= nil)

                local Entry = {
                    Value = Value,
                    RawValue = RawValue,
                    FormattedValue = FormattedValue,
                    IsDisabled = IsDisabled,
                    ValueImage = GetValueImage(Value, RawValue),
                    SortKey = Key,
                    MatchScore = MatchScore,
                    Order = #Pending + 1,
                }

                table.insert(Pending, Entry)
            end

            if IsSearching then
                --// Best matches first; ties fall back to original order \\--
                table.sort(Pending, function(A, B)
                    if A.MatchScore ~= B.MatchScore then
                        return A.MatchScore > B.MatchScore
                    end
                    return A.Order < B.Order
                end)
            elseif not IsDictionary then
                table.sort(Pending, function(A, B)
                    return A.SortKey < B.SortKey
                end)
            end

            table.clear(FilteredEntries)

            if Dropdown.KeepDisabledValuePosition then
                for _, Entry in Pending do
                    table.insert(FilteredEntries, Entry)
                end
                return
            end

            for _, Entry in Pending do
                if Entry.IsDisabled then
                    table.insert(DisabledList, Entry)
                else
                    table.insert(EnabledList, Entry)
                end
            end

            for _, Entry in EnabledList do
                table.insert(FilteredEntries, Entry)
            end
            for _, Entry in DisabledList do
                table.insert(FilteredEntries, Entry)
            end
        end

        local function GetFirstVisibleIndex()
            local Total = #FilteredEntries
            if Total <= PoolSize then
                return 1
            end

            local MaxFirst = Total - PoolSize + 1
            local ScrollY = MenuTable.Menu.CanvasPosition.Y / Library.DPIScale
            local Index = math.floor(ScrollY / ItemHeight) + 1
            return math.clamp(Index, 1, MaxFirst)
        end

        function Dropdown:RefreshPool()
            local Total = #FilteredEntries
            local First = GetFirstVisibleIndex()

            for SlotIndex, Row in Pool do
                local DataIndex = First + SlotIndex - 1
                local Entry = FilteredEntries[DataIndex]

                Row.Entry = Entry
                Row.Index = Entry and DataIndex or nil

                if not Entry then
                    Row.Container.Visible = false
                    continue
                end

                Row.Container.Visible = true
                Row.Container.Position = UDim2.fromOffset(0, (DataIndex - 1) * ItemHeight)

                local IsLast = DataIndex == Total
                Row.Corner.BottomRightRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                Row.Corner.BottomLeftRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)

                Row.Button.Text = Entry.FormattedValue

                if Entry.ValueImage then
                    Row.Image = Library:ApplyIcon(Row.Image, Entry.ValueImage)
                    Row.Image.Visible = true
                    Row.Button.Size = UDim2.new(1, -18, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(18, 0)
                else
                    Row.Image.Visible = false
                    Row.Button.Size = UDim2.new(1, 0, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(0, 0)
                end

                Row:UpdateButton()
            end
        end

        function Dropdown:RunChanged()
            if Dropdown.Disabled then
                return
            end

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        local function StopDragSelect()
            DragSelecting = false
            DragStartIndex = nil
            DragPrevMin = nil
            DragPrevMax = nil
            DragLastIndex = nil
            table.clear(DragInitialValues)

            if DragInputEndedConn then
                DragInputEndedConn:Disconnect()
                DragInputEndedConn = nil
            end

            if DragInputChangedConn then
                DragInputChangedConn:Disconnect()
                DragInputChangedConn = nil
            end
        end

        local DragActiveCount = 0

        local function ApplyDragIndex(Index, InRange)
            local Entry = FilteredEntries[Index]
            if not Entry or Entry.IsDisabled then
                return
            end

            local Try = DragInitialValues[Entry.Value]
            if InRange then
                Try = not Try
            end

            local WantActive = Try and true or false
            local IsActive = Dropdown.Value[Entry.Value] and true or false
            if WantActive == IsActive then
                return
            end

            if not WantActive and DragActiveCount == 1 and not Info.AllowNull then
                return
            end

            Dropdown.Value[Entry.Value] = WantActive and true or nil
            DragActiveCount += WantActive and 1 or -1
        end

        local function ApplyDragRange(From, To, InRange)
            for Index = From, To do
                ApplyDragIndex(Index, InRange)
            end
        end

        local function UpdateDrag(CurrentIndex)
            if CurrentIndex == nil or CurrentIndex == DragLastIndex then
                return
            end

            DragLastIndex = CurrentIndex

            local Min = math.min(DragStartIndex, CurrentIndex)
            local Max = math.max(DragStartIndex, CurrentIndex)
            DragActiveCount = Dropdown:GetActiveValues(true)

            if DragPrevMin == nil then
                ApplyDragRange(Min, Max, true)
            else
                if DragPrevMin < Min then
                    ApplyDragRange(DragPrevMin, Min - 1, false)
                end
                if DragPrevMax > Max then
                    ApplyDragRange(Max + 1, DragPrevMax, false)
                end
                if Min < DragPrevMin then
                    ApplyDragRange(Min, DragPrevMin - 1, true)
                end
                if Max > DragPrevMax then
                    ApplyDragRange(DragPrevMax + 1, Max, true)
                end
            end

            DragPrevMin = Min
            DragPrevMax = Max

            for _, OtherRow in Pool do
                OtherRow:UpdateButton()
            end
        end

        local function CreatePoolRow()
            local Row = {
                Entry = nil,
                Index = nil
            }

            local Container = New("Frame", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Visible = false,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Container,
            }); table.insert(Library.SpecificCorners, Corner)

            local Image = Library:CreateIcon(nil, {
                ImageTransparency = 0.5,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(4, 3),
                Visible = false,
                Parent = Container,
            })

            local Button = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                Parent = Button,
            })

            Row.Container = Container
            Row.Corner = Corner
            Row.Image = Image
            Row.Button = Button

            function Row:UpdateButton()
                local Entry = Row.Entry
                if not Entry then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                Row.Selected = Selected and true or false

                Container.BackgroundTransparency = Selected and 0 or 1
                Button.TextTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5

                if Entry.ValueImage then
                    SetIconProperties(Row.Image, { ImageTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5 })
                end
            end

            table.insert(Dropdown.Connections, Button.MouseButton1Click:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or DragSelecting then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                local Try = not Selected
                if not (Dropdown:GetActiveValues(true) == 1 and not Try and not Info.AllowNull) then
                    Selected = Try
                    if Info.Multi then
                        Dropdown.Value[Entry.Value] = Selected and true or nil
                    else
                        Dropdown.Value = Selected and Entry.Value or nil
                    end

                    for _, OtherRow in Pool do
                        OtherRow:UpdateButton()
                    end
                end

                Row:UpdateButton()
                Dropdown:Display()

                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end))

            table.insert(Dropdown.Connections, Button.MouseEnter:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 0.85,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.25,
                }):Play()

                TweenIcon(Row.Image, { ImageTransparency = 0.25 })
            end))

            table.insert(Dropdown.Connections, Button.MouseLeave:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.5,
                }):Play()

                TweenIcon(Row.Image, { ImageTransparency = 0.5 })
            end))

            table.insert(Dropdown.Connections, Button.InputBegan:Connect(function(StartInput)
                if not (Info.Multi and Dropdown.DragSelect and not Library.IsMobile) then
                    return
                end

                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if not IsMouseInput(StartInput) then
                    return
                end

                DragSelecting = true
                DragStartIndex = Row.Index
                table.clear(DragInitialValues)

                for _, FilteredEntry in FilteredEntries do
                    DragInitialValues[FilteredEntry.Value] = Dropdown.Value[FilteredEntry.Value]
                end

                UpdateDrag(Row.Index)

                if DragInputEndedConn then DragInputEndedConn:Disconnect() end
                if DragInputChangedConn then DragInputChangedConn:Disconnect() end

                DragInputChangedConn = Library:GiveSignal(UserInputService.InputChanged:Connect(function(ChangeInput)
                    if not IsMovementInput(ChangeInput) and ChangeInput ~= StartInput then
                        return
                    end

                    local Pos = ChangeInput.Position
                    for _, OtherRow in Pool do
                        if OtherRow.Entry and Library:MouseIsOverFrame(OtherRow.Button, Pos) then
                            UpdateDrag(OtherRow.Index)
                            break
                        end
                    end
                end))

                DragInputEndedConn = Library:GiveSignal(UserInputService.InputEnded:Connect(function(EndInput)
                    if EndInput ~= StartInput and not (IsMouseInput(EndInput) and EndInput.UserInputType == StartInput.UserInputType) then
                        return
                    end

                    Dropdown:Display()
                    Library:UpdateDependencyBoxes()
                    Dropdown:RunChanged()

                    StopDragSelect()
                end))

                table.insert(Dropdown.Connections, DragInputEndedConn)
                table.insert(Dropdown.Connections, DragInputChangedConn)
            end))

            return Row
        end

        function Dropdown:BuildDropdownList()
            StopDragSelect()

            RecomputeFilteredEntries()

            MenuTable.Menu.CanvasPosition = Vector2.new(0, 0)

            Dropdown:RefreshPool()
            Dropdown:RecalculateListSize(#FilteredEntries)
        end

        for _ = 1, PoolSize do
            table.insert(Pool, CreatePoolRow())
        end

        table.insert(Dropdown.Connections, MenuTable.Menu:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Dropdown:RefreshPool()
        end))

        local function ValueExists(Val)
            if IsSequentialArray(Dropdown.Values) then
                for _, Existing in Dropdown.Values do
                    if Existing == Val then
                        return true
                    end
                end

                return false
            end

            return Dropdown.Values[Val] ~= nil
        end

        function Dropdown:SetValue(Value)
            if Info.Multi then
                if typeof(Value) == "string" then
                    Value = if Value == "" then {} else { [Value] = true }
                end

                local Table = {}

                for Val, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and ValueExists(Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if ValueExists(Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Row in Pool do
                Row:UpdateButton()
            end

            if not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            Dropdown:RunChanged()
        end

        function Dropdown:SetValues(Values)
            Dropdown.Values = Values

            local Changed = false
            if Info.Multi then
                for Val in Dropdown.Value do
                    if not ValueExists(Val) then
                        Dropdown.Value[Val] = nil
                        Changed = true
                    end
                end

            elseif Dropdown.Value ~= nil and not ValueExists(Dropdown.Value) then
                Dropdown.Value = nil
                Changed = true
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()

            if Changed and not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if Changed then
                Dropdown:RunChanged()
            end
        end

        function Dropdown:AddValues(Values)
            if typeof(Values) ~= "table" and typeof(Values) ~= "string" then
                return
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            if IsDictionary then
                if typeof(Values) == "string" then
                    Dropdown.Values[Values] = Values

                elseif IsSequentialArray(Values) then
                    for _, Val in Values do
                        Dropdown.Values[Val] = Val
                    end

                else
                    for Key, Val in Values do
                        Dropdown.Values[Key] = Val
                    end
                end
            else
                if typeof(Values) == "table" then
                    for _, Val in Values do
                        table.insert(Dropdown.Values, Val)
                    end
                else
                    table.insert(Dropdown.Values, Values)
                end
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in DisabledValues do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            Dropdown.ValueImages = ValueImages
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            for key, val in ValueImages do
                Dropdown.ValueImages[key] = val
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            DisplayButton.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()
            Library:UpdateAddons(Dropdown)

            Library:UpdateDependencyBoxes()
        end

        function Dropdown:SetVisible(Visible: boolean)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible
            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            Dropdown.Text = Text
            Holder.Size = UDim2.new(1, 0, 0, Text and 39 or 21)

            Label.Text = Text and Text or ""
            Label.Visible = not not Text
        end

        function Dropdown:SetDragSelect(Value: boolean)
            if not Info.Multi or Library.IsMobile then
                Value = false
            end

            Dropdown.DragSelect = Value == true
            Dropdown:BuildDropdownList()
        end

        local ToggleDropdown = function()
            if Dropdown.Disabled then
                return
            end

            MenuTable:Toggle()
        end

        table.insert(Dropdown.Connections, DisplayContainer.MouseButton1Click:Connect(ToggleDropdown))
        table.insert(Dropdown.Connections, DisplayButton.MouseButton1Click:Connect(ToggleDropdown))

        if SearchBox then
            table.insert(Dropdown.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList))
        end

        local Defaults = (function()
            local Resolved = {}
            local Default = Info.Default
            if Default == nil then
                return Resolved
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            local function ResolveOne(Candidate)
                if IsDictionary then
                    return Dropdown.Values[Candidate] ~= nil and Candidate or nil
                end

                for _, Existing in Dropdown.Values do
                    if Existing == Candidate then
                        return Existing
                    end
                end

                return nil
            end

            local DefaultType = typeof(Default)
            if DefaultType == "string" then
                local Value = ResolveOne(Default)
                if Value ~= nil then
                    table.insert(Resolved, Value)
                end

            elseif DefaultType == "table" then
                for _, Candidate in Default do
                    local Value = ResolveOne(Candidate)
                    if Value ~= nil then
                        table.insert(Resolved, Value)
                    end
                end

            elseif Dropdown.Values[Default] ~= nil then
                table.insert(Resolved, IsDictionary and Default or Dropdown.Values[Default])
            end

            return Resolved
        end)()

        for _, SelectValue in Defaults do
            if Info.Multi then
                Dropdown.Value[SelectValue] = true
            else
                Dropdown.Value = SelectValue
                break
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, DisplayContainer)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        Dropdown.Label = Label
        Dropdown.Container = DisplayContainer

        Dropdown.AddSettings = BaseAddons.__index.AddSettings
        table.insert(Groupbox.Elements, Dropdown)

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        function Dropdown:Destroy()
            Dropdown.Destroyed = true

            StopDragSelect()

            if Dropdown.Connections then
                for _, Connection in Dropdown.Connections do
                    Connection:Disconnect()
                end
            end

            if Dropdown.Addons then
                for Index = #Dropdown.Addons, 1, -1 do
                    local Addon = table.remove(Dropdown.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable:Destroy()
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Dropdown)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Dropdown
    end

    function Funcs:AddViewport(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Connections = {},
            Destroyed = false,

            Object = ViewportObject :: PVInstance,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = (Viewport.Object :: PVInstance):GetPivot().Position

            Viewport.Camera.CFrame = CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local function GetPivotPosition()
            return (Viewport.Object :: PVInstance):GetPivot().Position
        end

        local function OrbitCamera(Yaw: number, Pitch: number)
            local Position = GetPivotPosition()
            local Camera = Viewport.Camera

            local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), Yaw)
            Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

            local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, Pitch)
            local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

            if PitchedCFrame.UpVector.Y > 0.1 then
                Camera.CFrame = PitchedCFrame
            end
        end

        local function ZoomCamera(Amount: number)
            Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * Amount
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        table.insert(Viewport.Connections, ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = false
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = true
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Touch and not Pinching) then
                Dragging = true
                LastMousePos = input.Position
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                OrbitCamera(-MouseDelta.X * 0.01, -MouseDelta.Y * 0.01)
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                ZoomCamera(input.Position.Z * 2)
            end
        end))

        table.insert(Viewport.Connections, UserInputService.TouchPinch:Connect(function(touchPositions, _, _, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                ZoomCamera(delta)
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        ;(Viewport.Object :: PVInstance).Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            ;(Viewport.Object :: PVInstance).Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetCameraCFrame(NewCFrame: CFrame)
            assert(typeof(NewCFrame) == "CFrame", "CFrame must be a valid CFrame.")

            Viewport.Camera.CFrame = NewCFrame
        end

        function Viewport:GetCameraCFrame(): CFrame
            return Viewport.Camera.CFrame
        end

        function Viewport:Rotate(Yaw: number, Pitch: number?)
            if not Viewport.Object then
                return
            end

            OrbitCamera(math.rad(Yaw or 0), math.rad(Pitch or 0))
        end

        function Viewport:Zoom(Amount: number)
            assert(typeof(Amount) == "number", "Amount must be a number.")

            ZoomCamera(Amount)
        end

        function Viewport:LookAt(Target: Vector3?)
            if not Target and not Viewport.Object then
                return
            end

            Viewport.Camera.CFrame = CFrame.lookAt(Viewport.Camera.CFrame.Position, Target or GetPivotPosition())
        end

        function Viewport:SetDistance(Distance: number)
            assert(typeof(Distance) == "number" and Distance > 0, "Distance must be greater than 0.")
            if not Viewport.Object then
                return
            end

            local Position = GetPivotPosition()
            local Offset = Viewport.Camera.CFrame.Position - Position
            local Direction = Offset.Magnitude > 0 and Offset.Unit or -Viewport.Camera.CFrame.LookVector

            Viewport.Camera.CFrame = CFrame.lookAt(Position + Direction * Distance, Position)
        end

        function Viewport:GetDistance(): number
            if not Viewport.Object then
                return 0
            end

            return (Viewport.Camera.CFrame.Position - GetPivotPosition()).Magnitude
        end

        function Viewport:SetFieldOfView(FieldOfView: number)
            assert(typeof(FieldOfView) == "number", "FieldOfView must be a number.")

            Viewport.Camera.FieldOfView = math.clamp(FieldOfView, 1, 120)
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        function Viewport:Destroy()
            Viewport.Destroyed = true

            if Viewport.Connections then
                for _, Connection in Viewport.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Viewport)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Connections = {},
            Destroyed = false,

            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = Image.BackgroundTransparency,
            ClipsDescendants = true,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local Icon = Library:GetCustomIcon(Image.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        local ImageLabel = New("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ScaleType = Image.ScaleType,
            Parent = Box,
        })
        FillInstance(ImageContent(Icon), ImageLabel)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            FillInstance(ImageContent(Icon), ImageLabel)
            Image.Image = Icon.Url
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        function Image:Destroy()
            Image.Destroyed = true

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Image)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Connections = {},
            Destroyed = false,

            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        function Video:Destroy()
            Video.Destroyed = true

            if Video.Connections then
                for _, Connection in Video.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Video)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Connections = {},
            Destroyed = false,

            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        function Passthrough:Destroy()
            Passthrough.Destroyed = true

            if Passthrough.Connections then
                for _, Connection in Passthrough.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Passthrough)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Passthrough
    end

    function Funcs:AddDependencyBox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {}
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        table.insert(Depbox.Connections, DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end))

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        table.insert(Depbox.Connections, DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end))

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        function Depbox:Destroy()
            Depbox.Destroyed = true

            if Depbox.Connections then
                for _, Connection in Depbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in Depbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in Depbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepboxContainer then
                DepboxContainer:Destroy()
            end

            local ElemIdx = table.find(Groupbox.DependencyBoxes, Depbox)
            if ElemIdx then
                table.remove(Groupbox.DependencyBoxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, Depbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                BackgroundTransparency = 0.6,
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
            if Groupbox.RefreshBoxHolderLayout then
                Groupbox.RefreshBoxHolderLayout()
            end
        end

        function DepGroupbox:Update(CancelSearch)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox :: any)

        function DepGroupbox:Destroy()
            DepGroupbox.Destroyed = true

            if DepGroupbox.Connections then
                for _, Connection in DepGroupbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in DepGroupbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in DepGroupbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepGroupboxContainer then
                DepGroupboxContainer:Destroy()
            end

            local ElemIdx = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if ElemIdx then
                table.remove(Tab.DependencyGroupboxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, DepGroupbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return DepGroupbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()

    if Library.AllFontEnabled then
        Library:SetAllFont(true, FontFace)
    end

    for _, Label in Labels do
        if Label.DoesWrap then
            Label:Display()
            Label.Parent:Resize()
        end
    end

    if Library.Window and Library.Window.RefreshTitleSize then
        Library.Window:RefreshTitleSize()
    end
end

--// "All Font": apply the chosen font to every text object in the game \\--
Library.AllFontEnabled = false
local AllFontOriginals = setmetatable({}, { __mode = "k" }) -- text object -> its original Font
local AllFontConnections = {}
local AllFontWatchers = setmetatable({}, { __mode = "k" }) -- text object -> FontFace change listener
local AllFontFace
local AllFontUnloadHooked = false

-- top-level GUIs that "All Font" never touches (Roblox core UI that is created later than the snapshot)
Library.AllFontIgnore = {
    "RobloxGui", "TopBarApp", "TopBar", "ExperienceChat", "Chat", "BubbleChat", "PlayerList",
    "ThemeProvider", "PurchasePromptApp", "RobloxPromptGui", "RobloxNetworkPauseNotification",
    "InGameMenu", "InGameMenuApp", "FoundationOverlay", "ControlGui", "RobloxLoadingGui", "ScreenshotHud",
    "ModalGui", "ChatBar", "Backpack",
}

-- Only objects that currently use a normal built-in text font are changed.
-- Icon fonts (the menu / chat / settings buttons draw their icon from a word like "menu")
-- and custom fonts are left alone, otherwise the icon turns into its plain name.
local function IsPlainTextFont(Face): boolean
    local Ok, Family = pcall(function()
        return Face.Family
    end)
    if not Ok or typeof(Family) ~= "string" then
        return false
    end

    local Lower = Family:lower()
    local BuiltIn = "rbxasset://fonts/families/"
    if Lower:sub(1, #BuiltIn) ~= BuiltIn then
        return false
    end
    for _, Word in { "icon", "symbol", "glyph", "awesome", "material", "emoji" } do
        if Lower:find(Word, 1, true) then
            return false
        end
    end
    return true
end

local function IsIgnoredByAllFont(Object)
    -- climb to the GUI directly under CoreGui / PlayerGui that contains this object
    local Top = Object
    while Top.Parent do
        local ParentClass = Top.Parent.ClassName
        if ParentClass == "CoreGui" or ParentClass == "PlayerGui" then
            break
        end
        Top = Top.Parent
    end
    local Container = Top.Parent
    if not Container then
        return false
    end
    if table.find(Library.AllFontIgnore, Top.Name) then
        return true
    end
    -- anything that was already in CoreGui before this library loaded is Roblox's own UI
    if Container.ClassName == "CoreGui" and CoreGuiBaseline[Top] then
        return true
    end
    return false
end

local function ApplyAllFont(Object)
    if not (Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox")) then
        return
    end
    -- leave the library's own interface alone (it already follows Library:SetFont)
    if ScreenGui and Object:IsDescendantOf(ScreenGui) then
        return
    end
    -- and leave Roblox's own UI (menu button, settings, chat, top bar) alone
    if IsIgnoredByAllFont(Object) then
        return
    end
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui and Object:IsDescendantOf(Library.ActiveLoading.ScreenGui) then
        return
    end

    local Ok, Current = pcall(function()
        return Object.FontFace
    end)
    if not Ok or not IsPlainTextFont(Current) then
        return
    end
    if AllFontOriginals[Object] == nil then
        AllFontOriginals[Object] = Current
    end
    pcall(function()
        Object.FontFace = AllFontFace
    end)

    -- if a script sets its own font later (common right after creating a label), put ours back
    if not AllFontWatchers[Object] then
        local Ok2, Signal = pcall(function()
            return Object:GetPropertyChangedSignal("FontFace")
        end)
        if Ok2 then
            AllFontWatchers[Object] = Signal:Connect(function()
                if not Library.AllFontEnabled then
                    return
                end
                local OkNow, Now = pcall(function()
                    return Object.FontFace
                end)
                if OkNow and Now ~= AllFontFace and IsPlainTextFont(Now) then
                    AllFontOriginals[Object] = Now
                    task.defer(function()
                        if Library.AllFontEnabled then
                            pcall(function()
                                Object.FontFace = AllFontFace
                            end)
                        end
                    end)
                end
            end)
        end
    end
end

function Library:SetAllFont(Enabled: boolean, FontFace: (Font | EnumItem)?)
    FontFace = FontFace or Library.Scheme.Font
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    for _, Connection in AllFontConnections do
        Connection:Disconnect()
    end
    table.clear(AllFontConnections)

    if not Enabled then
        Library.AllFontEnabled = false
        for _, Watcher in AllFontWatchers do
            Watcher:Disconnect()
        end
        table.clear(AllFontWatchers)
        for Object, Original in AllFontOriginals do
            if Object.Parent then
                pcall(function()
                    Object.FontFace = Original
                end)
            end
        end
        table.clear(AllFontOriginals)
        return
    end

    Library.AllFontEnabled = true
    AllFontFace = FontFace

    for Object, Original in AllFontOriginals do
        if Object.Parent and (IsIgnoredByAllFont(Object) or not IsPlainTextFont(Original)) then
            pcall(function()
                Object.FontFace = Original
            end)
            AllFontOriginals[Object] = nil
        end
    end

    if not AllFontUnloadHooked then
        AllFontUnloadHooked = true
        table.insert(Library.UnloadSignals, function()
            Library:SetAllFont(false)
        end)
    end

    local Roots = { workspace }
    local PlayerGui = pcall(function() return Players.LocalPlayer end) and Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if PlayerGui then
        table.insert(Roots, PlayerGui)
    end
    local OkCore, CoreGuiService = pcall(function()
        return cloneref(game:GetService("CoreGui"))
    end)
    if OkCore and CoreGuiService then
        table.insert(Roots, CoreGuiService)
    end
    local OkHui, HiddenGui = pcall(function()
        return gethui and gethui()
    end)
    if OkHui and typeof(HiddenGui) == "Instance" and HiddenGui ~= CoreGuiService then
        table.insert(Roots, HiddenGui)
    end

    for _, Root in Roots do
        -- text that appears later (new menus, chat, billboards...) gets the font too
        table.insert(AllFontConnections, Root.DescendantAdded:Connect(function(Descendant)
            if Library.AllFontEnabled then
                ApplyAllFont(Descendant)
            end
        end))

        -- text that already exists (scanned in slices so big games don't freeze)
        task.spawn(function()
            local Count = 0
            for _, Descendant in Root:GetDescendants() do
                if not Library.AllFontEnabled or AllFontFace ~= FontFace then
                    return
                end
                ApplyAllFont(Descendant)
                Count += 1
                if Count % 800 == 0 then
                    task.wait()
                end
            end
        end)
    end
end

--// Font selector (Settings tab) \\--
Library.AutoFontSelector = false -- (ThemeManager's "Font Face" dropdown is used instead) set true to add a "Font" group box to every tab whose name contains "setting"
Library.FontChoices = {
    { Name = "Press Start 2P", Face = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular) },
    { Name = "Grenze Gotisch", Face = Font.new("rbxasset://fonts/families/GrenzeGotisch.json", Enum.FontWeight.Regular) },
}

function Library:AddFontSelector(Groupbox)
    assert(Groupbox and Groupbox.AddDropdown, "Library:AddFontSelector expects a groupbox")

    local BaseFont = Library.FontBase or Library.Scheme.Font
    Library.FontBase = BaseFont

    local Names, Faces = {}, {}
    for _, Choice in Library.FontChoices do
        table.insert(Names, Choice.Name)
        Faces[Choice.Name] = Choice.Face
    end

    return Groupbox:AddDropdown("UIFontSelector", {
        Text = "Font",
        Values = Names,
        AllowNull = true, -- deselect = back to the original font
        Tooltip = "Pick a UI font (deselect to restore the default)",
        Callback = function(Value)
            Library:SetFont(Faces[Value] or BaseFont)
        end,
    })
end

function Library:SetBackgroundImage(Image: string | number)
    assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected string/number got " .. typeof(Image))

    Library.Scheme.BackgroundImage = Image
    if Library.Window then
        Library.Window:SetBackgroundImage(Image)
    end

    Library:UpdateColorsUsingRegistry()
end

function Library:UpdateNotificationPositions(Snap: boolean?)
    local IsLeft = Library.NotifySide:lower() == "left"
    local XScale = IsLeft and 0 or 1
    local RunningY = 0

    for _, FakeBackground in NotifyOrder do
        local Data = Library.Notifications[FakeBackground]
        if not (Data and FakeBackground.Parent) then continue end

        local Target = UDim2.new(XScale, 0, 0, RunningY)
        if Snap or not Data.PositionInitialized then
            FakeBackground.Position = Target
            Data.PositionInitialized = true

        elseif FakeBackground.Position ~= Target then
            TweenService:Create(FakeBackground, Library.NotifyTweenInfo, {
                Position = Target,
            }):Play()
        end

        RunningY = RunningY + FakeBackground.AbsoluteSize.Y / Library.DPIScale + 8
    end
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    local IsLeft = Side:lower() == "left"
    if IsLeft then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
    end

    for FakeBackground in Library.Notifications do
        if not (FakeBackground and FakeBackground.Parent) then continue end
        FakeBackground.AnchorPoint = if IsLeft then Vector2.new(0, 0) else Vector2.new(1, 0)
    end

    if Library.UpdateNotificationPositions then
        Library:UpdateNotificationPositions(true)
    end
end

function Library:Notify(...)
    local Data = {}
    local Info = select(1, ...)

    if typeof(Info) == "table" then
        Data.Title = tostring(Info.Title)
        Data.TitleColor = Info.TitleColor

        Data.Description = tostring(Info.Description)
        Data.DescriptionColor = Info.DescriptionColor

        Data.Time = Info.Time or 5
        Data.SoundId = Info.SoundId
        Data.Steps = Info.Steps
        Data.Persist = Info.Persist

        Data.Callback = typeof(Info.Callback) == "function" and Info.Callback or nil
        Data.Closable = Info.Closable == true

        Data.Icon = Info.Icon
        Data.BigIcon = Info.BigIcon
        Data.IconColor = Info.IconColor

        Data.Volume = tonumber(Info.Volume) or 3
    else
        Data.Description = tostring(Info)
        Data.Time = select(2, ...) or 5
        Data.SoundId = select(3, ...)
        Data.Volume = select(4, ...) or 3
    end
    Data.Destroyed = false

    local DeletedInstance = false
    local DeleteConnection = nil
    if typeof(Data.Time) == "Instance" then
        DeleteConnection = Data.Time.Destroying:Connect(function()
            DeletedInstance = true

            DeleteConnection:Disconnect()
            DeleteConnection = nil
        end)
    end

    local FakeBackground = New("Frame", {
        AnchorPoint = Library.NotifySide:lower() == "left" and Vector2.new(0, 0) or Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 0),
        Visible = false,
        Parent = NotificationArea,
    })

    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.12,
        Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, 0) or UDim2.new(1, 8, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 5,
        Parent = FakeBackground,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local ContentHolder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = ContentHolder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = ContentHolder,
    })

    local CloseButton
    if Data.Closable then
        CloseButton = Library:CreateIcon(CloseIcon, {
            AnchorPoint = Vector2.new(1, 0),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -8, 0, 8),
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 6,
            Parent = Holder,
        }, true)

        CloseButton.MouseEnter:Connect(function()
            TweenIcon(CloseButton, { ImageTransparency = 0 })
        end)
        CloseButton.MouseLeave:Connect(function()
            TweenIcon(CloseButton, { ImageTransparency = 0.5 })
        end)
        CloseButton.MouseButton1Click:Connect(function()
            Data:Destroy("user")
        end)
    end

    local ContentContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentHolder,
    })

    if Data.BigIcon then
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ContentContainer,
        })
    end

    local BigIconLabel
    if Data.BigIcon then
        local ParsedIcon = Library:GetCustomIcon(Data.BigIcon)
        if ParsedIcon then
            BigIconLabel = Library:CreateIcon(ParsedIcon, {
                Size = UDim2.fromOffset(24, 24),
                ImageColor3 = Data.IconColor or "AccentColor",
                Parent = ContentContainer,
            })
        end
    end

    local TextContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentContainer,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = TextContainer,
    })

    local TitleContainer
    if Data.Title then
        TitleContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0),
            Parent = TextContainer,
        })
    end

    local IconLabel
    if Data.Icon and TitleContainer then
        local ParsedIcon = Library:GetCustomIcon(Data.Icon)
        if ParsedIcon then
            IconLabel = Library:CreateIcon(ParsedIcon, {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(15, 15),
                ImageColor3 = Data.IconColor or "FontColor",
                Parent = TitleContainer,
            })
        end
    end

    local Title
    local Desc
    local TitleX = 0
    local DescX = 0

    local TimerFill

    if Data.Title then
        Title = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (IconLabel and 21 or 0), 0.5, 0),
            Size = UDim2.fromScale(0, 0),
            Text = Data.Title,
            TextColor3 = Data.TitleColor or "FontColor",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Parent = TitleContainer,
        })
    end

    if Data.Description then
        Desc = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Text = Data.Description,
            TextColor3 = Data.DescriptionColor or "FontColor",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = TextContainer,
        })
    end

    function Data:Resize()
        local ExtraWidth = BigIconLabel and 32 or 0
        local IconWidth = IconLabel and 21 or 0
        local CloseWidth = Data.Closable and 20 or 0
        local MaxTextWidth = math.max(
            40,
            (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth - CloseWidth
        )

        if Title then
            local X, Y = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, MaxTextWidth - IconWidth)
            Title.Size = UDim2.fromOffset(X, Y)
            TitleX = X + IconWidth
            TitleContainer.Size = UDim2.fromOffset(TitleX, math.max(Y, IconLabel and 16 or 0))
        end

        if Desc then
            local X, Y = Library:GetTextBounds(Desc.Text, Desc.FontFace, Desc.TextSize, MaxTextWidth)
            Desc.Size = UDim2.fromOffset(X, Y)
            DescX = X
        end

        FakeBackground.Size = UDim2.fromOffset(math.max(TitleX, DescX) + 24 + ExtraWidth + CloseWidth, 0)

        if Library.Notifications[FakeBackground] then
            task.defer(function()
                if Data.Destroyed or not FakeBackground.Parent then
                    return
                end

                if FakeBackground.AbsoluteSize.Y <= 0 then
                    task.defer(function()
                        if Data.Destroyed or not FakeBackground.Parent then
                            return
                        end

                        Library:UpdateNotificationPositions(true)
                    end)
                    return
                end

                Library:UpdateNotificationPositions(true)
            end)
        end
    end

    function Data:ChangeTitle(Text)
        if Title then
            Data.Title = tostring(Text)
            Title.Text = Data.Title
            Data:Resize()
        end
    end

    function Data:ChangeDescription(Text)
        if Desc then
            Data.Description = tostring(Text)
            Desc.Text = Data.Description
            Data:Resize()
        end
    end

    function Data:ChangeStep(NewStep)
        if TimerFill and Data.Steps then
            NewStep = math.clamp(NewStep or 0, 0, Data.Steps)
            TimerFill.Size = UDim2.fromScale(NewStep / Data.Steps, 1)
        end
    end

    function Data:Destroy(Reason)
        if Data.Destroyed then
            return
        end

        Reason = Reason or "script"
        Data.Destroyed = true

        if Data.Callback then
            pcall(Data.Callback, Reason)
        end

        if typeof(Data.Time) == "Instance" then
            pcall(Data.Time.Destroy, Data.Time)
        end

        if DeleteConnection then
            DeleteConnection:Disconnect()
        end

        if FakeBackground then
            local Idx = table.find(NotifyOrder, FakeBackground)
            if Idx then
                table.remove(NotifyOrder, Idx)
            end
        end

        Library:UpdateNotificationPositions()

        TweenService
            :Create(Holder, Library.NotifyTweenInfo, {
                Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
            })
            :Play()

        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[FakeBackground] = nil
            FakeBackground:Destroy()
        end)
    end

    local TimerHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = (Data.Persist ~= true and typeof(Data.Time) ~= "Instance") or typeof(Data.Steps) == "number",
        Parent = ContentHolder,
    })
    local TimerBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.6,
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = TimerHolder,
    })
    TimerFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = TimerBar,
    })

    if typeof(Data.Time) == "Instance" then
        TimerFill.Size = UDim2.fromScale(0, 1)
    end
    if Data.SoundId then
        local SoundId = Data.SoundId
        if typeof(SoundId) == "number" then
            SoundId = string.format("rbxassetid://%d", SoundId)
        end

        New("Sound", {
            SoundId = SoundId,
            Volume = tonumber(Data.Volume) or 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    Data.Holder = Holder

    table.insert(NotifyOrder, FakeBackground)
    Library.Notifications[FakeBackground] = Data

    Data:Resize()

    FakeBackground.Visible = true
    TweenService:Create(Holder, Library.NotifyTweenInfo, {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.defer(function()
        if not Data.Destroyed then
            Library:UpdateNotificationPositions(true)
        end
    end)

    task.delay(Library.NotifyTweenInfo.Time, function()
        if Data.Persist then
            return
        elseif typeof(Data.Time) == "Instance" then
            repeat
                task.wait()
            until DeletedInstance or Data.Destroyed
        else
            TweenService
                :Create(TimerFill, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromScale(0, 1),
                })
                :Play()
            task.wait(Data.Time)
        end

        Data:Destroy("timer")
    end)

    return Data
end

Library.KaitenHikariBase64 = "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"

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Vector2.new(math.min(WindowInfo.MinContainerWidth, MaxX), Library.OriginalMinSize.Y)

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font :: any)
    end
    WindowInfo.CornerRadius = math.min(WindowInfo.CornerRadius, 20)

    local TabButtonsStyle = WindowInfo.TabButtonsStyle

    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64 + TabButtonsStyle.Padding * 2, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.CompactWidthActivation)
    WindowInfo.SnapDistance = math.max(0, WindowInfo.SnapDistance)
    WindowInfo.SnapMargin = math.max(0, WindowInfo.SnapMargin)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch

    Library.Animations = WindowInfo.Animations
    Library.TabTransitionInfo = TweenInfo.new(
        math.max(0, WindowInfo.TabTransitionTime or 0.22),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    Library.TabSwipeOffset = math.max(1, WindowInfo.TabSwipeOffset or 26)
    Library.TabSwipeFrom = WindowInfo.TabSwipeFrom or "right"

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local HasBackgroundImage = false
    local BottomBackground
    local BottomBackgroundCorner
    local FooterLabel
    local TopBar
    local WindowSnapConfig = {
        Enabled = WindowInfo.Snapping,
        Distance = WindowInfo.SnapDistance,
        Margin = WindowInfo.SnapMargin,
        AvoidCoreGui = WindowInfo.SnapAvoidCoreGui,
    }

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth
    local RefreshWindowTitleSize

    do
        local KeybindFrame, KeybindContainer, _, KeybindDivider, KeybindLabelPadding = Library:AddDraggableMenu("Keybinds")
        KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        KeybindFrame.Visible = false
        KeybindLabelPadding.PaddingRight = UDim.new(0, 34)

        local HeaderButtons = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -8, 0, 17),
            Size = UDim2.fromOffset(0, 22),
            ZIndex = 2,
            Parent = KeybindFrame,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
            Parent = HeaderButtons,
        })

        local SettingsButton = Library:CreateIcon(SettingsIcon, {
            ImageColor3 = "FontColor",
            LayoutOrder = 1,
            Size = UDim2.fromOffset(18, 18),
            Visible = false,
            ZIndex = 2,
            Parent = HeaderButtons,
        }, true)

        local CollapseButton = Library:CreateIcon(ArrowIcon, {
            ImageColor3 = "FontColor",
            LayoutOrder = 2,
            Rotation = 180,
            Size = UDim2.fromOffset(18, 18),
            ZIndex = 2,
            Parent = HeaderButtons,
        }, true)

        local SettingsFrame, SettingsContainer, _, _, SettingsLabelPadding = Library:AddDraggableMenu("Visible Keybinds")
        SettingsFrame.Visible = false
        SettingsLabelPadding.PaddingRight = UDim.new(0, 34)

        local CloseSettingsButton = Library:CreateIcon(CloseIcon, {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            Position = UDim2.new(1, -8, 0, 17),
            Size = UDim2.fromOffset(18, 18),
            ZIndex = 2,
            Parent = SettingsFrame,
        }, true)

        local KeybindMenu = {
            VisibilityControl = false,
            Collapsed = false,
            SettingsOpen = false,
            Frame = KeybindFrame,
            Container = KeybindContainer,
            SettingsFrame = SettingsFrame,
            SettingsContainer = SettingsContainer,
        }

        function KeybindMenu:RefreshSettings()
            for _, Child in SettingsContainer:GetChildren() do
                if Child:IsA("GuiObject") and not Child:IsA("UIListLayout") and not Child:IsA("UIPadding") then
                    Child:Destroy()
                end
            end

            for Idx, Option in Options do
                if Option.Type ~= "KeyPicker" or Option.NoUI == true then
                    continue
                end

                local Holder = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = "",
                    Parent = SettingsContainer,
                })

                local Visible = Option.MenuVisible ~= false
                New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(22, 0),
                    Size = UDim2.fromScale(0, 1),
                    Text = ("[%s] %s (%s)"):format(
                        Option.DisplayValue or Option.Value or "None",
                        Option.Text or tostring(Idx),
                        Option.Mode or "Toggle"
                    ),
                    TextSize = 14,
                    TextTransparency = Visible and 0 or 0.5,
                    Parent = Holder,
                })

                local Checkbox = New("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0.5,
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.fromOffset(14, 14),
                    Parent = Holder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                        Parent = Checkbox,
                    })
                )
                New("UIStroke", {
                    Color = "OutlineColor",
                    Parent = Checkbox,
                })

                Library:CreateIcon(CheckIcon, {
                    ImageColor3 = "FontColor",
                    ImageTransparency = Visible and 0 or 1,
                    Position = UDim2.fromOffset(2, 2),
                    Size = UDim2.new(1, -4, 1, -4),
                    Parent = Checkbox,
                })

                Holder.MouseButton1Click:Connect(function()
                    local Picker = Options[Idx]
                    if not (Picker and Picker.Type == "KeyPicker" and Picker.SetMenuVisibility) then
                        return
                    end

                    Picker:SetMenuVisibility(Picker.MenuVisible == false)
                end)
            end
        end

        function KeybindMenu:SetCollapsed(Collapsed: boolean)
            Collapsed = Collapsed == true
            KeybindMenu.Collapsed = Collapsed

            KeybindContainer.Visible = not Collapsed
            KeybindDivider.Visible = not Collapsed

            if Collapsed then
                local Width = math.max(160, KeybindFrame.AbsoluteSize.X / Library.DPIScale)
                KeybindFrame.AutomaticSize = Enum.AutomaticSize.None
                KeybindFrame.Size = UDim2.fromOffset(Width, 34)
                CollapseButton.Rotation = 0
            else
                KeybindFrame.AutomaticSize = Enum.AutomaticSize.XY
                KeybindFrame.Size = UDim2.fromOffset(0, 0)
                CollapseButton.Rotation = 180
            end
        end

        function KeybindMenu:ToggleCollapsed()
            KeybindMenu:SetCollapsed(not KeybindMenu.Collapsed)
        end

        function KeybindMenu:SetSettingsOpen(Open: boolean)
            Open = Open == true
            if Open and not KeybindMenu.VisibilityControl then
                return
            end

            KeybindMenu.SettingsOpen = Open
            SettingsFrame.Visible = Open

            if Open then
                KeybindMenu:RefreshSettings()

                local Bounds = Floats.AbsoluteSize
                local Pos = KeybindFrame.AbsolutePosition - Floats.AbsolutePosition
                local Size = KeybindFrame.AbsoluteSize
                local SettingsSize = SettingsFrame.AbsoluteSize

                local X = Pos.X + Size.X + 8
                if X + SettingsSize.X > Bounds.X then
                    X = Pos.X - SettingsSize.X - 8
                end

                SettingsFrame.Position = UDim2.fromOffset(
                    math.clamp(X, 0, math.max(0, Bounds.X - SettingsSize.X)),
                    math.clamp(Pos.Y, 0, math.max(0, Bounds.Y - SettingsSize.Y))
                )
            end
        end

        function KeybindMenu:ToggleSettings()
            KeybindMenu:SetSettingsOpen(not KeybindMenu.SettingsOpen)
        end

        function KeybindMenu:SetVisibilityControl(Enabled: boolean)
            Enabled = Enabled == true
            KeybindMenu.VisibilityControl = Enabled
            SettingsButton.Visible = Enabled
            KeybindLabelPadding.PaddingRight = UDim.new(0, Enabled and 56 or 34)

            if not Enabled then
                KeybindMenu:SetSettingsOpen(false)
            end
        end

        function KeybindMenu:Destroy()
            local DraggableIndex = table.find(Library.DraggableElements, SettingsFrame)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end

            SettingsFrame:Destroy()
            KeybindMenu.SettingsFrame = nil
            KeybindMenu.SettingsContainer = nil
            KeybindMenu.SettingsOpen = false
            Library.KeybindMenu = nil
        end

        SettingsButton.MouseButton1Click:Connect(function()
            KeybindMenu:ToggleSettings()
        end)
        CollapseButton.MouseButton1Click:Connect(function()
            KeybindMenu:ToggleCollapsed()
        end)
        CloseSettingsButton.MouseButton1Click:Connect(function()
            KeybindMenu:SetSettingsOpen(false)
        end)

        Library.KeybindFrame = KeybindFrame
        Library.KeybindContainer = KeybindContainer
        Library.KeybindMenu = KeybindMenu

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            BackgroundTransparency = 0.88,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)

        -- glass body: bright from the top, deeper toward the bottom
        New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 168, 205)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0.08),
            }),
            Rotation = 80,
            Parent = MainFrame,
        })

        -- inner lens rim: a second thin highlight just inside the edge (fake refraction at the border)
        local LensRim = New("Frame", {
            Active = false,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(4, 4),
            Size = UDim2.new(1, -8, 1, -8),
            Parent = MainFrame,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, math.max(0, WindowInfo.CornerRadius - 4)),
            Parent = LensRim,
        })
        local LensStroke = New("UIStroke", {
            Color = Color3.new(1, 1, 1),
            Thickness = 1.25,
            Transparency = 0.4,
            Parent = LensRim,
        })
        New("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(0.25, 0.85),
                NumberSequenceKeypoint.new(0.75, 0.85),
                NumberSequenceKeypoint.new(1, 0.25),
            }),
            Rotation = 45,
            Parent = LensStroke,
        })

        -- top sheen: soft light reflected on the upper part of the glass
        local TopSheen = New("Frame", {
            Active = false,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0,
            Position = UDim2.fromOffset(5, 5),
            Size = UDim2.new(1, -10, 0.32, 0),
            Parent = MainFrame,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, math.max(0, WindowInfo.CornerRadius - 5)),
            Parent = TopSheen,
        })
        New("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.9),
                NumberSequenceKeypoint.new(0.6, 0.975),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Rotation = 90,
            Parent = TopSheen,
        })

        -- bottom depth: slight shade gathering at the lower edge (glass thickness)
        local BottomShade = New("Frame", {
            Active = false,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.fromRGB(5, 10, 25),
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 5, 1, -5),
            Size = UDim2.new(1, -10, 0.28, 0),
            Parent = MainFrame,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, math.max(0, WindowInfo.CornerRadius - 5)),
            Parent = BottomShade,
        })
        New("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0.86),
            }),
            Rotation = 90,
            Parent = BottomShade,
        })

        -- floating drop shadow (lifts the window off the scene)
        local DropShadow = New("ImageLabel", {
            Active = false,
            BackgroundTransparency = 1,
            Image = "rbxassetid://1316045217",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.55,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(10, 10, 118, 118),
            ZIndex = 0,
            Visible = false,
            Parent = ScreenGui,
        })
        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not (DropShadow and MainFrame and MainFrame.Parent) then
                return
            end
            DropShadow.Visible = MainFrame.Visible
            if MainFrame.Visible then
                DropShadow.Position = UDim2.fromOffset(MainFrame.AbsolutePosition.X - 28, MainFrame.AbsolutePosition.Y - 10)
                DropShadow.Size = UDim2.fromOffset(MainFrame.AbsoluteSize.X + 56, MainFrame.AbsoluteSize.Y + 56)
            end
        end))

        -- frosted backdrop: blur the 3D world behind the (translucent) window while it is open
        if Library.GlassBlur then
            local Lighting = cloneref(game:GetService("Lighting"))
            local GlassBlurEffect = Instance.new("BlurEffect")
            GlassBlurEffect.Name = "ObsidianGlassBlur"
            GlassBlurEffect.Size = 0
            GlassBlurEffect.Parent = Lighting

            Library:GiveSignal(RunService.RenderStepped:Connect(function(Delta)
                if not (MainFrame and MainFrame.Parent) then
                    return
                end
                local Target = MainFrame.Visible and Library.GlassBlurSize or 0
                GlassBlurEffect.Size += (Target - GlassBlurEffect.Size) * math.min(1, Delta * 10)
            end))
            table.insert(Library.UnloadSignals, function()
                GlassBlurEffect:Destroy()
            end)
        end

        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            Parent = MainFrame,
            ZIndex = 2
        })

        local BackgroundIcon = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        HasBackgroundImage = BackgroundIcon ~= nil
        BackgroundImage = New("ImageLabel", {
            Active = false,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Stretch,
            ZIndex = Overlay.ZIndex + 1,
            BackgroundTransparency = 1,
            ImageTransparency = 0.75,
            Visible = false,
            Parent = ScreenGui,
        })
        FillInstance(ImageContent(BackgroundIcon), BackgroundImage)

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BackgroundImage,
            })
        )

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not (BackgroundImage and MainFrame) then
                return
            end

            local ShouldShow = HasBackgroundImage and MainFrame.Visible
            BackgroundImage.Visible = ShouldShow

            if not ShouldShow then
                return
            end

            BackgroundImage.Position = UDim2.fromOffset(
                MainFrame.AbsolutePosition.X,
                MainFrame.AbsolutePosition.Y
            )
            BackgroundImage.Size = UDim2.fromOffset(
                MainFrame.AbsoluteSize.X,
                MainFrame.AbsoluteSize.Y
            )
        end))

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true, WindowSnapConfig)

        --// Title \\--
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, InitialLeftWidth, 1, 0),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            WindowIcon = Library:CreateIcon(Library:GetCustomIcon(WindowInfo.Icon), {
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        WindowTitle = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0),
            Text = WindowInfo.Title,
            TextSize = 20,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = TitleHolder,
        })

        RefreshWindowTitleSize = function()
            local IconWidth = 0
            if WindowIcon and WindowIcon.Visible then
                IconWidth = WindowIcon.Size.X.Offset + 6
            end

            local MaxWidth = math.max(0, (TitleHolder.AbsoluteSize.X / Library.DPIScale) - IconWidth - 12)
            local NaturalWidth = Library:GetTextBounds(WindowTitle.Text, Library.Scheme.Font, WindowTitle.TextSize)
            WindowTitle.Size = UDim2.new(0, math.min(NaturalWidth, MaxWidth), 1, 0)
        end
        RefreshWindowTitleSize()

        --// Top Right Bar \\--
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -49, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 57 - 1, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(WindowInfo.DisableSearch and 1 or 0.5, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.5,
            PlaceholderText = "Search",
            Size = WindowInfo.SearchbarSize,
            TextScaled = true,
            Visible = not (WindowInfo.DisableSearch or false),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        local SearchBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        Library:GiveSignal(SearchBox.Focused:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "AccentColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        Library:GiveSignal(SearchBox.FocusLost:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "OutlineColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            Library:CreateIcon(SearchIcon, {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
        end

        if MoveIcon then
            Library:CreateIcon(MoveIcon, {
                AnchorPoint = Vector2.new(1, 0.5),
                ImageColor3 = "OutlineColor",
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(28, 28),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = TopBar,
            })
        end

        --// Bottom Bar \\--
        local BottomClip = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 3,
            Parent = MainFrame,
        })

        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, math.max(20, WindowInfo.CornerRadius * 2)),
            ZIndex = 3,
            Parent = BottomClip,
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 3,
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 4,
            Parent = MainFrame,
        })
        BottomBackgroundCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
            BottomRightRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = BottomBackground,
        })

        --// Footer \\-
        FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = WindowInfo.Footer,
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = BottomBar,
        })

        --// Resize Button \\--
        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = BottomBar,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
            end)
        end

        Library:CreateIcon(ResizeIcon, {
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = ResizeButton,
        })

        --// Tabs \\--
        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.6,
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 49),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            Size = UDim2.new(0, InitialLeftWidth, 1, -70),
            Parent = MainFrame,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, TabButtonsStyle.Gap),
            Parent = Tabs,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, TabButtonsStyle.Padding),
            PaddingLeft = UDim.new(0, TabButtonsStyle.Padding),
            PaddingRight = UDim.new(0, TabButtonsStyle.Padding),
            PaddingTop = UDim.new(0, TabButtonsStyle.Padding),
            Parent = Tabs,
        })

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            BackgroundTransparency = 0.78,
            ClipsDescendants = true,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 49),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 12),
            Parent = Container,
        })

        local CB = WindowInfo.ContentBackground
        if typeof(CB) == "table" and CB.Enabled ~= false then
            local Source = CB.Image
            local Builtin = Source == nil
            if Builtin then
                -- built-in rotating light: written once to the executor workspace, then loaded as a custom asset
                CB.Rotate = if CB.Rotate == nil then true else CB.Rotate
                CB.Transparency = CB.Transparency or 0.55
                local FileName = "kaitenhikari.png"
                if writefile and isfile and getcustomasset then
                    if not isfile(FileName) then
                        local Decode = (crypt and (crypt.base64decode or (crypt.base64 and crypt.base64.decode)))
                            or base64decode
                            or base64_decode
                            or (base64 and base64.decode)
                        if Decode then
                            pcall(function()
                                writefile(FileName, Decode(Library.KaitenHikariBase64))
                            end)
                        end
                    end
                    if isfile(FileName) then
                        local Ok, Asset = pcall(getcustomasset, FileName)
                        if Ok then
                            Source = Asset
                        end
                    end
                end
            elseif tonumber(Source) then
                Source = "rbxassetid://" .. tostring(Source)
            elseif typeof(Source) == "string" and getcustomasset and isfile and isfile(Source) then
                local Ok, Asset = pcall(getcustomasset, Source)
                if Ok then
                    Source = Asset
                end
            end

            if Source or CB.Url then
                local Columns = math.max(1, CB.Columns or 1)
                local Rows = math.max(1, CB.Rows or 1)
                local Frames = math.clamp(CB.Frames or (Columns * Rows), 1, Columns * Rows)
                local FrameSize = CB.FrameSize or Vector2.new(256, 256)
                local FrameTime = 1 / math.max(1, CB.FPS or 12)
                local Animated = Frames > 1
                local RotationSpeed = if CB.Rotate then (CB.RotationSpeed or 20) else 0
                local Scale = CB.Scale or 1.1

                local ContentBackgroundImage = New("ImageLabel", {
                    Active = false,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = Source or "",
                    ImageTransparency = CB.Transparency or 0.3,
                    Name = "ContentBackground",
                    Position = UDim2.fromScale(0.5, 0.5),
                    ScaleType = if RotationSpeed ~= 0 then Enum.ScaleType.Fit else Enum.ScaleType.Crop,
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 0,
                    Parent = Container,
                })
                if RotationSpeed ~= 0 then
                    -- keep it square (relative to the container height) so it spins without distortion
                    ContentBackgroundImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
                    ContentBackgroundImage.Size = UDim2.fromScale(Scale, Scale)
                end
                if Animated then
                    ContentBackgroundImage.ImageRectSize = FrameSize
                end

                local Elapsed, Index = 0, 0
                Library:GiveSignal(RunService.RenderStepped:Connect(function(Delta)
                    if not MainFrame or not MainFrame.Visible then
                        return
                    end
                    if RotationSpeed ~= 0 then
                        ContentBackgroundImage.Rotation = (ContentBackgroundImage.Rotation + RotationSpeed * Delta) % 360
                    end
                    if not Animated then
                        return
                    end
                    Elapsed += Delta
                    if Elapsed < FrameTime then
                        return
                    end
                    Index = (Index + math.floor(Elapsed / FrameTime)) % Frames
                    Elapsed %= FrameTime
                    ContentBackgroundImage.ImageRectOffset =
                        Vector2.new((Index % Columns) * FrameSize.X, math.floor(Index / Columns) * FrameSize.Y)
                end))

                -- remote background: the built-in light above is shown immediately and is only
                -- replaced if the download works and the format is usable (otherwise it just stays)
                if typeof(CB.Url) == "string" and CB.Url ~= "" then
                    task.spawn(function()
                        local function Fail(Reason)
                            warn("[Library] ContentBackground.Url: " .. Reason .. " (using built-in background)")
                            pcall(function()
                                Library:Notify({
                                    Title = "Background",
                                    Description = Reason,
                                    Time = 6,
                                })
                            end)
                        end

                        if not (writefile and isfile and getcustomasset) then
                            return Fail("this executor has no writefile/getcustomasset")
                        end

                        local function Get(Url)
                            local Ok, Result = pcall(function()
                                return game:HttpGet(Url)
                            end)
                            if Ok and typeof(Result) == "string" and #Result > 16 then
                                return Result
                            end
                            local Request = request or http_request or (syn and syn.request) or (http and http.request)
                            if Request then
                                local Ok2, Response = pcall(Request, { Url = Url, Method = "GET" })
                                if Ok2 and typeof(Response) == "table" and Response.Body and #Response.Body > 16
                                    and (Response.StatusCode or 200) == 200 then
                                    return Response.Body
                                end
                            end
                        end

                        local Body = Get(CB.Url)
                        -- a file-hosting "download page" (html) instead of the file itself:
                        -- look inside for the real mp4/webm/png/jpg link and download that
                        if Body and Body:sub(1, 1) ~= "\137" and Body:find("<", 1, true) and Body:lower():find("<html", 1, true) then
                            local Direct
                            for Link in Body:gmatch("https?://[^%s\"'<>()]+") do
                                local Clean = Link:lower():gsub("[%?#].*$", "")
                                if Clean:match("%.mp4$") or Clean:match("%.webm$") or Clean:match("%.png$")
                                    or Clean:match("%.jpe?g$") then
                                    Direct = Link:gsub("&amp;", "&")
                                    break
                                end
                            end
                            Body = Direct and Get(Direct) or nil
                        end
                        if not Body then
                            return Fail("download failed")
                        end

                        local Head = Body:sub(1, 4)
                        local Ext
                        if Head == "\137PNG" then
                            Ext = "png"
                        elseif Head:sub(1, 3) == "\255\216\255" then
                            Ext = "jpg"
                        elseif Head == "\026\069\223\163" then
                            Ext = "webm"
                        elseif Body:sub(5, 8) == "ftyp" then
                            Ext = "mp4"
                        elseif Head == "GIF8" then
                            return Fail("GIF can't be played in Roblox - convert it to mp4/webm (or a sprite sheet png)")
                        else
                            return Fail("unsupported file type (use mp4, webm, png or jpg)")
                        end

                        local Hash = 0
                        for i = 1, #CB.Url do
                            Hash = (Hash * 31 + CB.Url:byte(i)) % 1000000007
                        end
                        local FileName = "glassui_bg_" .. Hash .. "." .. Ext
                        local Wrote = pcall(writefile, FileName, Body)
                        local OkAsset, Asset = pcall(getcustomasset, FileName)
                        if not (Wrote and OkAsset and Asset) then
                            return Fail("could not load the downloaded file")
                        end
                        if not (Container and Container.Parent) then
                            return
                        end

                        if Ext == "mp4" or Ext == "webm" then
                            local Video = New("VideoFrame", {
                                Active = false,
                                BackgroundTransparency = 1,
                                Looped = true,
                                Name = "ContentBackgroundVideo",
                                Size = UDim2.fromScale(1, 1),
                                Video = Asset,
                                Volume = 0,
                                ZIndex = 0,
                                Parent = Container,
                            })
                            -- dim overlay: videos can't be transparent, so darken instead (keeps text readable)
                            New("Frame", {
                                Active = false,
                                BackgroundColor3 = Color3.fromRGB(8, 12, 24),
                                BackgroundTransparency = CB.VideoDim or 0.45,
                                BorderSizePixel = 0,
                                Name = "ContentBackgroundDim",
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 0,
                                Parent = Container,
                            })
                            Video.Playing = MainFrame.Visible
                            Library:GiveSignal(MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                                if Video.Parent then
                                    Video.Playing = MainFrame.Visible
                                end
                            end))
                            ContentBackgroundImage.Visible = false
                            RotationSpeed, Animated = 0, false
                        else
                            -- static image or sprite sheet
                            RotationSpeed = if CB.Rotate ~= nil then RotationSpeed else 0
                            ContentBackgroundImage.Image = Asset
                            ContentBackgroundImage.ImageTransparency = CB.Transparency or 0.3
                            if RotationSpeed == 0 then
                                ContentBackgroundImage.Rotation = 0
                                ContentBackgroundImage.SizeConstraint = Enum.SizeConstraint.RelativeXY
                                ContentBackgroundImage.Size = UDim2.fromScale(1, 1)
                                ContentBackgroundImage.ScaleType = Enum.ScaleType.Crop
                            end
                            if Frames > 1 then
                                ContentBackgroundImage.ImageRectSize = FrameSize
                                Animated = true
                            else
                                ContentBackgroundImage.ImageRectSize = Vector2.zero
                                Animated = false
                            end
                        end
                    end)
                end
            end
        end

        Library.WindowContainer = Container
    end

    --// Window Table \\--
    local Window = {}
    local Fading = false

    local function SetUICorner(UICorner, Corner, HalfValue)
        local Current = UICorner[Corner]
        if Current.Offset == 0 and Current.Scale == 0 then
            return
        end

        UICorner[Corner] = HalfValue
    end

    function Window:ChangeTitle(title)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitle.Text = title
        WindowInfo.Title = title
        RefreshWindowTitleSize()
    end

    function Window:RefreshTitleSize()
        RefreshWindowTitleSize()
    end

    function Window:SetBackgroundImage(Image: string)
        local ValidIcon = false

        if typeof(Image) == "string" then
            local BackgroundIcon = Library:GetCustomIcon(Image)

            if BackgroundIcon then
                ValidIcon = true

                FillInstance(ImageContent(BackgroundIcon), BackgroundImage)
            elseif Image:match("http://") or Image:match("https://") then
                local RawFileName = Image:match("(.+)%..+$")
                local _, Domain = Image:match("^(https?://)([^/]+)");

                if RawFileName and Domain then
                    local Extention = string.sub(Image, #RawFileName + 1, #Image)
                    local FileNamePos = RawFileName:gsub("\\", "/"):find("/[^/]*$")
                    local FileName = FileNamePos and Image:sub(FileNamePos + 1) or nil

                    if FileName then
                        ValidIcon = true

                        local AssetName = Domain .. FileName
                        if #AssetName > 255 then
                            local NewLength = 255 - #Domain - #Extention
                            if NewLength < 0 then
                                AssetName = Domain .. Extention
                            else
                                AssetName = Domain .. string.sub(FileName:sub(1, #FileName - #Extention), 1, NewLength) .. Extention
                            end
                        end

                        if CustomImageManagerAssets[FileName] == nil then
                            CustomImageManager.AddAsset(FileName, 0, Image)
                        else
                            CustomImageManager.DownloadAsset(FileName, true)
                        end

                        FillInstance(ImageContent({ Url = CustomImageManager.GetAsset(FileName) }), BackgroundImage)
                    end
                end
            end
        end

        if not ValidIcon then
            FillInstance(ImageContent(nil), BackgroundImage)
        end

        HasBackgroundImage = ValidIcon
        WindowInfo.BackgroundImage = Image
    end

    function Window:SetFooter(Footer: string)
        assert(typeof(Footer) == "string", "Expected string for footer got: " .. typeof(Footer))

        FooterLabel.Text = Footer
        WindowInfo.Footer = Footer
    end

    function Window:SetAlwaysOnTop(Enabled: boolean)
        WindowInfo.AlwaysOnTop = Enabled == true
        SetAlwaysOnTop(Library.ScreenGui, WindowInfo.AlwaysOnTop)
    end

    function Window:SetSnapping(Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean?)
        WindowInfo.Snapping = Enabled == true
        WindowSnapConfig.Enabled = WindowInfo.Snapping

        if Distance then
            WindowInfo.SnapDistance = math.max(0, Distance)
            WindowSnapConfig.Distance = WindowInfo.SnapDistance
        end

        if Margin then
            WindowInfo.SnapMargin = math.max(0, Margin)
            WindowSnapConfig.Margin = WindowInfo.SnapMargin
        end

        if AvoidCoreGui ~= nil then
            WindowInfo.SnapAvoidCoreGui = AvoidCoreGui == true
            WindowSnapConfig.AvoidCoreGui = WindowInfo.SnapAvoidCoreGui
        end
    end

    function Window:SetCornerRadius(Radius: number)
        assert(typeof(Radius) == "number", "Expected number for Radius got: " .. typeof(Radius))
        Radius = math.min(Radius, 20)

        local RadiusHalf = UDim.new(0, Radius / 2)
        local RadiusUDim = UDim.new(0, Radius)
        local HalfCurrent = Library.CornerRadius / 2

        for _, UICorner in Library.Corners do
            if math.abs(UICorner.CornerRadius.Offset - HalfCurrent) < 0.001 then
                UICorner.CornerRadius = RadiusHalf
            else
                UICorner.CornerRadius = RadiusUDim
            end
        end

        for _, UICorner in Library.SpecificCorners do
            SetUICorner(UICorner, "TopRightRadius", RadiusHalf)
            SetUICorner(UICorner, "TopLeftRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomRightRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomLeftRadius", RadiusHalf)
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        if ResizeButton then
            ResizeButton.Position = UDim2.new(1, -Radius / 4, 0, 0)
        end
        if BottomBackgroundCorner then
            BottomBackground.Size = UDim2.new(1, 0, 0, math.max(20, Radius * 2))
            BottomBackgroundCorner.BottomLeftRadius = RadiusUDim
            BottomBackgroundCorner.BottomRightRadius = RadiusUDim
        end

        for _, Menu in Library.ContextMenus do
            if Menu.Destroyed then
                continue
            end

            if typeof(Menu.ActiveCallback) ~= "function" then
                continue
            end

            if not Menu.Active then
                local HolderActive = false
                for _, Other in Library.ContextMenus do
                    if Other == Menu then 
                        continue
                    end
   
                    if Other.Active and Other.Holder == Menu.Holder then
                        HolderActive = true
                        break
                    end
                end

                if HolderActive then
                    continue
                end

                Menu.ActiveCallback(false)
                continue
            end

            Menu.ActiveCallback(true)
        end

        for _, Option in Options do
            if Option.Type == "Dropdown" and Option.RefreshPool then
                Option:RefreshPool()
            end
        end

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
        end
    end

    function Window:SetAnimations(Animations: { [string]: boolean }?, TabTransitionTime: number?, TabSwipeOffset: number?, TabSwipeFrom: ("left" | "right" | "top" | "bottom" | string)?)
        if typeof(Animations) == "table" then
            WindowInfo.Animations = Animations
            Library.Animations = Animations
        end

        if typeof(TabTransitionTime) == "number" then
            local TweenInfo = TweenInfo.new(
                math.max(0, TabTransitionTime or 0.22),
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            WindowInfo.TabTransitionInfo = TweenInfo
            Library.TabTransitionInfo = TweenInfo
        end

        if typeof(TabSwipeOffset) == "number" then
            TabSwipeOffset = math.max(1, TabSwipeOffset)

            WindowInfo.TabSwipeOffset = TabSwipeOffset
            Library.TabSwipeOffset = TabSwipeOffset
        end

        if typeof(TabSwipeFrom) == "string" then
            TabSwipeFrom = string.lower(TabSwipeFrom)

            WindowInfo.TabSwipeFrom = TabSwipeFrom
            Library.TabSwipeFrom = TabSwipeFrom
        end
    end

    local function ApplyCompact()
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact
        if not WindowInfo.Icon then
            WindowIcon.Visible = IsCompact
        end

        for _, Button in Library.TabButtons do
            if not Button.Icon then
                continue
            end

            Button.Label.Visible = not IsCompact
            Button.Padding.PaddingBottom = UDim.new(0, IsCompact and 6 or 11)
            Button.Padding.PaddingLeft = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingRight = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingTop = UDim.new(0, IsCompact and 6 or 11)
            Button.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY
        end
    end

    function Window:IsSidebarCompacted()
        return IsCompact
    end

    function Window:SetCompact(State)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        Width = math.clamp(Width, 48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)

        DividerLine.Position = UDim2.fromOffset(Width, 0)

        TitleHolder.Size = UDim2.new(0, Width, 1, 0)
        RightWrapper.Size = UDim2.new(1, -Width - 57 - 1, 1, -16)
        Tabs.Size = UDim2.new(0, Width, 1, -70)
        Container.Size = UDim2.new(1, -Width - 1, 1, -70)

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        end
    
        RefreshWindowTitleSize()
        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:ShowTabInfo(Name, Description)
        CurrentTabLabel.Text = Name
        CurrentTabDescription.Text = Description

        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(0.5, 1)
        end
        CurrentTabInfo.Visible = true
    end

    function Window:HideTabInfo()
        CurrentTabInfo.Visible = false
        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(1, 1)
        end
    end

    function Window:AddTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer
        local TabLeft
        local TabRight

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })
            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = Library:CreateIcon(Icon, {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Connections = {},
            Destroyed = false,

            Window = Window,
            Button = TabButton,
            Container = TabContainer,
            Sides = {
                TabLeft,
                TabRight,
            },
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = "",
            },

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
        }

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(127, 0, 0),
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            Library:AddToRegistry(WarningBox, {
                BackgroundColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
                end
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)
            Library:AddToRegistry(WarningBoxOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
                end
            })
            Library:AddToRegistry(WarningBoxShadowOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
                end
            })

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })
            Library:AddToRegistry(WarningTitle, {
                TextColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
                end
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })
            Library:AddToRegistry(WarningStroke, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
                end
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = GetTextStrokeColor,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Handlers \\--
        function Tab:UpdateWarningBox(Info)
            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Library.Registry[WarningBox].BackgroundColor3()
            WarningBoxShadowOutline.Color = Library.Registry[WarningBoxShadowOutline].Color()
            WarningBoxOutline.Color = Library.Registry[WarningBoxOutline].Color()
            WarningTitle.TextColor3 = Library.Registry[WarningTitle].TextColor3()
            WarningStroke.Color = Library.Registry[WarningStroke].Color()
        end

        function Tab:RefreshSides()
            local Offset = WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0
            for _, Side in Tab.Sides do
                Side.Position = UDim2.new(Side.Position.X.Scale, 0, 0, Offset)
                Side.Size = UDim2.new(0.5, -3, 1, -Offset)
            end
        end

        function Tab:Resize(ResizeWarningBox: boolean?)
            if ResizeWarningBox then
                local MaximumSize = math.floor((TabContainer.AbsoluteSize.Y / Library.DPIScale) / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X / Library.DPIScale
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        local function AddTabbox(self, Info)
            Info = Library:Validate(Info, Templates.Tabbox)
            local ParentObj = self
            local IsNested = ParentObj.Type == "Groupbox" or ParentObj.Type == "SubTab"

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = if IsNested then ParentObj.Container else (Info.Side == 1 and TabLeft or TabRight),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    BackgroundTransparency = 0.6,
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalTabs = 0
            local FirstTab
            local LastTab

            local Tabbox: any = {
                Type = "Tabbox",

                Connections = {},
                Destroyed = false,

                Visible = true,
                ActiveTab = nil,
                MaxHeight = Info.MaxHeight,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {},

                ParentBox = if IsNested then ParentObj else nil,
            }

            function Tabbox:UpdateCorners()
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:Resize()
                if Tabbox.ActiveTab then
                    Tabbox.ActiveTab:Resize()
                end
            end

            function Tabbox:SetMaxHeight(MaxHeight: number?)
                if MaxHeight ~= nil then
                    assert(typeof(MaxHeight) == "number", "MaxHeight must be a number or nil")
                    assert(MaxHeight > 0, "MaxHeight must be higher than 0")
                end

                Tabbox.MaxHeight = MaxHeight
                Tabbox:Resize()
            end

            function Tabbox:AddTab(Name, IconName, MaxHeight)
                TotalTabs = TotalTabs + 1
                local TabIndex = TotalTabs

                LastTab = TabIndex
                if not FirstTab then
                    FirstTab = TabIndex
                end

                local IsNameEmpty = Name == nil or Trim(tostring(Name)) == ""
                local TabStoringIndex = IsNameEmpty and tostring(TabIndex) or Name

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                local ButtonCorner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
                    TopRightRadius = UDim.new(0, WindowInfo.CornerRadius),
                    BottomRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, 0),
                    Parent = Button,
                }); table.insert(Library.SpecificCorners, ButtonCorner)

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                local BoxIcon = Library:GetCustomIcon(IconName)
                if BoxIcon then
                    ButtonIcon = Library:CreateIcon(BoxIcon, {
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageTransparency = 0.5,
                        Size = IsNameEmpty and UDim2.fromOffset(16, 16) or UDim2.fromOffset(18, 18),
                        Parent = ButtonContent,
                    })
                end

                local ButtonLabel
                if not IsNameEmpty then
                    ButtonLabel = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(0, 16),
                        Text = Name,
                        TextSize = 15,
                        TextTransparency = 0.5,
                        Parent = ButtonContent,
                    })
                end

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.None,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromOffset(0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    ScrollBarImageTransparency = 1,
                    ScrollBarThickness = 0,
                    ScrollingEnabled = false,
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = Container,
                })

                local Tab = {
                    Type = "SubTab",
                    Name = Name,
                    MaxHeight = MaxHeight,

                    Connections = {},
                    Destroyed = false,

                    ButtonHolder = Button,
                    Container = Container,
                    ButtonCorner = ButtonCorner,

                    Tab = Tab,
                    Tabbox = Tabbox,

                    Elements = {},
                    DependencyBoxes = {},
                }

                function Tab:Show()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    Button.BackgroundTransparency = 1

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0
                    end
                    if ButtonIcon then
                        SetIconProperties(ButtonIcon, { ImageTransparency = 0 })
                    end

                    Line.Visible = false

                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                    Tabbox:RefreshPopOutPlaceholder()
                end

                function Tab:Hide()
                    Button.BackgroundTransparency = 0

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0.5
                    end
                    if ButtonIcon then
                        SetIconProperties(ButtonIcon, { ImageTransparency = 0.5 })
                    end
                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    local ContentSize = (List.AbsoluteContentSize.Y / Library.DPIScale) + 14
                    local FrameSize = ContentSize
                    local TabMaxHeight = Tab.MaxHeight or Tabbox.MaxHeight
                    if Tabbox.PoppedOut then
                        FrameSize = math.min(ContentSize, GetPopOutBodyMaxHeight(Tabbox, 35))
                    elseif typeof(TabMaxHeight) == "number" then
                        FrameSize = math.min(ContentSize, math.max(TabMaxHeight - 35, 0))
                    end

                    local NeedsScroll = ContentSize > FrameSize + 1
                    Container.CanvasSize = UDim2.fromOffset(0, if NeedsScroll then ContentSize else 0)
                    Container.ScrollingEnabled = NeedsScroll
                    TabboxHolder.Size = UDim2.new(1, 0, 0, FrameSize + 35)

                    if IsNested then
                        ParentObj:Resize()
                    end
                end

                function Tab:SetMaxHeight(NewMaxHeight: number?)
                    if NewMaxHeight ~= nil then
                        assert(typeof(NewMaxHeight) == "number", "MaxHeight must be a number or nil")
                        assert(NewMaxHeight > 0, "MaxHeight must be higher than 0")
                    end

                    Tab.MaxHeight = NewMaxHeight
                    Tab:Resize()
                end

                function Tab:UpdateCorners()
                    local Radius = WindowInfo.CornerRadius

                    ButtonCorner.TopLeftRadius = UDim.new(0, TabIndex == FirstTab and Radius or 0)
                    ButtonCorner.TopRightRadius = UDim.new(0, TabIndex == LastTab and Radius or 0)
                end

                function Tab:Destroy()
                    Tab.Destroyed = true

                    if Tab.Connections then
                        for _, Connection in Tab.Connections do
                            Connection:Disconnect()
                        end
                    end

                    for _, Element in Tab.Elements do
                        if Element.Destroy then
                            Element:Destroy()
                        end
                    end

                    for _, SubDepbox in Tab.DependencyBoxes do
                        if SubDepbox.Destroy then
                            SubDepbox:Destroy()
                        end
                    end

                    if Container then
                        Container:Destroy()
                    end

                    if Button then
                        Button:Destroy()
                    end
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                Button.MouseButton1Click:Connect(Tab.Show)

                Tab.AddTabbox = AddTabbox
                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[TabStoringIndex] = Tab
                Tabbox:UpdateCorners()

                return Tab, TabStoringIndex
            end

            Library:MakeBoxPopOut(Tabbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = TabboxButtons,
                Children = function()
                    return { TabboxHolder }
                end,

                After = function()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Resize()
                    end
                    if IsNested then
                        ParentObj:Resize()
                    end
                end,
            })

            function Tabbox:Destroy()
                if Tabbox.PoppedOut then
                    Tabbox:SetPoppedOut(false)
                end

                Tabbox.Destroyed = true

                if Tabbox.Connections then
                    for _, Connection in Tabbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Tab in Tabbox.Tabs do
                    if Tab.Destroy then
                        Tab:Destroy()
                    end
                end

                if TabboxHolder then
                    TabboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            if Info.Name then
                Tab.Tabboxes[Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end

            return Tabbox
        end

        Tab.AddTabbox = AddTabbox

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        function Tab:AddGroupbox(Info)
            Info = Library:Validate(Info, Templates.Groupbox)

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = (Info.Side == 1) and TabLeft or TabRight,
            })
            local BoxHolderList = New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder

            local GroupboxTop
            local GroupboxLabel
            local GroupboxDescription

            local GroupboxContainer
            local GroupboxList

            local GroupboxCollapseArrow
            local GroupboxLine

            do
                GroupboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    BackgroundTransparency = 0.6,
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = GroupboxHolder,
                    })
                )
                New("UIListLayout", {
                    Parent = GroupboxHolder,
                })
                Library:AddOutline(GroupboxHolder)

                GroupboxTop = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxTop,
                })

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    Library:CreateIcon(BoxIcon, {
                        AnchorPoint = Vector2.new(0, 0.5),
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(22, 22),
                        Parent = GroupboxTop,
                    })
                end

                local RightInset = if Info.DisableCollapsing ~= true then 22 else 0
                local TextsFrame = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(BoxIcon and 24 or 0, 0),
                    Size = UDim2.new(1, -RightInset - (BoxIcon and 24 or 0), 0, 0),
                    Parent = GroupboxTop,
                })
                New("UIListLayout", {
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 3),
                    Parent = TextsFrame,
                })

                GroupboxLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Name,
                    TextSize = 15,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 1),
                    Parent = GroupboxLabel,
                })

                GroupboxDescription = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Description or "",
                    TextSize = 14,
                    TextTransparency = 0.5,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = (Info.Description ~= nil),
                    Parent = TextsFrame,
                })

                GroupboxCollapseArrow = Library:CreateIcon(ArrowIcon, {
                    Visible = Info.DisableCollapsing ~= true,
                    AnchorPoint = Vector2.new(1, 0.5),
                    ImageColor3 = "WhiteColor",
                    Position = UDim2.fromScale(1, 0.5),
                    Rotation = 180,
                    Size = UDim2.fromOffset(22, 22),
                    Parent = GroupboxTop,
                }, true)

                GroupboxLine = Library:MakeLine(GroupboxHolder, {
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 1),
                })

                GroupboxContainer = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.None,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromOffset(0, 0),
                    LayoutOrder = 2,
                    ScrollBarImageTransparency = 1,
                    ScrollBarThickness = 0,
                    ScrollingEnabled = false,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = GroupboxContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = GroupboxContainer,
                })
            end

            local Groupbox: any = {
                Type = "Groupbox",

                Name = Info.Name,
                Description = Info.Description,

                Connections = {},
                Destroyed = false,

                Visible = true,
                Collapsed = false,
                MaxHeight = Info.MaxHeight,

                BoxHolder = BoxHolder,
                Holder = GroupboxHolder,
                Container = GroupboxContainer,

                Tab = Tab,
                DependencyBoxes = {},
                Elements = {}
            }

            local ResizeTween
            local CollapseArrowTween

            local function RefreshBoxHolderLayout()
                BoxHolder.AutomaticSize = Enum.AutomaticSize.None
                BoxHolder.Size = UDim2.new(1, 0, 0, BoxHolderList.AbsoluteContentSize.Y / Library.DPIScale + 8)
                BoxHolder.AutomaticSize = Enum.AutomaticSize.Y
            end
            Groupbox.RefreshBoxHolderLayout = RefreshBoxHolderLayout

            function Groupbox:Resize()
                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                local TopSize = (GroupboxTop.AbsoluteSize.Y / Library.DPIScale)
                local ContentSize = (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 14
                local ContainerSize = ContentSize
                if Groupbox.PoppedOut then
                    ContainerSize = math.min(ContainerSize, GetPopOutBodyMaxHeight(Groupbox, TopSize + 1))
                elseif typeof(Groupbox.MaxHeight) == "number" then
                    ContainerSize = math.min(ContainerSize, math.max(Groupbox.MaxHeight - TopSize - 1, 0))
                end

                local NeedsScroll = ContentSize > ContainerSize + 1
                GroupboxContainer.CanvasSize = UDim2.fromOffset(0, if NeedsScroll then ContentSize else 0)
                GroupboxContainer.ScrollingEnabled = NeedsScroll

                local TargetSize = UDim2.new(1, 0, 0, if Groupbox.Collapsed then TopSize else (TopSize + 1 + ContainerSize))
                GroupboxContainer.Size = UDim2.new(1, 0, 0, ContainerSize)
                GroupboxLine.Visible = not Groupbox.Collapsed

                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxHolder, TweenInfo, { Size = TargetSize })
                    ResizeTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if ResizeTween == Tween then
                            StopTween(ResizeTween, true)
                            ResizeTween = nil
                        end

                        RefreshBoxHolderLayout()
                    end))

                    Tween:Play()
                else
                    GroupboxHolder.Size = TargetSize
                    RefreshBoxHolderLayout()
                end
            end

            table.insert(Groupbox.Connections, GroupboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Groupbox.Visible == false or Groupbox.Destroyed then
                    return
                end

                Groupbox:Resize()
            end))

            function Groupbox:SetDescription(Description: string | nil)
                GroupboxDescription.Text = Description or ""
                GroupboxDescription.Visible = (Description ~= nil)

                Groupbox:Resize()
            end

            function Groupbox:SetCollapsed(Collapsed: boolean)
                if Info.DisableCollapsing == true then return end
                Groupbox.Collapsed = Collapsed

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                local TargetRotation = if Collapsed then 0 else 180

                GroupboxContainer.Visible = not Collapsed
                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxCollapseArrow, TweenInfo, { Rotation = TargetRotation })
                    CollapseArrowTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Connect(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if CollapseArrowTween == Tween then
                            StopTween(CollapseArrowTween, true)
                            CollapseArrowTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxCollapseArrow.Rotation = TargetRotation
                end

                Groupbox:Resize()
            end

            function Groupbox:ToggleCollapsed()
                if Info.DisableCollapsing == true then return end
                Groupbox:SetCollapsed(not Groupbox.Collapsed)
            end

            function Groupbox:SetMaxHeight(MaxHeight: number?)
                if MaxHeight ~= nil then
                    assert(typeof(MaxHeight) == "number", "MaxHeight must be a number or nil")
                    assert(MaxHeight > 0, "MaxHeight must be higher than 0")
                end

                Groupbox.MaxHeight = MaxHeight
                Groupbox:Resize()
            end

            Library:MakeBoxPopOut(Groupbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = GroupboxTop,
                Children = function()
                    local Children = {}
                    for _, Child in BoxHolder:GetChildren() do
                        if Child:IsA("GuiObject") and Child ~= Groupbox.PopOutPlaceholder then
                            table.insert(Children, Child)
                        end
                    end
                    return Children
                end,

                Before = function()
                    GroupboxCollapseArrow.Visible = false
                end,
                After = function()
                    GroupboxCollapseArrow.Visible = Info.DisableCollapsing ~= true
                    Groupbox:Resize()
                end
            })

            function Groupbox:Destroy()
                if Groupbox.PoppedOut then
                    Groupbox:SetPoppedOut(false)
                end

                Groupbox.Destroyed = true

                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                if Groupbox.Connections then
                    for _, Connection in Groupbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Element in Groupbox.Elements do
                    if Element.Destroy then
                        Element:Destroy()
                    end
                end
                table.clear(Groupbox.Elements)

                for _, SubDepbox in Groupbox.DependencyBoxes do
                    if SubDepbox.Destroy then
                        SubDepbox:Destroy()
                    end
                end
                table.clear(Groupbox.DependencyBoxes)

                if GroupboxHolder then
                    GroupboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            function Groupbox:SetVisible(Visible: boolean)
                Groupbox.Visible = Visible
                BoxHolder.Visible = Visible
                SyncPopOutVisibility(Groupbox)

                if Visible == true and Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function Groupbox:Show()
                Groupbox:SetVisible(true)
            end

            function Groupbox:Hide()
                Groupbox:SetVisible(false)
            end

            if Info.DisableCollapsing ~= true then
                GroupboxCollapseArrow.MouseButton1Click:Connect(function()
                    Groupbox:ToggleCollapsed()
                end)
            end

            Groupbox.AddTabbox = AddTabbox
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()
            Tab.Groupboxes[Info.Name] = Groupbox

            if Info.Visible == false then
                Groupbox:Hide()
            end

            if Info.DisableCollapsing ~= true and Info.Collapsed == true then
                Groupbox:SetCollapsed(true)
            end

            return Groupbox
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = Hovering and 0.25 or 0.5 })
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0 })
            end

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Library:PlayTabAnimation(Tab, true)
            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0.5 })
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        function Tab:Destroy()
            Tab.Destroyed = true

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            for _, Groupbox in Tab.Groupboxes do
                if Groupbox.Destroy then
                    Groupbox:Destroy()
                end
            end
            table.clear(Tab.Groupboxes)

            for _, Tabbox in Tab.Tabboxes do
                if Tabbox.Destroy then
                    Tabbox:Destroy()
                end
            end
            table.clear(Tab.Tabboxes)

            for _, DepGroupbox in Tab.DependencyGroupboxes do
                if DepGroupbox.Destroy then
                    DepGroupbox:Destroy()
                end
            end

            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Library.Tabs[Name] = Tab

        if Library.AutoFontSelector and typeof(Name) == "string" and Name:lower():find("setting", 1, true) then
            pcall(function()
                Library:AddFontSelector(Tab:AddLeftGroupbox("Font"))
            end)
        end

        return Tab
    end

    function Window:AddKeyTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = Library:CreateIcon(Icon, {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Description = Description,
            IsKeyTab = true,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Elements = {},

            Window = Window,
            Button = TabButton,
            Container = TabContainer
        }

        function Tab:AddKeyBox(Callback)
            assert(typeof(Callback) == "function", "Callback must be a function")

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.5,
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })
            local BoxStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = Box,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Box,
                })
            )

            Box.Focused:Connect(function()
                Library.Registry[BoxStroke].Color = "AccentColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end)

            Box.FocusLost:Connect(function()
                Library.Registry[BoxStroke].Color = "OutlineColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end)

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.5,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                TextTransparency = 0.4,
                Parent = Holder,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.4,
                }):Play()
            end)

            Button.InputBegan:Connect(function(Input)
                if not IsClickInput(Input) then
                    return
                end

                if not Library:MouseIsOverFrame(Button, Input.Position) then
                    return
                end

                Callback(Box.Text)
            end)
        end

        function Tab:Destroy()
            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = Hovering and 0.25 or 0.5 })
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0 })
            end

            Library:PlayTabAnimation(Tab, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0.5 })
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddCustomTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = Library:CreateIcon(Icon, {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,
            IsCustomTab = true,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Connections = {},
            Destroyed = false,

            Window = Window,
            Button = TabButton,
            Container = TabContainer,
            Sides = {},

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
        }

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = Hovering and 0.25 or 0.5 })
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0 })
            end

            Library:PlayTabAnimation(Tab, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0.5 })
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        function Tab:Destroy()
            Tab.Destroyed = true

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if Library.ActiveTab == Tab then
                Tab:Hide()
            end

            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        table.insert(Tab.Connections, TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end))
        table.insert(Tab.Connections, TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end))
        table.insert(Tab.Connections, TabButton.MouseButton1Click:Connect(Tab.Show))

        Library.Tabs[Name] = Tab

        return TabContainer, Tab
    end

    function Window:AddDialog(Idx, Info)
        Info = Library:Validate(Info, Templates.Dialog)

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = MainFrame,
        })
        TweenService:Create(DialogOverlay, Library.TweenInfo, {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.6,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1,
            Parent = DialogOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = DialogFrame,
            })
        )
        Library:AddOutline(DialogFrame)

        local InnerContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            Parent = DialogFrame,
        })
        local DialogScale = New("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TweenService:Create(DialogScale, Library.TweenInfo, {
            Scale = 1
        }):Play()
        local _InnerPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = HeaderContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        if Info.Icon then
            local ParsedIcon = Library:GetCustomIcon(Info.Icon)
            if ParsedIcon then
                Library:CreateIcon(ParsedIcon, {
                    Size = UDim2.fromOffset(16, 16),
                    ImageColor3 = Info.TitleColor or "FontColor",
                    LayoutOrder = 1,
                    ZIndex = 2,
                    Parent = TitleRow,
                })
            end
        end

        local TitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title,
            TextSize = 18,
            TextColor3 = Info.TitleColor or "FontColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = TitleRow,
        })

        local DescriptionLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description,
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Info.DescriptionColor or "FontColor",
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = HeaderContainer,
        })

        DialogContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        local _DialogContainerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DialogContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = DialogContainer,
        })

        local _Sep2 = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 2,
            Parent = InnerContainer,
        })

        ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Destroyed = false,
            Elements = {},
            Container = DialogContainer,
            OutsideClickDismiss = Info.OutsideClickDismiss,
        }

        function Dialog:Resize()
            local MaxWidth = (MainFrame.AbsoluteSize.X / Library.DPIScale) * 0.75
            local MinWidth = 400

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in FooterButtonsList do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

            local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in DialogContainer:GetChildren() do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end
            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons
        end

        function Dialog:SetTitle(Title)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            if Dialog.Destroyed then
                return
            end

            Dialog.Destroyed = true

            if Library.ActiveDialog == Dialog then
                Library.ActiveDialog = nil
            end

            for Index = #Dialog.Elements, 1, -1 do
                local Element = Dialog.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end
            table.clear(Dialog.Elements)

            local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
            TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            CloseTween:Play()

            task.delay(Library.TweenInfo.Time, function()
                DialogOverlay:Destroy()
            end)
            Library.Dialogues[Idx] = nil
        end

        DialogOverlay.MouseButton1Click:Connect(function()
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0

            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 2,
                Parent = ButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 2,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            local _BtnPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14,
                ZIndex = 2,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius),
                        Parent = ProgressBar
                    })
                )
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    IsActive = not Disabled
                    if Disabled then
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    else
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    end
                end
            }

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if not IsActive then return end
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end
                if Info.AutoDismiss then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()

                task.delay(WaitTime, function()
                    ButtonWrap:SetDisabled(false)
                    if ProgressBar then
                        TweenService:Create(ProgressBar, Library.TweenInfo, {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        for BIdx, BInfo in Info.FooterButtons do
            if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
            Dialog:AddFooterButton(BIdx, BInfo)
        end

        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog

        Dialog:Resize()

        Library.ActiveDialog = Dialog
        return Dialog
    end

    local GuiProperties = { "BackgroundTransparency" }
    local ImageProperties = { "BackgroundTransparency", "ImageTransparency" }
    local TextProperties = { "BackgroundTransparency", "TextTransparency" }
    local StrokeProperties = { "Transparency" }

    local function FadeInstance(Desc, Properties)
        local Cache = TransparencyCache[Desc]
        if not Cache then
            Cache = {}
            TransparencyCache[Desc] = Cache
        end

        for _, Prop in Properties do
            if not Library.Toggled then
                Cache[Prop] = Desc[Prop]
            end

            if Cache[Prop] ~= nil and Cache[Prop] ~= 1 then
                TweenService:Create(Desc, Library.WindowAnimationInfo, {
                    [Prop] = Library.Toggled and Cache[Prop] or 1,
                }):Play()
            end
        end
    end

    function Window:Toggle(Value: boolean?)
        if Fading then
            return
        end

        if Library.ActiveLoading then
            if Value == true then
                return
            end

            if not Library.Toggled then
                return
            end
        end

        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        if Library.Animations and Library.Animations.ToggleWindow == true then
            local FadeTime = Library.WindowAnimationInfo.Time
            Fading = true

            if Library.Toggled then
                MainFrame.Visible = true
            end

            if Library.Toggled then
                FadeInstance(MainFrame, { "BackgroundTransparency" })
                task.wait(FadeTime / 2)
            else
                task.delay(FadeTime / 2, FadeInstance, MainFrame, { "BackgroundTransparency" })
            end

            for _, Instance in MainFrame:GetDescendants() do
                if Instance == TopBar then
                    continue
                end

                if Instance:IsA("GuiObject") then
                    local ClassName = Instance.ClassName
                    if ClassName == "ImageLabel" or ClassName == "ImageButton" then
                        FadeInstance(Instance, ImageProperties)
                    elseif ClassName == "TextLabel" or ClassName == "TextBox" or ClassName == "TextButton" then
                        FadeInstance(Instance, TextProperties)
                    else
                        FadeInstance(Instance, GuiProperties)
                    end
                elseif Instance.ClassName == "UIStroke" then
                    FadeInstance(Instance, StrokeProperties)
                end
            end

            task.delay(FadeTime, function()
                MainFrame.Visible = Library.Toggled
                Fading = false
            end)
        else
            MainFrame.Visible = Library.Toggled
        end

        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled
        end

        if Library.Toggled and not Library.IsMobile then
            local ShowCursorBinding = Library.ShowCursorBinding
            Library.OriginalMouseIconEnabled = UserInputService.MouseIconEnabled

            pcall(function() RunService:UnbindFromRenderStep(ShowCursorBinding) end)
            RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
                UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
                Cursor.Visible = Library.ShowCustomCursor

                if Library.Unloaded == true or not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                    RestoreMouseIcon()
                end
            end)
        elseif not Library.Toggled then
            RestoreMouseIcon()
            TooltipLabel.Visible = false

            CloseMenus()
        end
    end

    function Library:Toggle(Value: boolean?)
        return Window:Toggle(Value)
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true

            Changed = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsHoverInput(Input) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end

    Window:SetAlwaysOnTop(WindowInfo.AlwaysOnTop)
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow and not Library.ActiveLoading then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then
        local ToggleButton = Library:AddDraggableButton("Toggle", function()
            Library:Toggle()
        end, true)

        local LockButton = Library:AddDraggableButton("Lock", function(self)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end, true)

        if WindowInfo.MobileButtonsSide == "Right" then
            ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)
            ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)

            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
            LockButton.Button.Position = UDim2.new(1, -(ToggleButton.Button.Size.X.Offset + 12), 0, 6)
        else
            ToggleButton.Button.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Button.Position = UDim2.fromOffset(6, 6)

            LockButton.Button.AnchorPoint = Vector2.new(0, 0)
            LockButton.Button.Position = UDim2.fromOffset(ToggleButton.Button.Size.X.Offset + 12, 6)
        end

        if WindowInfo.ShowMobileButtons == false then
            ToggleButton.Button.Visible = false
            LockButton.Button.Visible = false
        end
    end

    --// Execution \\--
    Library:GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:UpdateSearch(SearchBox.Text)
    end))

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape then
            -- Releasing focus from a text input takes priority and never toggles the window --
            local FocusedBox = UserInputService:GetFocusedTextBox()
            if FocusedBox then
                FocusedBox:ReleaseFocus()
                return
            end

            -- Dismiss the topmost dialog before closing any open menu --
            if Library.ActiveDialog and Library.ActiveDialog.OutsideClickDismiss ~= false then
                Library.ActiveDialog:Dismiss()
                return
            end

            if CurrentMenu then
                CurrentMenu:Close()
                return
            end

            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
    end))

    Window.MainFrame = MainFrame
    Library.Window = Window

    return Window
end

function Library:CreateLoading(LoadingInfo)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        AlwaysOnTop = LoadingInfo.AlwaysOnTop,

        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui
    SetAlwaysOnTop(ScreenGui, LoadingInfo.AlwaysOnTop)

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        task.defer(function()
            if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
                return
            end

            Library:RemoveFromRegistry(Instance)
        end)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))

    local MainScale = New("UIScale", {
        Scale = Library.IsMobile and 0.8 or 1,
        Parent = MainFrame
    })
    table.insert(Library.Scales, MainScale)
    Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)

    Library:AddOutline(SideBar)

    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        Library:CreateIcon(Library:GetCustomIcon(LoadingInfo.Icon), {
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
    else
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local LoadingIconWidth = LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0
    local LoadingMaxWidth = math.max(0, (TitleHolder.AbsoluteSize.X / Library.DPIScale) - LoadingIconWidth - 12)
    local LoadingTitleWidth = math.min(
        Library:GetTextBounds(LoadingInfo.Title, Library.Scheme.Font, 20),
        LoadingMaxWidth
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, LoadingTitleWidth, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoadingIcon = Library:CreateIcon(Library:GetCustomIcon(LoadingInfo.LoadingIcon), {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = GetTextStrokeColor,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},

        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,

        Resize = function(self)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight

        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight =
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        local IconData = Library:GetCustomIcon(Icon)
        assert(IconData, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        local Replacement = Library:ApplyIcon(LoadingIcon, IconData)
        if Replacement ~= LoadingIcon then
            LoadingIcon = Replacement
            Loading:SetLoadingIconTweenTime(LoadingInfo.LoadingIconTweenTime)
        end
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        LoadingInfo.LoadingIconTweenTime = TweenTime

        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        SetIconProperties(LoadingIcon, { ImageColor3 = Color })
    end

    function Loading:SetCurrentStep(Step)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then
                button:Destroy()
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

function Library:Unload()
    Library.Unloaded = true

    --// Disconnect connections
    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)

        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    --// Run Unload Callbacks
    for _ = 1, #Library.UnloadSignals do
        local Callback = table.remove(Library.UnloadSignals, 1)

        if Callback then
            Library:SafeCallback(Callback)
        end
    end

    --// Destroy elements
    for Index = #Library.Tabs, 1, -1 do
        local Tab = table.remove(Library.Tabs, Index)

        if Tab and Tab.Destroy then
            Library:SafeCallback(Tab.Destroy, Tab)
        end
    end

    for Index = #Tooltips, 1, -1 do
        local Tooltip = table.remove(Tooltips, Index)

        if Tooltip and Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if Library.KeybindMenu then
        Library.KeybindMenu:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    --// Clear tables
    table.clear(Library.Registry)

    table.clear(Options)
    table.clear(Toggles)
    table.clear(Buttons)
    table.clear(Labels)
    table.clear(Tooltips)

    table.clear(Library.Tabs)
    table.clear(Library.TabButtons)

    table.clear(Library.Scales)
    table.clear(Library.ScalesOffset)

    table.clear(Library.Corners)
    table.clear(Library.SpecificCorners)
    table.clear(Library.ContextMenus)

    table.clear(Library.Notifications)
    table.clear(Library.Dialogues)
    table.clear(Library.DraggableElements)
    table.clear(Library.KeybindToggles)
    table.clear(Library.DependencyBoxes)

    table.clear(TransparencyCache)
    table.clear(ActiveTabTweens)

    Library.Toggle = function(...) end
    Library.ScreenGui = nil
    Library.Floats = nil
    Library.Overlay = nil
    Library.WindowContainer = nil
    Library.KeybindFrame = nil
    Library.KeybindContainer = nil
    Library.KeybindMenu = nil

    getgenv().Library = nil
end

getgenv().Library = Library
return Library
