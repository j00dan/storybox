import serial

ser = serial.Serial('/dev/tty.usbserial-A9009hcV', 9600)
ser.write('D')
ser.close()
