#= require TweenMax.min
#= require anim

#= require jquery

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

        $(".js-anim-toggle").on "click", ()->
            $(".tab").removeClass("hidden")
            $(".tab").hide()
            $(".nav-pills li").removeClass("active")
            $(this).parents("li").addClass("active")
            $(".js-sim-tab").show()
        $(".js-result-toggle").on "click", ()->
            $(".tab").removeClass("hidden")
            $(".tab").hide()
            $(".nav-pills li").removeClass("active")
            $(this).parents("li").addClass("active")
            $(".js-result-tab").show()
        $(".js-graph-toggle").on "click", ()->
            $(".tab").removeClass("hidden")
            $(".tab").hide()
            $(".nav-pills li").removeClass("active")
            $(this).parents("li").addClass("active")
            $(".js-graph-tab").show()

        $time = $(".js-time")
        setInterval(()->
            if (global_timeline)
                $time.text((global_timeline.time() / 1000).toFixed(3) + "s")
        , 10)


landing =
    init: ()->
        $(".js-simulation-toggle").on "click", ()->
            $(".btns").slideUp "slow", ()->
                $(".simulation-form").hide()
                $(".simulation-form").removeClass "hidden"
                $(".simulation-form").slideDown "slow"
        $(".js-comparison-toggle").on "click", ()->
            $(".btns").slideUp "slow", ()->
                $(".comparison-form").hide()
                $(".comparison-form").removeClass "hidden"
                $(".comparison-form").slideDown "slow"


simulator =
    init: ()->
        if $(".js-simulation")
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
                $.getJSON "/simulations/#{id}.json", (data)->
                    $(".anim-loading").addClass("hidden")
                    $(".js-simview").removeClass("hidden")
                    setup(parseInt($(".js-simulation").data("clients")))
                    anims = {}
                    data.stats = eval(data.json)
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
                                anim_leaveDyno(req, event.dyno)
                            else
                                anim_fromRouterToExit(req, event.start_time)
                        $(".js-total-time").text((global_timeline.totalDuration() / 1000.0).toFixed(3) + "s")
                    if (data.results)
                        $(".mean-queue-length").text("#{data.results.mean_queue_length.toFixed(3)}")
                        $(".std-dev-queue-length").text("#{data.results.std_dev_queue_length.toFixed(3)}")
                        $(".mean-idle-time").text("#{data.results.mean_idle_time.toFixed(3)}ms")
                        $(".std-dev-idle-time").text("#{data.results.std_dev_idle_time.toFixed(3)}ms")
                        $(".mean-duration").text("#{data.results.mean_duration.toFixed(3)}ms")
                        $(".std-dev-duration").text("#{data.results.std_dev_duration.toFixed(3)}ms")
                        $(".total").text("#{data.results.accepted + data.results.rejected} pedidos")
                        $(".accepted").text("#{data.results.accepted} pedidos")
                        $(".rejected").text("#{data.results.rejected} pedidos")


comparison =
    init: ()->
        if $(".js-comparison")
            $(".anim-loading").removeClass("hidden")
            percentage = comparison.percentage = $(".js-comparison").data("percentage")
            if (parseInt(percentage) < 100.0)
                comparison.ui.status_updater()
            else
                comparison.ui.toggle_screen()
    ui:
        status_updater: ()->
            id = $(".js-comparison").attr "data-id"
            if id
                $.getJSON "/comparisons/#{id}.json?status=true",(data)->
                    $(".js-comparison").removeClass("hidden")

                    comparison.percentage = perc = data.percentage
                    $(".bar").css("width", "#{perc}%")
                    $(".amount").text("#{data.amount}")
                    $(".total").text("#{data.total}")
                    if (parseInt(perc) < 100.0)
                        setTimeout(comparison.ui.status_updater,100)
                    else
                        comparison.ui.toggle_screen()
        toggle_screen: ()->
            $(".js-comparison").addClass("hidden")
            comparison.ui.panel()
        panel: ()->
            id = $(".js-comparison").attr "data-id"
            if id
                $.getJSON "/comparisons/#{id}.json", (data)->
                    comparison.results = eval(data.results)
                    $(".anim-loading").addClass("hidden")
                    $(".js-compview").removeClass("hidden")
                    


landing.init()
simulator.init()
comparison.init()
control.init()
