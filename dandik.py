from PIL import Image, ImageEnhance
import sys


im = Image.open(sys.argv[1])
im = im.convert("RGB")
pix = im.load()
w ,h = im.size

for i in range(0, w):
    for j in range(0, h):
        if not 0 in pix[i, j]:
            pix[i, j] = (255, 255, 255, 255)

im = im.resize((w*2,h*2), Image.ANTIALIAS)
enhancer = ImageEnhance.Sharpness(im)
#im = enhancer.enhance(2.0)

img = im.rotate(3)
im.save("foo.png", "PNG", quality=100)

