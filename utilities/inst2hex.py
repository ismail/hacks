#!/usr/bin/env python3
import sys

if __name__ == "__main__":
    insts = sys.argv[1].strip().split(" ")


    for inst in insts:
        i = len(inst)
        while i >= 2:
            print("0x%s " % inst[i-2:i], end="")
            i -= 2
        print()
