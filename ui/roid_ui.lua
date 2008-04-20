declare("roiddb", {})

roiddb.sector_table = {}

targetless.ui.ore = {}

local plot = gkini.ReadString("targetless", "roid_clickplot", "ON")

local function sysplural(n)
	if not n then return "no route" end
	return n == 1 and "1 system" or n.." systems"
end

roiddb.sectorsort = {
	[1] = {
		name = "Sector",
		fn = function(a,b) return ShortLocationStr(a.sector) < ShortLocationStr(b.sector) end,
		itementry_fn = function(s) return ShortLocationStr(s.sector) end,
	},
	[2] = {
		name = "Scanned Roids",
		fn = function(a,b)
			if a.num ~= b.num then
				return a.num > b.num
			else
				return ShortLocationStr(a.sector) < ShortLocationStr(b.sector)
			end
		end,
		itementry_fn = function(s) return s.num end,
	},
	[3] = {
		name = "Distance",
		fn = function(a,b)
			local adist, bdist = targetless.ui.getdist(a.sector, b.sector)
			if adist ~= bdist then
				return adist < bdist
			else
				return ShortLocationStr(a.sector) < ShortLocationStr(b.sector)
			end
		end,
		itementry_fn = function(s) return sysplural(targetless.ui.getdist(s.sector)) end,
	},
	table_sort = {},
	table_system = {},
	onedit=function(self, row, col, mode)
		if plot == "ON" and mode == 1 and self.table_sort[row] then
			local sector = self.table_sort[row].sector
			NavRoute.SetFullRoute{sector}
			targetless.ui.logintext.title = "NavRoute set to ".. ShortLocationStr(sector)
			FadeControl(targetless.ui.logintext, 5, 4, 0)
		end
	end,
}

local systems = {}
for i=1, #SystemNames do systems[i] = " "..SystemNames[i] end
table.sort(systems)

targetless.ui.ore.systemlist = iup.stationhighopacitysublist{" All Systems", dropdown="YES", visible_items="15", value=1,
	action=function(self, s, i, v)
		if roiddb.sectorsort.table_system[1] then
			local selsys
			if s ~= " All Systems" then selsys = SystemNames[s:lower():match(" (%w+)")] else selsys = false end
			targetless.ui.ore.sectormat:populate(function()
				roiddb.sectorsort.table_sort = {}
				for i,v in ipairs(roiddb.sectorsort.table_system) do
					if selsys then
						if selsys == GetSystemID(v.sector) then roiddb.sectorsort.table_sort[#roiddb.sectorsort.table_sort+1] = v end
					else
						roiddb.sectorsort.table_sort[#roiddb.sectorsort.table_sort+1] = v
					end
				end
			end)
		end
	end
}
for i=1, #systems do targetless.ui.ore.systemlist[i+1] = systems[i] end

targetless.ui.ore.searchtext = iup.text{expand="HORIZONTAL", action=function(self, k, v)
	targetless.ui.ore.go.active = #v > 0 and "YES" or "NO"
	if k == 13 and #v > 0 then targetless.ui.ore.go:action() end
end}

targetless.ui.ore.go = iup.stationbutton{title="Search", active="NO", size=75,
	action=function(self)
		local rtype = targetless.ui.ore.searchtext.value
		targetless.ui.ore.searchtext.value = ""
		self.active = "NO"
		roiddb.sector_table = {}
		roiddb.sectorsort.table_sort = {}
		roiddb.sectorsort.table_system = {}
		targetless.findsectors(rtype)
	end,
}

targetless.ui.ore.clear = iup.stationbutton{title="Clear", active="NO", size=75,
	action=function(self)
		targetless.ui.ore.sectormat:populate(function()
			roiddb.sector_table = {}
			roiddb.sectorsort.table_sort = {}
			roiddb.sectorsort.table_system = {}
			targetless.ui.ore.clear.active = "NO"
		end)
	end,
}

targetless.ui.ore.sectormat = targetless.ui.matrix(roiddb.sectorsort)

targetless.ui.ore.clickplot = iup.stationtoggle{value=plot, title="Automatically set navroute when you double-click on a sector"}

targetless.ui.ore.main = iup.vbox{
	iup.hbox{iup.label{title="Roid Type:"}, targetless.ui.ore.searchtext, targetless.ui.ore.systemlist, targetless.ui.ore.go, targetless.ui.ore.clear, gap=5, alignment="ACENTER"},
	targetless.ui.ore.sectormat,
	gap=5,
	tabtitle="Scanned Ore",
	margin="2x2",
	alignment="ACENTER",
	OnShow=function(self)
		targetless.ui.ore.sectormat:update()
	end,
	OnHide=function(self) end,
	hotkey=iup.K_o,
}

targetless.ui.ore.options = iup.vbox{
	targetless.ui.ore.clickplot,
	gap=5,
	alignment="ALEFT",
	hotkey=iup.K_o,
	tabtitle="Scanned Ore",
	margin="2x2",
	OnShow=function(self)
		plot = gkini.ReadString("targetless", "roid_clickplot", "ON")
		targetless.ui.ore.clickplot.value = plot
	end,
	OnHide=function(self)
		plot = targetless.ui.ore.clickplot.value
		gkini.WriteString("targetless", "roid_clickplot", plot)
	end,
}
