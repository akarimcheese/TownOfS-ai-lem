require 'socket'

CODE = {
	"0000" => :name,
    	"0002" => :ooc_broadcast,
	"0003" => :ic_broadcast,
	"0004" => :ic_whisper_message,
	"0101" => lambda {|args| "#{args[0]} claims to be a Sheriff!" },
	"0102" => lambda {|args| "#{args[0]} claims to be a Doctor!" },
	"0103" => lambda {|args| "#{args[0]} claims to be a Investigator!" },
	"0104" => lambda {|args| "#{args[0]} claims to be a Jailor!" },
	"0105" => lambda {|args| "#{args[0]} claims to be a Medium!" },
	"0106" => lambda {|args| "#{args[0]} claims to be a Godfather!" },
	"0107" => lambda {|args| "#{args[0]} claims to be a Framer!" },
	"0108" => lambda {|args| "#{args[0]} claims to be a Executioner!" },
	"0109" => lambda {|args| "#{args[0]} claims to be a Jester!" },
	"0110" => lambda {|args| "#{args[0]} claims to be a Bodyguard!" },
	"0111" => lambda {|args| "#{args[0]} claims to be a Mayor!" },
	"0112" => lambda {|args| "#{args[0]} claims to be a Retributionist!" },
	"0113" => lambda {|args| "#{args[0]} claims to be a Spy!" },
	"0114" => lambda {|args| "#{args[0]} claims to be a Transporter!" },
	"0115" => lambda {|args| "#{args[0]} claims to be a Vigilante!" },
	"0116" => lambda {|args| "#{args[0]} claims to be a Veteran!" },
	"0117" => lambda {|args| "#{args[0]} claims to be a Escort!" },
	"0118" => lambda {|args| "#{args[0]} claims to be a Mafioso!" },
	"0119" => lambda {|args| "#{args[0]} claims to be a Lookout!" },
	"0120" => lambda {|args| "#{args[0]} claims to be a Serial Killer!" },
	"0121" => lambda {|args| "#{args[0]} claims to be a Townie!" },
	"0122" => lambda {|args| "#{args[0]} claims to be part of the Mafia!" },
	"0131" => lambda {|args| "#{args[0]} claims #{args[1]} is a Sheriff!" },
	"0132" => lambda {|args| "#{args[0]} claims #{args[1]} is a Doctor!" },
	"0133" => lambda {|args| "#{args[0]} claims #{args[1]} is a Investigator!" },
	"0134" => lambda {|args| "#{args[0]} claims #{args[1]} is a Jailor!" },
	"0135" => lambda {|args| "#{args[0]} claims #{args[1]} is a Medium!" },
	"0136" => lambda {|args| "#{args[0]} claims #{args[1]} is a Godfather!" },
	"0137" => lambda {|args| "#{args[0]} claims #{args[1]} is a Framer!" },
	"0138" => lambda {|args| "#{args[0]} claims #{args[1]} is a Executioner!" },
	"0139" => lambda {|args| "#{args[0]} claims #{args[1]} is a Jester!" },
	"0140" => lambda {|args| "#{args[0]} claims #{args[1]} is a Bodyguard!" },
	"0141" => lambda {|args| "#{args[0]} claims #{args[1]} is a Mayor!" },
	"0142" => lambda {|args| "#{args[0]} claims #{args[1]} is a Retributionist!" },
	"0143" => lambda {|args| "#{args[0]} claims #{args[1]} is a Spy!" },
	"0144" => lambda {|args| "#{args[0]} claims #{args[1]} is a Transporter!" },
	"0145" => lambda {|args| "#{args[0]} claims #{args[1]} is a Vigilante!" },
	"0146" => lambda {|args| "#{args[0]} claims #{args[1]} is a Veteran!" },
	"0147" => lambda {|args| "#{args[0]} claims #{args[1]} is a Escort!" },
	"0148" => lambda {|args| "#{args[0]} claims #{args[1]} is a Mafioso!" },
	"0149" => lambda {|args| "#{args[0]} claims #{args[1]} is a Lookout!" },
	"0150" => lambda {|args| "#{args[0]} claims #{args[1]} is a Serial Killer!" },
	"0151" => lambda {|args| "#{args[0]} claims #{args[1]} is a Townie!" },
	"0152" => lambda {|args| "#{args[0]} claims #{args[1]} is part of the Mafia!" },
	"9000" => :lobby,
	"9001" => :game_full,
	"9002" => :name_taken,
	"9003" => :starting,
	"9100" => :ooc_broadcast,
	"9200" => :ic_broadcast,
	"9201" => :ic_whisper_message,
	"9202" => :ic_whisper_observation
}

