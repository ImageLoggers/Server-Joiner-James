local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Target model names (alternative/backup list with all pets)
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

-- Send data to API using CORS proxy
local function sendDataToAPI()
    -- Check if we should skip sending data
    if isPrivateServer() then
        print("🇵🇭 Private server detected - skipping API call")
        return
    end
    
    if isServerFull() then
        print("🇵🇭 Server is full - skipping API call")
        return
    end
    
    -- Collect data
    local targetModels = getTargetModels()
    local philippineTime = getPhilippineTime()
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    -- Only send if we found pets
    if #targetModels == 0 then
        print("🇵🇭 No target pets found - skipping API call")
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
        placeId = tostring(placeId),
        jobId = jobId,
        pets = petsData,
        timestamp = philippineTime,
        scriptVersion = "DataSenderScript2"
    }
    
    print("🇵🇭 Sending data to API with Philippine time:", philippineTime)
    print("🇵🇭 Pets found:", #targetModels, "Players:", playerCount .. "/" .. maxPlayers)
    
    -- Try multiple CORS proxies in sequence
    local proxies = {
        "https://corsproxy.io/?url=",  -- Primary proxy
        "https://api.codetabs.com/v1/proxy?quest=",  -- Backup proxy 1
        "https://cors-anywhere.herokuapp.com/"  -- Backup proxy 2
    }
    
    local targetUrl = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets"
    local success = false
    local lastError = ""
    
    for i, proxy in ipairs(proxies) do
        local proxyUrl = proxy .. HttpService:UrlEncode(targetUrl)
        
        local proxySuccess, response = pcall(function()
            return HttpService:RequestAsync({
                Url = proxyUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "h",
                    ["X-Requested-With"] = "XMLHttpRequest"
                },
                Body = HttpService:JSONEncode(requestData)
            })
        end)
        
        if proxySuccess then
            if response.Success then
                print("✅ Data sent successfully via proxy " .. i)
                print("Response:", response.Body)
                success = true
                break
            else
                lastError = "Proxy " .. i .. " returned error: " .. tostring(response.StatusCode)
                warn("❌ " .. lastError)
            end
        else
            lastError = "Proxy " .. i .. " failed: " .. tostring(response)
            warn("❌ " .. lastError)
        end
        
        -- Wait before trying next proxy
        if i < #proxies then
            wait(1)
        end
    end
    
    if not success then
        -- Final attempt: direct connection (in case proxies are down)
        local directSuccess, directResponse = pcall(function()
            return HttpService:RequestAsync({
                Url = targetUrl .. "?t=" .. tick(),  -- Cache buster
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "h"
                },
                Body = HttpService:JSONEncode(requestData)
            })
        end)
        
        if directSuccess and directResponse.Success then
            print("✅ Data sent successfully via direct connection")
            success = true
        else
            warn("❌ All methods failed. Last error: " .. lastError)
        end
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

print("🇵🇭 DataSenderScript2 loaded with Philippine Time (UTC+8) and CORS proxy")
