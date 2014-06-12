#rolefile="/opt/ocdet/role_servers.txt"
rolefile="role_servers.txt"
roles = {}
open(rolefile){ |f| 
  f.each{ |line|
    host = line.split(",")
    next if host.size != 2
    roles[host[0].strip] = [] if roles[host[0]] == nil
    roles[host[0].strip].push(host[1].strip)
  }

  roles.keys.each { |key|
    print "role :#{key},#{roles[key].to_s.gsub(/[\[\]]/,"")} \n"
  }
}

