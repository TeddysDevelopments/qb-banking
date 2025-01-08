local QBCore = exports['qb-core']:GetCoreObject()
local zones = {}

local isPlayerInsideBankZone = false

local createdZones = {} 

local function OpenBank()
    for _, location in ipairs(Config.bankLocations) do
        if not createdZones[location] then
            exports.ox_target:addSphereZone({
                coords = location, 
                radius = 3.0,  
                drawSprite = false,  
                options = {
                    {
                        name = 'openBank', 
                        label = 'Open Bank',  
                        icon = 'fas fa-credit-card',  
                        canInteract = function(entity, distance, coords, name, bone)
                            if distance < 3.0 then
                                return true 
                            end
                            return false  
                        end,
                        onSelect = function()
                            QBCore.Functions.TriggerCallback('qb-banking:server:openBank', function(accounts, statements, playerData)
                                SendNUIMessage({
                                    action = 'openBank',
                                    accounts = accounts,
                                    statements = statements,
                                    playerData = playerData
                                })
                                SetNuiFocus(true, true)  
                            end)
                        end
                    }
                }
            })
            createdZones[location] = true
        end
    end
end

OpenBank()
local function OpenATM()
    QBCore.Functions.Progressbar('accessing_atm', Lang:t('progress.atm'), 1500, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    }, {
        animDict = 'amb@prop_human_atm@male@enter',
        anim = 'enter',
    }, {
        model = 'prop_cs_credit_card',
        bone = 28422,
        coords = vector3(0.1, 0.03, -0.05),
        rotation = vector3(0.0, 0.0, 180.0),
    }, {}, function()
        QBCore.Functions.TriggerCallback('qb-banking:server:openATM', function(accounts, playerData, acceptablePins)
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openATM',
                accounts = accounts,
                pinNumbers = acceptablePins,
                playerData = playerData
            })
        end)
    end)
end

local function AddATMTargetZones()
    for _, atmModel in ipairs(Config.atmModels) do
        local modelHash = joaat(atmModel)
        exports.ox_target:addModel(modelHash, {
            name = 'atmInteraction', 
            label = 'Access ATM',  
            icon = 'fas fa-credit-card', 
            canInteract = function(entity, distance, coords, name, bone)
                if distance < 2.0 then
                    return true
                end
                return false
            end,
            onSelect = function()
                OpenATM()
            end
        })
    end
end

AddATMTargetZones()

-- NUI Callback

RegisterNUICallback('closeApp', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:withdraw', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('deposit', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:deposit', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('internalTransfer', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:internalTransfer', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('externalTransfer', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:externalTransfer', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('orderCard', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:orderCard', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('openAccount', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:openAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('renameAccount', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:renameAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('deleteAccount', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:deleteAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('addUser', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:addUser', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('removeUser', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:removeUser', function(status)
        cb(status)
    end, data)
end)

-- Events

RegisterNetEvent('qb-banking:client:useCard', function()
    if NearATM() then OpenATM() end
end)

-- Threads

CreateThread(function()
    for i = 1, #Config.locations do
        local blip = AddBlipForCoord(Config.locations[i])
        SetBlipSprite(blip, Config.blipInfo.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.blipInfo.scale)
        SetBlipColour(blip, Config.blipInfo.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(tostring(Config.blipInfo.name))
        EndTextCommandSetBlipName(blip)
    end
end)
