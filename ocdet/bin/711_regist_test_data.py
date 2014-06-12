#!/Usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os
import glob
import sqlite3
import tempfile
import re

testname = None
db_path = None
sar_dir = None
con = None
cur = None 

def setTestname(t):
    global testname
    testname = t

def setDbpath(p):
    global db_path
    db_path = p

def setSardir(d):
    global sar_dir
    sar_dir = d

def initConnection():
    global con
    global cur
    con = sqlite3.connect(db_path)
    cur = con.cursor()    

def getConnection():
    return con

def getTestID():
    print testname
    cur.execute(' select TESTID from TEST where TESTNAME = ? ' , [testname])
    row = cur.fetchone()
    if row != None:
        return row[0]
    else:
        items = testname.split('-')
        del items[20:]
        starttime = items[0]
        items[0] = testname
        items.append(starttime)
        print items
        sql = ''' insert into TEST 
                        (TESTNAME,PROXY_WORKERS,OBJECT_WORKERS,CONTAINER_WORKERS,ACCOUNT_WORKERS,REPLICATION,
                         ZONE,ACCOUNT_PAR_ZONE,CONTAINER_PAR_ZONE,OBJECT_PAR_ZONE,PROXY_NUM,
                         PROXY_AUTH_METHOD,PROXY_CACHE,DOWN_ZONE,OBJECT_SIZE,NUM_GETS,NUM_PUTS,
                         CONCURRENCY,SWIFT_BENCH_NUM,NUM_CONTAINERS,STARTTIME) 
                        values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,datetime(?, 'unixepoch'))'''
        cur.execute( sql , items )
        con.commit()
        return cur.lastrowid

def getHostID(hostname):
    hostname = hostname.strip().strip('"')
    
    cur.execute(' select HOSTID from HOST where HOSTNAME = ?' , [hostname])
    row = cur.fetchone()
    if row != None:
        hostid = row[0]
    else:
        cur.execute(' insert into HOST (HOSTNAME) VALUES (?)' , [hostname])
        hostid = cur.lastrowid
        con.commit()
    return hostid

def parseHeaderInfo(hostid,hostname,line):
    items=line.split()
    # items is expected format like ['Linux', '2.6.32-279.el6.i686', '(ec2n0804)', '04/24/13', '_i686_', '(2', 'CPU)']
    #Linux 2.6.32-358.el6.x86_64 (i024) 	06/20/13 	_x86_64_	(24 CPU)
    os = items[1]
    cpunum = items[5][1:]
#    print [hostname,os,cpunum,hostid]
    cur.execute('update HOST set hostname = ? , OS = ? , CPU = ? where HOSTID = ?' , [hostname,os,cpunum,hostid])
    de = items[3].split('/')
    return "20%s-%s-%s" % (de[2],de[0],de[1])

def parseDeviceIO(testid,hostid,testdate,line):
    items=line.split()
    # ['23:34:04', 'sda', '3.96', '0.00', '63.37', '16.00', '0.02', '4.75', '4.75', '1.88']

    if (items[0] == 'Average:') :
        return
    items[0] = testdate + " " + items[0]
    items = [testid,hostid] + items
    if (items[3] != 'DEV'):
##        print items
        cur.execute(' insert into IODEV values (?,?,?,?,?,?,?,?,?,?,?,?) ' , items)

def parseDeviceIO(testid,hostid,testdate,line):
    items=line.split()
    # ['23:34:04', 'sda', '3.96', '0.00', '63.37', '16.00', '0.02', '4.75', '4.75', '1.88']

    if (items[0] == 'Average:') :
        return
    items[0] = testdate + " " + items[0]
    items = [testid,hostid] + items
    if (items[3] != 'DEV'):
##        print items
        cur.execute(' insert into IODEV values (?,?,?,?,?,?,?,?,?,?,?,?) ' , items)


def parseIO(testid,hostid,testdate,line):
    # 23:33:00         3.96      0.00      3.96      0.00    166.34
    items=line.split()
    if (items[0] == 'Average:') :
        return
    items[0] = testdate + " " + items[0]
    items = [testid,hostid] + items
    if (items[3] != 'tps'):
#        print items
        cur.execute(' insert into IO values (?,?,?,?,?,?,?,?) ' , items)


def parseNetwork(testid,hostid,testdate,line):
    # 23:33:00           lo      0.99      0.99      0.05      0.05      0.00      0.00      0.00
    items=line.split()
    if (items[0] == 'Average:') :
        return
    items[0] = testdate + " " + items[0]
    items = [testid,hostid] + items
    if (items[3] != 'IFACE'):
        items.insert(3,'dev')
#        print items
        cur.execute(' insert into NETWORK values (?,?,?,?,?,?,?,?,?,?,?,?) ' , items)

def parseCPU(testid,hostid,testdate,line):
    # 23:33:00        all      0.50      0.00      0.50      3.00      0.00     96.00
    items=line.split()
    try:
        if (items[0] == 'Average:') :
            return
        items[0] = testdate + " " + items[0]
        items = [testid,hostid] + items
        if (items[3] != 'CPU'):
            #        print items
            cur.execute(' insert into CPU values (?,?,?,?,?,?,?,?,?,?) ' , items)
    except Exception:
        return

def parseMemory(testid,hostid,testdate,line):
    #23:33:00      1220308    717696     37.03    189820    352736    333728      8.27
    items=line.split()
    if (items[0] == 'Average:') :
        return
    items[0] = testdate + " " + items[0]
    items = [testid,hostid] + items
    if (items[3] != 'kbmemfree'):
        cur.execute(' insert into Memory values (?,?,?,?,?,?,?,?,?,?) ' , items)

