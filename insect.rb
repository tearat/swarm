require 'socket'
require 'colorize'
require 'concurrent'

$connect = nil
$completed_missions = []
$reconnecting_time = 0

def reconnect
    begin
        $connect = TCPSocket.new 'localhost', 2000
    rescue Errno::ECONNREFUSED
        $reconnecting_time += 1
        time = Time.at($reconnecting_time).utc.strftime("%H:%M:%S")
        print " 💔 Connection failed [#{time}] \r".red
    end
end

def attack(mission_id, target, count, size)
    puts
    puts " ✉️  Mission #{mission_id} "
    puts

    if $completed_missions.include? mission_id
        puts " ⏩ Mission already completed".yellow
        return
    end

    # puts "Exec firmware".green
    # require './firmware.rb' ## Не запускаеццо

    puts " 🚀 Atak!"
    (0..count.to_i - 1).each do |i|
        print " 💥 -> #{target}!".light_blue + " [#{size}] [#{i+1} / #{count}] \r"
        sleep 0.01
    end
    puts
    puts " ✅ Mission complete! \n".light_magenta
    $completed_missions << mission_id
    # File.write "missions", $completed_missions
end

reconnect

# $firmware_writing = false
# $firmware = []

Kernel.loop do
    begin
        while line = $connect.gets
            line.chomp!
            puts " #{line}"

            if line.split("type=MISSION").size > 1
                params     = line.split ";"
                mission_id = params[1].split("=")[1]
                target     = params[2].split("=")[1]
                count      = params[3].split("=")[1]
                size       = params[4].split("=")[1]
                Concurrent::Promise.execute{ attack(mission_id, target, count, size) }
            end

            # if line == "firmware_end"
            #     # puts ">>> Firmaware end"
            #     $firmware_writing = false
            #     puts "Write to file".green
            #     File.write "firmware.rb", $firmware.join("\n")
            # end
            #
            # if $firmware_writing
            #     $firmware << line
            # end
            #
            # if line == "firmware_begin"
            #     # puts ">>> Firmaware begin"
            #     $firmware = []
            #     $firmware_writing = true
            # end
            #
        end
    rescue NoMethodError
        # puts "Connection not found".yellow
    end
    reconnect
    sleep 1
end

$connect.close
