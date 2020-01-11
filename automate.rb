require 'socket'
require 'tty-prompt'

def init(sock, cmd)

    def wait_available(sock)
        i=0
        while not sock.ready?
            if i >= 5
                return "TIMEOUT"
            end
            sleep 1
            i+=1
        end
    end

    def read(sock)
        data=""
        if wait_available(sock) == "TIMEOUT"
            return "[ERROR][READ TIMEOUT]"
        end
        while sock.ready?
            data += sock.recv(1)
        end
        return data
    end
  
    sock.write("return\n")
    if not ( read(sock).split("\n").last =~ /<.*>/ )
        puts("ERROR")
    end
    sock.write(" #{cmd}\n")
    return read(sock)
    
end

def execute(sock, cmd)

    def wait_available(sock)
        i=0
        while not sock.ready?
            if i >= 5
                return "TIMEOUT"
            end
            sleep 1
            i+=1
        end
    end

    def read(sock)
        data=""
        if wait_available(sock) == "TIMEOUT"
            return "[ERROR][READ TIMEOUT]"
        end
        while sock.ready?
            data += sock.recv(1)
        end
        return data
    end

    sock.write("#{cmd}\n")
    return read(sock)

end

ROUTERS = {
    id: ["PE1","PE2","PE3","P1","P2"],
    PE1: {
        port: 2000,
    },
    PE2: {
        port: 2001,
    },
    PE3: {
        port: 2002,
    },
    P1: {
        port: 2003,
    },
    P2: {
        port: 2004,
    }
}

#
def flushConf(_r, r)
    puts("Flushing #{r}")
    toto = execute(_r, "return\n").split("\n").last =~ /<.*>/ 
    if not (toto)
        puts("ERROR")
        puts(toto)
    end
    execute(_r, "reset saved-configuration\n")
    puts execute(_r, "y\n")
    puts("End")
end

def getConf(r)
    return File.open(r+".conf").readlines.
    map(&:chomp).
    map(&:split).
    map{ |arr| arr.join(" ")}.
    reject { |str| str.empty? }
end


actionsList = {
    generateConfig: "generateConfig()",
    deployConfig: "deployConfig()",
    exit: "exit()"
}

PROMPT = TTY::Prompt.new

def selectRouters()
    return PROMPT.
    multi_select("🦊 >> Which router/s ?",
    ROUTERS[:id])
end

def generateConfig()
    puts("[GNRT]")
    routers = selectRouters()

end

def deploy(_r, conf)
    log = ""
    conf.each do |line|
        log += execute(_r[:sock])
    end
    return log
end

def deployConfig()
    puts("[DPLY]")
    
    routers = selectRouters()
    
    routers[:id].each do |r|
    _r = ROUTERS[:"#{r}"]
        _r[:thread] = Thread.new {
            puts("[deployement][automation]>[start] #{r} => #{_r[:port]}")
            _r[:sock] = TCPSocket.open("127.0.0.1", _r[:port])
            _r[:conf] = getConf(r)
            deploy(_r[:sock], _r[:conf])
            puts("[deployement][automation]>  [end] #{r} => #{_r[:port]}")
        }
    _r[:thread].join
    end
end

PROMPT.select("🎋 >> { Menu }") do |menu|
    menu.choice "> generate Config", -> { generateConfig() }
    menu.choice "> deploy Config", -> { deployConfig() }
    menu.choice "> quit", -> { exit() }
end