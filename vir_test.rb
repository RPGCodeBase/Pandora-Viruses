#!/usr/bin/ruby

require 'viruses'

v = Viruses.new('VIRUSES')
v.show
#v.nucl_stat
nums = v.numbers

n = 0
adds = [1, 1, 2, 4, 8]
add_idx = 0
max = ('88' * 10).hex
while n <= max
	n = n + adds[add_idx]
	add_idx = (add_idx + 1) % adds.size
	printf("%x\n", n)
end

