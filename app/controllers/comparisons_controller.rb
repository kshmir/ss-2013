class ComparisonsController < ApplicationController
	def create
		clients_interval = (params[:comparison][:clients_from].to_i..params[:comparison][:clients_to].to_i).step(params[:comparison][:clients_interval].to_i).to_a
		reqs_interval = (params[:comparison][:reqs_per_second_from].to_i..params[:comparison][:reqs_per_second_to].to_i).step(params[:comparison][:reqs_per_second_interval].to_i).to_a
		strats = params[:comparison][:strategies].select { |x| !x.empty? }
		iters = params[:comparison][:iterations].to_i

		unless [clients_interval.size, reqs_interval.size].min > 1
			@comp = Comparison.new iterations: iters, reqs_per_second: reqs_interval.join(","),
													 clients: clients_interval.join(","),
													 strategies: strats.join(","),
													 amount_of_tests: params[:comparison][:amount_of_tests]
			@comp.save	
		end
		respond_to :js
	end

	def destroy
		@comparison = Comparison.find(params[:id])
		@comparison.simulations_list.each do |sim| sim.delete end
		@comparison.delete
	end

	def show
		@comp = Comparison.find(params[:id])
		@simulations = @comp.simulations_list unless params[:status] or params[:format] == "json"
		respond_to do |f|
			f.html
			f.json {
				unless params[:status]
					render :text => { results: @comp.results, criteria: @comp.criteria }.to_json
				else
					render :text => { percentage: @comp.percentage, total: @comp.amount_total.value, amount: @comp.amount_completed.value }.to_json
				end
			}
		end
	end
end
