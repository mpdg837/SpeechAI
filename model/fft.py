import sounddevice
from scipy.io.wavfile import write
import numpy as np
# for visualizing the data
import matplotlib.pyplot as plt
# for opening the media file
import scipy.io.wavfile as wavfile
import math

from cmath import exp, pi

import speech


def zaz(z1,alfa,z2):
    x1 = z1.real
    x2 = z2.real
    xa = alfa.real

    y1 = z1.imag
    y2 = z2.imag
    ya = alfa.imag

    return (x1 + xa*x2 - ya*y2) + 1j*(y1 + xa*y2 + ya*x2)
def reverse(num,size):
    nummem = num
    retu = 0
    for n in range(size):
        number = (nummem & (1 << n)) >> n
        retu = retu | (number <<  (size - n - 1) )
    return retu

def writeschematic(stage,size,inData,littleSize):
    results = []
    print("")

    for n in range(int(size >> (stage))):

        for k in range(int(littleSize >> 1)):

            wsp = exp(-2j*pi*k/(int(littleSize)))

            re = int(wsp.real * 1000) / 1000
            imag = int(wsp.imag * 1000) / 1000
            wsp = (re + imag * 1j)

            if wsp.real == 0:
                wsp = wsp.imag * 1j

            if wsp.imag == 0:
                wsp = wsp.real

            result = inData[int((n << (stage)) + (littleSize >> 1) + k)] + wsp * inData[int((n << (stage)) + k)]
            results.append(result)

            re = int(result.real * 1000) / 1000
            imag = int(result.imag * 1000) / 1000
            result = -(re + imag * 1j)

            wsp = str(wsp)

            print("r("+str(int(n*littleSize + k))+") = "+str(inData[int(n*littleSize + k)])+"   -> r("+str(int(n*littleSize + littleSize/2 + k))+") + "+wsp+" *r("+str(int(n*littleSize + k))+") = " + str(result))


        for k in range(int(littleSize >> 1)):
            wsp = exp(-2j*pi*k/(int(littleSize)))

            re = int(wsp.real * 1000) / 1000
            imag = int(wsp.imag * 1000) / 1000
            wsp = -(re + imag * 1j)

            if wsp.real == 0:
                wsp = wsp.imag * 1j

            if wsp.imag == 0:
                wsp = wsp.real

            result = inData[int((n << (stage)) + k)] + wsp * inData[int((n << (stage)) + (littleSize >> 1) + k)]

            re = int(result.real * 1000) / 1000
            imag = int(result.imag * 1000) / 1000
            result = -(re + imag * 1j)

            results.append(result)

            wsp = str(wsp)
            if wsp[0] != '-':
                wsp = '+'+wsp

            print("r("+str(int(n*littleSize + littleSize/2 + k))+") = "+str(inData[int(n*littleSize + littleSize/2 + k)])+"     -> r("+str(int(n*littleSize + k))+") "+wsp+" * r("+str(int(n*littleSize + littleSize/2 + k))+") = "+str(result))

    return results

def fft(x):

    N = len(x)

    if N <= 1: return x

    even = fft(x[0::2])
    odd =  fft(x[1::2])

    T= [exp(-2j*pi*k/N)*odd[k] for k in range(N//2)]

    ret = [even[k] + T[k] for k in range(N//2)] + [even[k] - T[k] for k in range(N//2)]

    return ret

if __name__ == "__main__":
    x = []

    for n in range(512):
        el = n
        print(el)
        x.append(el)

    x = speech.hamming(x)
    t = fft(x)
    n = 0
    for el in t:
        print(int(n),end=")")
        print(int(np.abs(el)))
        n = n + 1
