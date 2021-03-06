ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    ESX.PlayerData = ESX.GetPlayerData()
end)

local toghud = true
local tokovoipstate = 1
local isTalking = false

RegisterCommand('hud', function(source, args, rawCommand)

    if toghud then 
        toghud = false
    else
        toghud = true
    end

end)

RegisterNetEvent('hud:toggleui')
AddEventHandler('hud:toggleui', function(show)

    if show == true then
        toghud = true
    else
        toghud = false
    end

end)

RegisterNetEvent('sh1no:toggleTokoVOIP')
AddEventHandler('sh1no:toggleTokoVOIP', function(state)
    tokovoipstate = state
end)

RegisterNetEvent('sh1no:setTalkingState')
AddEventHandler('sh1no:setTalkingState', function(state)
    isTalking = state
end)


Citizen.CreateThread(function()
    while true do

        if toghud == true then
            if (not IsPedInAnyVehicle(PlayerPedId(), false) )then
                DisplayRadar(0)
            else
                DisplayRadar(1)
            end
        else
            DisplayRadar(0)
        end 
        
        TriggerEvent('esx_status:getStatus', 'hunger', function(hunger)
            TriggerEvent('esx_status:getStatus', 'thirst', function(thirst)
                TriggerEvent('esx_status:getStatus','stress',function(stress)

                    local myhunger = hunger.getPercent()
                    local mythirst = thirst.getPercent()
                    local mystress = stress.getPercent()

                    SendNUIMessage({
                        action = "updateStatusHud",
                        show = toghud,
                        hunger = myhunger,
                        thirst = mythirst,
                        stress = mystress,
                        state = tokovoipstate,
                        talking = isTalking,
                    })
                end)
            end)
        end)
        Citizen.Wait(5000)
    end
end)

RegisterNetEvent("esx_status:onTick") 
AddEventHandler("esx_status:onTick", function(Status)
 hunger, thirst = Status[1].percent, Status[2].percent
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        local player = PlayerPedId()
        local health = (GetEntityHealth(player) - 100)
        local armor = GetPedArmour(player)
        local oxy = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 2.5
        local stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())

        SendNUIMessage({
            action = 'updateStatusHud',
            show = toghud,
            health = health,
            armour = armor,
            oxygen = oxy,
			hunger = hunger,
			thirst = thirst,
            stamina = stamina,
            state = tokovoipstate,
            talking = isTalking,
        })
        Citizen.Wait(200)
    end
end)