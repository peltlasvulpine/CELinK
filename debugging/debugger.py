import serial

port = serial.Serial(input("Where to?"), 115200)
towrite = ""

while towrite != "exit":
    towrite = input("To send?")
    port.write(towrite.replace("\\n", "\n").encode())
    print("Sent!")
port.close()
