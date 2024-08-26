import os

import headers

size = 1024 * 20

data = []

f = open("./trained/up2.bin", "rb")

down = f.read()

line = 0
for element in down:

    strhex = hex(element)
    mstrhex = 0

    if len(strhex) == 3:
        strhex = '0' + strhex[2]
    else:
        strhex = strhex[2] + strhex[3]

    print(strhex,end="");
    line +=1

    if line == 32:
        line = 0;

print("\n")

dirs = os.listdir("./trained")

for n in range(256):
    filename = "./trained/down"+str(n)+".bin"

    f = open("./trained/up2.bin", "rb")
    f1 = open(filename,"rb")

    points = f.read()
    cpoints = f1.read()

    sum = 0
    addr = 0

    line = 0
    for y in range(size):
        line +=1


        addr = addr  + 1

        if line == 32:
            line = 0

    line = 0
    block = 0
    addr = 0
    for y in range(size):

        line += 1
        block += 1
        addr = addr + 1


        if line == 16:
            line = 0
            if block == 512:
                block = 0

    addr = 0
    line = 0
    block = 0
    for y in range(size):

        diff = abs(cpoints[addr] - points[addr])

        sum += diff
        line +=1
        block += 1
        addr = addr  + 1

        if line == 16:
            line = 0

            if block == 512:
                block = 0

    data.append(sum)

data.sort()

n = 0

for element in data:
    print(element)
    n +=1
    if n == 8:
        break