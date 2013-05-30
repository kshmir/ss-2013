require 'rsruby'

module Simulator
	module Stats
		
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
				@r.pdf("rplot.pdf")
				@r.par(mfrow: [2,@ys.size/2])
				@ys.each { |y| @r.plot(@x,y,{type: "o",pch: 15}) }
				@r.eval_R("dev.off()")
			end
		end
	
	end
end

