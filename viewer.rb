# ----------------------------------------------------------------------------
require 'storage'
# ----------------------------------------------------------------------------
CONTROLS_HEIGHT = 50
# ----------------------------------------------------------------------------
class LifeView
	UNIT = 12  # The dimensions of a single critter

	def initialize(app)
		@paused = false
		@app = app
		
		@pixel_width = $storage.width * UNIT
		@pixel_height = $storage.height * UNIT
		
		@max_speed = 1
		@speed = 1
		@paused = false

		@background_text = nil
		@plain = @app.flow(:margin => 0, :top => 0, :left => 0,
				:width => @pixel_width, :height => @pixel_height + 10)
		@app.flow({:margin_top => 4, :margin_left => 15, :top => @pixel_height + 10, :left => 0}) {
			@pause_button = @app.button('Пауза')
			@pause_button.click { pause }
			@step_view = @app.para "Шаг: 1", :stroke => @app.white
		}

		draw

		counter = 0
		@app.animate(@max_speed) {
			counter += 1
			maybe_update(counter)
		}
	end

	def pause
		if @paused then
			@background_text = nil 
		else
			@background_text = "Пауза"
		end
		@paused = !@paused
		draw
	end

private
	def draw
		@plain.clear {
			@app.para(@background_text, :stroke => @app.rgb(0.1, 0.1, 0.3), :top => 177, :left => 107, :font => '180px') if @background_text

			stroke_color = @app.gray(1.0, 0.6)
			@app.stroke(stroke_color)

			$storage.each {|x, y, value|
				next if value == CELL_FREE
				@app.fill(color_by_value(value))
				@app.oval(y * UNIT, x * UNIT, UNIT - 1, UNIT - 1)
			} 
		}

	end	

	def maybe_update(counter)
		reload if counter % @speed == 0 && !@paused
	end

	def reload
		$storage.get_next_step_if_exists!
		draw
		@step_view.text = "Шаг: #{$storage.step}"
	end

	def color_by_value(v)
		case v
		when CELL_GOOD_RANGE then @app.rgb(0.2, 0.2 + 0.8 * (1.0 - v.to_f / LIFE_MAX_AGE.to_f), 0.2, 0.6)
		when CELL_VIRUS_RANGE then @app.rgb(0.8, 0.2, 0.2, 0.6)
		when CELL_ANTIBODY_RANGE then @app.rgb(0.8, 0.8, 0.2, 0.6)
		else	
			@app.white
		end
	end
end
# ----------------------------------------------------------------------------
dir = ask_open_folder
$storage = Storage.new(dir)

Shoes.app({:resizable => false,
	:title => "Просмотр результатов эксперимента '#{$storage.description}', начало: #{$storage.time}",
	:width => $storage.width * LifeView::UNIT,
	:height => $storage.height * LifeView::UNIT + CONTROLS_HEIGHT}) { 

	background(rgb(0.05, 0.05, 0.2))
	begin
		LifeView.new(self)
	rescue Exception => e
		puts e
		puts e.backtrace.join("\n")
	end
}
