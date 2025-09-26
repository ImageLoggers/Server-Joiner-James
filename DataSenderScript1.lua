local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Target model names (expanded list)
local targetNames = {
    "Chicleteira Bicicleteira", "Dragon Cannelloni", "Garama and Madundung",
    "Graipuss Medussi", "La Grande Combinasio", "La Supreme Combinasion",
    "Los Combinasionas", "Los Hotspotsitos", "Los Matteos", "Nooo My Hotspot",
    "Los Noo My Hotspotsitos", "Nuclearo Dinossauro", "Pot Hotspot",
    "Cocofanto Elefanto", "Antonio", "Tacorita Bicicleta", "Girafa Celestre",
    "Gattatino Nyanino", "Chihuanini Taconini", "Matteo", "Los Spyderinis",
    "Tralalero Tralala", "Los Crocodillitos", "Trigoligre Frutonni",
    "Espresso Signora", "Odin Din Din Dun", "Statutino Libertino",
    "Tipi Topi Taco", "Unclito Samito", "Aessio", "Orcalero Orcala",
    "Tralalita Tralala", "Tukanno Bananno", "Trenostruzzo Turbo 3000",
    "Urubini Flamenguini", "Gattito Tacoto", "Trippi Troppi Troppa Trippa",
    "Las Cappuchinas", "Ballerino Lololo", "Bulbito Bandito Traktorito",
    "Los Tungtungtungcitos", "Pakrahmatmamat", "Los Bombinitos",
    "Brr es Teh Patipum", "Piccione Macchina", "Bombardini Tortini",
    "Tractoro Dinosauro", "Los Orcalitos", "Orcalita Orcala", "Cacasito Satalito",
    "Tartaruga Cisterna", "Los Tipi Tacos", "Piccionetta Macchina",
    "Mastodontico Telepiedone", "Anpali Babel", "Belula Beluga",
    "La Vacca Staturno Saturnita", "Bisonte Giuppitere", "Karkerkar Kurkur",
    "Trenostruzzo Turbo 4000", "Sammyni Spyderini", "Torrtuginni Dragonfrutini",
    "Dul Dul Dul", "Extinct Tralalero", "Blackhole Goat", "Agarrini la Palini",
    "La Cucaracha", "Capi Taco", "Los Chicleteiras", "Los Tacoritas", "Las Sis",
    "Celularcini Viciosini", "Fragola la la la", "Chimpanzini Spiderini",
    "Tortuginni Dragonfruitini", "Los Tralaleritos", "Guerriro Digitale",
    "Las Tralaleritas", "Job Job Job Sahur", "Las Vaquitas Saturnitas",
    "Noo My Hotspot", "Chachechi", "Extinct Matteo", "La Extinct Grande",
    "Extinct Cappuccina", "Sahur Combinasion", "Los Nooo My Hotspotsitos",
    "Karkerkar combinasion", "Tralaledon", "Esok Sekolah", "Ketupat Kepat",
    "Los Bros", "Ketchuru and Masturu", "Spaghetti Tualetti",
    "Strawberry Elephant", "Corn Corn Corn Sahur"
}

-- Multiple HTTP bypass methods
local httpMethods = {
    -- Method 1: Direct API call
    function(data)
        return HttpService:RequestAsync({
            Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "h"
            },
            Body = HttpService:JSONEncode(data)
        })
    end,
    
    -- Method 2: Using proxy service
    function(data)
        local proxyUrl = "https://rprxy.herokuapp.com/https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets"
        return HttpService:RequestAsync({
            Url = proxyUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "h"
            },
            Body = HttpService:JSONEncode(data)
        })
    end,
    
    -- Method 3: Using alternative proxy
    function(data)
        local proxyUrl = "https://cors-anywhere.herokuapp.com/https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets"
        return HttpService:RequestAsync({
            Url = proxyUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "h",
                ["X-Requested-With"] = "XMLHttpRequest"
            },
            Body = HttpService:JSONEncode(data)
        })
    end,
    
    -- Method 4: Using HttpGet with URL encoding (fallback)
    function(data)
        local encodedData = HttpService:UrlEncode(HttpService:JSONEncode(data))
        local getUrl = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets?data=" .. encodedData
        return {
            Body = game:HttpGet(getUrl),
            Success = true,
            StatusCode = 200
        }
    end,
    
    -- Method 5: Using alternative endpoint
    function(data)
        return HttpService:PostAsync(
            "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false,
            {["Authorization"] = "h"}
        )
    end
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
    local baghdadTime = utcTime + (3 * 3600)
    return os.date("%Y-%m-%d %H:%M:%S", baghdadTime)
end

-- Advanced HTTP bypass function
local function sendDataWithBypass()
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
    local baghdadTime = getBaghdadTime()
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    -- Prepare pets data
    local petsData = {}
    for _, petName in ipairs(targetModels) do
        table.insert(petsData, {name = petName})
    end
    
    -- Prepare request data
    local requestData = {
        targetPlayer = LocalPlayer.Name,
        playerCount = playerCount,
        maxPlayers = maxPlayers,
        placeId = tostring(placeId),
        jobId = jobId,
        pets = petsData,
        timestamp = baghdadTime,
        bypass = "method1" -- Track which method worked
    }
    
    print("Attempting to send data with bypass methods...")
    
    -- Try each HTTP method until one works
    for i, method in ipairs(httpMethods) do
        local success, response = pcall(method, requestData)
        
        if success then
            if type(response) == "string" then
                -- Handle PostAsync response
                print("Data sent successfully using method", i, "- PostAsync")
                print("Response:", response)
                return true
            elseif response.StatusCode and response.StatusCode >= 200 and response.StatusCode < 300 then
                print("Data sent successfully using method", i)
                print("Status Code:", response.StatusCode)
                print("Response:", response.Body)
                return true
            end
        else
            print("Method", i, "failed:", tostring(response))
        end
        
        -- Small delay between attempts
        task.wait(0.1)
    end
    
    -- If all methods fail, try a simple webhook as last resort
    local webhookSuccess = pcall(function()
        local simpleData = string.format(
            "Player: %s | Pets: %d | Server: %d/%d | Time: %s | Place: %s",
            LocalPlayer.Name, #targetModels, playerCount, maxPlayers, baghdadTime, tostring(placeId)
        )
        
        -- Try a generic webhook service
        local webhookUrl = "https://webhook.site/unique-id-here" -- Replace with your webhook.site URL
        return HttpService:RequestAsync({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "text/plain"},
            Body = simpleData
        })
    end)
    
    if webhookSuccess then
        print("Data sent via webhook fallback")
        return true
    end
    
    warn("All HTTP bypass methods failed")
    return false
end

-- Initial data collection and send
sendDataWithBypass()

-- Set up connection to send data when models change
local function handleDescendantAdded(descendant)
    if descendant:IsA("Model") then
        for _, targetName in ipairs(targetNames) do
            if descendant.Name == targetName then
                sendDataWithBypass()
                break
            end
        end
    end
end

local function handleDescendantRemoved(descendant)
    if descendant:IsA("Model") then
        for _, targetName in ipairs(targetNames) do
            if descendant.Name == targetName then
                sendDataWithBypass()
                break
            end
        end
    end
end

-- Connect events
Workspace.DescendantAdded:Connect(handleDescendantAdded)
Workspace.DescendantRemoved:Connect(handleDescendantRemoved)

-- Also send data when players join/leave
Players.PlayerAdded:Connect(sendDataWithBypass)
Players.PlayerRemoving:Connect(sendDataWithBypass)
