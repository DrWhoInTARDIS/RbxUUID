local m = {}
function m.NewFreeTimer(name :string|number)
	local timer = {
		Name = name;
		StartTime = 0;
		StopTime = 0;
	}
	function timer:Start()
		print("Starting Timer:", self.Name)
		self.StartTime = os.clock()
		return self
	end
	function timer:Stop()
		timer.StopTime = os.clock()
		timer:Print()
		return self
	end
	function timer:ElapsedTime() :number
		return (if timer.StopTime~=0 then timer.StopTime else os.clock()) - timer.StartTime
	end
	function timer:Print()
		print("Timer",self.Name..":", self:ElapsedTime(), "secs")
		return self
	end

	return timer
end


export type timer = typeof(m.NewFreeTimer(""))
export type Array<T> = {[number] :T}


function m.NewBench(name :string)
	local timers :Array<timer> = {}
	local bench = {
		Timers = timers;
		Name = name;
		CurrentTimer = m.NewFreeTimer("");
	}

	function bench:NewTimer(timerName)
		local timer = m.NewFreeTimer(timerName or #self.Timers+1)
		table.insert(self.Timers, timer)
		self.CurretTimer = timer
		return timer
	end

	function bench:StopCurrentTimer()
		self.CurretTimer:Stop()
	end

	function bench:DeleteTimers()
		self.Timers = {}
	end

	function bench:Results()
		print(self.Name,"Benchmark Results:")
		for _,timer in pairs(self.Timers) do
			timer:Print()
		end
	end

	return bench
end

return m



--[[
local function newTimer()

	local timer = {}
	setmetatable(timer,{ __index = function(t,k) 
			for _,v in ipairs(t) do 
				if v[1]==k then return v end end end })

	function timer:print(n) 
		if self[n] then
			print(self[n][1]..":",self[n][2],"secs")
		else
			warn("No timer for:",n)
		end
	end
	function timer:results()
		print("Results:")
		for k,v in ipairs(self) do 
			print(v[1]..":",v[2],"secs")
		end
	end 
	function timer:start(n)
		wait()
		n = n or #self+1
		print("Starting timer:",n)
		self[#self +1] = {n,os.clock()} 
	end
	function timer:stop() 
		self[#self][2] = os.clock() - self[#self][2]
		self:print(#self)
		wait()
	end
	return timer
end

return {new = newTimer}
]]