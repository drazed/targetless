-- Vendetta Online targetless Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com
-- CopyRight: CoalitionOfITAN
--
-- The config Dialog

targetless.UIconfig = {}
targetless.UIconfig.element = {}
targetless.UIconfig.element.filtera = iup.list {"Best","Aquean","Silicate","Carbonic","Ferric","Ishik","VanAzek","Xithricite","Lanthanic","Denic","Pyronic","Apicene","Pentric","Heliocene"; dropdown="YES"}
targetless.UIconfig.element.filterb = iup.list {"---","Aquean","Silicate","Carbonic","Ferric","Ishik","VanAzek","Xithricite","Lanthanic","Denic","Pyronic","Apicene","Pentric","Heliocene"; dropdown="YES"}
    
targetless.UIconfig.options = iup.vbox{
	iup.hbox{
		iup.label { title = "Show Ore 1:"},
		targetless.UIconfig.element.filtera,
		iup.fill {},
		gap=5,
	},
	iup.hbox{
		iup.label { title = "Show Ore 2:"},
		targetless.UIconfig.element.filterb,
		iup.fill {},
		gap=5,
	},
	gap=5,
	tabtitle="targetless Roids",
	margin="2x2",
	OnHide=function(self)
		if(targetless.UIconfig.element.filtera.value == "1") then
     		targetless.UIconfig.element.filterb.value = "1"
    	end --if no filter 1 no filter 2 =)
    	gkini.WriteString("targetless","filtera",targetless.UIconfig.element.filtera.value)
    	gkini.WriteString("targetless","filterb",targetless.UIconfig.element.filterb.value)
    	targetless.RoidList:clear()
    	targetless.RoidList:updatesector(GetCurrentSectorid())
    end,
    OnShow=function(self)
    	targetless.UIconfig.element.filtera.value = gkini.ReadString("targetless","filtera","1")
    	targetless.UIconfig.element.filterb.value = gkini.ReadString("targetless","filterb","1")
    end,
    hotkey=iup.K_t,
}

