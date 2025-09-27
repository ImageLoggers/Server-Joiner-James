local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local API_URL = "https://petroblox-data-api.vercel.app/api/pets"
local AUTH_HEADER = "h"

local targetModels1 = {
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

local function getTargets()
    local found = {}
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") then
            for _, target in ipairs(targetModels1) do
                if model.Name == target then
                    table.insert(found, {name = model.Name})
                end
            end
        end
    end
    return found
end

local function sendData()
    local data = {
        targetPlayer = LocalPlayer.Name,
        placeId = tostring(game.PlaceId),
        jobId = tostring(game.JobId),
        playerCount = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers,
        pets = getTargets()
    }
    pcall(function()
        HttpService:PostAsync(
            API_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false,
            {["Authorization"] = AUTH_HEADER}
        )
    end)
end

-- Initial send
sendData()

-- Updates when models or players change
Workspace.DescendantAdded:Connect(sendData)
Workspace.DescendantRemoving:Connect(sendData)
Players.PlayerAdded:Connect(sendData)
Players.PlayerRemoving:Connect(sendData)
