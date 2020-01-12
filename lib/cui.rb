require 'pastel'
require 'tty-prompt'

PASTEL = Pastel.new
PROMPT = TTY::Prompt.new(symbols: {
    marker: '$',
    radio_on: 'x',
    radio_off: 'o',
    arrow_up: 'up',
    arrow_down: 'down'
}.freeze,
active_color: :yellow)

def gnrt_line(str, align, ptrn)
    new_str = ""
    cols     = (`tput cols`.chomp).to_i
    mpl   = (cols/2 - (str.length/2))-3
    (1..2).each do
        if (new_str.length < cols/2)
            if(align == "left")
                new_str += ' '+str+' '
            end
        end
        for i in (0..mpl) do
            if (i%2 == 0)
                new_str += ptrn[0]
            else
                new_str += ptrn[1]
            end
        end
        if (new_str.length < cols/2)
            if(align == "center")
                new_str += ' '+str+' '
            end
        end
    end
    if(align == "right")
        new_str += ' '+str+' '
    end
    return new_str
end

def msg(str, options = {})
    case options[:pos]
        when "l"
            options[:pos] = "left"
        when "c"
            options[:pos] = "center"
        when "r"
            options[:pos] = "right"
        else
            options[:pos] = "center"
    end

    if (options[:ptrn].nil?)
        options[:ptrn] = [' ', '.']
    end

    case options[:type]
        when "ok"
            return PASTEL.green(gnrt_line("[OK]=>["+str+"]", options[:pos], options[:ptrn]))
        when "err"
            return PASTEL.red(gnrt_line("[ERR]=>["+str+"]", options[:pos], options[:ptrn]))
        when "warn"
            return PASTEL.yellow(gnrt_line("["+str+"]", options[:pos], options[:ptrn]))
        when "info"
            return PASTEL.blue(gnrt_line("["+str+"]", options[:pos], options[:ptrn]))
        else
            gnrt_line("["+str+"]", options[:pos], options[:ptrn])
    end
end



