RegisterNetEvent('trunk:server:toggleTrunk')
AddEventHandler('trunk:server:toggleTrunk', function(veh, state)
    vehicle = NetworkGetEntityFromNetworkId(veh)
    Entity(vehicle).state.someoneInTrunk = state
end)

--[[ DO NOT REMOVE ]]
print("^1======================================================================^0")
print("^1[^0Author^1] ^0:^1 ^57empest15")
print("^1======================================================================^0")
--[[ DO NOT REMOVE ]]