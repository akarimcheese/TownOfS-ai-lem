require 'socket'
require_relative 'brains'

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
#### Perform Action
# 0901[Target] - Investiage Target as Sheriff
# 0905 - Doctor heals self
# 0906[Target] - Doctor heals Target
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
# 9000[Number] - Number of users needed to start
# 9001 - Game is full
# 9002 - Name taken
# 9003[Role] - Starting Game, Assigned Role
# 9100[Name]\00[Message] - OOC Message broadcast

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
	"0901" => lambda {|args| "#{args[0]} is investigating #{args[1]} tonight!" },
	"0905" => lambda {|args| "#{args[0]} will be healing themself tonight!" },
	"0906" => lambda {|args| "#{args[0]} will be healing #{args[1]} tonight!" },
	"9000" => :lobby,
	"9001" => :game_full,
	"9002" => :name_taken,
	"9003" => :starting,
	"9004" => :roster,
	"9100" => :ooc_broadcast,
	"9200" => :ic_broadcast,
	"9201" => :ic_whisper_message,
	"9202" => :ic_whisper_observation
}

ACTIONS = { 
			:roleAct => {
				:sheriff => {
					:investigate => "0901"
				},
				:doctor => {
					:heal => {
						:self => "0905",
						:other => "0906"
					}
				}
			},
			:claim => {
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





class GameClient
    
    def initialize(nickname, server_ip, server_port)
		@server = TCPSocket.new server_ip, server_port
		@nickname = nickname
		@brain = nil
	end
	
	def run
		# Tell the server our name
		send "0000", @nickname
		# We need to handle what to do when our nickname is taken or game is full
		Thread.new do
		    loop {
		       puts "Waiting to read"
		       msg = @server.read(516)
		       puts "Read"
		       rawCode = msg[0..3]
		       code = CODE[msg[0..3]]
		       msg = msg[4..-1]
		       
		       case code
		       # If we're waiting on others, inform user of how many others
		       when :lobby
		           puts "Waiting on " + msg[0].ord.to_s +  " players"
		       # If name is taken, tell user
		       # We need to allow the user to change their name
		       when :name_taken
		       		puts "name is taken"
		       # If the game is full, tell user
		       when :game_full
		       		puts "game is full"
		       # If we received an OOC message, show it to user in (( this form ))
		       when :ooc_broadcast
		       		puts "printing ooc"
				   nick,msg = msg.split(00.chr)
				   puts nick + ": (( " + msg.chomp + " ))"
			   # If we received an IC message, show it to user
			   when :ic_broadcast
			   	   nick,msg = msg.split(00.chr)
			   	   puts nick + ": " + msg.chomp
			   # Game is starting
			   when :starting
			   		# Separate roster string into array
					roster = msg.split(00.chr)
					# Extract your given role
					role = roster.shift
					# Set the AI up to your role
					setRole(role)
					puts "Your role is: " + role
			   		puts "Roster is #{roster.inspect}"
			   		# Allow your AI to initialize the roster 
			   		@brain.processRoster(roster)
		       else
		       		# Otherwise, we have an action that maps to a lambda expression.
		       		# Args for the function is provided in message from server.
		       		args = msg.split(00.chr).flatten
		       		puts code.call(args)
		       		# We need to set up the brain to process events
		       		# @brain.process(code,args)
		       end
		    }
	    end
	    loop {
	    	command = gets
	    	send("0002",command)
	    }
	end
	
	# Right now we're just working on the Jester class due to the simplicity
	def setRole(role)
		case role
		when "jester"
			puts "JESTER"
			@brain = JesterBrain.new(client: self,name: @nickname)
			@brain.act
			puts "JESTER"
		else
			@brain  = JesterBrain.new(client: self,name: @nickname)
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
