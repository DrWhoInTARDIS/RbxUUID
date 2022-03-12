local RunService = game:GetService("RunService")
local TestService = game:GetService("TestService")
local GuiService = game:GetService("GuiService")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local Types = require(script.Parent.Types)
local Rando = Random.new()
local p = "Mainframe:"

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
    distance = distance or (start-stop).Magnitude
    life = life or 0.2
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


function module.tableSerialize(myTable)
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


function module.tableDeserialize(myTable)
	local tempTable = {}
	for _,t in pairs(myTable) do
		if type(t[2]) == "table" then
			t[2] = module.tableDeserialize(t[2])
		end
		tempTable[t[1]] = t[2]
	end
	return tempTable
end


--shrinks the number portion of a table to an array
--keeps the non number keys
--results may be randomized if keepOrder ~= true
function module.tableShrink(myTable, keepOrder :boolean)
	local shrunk = {}
	local numbs :{{k:number,v:any}} = {}
	for k,v in pairs(myTable) do
		if type(k)=="number" then
			if keepOrder
			then table.insert(numbs,{k=k,v=v})
			else table.insert(shrunk,v)
			end
		else
			shrunk[k] = v
		end
	end
	table.sort(numbs, function(a,b) return a.k < b.k end)
	for newSpot,original in ipairs(numbs) do
		shrunk[newSpot] = original.v
	end
	return shrunk
end


--modify is optional. if use: return key,value
function module.tableCopy(t :table, keepMeta :boolean?, modify :((t :table, k :any, v :any, copy :table) -> (any,any))) :table
	local tempTable = {}
	if modify then
		for k,v in pairs(t) do
			k,v = modify(t,k,v,tempTable)
			if k==nil or v==nil then continue end
			tempTable[k] = v
		end
	else
		for k,v in pairs(t) do
			tempTable[k] = v
		end
	end

	if keepMeta then
		setmetatable(tempTable, getmetatable(t))
	end
	return tempTable
end


function module.tableGetRandomElement(myTable :table) :(any, any)
	local count = module.tableCount(myTable)
	local stopOn = Rando:NextInteger(1,count)
	local i = 0
	for k,v in pairs(myTable) do
		i +=1
		if i == stopOn then
			return k,v
		end
	end
end


function module.tableShuffle(myTable :{})
	local shuffled, values = {}, {}
	for _,v in pairs(myTable) do
		table.insert(values,v)
	end
	for k in pairs(myTable) do
		local vn,newValue = module.tableGetRandomElement(values)
		shuffled[k] = newValue
		values[vn] = nil
	end
	return shuffled
end


--table.concat only works for num/string so use this
--rename to array concat sometime
function module.tableConcat(myTable :Array<any>, sep :string?, start :number?, stop :number?) :string
	local out = ""
	sep = sep or ""
	for i = start or 1, stop or #myTable do
		out ..= tostring(myTable[i])
		if i~=stop then
			out ..= sep
		end
	end
	return out
end


function module.tableBisect(myTable :Array<any>, start :number, stop :number?) :Array<any>
	local out = {}
	for i = start, stop or #myTable do
		table.insert(out,myTable[i])
	end
	return out
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


---@return boolean found
---@return any key
---@return any value
function module.tableFind(myTable :table, search)
	for k,v in pairs(myTable) do
		if v==search then return true,k,v end
	end
	return false
end


function module.tableCount(myTable :table) :number
	local i = 0
	for k,v in pairs(myTable) do
		i+=1
	end
	return i
end


--may overwrites keys in orginal table
function module.tableAppend(myTable, ... :table)
	for _,toAdd in pairs({...}) do
		for k,v in pairs(toAdd) do
			myTable[k]=v
		end
	end
	return myTable
end

--tacks args on the end
function module.tableInsert(myTable, ...)
	for _,v in pairs({...}) do
		table.insert(myTable,v)
	end
	return myTable
end


function module.tableForPairs(t, callback :(t :table, k :any, v :any) -> ()) :table
	for k,v in pairs(t) do callback(t,k,v) end
	return t
end


--creates new table with same keys* and new values
--*if return is nil then no key obv
function module.tableMap(t, callback :(v :any) -> (any))
	local out = {}
	for k,v in pairs(t) do
		out[k] = callback(v)
	end
	return out
end


--new table with true filter returns. Doesn't modify k/v
function module.tableFilter(t, filter :(t :{any}, k :any, v :any)->(boolean))
	local tempTable = {}
	for k,v in pairs(t) do
		if filter(t,k,v) then
			tempTable[k] = v
		end
	end
	return tempTable
