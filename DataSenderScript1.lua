local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Target model names (expanded list)
local targetNames = {
    "Chicleteira Bicicleteira",
    "Dragon Cannelloni",
    "Garama and Madundung",
    "Graipuss Medussi",
    "La Grande Combinasio",
    "La Supreme Combinasion",
    "Los Combinasionas",
    "Los Hotspotsitos",
    "Los Matteos",
    "Nooo My Hotspot",
    "Los Noo My Hotspotsitos",
    "Nuclearo Dinossauro",
    "Pot Hotspot",
    "Cocofanto Elefanto",
    "Antonio",
    "Tacorita Bicicleta",
    "Girafa Celestre",
    "Gattatino Nyanino", 
    "Chihuanini Taconini",
    "Matteo",
    "Los Spyderinis",
    "Tralalero Tralala",
    "Los Crocodillitos", 
    "Trigoligre Frutonni",
    "Espresso Signora",
    "Odin Din Din Dun",
    "Statutino Libertino", 
    "Tipi Topi Taco",
    "Unclito Samito",
    "Aessio",
    "Orcalero Orcala",
    "Tralalita Tralala", 
    "Tukanno Bananno",
    "Trenostruzzo Turbo 3000",
    "Urubini Flamenguini",
    "Gattito Tacoto", 
    "Trippi Troppi Troppa Trippa",
    "Las Cappuchinas",
    "Ballerino Lololo",
    "Bulbito Bandito Traktorito", 
    "Los Tungtungtungcitos",
    "Pakrahmatmamat",
    "Los Bombinitos",
    "Brr es Teh Patipum",
    "Piccione Macchina", 
    "Bombardini Tortini",
    "Tractoro Dinosauro",
    "Los Orcalitos",
    "Orcalita Orcala",
    "Cacasito Satalito", 
    "Tartaruga Cisterna",
    "Los Tipi Tacos",
    "Piccionetta Macchina",
    "Mastodontico Telepiedone",
    "Anpali Babel", 
    "Belula Beluga",
    "La Vacca Staturno Saturnita",
    "Bisonte Giuppitere",
    "Karkerkar Kurkur", 
    "Trenostruzzo Turbo 4000",
    "Sammyni Spyderini",
    "Torrtuginni Dragonfrutini",
    "Dul Dul Dul",
    "Extinct Tralalero", 
    "Blackhole Goat",
    "Agarrini la Palini",
    "La Cucaracha",
    "Capi Taco",
    "Los Chicleteiras",
    "Los Tacoritas", 
    "Las Sis",
    "Celularcini Viciosini",
    "Fragola la la la",
    "Chimpanzini Spiderini",
    "Tortuginni Dragonfruitini", 
    "Los Tralaleritos",
    "Guerriro Digitale",
    "Las Tralaleritas",
    "Job Job Job Sahur",
    "Las Vaquitas Saturnitas", 
    "Noo My Hotspot",
    "Chachechi",
    "Extinct Matteo",
    "La Extinct Grande",
    "Extinct Cappuccina", 
    "Sahur Combinasion",
    "Los Nooo My Hotspotsitos",
    "Karkerkar combinasion",
    "Tralaledon", 
    "Esok Sekolah",
    "Ketupat Kepat",
    "Los Bros",
    "Ketchuru and Masturu", 
    "Spaghetti Tualetti",
    "Strawberry Elephant", 
    "Corn Corn Corn Sahur"
}

-- Check if server is private
local function isPrivateServer()
    local privateTextObj
    pcall(function()
        privateTextObj = workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.PrivateText
    end)
    
    if privateTextObj and privateTextObj:IsA("TextLabel") then
        local function isActuallyVisible(guiObj)
            if not guiObj.Visible then return false end
            local parent = guiObj.Parent
            while parent do
                if parent:IsA("GuiObject") and not parent.Visible then
                    return false
                end
                parent = parent.Parent
            end
            return true
        end
        
        if isActuallyVisible(privateTextObj) and privateTextObj.Text == "Milestones are unavailable in Private Servers." then
            return true
        end
    end
    return false
end

-- Check if server is full
local function isServerFull()
    local currentPlayers = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    return currentPlayers >= maxPlayers
end

