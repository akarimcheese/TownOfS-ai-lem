require_relative 'client.rb'

# The class that will be used when the client is chosen to be a Jester
class JesterBrain
	# Initialize with the client and nickname chosen
	def initialize(client: nil,name: nil, role: :jester)
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

# Filler AI
class DumbBrain
	# Initialize with the client and nickname chosen
	def initialize(client: nil,name: nil, role: nil)
	    @role = role
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
		
		@canSaveSelf = true
		@firstNight = true
		@veteranUses = 3
	end
	
	# Once given the roster of players, make a hash entry for each player
	def processRoster(roster)
		roster.each {|player|
			@players[player] = {:guess => nil, :trust => 0.5, :state => :alive} unless player == @name
		}
	end
	
	def act
		case @gameState
		when :starting
		    case @role
		    when :jailor
		        randomPlayer
		    else
		    end
		when :night
		    case @role
		    when :sheriff
		        @client.send(ACTIONS[:roleAct][:sheriff][:investigate],randomPlayer)
		    when :doctor
		        if @canSaveSelf && Random.rand(100) > 75 
		            @client.send(ACTIONS[:roleAct][:doctor][:heal][:self],"")
		            @canSaveSelf = false
		        else
		            @client.send(ACTIONS[:roleAct][:doctor][:heal][:other],randomPlayer)
		        end
		    when :investigator
		        @client.send(ACTIONS[:roleAct][:investigator][:investigate],randomPlayer)
		    when :jailor
		        # Low priority
		    when :medium
		        # Low priority
		    when :godfather
		        if Random.rand(100) > 50 then
		            @client.send(ACTIONS[:roleAct][:godfather][:plot],randomPlayer)
		        end
		    when :framer
		        @client.send(ACTIONS[:roleAct][:framer][:frame],randomPlayer)
		    when :executioner
		        # No action
		    when :escort
		        @client.send(ACTIONS[:roleAct][:escort][:block],randomPlayer)
		    when :mafioso
		        @client.send(ACTIONS[:roleAct][:mafioso][:plot],randomPlayer)
		    when :lookout
		        @client.send(ACTIONS[:roleAct][:lookout][:monitor],randomPlayer)
		    when :serialkiller
		    when :veteran
		        if @veteranUses > 0 && Random.rand(100) > 45 then
		            @client.send(ACTIONS[:roleAct][:veteran][:alert],"")
		            @veteranUses = @veteranUses - 1
		        end
		    when :vigilante
		    when :jester
		        # No action UNLESS TAKING REVENGE
		    when :bodyguard
		        if @canSaveSelf && Random.rand(100) > 75 
		            @client.send(ACTIONS[:roleAct][:bodyguard][:protect][:self],"")
		            @canSaveSelf = false
		        else
		            @client.send(ACTIONS[:roleAct][:bodyguard][:protect][:other],randomPlayer)
		        end
		    when :mayor
		        # No action
		    when :retributionist
		        # Low priority
		    when :spy
		        # Low priority
		    when :transporter
		    end
		    @firstNight = false
		when :day
		end
	end
	
	def randomPlayer
	    player = @players.keys.select {|x| @players[x][:state] == :alive}.sample
	end
	
	# We choose someone to vote for execution
	def vote
		randomPlayer
	end
	
	def turnsNight
		@gameState = :night
	end
end