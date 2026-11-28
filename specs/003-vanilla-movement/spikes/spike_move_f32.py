#!/usr/bin/env python3
"""spike (throwaway, plan 003): check spike_move_f32.cob. Usage: spike_move_f32.py <spike output file>"""
import math
import struct
import sys


def bits(x):
    return struct.unpack("<I", struct.pack("<f", x))[0]


def main():
    lines = open(sys.argv[1]).read().split("\n")
    table = 0
    for i in range(65536):
        table = (table * 31 + bits(math.sin(i / 10430.378350470453))) % 1000000007
    for line in lines:
        p = line.split()
        if not p:
            continue
        if p[0] == "N":
            d = {"0.100000000": 0.1, "0.980000000": 0.98, "0.600000000": 0.6, "0.910000000": 0.91,
                 "0.216000020": 0.21600002, "0.333333333": 1 / 3}[p[1]]
            print(f"narrow {p[1]}: move={'ok' if int(p[2]) == bits(d) else 'DIFF'} "
                  f"compute={'ok' if int(p[3]) == bits(d) else 'DIFF'} (got {p[2]} {p[3]}, want {bits(d)})")
        elif p[0] == "T":
            print(f"sine table checksum: {'ok' if int(p[1]) == table else 'DIFF'} (got {int(p[1])}, want {table})")
        elif p[0] == "I":
            x = float(p[1])
            want = int(x * 10430.378350470453) & 65535
            print(f"index of {p[1]}: {'ok' if int(p[2]) == want else 'DIFF'} (got {int(p[2])}, want {want})")
        else:
            print(line)


main()
