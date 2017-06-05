$LOAD_PATH << '.'

require 'page'
require 'domain'
require 'set'

def print maze
	(1..maze.rows).each do |i|
		puts (1..maze.columns).map{|j| maze.get(i,j).state}.join(' ')
	end
end

def create_maze
	maze = Maze.new(Page::ROW, Page::COLUMN)
	locations=(1..Page::ROW).inject([]){|a,i| a + ([i]*Page::COLUMN).zip((1..Page::COLUMN).map{|j|j})}
	locations.each{|l| maze.add_cell(Cell.new(l[0],l[1],'U'))}
	maze
end

def to_flag_simple maze 
	return Set.new
	(Set.new).tap do |cells|
		maze.opened.map do |cell|
			neighbours = maze.neighbours(cell)
			flags_count = neighbours.count{|c| c.flagged?}
			unopened = neighbours.find_all{|c| c.unopened?}
			cells.merge(unopened) if cell.state - flags_count == unopened.count
		end
	end
end

def ai_brain a,b
	cells = {:to_flag => Set.new, :to_open => Set.new}	
	rest = b[:blocks]-a[:blocks]
	intersection = b[:blocks] - rest
	left = a[:blocks]-intersection
	return cells if intersection.empty?
	min_bombs = b[:bombs] - [a[:bombs], intersection.size].min
	max_bombs = b[:bombs] - [a[:bombs]-left.size,0].max
	cells[:to_flag]= rest if rest.count == min_bombs
	cells[:to_open]= rest if max_bombs == 0	
	cells
end

def ai maze 
	cells = {:to_flag => Set.new, :to_open => Set.new}	
	blocks = []
	maze.opened.each do |cell|
		neighbours=maze.neighbours(cell)
		flags_count = neighbours.count{|c| c.flagged?}
		unopened = neighbours.find_all{|c| c.unopened?}
		blocks << {:bombs => cell.state-flags_count, :blocks => unopened} if cell.state!=flags_count		
		cells[:to_flag].merge(unopened) if unopened.count == cell.state - flags_count
	end
	blocks.sort_by!{|b| b[:bombs]}

	(0..blocks.size-1).each do |i|
		(i+1..blocks.size-1).each do |j|
			a,b=blocks[i],blocks[j]
			temp1=ai_brain(a,b)
			temp2=ai_brain(b,a)
			cells[:to_flag].merge(temp1[:to_flag]).merge(temp2[:to_flag])
			cells[:to_open].merge(temp1[:to_open]).merge(temp2[:to_open])
		end
	end
	cells
end

def to_open_simple maze 
	(Set.new).tap do |cells|
		maze.opened.map do |cell|
			neighbours = maze.neighbours(cell)
			flags_count = neighbours.count{|c| c.flagged?}
			unopened = neighbours.find_all{|c| c.unopened?}
			cells.merge(unopened) if cell.state == flags_count
		end
	end
end

def solve maze
	while true do
		if Page.game_over?
			maze=create_maze
			puts '\n\n!!!New Game!!!\n'
			Page.start_new_game			
		end

		Page.read_maze((maze.unopened+maze.unknown).reject{|c| maze.neighbours(c).all?{|n| n.unopened? }}.map(&:location)).each{|k,v| maze.get(k).set_state(v)}

		cells = {:to_flag => Set.new, :to_open => Set.new}	
	
		while true
			temp_cells = ai(maze)
			temp_cells[:to_flag].each{|cell| cell.set_state('F')}
			temp_cells[:to_open].merge(to_open_simple(maze))
			break if temp_cells[:to_flag].empty? && temp_cells[:to_open].empty?
			cells[:to_flag].merge(temp_cells[:to_flag])
			cells[:to_open].merge(temp_cells[:to_open])
			temp_cells[:to_open].each{|cell| cell.set_state('-')}
		end

		if cells[:to_flag].empty? && cells[:to_open].empty?
			cell = maze.random_cell
			if cell
			 	puts "random"
			 	cell.set_state('-')
			 	Page.open(cell.location) 
			end
		else
		 	puts "calculated"
		end

		cells[:to_flag].each{|cell| Page.flag(cell.location)}
		cells[:to_open].each{|cell| Page.open(cell.location)}
	end
end

Page.initialize

solve(create_maze)

Page.quit