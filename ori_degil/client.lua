local PlayerData = {}

local taxiActive = false
local taxiDestination = nil

local cleanerActive = false
local cleanerPoint = nil

local blurActive = false

--------------------------------------------------
-- NOTIFICATION
--------------------------------------------------

local function Notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(tostring(message))
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent('ori_degil:notify', function(message)
    Notify(message)
end)

--------------------------------------------------
-- PLAYER DATA
--------------------------------------------------

RegisterNetEvent('ori_degil:updateData', function(data)
    PlayerData = data or {}
end)

CreateThread(function()
    Wait(3000)
    TriggerServerEvent('ori_degil:playerLoaded')
end)

--------------------------------------------------
-- HELPER: DRAW 3D TEXT
--------------------------------------------------

local function DrawText3D(x, y, z, text)
    local onScreen, screenX, screenY = World3dToScreen2d(x, y, z)

    if onScreen then
        SetTextScale(0.30, 0.30)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(true)
        SetTextEntry('STRING')
        AddTextComponentString(text)
        DrawText(screenX, screenY)
    end
end

--------------------------------------------------
-- CHARACTER SYSTEM
--------------------------------------------------

RegisterCommand('character', function()
    TriggerEvent('ori_degil:createCharacterMenu')
end, false)

RegisterNetEvent('ori_degil:createCharacterMenu', function()

    -- NAME
    AddTextEntry('ORI_CHAR_NAME', 'Masukkan nama character:')
    DisplayOnscreenKeyboard(
        1,
        'ORI_CHAR_NAME',
        '',
        '',
        '',
        '',
        '',
        30
    )

    while UpdateOnscreenKeyboard() == 0 do
        Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 1 then
        Notify('~r~Character creation dibatalkan.')
        return
    end

    local name = GetOnscreenKeyboardResult()

    if not name or name == '' then
        Notify('~r~Nama tak boleh kosong.')
        return
    end

    Wait(300)

    -- AGE
    AddTextEntry('ORI_CHAR_AGE', 'Masukkan umur character:')
    DisplayOnscreenKeyboard(
        1,
        'ORI_CHAR_AGE',
        '',
        '',
        '',
        '',
        '',
        3
    )

    while UpdateOnscreenKeyboard() == 0 do
        Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 1 then
        Notify('~r~Character creation dibatalkan.')
        return
    end

    local age = tonumber(GetOnscreenKeyboardResult())

    if not age then
        Notify('~r~Umur mesti nombor.')
        return
    end

    Wait(300)

    -- BIRTH PLACE
    AddTextEntry('ORI_CHAR_BIRTH', 'Masukkan tempat lahir:')
    DisplayOnscreenKeyboard(
        1,
        'ORI_CHAR_BIRTH',
        '',
        '',
        '',
        '',
        '',
        30
    )

    while UpdateOnscreenKeyboard() == 0 do
        Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 1 then
        Notify('~r~Character creation dibatalkan.')
        return
    end

    local birthPlace = GetOnscreenKeyboardResult()

    if not birthPlace or birthPlace == '' then
        Notify('~r~Tempat lahir tak boleh kosong.')
        return
    end

    Wait(300)

    -- GENDER
    Notify('Gender: taip ~b~male~s~ atau ~p~female')

    AddTextEntry('ORI_CHAR_GENDER', 'Taip male atau female:')
    DisplayOnscreenKeyboard(
        1,
        'ORI_CHAR_GENDER',
        '',
        '',
        '',
        '',
        '',
        10
    )

    while UpdateOnscreenKeyboard() == 0 do
        Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 1 then
        Notify('~r~Character creation dibatalkan.')
        return
    end

    local gender = string.lower(GetOnscreenKeyboardResult() or '')

    if gender ~= 'male' and gender ~= 'female' then
        Notify('~r~Gender salah! Sila gunakan male atau female.')
        Notify('~y~Taip /character untuk cuba semula.')
        return
    end

    TriggerServerEvent(
        'ori_degil:createCharacter',
        name,
        age,
        birthPlace,
        gender
    )
end)

--------------------------------------------------
-- MONEY
--------------------------------------------------

RegisterCommand('money', function()
    if not PlayerData or not PlayerData.cash then
        Notify('~r~Data player belum loaded.')
        return
    end

    Notify(
        ('~g~Cash: RM%s ~s~| ~b~Bank: RM%s'):format(
            PlayerData.cash or 0,
            PlayerData.bank or 0
        )
    )
end, false)

--------------------------------------------------
-- INVENTORY
--------------------------------------------------

RegisterCommand('inventory', function()
    if not PlayerData or not PlayerData.inventory then
        Notify('~r~Inventory belum loaded.')
        return
    end

    TriggerEvent(
        'ori_degil:showInventory',
        PlayerData.inventory
    )
end, false)

