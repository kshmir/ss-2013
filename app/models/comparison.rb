#coding: utf-8
class Comparison < ActiveRecord::Base
	include Redis::Objects
  attr_accessible :clients, :iterations, :reqs_per_second, :strategies

  attr_accessor :clients_from, :clients_to, :clients_interval, 
  							:reqs_per_second_from, :reqs_per_second_to, :reqs_per_second_interval

  list :simulations, marshal: true
  counter :amount_completed
  counter :amount_total

  value :result_json

  def simulations_list
  	@list ||= simulations.map { |id| Simulation.find(id) }
  end

  after_save :create_strategies

  def create_strategies
  	clients_interval = clients.split(",")
  	iterations_amount = iterations.to_i
  	reqs_per_second_interval = reqs_per_second.split(",")
  	strategies_set = strategies.split(",")

  	if [clients_interval.size, reqs_per_second_interval.size].min > 1
  		raise "No se puede tener más de un dato a comparar"
  	end

  	10.times do
	  	clients_interval.each do |clients_n|
	  		reqs_per_second_interval.each do |reqs_per_second|
	  			strategies_set.each do |strategy|
	  				sim = Simulation.new clients: clients_n, 
	  				                     reqs_per_second: reqs_per_second, 
	  				                     strategy: strategy, 
	  				                     iterations: iterations_amount,
	  				                     hidden: true
	  				sim.save
	  				simulations << sim.id
	  				Resque.enqueue ComparisonWorker, self.id, sim.id
	  				amount_total.increment
	  			end
	  		end
	  	end
  	end
  end

  def results
    result_json ||= simulations_list.map { |sim| 
      {
        strategy: sim.strategy,
        results: sim.results,
        clients: sim.clients,
        reqs_per_second: sim.reqs_per_second
      }
    }.to_json
  end

  def percentage
  	amount_completed.value.to_f / amount_total.value * 100.0
  end
end
