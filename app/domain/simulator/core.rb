module Simulator
	module Core
		def self.simulate strategy, &block
			while not strategy.finished?
				# strategy.before_step
				strategy.step &block
				# strategy.after_step
			end
		  stats =	strategy.terminate
		end
	end
end
