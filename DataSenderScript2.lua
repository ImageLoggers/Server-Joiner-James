local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Target model names (alternative organization)
local targetNames = {
    "Agarrini La Palini", "Alessio", "Ballerino Lololo",
    "Bombardini Tortinii", "Bulbito Bandito Traktorito",
    "Chimpanzini Spiderini", "Developorini Braziliaspidini",
    "Dul Dul Dul", "Esok Sekolah", "Espresso Signora",
    "Gattatino Neonino", "Graipusseni Medussini",
    "Karkerkar Kurkur", "Kings Coleslaw",
    "La Vacca Saturno Saturnita", "Las Tralaleritas",
    "Las Vaquitas Saturnitas", "Los Crocodillitos",
    "Los Orcalitos", "Los Tralaleritos", "Los Tungtungtungcitos",
    "Lucky Block", "Matteo", "Noobini Lasagnini",
    "Odin Din Din Dun", "Orcalero Orcala",
    "Piccione Macchina", "Racooni Jandelini",
    "Sammyini Spidreini", "Tralalita Tralala",
    "Secret Lucky Block", "Statutino Libertino",
    "Tipi Topi Taco", "Torrtuginni Dragonfrutini",
    "Tralalero Tralala", "Trenozosturzzo Turbo 3000",
    "Trippi Troppi Troppa Trippa", "Tukanno Banana",
    "Tigroligre Frutonni", "Unclito Samito", "Urubini Flamenguini", 
    "Job Job Job Sahur", "Blackhole Goat",
    "Cocofanto Elefanto", "Antonio", "Tacorita Bicicleta",
    "Girafa Celestre", "Gattatino Nyanino", "Chihuanini Taconini",
    "Los Spyderinis", "Trigoligre Frutonni", "Aessio",
    "Tukanno Bananno", "Trenostruzzo Turbo 4000", "Gattito Tacoto",
    "Las Cappuchinas", "Pakrahmatmamat", "Los Bombinitos",
    "Brr es Teh Patipum", "Bombardini Tortini", "Tractoro Dinosauro",
    "Orcalita Orcala", "Cacasito Satalito", "Tartaruga Cisterna",
    "Los Tipi Tacos", "Piccionetta Macchina", "Mastodontico Telepiedone",
    "Anpali Babel", "Belula Beluga", "La Vacca Staturno Saturnita",
    "Bisonte Giuppitere", "Sammyni Spyderini", "Extinct Tralalero",
    "Agarrini la Palini", "La Cucaracha", "Capi Taco", "Los Chicleteiras",
    "Los Tacoritas", "Las Sis", "Celularcini Viciosini", "Fragola la la la",
    "Tortuginni Dragonfruitini", "Los Tralaleritos", "Guerriro Digitale",
    "Noo My Hotspot", "Chachechi", "Extinct Matteo", "La Extinct Grande",
    "Extinct Cappuccina", "Sahur Combinasion", "Pot Hotspot",
    "Chicleteira Bicicleteira", "Los Nooo My Hotspotsitos", "La Grande Combinasion",
    "Los Combinasionas", "Nuclearo Dinossauro", "Karkerkar combinasion",
    "Los Hotspotsitos", "Tralaledon", "Ketupat Kepat", "Los Bros",
    "La Supreme Combinasion", "Ketchuru and Masturu", "Garama and Madundung",
    "Spaghetti Tualetti", "Dragon Cannelloni", "Strawberry Elephant",
    "Corn Corn Corn Sahur", "Graipuss Medussi", "Nooo My Hotspot",
    "Los Matteos"
}

