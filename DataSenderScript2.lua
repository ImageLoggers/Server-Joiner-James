-- DataSenderScript2 (complete)
-- Use as LocalScript or Server Script (recommended: server script).

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- CONFIG
local API_URL = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets"
local AUTH_TOKEN = "h"
local MAX_RETRIES = 3
local RETRY_DELAY = 2
local DEBOUNCE_SECONDS = 6

-- alternate/backup target names (full list)
local targetNames = {
    "Agarrini La Palini", "Alessio", "Ballerino Lololo", "Bombardini Tortinii",
    "Bulbito Bandito Traktorito", "Chimpanzini Spiderini", "Developorini Braziliaspidini",
    "Dul Dul Dul", "Esok Sekolah", "Espresso Signora", "Gattatino Neonino",
    "Graipusseni Medussini", "Karkerkar Kurkur", "Kings Coleslaw",
    "La Vacca Saturno Saturnita", "Las Tralaleritas", "Las Vaquitas Saturnitas",
    "Los Crocodillitos", "Los Orcalitos", "Los Tralaleritos", "Los Tungtungtungcitos",
    "Lucky Block", "Matteo", "Noobini Lasagnini", "Odin Din Din Dun", "Orcalero Orcala",
    "Piccione Macchina", "Racooni Jandelini", "Sammyini Spidreini", "Tralalita Tralala",
    "Secret Lucky Block", "Statutino Libertino", "Tipi Topi Taco", "Torrtuginni Dragonfrutini",
    "Tralalero Tralala", "Trenozosturzzo Turbo 3000", "Trippi Troppi Troppa Trippa",
    "Tukanno Banana", "Tigroligre Frutonni", "Unclito Samito", "Urubini Flamenguini",
    "Job Job Job Sahur", "Blackhole Goat", "Cocofanto Elefanto", "Antonio",
    "Tacorita Bicicleta", "Girafa Celestre", "Gattatino Nyanino", "Chihuanini Taconini",
    "Los Spyderinis", "Trigoligre Frutonni", "Aessio", "Tukanno Bananno",
    "Trenostruzzo Turbo 4000", "Gattito Tacoto", "Las Cappuchinas", "Pakrahmatmamat",
    "Los Bombinitos", "Brr es Teh Patipum", "Bombardini Tortini", "Tractoro Dinosauro",
    "Orcalita Orcala", "Cacasito Satalito", "Tartaruga Cisterna", "Los Tipi Tacos",
    "Piccionetta Macchina", "Mastodontico Telepiedone", "Anpali Babel", "Belula Beluga",
    "La Vacca Staturno Saturnita", "Bisonte Giuppitere", "Sammyni Spyderini",
    "Extinct Tralalero", "Agarrini la Palini", "La Cucaracha", "Capi Taco",
    "Los Chicleteiras", "Los Tacoritas", "Las Sis", "Celularcini Viciosini",
    "Fragola la la la", "Tortuginni Dragonfruitini", "Los Tralaleritos", "Guerriro Digitale",
    "Noo My Hotspot", "Chachechi", "Extinct Matteo", "La Extinct Grande",
    "Extinct Cappuccina", "Sahur Combinasion", "Pot Hotspot", "Chicleteira Bicicleteira",
    "Los Nooo My Hotspotsitos", "La Grande Combinasion", "Los Combinasionas",
    "Nuclearo Dinossauro", "Karkerkar combinasion", "Los Hotspotsitos", "Tralaledon",
    "Ketupat Kepat", "Los Bros", "La Supreme Combinasion", "Ketchuru and Masturu",
    "Garama and Madundung", "Spaghetti Tualetti", "Dragon Cannelloni",
    "Strawberry Elephant", "Corn Corn Corn Sahur", "Graipuss Medussi", "Nooo My Hotspot",
    "Los Matteos"
}

-- internal state
local lastSendTime = 0
local pendingSend = false

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
            local respBody = result.Body or ""
            local decoded
            pcall(function() decoded = HttpService:JSONDecode(respBody) end)
            return true, decoded or respBody
        else
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
    local now = tick()
    if now - lastSendTime < DEBOUNCE_SECONDS then
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
    else
        warn("Failed to send data to API:", resp)
    end
end

pcall(function() sendDataToAPI() end)

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

spawn(function()
    while true do
        wait(60 + math.random(-10,10))
        pcall(function() sendDataToAPI() end)
    end
end)
