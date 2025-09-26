-- DataSenderScript1 (complete)
-- Place this in a LocalScript or Server Script depending on your setup.
-- Recommended: move to ServerScriptService and enable HttpService for reliability.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- CONFIG
local API_URL = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets"
local AUTH_TOKEN = "h" -- replace with your real token if any
local MAX_RETRIES = 3
local RETRY_DELAY = 2 -- seconds, multiplied per retry
local DEBOUNCE_SECONDS = 6 -- don't spam API more often than this

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

-- internal state
local lastSendTime = 0
local pendingSend = false

-- UTIL: check if GUI message indicating private server exists (client-only path)
local function isPrivateServer()
    local ok, privateTextObj = pcall(function()
        return workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.PrivateText
    end)
    if not ok or not privateTextObj then return false end
    if privateTextObj:IsA("TextLabel") then
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

local function buildRequestData()
    local targetModels = getTargetModels()
    local petsData = {}
    for _, petName in ipairs(targetModels) do
        table.insert(petsData, { name = petName })
    end
    local requestData = {
        targetPlayer = (Players.LocalPlayer and Players.LocalPlayer.Name) or "Unknown",
        playerCount = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers,
        placeId = tostring(game.PlaceId),
        jobId = tostring(game.JobId),
        pets = petsData,
        timestamp = getBaghdadTime()
    }
    return requestData
end

local function sendHttp(payload)
    if not API_URL or API_URL == "" then
        warn("API_URL not configured")
        return false, "no-url"
    end

    local headers = {
        ["Content-Type"] = "application/json",
    }
    if AUTH_TOKEN and AUTH_TOKEN ~= "" then
        headers["Authorization"] = AUTH_TOKEN
    end

    local body = HttpService:JSONEncode(payload)
    local attempt = 0
    while attempt < MAX_RETRIES do
        attempt = attempt + 1
        local success, result = pcall(function()
            return HttpService:RequestAsync({
                Url = API_URL,
                Method = "POST",
                Headers = headers,
                Body = body,
                Timeout = 15,
            })
        end)

        if success and result and (result.Success == true or (result.StatusCode and tonumber(result.StatusCode) and tonumber(result.StatusCode) >= 200 and tonumber(result.StatusCode) < 300)) then
            -- If the API returned a Body string, try to decode safely
            local respBody = result.Body or ""
            local decoded
            pcall(function() decoded = HttpService:JSONDecode(respBody) end)
            return true, decoded or respBody
        else
            -- Retry with exponential backoff
            local err = result or "unknown error"
            warn(("HTTP attempt %d failed: %s"):format(attempt, tostring(err)))
            if attempt < MAX_RETRIES then
                wait(RETRY_DELAY * attempt)
            else
                return false, err
            end
        end
    end
    return false, "max attempts reached"
end

local function sendDataToAPI()
    -- Debounce
    local now = tick()
    if now - lastSendTime < DEBOUNCE_SECONDS then
        -- schedule a deferred send if not already pending
        if not pendingSend then
            pendingSend = true
            spawn(function()
                wait(DEBOUNCE_SECONDS - (now - lastSendTime))
                pendingSend = false
                sendDataToAPI()
            end)
        end
        return
    end
    lastSendTime = now

    -- Early skips
    if isPrivateServer() then
        print("Private server detected - skipping API call")
        return
    end
    if isServerFull() then
        print("Server is full - skipping API call")
        return
    end

    local payload = buildRequestData()
    print("Sending data to API with Baghdad time:", payload.timestamp)
    local ok, resp = sendHttp(payload)
    if ok then
        print("Data sent successfully")
        -- optional: print(resp) but careful with big responses
    else
        warn("Failed to send data to API:", resp)
    end
end

-- initial send (wrapped in pcall to be safe in different environments)
pcall(function() sendDataToAPI() end)

-- Listen for relevant events: models added/removed and players join/leave
Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") then
        for _, t in ipairs(targetNames) do
            if descendant.Name == t then
                sendDataToAPI()
                break
            end
        end
    end
end)

Workspace.DescendantRemoving:Connect(function(descendant)
    if descendant:IsA("Model") then
        for _, t in ipairs(targetNames) do
            if descendant.Name == t then
                sendDataToAPI()
                break
            end
        end
    end
end)

Players.PlayerAdded:Connect(function() sendDataToAPI() end)
Players.PlayerRemoving:Connect(function() sendDataToAPI() end)

-- Keep alive/heartbeat occasionally to update server data (not often)
spawn(function()
    while true do
        wait(60 + math.random(-10,10))
        pcall(function() sendDataToAPI() end)
    end
end)
