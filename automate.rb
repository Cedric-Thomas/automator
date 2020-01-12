include Process
require './lib/ensp.rb'

Routers = {
    id: ["PE1","PE2","PE3","P1","P2","CE1","CE2","CE3","CE4","CE5"],
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
    },
    CE1: {
        port: 2005,
    },
    CE2: {
        port: 2006,
    },
    CE3: {
        port: 2007,
    },
    CE4: {
        port: 2008,
    },
    CE5: {
        port: 2009,
    }
}

def waitForChild()
    Routers[:id].each do |r|
        if (! Routers[:"#{r}"][:pid].nil?)
            Process.wait(Routers[:"#{r}"][:pid])
        end
    end
end

while true
    PROMPT.select(">> { Menu }") do |menu|
        puts(msg("RECAENT Automation System", {msg: "warn", ptrn: ['*','-']}))
        menu.choice "> generate Config", -> do 
            generateConfig()
        end
        menu.choice "> deploy Config", -> do 
            deployConfig()
            waitForChild()
        end
        menu.choice "> flush router/s", -> do 
            flushConf()
            waitForChild()
            puts(msg(
                "Completed !",
                {type: "info", pos: "c"}  )  )
            puts("\n\n")
        end
        menu.choice "> quit", -> { exit() }
    end
end