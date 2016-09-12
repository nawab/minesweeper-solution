class Cell
	def initialize(x,y,state)
		@x=x
		@y=y
		@state=state
	end

	def opened?
		@state != 'U' && @state != 'F' && @state != 'X' && @state != '-'
	end

	def flagged?
		@state == 'F'
	end

	def unopened?
		@state == 'U'
	end

	def unknown?
		@state == '-'
	end

	def state
		@state
	end

	def set_state new_state
		@state = new_state
	end

	def location
		[@x,@y]
	end
end

class Maze
	def initialize(rows,columns)
		@rows=rows
		@columns=columns
		@cells = {}
	end

	def inside? x,y
		x >0 && x<=@rows && y>0 && y<=@columns
	end

	def add_cell cell
		@cells[cell.location] = cell
	end

	def get location
		@cells[location]
	end

	def neighbours cell
		x,y=cell.location
		cells = []
		(x-1..x+1).each do |i|
			(y-1..y+1).each do |j|
				cells << @cells[[i,j]] if inside?(i,j) && !(i==x && j==y)
			end
		end
		cells
	end

	def unopened
		@cells.values.find_all{|cell| cell.unopened?}
	end

	def unknown
		@cells.values.find_all{|cell| cell.unknown?}
	end

	def opened
		@cells.values.find_all{|cell| cell.opened?}
	end

	def rows
		@rows
	end

	def columns
		@columns
	end

	def random_cell
		cells=unopened
		cells[rand(cells.count)-1]
	end
end