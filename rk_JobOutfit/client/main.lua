local ESX = nil
local originalOutfit = nil
local isWearingUniform = false
local menuRegistered = false
local locationsRegistered = false

CreateThread(function()
    ESX = exports["es_extended"]:getSharedObject()
    
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    RegisterMenus()
    RegisterLocations()
end)

function RegisterMenus()
    if menuRegistered then return end
    
    lib.registerContext({
        id = 'wardrobe_menu',
        title = Config.Locale['wardrobe'],
        options = {
            {
                title = Config.Locale['wear_uniform'],
                description = Config.Locale['wear_uniform_desc'],
                arrow = true,
                event = 'rk_JobOutfit:openOutfitsMenu'
            },
            {
                title = Config.Locale['remove_uniform'],
                description = Config.Locale['remove_uniform_desc'],
                arrow = true,
                event = 'rk_JobOutfit:removeOutfit'
            },
            {
                title = Config.Locale['save_outfit'],
                description = Config.Locale['save_outfit_desc'],
                arrow = true,
                event = 'rk_JobOutfit:saveOutfit'
            },
            {
                title = Config.Locale['delete_uniform'],
                description = Config.Locale['delete_uniform_desc'],
                arrow = true,
                event = 'rk_JobOutfit:openDeleteMenu'
            }
        }
    })
    
    menuRegistered = true
end

function RegisterLocations()
    if locationsRegistered then return end
    
    for job, coords in pairs(Config.Locations) do
        exports.ox_target:addBoxZone({
            coords = coords,
            size = vec3(2, 2, 3),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'job_wardrobe_' .. job,
                    icon = 'fas fa-tshirt',
                    label = 'Apri Guardaroba',
                    canInteract = function()
                        local playerJob = ESX.GetPlayerData().job
                        return playerJob.name == job
                    end,
                    onSelect = function()
                        TriggerEvent('rk_JobOutfit:openWardrobe')
                    end
                }
            }
        })
    end
    
    locationsRegistered = true
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    RegisterMenus()
end)

RegisterNetEvent('rk_JobOutfit:openWardrobe')
AddEventHandler('rk_JobOutfit:openWardrobe', function()
    local playerJob = ESX.GetPlayerData().job
    local options = {
        {
            title = Config.Locale['wear_uniform'],
            description = Config.Locale['wear_uniform_desc'],
            arrow = true,
            event = 'rk_JobOutfit:openOutfitsMenu'
        },
        {
            title = Config.Locale['remove_uniform'],
            description = Config.Locale['remove_uniform_desc'],
            arrow = true,
            event = 'rk_JobOutfit:removeOutfit'
        }
    }

    if Config.JobGrades[playerJob.name] and playerJob.grade >= Config.JobGrades[playerJob.name].minGrade then
        table.insert(options, {
            title = Config.Locale['save_outfit'],
            description = Config.Locale['save_outfit_desc'],
            arrow = true,
            event = 'rk_JobOutfit:saveOutfit'
        })
        table.insert(options, {
            title = Config.Locale['delete_uniform'],
            description = Config.Locale['delete_uniform_desc'],
            arrow = true,
            event = 'rk_JobOutfit:openDeleteMenu'
        })
    end

    lib.registerContext({
        id = 'wardrobe_menu',
        title = Config.Locale['wardrobe'],
        options = options
    })

    lib.showContext('wardrobe_menu')
end)

RegisterNetEvent('rk_JobOutfit:openOutfitsMenu')
AddEventHandler('rk_JobOutfit:openOutfitsMenu', function()
    local playerJob = ESX.GetPlayerData().job
    
    ESX.TriggerServerCallback('rk_JobOutfit:getOutfits', function(outfits)
        local outfitOptions = {}
        for _, outfit in ipairs(outfits) do
            if playerJob.grade >= outfit.grade then
                table.insert(outfitOptions, {
                    title = outfit.label,
                    description = Config.Locale['grade_required']:format(outfit.grade),
                    arrow = true,
                    event = 'rk_JobOutfit:wearOutfit',
                    args = {
                        components = outfit.components,
                        props = outfit.props,
                        grade = outfit.grade
                    }
                })
            end
        end
        
        if #outfitOptions == 0 then
            lib.notify({
                title = Config.Locale['wardrobe'],
                description = Config.Locale['no_uniforms_available'],
                type = 'error'
            })
            return
        end

        lib.registerContext({
            id = 'outfits_menu',
            title = Config.Locale['available_uniforms'],
            menu = 'wardrobe_menu',
            options = outfitOptions
        })
        
        lib.showContext('outfits_menu')
    end)
end)

