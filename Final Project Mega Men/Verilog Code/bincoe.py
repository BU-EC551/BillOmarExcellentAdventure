import struct
import sys

lineCount = 0
byteList = bytearray()
coeName = sys.argv[1]                       #change for each file
binName = coeName.replace('.coe','.bin')


with open(binName, 'wb') as binary:
    with open(coeName) as coe:
        for line in coe:
            if lineCount == 0:
                lineCount = lineCount + 1;
            elif lineCount == 1:
                lineCount = lineCount + 1;
            else:
                byteString = line[0:len(line)-2]
                byteInt = int(byteString,2)
                binary.write(struct.pack('B',byteInt))
                

