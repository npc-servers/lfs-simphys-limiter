-- Some simpfhys vehicles dont have .Class
local extraVehicles = {
    ["DIPRIP - Ratmobile"] = true,
    ["DIPRIP - Chaos126p"] = true,
    ["DIPRIP - Hedgehog"] = true
}

util.AddNetworkString( "simpfhysLFSLimiterNotify" )

-- Convars
local simfphysLimit = CreateConVar( "vehiclelimiter_simpfhys_max", 3, { FCVAR_ARCHIVE }, "The max amount of simpfhys vehicles players can spawn.", 0 )
local simfphysAdminBypass = CreateConVar( "vehiclelimiter_simpfhys_adminbypass", 0, { FCVAR_ARCHIVE }, "If admins and higher ranks can bypass the simpfhys limit.", 0 )
local LFSLimit = CreateConVar( "vehiclelimiter_lfs_max", 2, { FCVAR_ARCHIVE }, "The max amount of LFS vehicles can spawn.", 0 )
local LFSAdminBypass = CreateConVar( "vehiclelimiter_lfs_adminbypass", 0, { FCVAR_ARCHIVE }, "If admins and higher ranks can bypass the simpfhys limit.", 0 )

local function sendLimitNotification( ply, str )
    net.Start( "simpfhysLFSLimiterNotify" )
    net.WriteString( str )
    net.Send( ply )
end

-- Simfphys restriction hooks
hook.Add( "PlayerSpawnVehicle", "limitsimpfhysVehicles", function( ply, _, _, vehTable )
    if simfphysAdminBypass:GetBool() and ply:IsAdmin() then return end
    if not vehTable then return end
    if vehTable.Class ~= "gmod_sent_vehicle_fphysics_base" and not extraVehicles[vehTable.Name] then return end
    if ply:GetCount( "max_simpfhys_vehicles" ) < simfphysLimit:GetInt() then return end
    sendLimitNotification( ply, "Simfphys" )
    return false
end )

hook.Add( "PlayerSpawnedVehicle", "limitsimpfhysVehicles", function( ply, ent )
    if ent:GetClass() ~= "gmod_sent_vehicle_fphysics_base" then return end
    ply:AddCount( "max_simpfhys_vehicles", ent )
end )

-- LFS restriction hook
local lfsClasses = {}
hook.Add( "PlayerSpawnSENT", "limitLFSVehicles", function( ply, class )
    if LFSAdminBypass:GetBool() and ply:IsAdmin() then return end

    if not lfsClasses[class] then return end

    if ply:GetCount( "max_lfs_vehicles" ) < LFSLimit:GetInt() then return end
    sendLimitNotification( ply, "LFS" )
    return false
end )

hook.Add( "PlayerSpawnedSENT", "limitLFSVehicles", function( ply, ent )
    if not ent.LFS then return end
    lfsClasses[ent:GetClass()] = true
    ply:AddCount( "max_lfs_vehicles", ent )
end )
