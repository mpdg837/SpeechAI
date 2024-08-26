import math
N = 512


for n in range(N):
    print("memory["+str(n)+"] = "+str(int(abs(512*math.sin(n/256 * 2 *math.pi))))+";")

for n in range(N):
    wsp = (0.53836 - 0.46164 * math.cos((2 * math.pi * n) / (N - 1)))
    # print(wsp)
    multi = int(wsp * 65535)
    print("multiplies["+str(n)+"]="+str(multi)+";")


