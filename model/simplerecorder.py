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

import headers
import scaling
import speech
import stamp
import headers

def tohex(val, nbits):
  return hex((val + (1 << nbits)) % (1 << nbits))
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


        stra = tohex(lev, 16)
        straa = ""

        for n in range(len(stra) - 2):
            straa = straa + stra[n + 2]

        straaa = ""
        for n in range(4 - len(straa)):
            straaa += "0"

        straaa += straa

        print(straaa, end="")

    samples = bytearray(frames)
    # Stop and close the stream
    stream.stop_stream()
    stream.close()
    # Terminate the PortAudio interface
    p.terminate()

record()