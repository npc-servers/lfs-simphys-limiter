-- Some simphys vehicles dont have .Class
local extraVehicles = {
    ["DIPRIP - Ratmobile"] = true,
    ["DIPRIP - Chaos126p"] = true,
    ["DIPRIP - Hedgehog"] = true
}

util.AddNetworkString( "simphysLFSLimiterNotify" )

local SimfphysLimit = CreateConVar( "vehiclelimiter_simphys_max", 3, { FCVAR_ARCHIVE }, "The max amount of simphys vehicles players can spawn.", 0 ):GetInt()
cvars.AddChangeCallback( "vehiclelimiter_simphys_max", function( _, _, val )
    SimfphysLimit = tonumber( val )
end )

local LFSLimit = CreateConVar( "vehiclelimiter_lfs_max", 2, { FCVAR_ARCHIVE }, "The max amount of LFS vehicles can spawn.", 0 ):GetInt()
cvars.AddChangeCallback( "vehiclelimiter_lfs_max", function( _, _, val )
    LFSLimit = tonumber( val )
end )

local function sendLimitNotification( ply, str )
    net.Start( "simphysLFSLimiterNotify" )
    net.WriteString( str )
    net.Send( ply )
end

-- Simfphys restriction hooks
hook.Add( "PlayerSpawnVehicle", "limitSimphysVehicles", function( ply, _, _, vehTable )
    if vehTable.Class ~= "gmod_sent_vehicle_fphysics_base" and not extraVehicles[vehTable.Name] then return end
    if ply:GetCount( "max_simphys_vehicles" ) < SimfphysLimit then return end
    sendLimitNotification( ply, "simfphys" )
    return false
end )

hook.Add( "PlayerSpawnedVehicle", "limitSimphysVehicles", function( ply, ent )
    if ent:GetClass() ~= "gmod_sent_vehicle_fphysics_base" then return end
    ply:AddCount( "max_simphys_vehicles", ent )
end )

-- LFS restriction hook
hook.Add( "PlayerSpawnSENT", "limitLFSVehicles", function( ply, ent )
    if not string.StartWith( ent, "lfs_" ) and not string.StartWith( ent, "lunasflightschool_" ) then return end
    if ply:GetCount( "max_lfs_vehicles" ) < LFSLimit then return end
    sendLimitNotification( ply, "LFS" )
    return false
end )

hook.Add( "PlayerSpawnedSENT", "limitLFSVehicles", function( ply, ent )
    if not ent.LFS then return end
    ply:AddCount( "max_lfs_vehicles", ent )
end )
