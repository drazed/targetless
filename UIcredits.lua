-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

targetls.UIcredits = {}
targetls.UIcredits.element = {}
targetls.UIcredits.element.okbutton = iup.stationbutton { title = "OK" }
    
targetls.UIcredits.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "Vendetta Online TargetLS Plugin\n\nAuthor: Adrian (drazed) Zakrzewski\ncontact: drazed@gmail.com\n\ncredits:\n", expand = "HORIZONTAL" },
                iup.fill {},
                iup.label { title = "" .. targetls.var.version }
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Scuba Steve 9.0 and his Pirates Toolkit for providing me with\nwonderful sample code.\n\nBlackNet, Omega0, Eonis, FireMage, Nautargos, Katarn, and a \nbunch of others in IRC land for their l33t lua coding skills.  If \nI missed any of you remind me, I have a terrible memory =9\n\nEveryone that tested my buggy lua code, thanks alot.\n\nAnd thank you VO devs for making this all possible.\nThanks John, Ray, Andy, and Michael =)", expand = "HORIZONTAL" },
                iup.fill { size = "20"}
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetls.UIcredits.element.okbutton,
            }
        }
    }
}

function targetls.UIcredits.element.okbutton:action()
    targetls.UIcredits.dlg:hide()
end

function targetls.UIcredits.open()
    targetls.UIcredits.dlg:show()
    iup.Refresh(targetls.UIcredits.dlg)
end

targetls.UIcredits.dlg = iup.dialog 
{
    targetls.UIcredits.mainbox;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES",
}

