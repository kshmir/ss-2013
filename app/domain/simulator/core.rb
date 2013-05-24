module Simulator
	module Core
		def self.simulate strategy
			while not strategy.finished?
				
				# strategy.before_step
				strategy.step
				# strategy.after_step
			end
		end
	end
end