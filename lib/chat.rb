require 'socket'

def wait_available(sock)
    i=0
    while not sock.ready?
        if i >= 5
            return
        end
        sleep 1
        i+=1
    end
    return "ok"
end

def read(sock)
    data=""
    if (wait_available(sock) != "ok")
        return "timeout"
    end
    while sock.ready?
        data += sock.recv(1)
    end
    return data
end

def check_init()
end

def execute(sock, cmd)
    sock.write("#{cmd}\n")
    return read(sock)
end