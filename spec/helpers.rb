module Helpers
	def init_load_balancer_with algorithm
		Simulator::Strategy::LoadBalancer.with_algorithm algorithm
	end
end
