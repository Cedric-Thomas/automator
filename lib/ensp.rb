require 'socket'
require './lib/chat.rb'
require './lib/cui.rb'


def selectRouters()
    return PROMPT.
    multi_select(
        " ->> Which router/s ?",
        Routers[:id]
    )
end

def getConf(r)
    ## Cleaning the conf file to inject later
    return File.open(r+".conf").readlines.
    map(&:chomp).map(&:split).
    map{ |arr| arr.join(" ")}.
    reject { |str| str.empty? }
end

def generateConfig()
    puts(msg("Generating config", {pos: "l", type: "info"}))
    routers = selectRouters()
end


def deploy(r_sock, conf)
    log = ""
    conf.each do |line|
        log += execute(r_sock, line)
    end
    return log
end


def flushConf()

    cflush = [
    "reset saved-configuration",
    "y"
    ]

    routers = selectRouters()

    puts(msg(
        "Flushing router/s",
        {type: "info", pos: "c"}  )  )

    routers.each do |r|

        _r = Routers[:"#{r}"]

        _r[:pid] = Process.fork do
            _r[:sock] = TCPSocket.open("127.0.0.1", _r[:port])
            deploy(_r[:sock], cflush)
            puts(msg(
                "#{r} Flushed",
                {type: "ok", pos: "l"}  )  )
            sleep 5
            puts(msg(
                "Please reboot router [#{r}] ", 
                {type: "warn", pos: "r", ptrn: ['-', ' ']}  )  )
            exit
        end

    end

end

def deployConfig()

    puts(msg(
        "DEPLOYING !", 
        {type: "warn", pos: "c", ptrn: ['-', '*']}  )  )

    routers = selectRouters()

    routers.each do |r|
        _r = Routers[:"#{r}"]

            _r[:pid] = Process.fork do
                puts(msg(
                        "deployement #{r} => #{_r[:port]}", 
                        {pos: "c", type: "wrn"}  )  )

                puts(msg(
                        "automation > start", 
                        {pos: "l", type: "info"}  )  )

                _r[:sock] = TCPSocket.open("127.0.0.1", _r[:port])
                _r[:conf] = getConf(r)

                puts( msg("report ->") )

                puts( deploy(_r[:sock], _r[:conf]) )

                puts(msg(
                        "end ->", 
                        {type: "warn", pos: "l", ptrn: [' ', ' ']}  )  )
                puts(msg(
                        "automation > end", 
                        {pos: "l", type: "info"}  )  )
                exit
            end

    end

end

