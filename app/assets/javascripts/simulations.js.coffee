simulator = 
	init: ()->
		percentage = simulator.percentage = $(".js-simulation").data("percentage")		
		if (parseInt(percentage) < 100.0)
			simulator.ui.status_updater()
		else
			simulator.ui.toggle_screen()
	ui: 
		status_updater:  ()->
			id = $(".js-simulation").attr "data-id"
			$.getJSON("/simulations/#{id}.json",(data)->
				$(".js-simulation").removeClass("hidden")
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

simulator.init()