#= require TweenMax.min
#= require anim

#=require jquery
#=require jquery-ui

control =
    init: ()->
        $(".js-1-times").on "click", ()->
            global_timeline.timeScale(1)
        $(".js-20-times").on "click", ()->
            global_timeline.timeScale(1 * 20)
        $(".js-100-times").on "click", ()->
            global_timeline.timeScale(1 * 100)
        $(".js-1000-times").on "click", ()->
            global_timeline.timeScale(1 * 1000)
        $("#start_btn").on "click", ()->
            global_timeline.resume()
        $("#pause_btn").on "click", ()->
            global_timeline.pause()

        $time = $(".js-time")
        setInterval(()->
            if (global_timeline)
                $time.text((global_timeline.time() / 1000).toFixed(3) + "s")
        , 10)


landing =
    init: ()->
        $(".js-simulation-toggle").on "click", ()->
            $(this).slideUp "slow", ()->
                $(".simulation-form").hide()
                $(".simulation-form").removeClass "hidden"
                $(".simulation-form").slideDown "slow"


simulator =
    init: ()->
        $(".anim-loading").removeClass("hidden")
        percentage = simulator.percentage = $(".js-simulation").data("percentage")
        if (parseInt(percentage) < 100.0)
            simulator.ui.status_updater()
        else
            simulator.ui.toggle_screen()
    ui:
        status_updater: ()->
            id = $(".js-simulation").attr "data-id"
            if id
                $.getJSON "/simulations/#{id}.json?status=true",(data)->
                    $(".js-simulation").removeClass("hidden")

                    simulator.percentage = perc = data.percentage
                    $(".bar").css("width", "#{perc}%")
                    if (parseInt(perc) < 100.0)
                        setTimeout(simulator.ui.status_updater,100)
                    else
                        simulator.ui.toggle_screen()
        toggle_screen: ()->
            $(".js-simulation").addClass("hidden")
            simulator.ui.animation()


        animation: ()->
            id = $(".js-simulation").attr "data-id"
            if id
                $.getJSON "/simulations/#{id}.json",(data)->
                    $(".anim-loading").addClass("hidden")
                    $(".js-simview").removeClass("hidden")
                    setup(parseInt($(".js-simulation").data("clients")))
                    anims = {}
                    if (data.stats)
                        for stat in data.stats
                            if (stat.event.event_type == "routing")
                                anims[stat.event.req] = {}
                                anims[stat.event.req].dyno = stat.event.dyno;
                                anims[stat.event.req].start_time = stat.time;
                            else if (stat.event.event_type == "exit")
                                anims[stat.event.req].end_time = stat.time;
                                anims[stat.event.req].total_time = anims[stat.event.req].end_time - anims[stat.event.req].start_time;
                            else if (stat.event.event_type == "rejection")
                                anims[stat.event.req] = {}
                                anims[stat.event.req].start_time = stat.time;
                        for req, event of anims
                            createAnimation(req)
                            if event.dyno != undefined
                                anim_fromRouterToDyno(req, event.dyno, event.start_time, event.total_time)
                                debugger
                                anim_leaveDyno(req, event.dyno)
                            else
                                anim_fromRouterToExit(req, event.start_time)
                        $(".js-total-time").text((global_timeline.totalDuration() / 1000.0).toFixed(3) + "s")


landing.init()
simulator.init()
control.init()
