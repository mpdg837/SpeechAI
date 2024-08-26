import math
import os

import melScale
import speech
import stamp
import headers

sd1 = bytearray()
sd2 = bytearray()
sd3 = bytearray()
sd4 = bytearray()
def analyseFolder(folder,name,mels):

    lista = os.listdir(folder)

    n = 0
    k = 0

    localspect = []
    fullspect = []

    for x in range(headers.sizeX):
        line = []
        line1 = []
        for y in range(headers.sizeFFT + headers.sizeEnergyLevel):
            line.append(0)
            line1.append(0)
        localspect.append(line)
        fullspect.append(line1)

    print("Folder "+folder+" : ",end="")

    lista.sort()
    p = 0
    fil = 0
    for file in lista:

        fil = fil + 1

        if fil == 1:
            fil = 0
            spect = stamp.getStamp(folder + file, True,mels)

            if spect != None:
                k = k + 1
                p = p + 1

                for y in range(headers.sizeX):
                    for x in range(headers.sizeFFT+ headers.sizeEnergyLevel):
                        localspect[y][x] = localspect[y][x] + spect[y][x]

                if k == 1:
                    print("+", end="")
                    for y in range(headers.sizeX):
                        for x in range(headers.sizeFFT + headers.sizeEnergyLevel ):

                            if localspect[y][x] > 255:
                                localspect[y][x] = 255

                            localspect[y][x] = int(localspect[y][x])
                            fullspect[y][x] = fullspect[y][x] + localspect[y][x]

                    save(name+str(n)+".bin",localspect,p)

                    if p == 4:
                        p = 0

                    k = 0
                    for x in range(headers.sizeX):
                        for y in range(headers.sizeFFT + headers.sizeEnergyLevel):
                            localspect[x][y] = 0

                n = n + 1

                if n == headers.packSize:


                    for y in range(headers.sizeX):
                        for x in range(headers.sizeFFT + headers.sizeEnergyLevel):
                            fullspect[y][x] = int(fullspect[y][x] / (headers.sizeFFT))



                    print("")
                    return fullspect


def save(toFile,spect,tier):

    f = open(toFile,"wb")

    mem = bytearray()

    count = 0

    if headers.compress == 2:
        for y in range(headers.sizeX):
            k = 0
            maxval = 0
            pos = 0

            for x in range(headers.sizeFFT + headers.sizeEnergyLevel):

                k = k + 1

                val = int(spect[y][x])

                if val > 255:
                    val = 255


                if val > maxval:
                    maxval = val
                    pos = k

                if k == 2:

                    maxval = (maxval >> 1) << 1

                    if pos == 2:
                        maxval |= 0x1

                    mem.append(maxval)

                    if tier == 1:
                        sd1.append(maxval)

                    if tier == 2:
                        sd2.append(maxval)

                    if tier == 3:
                        sd3.append(maxval)

                    if tier == 4:
                        sd4.append(maxval)

                    k = 0
                    maxval = 0
                    count = count + 1
    elif headers.compress == 4:
        for y in range(headers.sizeX):
            k = 0

            sval = 0
            maxval = 0
            pos = 0

            for x in range(headers.sizeFFT + headers.sizeEnergyLevel):

                k = k + 1

                val = int(spect[y][x])

                if val > 255:
                    val = 255

                if val > maxval:
                    maxval = val
                    pos = k

                sval += val

                if k == 4:
                    sval = maxval
                    sval = (sval >> 1) << 1

                    if pos == 3 or pos == 4:
                        sval |= 0x1

                    mem.append(sval)

                    if tier == 1:
                        sd1.append(sval)

                    if tier == 2:
                        sd2.append(sval)

                    if tier == 3:
                        sd3.append(sval)

                    if tier == 4:
                        sd4.append(sval)

                    sval = 0
                    k = 0
                    maxval = 0
                    count = count + 1

    f.write(mem)

