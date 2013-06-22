class HomeController < ApplicationController
	def index
		@simulations = Simulation.scoped
	end
end
