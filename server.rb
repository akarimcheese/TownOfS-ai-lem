require 'socket'


# MSG CODES
# 0XXX - Client Message
# 9XXX - Server Message
# 0000[Name] - Nickname Declaration
# 0001[Name] - Nickname Change
# 0002[Message] - OOC Chat Message
# 9000[Number] - Number of users needed to start
#
#
class GameServer
    def initialize(ip, port)
		@server = TCPServer.open(ip, port)
		@clients = {}
		@players = {}
		@state = :lobby
	end
	
	def run
	    gameThread
		loop {
			Thread.start(@server.accept) do |client|
			    puts client.addr 
				nick,throwaway = (client.read(516)[4..-1]).chomp.split(00.chr)
				@clients[client] = nick
				puts nick 
				
				#listMsg(client, nick)
				
				listen(client)
			end
		}
	end
	
	def gameThread
	    Thread.new do
	        loop {
	            puts "SLEEPING"
	            sleep(10)
	            puts "BROADCASTING"
	            puts (10 - @clients.size)
	            broadcast(9.chr + 00.chr*3, (10 - @clients.size).chr)
	        }
	    end
	end
	
	def broadcast(code, msg)
	    remainder = 512 - msg.length
	    @clients.each_pair { |sock,nick|
	        puts "sending" + code + msg + 00.chr*remainder
	        sock.write code + msg + 00.chr*remainder
	        puts "sent"
	    }
	end
	
	def send(code,msg,client)
	    remainder = 512 - msg.length
	    puts "sending" + code + msg + 00.chr*remainder
	    client.write code + msg + 00.chr*remainder
	    puts "sent"
	end
	
	def listen (client)
		loop {
			data = nil
			data = client.read(516)
			
			if (!data)
				puts @clients[client] + " disconnected"
				@clients.delete(client)
				return
			end
			
		}
	end
end

server = GameServer.new('0.0.0.0', 8080)
server.run

