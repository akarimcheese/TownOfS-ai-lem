require 'socket'


# MSG CODES
# 0XXX - Client Message
# 9XXX - Server Message
# 0000[Name] - Nickname Declaration
# 0001[Name] - Nickname Change
# 0002[OOC Message] - OOC Chat Message
# 0003[IC Message] - IC Chat Message
# 0004(\00[MSG])* - Update Will
# 0005(\00[MSG])* - Update Death Note
###### Role Actions ######
#### Public
## Self-Claim
# 0101 - Claim Sheriff
# 0102 - Claim Doctor
# 0103 - Claim Investigator
# 0104 - Claim Jailor
# 0105 - Claim Medium
# 0106 - Claim Godfather
# 0107 - Claim Framer
# 0108 - Claim Executioner
# 0109 - Claim Jester
# 0110 - Claim Bodyguard
# 0111 - Claim Mayor
# 0112 - Claim Retributionist
# 0113 - Claim Spy
# 0114 - Claim Transporter
# 0115 - Claim Vigilante
# 0116 - Claim Veteran
# 0117 - Claim Escort
# 0118 - Claim Mafioso
# 0119 - Claim Lookout
# 0120 - Claim Serial Killer
# 0121 - Claim Townie
# 0122 - Claim Mafia
## Other-Claim
# 0131[Target] - Claim Target is Sheriff
# 0132[Target] - Claim Target is Doctor
# 0133[Target] - Claim Target is Investigator
# 0134[Target] - Claim Target is Jailor
# 0135[Target] - Claim Target is Medium
# 0136[Target] - Claim Target is Godfather
# 0137[Target] - Claim Target is Framer
# 0138[Target] - Claim Target is Executioner
# 0139[Target] - Claim Target is Jester
# 0140[Target] - Claim Target is Bodyguard
# 0141[Target] - Claim Target is Mayor
# 0142[Target] - Claim Target is Retributionist
# 0143[Target] - Claim Target is Spy
# 0144[Target] - Claim Target is Transporter
# 0145[Target] - Claim Target is Vigilante
# 0146[Target] - Claim Target is Veteran
# 0147[Target] - Claim Target is Escort
# 0148[Target] - Claim Target is Mafioso
# 0149[Target] - Claim Target is Lookout
# 0150[Target] - Claim Target is Serial Killer
# 0151[Target] - Claim Target is Townie
# 0152[Target] - Claim Target is Mafia
## Role Questioning
# 0200[Target] - Ask for Target's role
# 0201[Target] - Ask for Target's affiliation
# 0202[Target1]\00[Target2] - Ask for Target1's opinion on Target2's role
# 0203[Target]\00[MSG] - Ask Target about something
# 0204[Target] - Test that Target is Spy
# 0210 - Cannot answer due to safety
# 0211 - Does not trust accuser
# 0212 - Claim witch hunt
# 0213 - Refuse to answer
# 0214 - Yes
# 0215 - No
# 0216 - I don't know
# 0217 - Prove you are a spy (only works if you are a spy)
## Emotes
# 0301[Msg] - Say hi in the form of Msg
#### Actions Descriptions
# 1001[Night]\00[Target] - The Death of Target
# 1002[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Sheriff) investigated Targeted 1, found to be nonsuspicious
# 1003[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Sheriff) investigated Targeted 1, found to be mafia
# 1004[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Sheriff) investigated Targeted 1, found to be serial killer
# 1005[Night]\00[Target1]\00[Target2 (Optional)] - Target1 saved by Target2 (Doctor)
# 1006[Night]\00[Target1]\00[Target2 (Optional)] - Target1 monitored by Target2 (Doctor)
# 1007[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Doctor) failed to heal Target1
# 1008[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Escort, Transporter, or Consort*
# 1009[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Investigator, Consigliere*, or Mayor
# 1010[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Sheriff, Executioner or Werewolf*
# 1011[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Lookout, Forger* or Amnesiac*
# 1012[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Spy, Blackmailer* or Jailor
# 1013[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Doctor, Disguiser* or Serial Killer
# 1014[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Bodyguard, Godfather or Arsonist*
# 1015[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Medium, Janitor*, or Retributionist
# 1016[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Survivor*, Vampire Hunter* or Witch*
# 1017[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Invest) found Target1 to be Framer, Vampire*, Jester, or Framed
# 1018[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Jailor) jailed Target1
# 1019[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Jailor) jailed Target1 and executed them
# 1020[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Jailor) jailed Target1 and let them go
# 1021[Night]\00[Target1]\00[Target2]\00[MSG] - Target2 (Medium) spoke with Target1 about [MSG]
# 1022[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Framer) framed Target1
# 1023[Target1]\00[Target2] - Target2 (Executioner) is assigned to kill Target1
# 1024[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Escort) distracted Target1
# 1025[Night]\00[Target1]\00[Target2] - Target2 (Escort) died distracting Target1
# 1026[Night]\00[Target1]\00[Target2]\00[Target3] - Target3 (Lookout) saw Target2 visiting Target1
# 1027[Night]\00[Target1]\00[Target2] - Target2 (Veteran) attacked Target1 while on alert
# 1028[Target1] - Target1 Revealed himself to be Mayor
# 1029[Night]\00[Target1]\00[Target2 (Optional)] - Target2 (Retributionist) brought Target1 back from the dead
# 1030[Night]\00[Target1]\00[Target2]\00[Target3 (Optional)] - Target3 (Transporter) switched Target2 and Target1
# 1031[Night]\00[Target1]\00[Target2 (Optional)] - Target1 was invincible to an attack from Target2
# 1032[Night]\00[Target1]\00[Target2 (Optional)] - Target1 was role blocked by Target2
# 1033[Night]\00[Target1]\00[Target2 (Optional)] - Target1 was role block immune from Target2's role block
# 1034[Night]\00[Target1]\00[Target2] - Target1 was killed by Target2
# 1035[Night]\00[Target1]\00[Target2] - Target2 (Bodyguard) guarded Target1
# 1035[Night]\00[Target1]\00[Target2] - Target2 (Bodyguard) died guarding Target1
#
# 8000\00[n] - It is the nth night
#
# 9000[Number] - Number of users needed to start
# 9001 - Game is full
# 9002 - Name taken/Too Long
# 9003[Role](\00[Name])* - Starting Game, Assigned Role, List of all other players
# 9100[Name]\00[Message] - OOC Message broadcast

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

