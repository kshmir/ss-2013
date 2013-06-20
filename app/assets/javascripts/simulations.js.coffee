#= require TweenMax.min
#= require anim

#=require jquery
#=require jquery-ui

control =
    init: ()->
	$("#speed_slider").slider 
        min: 0.01
        max: 2
        step: 0.001
        slide: (event, ui)->
            if (ui.value > 0)
                document.global_timeline.timeScale(ui.value)
    $("#timeline_slider").slider 
        min: 0
        max: 100
        step: 0.1
        slide: (event, ui)->
            document.global_timeline.progress(ui.value / 100.0)
	$("#start_btn").on "click", ()->
	    document.global_timeline.resume()
	$("#pause_btn").on "click", ()->
	    document.global_timeline.pause()


simulator = 
    init: ()->
        percentage = simulator.percentage = $(".js-simulation").data("percentage") 
        if (parseInt(percentage) <= 100.0)
            simulator.ui.status_updater()
        else
            simulator.ui.toggle_screen()
    ui: 
        status_updater: ()->
            id = $(".js-simulation").attr "data-id"
            $.getJSON("/simulations/#{id}.json",(data)->
                $(".js-simulation").removeClass("hidden")
                
                simulator.percentage = perc = data.percentage
                $(".bar").css("width", "#{perc}%")
                if (parseInt(perc) < 100.0)
                    setTimeout(simulator.ui.status_updater,100)
                else
                    simulator.ui.toggle_screen()
            )
        toggle_screen: ()->
            $(".js-simview").removeClass("hidden")    
            $(".js-simulation").addClass("hidden")  
            simulator.ui.animation()


        animation: ()->
            id = $(".js-simulation").attr "data-id"
            $.getJSON "/simulations/#{id}.json",(data)->
                anims = {}
                if (data.stats)
                    for stat in data.stats
                        if (stat.event.event_type == "routing")
                            anims[stat.event.req] = {}
                            anims[stat.event.req].dyno = stat.event.dyno;
                            anims[stat.event.req].start_time = stat.time / 100;
                        else if (stat.event.event_type == "exit")
                            anims[stat.event.req].end_time = stat.time / 100;
                            anims[stat.event.req].total_time = anims[stat.event.req].end_time - anims[stat.event.req].start_time;
                    for req, event of anims
                        createAnimation(req)
                        anim_fromRouterToDyno(req, event.dyno, event.start_time, event.total_time)
                        anim_leaveDyno(req, event.dyno)       

simulator.init()
control.init()
