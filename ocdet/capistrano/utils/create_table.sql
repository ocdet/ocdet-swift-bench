PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS TEST ( 
 TESTID    INTEGER    PRIMARY KEY    AUTOINCREMENT,
 TESTNAME TEXT,
 PROXY_WORKERS INTEGER,
 OBJECT_WORKERS INTEGER,
 CONTAINER_WORKERS INTEGER,
 ACCOUNT_WORKERS INTEGER,
 REPLICATION INTEGER,
 ZONE INTEGER,
 ACCOUNT_PAR_ZONE INTEGER,
 CONTAINER_PAR_ZONE INTEGER,
 OBJECT_PAR_ZONE INTEGER,
 PROXY_NUM INTEGER,
 PROXY_AUTH_METHOD TEXT,
 PROXY_CACHE TEXT,
 DOWN_ZONE INTEGER,
 OBJECT_SIZE INTEGER,
 NUM_GETS INTEGER,
 NUM_PUTS INTEGER,
 CONCURRENCY INTEGER,
 SWIFT_BENCH_NUM INTEGER,
 NUM_CONTAINERS INTEGER,
 STARTTIME DATETIME
);

create table if not exists HOST ( /*Test target hosts */
 HOSTID    INTEGER    PRIMARY KEY    AUTOINCREMENT,
 HOSTNAME TEXT,
 OS TEXT , /* OS name like Linux 2.6.32-279.el6.i686 (ec2n0800) */
 CPU TEXT, /* CPU numbers */
 Memory TEXT, /* not implemented */ 
 Disk TEXT  /* not implemented */ 
);

CREATE TABLE IF NOT EXISTS IO ( 
 TESTID INTEGER,
 HOSTID INTEGER,
 RECORDTIME DATETIME , /*recorded time. */ 
 TPS REAL,  /* Number of transfers per second. */            
 RTPS REAL, /* Number of read requests per second. */
 WTPS REAL, /* Number of write requests per second. */
 BREADPS REAL, /* Amount of data read from the devices in blocks per second. */
 BWRTNPS REAL, /* Amount of data written to the devices in blocks per second. */
 FOREIGN KEY(TESTID) REFERENCES TEST(TESTID),
 FOREIGN KEY(HOSTID) REFERENCES HOST(HOSTID)
);

CREATE TABLE IF NOT EXISTS IODEV ( 
 TESTID INTEGER,
 HOSTID INTEGER,
 RECORDTIME DATETIME , /*recorded time. */ 
 DEV TEXT, /* (disk) device name. */
 TPS REAL, /* Number of transfers per second that were issued to the device. */
 RDSECPS REAL, /*  Number of sectors read from the device. */
 WRSECPS REAL, /*  Number of sectors written to the device. */
 AVGRQSZ REAL, /*  The average size (in sectors) of the requests that were issued to the device. */
 AVGQUSZ REAL, /*  The average queue length of the requests that were issued to the device. */
 AWAIT REAL, /* The average time (in milliseconds) for I/O requests issued to the device to be served. */
 SVCTM REAL, /* The average service time (in milliseconds) for I/O requests issued to the device */
 PUTIL REAL , /* Percentage of CPU time during which I/O requests */
 FOREIGN KEY(TESTID) REFERENCES TEST(TESTID),
 FOREIGN KEY(HOSTID) REFERENCES HOST(HOSTID)
);

CREATE TABLE IF NOT EXISTS NETWORK (
 TESTID INTEGER,
 HOSTID INTEGER,
 RECORDTIME DATETIME , /*recorded time. */ 
 NETWORKTYPE TEXT , /* DEV only. */
 IFACE TEXT, /* Interface name. */
 RXPCKPS REAL, /* Number of packets received per second. */
 TXPCKPS REAL, /* Number of packets transmitted per second. */
 RXKBPS REAL, /* Number of kilobytes received per second. */
 TXKBPS REAL, /* Number of kilobytes transmitted per second. */
 RXCMPPS REAL, /* Number of compressed packets received per second */
 TXCMPPS REAL, /* Number of compressed packets transmitted per second */
 RXMCSTPS REAL, /*  Number of multicast packets received per second. */
 FOREIGN KEY(TESTID) REFERENCES TEST(TESTID),
 FOREIGN KEY(HOSTID) REFERENCES HOST(HOSTID)
);

CREATE TABLE IF NOT EXISTS CPU (
 TESTID INTEGER,
 HOSTID INTEGER,
 RECORDTIME DATETIME , /*recorded time. */ 
 CPU TEXT , /* CPU ID */
 PUSER REAL, 
 PNICE REAL,
 PSYSTEM REAL,
 PIOWAIT REAL,
 PSTEAL REAL,
 PIDLE REAL,
 FOREIGN KEY(TESTID) REFERENCES TEST(TESTID),
 FOREIGN KEY(HOSTID) REFERENCES HOST(HOSTID)
);

CREATE TABLE IF NOT EXISTS LOADAVG (
 TESTID INTEGER,
 HOSTID INTEGER,
 RECORDTIME DATETIME , /*recorded time. */ 
 RUNQSZ REAL   , /* Run queue length. */
 PLISTSZ REAL  , /*  Number of tasks in the task list. */
 LDAVG1 REAL  , /*  System load average for the past 1 minutes. */
 LDAVG5 REAL  , /*  System load average for the past 5 minutes. */
 LDAVG15 REAL , /*  System load average for the past 15 minutes. */
 FOREIGN KEY(TESTID) REFERENCES TEST(TESTID),
 FOREIGN KEY(HOSTID) REFERENCES HOST(HOSTID)
);

CREATE TABLE IF NOT EXISTS MEMORY (
 TESTID INTEGER,
 HOSTID INTEGER,
 RECORDTIME DATETIME , /*recorded time. */ 
 KBMEMFREE REAL, /* Amount of free memory available in kilobytes*/ 
 KBMEMUSED REAL, /* Amount  of  used memory in kilobytes.*/ 
 PMEMUSED REAL,  /* Percentage of used memory. */ 
 KBBUFFERS REAL, /* Amount of memory used as buffers by the kernel in kilobytes.*/
 KBCACHED REAL,  /* Amount of memory used to cache data by the kernel in kilobytes. */
 KBCOMMIT REAL,  /*  Amount of memory in kilobytes needed for current workload. */
 PCOMMIT REAL,   /* Percentage of memory needed for current workload in relation  to  the  total amount  of  memory (RAM+swap).  */
 FOREIGN KEY(TESTID) REFERENCES TEST(TESTID),
 FOREIGN KEY(HOSTID) REFERENCES HOST(HOSTID)
);

CREATE TABLE ROLE (
  TESTID INTEGER,
  HOSTID INTEGER,
  ROLENAME TEXT,
 FOREIGN KEY(TESTID) REFERENCES TEST(TESTID),
 FOREIGN KEY(HOSTID) REFERENCES HOST(HOSTID)
);

CREATE TABLE IF NOT EXISTS RESULT ( 
 TESTID INTEGER,
 HOSTID INTEGER,
 RECORDTIME DATETIME , /*recorded time. */ 
 RECORDTYPE TEXT ,  /* put,get,del */
 TRYNUM INTEGER  ,  /* tried numbers */
 FAILURE INTEGER ,  /* failure numbers */
 SPEED  REAL        /* succeeds / seconds */
);

