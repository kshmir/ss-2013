#= require TweenMax.min
#= require anim

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
                if (data.content)
                    for stat in data.content.stats
                        if (stat.event.event_type == "routing")
                            createAnimation(stat.event.req)
                            anim_fromRouterToDyno(stat.event.req, stat.event.dyno, stat.time  / 5.0 )
                            launch_animation(stat.event.req)
                        else if (stat.event.event_type == "exit")
                            anim_leaveDyno(stat.event.req, stat.event.dyno, stat.time / 5.0 )

simulator.init()
