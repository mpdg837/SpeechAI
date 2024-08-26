import pyaudio
from scipy.io import wavfile
import numpy as np
import sounddevice as sd
import math
import fft
def convert(name):
    samplerate, data = wavfile.read('./SpeechT/'+name+".wav")

    f = open("./basicbin/"+name+".bin", "wb")
    bytes = bytearray()


    value = len(data)

    normalized = []
    max = 0
    min = 0x3FFFFFFF

    for sample in data:

        abss = abs(sample)

        if max < abss:
            max = abss

        if min > abss:
            min = abss

    size = 0
    lensize = 0

    for sample in data:
        sam = int((sample / max) * 32767)
        normalized.append(sam)

        size +=1

        if size == 4096:
            lensize += 1
            size = 0

    while True:

        if size >= 8192:
            lensize += 1
            break
        else:
            size +=1
            normalized.append(0)

    print(name + " size: "+str(lensize))

    for sample in normalized:

        value = sample

        byte1 = (value >> 8) & 0xFF
        byte2 = (value) & 0xFF


        bytes.append(byte2)
        bytes.append(byte1)


    f.write(bytes)
    f.close()

convert("Yes")
convert("Sorry")
convert("Nodetect")
convert("Hello")
convert("Repeat")
convert("Ok")

names = ["yes","stop","down","up","left","right","go","sheila","on","off","marvin","four","happy","cat","tree","house"]

for name in names:
    convert("s" + name)

