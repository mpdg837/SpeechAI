import math
import os

import pyaudio
import wave

import melScale
import speech
import sounddevice as sd
import wavio as wv
import time

import matplotlib.pyplot as plt

import stamp
import headers

def readSpectrogram(file):
    spect = []
    f = open(file,"rb")

    points = f.read()

    if headers.compress == 2:
        p = 0

        maxrange = int((headers.sizeFFT + headers.sizeEnergyLevel) / 2)
        for y in range(headers.sizeX):
            line = []
            lastval = 0

            for x in range(maxrange):


                if x + 1 < maxrange:
                    nextval = points[p+1]
                else:
                    nextval = points[p]

                val = (points[p] >> 1) << 1
                pos = points[p] & 0x1

                delta1 = val - lastval
                delta2 = nextval - val

                if pos == 0x1:

                    line.append(lastval+ int(delta1/2))
                    line.append(val )
                else:
                    line.append(val)
                    line.append(val + int(delta2 / 2))


                lastval = val

                p = p + 1
            spect.append(line)
    elif headers.compress == 4:
        p = 0

        maxrange = int((headers.sizeFFT + headers.sizeEnergyLevel) / 4)
        for y in range(headers.sizeX):
            line = []
            lastval = 0

            for x in range(maxrange):

                if x+1 < maxrange:
                    nextval = (points[p + 1] >> 1) << 1
                else:
                    nextval = (points[p] >> 1) << 1

                val = (points[p] >> 1) << 1
                pos = val & 0x1

                delta1 = val - lastval
                delta2 = nextval - val

                if pos == 0x1:
                    line.append(lastval + int(delta1 / 2))
                    line.append(lastval + int(delta1 / 2) + int(delta1 / 4)+ int(delta1/8))
                    line.append(lastval + int(delta1 / 2) + int(delta1/4) + int(delta1/8)+ int(delta1/16))
                    line.append(val)
                else:
                    line.append(lastval + int(delta1 / 2))
                    line.append(val)
                    line.append(val + int(delta2 / 16))
                    line.append(val + int(delta2 / 8))


                lastval = val

                p = p + 1
            spect.append(line)

    return spect


def compare(nspectrogram, nnspectrogram):

    delta = 0

    yr = 0
    for y in range(headers.sizeX):
        linedelta = 0

        for x in range(headers.sizeFFT + headers.sizeEnergyLevel):

            val = abs(int(nspectrogram[yr][x]) - int(nnspectrogram[yr][x]))
            linedelta = linedelta + val

        yr = yr + 1
        delta = delta + linedelta


    return delta

def analyse(spects,cmp):

    names = ["up","down","left","right","yes","stop","sheila","go","on","off","marvin","four","happy","cat","tree","house"]

    shorts = []

    for name in names:
        if len(name) < 3:
            idx = name[0] + name[1]
        else:
            idx = name[0] + name[1] + name[2]
        shorts.append(idx)

    resultsid = {}
    results = []

    for key in spects.keys():
        cval = compare(cmp, spects[key])

        resultsid[cval] = key
        results.append(cval)

    results.sort()

    max = ""

    size = len(names)

    print("..",end="")
    print("")
    n = 0
    finalres = {}
    for result in results:
        id = resultsid[result]

        if ord(id[2]) >= ord('0') and ord(id[2]) <= ord('9'):
            idx = id[0] + id[1]
        else:
            idx = id[0] + id[1] + id[2]

        print(str(n)+") "+ idx + " " + str(result))
        if idx in shorts:
            n = n + 1

            points = 8 + 1 - n
            try:
                finalres[idx] = finalres[idx] + points
            except:
                finalres[idx] = points

            if n == 8:
                break

    val = 0
    name = ""

    for keys in finalres.keys():
        print(keys+" "+str(finalres[keys]))

        if val < finalres[keys]:

            for namex in names:
                if len(namex) < 3:
                    if keys == namex[0] + namex[1]:
                        name = namex
                        break
                else:
                    if keys == namex[0] + namex[1]+namex[2]:
                        name = namex
                        break


            val = finalres[keys]

    if val < 15:
        print("Cant detect")
    else:
        print("You said "+name)

def record():
    chunk = 1  # Record in chunks of 1024 samples
    sample_format = pyaudio.paInt16  # 16 bits per sample
    channels = 1
    fs = 16000  # Record at 44100 samples per second
    seconds = 1.5
    filename = "speech.wav"

    p = pyaudio.PyAudio()  # Create an interface to PortAudio

    stream = p.open(format=sample_format,
                    channels=channels,
                    rate=fs,
                    frames_per_buffer=chunk,
                    input=True)

    frames = bytearray()

    buffer = []  # Initialize array to store frames


    for n in range(int(fs * seconds)):
        buffer.append(0)

    margin = fs * 0.75
    mmargin = 0
    edge = 4096*4

    addr = 0

    licz = 0
    delta = 0

    # Store data in chunks for 3 seconds
    while True:
        data = stream.read(chunk)

        lev = int(data[1] << 8) | int(data[0])

        if lev > 32768:
            lev = lev - 65536
        buffer[addr] = lev

        if mmargin == 0:
            if lev > edge or lev < -edge:
                mmargin = 1
        else:
            mmargin = mmargin + 1


        if mmargin >= margin:
            naddr = addr
            for k in range(int(fs*seconds)):

                mlev = buffer[naddr]

                frames.append((mlev) & 0xFF)
                frames.append((mlev >> 8) & 0xFF)

                naddr = naddr + 1

                if naddr == fs*seconds:
                    naddr = 0

            break

        addr = addr + 1

        if addr == fs*seconds :
            addr = 0

    samples = bytearray(frames)
    # Stop and close the stream
    stream.stop_stream()
    stream.close()
    # Terminate the PortAudio interface
    p.terminate()

    print('..',end="")

    # Save the recorded data as a WAV file
    wf = wave.open(filename, 'wb')
    wf.setnchannels(channels)
    wf.setsampwidth(p.get_sample_size(sample_format))
    wf.setframerate(fs)
    wf.writeframes(samples)
    wf.close()

if __name__ == "__main__":


    print("loading...")
    files = os.listdir("trained")

    spects = {}


    for file in files:
        spects[file] = readSpectrogram("./trained/" + file)

    mel = melScale.countmel()
    print("Speak!:")
    while True:
        record()
        print("..",end="")
        cmp = stamp.getStamp("./speech.wav",False,mel)

        speech.showSpec(cmp,"./speech.png")

        print("..",end="")
        start = int(round(time.time() * 1000))
        analyse(spects,cmp)
        stop = int(round(time.time() * 1000))
        print("Duration: "+str(stop - start) + " ms")
