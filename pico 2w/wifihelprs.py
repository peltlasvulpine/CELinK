## Using CircuitPython for the Raspberry Pi Pico 2W, Adafruit CircuitPython 10.3.0
import wifi
import math
import time
import ipaddress
import board
import digitalio
import socketpool

signalstrength = {
      0 : "Excellent",
    -10 : "Excellent",
    -20 : "Excellent",
    -30 : "Excellent",
    -40 : "Excellent",
    -50 : "Reliable",
    -60 : "Reliable",
    -70 : "Weak",
    -80 : "Weak",
    -90 : "Unusable",
    -100 : "Unusable"
}

led = digitalio.DigitalInOut(board.LED)
led.direction = digitalio.Direction.OUTPUT

pool = socketpool.SocketPool(wifi.radio)

def resolve(hostname):
    return pool.getaddrinfo(hostname, 0)[0][4][0]


def scan():
    print("scanning...")
    led.value = True
    scanned = []
    toreturn = []
    for network in wifi.radio.start_scanning_networks():
            if network.ssid != "" and network.ssid not in scanned:
                scanned.append(network.ssid)
                toreturn.append((network.ssid, signalstrength.get(math.floor(network.rssi / 10) * 10 , 'Unknown')))
    wifi.radio.stop_scanning_networks()
    led.value = False
    print("done scanning")
    return toreturn

def connect(ssid, passwd):
    print(f"connecting to {ssid}...")
    led.value = True
    wifi.radio.connect(ssid, passwd)
    led.value = False
    print(f"connected to {ssid}")

def disconnect():
    print("disconnecting...")
    led.value = True
    wifi.radio.stop_station()
    led.value = False
    print("disconnected")

def wifi_is_connected():
    print("checking if wifi is connected...")
    return wifi.radio.connected

def ping(ip, timeout):
    print(f"pinging {ip}...")
    if any(char.isalpha() for char in ip):
        ip = resolve(ip)
    return wifi.radio.ping(ip, timeout=timeout)

def help():
    return "wifiscan|clear|wifiisconnected|connect|disconnect|ping"