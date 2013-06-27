class HomeController < ApplicationController
	def index
		@simulations = Simulation.where(hidden: false)
		@comparisons = Comparison.scoped
	end
end
