-- DataSenderScript1.lua
-- Scans for an expanded list of target models, caches results, and posts to your API.
-- Tries syn.request / http_request / request (executor bypass). Falls back to HttpService when available.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local API_URL = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets"
local AUTH_HEADER = "h"

-- Expanded target list (DataSenderScript1)
local targetNames = {
    "Chicleteira Bicicleteira","Dragon Cannelloni","Garama and Madundung","Graipuss Medussi",
    "La Grande Combinasio","La Supreme Combinasion","Los Combinasionas","Los Hotspotsitos",
    "Los Matteos","Nooo My Hotspot","Los Noo My Hotspotsitos","Nuclearo Dinossauro",
    "Pot Hotspot","Cocofanto Elefanto","Antonio","Tacorita Bicicleta","Girafa Celestre",
    "Gattatino Nyanino","Chihuanini Taconini","Matteo","Los Spyderinis","Tralalero Tralala",
    "Los Crocodillitos","Trigoligre Frutonni","Espresso Signora","Odin Din Din Dun",
    "Statutino Libertino","Tipi Topi Taco","Unclito Samito","Aessio","Orcalero Orcala",
    "Tralalita Tralala","Tukanno Bananno","Trenostruzzo Turbo 3000","Urubini Flamenguini",
    "Gattito Tacoto","Trippi Troppi Troppa Trippa","Las Cappuchinas","Ballerino Lololo",
    "Bulbito Bandito Traktorito","Los Tungtungtungcitos","Pakrahmatmamat","Los Bombinitos",
    "Brr es Teh Patipum","Piccione Macchina","Bombardini Tortini","Tractoro Dinosauro",
    "Los Orcalitos","Orcalita Orcala","Cacasito Satalito","Tartaruga Cisterna",
    "Los Tipi Tacos","Piccionetta Macchina","Mastodontico Telepiedone","Anpali Babel",
    "Belula Beluga","La Vacca Staturno Saturnita","Bisonte Giuppitere","Karkerkar Kurkur",
    "Trenostruzzo Turbo 4000","Sammyni Spyderini","Torrtuginni Dragonfrutini","Dul Dul Dul",
    "Extinct Tralalero","Blackhole Goat","Agarrini la Palini","La Cucaracha","Capi Taco",
    "Los Chicleteiras","Los Tacoritas","Las Sis","Celularcini Viciosini","Fragola la la la",
    "Chimpanzini Spiderini","Tortuginni Dragonfruitini","Los Tralaleritos","Guerriro Digitale",
    "Las Tralaleritas","Job Job Job Sahur","Las Vaquitas Saturnitas","Noo My Hotspot",
    "Chachechi","Extinct Matteo","La Extinct Grande","Extinct Cappuccina","Sahur Combinasion",
    "Los Nooo My Hotspotsitos","Karkerkar combinasion","Tralaledon","Esok Sekolah",
    "Ketupat Kepat","Los Bros","Ketchuru and Masturu","Spaghetti Tualetti",
    "Strawberry Elephant","Corn Corn Corn Sahur"
}

-- build lookup for O(1) checks
local targetLookup = {}
for _, name in ipairs(targetNames) do targetLookup[name] = true end

-- cached map: name -> count (handles duplicates and fast membership)
local foundCounts = {}

-- throttle/debounce
local lastSend = 0
local SEND_INTERVAL = 8 -- seconds minimum between sends

-- helper: Baghdad time (UTC+3)
local function getBaghdadTime()
    local utcTime = os.time(os.date("!*t"))
    return os.date("%Y-%m-%d %H:%M:%S", utcTime + 3 * 3600)
end

-- helper: executor-friendly request
local function executorRequest(opts)
    -- opts = {Url, Method, Headers, Body}
    if syn and syn.request then
        return syn.request(opts)
    elseif http_request then
        return http_request(opts)
    elseif request then
        return request(opts)
    else
        -- fallback to HttpService:RequestAsync if allowed (Studio or server)
        local ok, res = pcall(function()
            return HttpService:RequestAsync({
                Url = opts.Url,
                Method = opts.Method or "GET",
                Headers = opts.Headers or {},
                Body = opts.Body or ""
            })
        end)
        if ok then return res end
        return nil, "no-http-function"
    end
end

-- build pets array from foundCounts
local function buildPetsArray()
    local arr = {}
    for name, count in pairs(foundCounts) do
        if count > 0 then
            -- push name multiple times? your server expects list of objects; we push each name once for clarity
            table.insert(arr, { name = name })
        end
    end
    return arr
end

-- send data (throttled)
local function sendData()
    local now = tick()
    if now - lastSend < SEND_INTERVAL then return end
    lastSend = now

    -- skip if private server GUI exists
    local isPrivate = false
    pcall(function()
        local privateText = workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.PrivateText
        if privateText and privateText:IsA("TextLabel") then
            -- check visible chain
            local function visibleChain(g)
                if not g.Visible then return false end
                local p = g.Parent
                while p do
                    if p:IsA("GuiObject") and not p.Visible then return false end
                    p = p.Parent
                end
                return true
            end
            if visibleChain(privateText) and privateText.Text == "Milestones are unavailable in Private Servers." then
                isPrivate = true
            end
        end
    end)
    if isPrivate then
        -- avoid sending from private servers
        return
    end

    local pets = buildPetsArray()
    local data = {
        targetPlayer = (LocalPlayer and LocalPlayer.Name) or "Unknown",
        playerCount = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers,
        placeId = tostring(game.PlaceId),
        jobId = tostring(game.JobId),
        pets = pets,
        timestamp = getBaghdadTime()
    }

    local body = HttpService:JSONEncode(data)
    local opts = {
        Url = API_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = AUTH_HEADER
        },
        Body = body
    }

    local ok, res = pcall(function() return executorRequest(opts) end)
    if not ok or not res then
        warn("DataSenderScript1: HTTP send failed.", res)
        return
    end

    -- executorRequest for syn returns a table; HttpService returns table-like
    -- print small confirmation (avoid huge bodies)
    pcall(function()
        if type(res) == "table" and res.Body then
            print("DataSenderScript1: sent. response:", tostring(res.Body):sub(1,200))
        else
            print("DataSenderScript1: sent (no response body).")
        end
    end)
end

-- update cache when a model is added
local function onModelAdded(model)
    if not model or not model:IsA("Model") then return end
    local n = model.Name
    if targetLookup[n] then
        foundCounts[n] = (foundCounts[n] or 0) + 1
        sendData()
    end
end

-- update cache when a model is removed
local function onModelRemoved(model)
    if not model or not model:IsA("Model") then return end
    local n = model.Name
    if targetLookup[n] and foundCounts[n] and foundCounts[n] > 0 then
        foundCounts[n] = foundCounts[n] - 1
        if foundCounts[n] <= 0 then foundCounts[n] = nil end
        sendData()
    end
end

-- initial scan (lightweight)
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and targetLookup[obj.Name] then
        foundCounts[obj.Name] = (foundCounts[obj.Name] or 0) + 1
    end
end

-- connect events
Workspace.DescendantAdded:Connect(function(d) onModelAdded(d) end)
Workspace.DescendantRemoving:Connect(function(d) onModelRemoved(d) end)
Players.PlayerAdded:Connect(function() sendData() end)
Players.PlayerRemoving:Connect(function() sendData() end)

-- periodic backup send in case events miss something
spawn(function()
    while true do
        wait(30 + math.random() * 10)
        sendData()
    end
end)