-- Get all target models in workspace (optimized)
local function getTargetModels()
    local foundModels = {}
    
    -- Use batch processing to prevent lag
    local descendants = Workspace:GetDescendants()
    for i = 1, #descendants, 50 do
        RunService.Heartbeat:Wait() -- Yield to prevent freezing
        local endIndex = math.min(i + 49, #descendants)
        
        for j = i, endIndex do
            local descendant = descendants[j]
            if descendant:IsA("Model") then
                for _, targetName in ipairs(targetNames) do
                    if descendant.Name == targetName then
                        table.insert(foundModels, descendant.Name)
                        break
                    end
                end
            end
        end
    end
    
    return foundModels
end

-- Get current time in Philippines (UTC+8)
local function getPhilippineTime()
    local utcTime = os.time(os.date("!*t"))
    local philippineTime = utcTime + (8 * 3600) -- UTC+8 for Philippines
    return os.date("%Y-%m-%d %H:%M:%S", philippineTime)
end

-- Send data via RemoteEvent (bypasses HTTP restrictions)
local function sendDataToAPI()
    -- Check if we should skip sending data
    if isPrivateServer() then
        print("🇵🇭 Private server detected - skipping data send")
        return
    end
    
    if isServerFull() then
        print("🇵🇭 Server is full - skipping data send")
        return
    end
    
    -- Collect data
    local targetModels = getTargetModels()
    local philippineTime = getPhilippineTime()
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    
    -- Only send if we found pets
    if #targetModels == 0 then
        print("🇵🇭 No target pets found - skipping data send")
        return
    end
    
    -- Prepare pets data
    local petsData = {}
    for _, petName in ipairs(targetModels) do
        table.insert(petsData, {
            name = petName
        })
    end
    
    -- Prepare request data
    local requestData = {
        targetPlayer = LocalPlayer.Name,
        playerCount = playerCount,
        maxPlayers = maxPlayers,
        placeId = tostring(game.PlaceId),
        jobId = game.JobId,
        pets = petsData,
        timestamp = philippineTime,
        scriptVersion = "DataSenderScript1"
    }
    
    print("🇵🇭 Sending data with Philippine time:", philippineTime)
    print("🇵🇭 Pets found:", #targetModels, "Players:", playerCount .. "/" .. maxPlayers)
    
    -- Send via RemoteEvent (bypasses HTTP restrictions)
    local success, errorMessage = pcall(function()
        local PetTrackerRemote = ReplicatedStorage:FindFirstChild("PetTrackerRemote")
        if PetTrackerRemote then
            PetTrackerRemote:FireServer(requestData)
            return true
        else
            -- Fallback to HTTP if RemoteEvent doesn't exist
            local httpSuccess, response = pcall(function()
                return HttpService:RequestAsync({
                    Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Authorization"] = "h"
                    },
                    Body = HttpService:JSONEncode(requestData)
                })
            end)
            
            if httpSuccess then
                print("🇵🇭 HTTP fallback: Data sent successfully")
            else
                warn("🇵🇭 HTTP fallback failed:", response)
            end
            return httpSuccess
        end
    end)
    
    if not success then
        warn("🇵🇭 Failed to send data:", errorMessage)
    end
end

-- Debounce mechanism to prevent spam
local lastSendTime = 0
local SEND_COOLDOWN = 10 -- seconds

local function debouncedSendData()
    local currentTime = tick()
    if currentTime - lastSendTime < SEND_COOLDOWN then
        return
    end
    lastSendTime = currentTime
    
    sendDataToAPI()
end

-- Set up connection to send data when models change
local function handleDescendantAdded(descendant)
    if descendant:IsA("Model") then
        for _, targetName in ipairs(targetNames) do
            if descendant.Name == targetName then
                debouncedSendData()
                break
            end
        end
    end
end

local function handleDescendantRemoved(descendant)
    if descendant:IsA("Model") then
        for _, targetName in ipairs(targetNames) do
            if descendant.Name == targetName then
                debouncedSendData()
                break
            end
        end
    end
end

-- Connect events with debouncing
Workspace.DescendantAdded:Connect(handleDescendantAdded)
Workspace.DescendantRemoved:Connect(handleDescendantRemoved)

-- Also send data when players join/leave (with debouncing)
Players.PlayerAdded:Connect(debouncedSendData)
Players.PlayerRemoving:Connect(debouncedSendData)

-- Wait for game to load then send initial data
wait(5)
debouncedSendData()

print("🇵🇭 DataSenderScript1 loaded with Philippine Time (UTC+8)")
