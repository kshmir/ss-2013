var main_queue_size = 0
var queue = new Array();
var playground;
var orig;
var router;
var internet;
var N;
var timelines = {};
var router_timeline;
var balls = {};
global_timeline = undefined;

function setup(numberOfQueues)
{
    playground = $("#playground");
    orig = playground.offset();

    internet = $('.internet');

    router = $('.router');
    playground.prepend(router);

    var hspace = playground.width() / 6;
    for (var i=0 ; i<numberOfQueues ; i++)
    {
             queue[i] = {
                 obj: $('<div class="queue"/>'),
                 text: $('<p>0</p>'),
                 size: 0
        };
             queue[i].obj.append(queue[i].text);
             $(".queues").append(queue[i].obj);
    }
    N = numberOfQueues;

}

function anim_updateRouter(t, val)
{
    if (!global_timeline) {
        $time = $(".js-time")
        global_timeline = new TimelineLite({paused: true,
            onUpdate: function() {
                $time.text((global_timeline.time() / 1000).toFixed(3) + "s")
            }
        });
        global_timeline.autoRemoveChildren = true;
        global_timeline.smoothChildTiming = true;
        document.global_timeline = global_timeline;
    }

    if (!router_timeline) {
         router_timeline = new TimelineLite();
         router_timeline.smoothChildTiming = true;
	 global_timeline.add(router_timeline, { position: 0 });
    }
    router_timeline.call(
             function() {
                  $(".js-router-queue-length").text(val)
             }, [], this, t
                  );
}

function createAnimation(id) 
{
    var ball = {obj: $('<div id="ball_' + id + '" class="ball"></div>'), 
                  spot: -1};

    ball.obj.css("top",router.offset().top + 15);
    ball.obj.css("left",router.offset().left + 15);
    playground.append(ball.obj);

    balls[id] = ball;
    timelines[id]  = new TimelineLite();

    if (!global_timeline) {
        $time = $(".js-time")
        global_timeline = new TimelineLite({paused: true,
            onUpdate: function() {
                $time.text((global_timeline.time() / 1000).toFixed(3) + "s")
            }
        });
        global_timeline.autoRemoveChildren = true;
        global_timeline.smoothChildTiming = true;
        document.global_timeline = global_timeline;
    }
    global_timeline.add(timelines[id], { position: 0 });
}


function anim_fromRouterToDyno(id_ball, i, delay, stay_time)
{
    var spot_found = false;
    var tl = timelines[id_ball];
    var ball = balls[id_ball];

    ball.spot = i;


    TweenMax.defaultOverwrite = "all";
    var dX = queue[i].obj.offset().left-router.offset().left - 5; 
    var dY = queue[i].obj.offset().top-router.offset().top - 25;
    tl.add( TweenMax.to(ball.obj, 0.01, { opacity:1, delay: delay }));
    tl.add( TweenMax.to(ball.obj, 0.5, {bezier: {
         type: "soft",
         values: [{x:dX, y:dY + 20}, 
                   {x:dX, y:dY + 20}]
                   // {x:dX, y:280 - ball.spot*22 }],
    }
    , opacity: 0
    }));
    tl.call(function() 
    {
    queue[i].size += (tl.reversed()) ? -1 : 1; 
    queue[i].text.text(queue[i].size);
    }, [], this);
    tl.add(TweenMax.to(queue[i].obj, stay_time, {css: {
         backgroundColor: "#FF0000"
    }}));


    
}

function anim_fromRouterToExit(id_ball, start_time)
{
    var tl = timelines[id_ball];
    var ball = balls[id_ball];
    tl.add( TweenMax.to(ball.obj, 0.01, { opacity:1, delay: start_time }));
    tl.call(function() 
    {
        $(".js-time").text(((start_time) / 1000.0).toFixed(3) + "s")
    }, [], this);
    tl.add( TweenMax.to(ball.obj, 0.5, {bezier: {
         type: "soft",
         values: [{x:0, y:0}, {x:400, y:0}, {x:450, y:150}, {x:450, y:200}]
    },opacity:0}));
}

function anim_leaveDyno(id_ball, i, delay)
{
    var tl = timelines[id_ball];
    var ball = balls[id_ball];
    var dX = ball.obj.offset().left-router.offset().left - 5 + Math.random()*internet.width()/2 - internet.width()/4; 
    var dY = internet.offset().top - ball.obj.offset().top + Math.random()*(internet.height()-ball.obj.height());

    tl.call(function() 
        {
        queue[i].size += (tl.reversed()) ? 1 : -1; 
        queue[i].text.text(queue[i].size);
        }, [], this);

    tl.add(TweenMax.to(queue[i].obj, 0.1, {css: {
         backgroundColor: "rgb(79, 160, 55)"
    }}));

    tl.add(TweenMax.to(ball.obj, 0.5, 
            {bezier: {
                type: "soft",
                values: [
                    {x:dX, y:dY},
                    {x:dX, y:dY}
                   ]
            }, opacity: 1
    }));
    
    

    tl.add(TweenLite.to(ball.obj, 1,
            {css: {
                opacity: "0"
            }}));
}
