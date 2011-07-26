# ----------------------------------------------------------------------------
class Life
	CRITTERS_TO_START_WITH = 1000  # The amount of critters to make if you seed.

	WIDTH = 100
	HEIGHT = 70

	UNIT = 10  # The dimensions of a single critter
	PIXEL_WIDTH = UNIT * WIDTH
	PIXEL_HEIGHT = UNIT * HEIGHT

	CONTROLS_HEIGHT = 50

	@speed = 25
  
	# Iterator for each critter
	def self.each
		WIDTH.times { |x|
			HEIGHT.times { |y|
		        	yield(x,y)
      			}
		}
	end
  
	def self.set_speed(speed_factor)
		if @paused
      			@paused = (speed_factor * 50 + 1).to_i
		else
      			@speed = (speed_factor * 50 + 1).to_i
		end
	end
  
	def self.maybe_update(counter)
		if counter % @speed == 0 && @speed < 100
			GoldenPlain.armageddon_and_resurrection
		end
	end
  
	def self.pause
		if @paused
			@speed = @paused
			@paused = nil
      			GoldenPlain.background_text = nil
		else
			@paused = @speed
			@speed = 100
			GoldenPlain.background_text = "Пауза"
		end
		GoldenPlain.draw
	end
  
	def self.click(button, x, y)
		if button == 1
			if y >= Life::PIXEL_HEIGHT
				ControlPanel.start_slide(x, y)
			end
		end
	end
  
	def self.motion(x,y)
		ControlPanel.maybe_motion(x, y)
	end
  
	def self.release(button,x,y)
		if button == 1
			@clicking = false
			ControlPanel.end_slide 
		end
	end
end

class GoldenPlain
	class << self; attr_accessor :background_text; end
	def self.reset
		@arrays = [Array.new(Life::WIDTH) { Array.new(Life::HEIGHT) { nil } },
				Array.new(Life::WIDTH) { Array.new(Life::HEIGHT) { nil } }]
		@array_now = 0
		@critters = self.fresh_array
		@plain = $app.flow(:margin => 0, :top => 0, :left => 0, :width => Life::PIXEL_WIDTH, :height => Life::PIXEL_HEIGHT + 10) if !@plain
		@plain.clear
		self.draw
		srand Time.now.to_i
	end
  
	def self.fresh_array
		res = @arrays[@array_now]
		@array_now = @array_now == 0? 1: 0
		res
	end
  
	def self.seed_randomly
		reset
		Life::CRITTERS_TO_START_WITH.times {
			x, y = rand(Life::WIDTH), rand(Life::HEIGHT)
			@critters[x][y] = Critter.new(x,y)
		}
		self.draw
	end
  
	def self.draw
		@plain.clear {
			$app.para(@background_text, :stroke => $app.rgb(0.1, 0.1, 0.3), :top => 177, :left => 107, :font => '180px') if @background_text
			Life.each {|x,y| @critters[x][y].draw if @critters[x][y] } 
		}
	end	
  
	def self.has_neighbor?(x, y)
		sum = 0
		(-1..1).each { |x_around|
			(-1..1).each { |y_around|
				test_x, test_y = x + x_around, y + y_around
        			if test_x >= 0 && test_x < Life::WIDTH && test_y >= 0 && test_y < Life::HEIGHT
					unless x_around == 0 && y_around == 0
						sum += 1 if @critters[test_x][test_y]
					end
				end
			}
		}
		sum
	end
  
	def self.alive?(x, y, sum)
		if (sum == 3) || (sum == 2 && @critters[x][y])
			return true
		else
			return false
		end
	end
  
	def self.armageddon_and_resurrection
		afterlife = self.fresh_array
		Life.each { |x, y|
			sum = has_neighbor?(x, y)
			afterlife[x][y] = Critter.new(x,y) if self.alive?(x, y, sum)
		}
		@critters = afterlife
		self.draw
	end
end

class Critter  
	def initialize(x,y)
    		@x, @y = x, y
		@stroke_color = $app.gray(1.0, 0.6)
    		@fill_color = $app.rgb(0.8, 0.2, 0.2, 0.45)
	end
  
	def draw
		$app.stroke(@stroke_color)
		$app.fill(@fill_color)
		$app.oval(@x*Life::UNIT, @y*Life::UNIT, Life::UNIT-1, Life::UNIT-1)
	end
end

class ControlPanel
	def self.setup
		$app.flow({:margin_top => 4, :margin_left => 15, :top => Life::PIXEL_HEIGHT + 10, :left => 0}) {
			$app.nostroke
			$app.fill($app.gray(0.1))
			$app.rect(0, Life::PIXEL_HEIGHT, Life::PIXEL_WIDTH, Life::CONTROLS_HEIGHT)
			$app.button("Очистить", :margin_left => 10) { GoldenPlain.reset }
			$app.button("Новый", :margin_left => 10) { GoldenPlain.seed_randomly }
			$app.button("Пауза", :margin_left => 10) { Life.pause }
		}
		@slider = Slider.new
	end
  
	def self.start_slide(x, y)
		if @slider.contains?(x, y)
			@sliding = true
		end
	end
  
	def self.maybe_motion(x, y)
		if @sliding
			@slider.move_to(x,y) 
			Life.set_speed(@slider.get_percentage)
		end
	end
  
	def self.end_slide
		@sliding = false
	end
end

class Slider
	LEFT_END = 335
	RIGHT_END = 775
	def initialize
		@x, @y, @dimensions = 525, Life::PIXEL_HEIGHT + 19, 15
		$app.fill($app.gray(0.8, 0.7))
		$app.stroke($app.gray(1.0, 0.8))
		$app.strokewidth(3)
		@slider = $app.oval(@x, @y, @dimensions, @dimensions)
		$app.nostroke
		$app.fill($app.gray(0.8, 0.12))
		$app.rect(LEFT_END, @y + 5, RIGHT_END - LEFT_END, 5)
		$app.para("Скорость:", :stroke => $app.gray(0.95), :font => '14px', :left => LEFT_END - 65, :top => @y - 5)
	end
  
	def contains?(x,y)
		return true if (@x..(@x + @dimensions)).include?(x) && (@y..(@y + @dimensions)).include?(@y)
    		return false
	end
  
  	def move_to(x, y)
		if (LEFT_END..RIGHT_END).include?(x)
			@x = x - (@dimensions/2)
			@slider.move(@x, @y)
    		end
	end
  
	def get_percentage
		return 1 - (@x - LEFT_END).to_f / (RIGHT_END - LEFT_END).to_f
	end
end
# ----------------------------------------------------------------------------
Shoes.app({:width => Life::PIXEL_WIDTH,
	:height => Life::PIXEL_HEIGHT + Life::CONTROLS_HEIGHT,
	:resizable => false, :title => "Исследование вируса"}) { 
	$app = self
	background(rgb(0.05, 0.05, 0.2))
	counter = 0
	GoldenPlain.reset
	ControlPanel.setup
  
	animate(30) {
		counter += 1
		Life.maybe_update(counter)
	}
  
	click { |button, x, y|
		Life.click(button, x, y)
	}
  
	motion { |x, y|
		Life.motion(x, y)
	}
  
	release { |button, x, y|
		Life.release(button, x,y)
  	}
}

