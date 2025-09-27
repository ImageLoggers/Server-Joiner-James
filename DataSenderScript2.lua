-- DataSenderScript2.lua
-- Alternate/backup target list. Optimized, cached, throttled, executor-friendly HTTP.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- API config (change if needed)
local API_URL = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets"
local AUTH_HEADER = "h"

-- Alternate/backup target list (DataSenderScript2)
local targetNames = {
    "Agarrini La Palini","Alessio","Ballerino Lololo","Bombardini Tortinii",
    "Bulbito Bandito Traktorito","Chimpanzini Spiderini","Developorini Braziliaspidini",
    "Dul Dul Dul","Esok Sekolah","Espresso Signora","Gattatino Neonino",
    "Graipusseni Medussini","Karkerkar Kurkur","Kings Coleslaw",
    "La Vacca Saturno Saturnita","Las Tralaleritas","Las Vaquitas Saturnitas",
    "Los Crocodillitos","Los Orcalitos","Los Tralaleritos","Los Tungtungtungcitos",
    "Lucky Block","Matteo","Noobini Lasagnini","Odin Din Din Dun","Orcalero Orcala",
    "Piccione Macchina","Racooni Jandelini","Sammyini Spidreini","Tralalita Tralala",
    "Secret Lucky Block","Statutino Libertino","Tipi Topi Taco","Torrtuginni Dragonfrutini",
    "Tralalero Tralala","Trenozosturzzo Turbo 3000","Trippi Troppi Troppa Trippa",
    "Tukanno Banana","Tigroligre Frutonni","Unclito Samito","Urubini Flamenguini",
    "Job Job Job Sahur","Blackhole Goat","Cocofanto Elefanto","Antonio",
    "Tacorita Bicicleta","Girafa Celestre","Gattatino Nyanino","Chihuanini Taconini",
    "Los Spyderinis","Trigoligre Frutonni","Aessio","Tukanno Bananno",
    "Trenostruzzo Turbo 4000","Gattito Tacoto","Las Cappuchinas","Pakrahmatmamat",
    "Los Bombinitos","Brr es Teh Patipum","Bombardini Tortini","Tractoro Dinosauro",
    "Orcalita Orcala","Cacasito Satalito","Tartaruga Cisterna","Los Tipi Tacos",
    "Piccionetta Macchina","Mastodontico Telepiedone","Anpali Babel","Belula Beluga",
    "La Vacca Staturno Saturnita","Bisonte Giuppitere","Sammyni Spyderini",
    "Extinct Tralalero","Agarrini la Palini","La Cucaracha","Capi Taco",
    "Los Chicleteiras","Los Tacoritas","Las Sis","Celularcini Viciosini",
    "Fragola la la la","Tortuginni Dragonfruitini","Los Tralaleritos",
    "Guerriro Digitale","Noo My Hotspot","Chachechi","Extinct Matteo",
    "La Extinct Grande","Extinct Cappuccina","Sahur Combinasion","Pot Hotspot",
    "Chicleteira Bicicleteira","Los Nooo My Hotspotsitos","La Grande Combinasion",
    "Los Combinasionas","Nuclearo Dinossauro","Karkerkar combinasion",
    "Los Hotspotsitos","Tralaledon","Ketupat Kepat","Los Bros",
    "La Supreme Combinasion","Ketchuru and Masturu","Garama and Madundung",
    "Spaghetti Tualetti","Dragon Cannelloni","Strawberry Elephant",
    "Corn Corn Corn Sahur","Graipuss Medussi","Nooo My Hotspot","Los Matteos"
}

-- Build fast lookup
local targetLookup = {}
for _, v in ipairs(targetNames) do
    targetLookup[v] = true
end

-- Cached counts to avoid full rescans each event
local foundCounts = {}

-- Throttle settings
local SEND_INTERVAL = 8
local lastSend = 0

-- Helper: Baghdad time (UTC+3)
local function getBaghdadTime()
    local utcTime = os.time(os.date("!*t"))
    return os.date("%Y-%m-%d %H:%M:%S", utcTime + 3 * 3600)
end

-- Executor-friendly request wrapper
local function executorRequest(opts)
    -- opts: { Url=string, Method=string, Headers=table, Body=string }
    if syn and syn.request then
        return syn.request(opts)
    elseif http_request then
        return http_request(opts)
    elseif request then
        return request(opts)
    else
        -- Fallback to HttpService:RequestAsync (works in Studio/server if enabled)
        local ok, res = pcall(function()
            return HttpService:RequestAsync({
                Url = opts.Url,
                Method = opts.Method or "GET",
                Headers = opts.Headers or {},
                Body = opts.Body or ""
            })
        end)
        if ok then
            return res
        end
        return nil, "no-http-function"
    end
end

-- Build pets array from cache
local function buildPetsArray()
    local arr = {}
    for name, cnt in pairs(foundCounts) do
        if cnt > 0 then
            table.insert(arr, { name = name })
        end
    end
    return arr
end

-- Check for private server UI (same logic used elsewhere)
local function isPrivateServer()
    local privateTextObj
    pcall(function()
        privateTextObj = workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.PrivateText
    end)
    if privateTextObj and privateTextObj:IsA("TextLabel") then
        local function visibleChain(guiObj)
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
        if visibleChain(privateTextObj) and privateTextObj.Text == "Milestones are unavailable in Private Servers." then
            return true
        end
    end
    return false
end

-- Send data (throttled)
local function sendData()
    local now = tick()
    if now - lastSend < SEND_INTERVAL then
        return
    end
    lastSend = now

    if isPrivateServer() then
        -- skip sending from private servers
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
        warn("DataSenderScript2: HTTP send failed.", res)
        return
    end

    pcall(function()
        if type(res) == "table" and res.Body then
            print("DataSenderScript2: sent. response:", tostring(res.Body):sub(1,200))
        else
            print("DataSenderScript2: sent (no response body).")
        end
    end)
end

-- Model added handler (updates cache)
local function onModelAdded(model)
    if not model or not model:IsA("Model") then return end
    local name = model.Name
    if targetLookup[name] then
        foundCounts[name] = (foundCounts[name] or 0) + 1
        sendData()
    end
end

-- Model removed handler (updates cache)
local function onModelRemoved(model)
    if not model or not model:IsA("Model") then return end
    local name = model.Name
    if targetLookup[name] and foundCounts[name] and foundCounts[name] > 0 then
        foundCounts[name] = foundCounts[name] - 1
        if foundCounts[name] <= 0 then
            foundCounts[name] = nil
        end
        sendData()
    end
end

-- Initial lightweight scan to populate cache
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and targetLookup[obj.Name] then
        foundCounts[obj.Name] = (foundCounts[obj.Name] or 0) + 1
    end
end

-- Connect events
Workspace.DescendantAdded:Connect(onModelAdded)
Workspace.DescendantRemoving:Connect(onModelRemoved)
Players.PlayerAdded:Connect(function() sendData() end)
Players.PlayerRemoving:Connect(function() sendData() end)

-- Periodic backup send in case events missed something
spawn(function()
    while true do
        wait(30 + math.random() * 10)
        sendData()
    end
end)
