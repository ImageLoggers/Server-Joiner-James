local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local API_URL = "https://petroblox-data-api.vercel.app/api/pets"
local AUTH_HEADER = "h"

-- List of pet/model names to track
local TARGET_MODELS = {
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

local TARGET_LOOKUP = {}
for _, name in ipairs(TARGET_MODELS) do
    TARGET_LOOKUP[name] = true
end

-- Get all pets/models
local function getTargets()
    local found = {}
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and TARGET_LOOKUP[model.Name] then
            table.insert(found, {name = model.Name})
        end
    end
    return found
end

-- Throttle sending to reduce lag
local lastSend = 0
local function sendServerData()
    local now = tick()
    if now - lastSend < 10 then return end
    lastSend = now

    local data = {
        targetPlayer
