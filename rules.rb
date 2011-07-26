# ----------------------------------------------------------------------------
require 'constants'
# ----------------------------------------------------------------------------
class Rules
	RANGE = 1
	
	def Rules.new_born(alive, good, viruses, antibodies)
		if alive == 3 or alive == 5 or alive == 7 then
			if viruses.size == 1 && rand < 0.4 then
				CELL_ANTIBODY_START			
			elsif viruses.size >= 1 && rand < 0.5 then
				CELL_LIFE_VIRUS_START
			else
				CELL_LIFE_BORN
			end
		else
			CELL_FREE
		end
	end
	
	def Rules.time_to_dead(value)
		if CELL_GOOD_RANGE.include? value then
			value == LIFE_MAX_AGE
		elsif value >= CELL_LIFE_VIRUS_START and value < CELL_LIFE_VIRUS_START + 10
			false
		elsif value == CELL_ANTIBODY_START
			true
		else
			true
		end
	end

	def Rules.dead_from_suffocation(value, alive)
		alive < 4 or alive > 7
	end

	def Rules.got_virus(value, viruses, antibodies)
		if viruses.size > 2 && rand < 0.8 then
			CELL_LIFE_VIRUS_START
		else
			nil
		end
	end

	def Rules.virus_is_killed(value, viruses, antibodies)
		if antibodies.size >= 1 then
			CELL_FREE
		else
			nil
		end
	end	
end	
# ----------------------------------------------------------------------------
