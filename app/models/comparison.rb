#coding: utf-8
class Array
  def mean
    reduce(0.0,:+) / length
  end

  def standard_deviation 
    m = mean
    m2 = (map { |x| (x-m)**2.0 }).mean
    m2 ** 0.5
  end
end




class Comparison < ActiveRecord::Base
	include Redis::Objects
  attr_accessible :clients, :iterations, :reqs_per_second, :strategies, :amount_of_tests

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

    (amount_of_tests || 10).times do
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

  def join_strategy array
    by_criteria = array.sort { |x,y| 
      x[criteria.to_sym] <=> y[criteria.to_sym]
    }.reduce({}) { |set, data|
      hash = set[data[criteria.to_sym]] ||= {}
      hash[:clients] = data[:clients]
      hash[:reqs_per_second] = data[:reqs_per_second]
      hash[:strategy] = data[:strategy]
      hash[:results] ||= []
      hash[:results] << data[:results]
      set
    }

    by_criteria.values.map { |val|
      old = val[:results]
      val[:results] = {}
      val[:results][:mean_queue_length] = old.map { |x| x.value[:mean_queue_length] }.mean
      val[:results][:std_dev_queue_length] = old.map { |x| x.value[:mean_queue_length] }.standard_deviation
      val[:results][:mean_idle_time] = old.map { |x| x.value[:mean_idle_time] }.mean
      val[:results][:std_dev_idle_time] = old.map { |x| x.value[:mean_idle_time] }.standard_deviation
      val[:results][:mean_duration] = old.map { |x| x.value[:mean_duration] }.mean
      val[:results][:std_dev_duration] = old.map { |x| x.value[:mean_duration] }.standard_deviation
      val[:results][:mean_rejected] = old.map { |x| x.value[:rejected] }.mean
      val[:results][:std_dev_rejected] = old.map { |x| x.value[:rejected] }.standard_deviation
    }

    by_criteria.values.flatten
  end

  def results
    unless result_json.value
      strats = simulations_list.map { |sim| 
        {
          strategy: sim.strategy,
          results: sim.results,
          clients: sim.clients,
          reqs_per_second: sim.reqs_per_second
        }
      }.reduce({}) { |set, data| 
        set[data[:strategy]] ||= [] 
        set[data[:strategy]] << data
        set
      }
      res = strats.map do |key, value|
        join_strategy value
      end.flatten
      result_json = res.to_json
    else
      result_json
    end
  end


  def percentage
  	amount_completed.value.to_f / amount_total.value * 100.0
  end

  def criteria 
    (clients.split(",").size > 1) ? 'clients' : 'reqs_per_second'
  end 
end
