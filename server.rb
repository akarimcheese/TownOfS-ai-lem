require 'socket'


# MSG CODES
# 0XXX - Client Message
# 9XXX - Server Message
# 0000[Name] - Nickname Declaration
# 0001[Name] - Nickname Change
# 0002[Message] - OOC Chat Message
# 9000[Number] - Number of users needed to start
# 9001 - Game is full
# 9002[Role] - Starting Game, Assigned Role

CODE = {
    00.chr*3 + 2.chr => :oocmessage, 
}

class GameServer
    @@roles = [
		            [:sheriff],
		            [:doctor],
		            [:investigator],
		            [:jailor],
		            [:medium],
		            [:godfather],
		            [:framer],
		            [:executioner],
		            [:escort],
		            [:mafioso],
		            [:lookout],
		            [:serialkiller],
		            [:veteran,:vigilante],
		            [:jester],
		            [
		                :bodyguard,
		                :doctor,
		                :escort,
		                :investigator,
		                :lookout,
		                :mayor,
		                :medium,
		                :retributionist,
		                :sheriff,
		                :spy,
		                :transporter,
		                :vigilante
		            ]
		        ]
    
    def initialize(ip, port, minPlayers)
		@server = TCPServer.open(ip, port)
		@clients = {}
		@players = {}
		@state = :lobby
		@minPlayers = minPlayers
	end
	
	def run
	    gameThread
		loop {
			Thread.start(@server.accept) do |client|
			    if (@clients.size >= 15) then
			        # Later make it so others can watch
			        client.write 9.chr + 0.chr*2 + 1.chr + 0.chr*512
			        return
			    end
			    puts client.addr 
				nick,throwaway = (client.read(516)[4..-1]).chomp.split(00.chr)
				@clients[client] = nick
				puts nick 
				
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
	            puts (@minPlayers - @clients.size)
	            if (@minPlayers - @clients.size > 0) then
	                broadcast(9.chr + 00.chr*3, (@minPlayers - @clients.size).chr)
	            else
	                @state = :starting
	            end
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
	
	def assignRoles
	    i = 0
	    @clients.keys.shuffle.each { |sock|
	        role = @@roles[i].sample
	        @players[sock] = role
	        send(9.chr + 0.chr*2 + 2.chr, role.to_s, sock)
	        i = i + 1
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
			
			#case CODE[data[0..3]]
			#when :oocmessage
			#else
			#end
			
		}
	end
end

server = GameServer.new('0.0.0.0', 8080, 15)
server.run

