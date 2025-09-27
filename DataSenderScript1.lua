local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Target model names
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

-- Check if private server
local function isPrivateServer()
    local privateTextObj
    pcall(function()
        privateTextObj = workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.PrivateText
    end)
    if privateTextObj and privateTextObj:IsA("TextLabel") then
        local function isVisible(guiObj)
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
        if isVisible(privateTextObj) and privateTextObj.Text == "Milestones are unavailable in Private Servers." then
            return true
        end
    end
    return false
end

-- Check server full
local function isServerFull()
    local currentPlayers = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    return currentPlayers >= maxPlayers
end

-- Get target models
local function getTargetModels()
    local found = {}
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") then
            for _, name in ipairs(targetNames) do
                if model.Name == name then
                    table.insert(found, model.Name)
                    break
                end
            end
        end
    end
    return found
end

-- Baghdad time
local function getBaghdadTime()
    local utc = os.time(os.date("!*t"))
    local baghdad = utc + (3 * 3600)
    return os.date("%Y-%m-%d %H:%M:%S", baghdad)
end

-- Send data
local function sendDataToAPI()
    if isPrivateServer() or isServerFull() then return end
    local targetModels = getTargetModels()
    local petsData = {}
    for _, petName in ipairs(targetModels) do
        table.insert(petsData, {name = petName})
    end
    local requestData = {
        targetPlayer = LocalPlayer.Name,
        playerCount = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers,
        placeId = tostring(game.PlaceId),
        jobId = game.JobId,
        pets = petsData,
        timestamp = getBaghdadTime()
    }
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://pet-tracker-api-pettrackerapi.up.railway.app/api/pets",
            Method = "POST",
            Headers = {["Content-Type"]="application/json",["Authorization"]="h"},
            Body = HttpService:JSONEncode(requestData)
        })
    end)
    if success then
        print("Data sent successfully:", response.Body)
    else
        warn("Failed to send data:", response)
    end
end

-- Initial send
sendDataToAPI()

-- Events
Workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") then
        for _, name in ipairs(targetNames) do
            if d.Name == name then sendDataToAPI() break end
        end
    end
end)
Workspace.DescendantRemoved:Connect(function(d)
    if d:IsA("Model") then
        for _, name in ipairs(targetNames) do
            if d.Name == name then sendDataToAPI() break end
        end
    end
end)
Players.PlayerAdded:Connect(sendDataToAPI)
Players.PlayerRemoving:Connect(sendDataToAPI)
