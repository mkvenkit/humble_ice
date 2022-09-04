"""

    serial_prog.py 

    This program talks to an RP2040 via serial port. It sends an 
    iCE40 FPGA bitstream (.bin) file to the RP which uploads it to the 
    FPGA via SPI.

    Author: Mahesh Venkitachalam (electronut.in)

"""
import serial
import argparse
import os 

def main():
    print("Starting serial_prog...")
    # parse arguments
    parser = argparse.ArgumentParser(description="This programs sends bitsteram to RP2040.")
    # add arguments
    parser.add_argument('--p', dest='port', required=True)
    parser.add_argument('--f', dest='filename', required=True)
    args = parser.parse_args()

    # serial port
    port = args.port

    # file name
    filename = args.filename

    file_size = os.path.getsize(filename)
    print("File size = {} bytes.".format(file_size))

    f = open(filename, "rb")
    chunk_size = 64
    # open serial 
    ser = serial.Serial(port, 115200)
    print("writing...")

    # send file size in 32 bit header
    count = 0
    try:
        nbytes = 0
        while True:
            bytes = f.read(chunk_size)
            nbytes += len(bytes)
            #print(bytes)
            if not bytes:
                break
            ser.write(bytes)
            #print("wrote {} bytes...".format(nbytes))
    except Exception as e:
        print(e)

    ser.close() 
    f.close()

    print("wrote {} bytes...".format(nbytes))
    print("done.")


if __name__ == "__main__":
    main()
