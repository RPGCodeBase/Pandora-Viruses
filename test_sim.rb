#!/usr/bin/ruby

require 'simulator'

srand Time.now.to_i
s = Simulator.new('virus-2-data', 'Virus + ACT1 test', 80, 50, 0.3)

200.times { |i|
	s.snapshot
	s.do_step
}
puts
