-- Pet Tracker GUI with transparent theme by James Michael
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- GUI setup with transparent theme
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "PetMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 99999

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0.95, 0, 0.5, 0)
ToggleButton.AnchorPoint = Vector2.new(0, 0.5)
ToggleButton.Text = "💧" -- Water drop instead of animal foot
ToggleButton.TextScaled = true
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundTransparency = 0.3 -- Semi-transparent
ToggleButton.TextColor3 = Color3.fromRGB(0, 150, 255) -- Blue water drop
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.ZIndex = 99999
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 360)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35) -- Darker blue-gray
MainFrame.BackgroundTransparency = 0.2 -- Semi-transparent background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 99998
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Add subtle border effect
local BorderFrame = Instance.new("Frame", MainFrame)
BorderFrame.Size = UDim2.new(1, 2, 1, 2)
BorderFrame.Position = UDim2.new(0, -1, 0, -1)
BorderFrame.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
BorderFrame.BackgroundTransparency = 0.7
BorderFrame.ZIndex = 99997
Instance.new("UICorner", BorderFrame).CornerRadius = UDim.new(0, 12)

-- Title bar with transparent theme
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
TitleBar.BackgroundTransparency = 0.1
TitleBar.ZIndex = 99999
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(150, 200, 255) -- Light blue text
TitleText.Text = "Owner: James Michael"
TitleText.TextScaled = true
TitleText.Font = Enum.Font.SourceSansBold
TitleText.ZIndex = 99999

-- Refresh Button with transparent theme
local RefreshButton = Instance.new("TextButton", TitleBar)
RefreshButton.Size = UDim2.new(0.25, 0, 0.8, 0)
RefreshButton.Position = UDim2.new(0.75, 0, 0.1, 0)
RefreshButton.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
RefreshButton.BackgroundTransparency = 0.2
RefreshButton.TextColor3 = Color3.new(1,1,1)
RefreshButton.Text = "Refresh"
RefreshButton.TextScaled = true
RefreshButton.ZIndex = 99999
Instance.new("UICorner", RefreshButton).CornerRadius = UDim.new(0, 6)

-- ScrollFrame with transparent background
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Position = UDim2.new(0, 5, 0, 32)
ScrollFrame.Size = UDim2.new(1, -10, 1, -37)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ZIndex = 99998
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)

