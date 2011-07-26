# ----------------------------------------------------------------------------
class Viruses
	def initialize(file)
		@a = []
		File.new(file).each_line { |l|
			l.strip!
			next if l.empty?
			next if l =~ /^\#/
			parts = l.split(':')

#			parts[2].gsub!('xxx','AGG')
#			parts[2].gsub!('yyy','CTG')
			parts[2].gsub!(/(xxx[^y]+yyy)/) { |m|
				'x' * $1.size
			}

			@a.push({:name => parts[0], :data => parts[2]})
		}
	end

	def nucl_stat
		t = {}
		@a.each { |vir|
			val = vir[:data]
			(val.size / 3).times { |i|
				triplet = val[i * 3, 3]
				if t.has_key? triplet then
					t[triplet] += 1
				else
					t[triplet] = 1
				end
			}
		}

		t.keys.sort.each { |k|
			puts "#{k} #{t[k]}"
		}
	end

	def convert(s)
		s.split(//).collect { |chr|
			case chr
			when 'A' then 1
			when 'C' then 2
			when 'G' then 4
			when 'T' then 8
			else
				0
			end
		}
	end

	def show
		@a.each { |p|
			puts "#{p[:name]} #{p[:data]}"
		}
	end

	def numbers
		@a.collect { |p|
			num = convert(p[:data]).join('')
			num.gsub!(/^0+/,'')
			num.gsub!(/0+$/,'')
			num.hex
		}
	end
end
# ----------------------------------------------------------------------------