RegisterKeyMapping(
    'inventory',
    'Open Inventory',
    'keyboard',
    'TAB'
)

RegisterNetEvent('ori_degil:openInventory', function(inventory)
    TriggerEvent(
        'ori_degil:showInventory',
        inventory
    )
end)

RegisterNetEvent('ori_degil:showInventory', function(inventory)

    Notify('~b~===== ORI DEGIL INVENTORY =====')

    for item, amount in pairs(inventory or {}) do

        local label = item

        if Config.Items[item] and Config.Items[item].label then
            label = Config.Items[item].label
        end

        Notify(
            ('~w~%s ~s~x%s'):format(
                label,
                amount
            )
        )

        Wait(100)
    end

    Notify('~b~==============================')
end)

--------------------------------------------------
-- USE ITEM COMMAND
--------------------------------------------------

RegisterCommand('useitem', function(source, args)

    local item = args[1]

    if not item then
        Notify('~y~Contoh: /useitem sandwich')
        return
    end

    if not PlayerData.inventory then
        Notify('~r~Inventory belum loaded.')
        return
    end

    if not PlayerData.inventory[item] or PlayerData.inventory[item] <= 0 then
        Notify('~r~Item tak ada dalam inventory.')
        return
    end

    TriggerServerEvent(
        'ori_degil:useItem',
        item
    )
end, false)

--------------------------------------------------
-- HUNGER / THIRST HUD
--------------------------------------------------

CreateThread(function()

    while true do

        Wait(0)

        if PlayerData then

            local hunger = PlayerData.hunger or 0
            local thirst = PlayerData.thirst or 0
            local dizzy = PlayerData.dizzy or 0

            SetTextFont(4)
            SetTextScale(0.32, 0.32)
            SetTextColour(255, 255, 255, 220)
            SetTextOutline()

            BeginTextCommandDisplayText('STRING')

            AddTextComponentSubstringPlayerName(
                ('Hunger: %s%%   Thirst: %s%%   Pening: %s%%'):format(
                    math.floor(hunger),
                    math.floor(thirst),
                    math.floor(dizzy)
                )
            )

            EndTextCommandDisplayText(
                0.015,
                0.78
            )
        end
    end
end)

--------------------------------------------------
-- STARVATION
--------------------------------------------------

RegisterNetEvent('ori_degil:starvation', function()

    local ped = PlayerPedId()

    Notify('~r~Hunger atau thirst anda sudah 0%!')

    Wait(1000)

    SetEntityHealth(
        ped,
        0
    )
end)

--------------------------------------------------
-- POWERBANK / PHONE
--------------------------------------------------

RegisterCommand('phonebattery', function()

    local battery = PlayerData.phoneBattery or 0

    Notify(
        ('~b~Phone Battery: %s%%'):format(
            battery
        )
    )

end, false)

--------------------------------------------------
-- BLUR / UBAT GEGAT
--------------------------------------------------

RegisterNetEvent('ori_degil:blur', function(duration)

    if blurActive then
        return
    end

    blurActive = true

    local endTime =
        GetGameTimer() + (duration or 20000)

    AnimpostfxPlay(
        'DrugsMichaelAliensFight',
        0,
        true
    )

    Notify('~r~Ubat Gegat menyebabkan kepala pening!')

    while GetGameTimer() < endTime do
        Wait(100)
    end

    AnimpostfxStop(
        'DrugsMichaelAliensFight'
    )

    blurActive = false

end)

--------------------------------------------------
-- TAXI JOB
--------------------------------------------------