local UIList = Instance.new("UIListLayout", ScrollFrame)
UIList.Padding = UDim.new(0, 4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Status label with improved styling
local StatusLabel = Instance.new("TextLabel", ScrollFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 28)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Loading pet data..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
StatusLabel.TextScaled = true
StatusLabel.Visible = false
StatusLabel.ZIndex = 99999

-- === PET DATA PARSING ===
local function parsePetData(rawText)
    if not rawText or rawText == "" then return {} end
    local entries, current = {}, {}
    for line in rawText:gmatch("[^\r\n]+") do
        if line:match("^%[.+%]$") then
            if next(current) then table.insert(entries, current) end
            local ts = line:match("%[(.-)%]")
            local y,m,d,h,mi,s = ts:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
            if y then
                current = {
                    timestamp = ts,
                    epoch = os.time({year=tonumber(y), month=tonumber(m), day=tonumber(d), hour=tonumber(h), min=tonumber(mi), sec=tonumber(s)}),
                    petNames = {}, players = "", placeId = "", jobId = ""
                }
            end
        elseif line:match("^Target Player:") then current.targetPlayer = line:match("^Target Player:%s*(.+)") or ""
        elseif line:match("^Server Player Count:") then current.players = line:match("^Server Player Count:%s*(.+)") or "" 
        elseif line:match("^Place ID:") then current.placeId = (line:match("^Place ID:%s*(.+)") or ""):gsub("%s+", "") 
        elseif line:match("^Job ID:") then current.jobId = (line:match("^Job ID:%s*(.+)") or ""):gsub("%s+", "") 
        elseif line:match("^%- ") then table.insert(current.petNames, line:match("^%- (.+)")) end
    end
    if next(current) then table.insert(entries, current) end
    return entries
end

-- === CREATE ENTRY with transparent styling ===
local function createPetEntry(entry)
    -- Avoid duplicate entries based on timestamp
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") and child:FindFirstChild("TimeLabel") and child.TimeLabel.Text == entry.timestamp then
            return
        end
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 85)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    Frame.BackgroundTransparency = 0.3 -- Semi-transparent entries
    Frame.Parent = ScrollFrame
    Frame.ZIndex = 99999
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    -- Add subtle glow effect
    local GlowFrame = Instance.new("Frame", Frame)
    GlowFrame.Size = UDim2.new(1, 4, 1, 4)
    GlowFrame.Position = UDim2.new(0, -2, 0, -2)
    GlowFrame.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    GlowFrame.BackgroundTransparency = 0.8
    GlowFrame.ZIndex = 99998
    Instance.new("UICorner", GlowFrame).CornerRadius = UDim.new(0, 10)

    local TimeLabel = Instance.new("TextLabel", Frame)
    TimeLabel.Name = "TimeLabel"
    TimeLabel.Size = UDim2.new(1, -8, 0.22, 0)
    TimeLabel.Position = UDim2.new(0, 4, 0, 2)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Text = entry.timestamp
    TimeLabel.TextColor3 = Color3.fromRGB(120, 170, 255)
    TimeLabel.TextScaled = true
    TimeLabel.ZIndex = 99999

    local PetLabel = Instance.new("TextLabel", Frame)
    PetLabel.Size = UDim2.new(1, -8, 0.45, 0)
    PetLabel.Position = UDim2.new(0, 4, 0.22, 0)
    PetLabel.BackgroundTransparency = 1
    PetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PetLabel.TextScaled = true
    PetLabel.TextWrapped = true
    PetLabel.ZIndex = 99999

    local petCount, petTextList = {}, {}
    for _, p in ipairs(entry.petNames) do petCount[p] = (petCount[p] or 0) + 1 end
    for name, count in pairs(petCount) do
        table.insert(petTextList, count > 1 and (name.." x"..count) or name)
    end
    table.sort(petTextList)
    PetLabel.Text = table.concat(petTextList, ", ")

    local BottomRow = Instance.new("Frame", Frame)
    BottomRow.Size = UDim2.new(1, -8, 0.28, 0)
    BottomRow.Position = UDim2.new(0, 4, 0.67, 0)
    BottomRow.BackgroundTransparency = 1

    local PlayerLabel = Instance.new("TextLabel", BottomRow)
    PlayerLabel.Size = UDim2.new(0.4, 0, 1, 0)
    PlayerLabel.BackgroundTransparency = 1
    PlayerLabel.Text = "👥 " .. (entry.players or "?")
    PlayerLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    PlayerLabel.TextScaled = true
    PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left

    local JoinButton = Instance.new("TextButton", BottomRow)
    JoinButton.Size = UDim2.new(0.55, 0, 1, 0)
    JoinButton.Position = UDim2.new(0.45, 0, 0, 0)
    JoinButton.Text = "JOIN"
    JoinButton.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
    JoinButton.BackgroundTransparency = 0.2
    JoinButton.TextColor3 = Color3.new(1, 1, 1)
    JoinButton.TextScaled = true
    Instance.new("UICorner", JoinButton).CornerRadius = UDim.new(0, 6)
    
    -- Add hover effect
    JoinButton.MouseEnter:Connect(function()
        JoinButton.BackgroundTransparency = 0
        JoinButton.BackgroundColor3 = Color3.fromRGB(70, 140, 220)
    end)
    JoinButton.MouseLeave:Connect(function()
        JoinButton.BackgroundTransparency = 0.2
        JoinButton.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
    end)
    
    JoinButton.MouseButton1Click:Connect(function()
        if entry.placeId ~= "" and entry.jobId ~= "" then
            local pid = tonumber(entry.placeId)
            local jid = tostring(entry.jobId)
            if pid and jid ~= "" then
                pcall(function() 
                    TeleportService:TeleportToPlaceInstance(pid, jid, Player) 
                end)
            end
        end
    end)
end

-- === LOAD PET LIST ===
local isLoading = false
local function loadPetList()
    if isLoading then return end
    isLoading = true

    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if not child:IsA("UIListLayout") and child ~= StatusLabel then child:Destroy() end
    end
    StatusLabel.Visible = true
    StatusLabel.Text = "Loading pet data..."

    local url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/data?t=" .. tick() .. "&r=" .. math.random(1,100000)
    local ok, result = pcall(function() return game:HttpGet(url, true) end)

    if not ok then
        StatusLabel.Text = "Failed to fetch data"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        isLoading = false
        return
    end

    local data = parsePetData(result)
    StatusLabel.Visible = false
    if #data == 0 then
        StatusLabel.Visible = true
        StatusLabel.Text = "No pet data found"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        isLoading = false
        return
    end

    table.sort(data, function(a,b) return a.epoch > b.epoch end)
    for i = 1, #data do createPetEntry(data[i]) end
    ScrollFrame.CanvasSize = UDim2.new(0,0,0, UIList.AbsoluteContentSize.Y+8)
    isLoading = false
end

-- Button actions with hover effects
ToggleButton.MouseEnter:Connect(function()
    ToggleButton.BackgroundTransparency = 0.1
    ToggleButton.Size = UDim2.new(0, 42, 0, 42)
end)
ToggleButton.MouseLeave:Connect(function()
    ToggleButton.BackgroundTransparency = 0.3
    ToggleButton.Size = UDim2.new(0, 40, 0, 40)
end)

RefreshButton.MouseEnter:Connect(function()
    RefreshButton.BackgroundTransparency = 0
    RefreshButton.BackgroundColor3 = Color3.fromRGB(70, 140, 220)
end)
RefreshButton.MouseLeave:Connect(function()
    RefreshButton.BackgroundTransparency = 0.2
    RefreshButton.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
end)

ToggleButton.MouseButton1Click:Connect(function() 
    MainFrame.Visible = not MainFrame.Visible 
end)
RefreshButton.MouseButton1Click:Connect(loadPetList)

-- Initial load
loadPetList()
