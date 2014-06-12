#!/usr/bin/env python
# -*- coding: utf-8 -*-

#select hostname , iface , recordtime , rxkbps , txkbps from network n , host h 
#  where n.hostid = h.hostid and testid = 22
#   and recordtime >= '2013-05-16 20:05:53' and recordtime <= '2013-05-16 20:06:56'
#  order by hostname  ,recordtime;

import sys
import re
import io

recordlist = {}

def main():
    if (len(sys.argv) != 2):
        usage()
        sys.exit(-1)

    file = sys.argv[1]
    for line in open(file, 'r'):
        parseLine(line)

    outputHeader()
    output()

def usage():
    print "python " + sys.argv[0] + " TargetFile"

def parseLine(line):
    global recordlist
    itemList = line.rstrip().split('|') 
    #ホスト名+インターフェース毎の読み込み、書きこみを値とする
    hostif = itemList[0] + "-" + itemList[1]
    recordtime = itemList[2]
    readnum = itemList[3]
    writenum = itemList[4]

    #loopbackとeth5は無視
    if itemList[1] == 'lo' or itemList[1] == 'eth5' :
        return

    #時刻をキーにする
    if recordtime in recordlist:
        recordlist[recordtime].update({hostif: [readnum,writenum]})
    else:
        recordlist[recordtime] = {hostif: [readnum,writenum]}

def outputHeader():
    records = recordlist[recordlist.keys()[0]]
    out = "Time"
    for j in sorted(records.keys()):
        out += "," + j + " r"
        out += "," + j + " s"
    print out

def output():
    global recordlist
    for i in sorted(recordlist.keys()) :
        out = i;
        for j in sorted(recordlist[i].keys()):
            out += "," + recordlist[i][j][0] + "," + recordlist[i][j][1]
        print out

    
if __name__ == "__main__":
    main()    