CreateThread(function()

    while true do

        local sleep = 1000

        local ped = PlayerPedId()

        local coords = GetEntityCoords(ped)

        local distance =
            #(coords - Config.TaxiStart)

        if distance < 20.0 then

            sleep = 0

            DrawMarker(
                1,
                Config.TaxiStart.x,
                Config.TaxiStart.y,
                Config.TaxiStart.z - 1.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                2.0,
                2.0,
                0.5,
                0,
                150,
                255,
                150,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            if distance < 2.0 then

                DrawText3D(
                    Config.TaxiStart.x,
                    Config.TaxiStart.y,
                    Config.TaxiStart.z + 1.0,
                    '[E] Mulakan Kerja Taxi'
                )

                if IsControlJustReleased(
                    0,
                    38
                ) then

                    if taxiActive then

                        Notify(
                            '~y~Anda sedang menjalankan job taxi.'
                        )

                    else

                        taxiActive = true

                        local randomIndex =
                            math.random(
                                1,
                                #Config.TaxiDestinations
                            )

                        taxiDestination =
                            Config.TaxiDestinations[randomIndex]

                        SetNewWaypoint(
                            taxiDestination.x,
                            taxiDestination.y
                        )

                        Notify(
                            '~g~Taxi job bermula!'
                        )

                        Notify(
                            '~w~Ikut GPS untuk hantar passenger.'
                        )
                    end
                end
            end
        end

        if taxiActive and taxiDestination then

            local destinationDistance =
                #(coords - taxiDestination)

            DrawMarker(
                1,
                taxiDestination.x,
                taxiDestination.y,
                taxiDestination.z - 1.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                3.0,
                3.0,
                1.0,
                0,
                255,
                100,
                150,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            if destinationDistance < 5.0 then

                DrawText3D(
                    taxiDestination.x,
                    taxiDestination.y,
                    taxiDestination.z + 1.0,
                    'Hantar Passenger'
                )

                if IsControlJustReleased(
                    0,
                    38
                ) then

                    taxiActive = false

                    local destination =
                        taxiDestination

                    taxiDestination = nil

                    TriggerServerEvent(
                        'ori_degil:taxiComplete'
                    )

                    Notify(
                        '~g~Passenger berjaya dihantar!'
                    )

                end
            end
        end

        Wait(sleep)
    end
end)

--------------------------------------------------
-- CLEANER JOB
--------------------------------------------------

CreateThread(function()

    while true do

        local sleep = 1000

        local ped = PlayerPedId()

        local coords =
            GetEntityCoords(ped)

        local distance =
            #(coords - Config.CleanerStart)

        if distance < 20.0 then

            sleep = 0

            DrawMarker(
                1,
                Config.CleanerStart.x,
                Config.CleanerStart.y,
                Config.CleanerStart.z - 1.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                2.0,
                2.0,
                0.5,
                255,
                150,
                0,
                150,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            if distance < 2.0 then

                DrawText3D(
                    Config.CleanerStart.x,
                    Config.CleanerStart.y,
                    Config.CleanerStart.z + 1.0,
                    '[E] Mulakan Kerja Cleaner'
                )

                if IsControlJustReleased(
                    0,
                    38
                ) then

                    if cleanerActive then

                        Notify(
                            '~y~Anda sedang menjalankan kerja cleaner.'
                        )

                    else

                        cleanerActive = true

                        cleanerPoint = 1

                        Notify(
                            '~g~Kerja cleaner bermula!'
                        )

                        Notify(
                            '~w~Pergi ke lokasi sampah pertama.'
                        )
                    end
                end
            end
        end

        if cleanerActive and cleanerPoint then

            local trashCoords =
                Config.CleanerTrashPoints[cleanerPoint]

            local trashDistance =
                #(coords - trashCoords)

            DrawMarker(
                1,
                trashCoords.x,
                trashCoords.y,
                trashCoords.z - 1.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                1.5,
                1.5,
                0.5,
                255,
                255,
                0,
                150,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            if trashDistance < 2.0 then

                DrawText3D(
                    trashCoords.x,
                    trashCoords.y,
                    trashCoords.z + 1.0,
                    '[E] Bersihkan'
                )

                if IsControlJustReleased(
                    0,
                    38
                ) then

                    Notify(
                        '~y~Sedang membersihkan...'
                    )

                    TaskStartScenarioInPlace(
                        ped,
                        'WORLD_HUMAN_JANITOR',
                        0,
                        true
                    )

                    Wait(5000)

                    ClearPedTasks(ped)

                    cleanerPoint =
                        cleanerPoint + 1

                    if cleanerPoint >
                        #Config.CleanerTrashPoints then

                        cleanerActive = false
                        cleanerPoint = nil

                        TriggerServerEvent(
                            'ori_degil:cleanerComplete'
                        )

                        Notify(
                            '~g~Semua sampah selesai dibersihkan!'
                        )

                    else

                        Notify(
                            '~g~Sampah seterusnya ditanda di map.'
                        )

                    end
                end
            end
        end

        Wait(sleep)
    end
end)

--------------------------------------------------
-- TELEPORT
--------------------------------------------------

RegisterNetEvent('ori_degil:teleport', function(
    x,
    y,
    z
)

    local ped =
        PlayerPedId()

    SetEntityCoords(
        ped,
        x,
        y,
        z,
        false,
        false,
        false,
        false
    )

    Notify(
        '~g~Teleport berjaya.'
    )
end)

--------------------------------------------------
-- EMOTE: TIDUR
--------------------------------------------------

RegisterCommand('tidur', function()

    local ped =
        PlayerPedId()

    RequestAnimDict(
        'amb@world_human_bum_slumped@male@laying_on_right_side@base'
    )

    while not HasAnimDictLoaded(
        'amb@world_human_bum_slumped@male@laying_on_right_side@base'
    ) do
        Wait(10)
    end

    TaskPlayAnim(
        ped,
        'amb@world_human_bum_slumped@male@laying_on_right_side@base',
        'base',
        8.0,
        -8.0,
        -1,
        1,
        0,
        false,
        false,
        false
    )

end, false)

--------------------------------------------------
-- EMOTE: DUDUK
--------------------------------------------------

RegisterCommand('duduk', function()

    local ped =
        PlayerPedId()

    RequestAnimDict(
        'amb@world_human_picnic@male@idle_a'
    )

    while not HasAnimDictLoaded(
        'amb@world_human_picnic@male@idle_a'
    ) do
        Wait(10)
    end

    TaskPlayAnim(
        ped,
        'amb@world_human_picnic@male@idle_a',
        'idle_a',
        8.0,
        -8.0,
        -1,
        1,
        0,
        false,
        false,
        false
    )

end, false)

--------------------------------------------------
-- EMOTE: TAMpar
--------------------------------------------------

RegisterCommand('tampar', function()

    local ped =
        PlayerPedId()

    RequestAnimDict(
        'melee@unarmed@streamed_core'
    )

    while not HasAnimDictLoaded(
        'melee@unarmed@streamed_core'
    ) do
        Wait(10)
    end

    TaskPlayAnim(
        ped,
        'melee@unarmed@streamed_core',
        'plyr_takedown_front_slap',
        8.0,
        -8.0,
        1500,
        0,
        0,
        false,
        false,
        false
    )

end, false)

--------------------------------------------------
-- STOP EMOTE
--------------------------------------------------

RegisterCommand('stopemote', function()

    ClearPedTasks(
        PlayerPedId()
    )

end, false)

--------------------------------------------------
-- GARAGE
--------------------------------------------------

local garageVehicle = nil

local function SpawnGarageVehicle(model)

    local ped =
        PlayerPedId()

    local coords =
        GetEntityCoords(ped)

    local heading =
        GetEntityHeading(ped)

    local modelHash =
        GetHashKey(model)

    RequestModel(modelHash)

    local timeout =
        GetGameTimer() + 10000

    while not HasModelLoaded(modelHash) do

        Wait(10)

        if GetGameTimer() > timeout then
            Notify('~r~Model vehicle gagal load.')
            return
        end

    end

    if garageVehicle and DoesEntityExist(
        garageVehicle
    ) then

        DeleteEntity(
            garageVehicle
        )
    end

    garageVehicle =
        CreateVehicle(
            modelHash,
            coords.x,
            coords.y,
            coords.z,
            heading,
            true,
            false
        )

    SetVehicleOnGroundProperly(
        garageVehicle
    )

    SetPedIntoVehicle(
        ped,
        garageVehicle,
        -1
    )

    SetVehicleEngineOn(
        garageVehicle,
        true,
        true,
        false
    )

    SetModelAsNoLongerNeeded(
        modelHash
    )

    Notify(
        '~g~Vehicle dikeluarkan dari garage.'
    )
end

RegisterCommand('garage', function()

    local ped =
        PlayerPedId()

    local coords =
        GetEntityCoords(ped)

    local distance =
        #(coords - Config.GarageLocation)

    if distance > 5.0 then

        Notify(
            '~r~Anda perlu berada di garage.'
        )

        return
    end

    Notify(
        '~b~Garage: /car sultan'
    )

    Notify(
        '~b~/car blista'
    )

    Notify(
        '~b~/car faggio'
    )

    Notify(
        '~b~/car sanchez'
    )

end, false)

RegisterCommand('car', function(
    source,
    args
)

    local model =
        args[1]

    if not model then

        Notify(
            '~y~Contoh: /car sultan'
        )

        return
    end

    local allowed = false

    for _, vehicle in ipairs(
        Config.GarageVehicles
    ) do

        if vehicle.model == model then

            allowed = true
            break

        end
    end

    if not allowed then

        Notify(
            '~r~Vehicle tidak tersedia dalam garage.'
        )

        return
    end

    SpawnGarageVehicle(
        model
    )

end, false)

--------------------------------------------------
-- GARAGE MARKER
--------------------------------------------------

CreateThread(function()

    while true do

        local sleep = 1000

        local ped =
            PlayerPedId()

        local coords =
            GetEntityCoords(ped)

        local distance =
            #(coords - Config.GarageLocation)

        if distance < 20.0 then

            sleep = 0

            DrawMarker(
                1,
                Config.GarageLocation.x,
                Config.GarageLocation.y,
                Config.GarageLocation.z - 1.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                3.0,
                3.0,
                0.5,
                0,
                100,
                255,
                150,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            if distance < 3.0 then

                DrawText3D(
                    Config.GarageLocation.x,
                    Config.GarageLocation.y,
                    Config.GarageLocation.z + 1.0,
                    'Garage - /garage'
                )

            end
        end

        Wait(sleep)
    end
end)