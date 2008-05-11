-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

targetless.var = {}
targetless.var.timer = Timer()
targetless.var.version = "1.6.a1"
targetless.var.state = true
targetless.var.updatelock = false
targetless.var.targetnum = 0
targetless.var.listpage = "target"
targetless.var.trim = math.floor((gkinterface.GetXResolution()/4 - 75)/10)/FontScale

function targetless.var.getfont(fontstr)
    if fontstr == "Font.H5" then
        return Font.H5
    elseif fontstr == "Font.H6" then
        return Font.H6
    else
        return Font.Tiny
    end
end

-- config settings
targetless.var.refreshDelay = tonumber(gkini.ReadString("targetless", "refresh", "1500"))
targetless.var.place = gkini.ReadString("targetless", "place", "right")
targetless.var.sortBy = gkini.ReadString("targetless", "sort", "distance")
targetless.var.font = targetless.var.getfont(gkini.ReadString("targetless", "font", "Font.H6"))
targetless.var.showRoid = gkini.ReadString("targetless", "roidtab", "ON")
targetless.var.showtls = gkini.ReadString("targetless", "showtls", "ON")
targetless.var.showself = gkini.ReadString("targetless", "self", "ON")
targetless.var.listmax = tonumber(gkini.ReadString("targetless", "listmax", "10"))
targetless.var.lswidth = tonumber(gkini.ReadString("targetless", "hudwidth", "300"))

-- layout format strings
targetless.var.layout = {}
targetless.var.layout.self = gkini.ReadString("targetless", "selflayout", "{<tab><tab><tab><health><name><fill><lstand>}")
targetless.var.layout.pc = gkini.ReadString("targetless", "pclayout", "{<health><name><fill><istand><sstand><ustand><lstand>}{<distance><ship>}")
targetless.var.layout.npc = gkini.ReadString("targetless", "npclayout", "{<health><name><fill><lstand>}{<distance><ship>}")
targetless.var.layout.roid = gkini.ReadString("targetless", "roidlayout", "{<tab><note><fill><id>}{<tab><ore>}")

-- factions enum
targetless.var.factions = {}
targetless.var.factions[12] = "Ineubis"
targetless.var.factions[6] = "Valent"
targetless.var.factions[99] = "Dev"
targetless.var.factions[1] = "Itani"
targetless.var.factions[3] = "Union"
targetless.var.factions[7] = "Orion"
targetless.var.factions[2] = "Serco"
targetless.var.factions[8] = "Axia"
targetless.var.factions[4] = "TPG"
targetless.var.factions[9] = "Corvus"
targetless.var.factions[0] = "Unaligned"
targetless.var.factions[10] = "Tunguska"
targetless.var.factions[5] = "BioCom"
targetless.var.factions[11] = "Aeolus"
targetless.var.factions[13] = "XangXi"

targetless.var.orecolor = {}
targetless.var.orecolor["Aquean"] = "\127aec6d6Aq\127o"
targetless.var.orecolor["Silicate"] = "\1279c8a5fSi\127o"
targetless.var.orecolor["Carbonic"] = "\127749281Ca\127o"
targetless.var.orecolor["Ferric"] = "\127a4a39bFe\127o"
targetless.var.orecolor["Ishik"] = "\12712d7e7Is\127o"
targetless.var.orecolor["VanAzek"] = "\127dda994Va\127o"
targetless.var.orecolor["Xithricite"] = "\12716ef25Xi\127o"
targetless.var.orecolor["Lanthanic"] = "\127a320e5La\127o"
targetless.var.orecolor["Denic"] = "\12713a2d9De\127o"
targetless.var.orecolor["Pyronic"] = "\127e38163Py\127o"
targetless.var.orecolor["Apicene"] = "\12725578dAp\127o"
targetless.var.orecolor["Pentric"] = "\127f9f825Pe\127o"
targetless.var.orecolor["Heliocene"] = "\127d73d25He\127o"


-- icons
targetless.var.IMAGE_DIR = "plugins/targetless/images/"
targetless.var.images = 
{
    iup.LoadImage("POS.png"),
    iup.LoadImage("admire.png"),
    iup.LoadImage("respect.png"),
    iup.LoadImage("neutral.png"),
    iup.LoadImage("dislike.png"),
    iup.LoadImage("hate.png"),
    iup.LoadImage("KOS.png"),
    iup.LoadImage("health.png")
}

