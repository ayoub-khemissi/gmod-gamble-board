GambleBoard = GambleBoard or {}

-- Shared
include("gambleboard/shared/sh_config.lua")

if SERVER then
    -- Send client files
    AddCSLuaFile("gambleboard/shared/sh_config.lua")
    AddCSLuaFile("gambleboard/client/cl_fonts.lua")
    AddCSLuaFile("gambleboard/client/cl_notifications.lua")
    AddCSLuaFile("gambleboard/client/cl_menu.lua")

    -- Include server files
    include("gambleboard/server/sv_network.lua")
    include("gambleboard/server/sv_data.lua")
    include("gambleboard/server/sv_coingame.lua")
    include("gambleboard/server/sv_crash.lua")
    include("gambleboard/server/sv_tower.lua")

    print("[GambleBoard] Server loaded successfully!")
end

if CLIENT then
    include("gambleboard/client/cl_fonts.lua")
    include("gambleboard/client/cl_notifications.lua")
    include("gambleboard/client/cl_menu.lua")

    print("[GambleBoard] Client loaded successfully!")
end
