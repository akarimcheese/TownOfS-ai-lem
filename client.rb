require 'socket'

CODE = {
    00.chr*4 => :name, 
    9.chr + 00.chr*3 => :lobby
}

class GameClient
    
    def initialize(nickname, server_ip, server_port)
		@server = TCPSocket.new server_ip, server_port
		@nickname = nickname
	end
	
	def run
		send 00.chr*4, @nickname
	    loop {
	       msg = @server.read(516)
	       code = CODE[msg[0..3]]
	       msg = msg[4..-1]
	       
	       case code
	       when :lobby
	           puts "Waiting on " + msg[0].ord.to_s +  " players"
	       else
	       end
	    }
	end
	
	def send(code,msg)
	    remainder = 512-msg.length
	    if (remainder < 0)
	        puts "Message Too Long"
	        return
	    end
	    @server.write code + msg + 00.chr*remainder
	end
	
	
end

client = GameClient.new("John", '0.0.0.0', 8080)
client.run