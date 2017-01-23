require_relative 'client.rb'

# The class that will be used when the client is chosen to be a Jester
class JesterBrain
	# Initialize with the client and nickname chosen
	def initialize(client: nil,name: nil)
		# The night number
		@night = 1
		# What state the game is
		@gameState = :starting
		# A hash of players and information/opinions about them
		@players = {}
		# A log of events that have occured in the game
		@eventLog = []
		# The client to send messages from
		@client = client
		# The state of the current player
		@state = :alive
		# Current player's name
		@name = name
		# People the jester can choose from to kill from the afterlife
		@victims = nil
	end
	
	# Once given the roster of players, make a hash entry for each player
	def processRoster(roster)
		roster.each {|player|
			@players[player] = {:guess => nil, :trust => 0.5, :state => :alive} unless player == @ame
		}
	end
	
	def act
		case @gameState
		when :starting
		    @client.send(ACTIONS[:claim][:self][:role][:jester],"")
		when :night
			if @state == :revenge
				# kill someone who voted against you
				# @victims.sample
				@state = :dead
			end
		when :day
		end
	end
	
	# If we are voted to be executed, we will have a chance to kill one of the people who voted against us
	def executed (victims)
		@victims = victims
		@state = :revenge
	end
	
	# We choose someone to vote for execution
	def vote
		@players.keys.select {|x| @players[x][:state] == :alive}.sample
	end
	
	def turnsNight
		@gameState = :night
	end
end