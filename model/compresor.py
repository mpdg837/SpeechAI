import math
import os
import numpy as np

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

def decode(file,mono):
    size = 256
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
        ysample[n] = int((float(sampletwice) / float(max)) * (256 * 2))
        n = n + 1

    return ysample
def record():
    chunk = 1  # Record in chunks of 1024 samples
    sample_format = pyaudio.paInt16  # 16 bits per sample
    channels = 1
    fs = 16000  # Record at 44100 samples per second
    seconds = 1.5
    filename = "recorded.wav"

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

record()

