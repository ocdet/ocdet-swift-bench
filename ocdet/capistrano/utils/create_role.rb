#rolefile="/opt/ocdet/role_servers.txt"
rolefile=ARGV[0]
roles = {}
ips ={}
open(rolefile){ |f| 
  f.each{ |line|
    host = line.split(",")
    next if host.size != 2
    roles[host[0].strip] = [] if roles[host[0]] == nil
    roles[host[0].strip].push(host[1].strip)
    ipel = host[1].split(".")
    ips[ipel[3]] = ipel[3].to_i  if ipel[3] != nil
    
  }

  roles.keys.each { |key|
    items = "";
    roles[key].each{ |item|
       items = items + ',"' + item + '"'	
    }
    print "role :#{key}#{items} \n"
  }

  items = "";
  ips.values.sort.each {|ip|
    items = items + ',"192.168.10.' + ip.to_s + '"'	
  }
  print "role :work #{items} \n"

}

