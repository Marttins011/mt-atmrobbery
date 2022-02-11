local QBCore = exports['qb-core']:GetCoreObject()

-- function do hack bem sucedido
function HackSuccess()
	QBCore.Functions.Notify("Sucesso!")
    ClearPedTasksImmediately(PlayerPedId())
	RobbingTheMoney()
	TriggerServerEvent("mt-atmrobbery:success")	
    TriggerServerEvent('mt-atmrobbery:Server:BeginCooldown')
end

-- function do hack falhado
function HackFailed()
    local pos = GetEntityCoords(PlayerPedId())
	QBCore.Functions.Notify("Que merdas que és xD como erras-te isso?")
		TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
    QBCore.Functions.Notify("Deixas-te impressões digitais no ATM...")
end

-- function do mini game
function RobAtm()
    local minigame = exports['hackingminigame']:Open()   
    if (minigame == true) then -- success
        ClearPedTasksImmediately(PlayerPedId())
        HackSuccess()
        TriggerServerEvent('QBCore:Server:RemoveItem', 'laptop_atm', 1)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["laptop_atm"], 'remove')
    else
        Citizen.Wait(1000)
        ClearPedTasksImmediately(PlayerPedId())
        HackFailed()
        TriggerServerEvent('QBCore:Server:RemoveItem', 'laptop_atm', 1)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["laptop_atm"], 'remove')
    end
end

-- function para o alerta da policia
function PoliceCall()
    TriggerServerEvent('police:server:policeAlert', 'ASSALTO A ATM EM CONCURSO')
end

--Event para iniciar roubo
RegisterNetEvent('mt-atmrobbery:client:iniciar', function()
    local rand = math.random(1,100)
    if rand => 50 then
        PoliceCall()
    end
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            RobAtm()
        end
    end, 'laptop_atm')
end)

-- Function da anim de pegar o dinheiro
function RobbingTheMoney()
    Anim = true
    QBCore.Functions.Progressbar("pegar_dinheiro", "A encher saco de dinheiro...", (7500), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@ornate_bank@grab_cash_heels",
        anim = "grab",
        flags = 16,
    }, {
       model = "prop_cs_heist_bag_02",
       bone = 57005,
       coords = { x = -0.005, y = 0.00, z = -0.16 },
       rotation = { x = 250.0, y = -30.0, z = 0.0 },


    }, {}, function() -- Done
        Anim = false
        StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
        SetPedComponentVariation((PlayerPedId()), 5, 47, 0, 0)

    end, function() -- Cancel
        Anim = false
        StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
        
    end)
    
    Citizen.CreateThread(function()
        while Anim do
            TriggerServerEvent('qb-hud:Server:gain:stress', math.random(2, 3))
            TriggerServerEvent('mt-atmrobbery:server:Reward')
            Citizen.Wait(12000)
        end
    end)
end

-- Target para roubo ao atm
local prop = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
}
exports['qb-target']:AddTargetModel(prop, {
    options = {
        {
            type = "client",
            event = "mt-atmrobbery:client:iniciar",
            icon = "fas fa-user-secret",
            label = "ROUBAR ATM",
        },
    },
    distance = 2.0    
})