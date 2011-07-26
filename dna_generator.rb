#!/usr/bin/ruby

MESS_MARKERS = [
	['TAA','CAG'],
	['TCG','CCA']
]

def mess(len)
	s = Array.new(len).collect { ['A','T','C','G'][rand(4)] }.join('')
end

puts mess(120)