end


--new shrunk array with true filter returns. Doesn't modify v
function module.arrayFilter(t, filter :(t :{any}, k :any, v :any)->(boolean))
	local tempTable = {}
	for k,v in ipairs(t) do
		if filter(t,k,v) then
			table.insert(tempTable,v)
		end
	end
	return tempTable
end


function module.arrayRemoveDupes(t)
	local values = {}
	local tempTable = {}
	for k,v in ipairs(t) do
		if values[v] then continue end
		values[v] = k
		table.insert(tempTable,v)
	end
	return tempTable
end


function module.arrayAppendArray(t, toAppend)
	for _,v in ipairs(toAppend) do
		t[#t+1] = v
	end
	return t
end


function module.isSameTable(tab1 :table?, tab2 :table?) :boolean
	if type(tab1) ~= "table" or type(tab2)~="table" then return false end
	if tab1==tab2 then return true end
	for k,v in pairs(tab1) do
		if tab2[k] ~= v and not module.isSameTable(v,tab2[k]) then
			return false
		end
	end
	for k,v in pairs(tab2) do
		if tab1[k] ~= v and not module.isSameTable(v,tab1[k]) then
			return false
		end
	end
	return true
end


function module.tobool(value) :boolean?
	return m.tableAppend(
		m.tableForPairs({true,1,"t","tru"},function(t,k,v) t[tostring(v)] = true end),
		m.tableForPairs({false,0,"f"},function(t,k,v) t[tostring(v)] = false end)
	)[string.lower(tostring(value))]
end


--(v >= 0 and 1) or -1
function module.sign(v)
	return (v >= 0 and 1) or -1
end
--http://lua-users.org/wiki/SimpleRound
function module.round(v, bracket) -- (5.6, 7) -> 7
	bracket = bracket or 1
	local rounded = v/bracket + module.sign(v) * 0.5
	if module.sign(v) == 1 then
		rounded = math.floor(rounded)
	else
		rounded = math.ceil(rounded)
	end
	return rounded * bracket
end

function module.sameSign(ignore0 :boolean,... :number)
	local args = {...}
	local firstSign = m.sign(args[1])
	for i=2,#args do
		if ignore0 and args[i]==0 then continue end
		if firstSign ~= m.sign(args[i]) then
			return false
		end
	end
	return true
end


---@param start number
---@param delta number +towards0, -awayfrom0
---@return number
function module.moveTo0(start, delta)
	return start + (if start>0 then -delta else delta)
end


function module.isInRange(n :number, min :number, max :number)
	return min <= n and n <= max
end


--for use in a box with ancorpoint .5,.5 remember to y = -y
function module.pointOnCircle(radius :number, degrees :number) :Vector2
	local angle = math.rad(degrees)
	return Vector2.new(radius*math.sin(angle), radius*math.cos(angle))
end


function module.midpoint(x1,y1,x2,y2) :(number,number)
	return (x1+x2)/2, (y1+y2)/2
end


function module.gmatches(s :string, pattern :string) :{string}
	local matches = {}
	for match in string.gmatch(s, pattern) do
		table.insert(matches,match)
	end
	return matches
end


module.fuzz = {
	X = nil ::number;
	Y = nil ::number;
	Z = nil ::number?;
	__type = "fuzzy";
}
module.fuzz.__index = module.fuzz
function module.fuzz:Magnitude() return math.sqrt((self^2):Sum()) end
function module.fuzz:Unit() return self/self:Magnitude() end
function module.fuzz:Unpack() return self.X,self.Y,self.Z end
function module.fuzz:ToVector3() return Vector3.new(self:Unpack()) end
function module.fuzz:ToVector2() return Vector2.new(self:Unpack()) end
function module.fuzz:ToList() return {self:Unpack()} end
function module.fuzz:FromList(from) return module.fuzz.new3(unpack(from)) end
function module.fuzz:ToDict() return {X=self.X,Y=self.Y,Z=self.Z} end
function module.fuzz:FromDict(from) return module.fuzz.new3(from.X,from.Y,from.Z) end
function module.fuzz:Sum()
	local i = 0
	for _,v in ipairs(self:ToList()) do i+=v end
	return i
end
function module.fuzz:ClampMagnitude(n :number)
	return if self:Magnitude() > math.abs(n) then self:Unit()*n else self
end
function module.fuzz:Equals(thing) return pcall(function()
		assert(thing.X == self.X)
		assert(thing.Y == self.Y)
		if self.Z then assert(thing.Z == self.Z) end
end) end
function module.fuzz:Compatible(thing) return pcall(function()
	assert(thing.X and thing.Y)
	if self.Z then assert(thing.Z) end
end) end
function module.fuzz.isFuzzy(thing) return pcall(function()
		assert(thing.__type == "fuzzy")
end) end

function module.fuzz:Operate(callback :(v:number, op :number)->(number), op)
	assert(type(op)=="number" or self:Compatible(op),"Uncompatable Operand")
	local newFuzz = self:ToDict()
	for k,v in pairs(newFuzz) do
		newFuzz[k] = callback(v, if type(op)=="number" then op else op[k])
	end
	return self:FromDict(newFuzz)
end
function module.fuzz:FuncOp(callback :(v:number)->(number),...)
	local newFuzz = self:ToDict()
	for k,v in pairs(newFuzz) do
		newFuzz[k] = callback(v,...)
	end
	return self:FromDict(newFuzz)
end
function module.fuzz.__pow(self,toOp)
	if not module.fuzz.isFuzzy(self) then local i=toOp; toOp=self; self=i end
	return self:Operate(function(v,op) return v^op end, toOp)
end
function module.fuzz.__mod(self,toOp)
	if not module.fuzz.isFuzzy(self) then local i=toOp; toOp=self; self=i end
	return self:Operate(function(v,op) return v%op end, toOp)
end
function module.fuzz.__mul(self,toOp)
	if not module.fuzz.isFuzzy(self) then local i=toOp; toOp=self; self=i end
	return self:Operate(function(v,op) return v*op end, toOp)
end
function module.fuzz.__div(self,toOp)
	if not module.fuzz.isFuzzy(self) then local i=toOp; toOp=self; self=i end
	return self:Operate(function(v,op) return v/op end, toOp)
end
function module.fuzz.__add(self,toOp)
	if not module.fuzz.isFuzzy(self) then local i=toOp; toOp=self; self=i end
	return self:Operate(function(v,op) return v+op end, toOp)
end
function module.fuzz.__sub(self,toOp)
	if not module.fuzz.isFuzzy(self) then local i=toOp; toOp=self; self=i end
	return self:Operate(function(v,op) return v-op end, toOp)
end
function module.fuzz:__umm()
	return self * -1
end
function module.fuzz:__tostring()
	return "["..self.X..", "..self.Y..(if self.Z then ", "..self.Z else "").."]"
end
function module.fuzz:__eq(thing)
	return self:Equals(thing)
end

function module.fuzz.new3FromVect(v :Vector3|Vector2)
	return module.fuzz.new3(v.X,v.Y,v.Z)
end
function module.fuzz.new3(x,y,z)
	local fuzz3 = {
		X = x or 0;
		Y = y or 0;
		Z = z or 0;
	}
	return setmetatable(fuzz3,module.fuzz)
end

function module.fuzz.new2FromVect(v :Vector2|Vector3)
	return module.fuzz.new2(v.X,v.Y)
end
function module.fuzz.new2(x,y)
	local fuzz2 = {
		X = x or 0;
		Y = y or 0;
	}
	function fuzz2:FromList(from) return module.fuzz.new2(unpack(from)) end
	function fuzz2:FromDict(from) return module.fuzz.new2(from.X,from.Y,from.Z) end
	return setmetatable(fuzz2,module.fuzz)
end

export type Fuzz3 = typeof(module.fuzz.new3())
export type Fuzz2 = typeof(module.fuzz.new2())

--pitch yaw roll
---https://math.stackexchange.com/a/1741317
---@param point Fuzz3
---@param rotate Fuzz3 degrees
---@return Fuzz3
function module.pointRotate(point, rotate)
	rotate = module.fuzz.new3(rotate.X,rotate.Y,-rotate.Z) --Flip Z because reasions
	rotate = rotate:FuncOp(math.rad) ::Fuzz3
	local cos = rotate:FuncOp(math.cos)
	local sin = rotate:FuncOp(math.sin)
	local Ax :Fuzz3 = m.fuzz.new3(cos.Y*cos.Z, cos.X*sin.Z + sin.X*sin.Y*cos.Z, sin.X*sin.Z - cos.X*sin.Y*cos.Z)
	local Ay :Fuzz3 = m.fuzz.new3(-cos.Y*sin.Z, cos.X*cos.Z - sin.X*sin.Y*cos.Z, sin.X*cos.Z + cos.X*sin.Y*sin.Z)
	local Az :Fuzz3 = m.fuzz.new3(sin.Y, -sin.X*cos.Y, cos.X*cos.Y)
	Ax *= point
	Ay *= point
	Az *= point
	return module.fuzz.new3(Ax:Sum(), Ay:Sum(), Az:Sum()) --roll,yaw,pitch
end



local tomt = {__index = {tostring = tostring}}
module.string = setmetatable({
	tonumber = tonumber;
	toUDim = function(s :string)
		local matches = module.gmatches(s,"%d+")
		return if #matches==2 then UDim.new(unpack(matches)) else nil
	end;
	toUDim2 = function(s :string)
		local matches = module.gmatches(s,"%d+")
		return if #matches==4 then UDim2.new(unpack(matches)) else nil
	end;
	toVector2 = function(s :string)
		local matches = module.gmatches(s,"%d+")
		return if #matches==2 then Vector2.new(unpack(matches)) else nil
	end;
	toVector3 = function(s :string)
		local matches = module.gmatches(s,"%d+")
		return if #matches==3 then Vector3.new(unpack(matches)) else nil
	end;
},tomt)
module.UDim2 = setmetatable({
	toVector2 = function(u :UDim2)
		return Vector2.new(u.X.Offset,u.Y.Offset)
	end;
	toVector3 = function(u :UDim2)
		return Vector3.new(u.X.Offset,u.Y.Offset)
	end;
},tomt)
module.Vector2 = setmetatable({
	toUDim2 = function(v :Vector2, xScale :number?, yScale :number?)
		return UDim2.new(xScale, v.X, yScale, v.Y)
	end;
	toVector3 = function(v: Vector2)
		return Vector3.new(v.X,v.Y,0)
	end
},tomt)
module.Vector3 = setmetatable({
	toUDim2 = function(v :Vector3, xScale :number?, yScale :number?)
		return UDim2.new(xScale, v.X, yScale, v.Y)
	end;
	toVector2 = function(v: Vector3)
		return Vector2.new(v.X,v.Y)
	end
},tomt)
module.CFrame = setmetatable({
	toDisplayString = function(cf :CFrame, rounding :number?) --rotation is in deg
		local P = m.fuzz.new3FromVect(cf.Position)
		local R = m.fuzz.new3(cf:ToEulerAnglesXYZ())
		P = P:FuncOp(m.round,rounding)
		R = R:FuncOp(math.deg):FuncOp(m.round,rounding)
		return "P:"..P:__tostring().."\tR:"..R:__tostring()
	end
},tomt)


function module.vector2Directions(origin :Vector2?, destination :Vector2?, UDimLogic :boolean?)
	origin = origin or Vector2.new()
	destination = destination or Vector2.new()
	local dirs = {
		Left = origin.X > destination.X;
		Right = origin.X < destination.X;
		Top = origin.Y < destination.Y;
		Bottom = origin.Y > destination.Y;
	}
	if UDimLogic then
		if dirs.Top then
			dirs.Bottom = true
			dirs.Top = false
		elseif dirs.Bottom then
			dirs.Bottom = false
			dirs.Top = true
		end
	end
	dirs.Up = dirs.Top
	dirs.Down = dirs.Bottom
	return dirs
end


function module.regionRandomPoint(v1 :Vector3, v2 :Vector3)
	return Vector3.new(Rando:NextNumber(v1.X,v2.X),Rando:NextNumber(v1.Y,v2.Y),Rando:NextNumber(v1.Z,v2.Z))
end


---+,+ is top,left. -,- is bottom,right.
---@return boolean isOnScreen
---@return Vector2 correctionNeeded add to offset to correct position
function module.isGuiObjectInScreen(thing :GuiObject, overridePos :Vector2?, overrideSize :Vector2?)
	local screenGui :ScreenGui = thing:FindFirstAncestorWhichIsA("ScreenGui")
	if not screenGui then error("Object needs to be decendant of a ScreenGui",2) end
	local screenSize = screenGui.AbsoluteSize
	local x,y = 0,0
	local topLeft = overridePos or thing.AbsolutePosition
	local bottomRight = topLeft + (overrideSize or thing.AbsoluteSize)
	if topLeft.X < 0 then x = -topLeft.X end
	if topLeft.Y < 0 then y = -topLeft.Y end
	if bottomRight.X > screenSize.X then x = -(bottomRight.X - screenSize.X) end
	if bottomRight.Y > screenSize.Y then y = -(bottomRight.Y - screenSize.Y) end
	return x==0 and y==0, Vector2.new(x,y)
end


function module.waitForChildren(waitTime :number?, parent :Instance, ... :string) :(boolean,string)
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


function module.waitForNested(waitTime :number?, parent :Instance, child :string, ... :string) :Instance?
	if not (parent and child) then return parent end
	return module.waitForNested(waitTime,parent:WaitForChild(child,waitTime),...)
end


-- children are expected to be like: {parent , child} so func(parent,child,{child to become parent, child ,child})
function module.waitForNestedChildren(waitTime :number?, parent :Instance, ... :string) :(boolean,string)
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


function module.hasNested(parent, ...:string) :(boolean,any)
	local good, result = pcall(function(...)
		for _, childName in pairs({...}) do
			parent = parent[childName]
		end
		return parent
	end, ...)
	if type(parent)=="table" and good and result==nil then --tables don't error on nil members so we need to force a no
		return false
	else
		return good, result
	end
end


function module.hasChildren(parent, ...:string) :(boolean,string)
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


--sorted by closest ancestor first
function module.getAncestors(thing :Instance) :Array<Instance>
	local ancestors, parent = {}, thing.Parent
	while parent do
		table.insert(ancestors, parent)
		parent = parent.Parent
	end
	return ancestors
end


function module.getLevelsToAncestor(myThing :Instance, ancestor :Instance) :(number, Array<Instance>)
	assert(myThing:IsDescendantOf(ancestor), myThing:GetFullName().." is not descendant of "..ancestor:GetFullName())
	local ancestors = module.getAncestors(myThing)
	local level = module.tableFlip(ancestors)[ancestor]
	local cutAncestors = {}
	for i=1, level do
		table.insert(cutAncestors, ancestors[i])
	end
	return level, cutAncestors
end


-- a.b.c.d.e.f;  (f,a,1) -> b; (f,a,3) -> d
function module.ascendToChildOfAncestor(myThing :Instance, ancestor :Instance, stopLevelsAwayFromAncestor :number?) :Instance
	if not myThing.Parent then error(myThing:GetFullName() .. " is not descendant of " .. ancestor:GetFullName()) end
	stopLevelsAwayFromAncestor = stopLevelsAwayFromAncestor or 1
	local newLevel = module.getLevelsToAncestor(myThing, ancestor) - stopLevelsAwayFromAncestor
	if newLevel < 1 then
		--requested to stop lower than we already are, (a,b,4) b is 1 away, not 4
		--I'm tempted to raise an error because you prolly didn't intend for this
		--for now, warn and return what we have
		--warn(p,"ascendToChildOfAncestor: requested to stop lower than we already are")
		return myThing
	end
	return module.getAncestors(myThing)[newLevel]
end


-- the idea is to determine basic game objects
-- : Asteroid, Base, Ship
function module.whatIsThis(thing :Instance) :(string?, Instance)
	if thing:IsDescendantOf(workspace.Asteroids) then return "Asteroid",module.ascendToChildOfAncestor(thing,workspace.Asteroids) end
	if thing:IsDescendantOf(workspace.Bases) then return "Base", module.ascendToChildOfAncestor(thing,workspace.Bases,2) end
	if thing:IsDescendantOf(workspace.Ships) then return "Ship", module.ascendToChildOfAncestor(thing,workspace.Ships) end
end


function module.isColliding(thing :Folder|Model)
	local parts :{BasePart} = m.arrayFilter(thing:GetDescendants(),function(t, k, v)
		return v:IsA("BasePart")
	end)
	return workspace:ArePartsTouchingOthers(parts, -0.1)
end


function module.getColliding(thing :Folder|Model) :{BasePart}
	local parts :{BasePart} = m.arrayFilter(thing:GetDescendants(),function(t, k, v)
		return v:IsA("BasePart")
	end)
	local parms = OverlapParams.new()
	parms.FilterType = Enum.RaycastFilterType.Blacklist
	parms.FilterDescendantsInstances = {thing}
	local collisions = {}
	local i = 0
	for _,part in ipairs(parts) do
		task.spawn(function() i+=1
			for _,hit in ipairs(workspace:GetPartsInPart(part,parms)) do
				table.insert(collisions,hit)
			end i-=1
		end)
	end
	while i~=0 do wait() end
	return m.arrayRemoveDupes(collisions)
end


print("MainFrame Loaded")
return module

--End of Line
