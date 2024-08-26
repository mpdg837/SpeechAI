import math
import headers
def countmel():
    max = 0

    mels = []
    out = []
    for n in range(8000):
        m = 2595 * math.log(1+n/700)
        max = m
        mels.append(m)
        # print(" "+str(n)+" Hz "+str(m)+" mel")

    k = 0
    for n in range(headers.sizeFFT):
        val = int(mels[k] / max * (headers.sizeFFT - 1))
        out.append(val)
        # print(str(n) + ") "+ str(val))

        k = k + int(64/headers.sizeFFT * 124)

    return out


if __name__ == "__main__":
    table = countmel()
    n = 0
    lpoint = 0

    sum = 0
    for point in table:
        print("memory["+str(n)+"] = ",end="")
        print(point - lpoint, end = "")
        print(";")

        sum += point - lpoint
        lpoint = point
        n = n + 1

    print(sum)