RegisterNetEvent('rk_JobOutfit:openDeleteMenu')
AddEventHandler('rk_JobOutfit:openDeleteMenu', function()
    ESX.TriggerServerCallback('rk_JobOutfit:getOutfits', function(outfits)
        local outfitOptions = {}
        for _, outfit in ipairs(outfits) do
            table.insert(outfitOptions, {
                title = outfit.label,
                description = Config.Locale['grade_required']:format(outfit.grade),
                arrow = true,
                event = 'rk_JobOutfit:confirmDelete',
                args = {
                    id = outfit.id,
                    label = outfit.label
                }
            })
        end
        
        lib.registerContext({
            id = 'delete_outfits_menu',
            title = Config.Locale['delete_uniforms'],
            menu = 'wardrobe_menu',
            options = outfitOptions
        })
        
        lib.showContext('delete_outfits_menu')
    end)
end)

RegisterNetEvent('rk_JobOutfit:confirmDelete')
AddEventHandler('rk_JobOutfit:confirmDelete', function(data)
    local alert = lib.alertDialog({
        header = Config.Locale['confirm_delete'],
        content = Config.Locale['confirm_delete_desc']:format(data.label),
        centered = true,
        cancel = true
    })
    
    if alert == 'confirm' then
        TriggerServerEvent('rk_JobOutfit:deleteOutfit', data.id)
        lib.notify({
            title = Config.Locale['wardrobe'],
            description = Config.Locale['uniform_deleted'],
            type = 'success'
        })
        TriggerEvent('rk_JobOutfit:openDeleteMenu')
    end
end)

local function extractClothingData(fullAppearance)
    local clothingData = {
        components = {},
        props = {}
    }
    
    if fullAppearance.components then
        for i=0, 11 do
            if (fullAppearance.components[i]) then
                clothingData.components[i] = {
                    drawable = fullAppearance.components[i].drawable,
                    texture = fullAppearance.components[i].texture
                }
            end
        end
    end
    
    if fullAppearance.props then
        for i=0, 7 do
            if (fullAppearance.props[i]) then
                clothingData.props[i] = {
                    drawable = fullAppearance.props[i].drawable,
                    texture = fullAppearance.props[i].texture
                }
            end
        end
    end
    
    return clothingData
end

local function applyClothingOnly(clothingData)
    local playerPed = PlayerPedId()
    
    for componentId, data in pairs(clothingData.components) do
        SetPedComponentVariation(playerPed, componentId, data.drawable, data.texture, 0)
    end
    
    for propId, data in pairs(clothingData.props) do
        if (data.drawable == -1) then
            ClearPedProp(playerPed, propId)
        else
            SetPedPropIndex(playerPed, propId, data.drawable, data.texture, true)
        end
    end
end

local function getCurrentClothing()
    local playerPed = PlayerPedId()
    local clothing = {
        components = {},
        props = {}
    }
    
   
    local componentsToSave = {
        [1] = true,  -- Maschera
        [3] = true,  -- Braccia
        [4] = true,  -- Pantaloni
        [5] = true,  -- Zaino
        [6] = true,  -- Scarpe
        [7] = true,  -- Accessori
        [8] = true,  -- Maglietta
        [9] = true,  -- Giubbotto
        [10] = true, -- Decali
        [11] = true  -- Torso
    }
    
    for componentId, shouldSave in pairs(componentsToSave) do
        if shouldSave then
            clothing.components[tostring(componentId)] = {
                drawable = GetPedDrawableVariation(playerPed, componentId),
                texture = GetPedTextureVariation(playerPed, componentId)
            }
        end
    end
    

    local propsToSave = {
        [0] = true, 
        [1] = true, 
        [2] = true, 
        [6] = true, 
        [7] = true  
    }
    
    for propId, shouldSave in pairs(propsToSave) do
        if shouldSave then
            local propIndex = GetPedPropIndex(playerPed, propId)
            if propIndex ~= -1 then
                clothing.props[tostring(propId)] = {
                    drawable = propIndex,
                    texture = GetPedPropTextureIndex(playerPed, propId)
                }
            end
        end
    end
    
    return clothing
end