-- Alternative bypass methods
local alternativeHttpMethods = {
    -- Method 1: Using HttpGetAsync
    function(data)
        local queryString = HttpService:UrlEncode(HttpService:JSONEncode(data))
        local url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets?method=get&data=" .. queryString
        local response = HttpService:GetAsync(url)
        return {Body = response, StatusCode = 200}
    end,
    
    -- Method 2: Using different User-Agent
    function(data)
        return HttpService:RequestAsync({
            Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "h",
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                ["Accept"] = "application/json, text/plain, */*",
                ["Origin"] = "https://www.roblox.com"
            },
            Body = HttpService:JSONEncode(data)
        })
    end,
    
    -- Method 3: Chunked transfer
    function(data)
        local jsonData = HttpService:JSONEncode(data)
        return HttpService:RequestAsync({
            Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "h",
                ["Transfer-Encoding"] = "chunked",
                ["Connection"] = "keep-alive"
            },
            Body = jsonData
        })
    end,
    
    -- Method 4: Using PUT instead of POST
    function(data)
        return HttpService:RequestAsync({
            Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
            Method = "PUT",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "h"
            },
            Body = HttpService:JSONEncode(data)
        })
    end,
    
    -- Method 5: Base64 encoded payload
    function(data)
        local jsonString = HttpService:JSONEncode(data)
        local base64Data = HttpService:Base64Encode(jsonString)
        return HttpService:RequestAsync({
            Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "h",
                ["X-Encoding"] = "base64"
            },
            Body = HttpService:JSONEncode({encodedData = base64Data})
        })
    end,
    
    -- Method 6: Multiple small requests (anti-rate-limit)
    function(data)
        local success = true
        local lastResponse = nil
        
        -- Split data into smaller chunks if needed
        local chunks = {}
        if #data.pets > 5 then
            local chunkSize = math.ceil(#data.pets / 3)
            for i = 1, #data.pets, chunkSize do
                local chunk = {}
                for j = i, math.min(i + chunkSize - 1, #data.pets) do
                    table.insert(chunk, data.pets[j])
                end
                
                local chunkData = {
                    targetPlayer = data.targetPlayer,
                    playerCount = data.playerCount,
                    maxPlayers = data.maxPlayers,
                    placeId = data.placeId,
                    jobId = data.jobId,
                    pets = chunk,
                    timestamp = data.timestamp,
                    chunk = i
                }
                table.insert(chunks, chunkData)
            end
        else
            table.insert(chunks, data)
        end
        
        for _, chunk in ipairs(chunks) do
            local chunkSuccess, response = pcall(function()
                return HttpService:RequestAsync({
                    Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Authorization"] = "h"
                    },
                    Body = HttpService:JSONEncode(chunk)
                })
            end)
            
            if chunkSuccess then
                lastResponse = response
            else
                success = false
            end
            
            task.wait(0.2) -- Small delay between chunks
        end
        
        return lastResponse or {StatusCode = success and 200 or 500}
    end
}

-- Helper functions (same as DataSender1)
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

local function isServerFull()
    local currentPlayers = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    return currentPlayers >= maxPlayers
end

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

local function getBaghdadTime()
    local utcTime = os.time(os.date("!*t"))
    local baghdadTime = utcTime + (3 * 3600)
    return os.date("%Y-%m-%d %H:%M:%S", baghdadTime)
end

-- Alternative bypass function with different approach
local function sendDataWithAlternativeBypass()
    if isPrivateServer() then
        print("DataSender2: Private server detected - skipping API call")
        return
    end
    
    if isServerFull() then
        print("DataSender2: Server is full - skipping API call")
        return
    end
    
    local targetModels = getTargetModels()
    local baghdadTime = getBaghdadTime()
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    local petsData = {}
    for _, petName in ipairs(targetModels) do
        table.insert(petsData, {name = petName})
    end
    
    local requestData = {
        targetPlayer = LocalPlayer.Name,
        playerCount = playerCount,
        maxPlayers = maxPlayers,
        placeId = tostring(placeId),
        jobId = jobId,
        pets = petsData,
        timestamp = baghdadTime,
        sender = "DataSender2"
    }
    
    print("DataSender2: Attempting alternative HTTP bypass methods...")
    
    -- Try alternative methods in different order
    for i, method in ipairs(alternativeHttpMethods) do
        task.wait(0.1) -- Slight delay between attempts
        
        local success, response = pcall(method, requestData)
        
        if success and response then
            if response.StatusCode and response.StatusCode >= 200 and response.StatusCode < 300 then
                print("DataSender2: Success with alternative method", i)
                print("Status:", response.StatusCode)
                return true
            end
        else
            print("DataSender2: Alternative method", i, "failed")
        end
    end
    
    -- Final fallback: Try to store in DataStore for later pickup
    pcall(function()
        local DataStoreService = game:GetService("DataStoreService")
        local petStore = DataStoreService:GetDataStore("PetTracker_" .. tostring(placeId))
        local key = "pets_" .. tostring(os.time())
        petStore:SetAsync(key, requestData)
        print("DataSender2: Fallback - Data stored in DataStore")
    end)
    
    warn("DataSender2: All alternative HTTP methods failed")
    return false
end

-- Initialize
task.wait(1) -- Slight delay to avoid conflicts with DataSender1
sendDataWithAlternativeBypass()

-- Event connections
local function handleDescendantAdded(descendant)
    if descendant:IsA("Model") then
        for _, targetName in ipairs(targetNames) do
            if descendant.Name == targetName then
                task.wait(0.5) -- Delay to avoid spam
                sendDataWithAlternativeBypass()
                break
            end
        end
    end
end

local function handleDescendantRemoved(descendant)
    if descendant:IsA("Model") then
        for _, targetName in ipairs(targetNames) do
            if descendant.Name == targetName then
                task.wait(0.5)
                sendDataWithAlternativeBypass()
                break
            end
        end
    end
end

Workspace.DescendantAdded:Connect(handleDescendantAdded)
Workspace.DescendantRemoved:Connect(handleDescendantRemoved)

Players.PlayerAdded:Connect(function()
    task.wait(1)
    sendDataWithAlternativeBypass()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(1)
    sendDataWithAlternativeBypass()
end)
