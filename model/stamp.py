import numpy as np
from matplotlib import pyplot as plt

import headers
import scaling
import speech

def decode(file,mono):
    size = headers.sizeFFT
    diff = 0xffffff

    samplerate, data = speech.wavfile.read(file)

    ysample = []

    max = 0
    doubled = False

    for sampletwice in data:

        anal = 0
        if mono:
            anal = np.int32(sampletwice)
        else:
            anal = np.int32(sampletwice)

        # anal = int(anal/32768 * 512)


        ysample.append(anal)
        if np.abs(anal) > max:
            max = np.abs(anal)


    n = 0
    for sampletwice in ysample:
        ysample[n] = int((float(sampletwice) / float(max)) * (128)) *4
        n = n + 1

    return ysample
def selectLoud(ysample):
    yselected = []
    start = 0
    stop = 0

    size = 5120
    detection = 128
    lena = -1


    for k in range(len(ysample)):

        if ysample[k] >= detection or ysample[k] <= - detection:

            if lena == -1:
                start = k - size
            lena = 0

        if lena != -1:
            lena = lena + 1

            if lena >= size:
                stop = k
                lenb = stop - start

                if lenb < 11000:
                    start = 0
                    stop = 0
                    lena = -1
                elif lenb > 18000:
                    start = 0
                    stop =  0
                    lena = -1
                else:
                    stop = k
                    break


    if stop == 0:


        lenb = size - start

        if lenb < 18000 and lenb < 11000:
            end = size - lena
            stop = len(ysample) - 1 + end

            for n in range(end):
                ysample.append(0)

        else:
            stop = 0
            start = 0


    for i in range(stop - start):
        index = start + i
        if index >= 0:
            yselected.append(ysample[index])
        else:
            yselected.append(0)

    return yselected

def tohex(val, nbits):
  return hex((val + (1 << nbits)) % (1 << nbits))

def getStamp(file, mono,mels):

    #plt.title("Recorded fragment")
    ysample = decode(file, mono)
    #xsample = range(len(ysample))

    #plt.plot(xsample, ysample)
    #plt.show()

    #plt.title("Loud fragment")

    yselected = selectLoud(ysample)

    if len(yselected) == 0:
        return None

    #xselected = range(len(yselected))

    #plt.plot(xselected, yselected)
    #plt.show()

    pack = speech.spect(yselected, headers.sizeFFT * 2)

    levels = pack[0]
    spectrogram = pack[1]

    # speech.showSpec(spectrogram,"Selected fragment")

    for n in range(len(pack[0])):
        nline = []

        for k in range(headers.sizeFFT):
            nline.append(spectrogram[n][k])

        for k in range(headers.sizeEnergyLevel):
            nline.append(levels[n][k])


    nspectrogram = scaling.scalex(spectrogram)
    nlevels = scaling.scalexlevels(levels)

    #speech.showSpec(nspectrogram,"Scaled X fragment")

    nspectrogram = scaling.melscale(nspectrogram,mels)

    #speech.showSpec(nspectrogram, "Scaled MEL fragment")

    npack = []
    for n in range(headers.sizeX):
        nline = []

        for k in range(headers.sizeFFT):
            if nspectrogram[n][k] > 255:
                nspectrogram[n][k] = 255

            if nspectrogram[n][k] < 16:
                nspectrogram[n][k] = 0

            nline.append(nspectrogram[n][k])

        for k in range(headers.sizeEnergyLevel):
            nline.append(nlevels[n][k])





        npack.append(nline)


    return npack