var main_queue_size = 0
var queue = new Array();
var playground;
var orig;
var router;
var internet;
var N;
var timelines = {};
var balls = {};
var global_timeline = undefined;


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


function createAnimation(id) 
{
    var ball = {obj: $('<div id="ball_' + id + '" class="ball"></div>'), 
		spot: -1};

    ball.obj.css("top",router.offset().top + 15);
    ball.obj.css("left",router.offset().left + 15);
    playground.append(ball.obj);

    balls[id] = ball;
    timelines[id]  = new TimelineLite();
}

function launch_animation(id_ball)
{
    timelines[id_ball].resume();
    if (!global_timeline) {
        global_timeline = new TimelineLite();
        global_timeline.timeScale(0.1);
        // global_timeline.autoRemoveChildren = true;
        global_timeline.smoothChildTiming = true;

    }
    global_timeline.add(timelines[id_ball], { position: 0 });
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
    queue[i].size++ ; 
    queue[i].text.text(queue[i].size);
    }, [], this);
    tl.add( TweenMax.to(ball.obj, stay_time, {bezier: {
    type: "soft",
    values: [{x:dX, y:dY + 20}, 
         {x:dX, y:dY + 20}]
         // {x:dX, y:280 - ball.spot*22 }],
    }}));
}

function anim_fromRouterToExit(id_ball, delay)
{
    var tl = timelines[id_ball];
    var ball = balls[id_ball];
    tl.add( TweenMax.to(ball.obj, 2, {bezier: {
	type: "soft",
	values: [{x:0, y:0}, {x:400, y:0}, {x:450, y:150}, {x:450, y:200}]
    }, delay: delay * 0.8}));
}

function anim_leaveDyno(id_ball, i, delay)
{
    var tl = timelines[id_ball];
    var ball = balls[id_ball];
    var dX = ball.obj.offset().left-router.offset().left - 5 + Math.random()*internet.width()/2 - internet.width()/4; 
    var dY = internet.offset().top - ball.obj.offset().top + Math.random()*(internet.height()-ball.obj.height());

    tl.call(function() 
        {
        queue[i].size-- ; 
        queue[i].text.text(queue[i].size);
        }, [], this);

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


setup(25);
