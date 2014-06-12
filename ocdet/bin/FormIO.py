#!/usr/bin/env python
# -*- coding: utf-8 -*-

# .output io.txt
# select hostname , recordtime , BREADPS/2  , BWRTNPS/2  from IO n , host h 
#  where n.hostid = h.hostid and testid = 22
#   and recordtime >= '2013-05-16 20:05:53' and recordtime <= '2013-05-16 20:06:56'
#  order by hostname  ,recordtime;

import sys
import re
import io

recordlist = {}

class FormIO:
    def usage(self):
        print "python " + sys.argv[0] + " TargetFile"

    def parseLine(self,line):
        global recordlist
        itemList = line.rstrip().split('|') 
        host = itemList[0]
        recordtime = itemList[1]
        readnum = itemList[2]
        writenum = itemList[3]

        #時刻をキーにする
        if recordtime in recordlist:
            recordlist[recordtime].update({host: [readnum,writenum]})
        else:
            recordlist[recordtime] = {host: [readnum,writenum]}

    def outputHeader(self):
        records = recordlist[recordlist.keys()[0]]
        out = "Time"

        for j in sorted(records.keys()):
            out += "," + j + " r"
            out += "," + j + " s"
        print out

    def output(self):
        global recordlist
        for i in sorted(recordlist.keys()) :
            out = i;
            for j in sorted(recordlist[i].keys()):
                out += "," + recordlist[i][j][0] + "," + recordlist[i][j][1]
            print out


def main():
    instance = FormIO()
    if (len(sys.argv) != 2):
        instance.usage()
        sys.exit(-1)

    file = sys.argv[1]
    for line in open(file, 'r'):
        instance.parseLine(line)

    instance.outputHeader()
    instance.output()


    
if __name__ == "__main__":
    main()    
