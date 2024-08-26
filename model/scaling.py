import speech
import headers
def scalexlevels(spectrogram):
    delta = len(spectrogram) / (headers.sizeX)
    ypos = 0

    nspectrogram = []

    for y in range(headers.sizeX):

        min = int(y)
        max = int(y + delta)
        line = []

        for x in range(headers.sizeEnergyLevel):

            maxd = 0

            for yy in range(int(max - min) + 1):

                if int(ypos) + yy >= len(spectrogram):
                    break

                val = spectrogram[int(ypos) + yy][x]
                if maxd < val:
                    maxd = val

            line.append(maxd)
        nspectrogram.append(line)

        ypos = ypos + delta

    return nspectrogram


def scalex(spectrogram):
    delta = len(spectrogram) / (headers.sizeX)
    ypos = 0

    nspectrogram = []
    for y in range(headers.sizeX):

        min = int(y)
        max = int(y + delta)
        line = []

        for x in range(headers.sizeFFT):

            maxd = 0

            for yy in range(int(max - min) + 1):

                if int(ypos) + yy >= len(spectrogram):
                    break

                val = spectrogram[int(ypos) + yy][x]
                if maxd < val:
                    maxd = val

            line.append(maxd)
        nspectrogram.append(line)

        ypos = ypos + delta

    return nspectrogram

def melscale(spectrogram,mels):
    nspectrogram = []
    for y in range(headers.sizeX):
        line = []
        for x in range(headers.sizeFFT):
            line.append(0)
        nspectrogram.append(line)

    y = 0

    for line in spectrogram:

        x = 0
        for point in line:

            xmel = mels[x]

            if x+1 > headers.sizeFFT - 1:
                xmelmax = headers.sizeFFT - 1
            else:
                xmelmax = mels[x+1]

            for xx in range(xmelmax - xmel):
                if point > nspectrogram[y][xmel + xx]:
                    nspectrogram[y][xmel + xx] = point

            x = x + 1
        y = y + 1

    return nspectrogram