ACTIONS = { :claim => {
				:self => {
					:role => {
						:sheriff => "0101",
				        :doctor => "0102",
				        :investigator => "0103",
				        :jailor => "0104",
				        :medium => "0105",
				        :godfather => "0106",
				        :framer => "0107",
				        :executioner => "0108",
				        :escort => "0117",
				        :mafioso => "0118",
				        :lookout => "0119",
				        :serialkiller => "0120",
				        :veteran => "0116",
				        :vigilante => "0115",
				        :jester => "0109",
				        :bodyguard => "0110",
				        :mayor => "0111",
				        :retributionist => "0112",
				        :spy => "0113",
				        :transporter => "0114"
					},
					:affiliation => {
						:townie => "0121",
						:mafia => "0122"
					}
				},
				:other => {
					:role => {
						:sheriff => "0131",
				        :doctor => "0132",
				        :investigator => "0133",
				        :jailor => "0134",
				        :medium => "0135",
				        :godfather => "0136",
				        :framer => "0137",
				        :executioner => "0138",
				        :escort => "0147",
				        :mafioso => "0148",
				        :lookout => "0149",
				        :serialkiller => "0150",
				        :veteran => "0146",
				        :vigilante => "0145",
				        :jester => "0139",
				        :bodyguard => "0140",
				        :mayor => "0141",
				        :retributionist => "0142",
				        :spy => "0143",
				        :transporter => "0144"
					},
					:affiliation => {
						:townie => "0121",
						:mafia => "0122"
					}
				}
			}
	
}


class JesterBrain
	def initialize(client)
		@night = 1
		@state = :starting
		@playerGuesses = {}
		@playerTrust = {}
		@eventLog = []
		@client = client
	end
	
	def act
		case @state
		when :starting
			@client.send(ACTIONS[:claim][:self][:role][:jester],"")
		else 
		end
	end
end


class GameClient
    
    def initialize(nickname, server_ip, server_port)
		@server = TCPSocket.new server_ip, server_port
		@nickname = nickname
		@brain = nil
	end
	
	def run
		send "0000", @nickname
		Thread.new do
		    loop {
		       puts "Waiting to read"
		       msg = @server.read(516)
		       puts "Read"
		       rawCode = msg[0..3]
		       code = CODE[msg[0..3]]
		       msg = msg[4..-1]
		       
		       case code
		       when :lobby
		           puts "Waiting on " + msg[0].ord.to_s +  " players"
		       when :name_taken
		       		puts "name is taken"
		       when :game_full
		       		puts "game is full"
		       when :ooc_broadcast
		       		puts "printing ooc"
				   nick,msg = msg.split(00.chr)
				   puts nick + ": (( " + msg.chomp + " ))"
			   when :ic_broadcast
			   	   nick,msg = msg.split(00.chr)
			   	   puts nick + ": " + msg.chomp
			   when :starting
					role,junk = msg.split(00.chr)
					setRole(role)
					puts "Your role is: " + role
		       else
		       		puts code.call(msg.split(00.chr).flatten)
		       end
		    }
	    end
	    loop {
	    	command = gets
	    	send("0002",command)
	    }
	end
	
	def setRole(role)
		case role
		when "jester"
			puts "JESTER"
			@brain = JesterBrain.new(self)
			@brain.act
			puts "JESTER"
		else
			@brain  = JesterBrain.new(self)
			puts "to do"
		end
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
