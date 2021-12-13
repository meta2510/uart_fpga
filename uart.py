import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import style
import numpy as np
import random
import serial
from time import sleep
#initialize serial port
ser = serial.Serial()
ser.port = 'COM9' 
ser.baudrate = 9600
ser.timeout = 2 #specify timeout when using readline()
ser.open()
if ser.is_open==True:
	print("\nAll right, serial port now open. Configuration:\n")
	print(ser, "\n") #print serial parameters

# Create figure for plotting
fig = plt.figure()
ax = fig.add_subplot(1, 1, 1)
xs = [] #store trials here (n)
data = np.array([])


# This function is called periodically from FuncAnimation
def animate(i, xs, data):

    #Aquire and parse data from serial port
    received_data = ser.read()              #read serial port
    sleep(0.03)
    data_left = ser.inWaiting()             #check for remaining byte
    received_data += ser.read(data_left)
    a = list(received_data)
    data = np.append(data,a)
    # Add x and y to lists
    xs = [x for x in range(len(data))]
    

    # Draw x and y lists
    ax.clear()
    ax.plot(xs, data, label="Datos enviados desde la FPGA")
    

    # Format plot
    plt.xticks(rotation=45, ha='right')
    plt.subplots_adjust(bottom=0.10)
    plt.title('Datos recibidos del UART')
    plt.ylabel('Datos')
    plt.legend()
    plt.axis([1, 75, 0, 150]) #limite de datos a mostrar en el eje X
    

# Set up plot to call animate() function periodically
ani = animation.FuncAnimation(fig, animate, fargs=(xs, data), interval=1000)
plt.show()