require "selenium-webdriver"


def find_state state_class
	return 'U' if state_class == 'blank'
	return 'F' if state_class == 'bombflagged'
	return 'X' if state_class == 'bombdeath' || state_class == 'bombrevealed'
	return state_class[-1].to_i	
end

module Page
	ROW = 16
	COLUMN = 30

	def Page.initialize
		cap = Selenium::WebDriver::Remote::Capabilities.firefox(:unexpectedAlertBehaviour=>"ignore")
		@driver = Selenium::WebDriver.for :firefox, :desired_capabilities=>cap
		@driver.navigate.to "http://minesweeperonline.com/"
		@elements={}
		@face = @driver.find_element(:id,"face")

		(1..ROW).each do |i|
			(1..COLUMN).each do |j|
				@elements["#{i}_#{j}"] = @driver.find_element(:id, "#{i}_#{j}")
			end
		end
	end

	def Page.read_maze locations
		t=Time.now
		maze={}
		begin
			locations.each do |location|
				x,y=location
				element=@elements["#{x}_#{y}"]
				state_class=element.attribute(:class).split(' ')[1]
				maze[location]=find_state(state_class)
			end
		rescue Selenium::WebDriver::Error::UnhandledAlertError => err
			alert=@driver.switch_to.alert
			alert.send_keys('@1_last_time@')
			alert.accept
		end
		puts Time.now-t
		maze
	end

	def Page.open location
		begin
			x,y=location
			@elements["#{x}_#{y}"].click
		rescue Selenium::WebDriver::Error::UnhandledAlertError => err
			alert=@driver.switch_to.alert
			alert.send_keys('@1_last_time@')
			alert.accept
		end
	end

	def Page.flag location
		x,y=location
		element=@elements["#{x}_#{y}"]
		@driver.action.context_click(element).perform
	end

	def Page.game_over?
		begin
			status = @face.attribute(:class)
			status == 'facedead' || status == 'facewin'  
		rescue Selenium::WebDriver::Error::UnhandledAlertError => err
			alert=@driver.switch_to.alert
			alert.send_keys('@1_last_time@')
			alert.accept
		end
	end

	def Page.start_new_game
		@face.click
	end

	def Page.quit
		@driver.quit
	end
end