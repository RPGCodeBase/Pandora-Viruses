#!/usr/bin/ruby

require 'storage'
require 'gnuplot'

exit if ARGV.size != 1

s = Storage.new(ARGV[0])

Gnuplot.open { |gp|
	Gnuplot::Plot.new(gp) { |plot|
  		plot.title  "#{ARGV[0]} statistics"
    		plot.ylabel "Bacteria count"
		plot.xlabel "Time"
		    
		t = []
		vs = []
		ls = []
		as = []

		begin
			t.push s.step
			print '.'; STDOUT.flush
			vsc = 0
			lsc = 0
			asc = 0
			
			stat = s.stat
			stat.each_key { |key|
				case key
				when CELL_GOOD_RANGE then lsc += stat[key]
				when CELL_VIRUS_RANGE then vsc += stat[key]
				when CELL_ANTIBODY_RANGE then asc += stat[key]
				end
			}

			vs.push vsc
			as.push asc
			ls.push lsc
			s.get_next_step_if_exists!
		end while not s.final_step?

		plot.data = [
			Gnuplot::DataSet.new( [t, ls] ) { |ds|
				ds.with = "linespoints"
				ds.title = "Life forms"
				ds.linecolor = "2"
			},
			Gnuplot::DataSet.new( [t, vs] ) { |ds|
				ds.with = "linespoints"
				ds.title = "Viruses"
				ds.linecolor = "1"
			},
			Gnuplot::DataSet.new( [t, as] ) { |ds|
				ds.with = "linespoints"
				ds.title = "Antibodies"
				ds.linecolor = "6"
			}
		]
	}
}
puts

