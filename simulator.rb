# ----------------------------------------------------------------------------
require 'constants'
require 'storage'
require 'rules'
# ----------------------------------------------------------------------------
class Simulator
	def initialize(dir, name, width, height, density)
		@storage = Storage.new(dir, name, width, height)
		random_life(density)
	end

	def snapshot
		@storage.show
	end

	def do_step
		@storage.each { |i, j, value|
			neighbors = @storage.get_in_range(i, j, Rules::RANGE)

			alive = 0 
			good = 0
			viruses = []
			antibodies = []

			neighbors.each { |x|
				case x
				when CELL_GOOD_RANGE then good += 1
				when CELL_VIRUS_RANGE then viruses.push x
				when CELL_ANTIBODY_RANGE then antibodies.push x
				else raise "Unknown cell type #{x} near (#{i},#{j})"
				end
			}

			alive = good + viruses.size

			case value
			when CELL_FREE
				new = Rules::new_born(alive, good, viruses, antibodies)
				@storage.set!(i, j, new) if new != CELL_FREE
			when CELL_GOOD_RANGE
				if Rules::time_to_dead(value) or Rules::dead_from_suffocation(value, alive) then
					@storage.set!(i, j, CELL_FREE)
				else
					res = Rules::got_virus(value, viruses, antibodies)
					if res.nil? then
						@storage.set!(i, j, value + 1)
					else
						@storage.set!(i, j, res) 
					end
				end
			when CELL_VIRUS_RANGE
				if Rules::time_to_dead(value) or Rules::dead_from_suffocation(value, alive) then
					@storage.set!(i, j, CELL_FREE)
				else
					res = Rules::virus_is_killed(value, viruses, antibodies)				
					if res.nil? then
						@storage.set!(i, j, value + 1)
					else
						@storage.set!(i, j, res) 
					end
				end
			when CELL_ANTIBODY_RANGE
				@storage.set!(i, j, CELL_FREE)
			else raise "Unknown cell type #{value} at (#{i},#{j})"
			end
		}
		@storage.update!
	end
private
	def random_life(density)
		@storage.each { |i, j, value|
			@storage.set!(i, j, CELL_LIFE_BORN) if rand < density
			@storage.set!(i, j, CELL_LIFE_VIRUS_START) if rand < 0.02
		}			
	end
end
# ----------------------------------------------------------------------------
