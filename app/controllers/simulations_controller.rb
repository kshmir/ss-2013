class SimulationsController < ApplicationController
	def create
		@sim = Simulation.new params[:simulation]
		@sim.percentage = 0.0
		@sim.save

		Resque.enqueue SimWorker, @sim.id
		respond_to :js
	end

	def destroy
		@sim = Simulation.find(params[:id])
		@sim.delete
	end

	def show
		@sim = Simulation.find(params[:id])
		respond_to do |f|
			f.html
			f.json {
				unless params[:status]
					render :text => @sim.to_json(methods: :stats)
				else
					render :text => @sim.to_json
				end
			}
		end
	end
end
