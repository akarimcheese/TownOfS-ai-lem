require_relative 'brains'
require_relative 'client'


class OfflineGame
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
		        
    @@names = ["Alfred","Ahmed","Barack","Chao","Thomas","Kendra","Patrick",
                "Atticus","Brittany","Minnesota","Lisa","Donald","Vince",
                "Oscar","Rascal"]
    
    def initialize()
        @roster = {}
        @state = :starting
        @events = []
        assignRoles
        startGame
    end
    
    def assignRoles
        puts "Roster:"
        @@names.shuffle!
        15.times do |i|
            role = @@roles[i].sample
            @roster[@@names[i]] = {:role => role}
            puts "#{@@names[i]} is the #{role.to_s}!"
            
            @roster[@@names[i]][:brain] = DumbBrain.new(client:self,name:@@names[i],role:role)
            @roster[@@names[i]][:state] = :alive
            @roster[@@names[i]][:brain].processRoster(@@names)
        end
    end
    
    
    
    def send(code,msg)
        puts "\t#{CODE[code].call(["",msg])}"
        @roster.each do |player,info|
            # info[1].process(code,msg)
        end
    end
    
    def startGame
        puts "\n\n\n\n\nGame is starting!"
        
        sleep(0.1)
        
        puts "\n\n\n\n\n"
        
        @roster.each do |player,info|
            puts "#{player} is acting"
            info[:brain].act
            sleep(0.1)
        end
        
        puts "\n\n\n\n\nNight is starting!"
        
        sleep(0.1)
        
        puts "\n\n\n\n\n"
        
        @roster.each do |player,info|
            puts "#{player} is acting"
            info[:brain].turnsNight
            if info[:state] == :alive
                info[:brain].act
            else
            end
        end
    end
    
    
                
    private :assignRoles, :startGame
end

OfflineGame.new