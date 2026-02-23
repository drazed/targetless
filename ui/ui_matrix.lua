local bg, bg_numbers
bg = {
	[0] = ListColors[0].." "..ListColors.Alpha,
	[1] = ListColors[1].." "..ListColors.Alpha,
	[2] = ListColors[2].." "..ListColors.SelectedAlpha,
}
bg_numbers = ListColors.Numbers

targetless.matrix = {}
function targetless.matrix(funcs)
	local curselindex
	local sort_key = funcs.defsort or 1
	
	local mat = iup.pdasubsubmatrix{
		numcol=#funcs,
		numcol_visible=funcs.numcol_visible or #funcs,
		numlin=0,
		numlin_visible=funcs.numlin_visible or 16,
		expand=funcs.expand or "YES",
		size=funcs.size,
	}
	
	for i, n in ipairs(funcs) do
		mat["0:"..i] = n.name
		mat["ALIGNMENT"..i] = n.alignment or "ALEFT"
		if n.size then mat["WIDTH"..i] = n.size end
	end
	
	local function set_sort_mode(mode)
		sort_key = mode
		for i=1, #funcs do
			mat:setattribute("FGCOLOR", 0, i, mode == i and tabseltextcolor or tabunseltextcolor)
		end
	end
	
	function mat:fgcolor_cb(row, col)
		local colorindex = math.fmod(row,2)
		local c = bg_numbers[colorindex]
		return c[1],c[2],c[3],c[4],iup.DEFAULT
	end
	mat.bgcolor_cb = mat.fgcolor_cb
	
	function mat:leaveitem_cb(row, col)
		local sel = curselindex and curselindex or row
		mat:setattribute("BGCOLOR", sel, -1, bg[math.fmod(sel, 2)])
		curselindex = nil
	end
	
	function mat:enteritem_cb(row, col)
		if curselindex then mat:setattribute("BGCOLOR", curselindex, -1, bg[math.fmod(row, 2)]) end
		curselindex = row
		mat:setattribute("BGCOLOR", row, -1, bg[2])
	end
	
	local function reload_matrix(self)
		local numitems = #funcs.table_sort
		mat.numlin = numitems
		for i,v in ipairs(funcs.table_sort) do
			mat:update_itementry(i, v)
		end
		if numitems > 0 and curselindex then
			if curselindex > numitems then
				curselindex = nil
			else
				local curs = curselindex
				mat:leaveitem_cb(curs, 1)
				mat:enteritem_cb(curs, 1)
			end
		end
	end
	mat.reload = reload_matrix
	
	local function update_matrix(self)
		local sort = funcs[sort_key].fn
		if curselindex then
			local oldsel = funcs.table_sort[curselindex]
			local oldindex = curselindex
			mat:leaveitem_cb(curselindex, 1)
			table.sort(funcs.table_sort, sort)
			for i,v in ipairs(funcs.table_sort) do
				if v == oldsel then mat:enteritem_cb(i, 1) break end
			end
		else table.sort(funcs.table_sort, sort)
		end
		set_sort_mode(sort_key)
		reload_matrix()
	end
	mat.update = update_matrix
	
	function mat:click_cb(row, col)
		if row == 0 then
			set_sort_mode(col)
			update_matrix()
		elseif funcs.onsel then
			funcs.onsel(row, col)
		end
	end
	
	function mat:edition_cb(row, col, mode)
		if funcs.onedit then funcs:onedit(row, col, mode) return iup.IGNORE else return iup.IGNORE end
	end
	
	function mat:update_itementry(i, item)
		for n=1, #funcs do
			self:setcell(i, n, " "..(funcs[n].itementry_fn(item) or ""))
		end
	end
	
	function mat:populate(func)
		curselindex = nil
		self.dellin = "1--1"
		if func then func() end
		update_matrix()
		iup.Refresh(self)
	end
	
	return mat
end
