-- DataSenderScript2 (complete, fixed payload, executor-only HTTP)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- API config (replace if needed)
local API_URL = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets"
local AUTH_HEADER = "h"

-- Target list (alternate/backup list)
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

-- Fast membership lookup
local targetLookup = {}
for _, name in ipairs(targetNames) do
    targetLookup[name] = true
end

-- Cache counts as lightweight state
local foundCounts = {}

-- Throttle settings
local SEND_INTERVAL = 8 -- seconds
local lastSend = 0

-- Helper: Baghdad time (UTC+3)
local function getBaghdadTime()
    local utcTime = os.time(os.date("!*t"))
    return os.date("%Y-%m-%d %H:%M:%S", utcTime + 3 * 3600)
end

-- Executor-only request: try syn.request / http_request / request
local function executorRequest(opts)
    -- opts = { Url=..., Method=..., Headers=..., Body=... }
    if syn and syn.request then
        local ok, res = pcall(function() return syn.request(opts) end)
        if ok then return res end
        return nil, res
    end
    if http_request then
        local ok, res = pcall(function() return http_request(opts) end)
        if ok then return res end
        return nil, res
    end
    if request then
        local ok, res = pcall(function() return request(opts) end)
        if ok then return res end
        return nil, res
    end
    -- If we reach here, executor doesn't support outbound HTTP
    return nil, "no-executor-http"
end

-- Build pets array as [{name="..."},...]
local function buildPetsArray()
    local arr = {}
    for name, cnt in pairs(foundCounts) do
        if cnt and cnt > 0 then
            table.insert(arr, { name = tostring(name) })
        end
    end
    return arr
end

-- Private server check (same as your other scripts)
local function isPrivateServer()
    local privateTextObj
    pcall(function()
        privateTextObj = workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.PrivateText
    end)
    if privateTextObj and privateTextObj:IsA("TextLabel") then
        local function visibleChain(g)
            if not g.Visible then return false end
            local p = g.Parent
            while p do
                if p:IsA("GuiObject") and not p.Visible then return false end
                p = p.Parent
            end
            return true
        end
        if visibleChain(privateTextObj) and privateTextObj.Text == "Milestones are unavailable in Private Servers." then
            return true
        end
    end
    return false
end

-- Build and send payload (throttled, executor-only)
local function sendData()
    local now = tick()
    if now - lastSend < SEND_INTERVAL then return end
    lastSend = now

    if isPrivateServer() then
        print("DataSenderScript2: detected private server — skipping send")
        return
    end

    -- Ensure required fields are present and typed correctly
    local payload = {
        targetPlayer = tostring((LocalPlayer and LocalPlayer.Name) or "Unknown"),
        playerCount = tonumber(#Players:GetPlayers()) or 0,
        maxPlayers = tonumber(Players.MaxPlayers) or 0,
        placeId = tostring(game.PlaceId or "0"),
        jobId = tostring(game.JobId or "0"),
        pets = buildPetsArray(),
        timestamp = tostring(getBaghdadTime())
    }

    -- Ensure pets is always an array (may be empty)
    if not payload.pets then payload.pets = {} end

    local body = HttpService:JSONEncode(payload)

    local opts = {
        Url = API_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = AUTH_HEADER
        },
        Body = body
    }

    local res, err = executorRequest(opts)
    if not res then
        if err == "no-executor-http" then
            warn("DataSenderScript2: executor does not expose HTTP functions (syn.request/http_request/request). Cannot send.")
        else
            warn("DataSenderScript2: HTTP request failed:", tostring(err))
        end
        return
    end

    -- Normalize response reporting
    pcall(function()
        if type(res) == "table" and res.Body then
            print("DataSenderScript2: sent. response:", tostring(res.Body))
        else
            print("DataSenderScript2: sent (no body).")
        end
    end)
end

-- Handlers to update cache and trigger send
local function onModelAdded(model)
    if not model or not model:IsA("Model") then return end
    local name = model.Name
    if targetLookup[name] then
        foundCounts[name] = (foundCounts[name] or 0) + 1
        sendData()
    end
end

local function onModelRemoved(model)
    if not model or not model:IsA("Model") then return end
    local name = model.Name
    if targetLookup[name] and foundCounts[name] and foundCounts[name] > 0 then
        foundCounts[name] = foundCounts[name] - 1
        if foundCounts[name] <= 0 then foundCounts[name] = nil end
        sendData()
    end
end

-- Initial lightweight scan to populate foundCounts
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

-- Periodic backup send
spawn(function()
    while true do
        wait(30 + math.random() * 10)
        sendData()
    end
end)