CODE = {
	"0000" => :name,
    "0002" => :ooc_broadcast,
	"0003" => :ic_broadcast,
	"0004" => :ic_whisper_message,
	"9000" => :lobby,
	"9001" => :game_full,
	"9002" => :name_taken,
	"9003" => :starting,
	"9100" => :ooc_broadcast,
	"9200" => :ic_broadcast,
	"9201" => :ic_whisper_message,
	"9202" => :ic_whisper_observation
}

STATES = {
	:lobby => :starting
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
				# If we have 15 clients, we can't accept any more
			    if (@clients.size >= 15) then
			        # Later make it so others can watch
			        client.write "9001" + 0.chr*512
			        return
			    end
			    puts client.addr 
				nick,throwaway = (client.read(516)[4..-1]).chomp.split(00.chr)
				
				# If the name is taken or is too long, they have to provide a new one
			    if ((@clients.value?(nick) && nick[0..3] !=~ /^\d{4}$/) || nick.length > 16) then
			    	client.write "9002" + 0.chr*512
			        return
			    end
			    
			    # Store each client's nickname
				@clients[client] = nick
				puts nick 
				
				# Listen to each client
				listen(client)
			end
		}
	end
	
	def gameThread
	    Thread.new do
	        loop {
	        	case @state
	        	# We are in lobby when we are waiting for enough players to start the game
	        	when :lobby
		            puts "SLEEPING"
		            # Check every 10 seconds to see if we have enough players
		            sleep(10)
		            puts "BROADCASTING"
		            puts (@minPlayers - @clients.size)
		            # If we don't have enough players, let them know how many we are waiting on
		            if (@minPlayers - @clients.size > 0) then
		                broadcast("9000", (@minPlayers - @clients.size).chr)
		            # Once we have enough players, assign roles
		            else
		                @state = :starting
		                assignRoles
		            end
		        # When we start the game, give players 15 seconds to initialize their AIs 
		        # and have them say Hi before nightfall
		        when :starting
		        	sleep(15)
		        	@state = :night
		        else
		        end
	        }
	    end
	end
	
	# Send everyone a message
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
	    # Make a readable list of the roster for everyone to receive
	    roster = @clients.values.map{|name| 00.chr + name}.join
	    # Rearrange the clients randomly
	    @clients.keys.shuffle.each { |sock|
	    	# Give each client a role
	        role = @@roles[i].sample
	        # Keep track of their role
	        @players[sock] = role
	        # Inform them of their role
	        send("9003", role.to_s + roster, sock)
	        i = i + 1
	    }
	end
	
	# Send a message to a single recipient
	def send(code,msg,client)
	    remainder = 512 - msg.length
	    puts "sending" + code + msg + 00.chr*remainder
	    client.write code + msg + 00.chr*remainder
	    puts "sent"
	end
	
	# Listen to a client
	def listen (client)
		loop {
			data = nil
			data = client.read(516)
			
			# If socket closes, say so
			if (!data)
				puts @clients[client] + " disconnected"
				@clients.delete(client)
				return
			end
			
			# If we receive a message from a client, broadcast it to everyone
			case CODE[data[0..3]]
			when :ooc_broadcast
				broadcast("9100",@clients[client] + 00.chr + data[4..-1].split(00.chr)[0])
			when :ic_broadcast
				broadcast("9200",@clients[client] + 00.chr + data[4..-1].split(00.chr)[0])
			else
				# If we receive an action, broadcast that action
				# We will need to change this for night actions and murders and things
				puts "GOT ACTION"
				broadcast(data[0..3],@clients[client])
			end
			
		}
	end
end

server = GameServer.new('0.0.0.0', 8080, 15)
server.run

