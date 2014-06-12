#!/Usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os
import glob
import sqlite3
import tempfile
import unittest
from  regist_test_data import getTestID,setTestname,setDbpath,initConnection,getConnection

class TestRegistTest(unittest.TestCase):

    def setUp(self):
        sql_path = "/opt/ocdet/capistrano/utils/create_table.sql"
        db_path = "/tmp/testdb.sqlite"
        os.system("rm -rf %s" %db_path )
        os.system("echo .read %s | sqlite3 %s" % (sql_path,db_path))
        setDbpath(db_path)
        initConnection()

    def tearDown(self):
        None

    def testGetTestID(self):
        testname = "1234567890-1-2-3-4-5-6-7-8-9-10-tempauth-on-11-12-13-14-15-16-17"
        setTestname(testname)
        id = getTestID()
        con =  getConnection()
        con.row_factory = sqlite3.Row
        for row in con.execute(' select * from TEST where TESTID = ? ' , [id]):
            print row["PROXY_WORKERS"]
            self.assertTrue(row["PROXY_WORKERS"] == 1)
            self.assertTrue(row["OBJECT_WORKERS"] == 2)
            self.assertTrue(row["CONTAINER_WORKERS"] == 3)
            self.assertTrue(row["ACCOUNT_WORKERS"] == 4)
            self.assertTrue(row["REPLICATION"] == 5)
            self.assertTrue(row["ZONE"] == 6)
            self.assertTrue(row["ACCOUNT_PAR_ZONE"] == 7)
            self.assertTrue(row["CONTAINER_PAR_ZONE"] == 8)
            self.assertTrue(row["OBJECT_PAR_ZONE"] == 9)
            self.assertTrue(row["PROXY_NUM"] == 10)
            self.assertTrue(row["PROXY_AUTH_METHOD"] == "tempauth")
            self.assertTrue(row["PROXY_CACHE"] == "on")
            self.assertTrue(row["DOWN_ZONE"] == 11)
            self.assertTrue(row["OBJECT_SIZE"] == 12)
            self.assertTrue(row["NUM_GETS"] == 13)
            self.assertTrue(row["NUM_PUTS"] == 14)
            self.assertTrue(row["CONCURRENCY"] == 15)
            self.assertTrue(row["SWIFT_BENCH_NUM"] == 16)
            self.assertTrue(row["NUM_CONTAINERS"] == 17)
 

if __name__ == '__main__':
    unittest.main()
