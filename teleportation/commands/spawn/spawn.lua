local Command = require("Command")
local Permission = require("Permission")
local Spawnpoint = require("Spawnpoint")
local Locationstack = require("Locationstack")

local function harmlessLightning(location)
	location:getWorld():strikeLightningEffect(location)
end

Command:register{
	name = "spawn",
	action = {
		format = "%s teleported to the spawnpoint of group %s",
		isProperty = false
	},
	arguments = {
		{
			name = "group",
			type = "string",
			required = false
		}
	},
	run = function(self, ply, args)
		local doLightning = flags:contains("l")
		if doLightning then
			harmlessLightning(ply:getLocation())
		end
		
		if not args.group then
			Locationstack:add(ply)
			ply:teleportToSpawn()
			self:sendActionReply(ply, ply, {
				format = "%s teleported the spawnpoint of %s group",
				isProperty = true
			})
		elseif Permission:getGroupImmunityLevel(args.group) <= ply:getImmunityLevel() then
			Locationstack:add(ply)
			ply:teleport(Spawnpoint:getPlayerSpawn(ply, args.group, true))
			self:sendActionReply(ply, nil, {}, args.group)
		else
			ply:sendError("Permission denied")
		end

		if doLightning then
			harmlessLightning(ply:getLocation())
		end
	end
}
