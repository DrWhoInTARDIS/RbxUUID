local RunService = game:GetService("RunService")
local TestService = game:GetService("TestService")
local Rando = Random.new()
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")

--Shared Library
--Note: This can not require Marvin or GLaDOS or else the code will go in circles!

local module = {}
local m = module

--use like print()
function module.throw(...)
	warn(debug.traceback("Mainframe Throw:",2))
	local arguments = {...}
	local message = "\n"
	for _,v in ipairs(arguments)do
		message = message .. tostring(v)
	end
	TestService:Message(message.."\nSee Orange above for location. "..string.char(1).."\n\aEND OF LINE\a")
end


function module.tern(condition :boolean, rTrue, rFalse)
	if condition then return rTrue else return rFalse end
end
_G.tern = module.tern


-- it annoys me that there is no self for the condition in an if
-- this is meant to fix that, however, I don't like the code style
-- as you must put code before the con. Prolly won't use
function module.runThisIf(func,con,...)
	if con then return func(con,...) end
end


function module.WhereAmI()
    local RunService = game:GetService("RunService")
	local location = ""

    if RunService:IsClient() then
    	location ..= "I am a client"
	elseif RunService:IsServer() then
    	location ..= "I am a server"
	end

	if RunService:IsStudio() then
    	location ..= ", in Studio"
    else
    	location ..= ", in an online "
		if game.PrivateServerId ~= "" then
			location ..= "private "
		end
		location ..= "server"
    end

	if RunService:IsRunMode() then
    	location ..= ", Running in Studio"
    end

	return location
end


function module.DisplayRay(start :Vector3, stop :Vector3, distance :number?, life :number?) --https://devforum.roblox.com/t/how-do-you-visualize-a-raycast-as-a-part/657972/5
    local distance = distance or (start-stop).Magnitude
    local life = life or 0.2
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CastShadow = false
    p.Color = Color3.new(Rando:NextNumber(),Rando:NextNumber(),Rando:NextNumber())
    p.Size = Vector3.new(0.1, 0.1, distance)
    p.CFrame = CFrame.lookAt(start, stop)*CFrame.new(0, 0, -distance/2)
    p.Parent = workspace
    delay(life,function()
        p:Destroy()
    end)
end


function module.DisplayBeam(start :Part, stop :Vector3, life :number?)
	life = life or 0.2
	local Attachment = Instance.new("Attachment")
	Attachment.Position = stop

	local Beam = Instance.new("Beam")
	Beam.FaceCamera = true
	Beam.Attachment0 = start:FindFirstChild("Attachment") or (function () Instance.new("Attachment",start) return start.Attachment end)()
	Beam.Attachment1 = Attachment
	Beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(math.random(),math.random(),math.random())),
		ColorSequenceKeypoint.new(1, Color3.new(math.random(),math.random(),math.random())),
	})

	Beam.Parent = Attachment
	Attachment.Parent = workspace.BeamHolder

	delay(life,function()
		Attachment:Destroy()
	end)
end


--this function kinda sucks, use hasNestedChildren or hasChildren instead
function module.checkThesePlz(array) --{parent,check,check,check...} !OR! { {parent,check} , {parent,check}, etc }
	local function checkTHIS(parent,child)
		return parent[child]
	end

	local parent, child, outBool, outPrint
	outBool = true
	outPrint=""

	for ctp1,ctp2 in ipairs(array) do
		if type(ctp2)=="table" then
			--print("Going Deeper:", ctp1)
			local deepBool,deepPrint = module.checkThesePlz(ctp2)
			if deepBool == false then
				outBool=false
				outPrint = outPrint .. "\n\r" .. deepPrint
			end

		elseif ctp1 == 1 then
			parent = ctp2
			continue
		else
			child = ctp2
		end
		local pcBool,pcResult = pcall(checkTHIS, parent, child)
		if pcBool == false then
			outBool=false
			outPrint = outPrint .. "\n" .. pcResult
		end
	end
	if outBool==true then outPrint="YES, YES, YEAHHHHHHHHS" end
	--print(outBool,outPrint)
	return outBool, outPrint
end


