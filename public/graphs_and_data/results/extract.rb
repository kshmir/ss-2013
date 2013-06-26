%w(RandomRouting RoundRobinRouting ShortestQueueRouting SmartRouting).each do |algo| 
	f = File.new("/home/lutinbleu/prg/current/ss-2013/public/graphs_and_data/results/#{algo}.plot","w")
	(30..70).to_a.each do |v|
		data = {};
		[:mean_idle_time, :std_dev_idle_time, :mean_duration, :std_dev_duration ].each do |mes|
			data[mes] = final_results.map { |tab| tab[v]["Simulator::Strategy::Algorithm::#{algo}"][mes] };
		end
		f << "#{v}    #{data[:mean_idle_time].mean}   #{data[:mean_idle_time].standard_deviation}    #{data[:std_dev_idle_time].mean}   #{data[:std_dev_idle_time].standard_deviation}    #{data[:mean_duration].mean}    #{data[:mean_duration].standard_deviation}    #{data[:std_dev_duration].mean}   #{data[:std_dev_duration].standard_deviation}\n";
	end
	f.close;
end