def parseMemory(testid,hostid,testdate,line):
    #23:33:00      1220308    717696     37.03    189820    352736    333728      8.27
    items=line.split()
    if (items[0] == 'Average:') :
        return
    items[0] = testdate + " " + items[0]
    items = [testid,hostid] + items
    if (items[3] != 'kbmemfree'):
        cur.execute(' insert into Memory values (?,?,?,?,?,?,?,?,?,?) ' , items)

def parseLoadAvg(testid,hostid,testdate,line):
    #23:33:00            1       158      0.29      0.08      0.09
    items=line.split()
    if (items[0] == 'Average:') :
        return
    items[0] = testdate + " " + items[0]
    items = [testid,hostid] + items
    if (items[3] != 'runq-sz'):
        cur.execute(' insert into Loadavg values (?,?,?,?,?,?,?,?) ' , items)

def getRoles(testid,hostid):
    rolename = None
    cur.execute(' select rolename from role where HOSTID = ? and testid = ? ' , [hostid,testid])
    row = cur.fetchone()
    if row != None:
        rolename = row[0]

    return rolename

def parseRoles(testid,filename):
    with open(filename) as f:
        f.readline()
        for line in f:
            items=line.split(",")
            rolename = '"' + items[0].strip()[5:] + '"' 
            if rolename == ':all':
                continue
            del items[0]
            for i in items:
                hostid = getHostID(i)
                if (getRoles(testid,hostid) == None) :
                    sql = ''' insert into role (TESTID,HOSTID,ROLENAME)
                              values (?,?,?)'''
                    cur.execute(sql, [testid,hostid,rolename])
        con.commit()

def parseResult(testid,filename):
    hostname = os.path.basename(filename).replace('.swift-bench.result','')
    hostname = hostname.strip().strip('"')
    hostid = getHostID(hostname)
    with open(filename) as f:
        line = f.readline()
        for line in f:
            if not re.search("swift-bench ",line):
                continue 
            items=line.split(" ")
            if items[6] != "**FINAL**" :
                continue
            recordtime = items[1] + " " + items[2][:8]
            typenum = items[4]
            recordtype = items[5]
            failure = items[7][1:]
            speed = items[9].replace('/s','').strip()
            sql = ''' insert into result (TESTID,HOSTID,RECORDTIME,RECORDTYPE,TRYNUM,FAILURE,SPEED)
                              values (?,?,?,?,?,?,?)'''
            cur.execute(sql, [testid,hostid,recordtime,recordtype,typenum,failure,speed])
        con.commit()


def parseSar(testid,filename):
    # file name must be "IPADDR.sar"
    hostname = os.path.basename(filename).replace('.sar','')
    hostname = hostname.strip().strip('"')
    hostid = getHostID(hostname)
    tf = tempfile.NamedTemporaryFile()
#    print "sar -f " + filename + " -d -p > " + tf.name
    os.system("sar -f " + filename + " -d -p > " + tf.name )
    testdate = None
    with open(tf.name) as f:
        testdate = parseHeaderInfo(hostid,hostname,f.readline())
        f.readline()
        for line in f:
            try:
                if len(line) > 20 :
                    parseDeviceIO(testid,hostid,testdate,line)
            except sqlite3.ProgrammingError , einst :
                print "Error" + line
                raise einst
    con.commit()

    os.system("sar -f " + filename + " -b > " + tf.name );
    inserted = 0
    with open(tf.name) as f:
        f.readline()
        f.readline()
        for line in f:
            if len(line) > 20 :
                parseIO(testid,hostid,testdate,line)
                inserted+=1
#    print "inserted " + str(inserted)
    con.commit()

    os.system("sar -f " + filename + " -n DEV > " + tf.name )
    with open(tf.name) as f:
        f.readline()
        f.readline()
        for line in f:
            if len(line) > 20 :
                parseNetwork(testid,hostid,testdate,line)
    con.commit();
        
    os.system("sar -f " + filename + " -P ALL > " + tf.name )
    with open(tf.name) as f:
        f.readline()
        f.readline()
        for line in f:
            if len(line) > 20 :
                parseCPU(testid,hostid,testdate,line)
    con.commit();
        
    os.system("sar -f " + filename + " -r > " + tf.name )
    with open(tf.name) as f:
        f.readline()
        f.readline()
        for line in f:
            if len(line) > 20 :
                parseMemory(testid,hostid,testdate,line)
    con.commit();
        
    os.system("sar -f " + filename + " -q > " + tf.name )
    with open(tf.name) as f:
        f.readline()
        f.readline()
        for line in f:
            if len(line) > 20 :
                parseLoadAvg(testid,hostid,testdate,line)
    con.commit();        

def main():
    global sar_dir,testname,db_path,con,cur
    if (len(sys.argv) != 4):
        print 'Usage: # python regist_test_data.py  TESTID DBPATH OCDET_VAR_DIR'
        exit(-1)
    testname = sys.argv[1]
    db_path = sys.argv[2]
    sar_dir = sys.argv[3]+sys.argv[1]
    initConnection()

    testid = getTestID()
    print "Parse " + sar_dir 
    search_path =sar_dir + "/*.sar"
    parseRoles(testid,sar_dir+"/role.rb")
    for filename in glob.glob(search_path):
        print "parseSar(%s,%s)"%(testid,filename)
        parseSar(testid,filename)
 
    search_path =sar_dir + "/*.swift-bench.result"
    for filename in glob.glob(search_path):
        print "parseSar(%s,%s)"%(testid,filename)
        parseResult(testid,filename)

if __name__ == "__main__":
    main()
