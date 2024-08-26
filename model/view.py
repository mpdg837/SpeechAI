import recorder
import speech

if __name__ == "__main__":
    spect = recorder.readSpectrogram("./generalt/no0.txt")
    speech.showSpec(spect,"no")