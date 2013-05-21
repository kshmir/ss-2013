module Simulator
	module Core
		def simulate strategy
			strategy.verify!
			strategy.init!
			while not strategy.finished?
				
				# strategy.before_step
				strategy.step
				# strategy.after_step
			end
		end
	end
end