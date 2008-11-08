#!/usr/bin/env python
import sys
import csv

def get_csv(file):
    f = open(file, 'r')
    data = list(csv.reader(f))
    f.close()
    return data

def put_csv(data):
    w = csv.writer(sys.stdout)
    w.writerows(data)

def put_col(data):
    for r in data:
        print '%8s %12s %16s %10s %10s' % r

def diff(t1, t2):
    try:
        return int(t2) - int(t1)
    except ValueError:
        return 0

def ms(t):
    try:
        return int(t) / 1000000
    except ValueError:
        return 0

def delta(data):
    return [(q, ms(t1), t1, diff(t1, t2), diff(t1, t2) - 1000000) for
            ((q, t1), (_, t2)) in zip(data, data[1:])]

def main(args=sys.argv):
    for f in args[1:]:
        put_col(delta(get_csv(f)))

if __name__ == '__main__':
    main(sys.argv)
