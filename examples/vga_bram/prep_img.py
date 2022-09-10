"""
    prep_img.py

    This Python script reads in an image, resizes it to 64 x 64 
    (maintains aspect ratio, pads black) and generates the hex file for 
    input to Verilog $readmemh(). 

    Author: Mahesh Venkitachalam

"""

from PIL import Image
import argparse 

# parse arguments
parser = argparse.ArgumentParser(description="This Python script reads in an image, resizes it to 64 x 64 (maintains aspect ratio, pads black) and generates the hex file for input to Verilog $readmemh(). ")
# add arguments
parser.add_argument('--w', dest='width', required=False)
parser.add_argument('--h', dest='height', required=False)
parser.add_argument('--i', dest='input_file', required=True)
args = parser.parse_args()

im = Image.open(args.input_file)

WIDTH, HEIGHT = 64, 64

if (args.width):
    WIDTH = int(args.width)

if (args.height):
    HEIGHT = int(args.height)

pixels = im.load() 
width, height = im.size
print("input image is {} x {}.".format(width, height))

im_new = None

if (width, height) != (WIDTH, HEIGHT):
    print("resizing to {}x{}...".format(WIDTH, HEIGHT))
    aspect = WIDTH / float(im.size[0])
    im_new = Image.new("RGB", (WIDTH, HEIGHT), (0, 0, 0))
    h = im.size[1] * (WIDTH / float(width))
    im = im.resize((WIDTH, int(h)), Image.Resampling.LANCZOS)
    y = (HEIGHT - int(h)) // 2
    im_new.paste(im, (0, y))
    im_new.save('out.png')

ofile = open("img.mem", 'w')
if im_new:
    pixels = im_new.load()
    width, height = im_new.size
else: 
    pixels = im.load()

for x in range(height):
    for y in range(width):
        pixel = pixels[y, x]
        # write out BGR in 12-bit format. eg. abc ce0 ...
        ofile.write("%x%x%x " % (pixel[2] >> 4, pixel[1] >> 4, pixel[0] >> 4))
    ofile.write('\n')
ofile.close()

print('output written to img.mem.')
