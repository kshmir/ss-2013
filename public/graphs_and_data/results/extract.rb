%w(RandomRouting RoundRobinRouting ShortestQueueRouting SmartRouting).each do |algo| 
	f = File.new("/home/lutinbleu/#{algo}.plot","w")
	(30..70).to_a.each do |v|
		data = {};
		[:mean_idle_time, :mean_duration].each do |mes|
			data[mes] = final_results.map { |tab| tab[v]["Simulator::Strategy::Algorithm::#{algo}"][mes] };
		end
		f << "#{v}    #{data[:mean_idle_time].mean}   #{data[:mean_idle_time].standard_deviation}    #{data[:mean_duration].mean}    #{data[:mean_duration].standard_deviation}\n";
	end
	f.close;
end


