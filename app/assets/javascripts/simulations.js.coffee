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
                        $(".router-queue-length").text("#{data.results.router_queue_length.toFixed(3)}")
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
            comparison.bind_filters()
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

        prepare_data: (usage = "print")->
            random         = []
            round_robin    = []
            shortest_queue = []
            smart_routing  = []
            for result in comparison.results
                switch result.strategy
                    when "Round Robin" then round_robin.push(result)
                    when "Random" then random.push(result)
                    when "Smart" then smart_routing.push(result)
                    when "Shortest Queue" then shortest_queue.push(result)

            sorter = (array)->
                crit = comparison.criteria
                _.sortBy(array, (i1)-> i1[crit])

            random = sorter(random)
            round_robin = sorter(round_robin)
            smart_routing = sorter(smart_routing)
            shortest_queue = sorter(shortest_queue)

            printer = (array)->
                crit = comparison.criteria
                a = []
                for simu in array
                    res = simu.results
                    a.push("#{simu[crit]} #{res.mean_duration} #{res.std_dev_duration} #{res.mean_queue_length} #{res.std_dev_queue_length} #{res.mean_idle_time} #{res.std_dev_idle_time}")
                a.join("\n")


            displayer = (array)->
                crit = comparison.criteria
                a = []
                for simu in array
                    res = simu.results
                    a.push("<tr><td>#{simu[crit]}</td><td>#{res.mean_duration.toFixed(2)}</td><td>#{res.std_dev_duration.toFixed(2)}</td><td>#{res.mean_queue_length.toFixed(2)}</td><td>#{res.std_dev_queue_length.toFixed(2)}</td><td>#{res.mean_idle_time.toFixed(2)}</td><td>#{res.std_dev_idle_time.toFixed(2)}</td></tr>")
                if a.length == 0 then null else a.join("\n")


            if (usage == "display")
                crit = switch comparison.criteria
                    when "clients" then "Clientes"
                    else comparison.criteria
                data = 
                    header: "<tr><th>#{crit}</th><th>Duración promedio de ruteo de un pedido</th><th>Desvío estándar en el duración de ruteo</th><th>Tamaño promedio de cola de servidores</th><th>Desvío estándar de tamaño de cola de servidores</th><th>Tiempo ocioso promedio de servidores</th><th>Desvío estándar de tiempo ocioso de los servidores</th></tr>"
                    random: displayer(random)
                    round_robin: displayer(round_robin)
                    smart_routing: displayer(smart_routing)
                    shortest_queue: displayer(shortest_queue)
            else
                data = 
                    random: printer(random)
                    round_robin: printer(round_robin)
                    smart_routing: printer(smart_routing)
                    shortest_queue: printer(shortest_queue)
            data


        plot: (selected_strategies, value)->
            print_to_image = (e)->
                    comparison.plotter.getFile "out.svg", (e) ->
                        unless e.content
                          alert "Output file out.svg not found!"
                          return
                        img = document.getElementById("result")
                        try
                          ab = new Uint8Array(e.content)
                          blob = new Blob([ab],
                            type: "image/svg+xml"
                          )
                          window.URL = window.URL or window.webkitURL
                          img.src = window.URL.createObjectURL(blob)
                        catch err # in case blob / URL missing, fallback to data-uri
                          rstr = ""
                          i = 0

                          while i < e.content.length
                            rstr += String.fromCharCode(e.content[i])
                            i++
                          img.src = "data:image/svg+xml;base64," + btoa(rstr)

            places = []
            switch value
                when "duration" then places = [2,3]
                when "queue" then places = [4,5]
                when "idle" then places = [6,7]

            fit_funct = ()->
                arr = []
                arr.push("fit f(x) 'RandomRouting.plot' u 1:#{places[0]} via a,b") if _.contains(selected_strategies, "Random")
                arr.push("fit g(x) 'RoundRobinRouting.plot' u 1:#{places[0]} via c,d") if _.contains(selected_strategies, "Round Robin")
                arr.push("fit h(x) 'ShortestQueueRouting.plot' u 1:#{places[0]} via e,f") if _.contains(selected_strategies, "Shortest Queue")
                arr.push("fit i(x) 'SmartRouting.plot' u 1:#{places[0]} via g,h") if _.contains(selected_strategies, "Smart")
                arr.join("\n")

            draw_funct = ()->
                arr = []
                arr.push("'RandomRouting.plot' using 1:#{places[0]}:#{places[1]} w yerrorlines") if _.contains(selected_strategies, "Random")
                arr.push("'RoundRobinRouting.plot' using 1:#{places[0]}:#{places[1]} w yerrorlines") if _.contains(selected_strategies, "Round Robin")
                arr.push("'ShortestQueueRouting.plot' using 1:#{places[0]}:#{places[1]} w yerrorlines") if _.contains(selected_strategies, "Shortest Queue")
                arr.push("'SmartRouting.plot' using 1:#{places[0]}:#{places[1]} w yerrorlines") if _.contains(selected_strategies, "Smart")
                arr.join(", ")

            gnuplot = comparison.plotter

            gnuplot.run """
                        set terminal svg enhanced size #{comparison.image_size[0]},#{comparison.image_size[1]}
                        set output 'out.svg'
                        set format cb "%4.1f"
                        
                        set title "Average idle time"

                        f(x) = a*x+b
                        g(x) = c*x+d
                        h(x) = e*x+f
                        i(x) = g*x+h

                        

                        plot #{draw_funct()}
                    """, print_to_image
                        

        panel: ()->
            id = $(".js-comparison").attr "data-id"
            if id
                $.getJSON "/comparisons/#{id}.json", (data)->
                    comparison.image_size = [
                        $("#result").parents(".span12").width(), $(window).height() - 160
                    ]
                    comparison.criteria = data.criteria
                    comparison.results = eval(data.results)
                    $(".anim-loading").addClass("hidden")
                    $(".js-compview").removeClass("hidden")
                   
                    data_display = comparison.ui.prepare_data("display")
                    data = comparison.data =  comparison.ui.prepare_data("print")

                    comparison.plotter = new Gnuplot("/assets/gnuplot.js")
                    comparison.plotter.putFile("RandomRouting.plot", data.random);
                    comparison.plotter.putFile("RoundRobinRouting.plot", data.round_robin);
                    comparison.plotter.putFile("ShortestQueueRouting.plot", data.shortest_queue);
                    comparison.plotter.putFile("SmartRouting.plot", data.smart_routing);

                    comparison.ui.plot(comparison.strategies(), comparison.variable())
                    $(".header-results").append(data_display.header)
                    if (data_display.random)
                        $(".random-results").append(data_display.random)
                    else
                        $(".random-table").addClass("hidden")
                    if (data_display.round_robin)
                        $(".round_robin-results").append(data_display.round_robin)
                    else
                        $(".round_robin-table").addClass("hidden")
                    if (data_display.shortest_queue)
                        $(".shortest_queue-results").append(data_display.shortest_queue)
                    else
                        $(".shortest_queue-table").addClass("hidden")
                    if (data_display.smart_routing)
                        $(".smart-results").append(data_display.smart_routing)
                    else
                        $(".smart-table").addClass("hidden")


    strategies: ()->
        _.map($(".js-strategy-cmp .active"), (item)-> $(item).text())
    variable: ()->
        $(".js-variable-cmp .active").data("variable")
    bind_filters: ()->
        $(".js-strategy-cmp .btn").on "click", ()-> 
            $(this).toggleClass("active")
            if (comparison.data)
                comparison.ui.plot(comparison.strategies(), comparison.variable())
        $(".js-variable-cmp .btn").on "click", ()-> 
            $(".js-variable-cmp .btn").removeClass("active")
            $(this).addClass("active")
            if (comparison.data)
                comparison.ui.plot(comparison.strategies(), comparison.variable())
        
            
                     
                      



plot = undefined;

landing.init()
simulator.init()
comparison.init()
control.init()
