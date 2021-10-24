--[[
	Description:
		Creates a UUID for all instances and is guaranteed to never be the same in the same server.
		The uuid string will never be deleted but the inst referance to it can be.
	Useage:
		_G.uuidTable[inst]
			- returns a string uuid, nil if not found, or nil inst was destroyed
		_G.uuidTable[string uuid]
			- returns inst, string "null" if inst was Destroyed, or nil if uuid was never created
	Notes:
		-Might Take a sec or two to start up
			if NOT _G.uuidTable == NIL then you are good to go
		-This does NOT CROSS the client/server boundry
		-This remembers EVERY UUID CREATED IN THE Game
			I do not know if that is a problem for a server that runs for a week
	~DrWhoInTARDIS
]]

local p = "UUID Service:"
math.randomseed(os.clock())
random = math.random

function uuid() --function from https://gist.github.com/jrus/3197011
	return string.gsub('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'x', function ()
		return utf8.char(random(0,127))
	end)
end

uuidTable = {
	size = {
		["Insts"] = 0,
		["IDs"] = 0,
		add = function(self,n)
			self.Insts = self.Insts + n
			self.IDs = self.IDs + n
		end,
		sub = function(self,n)
			self.Insts = self.Insts - n
		end
	}
}
setmetatable(uuidTable.size, {
	__call = function(t)
		local total = 0
		local outString = ""
		for k,v in pairs(t) do
			if type(v)==type(1) then
				outString = outString .. " #" .. tostring(k) .. ": " .. tostring(v)
				total = total + v
			end
		end
		return p .. " Size: " .. tostring(total) .. outString
	end
})
function putUUID(thing)
	local myUUID = uuid()

	if not uuidTable[myUUID] == nil then
		print(p,"ERROR generating ID!!!! Same UUID as generated!", myUUID)
		putUUID(thing)
	elseif not uuidTable[thing] == nil then
		print(p,"ERROR given UUID!!! Already has UUID!", thing:GetFullName())
	else
		uuidTable[myUUID] = thing
		uuidTable[thing] = myUUID
		uuidTable.size:add(1)
	end
end

for _,des in ipairs(game:GetDescendants()) do
	local good, message = pcall(putUUID,des)
	--if not good then print(message)end
end

game.DescendantAdded:Connect(function(des)
	local good, message = pcall(putUUID,des)
	--if not good then print(message)end
end)
game.DescendantRemoving:Connect(function(des)
	local found = uuidTable[des]
	if found == nil then
		--warn(p,"ERROR Removing ID!!! Could not find UUID for",pcall(function()return des:GetFullName()end))
	else
		--print("removing",des:GetFullName(),found)
		uuidTable[found] = ""
		uuidTable[des] = nil
		uuidTable.size:sub(1)
	end
end)

_G.uuidTable = uuidTable

repeat
	print(_G.uuidTable.size())
until not wait(60*2)