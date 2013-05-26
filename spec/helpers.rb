module Helpers
	def init_load_balancer_with algorithm, params
		Simulator::Strategy::LoadBalancer.with_algorithm algorithm, params
	end
end
