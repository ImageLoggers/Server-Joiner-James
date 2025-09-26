local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
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

-- Get all target models in workspace
local function getTargetModels()
    local foundModels = {}
    
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") then
            for _, targetName in ipairs(targetNames) do
                if model.Name == targetName then
                    table.insert(foundModels, model.Name)
                    break
                end
            end
        end
    end
    
    return foundModels
end

-- Get current time in Baghdad (UTC+3)
local function getBaghdadTime()
    local utcTime = os.time(os.date("!*t"))
    local baghdadTime = utcTime + (3 * 3600) -- UTC+3 for Baghdad
    return os.date("%Y-%m-%d %H:%M:%S", baghdadTime)
end

-- Send data to API
local function sendDataToAPI()
    -- Check if we should skip sending data
    if isPrivateServer() then
        print("Private server detected - skipping API call")
        return
    end
    
    if isServerFull() then
        print("Server is full - skipping API call")
        return
    end
    
    -- Collect data
    local targetModels = getTargetModels()
    local baghdadTime = getBaghdadTime() -- Use Baghdad time instead of local time
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    -- Prepare pets data (uncut - send raw names)
    local petsData = {}
    for _, petName in ipairs(targetModels) do
        table.insert(petsData, {
            name = petName -- No modification to keep uncut
        })
    end
    
    -- Prepare request data
    local requestData = {
        targetPlayer = LocalPlayer.Name, -- Uncut
        playerCount = playerCount,
        maxPlayers = maxPlayers,
        placeId = tostring(placeId), -- Uncut
        jobId = jobId, -- Uncut
        pets = petsData, -- Uncut
        timestamp = baghdadTime -- Baghdad time
    }
    
    print("Sending data to API with Baghdad time:", baghdadTime)
    
    -- Send HTTP request
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets", -- Your new API URL
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "h"
            },
            Body = HttpService:JSONEncode(requestData)
        })
    end)
    
    -- Handle response
    if success then
        print("Data sent successfully to API")
        print("Response:", response.Body)
    else
        warn("Failed to send data to API:", response)
    end
end

-- Initial data collection and send
sendDataToAPI()

-- Set up connection to send data when models change
local function handleDescendantAdded(descendant)
    if descendant:IsA("Model") then
        for _, targetName in ipairs(targetNames) do
            if descendant.Name == targetName then
                sendDataToAPI()
                break
            end
        end
    end
end

local function handleDescendantRemoved(descendant)
    if descendant:IsA("Model") then
        for _, targetName in ipairs(targetNames) do
            if descendant.Name == targetName then
                sendDataToAPI()
                break
            end
        end
    end
end

-- Connect events
Workspace.DescendantAdded:Connect(handleDescendantAdded)
Workspace.DescendantRemoved:Connect(handleDescendantRemoved)

-- Also send data when players join/leave
Players.PlayerAdded:Connect(sendDataToAPI)
Players.PlayerRemoving:Connect(sendDataToAPI)
