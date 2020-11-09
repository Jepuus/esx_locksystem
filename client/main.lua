ESX = nil

local isRunningWorkaround = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function StartWorkaroundTask()
	if isRunningWorkaround then
		return
	end

	local timer = 0
	local playerPed = PlayerPedId()
	isRunningWorkaround = true

	while timer < 100 do
		Citizen.Wait(0)
		timer = timer + 1

		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end

	isRunningWorkaround = false
end

function ToggleVehicleLock()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle

	Citizen.CreateThread(function()
		StartWorkaroundTask()
	end)

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end

	if not DoesEntityExist(vehicle) then
		return
	end

	ESX.TriggerServerCallback('esx_locksystem:requestPlayerCars', function(isOwnedVehicle)

		if isOwnedVehicle then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 1 then -- unlocked
				playAnimation()
				SetVehicleDoorsLocked(vehicle, 2)
				SetVehicleDoorsLockedForAllPlayers(vehicle, true)

				ESX.ShowNotification('Vehicle Unlocked')
			elseif lockStatus == 2 then -- locked
				playAnimation()
				SetVehicleDoorsLocked(vehicle, 1)
				SetVehicleDoorsLockedForAllPlayers(vehicle, false)

				ESX.ShowNotification('Vehicle Locked')
			end
			if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then
				Wait(500)
				local flickers = 0
				while flickers < 2 do
					SetVehicleLights(veh, 2)
					Wait(170)
					SetVehicleLights(veh, 0)
					flickers = flickers + 1
					Wait(170)
				end
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

RegisterCommand("key", function()
    ToggleVehicleLock()
end)

function playAnimation()
	local ply = GetPlayerPed(-1)
	local lib = "anim@mp_player_intmenu@key_fob@"
	local anim = "fob_click"

	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(ply, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
	end)
end

Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(0)
	  if IsDisabledControlJustReleased(1, 303) then
		ToggleVehicleLock()
	 end
	end
end)