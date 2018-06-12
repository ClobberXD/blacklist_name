--
--	blacklist_name
--

-- initialize mod storage and blacklist
local mod_storage = minetest.get_mod_storage()
local blacklist = minetest.parse_json(mod_storage:get_string("blacklist")) or {}

local disconnect_reason = "\nThis name has been blacklisted by the server staff.\nPlease use another name."

-- dofile chatcmdbuilder.lua
dofile(minetest.get_modpath("blacklist_name") .. "/chatcmdbuilder.lua")

-- /blacklist command
ChatCmdBuilder.new("blacklist", function(cmd)
		-- add sub-command
		cmd:sub("add :name", function(caller, name)
			local lname = name:lower()
			for _, blacklist_entry in pairs(blacklist) do
				if blacklist_entry == lname then
					return false, "Could not add \"" .. name .. "\". Name has already been blacklisted."
				end
			end
			
			-- kick player if online
			local player_name = minetest.get_player_by_name(name)
			if player then
				minetest.kick_player(name, disconnect_reason)
			end
			
			-- insert element and update mod-storage
			table.insert(blacklist, lname)
			mod_storage:set_string("blacklist", minetest.write_json(blacklist))
			return true, "Successfully added \"" .. name .. "\" to the blacklist."
		end)
		
		-- remove sub-command
		cmd:sub("remove :name", function(caller, name)
			local lname = name:lower()
			for key, blacklist_entry in pairs(blacklist) do
				if blacklist_entry == lname then
					-- delete element and update mod-storage
					blacklist[key] = nil
					mod_storage:set_string("blacklist", minetest.write_json(blacklist))
					return true, "Successfully removed \"" .. name .. "\" from the blacklist."
				end
			end
			return false, "Could not remove \"" .. name .. "\". Name has not been blacklisted yet."
		end)
		
		-- list sub-command
		cmd:sub("list", function(name)
			local names_str = table.concat(blacklist, ", ")
			if names_str == "" then
				names_str = "No names have been blacklisted yet."
			end
			return true, names_str
		end)
		
	end, {
		params = "<add|remove|list> [<name>]",
		description = "Add, remove or list blacklisted names",
		privs = {kick = true, ban = true}
})

minetest.register_on_prejoinplayer(function(name, ip)
	for _, blacklist_entry in pairs(blacklist) do
		if name:lower() == blacklist_entry then
			return disconnect_reason
		end
	end
end)
