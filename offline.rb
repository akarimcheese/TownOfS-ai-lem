require_relative 'brains'

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
    
    def initialize(speed:5)
        @roster = {}
        @state = :starting
        assignRoles
    end
    
    def assignRoles
        puts "Roster:"
        @@names.shuffle!
        15.times do |i|
            role = @@roles[i].sample
            @roster[@@names[i]] = [role]
            puts "#{@@names[i]} is the #{role.to_s}!"
            
            @roster[@@names[i]] << JesterBrain.new(client:self,name:@@names[i])
        end
    end
    
    def send(code,msg)
        puts code
    end
end

OfflineGame.new