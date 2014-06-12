#!/usr/bin/env python
# -*- coding: utf-8 -*-

# .output cpu.txt
# select hostname , recordtime , PUSER , PSYSTEM, PIOWAIT , PSTEAL , PIDLE 
#  from cpu n , host h 
#  where n.hostid = h.hostid and testid = 22 and CPU = 'all'
#   and recordtime >= '2013-05-16 20:05:53' and recordtime <= '2013-05-16 20:06:56'
#  order by hostname  ,recordtime;

import sys
import re
import io

recordlist = {}

class FormCPU:

    def usage(self):
        print "python " + sys.argv[0] + " TargetFile"

    def parseLine(self,line):
        global recordlist
        itemList = line.rstrip().split('|') 
        host = itemList[0]
        recordtime = itemList[1]
        puser = itemList[2]
        psystem = itemList[3]
        piowait = itemList[4]
        psteal = itemList[5]
        pidle = itemList[6]

        #時刻をキーにする
        if recordtime in recordlist:
            recordlist[recordtime].update({host: [puser,psystem,piowait,psteal,pidle]})
        else:
            recordlist[recordtime] = {host: [puser,psystem,piowait,psteal,pidle]}

    def outputHeader(self):
        records = recordlist[recordlist.keys()[0]]
        out = "Time"

        for j in sorted(records.keys()):
            out += "," + j + " puser "
            out += "," + j + " psystem "
            out += "," + j + " piowait "
            out += "," + j + " psteal "
            out += "," + j + " pidle "
        print out

    def output(self):
        global recordlist
        for i in sorted(recordlist.keys()) :
            #時刻
            out = i;
            for j in sorted(recordlist[i].keys()):
               #ホスト毎のCPU情報
               for k in sorted(recordlist[i][j]):
                    out += "," + str(k)
            print out

def main():
    instance = FormCPU()
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