--converts a table to a string that you can print vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
function module.tprint(tbl :table, indent) :string
	if not indent then indent = 0 end
	local toprint = string.rep(" ", indent) .. "{\r\n"
	indent = indent + 2
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if (type(k) == "number") then
			toprint = toprint .. "[" .. k .. "] = "
		elseif (type(k) == "string") then
			toprint = toprint  .."[\"".. k .."\"]"..  " = "
		end
		if (type(v) == "number") then
			toprint = toprint .. v .. ",\r\n"
		elseif (type(v) == "string") then
			toprint = toprint .. "\"" .. v .. "\",\r\n"
		elseif (type(v) == "table") then
			toprint = toprint .. module.tprint(v, indent + 2) .. ",\r\n"
		else
			toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
		end
	end
	toprint = toprint .. string.rep(" ", indent-2) .. "}"
	return toprint
end


function  module.tableSerialize(myTable)
	local tempTable = {}
	local i =1
	for k,v in pairs(myTable) do
		if type(v)=="table" then
			v=module.tableSerialize(v)
		end
		tempTable[i] = {k,v}
		i+=1
	end
	return tempTable
end


function  module.tableDeserialize(myTable)
	local tempTable = {}
	for _,t in pairs(myTable) do
		if type(t[2]) == "table" then
			t[2] = module.tableDeserialize(t[2])
		end
		tempTable[t[1]] = t[2]
	end
	return tempTable
end


--expects pure number array. Unknown for any other type.
-- {[1] = "chad", [5] = "Hi", [3] = "E"} to {[1] = "chad", [2] = "Hi", [3] = "E"} results MAY be ranomized depending on data
-- or if keeporder is true: {[1] = "chad", [2] = "E", [3] = "Hi"}
function module.tableShrink(myTable, keepOrder)
	local tempTable = {}
	local i = 1
	if keepOrder then
		local nonNumbers = {}
		for k,v in pairs(myTable) do
			if type(k) ~= "number" then
				nonNumbers[k] = v
			else
				tempTable[i] = {k,v}
				i=i+1
			end
		end
		table.sort(tempTable,function(a,b) return a[1] < b[1] end)
		table.foreachi(tempTable,function(k,v) tempTable[k] = v[2] end)
		table.foreach(nonNumbers,function(k,v) tempTable[k] = v end)
	else
		for k,v in pairs(myTable) do
			tempTable[i] = v
			i=i+1
		end
	end
	return tempTable
end


function module.tableCopy(myTable :table, keepMeta :boolean?)
	local tempTable = {}
	for k,v in pairs(myTable) do
		tempTable[k] = v
	end
	if keepMeta then
		setmetatable(tempTable, getmetatable(myTable))
	end
	return tempTable
end


