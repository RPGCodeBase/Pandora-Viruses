# ----------------------------------------------------------------------------
require 'constants'
# ----------------------------------------------------------------------------
class Storage
	attr_reader :description, :time, :width, :height, :step

	def initialize(db_dir, descr = nil, width = nil, height = nil)
		@db_dir = db_dir

		if descr.nil? then
			load_header!			
		else
			@description = descr
			@width = width
			@height = height
			t = Time.now
			@time = sprintf("%02d:%02d:%02d", t.hour, t.min, t.sec)
			save_header

			Dir.foreach(@db_dir) { |file|
				File.unlink("#{@db_dir}/#{file}") if file =~ /\.#{HISTORY_EXT}$/
			}
		end		

		@storage = Array.new(@height) {
			Array.new(@width) { nil }
		}
		@backup = Array.new(@height) {
			Array.new(@width) { nil }
		}

		if descr.nil? then
			load_data!(1)
		else
			reset!
		end
	end

	# GET

	def get(i, j) 
		@backup[i][j]
	end
		
	def get_in_range(i, j, range)
		res = []
		(- range .. range).each { |row_around|
			row_idx = row_around + i
			next if row_idx < 0 or row_idx >= @height # check border
			(- range .. range).each { |col_around|
				next if col_around == 0 and row_around == 0 # skip self
				col_idx = col_around + j
				next if col_idx < 0 or col_idx >= @width # check border
				val = @backup[row_idx][col_idx]
				res.push val if val != CELL_FREE
			}
		}
		res
	end

	def each
		@height.times { |i|
			@width.times { |j|
				yield i, j, @backup[i][j]
			}
		}		
	end

	def stat
		res = {}
		@height.times { |i|
			@width.times { |j|
				v = @backup[i][j]
				if res.has_key? v then
					res[v] += 1
				else
					res[v] = 1
				end
			}
		}
		res
	end

	# UPDATE

	def reset!
		@step = 0
		@height.times { |i|
			@width.times { |j|
				@storage[i][j] = CELL_FREE
				@backup[i][j] = CELL_FREE
			}
		}
	end

	def set!(i, j, value)
		@storage[i][j] = value
	end

	def update!
		@height.times { |i|
			@width.times { |j|
				@backup[i][j] = @storage[i][j]
			}
		}
		@step += 1
		save_data(@step)
	end

	def get_next_step_if_exists!
		load_data!(@step + 1) if has_data?(@step + 1)
	end

	def set_step!(step)
		load_data!(step)
	end

	def final_step?
		not has_data?(@step + 1)
	end

	# INSPECT

	def show
		puts "----------------------------------------------------------------------------"
		puts "Step: #{@step}"
		view @backup
	end

	def inspect
		puts "----------------------------------------------------------------------------"
		puts "Step: #{@step}"
		puts "Storage:"
		view @storage
		puts "Backup:"
		view @backup
		nil
	end

private
	DESCRIPTION_FILE = 'index.txt'
	HISTORY_FILE = 'history'
	HISTORY_EXT = 'dat'

	def load_header!
		File.new("#{@db_dir}/#{DESCRIPTION_FILE}", File::RDONLY).each_line { |line|
			line.strip!
			next if line.empty?
			case line
			when /^Description:(.+)$/
				@description = $1.strip
			when /^Time:(.+)$/
				@time = $1.strip
			when /^Width:(.+)$/
				@width = $1.to_i
			when /^Height:(.+)$/
				@height = $1.to_i
			end
		}
		raise "Bad height of data #{@height}" if @height.nil? or @height <= 0
		raise "Bad width of data #{@width}" if @width.nil? or @width <= 0
	end

	def save_header
		index = File.new("#{@db_dir}/#{DESCRIPTION_FILE}", File::TRUNC | File::WRONLY | File::CREAT)
		index.puts "Description: #{@description}"
		index.puts "Time: #{@time}"
		index.puts "Width: #{@width}"
		index.puts "Height: #{@height}"
		index.close
	end

	def save_data(step)
		@db_file = File.new("#{@db_dir}/#{HISTORY_FILE}-#{step}.#{HISTORY_EXT}", File::TRUNC | File::WRONLY | File::CREAT)
		@height.times { |i|
			@width.times { |j|
				@db_file.putc @storage[i][j]
			}
		}		
		@db_file.close
	end

	def load_data!(step)
		@db_file = File.new("#{@db_dir}/#{HISTORY_FILE}-#{step}.#{HISTORY_EXT}", File::RDONLY)
		@height.times { |i|
			@width.times { |j|
				@storage[i][j] = @db_file.getc
				@backup[i][j] = @storage[i][j]
			}
		}		
		@db_file.close
		@step = step
	end

	def has_data?(step)
		begin
			return File.stat("#{@db_dir}/#{HISTORY_FILE}-#{step}.#{HISTORY_EXT}").size == @width * @height
		rescue
			return false
		end
	end

	def view(array)
		@height.times { |i|
			@width.times { |j|
				v = array[i][j]
				case v
				when CELL_FREE then print ' '
				when CELL_GOOD_RANGE then print '+'
				when CELL_VIRUS_RANGE then print 'v'
				when CELL_ANTIBODY_RANGE then print 'a'
				else raise "Unknown cell type #{v} at (#{i},#{j})"
				end
			}
			puts
		}
	end

end
# ----------------------------------------------------------------------------

