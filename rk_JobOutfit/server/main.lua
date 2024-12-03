ESX = nil

ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('rk_JobOutfit:getOutfits', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.job.name

    MySQL.Async.fetchAll('SELECT id, job, label, grade, components, props FROM job_outfits WHERE job = @job', {
        ['@job'] = job
    }, function(result)
        for i=1, #result do
            result[i].components = json.decode(result[i].components)
            result[i].props = json.decode(result[i].props)
            result[i].grade = tonumber(result[i].grade)
        end
        cb(result)
    end)
end)

ESX.RegisterServerCallback('rk_JobOutfit:getOriginalOutfit', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.fetchAll('SELECT components, props FROM player_outfits WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            cb({
                components = json.decode(result[1].components),
                props = json.decode(result[1].props)
            })
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('rk_JobOutfit:saveOriginalOutfit')
AddEventHandler('rk_JobOutfit:saveOriginalOutfit', function(outfit)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.execute('REPLACE INTO player_outfits (identifier, components, props) VALUES (@identifier, @components, @props)', {
        ['@identifier'] = identifier,
        ['@components'] = json.encode(outfit.components),
        ['@props'] = json.encode(outfit.props)
    })
end)

RegisterServerEvent('rk_JobOutfit:saveOutfit')
AddEventHandler('rk_JobOutfit:saveOutfit', function(label, grade, clothingData)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.job.name

    MySQL.Async.execute('INSERT INTO job_outfits (job, label, grade, components, props) VALUES (@job, @label, @grade, @components, @props)', {
        ['@job'] = job,
        ['@label'] = label,
        ['@grade'] = grade,
        ['@components'] = json.encode(clothingData.components),
        ['@props'] = json.encode(clothingData.props)
    })
end)

RegisterServerEvent('rk_JobOutfit:deleteOutfit')
AddEventHandler('rk_JobOutfit:deleteOutfit', function(id)
    MySQL.Async.execute('DELETE FROM job_outfits WHERE id = @id', {
        ['@id'] = id
    })
end)