function module.tableDeepCopy(orig, copies) -- brought to you by http://lua-users.org/wiki/CopyTable
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[module.tableDeepCopy(orig_key, copies)] = module.tableDeepCopy(orig_value, copies)
			end
			setmetatable(copy, module.tableDeepCopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end


function module.tableFlip(myTable)
	local tempTable = {}
	for k,v in pairs(myTable) do
		tempTable[v] = k
	end
	return tempTable
end


function module.tableReverse(myTable :Array<any>) :Array<any>
	local temp = {}
	for i=#myTable,1,-1 do
		table.insert(temp,myTable[i])
	end
	return temp
end


function module.tableFind(myTable,search)
	for k,v in pairs(myTable) do
		if v == search then return k end
	end
end


function module.tableCount(myTable) :number
	local i = 0
	for k,v in pairs(myTable) do
		i+=1
	end
	return i
end


-- args must be tables
function module.tableAppend(myTable,... :table)
	for _,toAdd in pairs({...}) do
		for k,v in pairs(toAdd) do
			myTable[k]=v
		end
	end
	return myTable --if you want to use it
end


function module.tableForPairs(t, callback :(table,any,any) -> ()) :table
	for k,v in pairs(t) do callback(t,k,v) end
	return t
end


function module.isSameTable(tab1,tab2) :boolean
	if type(tab1) ~= "table" or type(tab2)~="table" then return false end
	if tab1==tab2 then return true end
	local temp1, temp2 = module.tableCopy(tab1), module.tableCopy(tab2)
	for k,v in pairs(temp1) do
		--print("Table1",temp1,k,v,"Table2",temp2,temp2[k],module.isSameTable(v,temp2[k]))
		if temp2[k] == v or module.isSameTable(v,temp2[k]) then
			temp2[k] = nil
			temp1[k] = nil
		end
	end
	for k,v in pairs(temp2) do
		--print("Table2",temp1,k,v,"Table1",temp2,temp2[k],module.isSameTable(v,temp2[k]))
		if temp1[k] == v or module.isSameTable(v,temp1[k]) then
			temp1[k] = nil
			temp2[k] = nil
		end
	end
	return module.tableCount(temp1)==0 and module.tableCount(temp2)==0
end


function module.tobool(value) :boolean?
	return m.tableAppend(
		m.tableForPairs({true,1,"t","tru"},function(t,k,v) t[tostring(v)] = true end),
		m.tableForPairs({false,0,"f"},function(t,k,v) t[tostring(v)] = false end)
	)[string.lower(tostring(value))]
end


--http://lua-users.org/wiki/SimpleRound
function module.sign(v)
	return (v >= 0 and 1) or -1
end
function module.round(v, bracket) -- (5.6, 7) -> 7
	bracket = bracket or 1
	return math.floor(v/bracket + module.sign(v) * 0.5) * bracket
end


function module.waitForChildren(waitTime :number?, parent :Instance, ...) :(boolean,string)
	local output, good, total = "Missing:",true,0
	for _,child in ipairs({...}) do
		total +=1
		spawn(function()
			if not parent:WaitForChild(child,waitTime) then
				good = false
				output ..= ", " .. child
			end
			total -= 1
		end)
	end
	repeat wait() until total==0
	return good, output
end


function  module.waitForNested(waitTime :number?, parent :Instance, child :string, ...) :Instance?
	if not (parent and child) then return parent end
	return module.waitForNested(waitTime,parent:WaitForChild(child,waitTime),...)
end


-- children are expected to be like: {parent , child} so func(parent,child,{child to become parent, child ,child})
function module.waitForNestedChildren(waitTime :number?, parent :Instance, ...) :(boolean,string)
	local args = {...}
	local deep = {}
	for k,child in ipairs(args) do
		if type(child) == "table" then
			args[k] = child[1]
			deep[child[1]] = child
		end
	end
	local good,result = module.waitForChildren(waitTime,parent,unpack(args))
	if not good then return good,result end
	local hasAll, total, missing = true,0,"Missing:"
	for name,children in pairs(deep) do
		total += 1
		spawn(function()
			local good, result = module.waitForNestedChildren(waitTime,parent:FindFirstChild(name),select(2,unpack(children)))
			if not good then
				hasAll = false
				missing ..= "\n" .. name .. " " .. result
			end
			total -= 1
		end)
	end
	repeat wait() until total==0
	return hasAll,missing
end


function module.hasNested(parent, ...) :(boolean,any)
	return pcall(function(...)
		for _, childName in pairs({...}) do
			parent = parent[childName]
		end
		return parent
	end, ...)
end


function module.hasChildren(parent, ...) :(boolean,string)
	local good, missing = true, "Missing:"
	pcall(function(...)
		for _, childName in pairs({...}) do
			if not pcall(function() _ = parent[childName] end) then
				missing ..= " " .. childName
				good = false
			end
		end
	end, ...)
	return good, missing
end


function module.hasNestedChildren(parent, ...) :(boolean,string)
	local good, missing = true, "Missing:"
	local lookInto = {}
	for _, child in pairs({...}) do
		local checkfor = child
		if type(child)=="table" then
			checkfor = child[1]
		end
		local subGood, result = pcall(function() return parent[checkfor] end)
		if not subGood then
			good = false
			missing ..= " " .. checkfor
		elseif type(child)=="table" then
			child[1] = result
			lookInto[child] = checkfor
		end
	end

	for deep,name in pairs(lookInto) do
		local subGood, result = module.hasNestedChildren(table.unpack(deep))
		if subGood == false then
			good = false
			missing ..= "\n" .. tostring(parent).. "." .. name .. " " .. result
		end
	end

	return good,missing
end


function module.getLevelsToParent(myThing :Instance, parent :Instance, level) :number
	assert(level or myThing:IsDescendantOf(parent), myThing:GetFullName() .. " is not descendant of " .. parent:GetFullName())
	level = level or 1
	if myThing.Parent == parent then return level end
	return module.getLevelsToParent(myThing.Parent,parent,level+1)
end


function module.ascendToChildOfParent(myThing :Instance, parent :Instance, stopLevelsAwayFromParent, level)
	if not myThing.Parent then error(myThing:GetFullName() .. " is not descendant of " .. parent:GetFullName()) end
	stopLevelsAwayFromParent = stopLevelsAwayFromParent or 1
	level = level or module.getLevelsToParent(myThing,parent)
	if level == stopLevelsAwayFromParent or myThing.Parent == parent then return myThing end
	return module.ascendToChildOfParent(myThing.Parent,parent,stopLevelsAwayFromParent,level-1)
end


print("MainFrame Loaded")
return module

--End of Line