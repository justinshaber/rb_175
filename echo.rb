require "socket"

server = TCPServer.new("localhost", 3003)

def parse_request(request_line)
  http_method, path_and_query, http_version = request_line.split(" ")
  path, params = path_and_query.split("?")

  params = (params || "").split("&").each_with_object({}) do |param, hash|
    key, value = param.split("=")
    hash[key] = value
  end

  [http_method, path, params]
end

def roll_dice(params)
  rolls = params["rolls"].to_i
  sides = params["sides"].to_i

  rolls.times do
    roll = rand(sides) + 1 
    yield(roll)
  end
end

loop do
  client = server.accept
  request_line = client.gets
  next if !request_line || request_line =~ /favicon/
  puts request_line

  http_method, path, params = parse_request(request_line)

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html\r\n\r\n"
  client.puts "<html>"
  client.puts "<body>"
  client.puts request_line
  client.puts "<h1>Counter</h1>"

  number = params["number"].to_i
  client.puts "<p>The current number is #{number}.</p>"
  client.puts "<a href='?number=#{number + 1}'>Add one</a>"
  client.puts "<a href='?number=#{number - 1}'>Subtract one</a>"

  client.puts "</body>"
  client.puts "</html>"

  client.close
end

=begin Rolling dice
  client.puts "<h1>Rolls!</h1>"
  roll_dice(params) do |roll|
    client.puts "<p>#{roll}</p>"
  end
=end
