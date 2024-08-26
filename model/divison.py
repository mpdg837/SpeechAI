dzielna = 1500
dzielnik = 50

loaded = 0

ACC = 0
A = dzielna
QUO = 0

print("acc | a | quo")
print(bin(ACC), end=",")
print(bin(A), end=",")
print(bin(QUO), end=",")
print("")

for n in range(32):
    ebit = 0

    ACC = ((ACC << 1) | ((A >> 31) & 0x1)) & 0xFFFFFFFF
    A = ((A << 1) | ((QUO >> 31) & 0x1)) & 0xFFFFFFFF
    QUO = (QUO << 1 | 0) & 0xFFFFFFFF

    print("acc | a | quo")
    print(bin(ACC),end=",")
    print(bin(A), end=",")
    print(bin(QUO), end=",")
    print("")

    if ACC >= dzielnik:

        ACC -= dzielnik
        QUO = QUO | 0x1
        print("XXX")
        print("acc | a | quo")
        print(bin(ACC), end=",")
        print(bin(A), end=",")
        print(bin(QUO))


print(QUO)