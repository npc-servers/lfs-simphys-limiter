net.Receive( "simpfhysLFSLimiterNotify", function()
    local message = net.ReadString()

    surface.PlaySound( "buttons/button10.wav" )
    notification.AddLegacy( "You've hit the " .. message .. " limit!", NOTIFY_ERROR, 2 )
end )
