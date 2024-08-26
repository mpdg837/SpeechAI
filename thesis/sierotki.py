f = open("./tex/1-wstep.tex","r", encoding="utf-8")
fw = open("./1-wstep.tex","w", encoding="utf-8")

for line in f:


    ciag = line.replace(" i ", " i~")
    ciag = ciag.replace(" o ", " o~")
    ciag = ciag.replace(" u ", " u~")
    ciag = ciag.replace(" w ", " w~")
    ciag = ciag.replace(" z ", " z~")
    ciag = ciag.replace(" a ", " a~")


    ciag = ciag.replace(" I ", " I~")
    ciag = ciag.replace(" O ", " O~")
    ciag = ciag.replace(" U ", " U~")
    ciag = ciag.replace(" W ", " W~")
    ciag = ciag.replace(" Z ", " Z~")
    ciag = ciag.replace(" A ", " A~")

    fw.write(ciag)