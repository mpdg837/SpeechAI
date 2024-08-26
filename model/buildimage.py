import os


def writeBase64(string,size):

    chars = []
    mbyte = bytearray()

    index = 0
    for charsa in string:
        orda = ord(charsa)
        chara = 10 + 26 + 26 + 1

        if orda >= ord('0') and orda <= ord('9'):
            chara = orda - ord('0')

        if orda >= ord('A') and orda <= ord('Z'):
            chara = orda - ord('A') + 10

        if orda >= ord('a') and orda <= ord('z'):
            chara = orda - ord('a') + 10 + 26

        if orda == ord(' '):
            chara = 10+26+26

        chars.append(chara)
        index += 1
        if index == 4:
            index = 0

    for n in range(size - len(string) - 1):
        chars.append(10 + 26 + 26 + 1)
        index += 1
        if index == 4:
            index = 0


    while index < 4:
        chars.append(10 + 26 + 26 + 1)
        index += 1

    buffer = 0x0
    index = 0

    for charsa in chars:

        buffer = (buffer << 6) | (charsa)
        index += 1

        if index == 4:

            mbyte.append((buffer >> 16) & 0xFF)
            mbyte.append((buffer >> 8) & 0xFF)
            mbyte.append((buffer) & 0xFF)

            buffer = 0
            index = 0

    return mbyte

def tobytefrom64(orda):
    if orda >= 0 and orda <= 9:
        return chr(orda + ord('0'))

    if orda >= 10 and orda <= 10 + 25:
        return chr(orda - 10 + ord('A'))

    if orda >= 10 + 26 and orda <= 10 + 26 + 25:
        return  chr(orda - 10 - 26 + ord('a'))

    if orda == 10 + 26 + 26:
        return ' '

    return ''


def bit_not(n, numbits=8):
    return (1 << numbits) - 1 - n

def readBase64(bytes):
    string = ""
    buffer = 0x0

    index = 0
    for charsa in bytes:

        buffer = (buffer << 8) | (charsa)

        index += 1
        while index == 3:

            for n in range(4):
                chara = tobytefrom64((buffer >> ((3 - n) * 6) & 0x3f))
                if chara != '':
                    string += chara
                else:
                    break

            buffer = 0
            index = 0

    return string

version = 1
subversion = 0

appversion = 1
appsubversion = 0

baseversion = 1

content = bytearray()

names = os.listdir("./basicbin")
sector_addr = 1

sizes = []
files = []
addrs = []

for name in names:


    nname = ""

    for chara in name:
        if chara == '.':
            break

        nname += chara

    files.append(nname)

    ox = open("./basicbin/"+name,"rb")
    data = ox.read()
    ox.close()

    sum = 512 * 16
    licz = 0
    sectors = 0

    start = sector_addr
    for znak in data:
        content.append(znak)
        licz += 1

        if licz == sum:
            licz = 0
            sectors += 1
            sector_addr += 1

    while licz < sum:
        content.append(0x0)
        licz += 1

    sectors += 1
    sector_addr += 1

    sizes.append(sectors)
    addrs.append(start)

while sector_addr % 16 != 0:
    for n in range(512*16):
        content.append(0x0)

    sector_addr += 1

files.append("Base")
addrs.append(sector_addr)
sizes.append(0)

for n in range(len(files)):
    print("file: "+files[n]+" addr: " +str(addrs[n])+ " sec:" + str(sizes[n]))



fs = bytearray()

fs.append(ord("A"))
fs.append(ord("I"))
fs.append(ord("F"))
fs.append(ord("S"))

byte = (version << 4) | subversion
fs.append(byte)


data = writeBase64("SpeechFiles", 32)

for byte in data:
    fs.append(byte)

for n in range(len(files)):
    fs.append(ord('F'))

    data = writeBase64(files[n], 16)

    for byte in data:
        fs.append(byte)

    fs.append((addrs[n] >> 8)& 0xFF)
    fs.append((addrs[n]) & 0xFF)

    fs.append((sizes[n] >> 8)& 0xFF)
    fs.append((sizes[n]) & 0xFF)

fs.append(ord('E'))


while len(fs) < 511 :
    fs.append(0x0)

csum = 0
for chara in fs:

    for n in range(8):
        index = 7 - n

        bit = (chara >> index) & 0x1
        csum += bit

csum &= 0xFF

csum = bit_not(csum)
print("sum:" + hex(csum))

fs.append(csum)

while len(fs) < 512 * 16 :
    fs.append(0x0)


print("----")
for k in range(4):

    bytesa = bytearray()
    bytesa.append(ord("A"))
    bytesa.append(ord("I"))
    bytesa.append(ord("D"))
    bytesa.append(ord("B"))

    byte = (version << 4) | subversion
    bytesa.append(byte)

    bytesa.append(0x0)
    bytesa.append(0xAA)
    bytesa.append(0xBB)
    # App
    data = writeBase64("SpeechAI", 16)

    for byte in data:
        bytesa.append(byte)

    byte = (appversion << 4) | appsubversion
    bytesa.append(byte)
    # vendor
    data = writeBase64("Politechnika Warsz", 32)

    for byte in data:
        bytesa.append(byte)

    # Database name
    data = writeBase64("Speech", 32)

    for byte in data:
        bytesa.append(byte)

    bytesa.append(baseversion)

    addrs = [1,65]
    crcs = [0x55fb764,0xb064c06e]
    for n in range(2):
        bytesa.append(ord('B'))
        data = writeBase64("tier"+str(n), 16)

        for byte in data:
            bytesa.append(byte)

        addr = addrs[n]

        bytesa.append((addr >> 8)& 0xFF)
        bytesa.append((addr) & 0xFF)

        crc = crcs[n]

        bytesa.append((crc >> 24) & 0xFF)
        bytesa.append((crc >> 16) & 0xFF)
        bytesa.append((crc >> 8)& 0xFF)
        bytesa.append((crc) & 0xFF)

        packetsize = 64

        bytesa.append(packetsize)

        spectsize = 5

        bytesa.append(spectsize)

        spectsinbase = 8

        bytesa.append(spectsinbase)

        compression = 1

        bytesa.append(compression)

    names = ["yes","stop","down","up","left","right","go","sheila","on","off","marvin","four","happy","cat","tree","house"];

    for name in names:
        bytesa.append(ord('L'))
        data = writeBase64(name, 16)

        for byte in data:
            bytesa.append(byte)
    bytesa.append(ord('F'))
    while len(bytesa) < 511 * (1):
        bytesa.append(0x0)



    csum = 0
    for chara in bytesa:

        for n in range(8):
            index = 7 - n

            bit = (chara >> index) & 0x1
            csum += bit

    csum &= 0xFF

    csum = bit_not(csum)
    print("sum:" + hex(csum))
    bytesa.append(csum)



    while len(bytesa) < 512 * 256 * (1):
        bytesa.append(0x0)

    index = str(k + 1)
    f = open("./tier1/sd"+index+".bin","rb")
    data = f.read()
    f.close()

    for mbyte in data:
        bytesa.append(mbyte)

    while len(bytesa) < 512 * 256 * (64 + 1):
        bytesa.append(0x0)

    f = open("./tier2/sd"+index+".bin","rb")
    data = f.read()
    f.close()

    for mbyte in data:
        bytesa.append(mbyte)

    while len(bytesa) < 512 * 256 * (64 * 2 + 1):
        bytesa.append(0x0)

    print(len(bytesa))
    f = open("sd"+index+".bin","wb")

    f.write(fs)
    f.write(content)
    f.write(bytesa)

    f.close()

