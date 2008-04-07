-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

targetls.var = {}
targetls.var.timer = Timer()
targetls.var.version = "v1.5.11"
targetls.var.state = true
targetls.var.updatelock = false
targetls.var.targetnum = 0
targetls.var.listpage = "target"

-- config settings
targetls.var.refreshDelay = tonumber(gkini.ReadString("targetls", "refresh", "1500"))
targetls.var.place = gkini.ReadString("targetls", "place", "right")
targetls.var.sortBy = gkini.ReadString("targetls", "sort", "distance")
targetls.var.font = targetls.func.getfont(gkini.ReadString("targetls", "font", "Font.H6"))
targetls.var.showRoid = gkini.ReadString("targetls", "roidtab", "ON")
targetls.var.showtls = gkini.ReadString("targetls", "showtls", "ON")
targetls.var.showself = gkini.ReadString("targetls", "self", "ON")
targetls.var.listmax = tonumber(gkini.ReadString("targetls", "listmax", "10"))
targetls.var.lswidth = tonumber(gkini.ReadString("targetls", "hudwidth", "300"))

-- layout format strings
targetls.var.layout = {}
targetls.var.layout.self = gkini.ReadString("targetls", "selflayout", "{<tab><tab><tab><health><name><fill><lstand>}")
targetls.var.layout.pc = gkini.ReadString("targetls", "pclayout", "{<health><name><fill><istand><sstand><ustand><lstand>}{<distance><ship>}")
targetls.var.layout.npc = gkini.ReadString("targetls", "npclayout", "{<health><name><fill><lstand>}{<distance><ship>}")
targetls.var.layout.roid = gkini.ReadString("targetls", "roidlayout", "{<tab><note><fill><id>}{<tab><ore>}")

-- factions enum
targetls.var.factions = {}
targetls.var.factions[12] = "Ineubis"
targetls.var.factions[6] = "Valent"
targetls.var.factions[99] = "Dev"
targetls.var.factions[1] = "Itani"
targetls.var.factions[3] = "Union"
targetls.var.factions[7] = "Orion"
targetls.var.factions[2] = "Serco"
targetls.var.factions[8] = "Axia"
targetls.var.factions[4] = "TPG"
targetls.var.factions[9] = "Corvus"
targetls.var.factions[0] = "Unaligned"
targetls.var.factions[10] = "Tunguska"
targetls.var.factions[5] = "BioCom"
targetls.var.factions[11] = "Aeolus"
targetls.var.factions[13] = "XangXi"

targetls.var.orecolor = {}
targetls.var.orecolor["Aquean"] = "\127aec6d6"
targetls.var.orecolor["Silicate"] = "\1279c8a5f"
targetls.var.orecolor["Carbonic"] = "\127749281"
targetls.var.orecolor["Ferric"] = "\127a4a39b"
targetls.var.orecolor["Ishik"] = "\12712d7e7"
targetls.var.orecolor["VanAzek"] = "\127dda994"
targetls.var.orecolor["Xithricite"] = "\12716ef25"
targetls.var.orecolor["Lanthanic"] = "\127a320e5"
targetls.var.orecolor["Denic"] = "\12713a2d9"
targetls.var.orecolor["Pyronic"] = "\127e38163"
targetls.var.orecolor["Apicene"] = "\12725578d"
targetls.var.orecolor["Pentric"] = "\127f9f825"
targetls.var.orecolor["Heliocene"] = "\127d73d25"


-- icons
targetls.var.IMAGE_DIR = "plugins/targetLS/images/"
targetls.var.images = 
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

-- list containers
targetls.var.sectortotals = nil
targetls.var.iupself = iup.vbox {}
targetls.var.iupplayers = iup.vbox {}
targetls.var.iuproids = iup.vbox {}
targetls.var.iuptotals = iup.vbox {}
targetls.var.iupspacer1 = iup.label { title="", image=targetls.var.IMAGE_DIR .."health.png", fgcolor = "255 255 255", size= targetls.var.lswidth .."x1"}
targetls.var.iupspacer2 = iup.label { title="", image=targetls.var.IMAGE_DIR .."health.png", fgcolor = "255 255 255", size= targetls.var.lswidth .."x1"}
targetls.var.PlayerData = iup.zbox 
{
    iup.vbox
    {
        iup.fill {size="3"},
        targetls.var.iupself,
        iup.fill {size="3"},
        targetls.var.iupspacer1,
        iup.fill {size="3"},
        targetls.var.iuptotals,
        iup.fill {size="3"},
        targetls.var.iupspacer2,
        iup.fill {size="3"},
        targetls.var.iupplayers,
        targetls.var.iuproids
    }
}

