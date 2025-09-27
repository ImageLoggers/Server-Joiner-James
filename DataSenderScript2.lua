-- DataSenderScript2.lua
-- Alternate/backup target list. Also optimized + executor HTTP bypass like Script1.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

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

-- lookup + cache
local targetLookup = {}
for _, name in ipairs(targetNames) do targetLookup[name] = true end

local foundCounts = {}
local lastSend = 0
local SEND_INTERVAL = 8

local function getBaghdadTime()
    local utcTime = os.time(os.date("!*t"))
    return os.date("%Y-%m-%d %H:%M:%S", utcTime + 3 * 3600)
end

local function executorRequest(opts)
    if syn and syn.request then
        return syn.request(opts)
    elseif http_request then
        return http_request(opts)
    elseif request then
        return request(opts)
    else
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

local function buildPetsArray()
    local arr = {}
    for name, count in pairs(foundCounts) do
        if count > 0 then table.insert(arr, { name = name }) end
    end
    return arr
end

local function sendData()
    local now = tick()
    if now - lastSend < SEND_INTERVAL then return end
    lastSend = now

    -- private server check
    local isPrivate = false
    pcall(function()
        local privateText = workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.PrivateText
        if privateText and privateText:IsA("TextLabel") then
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
    if isPrivate then return end

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

local function onModelAdded(model)
    if not model or not model:IsA("Model") then return end
    local n = model.Name
    if targetLookup[n] then
        foundCounts[n] = (foundCounts[n] or 0) + 1
        sendData()
    end
end

local function onModelRemoved(model)
    if not model or not model:IsA("Model") then return end
    local n = model.Name
    if targetLookup[n] and foundCounts[n] and foundCounts[n] > 0 then
        foundCounts[n] = foundCounts[n] - 1
        if foundCounts[n] <= 0 then foundCounts[n] = nil end
        sendData()
    end
end

-- initial scan
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and targetLookup[obj.Name] then
        foundCounts[obj.Name] = (foundCounts[obj.Name] or 0) + 1
    end
end

-- connect events
Workspace.DescendantAdded:Connect(onModelAdded)
Workspace.DescendantRemoving:Connect(onModelRemoved)
Players.PlayerAdded:Connect(function() sendData() end)
Players.PlayerRemoving:Connect(function() sendData() end)

-- periodic backup
spawn(function()
    while true do
        wait(30 + math.random() * 10)
        sendData()
    end
end)
