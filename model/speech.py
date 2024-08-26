import sounddevice
from scipy.io.wavfile import write
import numpy as np
# for visualizing the data
import matplotlib.pyplot as plt
# for opening the media file
import scipy.io.wavfile as wavfile
import math

from cmath import exp, pi

import numpy as np
import matplotlib
import matplotlib as mpl
import matplotlib.pyplot as plt

import fft

import headers

def findminmax(F):
    max = 0
    min = 0xFFFFFFFF

    for sample in F:

        val = int(sample.real) + 1j * int(sample.imag)
        val = int(np.abs(val))

        if max < val:

            max = val
            if max > 32767:
                max = 32767

        if min > val:
            min = val

            if min < -32767:
                min = -32767

    return min,max

def normalize(F,min,max):
    Fa = []

    mina = min
    maxa = max

    for sample in F:
        samplex = int(sample.real) +1j * int(sample.imag)
        samplex = np.abs(samplex)
        samplex = int(samplex)
        Fa.append(samplex)


    FaN = []

    pow = 65535

    for n in range(int(len(Fa) / 2) + 1):

        if n == 0:
            Fa.append(0)
        else:
            if Fa[n] == 0:
                FaN.append(0)
            else:

                if int(Fa[n]) > 32767 :
                    Fa[n] = 32767
                elif int(Fa[n]) < -32767:
                    Fa[n] = -32767

                val = int(math.sqrt((Fa[n]-mina)/(maxa-mina) * pow))
                FaN.append(val)

    return FaN

def showSpec(spectrogram,filename):

    fig, ax = plt.subplots()
    im = ax.imshow(np.rot90(spectrogram, k=1, axes=(1, 0)))

    ax.set_title("Spectrogram: "+filename)
    plt.show(block=True)
    plt.interactive(False)

def hamming(ysamlpes):

    nysamples = []

    N = len(ysamlpes)
    for n in range(N):
        wsp = (0.53836 - 0.46164 *math.cos(
            (2*math.pi*n)/(N-1)))
        nysamples.append(wsp * ysamlpes[n])

    return nysamples

def spect(normalizedSamples,size):

    energyLevels = []
    toFFT = []
    packetFFT = []

    n = 0
    k = 0

    lastValue = normalizedSamples[0]
    
    ZCR = 0
    maxZCR = 0
    
    for sample in normalizedSamples:

        packetFFT.append(sample)

        value = sample
        if value < 0 and lastValue > 0:
            ZCR = ZCR + 1

        if value > 0 and lastValue < 0:
            ZCR = ZCR + 1

        n = n + 1
        if n == size:
            toFFT.append(hamming(packetFFT))


            n = 0
            k = k + 1
            packetFFT = []

            lline = []
            for number in range(headers.sizeEnergyLevel):
                lline.append(ZCR)

            energyLevels.append(lline)

            ZCR = 0
        lastValue = value

    mfft = []

    min = 0xFFFFFFF
    max = 0

    for packet in toFFT:
        F = fft.fft(packet)

        lmin,lmax = findminmax(F)
        mfft.append(F)

        if min > lmin:
            min = lmin

        if max < lmax:
            max = lmax

    spectrogram = []
    for packet in mfft:
        spectrogram.append(normalize(packet,min,max))

    return [energyLevels,spectrogram]



def getSamples(data):


    return normalizeSamples(data,False,False)

def normalizeSamples(data,mono,norm):
    normalizedSamples = []


    min = 0xFFFFFFFFF
    max = 0

    n = 0

    nax = 0

    for sample in data:



        if n > 35000:
            if mono:
                normalizedSamples.append(sample)
                if min > sample:
                    min = sample

                if max < sample:
                    max = sample
            else:
                normalizedSamples.append(sample[0])
                if min > sample[0]:
                    min = sample[0]

                if max < sample[0]:
                    max = sample[0]
            nax = nax + 1

        n=n+1



    return normalizedSamples