def trainme(pack,out):

    global sd1
    global sd2
    global sd3
    global sd4

    sd1 = bytearray()
    sd2 = bytearray()
    sd3 = bytearray()
    sd4 = bytearray()

    mels = melScale.countmel()
    spects = {}





    if pack == 1:
        spects["yes"] = analyseFolder("./mini_speech_commands/yes/", "trained/yes", mels)
        spects["stop"] = analyseFolder("./mini_speech_commands/stop/", "trained/stop", mels)
        spects["down"] = analyseFolder("./mini_speech_commands/down/","trained/down",mels)
        spects["up"] = analyseFolder("./mini_speech_commands/up/", "trained/up",mels)
        spects["left"] = analyseFolder("./mini_speech_commands/left/", "trained/left",mels)
        spects["right"] = analyseFolder("./mini_speech_commands/right/", "trained/right",mels)
        spects["go"] = analyseFolder("./mini_speech_commands/go/", "trained/go", mels) # 1
        spects["sheila"] = analyseFolder("./mini_speech_commands/sheila/", "trained/sheila", mels) # 1

    if pack == 2:
        spects["on"] = analyseFolder("./mini_speech_commands/on/", "trained/on", mels)  # 1
        spects["off"] = analyseFolder("./mini_speech_commands/off/", "trained/off", mels)  # 1
        spects["marvin"] = analyseFolder("./mini_speech_commands/marvin/", "trained/marvin", mels)  # 1
        spects["four"] = analyseFolder("./mini_speech_commands/four/", "trained/four", mels)  # 1
        spects["happy"] = analyseFolder("./mini_speech_commands/happy/", "trained/happy", mels)  # 1
        spects["cat"] = analyseFolder("./mini_speech_commands/cat/", "trained/cat", mels)  # 1
        spects["tree"] = analyseFolder("./mini_speech_commands/tree/", "trained/tree", mels)  #
        spects["house"] = analyseFolder("./mini_speech_commands/house/", "trained/house", mels)  # 1

    for name1 in spects.keys():
        print("Diffrences "+name1+" ",end="")
        diffspect = []
        normalspect = spects[name1]

        finalspect = []

        for x in range(headers.sizeX):
            line = []
            line1 = []

            for y in range(headers.sizeFFT+ headers.sizeEnergyLevel):
                line.append(0)
                line1.append(0)

            diffspect.append(line)
            finalspect.append(line1)

        for name2 in spects.keys():
            print("+",end="")
            if name1 != name2:

                nspect = spects[name2]

                for y in range(headers.sizeX):
                    for x in range(headers.sizeFFT+ headers.sizeEnergyLevel):
                        diffspect[y][x] = diffspect[y][x] + nspect[y][x]/((len(spects) - 1))

        max = 0
        min = 255

        sum = 0
        for y in range(headers.sizeX):
            for x in range(headers.sizeFFT + headers.sizeEnergyLevel):
                finalspect[y][x] = int(normalspect[y][x] - diffspect[y][x])

                if finalspect[y][x] < 0:
                    finalspect[y][x] = 0

                sum = sum + finalspect[y][x]

        wsk = int((255*255) * headers.sizeFFT/64)
        for y in range(headers.sizeX):
            for x in range(headers.sizeFFT + headers.sizeEnergyLevel):
                finalspect[y][x] = (int)((finalspect[y][x] / sum)*wsk)


        print("")
        speech.showSpec(finalspect,name1)

    f = open(out+"sd1.bin", "wb")
    f.write(sd1)
    f.close()

    f = open(out+"sd2.bin", "wb")
    f.write(sd2)
    f.close()

    f = open(out+"sd3.bin", "wb")
    f.write(sd3)
    f.close()

    f = open(out+"sd4.bin", "wb")
    f.write(sd4)
    f.close()

if __name__ == "__main__":

    files = os.listdir("./trained/")

    for file in files:
        path = "./trained/"
        os.remove(path + file)

    trainme(1,"./tier1/")
    trainme(2, "./tier2/")