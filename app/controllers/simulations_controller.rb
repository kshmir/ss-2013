class SimulationsController < ApplicationController
	def create
		Resque.enqueue SimWorker, 1
		respond_to :js
	end
end
