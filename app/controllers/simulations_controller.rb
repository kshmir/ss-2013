class SimulationsController < ApplicationController
	def create
		@sim = Simulation.new params[:simulation]
		@sim.percentage = 0.0
		@sim.save

		Resque.enqueue SimWorker, @sim.id
		respond_to :js
	end

	def show
		@sim = Simulation.find(params[:id])
		respond_to do |f|
			f.html
			f.json {
				render :text => @sim.to_json(methods: :stats)
			}
		end
	end
end