local function playChangeClothesAnimation()
    local playerPed = PlayerPedId()
    
 
    FreezeEntityPosition(playerPed, true)
    
  
    RequestAnimDict("clothingtie")
    while not HasAnimDictLoaded("clothingtie") do
        Wait(100)
    end
    TaskPlayAnim(playerPed, "clothingtie", "try_tie_positive_a", 8.0, -8.0, -1, 0, 0, false, false, false)
    Wait(3000) 
    
   
    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
    RemoveAnimDict("clothingtie")
end

RegisterNetEvent('rk_JobOutfit:wearOutfit')
AddEventHandler('rk_JobOutfit:wearOutfit', function(outfit)
    if (not isWearingUniform) then
        local currentOutfit = getCurrentClothing()
        TriggerServerEvent('rk_JobOutfit:saveOriginalOutfit', currentOutfit)
    end

    local playerJob = ESX.GetPlayerData().job
    if (not outfit.grade) then 
        outfit.grade = 0
    end
    
    if (outfit.grade > playerJob.grade) then
        lib.notify({
            title = Config.Locale['wardrobe'],
            description = Config.Locale['grade_not_met'],
            type = 'error'
        })
        return
    end

    playChangeClothesAnimation()

    if (outfit.components) then
        for componentId, data in pairs(outfit.components) do
            SetPedComponentVariation(PlayerPedId(), tonumber(componentId), data.drawable, data.texture, 0)
        end
    end
    
    if (outfit.props) then
        for propId, data in pairs(outfit.props) do
            if (data.drawable == -1) then
                ClearPedProp(PlayerPedId(), tonumber(propId))
            else
                SetPedPropIndex(PlayerPedId(), tonumber(propId), data.drawable, data.texture, true)
            end
        end
    end
    
    isWearingUniform = true
    
    lib.notify({
        title = Config.Locale['wardrobe'],
        description = Config.Locale['uniform_worn'],
        type = 'success'
    })
end)

RegisterNetEvent('rk_JobOutfit:removeOutfit')
AddEventHandler('rk_JobOutfit:removeOutfit', function()
    if (not isWearingUniform) then
        lib.notify({
            title = Config.Locale['wardrobe'],
            description = Config.Locale['not_wearing_uniform'],
            type = 'error'
        })
        return
    end

    ESX.TriggerServerCallback('rk_JobOutfit:getOriginalOutfit', function(outfit)
        if (outfit) then
            local playerPed = PlayerPedId()
            
            playChangeClothesAnimation()
            
            for i = 0, 7 do
                ClearPedProp(playerPed, i)
            end
            
            if (outfit.components) then
                for componentId, data in pairs(outfit.components) do
                    SetPedComponentVariation(playerPed, tonumber(componentId), data.drawable, data.texture, 0)
                end
            end
            
            if (outfit.props) then
                for propId, data in pairs(outfit.props) do
                    if data.drawable ~= -1 then
                        SetPedPropIndex(playerPed, tonumber(propId), data.drawable, data.texture, true)
                    end
                end
            end
            
            isWearingUniform = false
            
            lib.notify({
                title = Config.Locale['wardrobe'],
                description = Config.Locale['civilian_clothes_worn'],
                type = 'success'
            })
        end
    end)
end)

RegisterNetEvent('rk_JobOutfit:saveOutfit')
AddEventHandler('rk_JobOutfit:saveOutfit', function()
    local input = lib.inputDialog(Config.Locale['save_outfit_title'], {
        {
            type = 'input',
            label = Config.Locale['outfit_name'],
            description = Config.Locale['outfit_name_desc'],
            required = true
        },
        {
            type = 'number',
            label = Config.Locale['min_grade'],
            description = Config.Locale['min_grade_desc'],
            required = true,
            min = 0,
            max = 10
        }
    })

    if (input) then
        local label = input[1]
        local grade = input[2]
        local clothingData = getCurrentClothing()
        
        TriggerServerEvent('rk_JobOutfit:saveOutfit', label, grade, clothingData)
        lib.notify({
            title = Config.Locale['wardrobe'],
            description = Config.Locale['outfit_saved'],
            type = 'success'
        })
    end
end)

RegisterNetEvent('rk_JobOutfit:deleteOutfit')
AddEventHandler('rk_JobOutfit:deleteOutfit', function(id)
    TriggerServerEvent('rk_JobOutfit:deleteOutfit', id)
end)