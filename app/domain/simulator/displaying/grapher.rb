require 'rsruby'

module Simulator
	module Displaying
		
		class Grapher

			attr_accessor :data
			def initialize n, titles, options = {}
				@x = []
				@ys = (1..n).map { [] } 
				@titles = titles
				@options = options
				@r = RSRuby.instance
			end

			def add x,ys
				@x << x
				(0..@ys.size-1).map { |i| @ys[i] << ys[i] }
			end

			def plot
				@r.par(mfrow: [1,@ys.size])
				@ys.each { |y| @r.plot(@x,y,{type: "o",pch: 15}) }
				sleep(2)
			end
		end
	
	end
end

