require 'socket'

CODE = {
    "0000" => :name, 
    "0002" => :oocmessage,
    "9100" => :oocmessage,
    "9000" => :lobby
}

class GameClient
    
    def initialize(nickname, server_ip, server_port)
		@server = TCPSocket.new server_ip, server_port
		@nickname = nickname
	end
	
	def run
		send "0000", @nickname
		Thread.new do
		    loop {
		       msg = @server.read(516)
		       code = CODE[msg[0..3]]
		       msg = msg[4..-1]
		       
		       case code
		       when :lobby
		           puts "Waiting on " + msg[0].ord.to_s +  " players"
		       when :oocmessage
				   nick,msg = msg.split(00.chr)
				   puts nick + ": (( " + msg.chomp + " ))"
		       else
		       end
		    }
	    end
	    loop {
	    	command = gets
	    	send("0002",command)
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