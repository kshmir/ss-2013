#= require TweenMax.min
#= require anim

simulator = 
	init: ()->
		percentage = simulator.percentage = $(".js-simulation").data("percentage")		
		if (parseInt(percentage) < 100.0)
			simulator.ui.status_updater()
		else
			simulator.ui.toggle_screen()
	on_toggle_screen: ()->
		id = $(".js-simulation").attr "data-id"
		$.getJSON "/simulations/#{id}.json",(data)->
			sim = data
			rows = sim.content.stats
			data = _.map rows, (row)-> row.queue_size[0]
			i = 0
			data = _.map data, (item)-> { t: (i++), value: item }
			new Morris.Line
			  element: 'myfirstchart'
			  data: data
			  xkey: 't'
			  ykeys: ['value']
			  labels: ['Value']
			
	ui: 
		status_updater: ()->
			id = $(".js-simulation").attr "data-id"
			$.getJSON("/simulations/#{id}.json",(data)->
				$(".js-simulation").removeClass("hidden")
				if data.content
				    createAnimation(dyno) for dyno in data.content.current_clients
				simulator.percentage = perc = data.percentage
				$(".bar").css("width", "#{perc}%")
				if (parseInt(perc) < 100.0)
					setTimeout(simulator.ui.status_updater,500)
				else
					simulator.ui.toggle_screen()

			)
		toggle_screen: ()->
			$(".js-simview").removeClass("hidden")	
			$(".js-simulation").addClass("hidden")		
			simulator.on_toggle_screen()

simulator.init()
