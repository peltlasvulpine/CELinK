## Using CircuitPython for the Raspberry Pi Pico 2W, Adafruit CircuitPython 10.3.0
import wifi
import math
import time
import ipaddress
import board
import digitalio
import socketpool
import adafruit_requests
import adafruit_connection_manager
import rtc
import adafruit_ntp

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
adafruitpool = adafruit_connection_manager.get_radio_socketpool(wifi.radio)
ssl_context = adafruit_connection_manager.get_radio_ssl_context(wifi.radio)
requests = adafruit_requests.Session(adafruitpool, ssl_context)

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
    try:
        wifi.radio.connect(ssid, passwd)
        print("Waiting for IP address...")
        timeout = 10
        start_time = time.time()
        while not wifi.radio.connected:
            if time.time() - start_time > timeout:
                print("Connection timed out waiting for IP.")
                led.value = False
                return
            time.sleep(0.5)
            
    except Exception as e:
        print(f"failed to connect to {ssid}: {e}")
        led.value = False
        return
    
    print("Settling network interface...")
    time.sleep(2.0)

    print("Syncing network time...")
    try:
        ntp = adafruit_ntp.NTP(pool, tz_offset=0)
        rtc.RTC().datetime = ntp.datetime
    except Exception as e:
        print(f"NTP sync failed: {e}")
        
    with open("/r1.pem", "r") as f:
        ca_cert_data = f.read().strip()

    ssl_context.load_verify_locations(cadata=ca_cert_data)
    
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

def geturl(url, maxbytes):
    led.value = True
    try:
        if not url.startswith("http"):
            url = "https://" + url
        print(f"getting {url}...")
        with requests.get(url) as response:
            body = response.content[:maxbytes]
            header = f"status|{response.status_code}|{len(body)}\n"
    except Exception as e:
        header = f"error|{str(e)[:80]}\n"
        body = b""
    led.value = False
    return header, body

def help():
    return "wifiscan|connect|disconnect|wifiisconnected|ping|get|clear"