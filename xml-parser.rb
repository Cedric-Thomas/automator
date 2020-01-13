require 'JSON'
require 'nokogiri'

raw = File.open("exemples/TP2.topo")
          .read
          .sub!('encoding="UNICODE"', 
          'encoding="UTF-8"')

doc = Nokogiri::XML(raw)

routers = {
    guid: { } 
}

doc.xpath("/topo/devices/dev").each do |i|
    buf = [i.attr("id"), i.attr("name")]
    routers[:guid][:"#{buf[0]}"] = buf[1]
    routers[:"#{buf[1]}"] = { 
        model: i.attr("model"),
        links: [] 
    }
    if (routers[:"#{buf[1]}"][:model] == "PC")
        routers[:"#{buf[1]}"][:settings] = i.attr("settings")
    end
end

doc.xpath("/topo/lines/line").each do |link|
    buf = [link.attr("srcDeviceID"), link.attr("destDeviceID")]
    sname = routers[:guid][:"#{buf[0]}"]
    dname = routers[:guid][:"#{buf[1]}"]
    routers[:"#{sname}"][:links].push([[dname, link.xpath("interfacePair").attr("srcIndex").to_s, link.xpath("interfacePair").attr("tarIndex").to_s]])
end

marray = []

=begin
routers.each do |key, val|
    if (key.to_s.start_with?("PC"))
        tmparr = []
        mval = {
            ip: "192.168.1.2",
            mask: "255.255.255.0",
            gateway: "192.168.1.1"
        }
        val[:settings].split(" -") do |setting|
            if (setting.start_with?("simpc_ip"))
                setting.sub!("simpc_ip 0.0.0.0", "simpc_ip #{mval[:ip]}")
            elsif (setting.start_with?("simpc_mask"))
                setting.sub!("simpc_mask 0.0.0.0", "simpc_ip #{mval[:mask]}")
            elsif (setting.start_with?("simpc_gateway"))
                setting.sub!("simpc_gateway 0.0.0.0", "simpc_ip #{mval[:gateway]}")
            end
            tmparr.push(setting)
        end
        puts tmparr.join(" -")
    end
end
=end

#p routers[:PC1][:settings]

routers.each do |key, infos|
     if (key.to_s != "guid")
        puts infos
        if (infos[:links][0] != nil)
            if (routers[:"#{infos[:links][0][0]}"] != nil)
                routers[:"#{infos[:links][0][0]}"].
                push([key.to_s, infos[:links][0][1], infos[:links][0][0]])
            end
        end
    end
end

puts JSON.pretty_generate(routers)