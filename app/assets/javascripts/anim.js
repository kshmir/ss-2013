var main_queue_size = 0
var queue = new Array();
var playground;
var orig;
var router;
var internet;
var N;

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
            spots: [0,0,0,0],
	        obj: $('<div class="queue"/>'),
	        text: $('<p>0</p>'),
	        size: 0
        };
    	queue[i].obj.append(queue[i].text);
    	$(".queues").append(queue[i].obj);
    }
    N = numberOfQueues;
}


function createAnimation() 
{
    var ball = {obj: $('<div class="ball"></div>'), 
		spot: -1};
    ball.obj.css("top",router.offset().top + 15);
    ball.obj.css("left",router.offset().left + 15);
    playground.append(ball.obj);

//random routing
//var dyno = Math.floor(Math.random()*5+1)-1;

//pseudo-smart routing
    var dyno = -1;
    for (var i = 0, tried = Math.floor(Math.random()*N); i < N && dyno == -1 ; i++)
    {
        if (queue[tried].size < queue[tried].spots.length)
        {
	    dyno = tried;
        }
        else
        {
	    tried = (tried + 1) % N;
        }
    }

    var tl = new TimelineLite();
    if (dyno == -1 || queue[dyno].size>=queue[dyno].spots.length)
    {
	anim_fromRouterToExit(tl, ball);
    }
    else
    {
	anim_fromRouterToDyno(tl, ball, dyno);
        tl.call(function() 
		{
		    queue[dyno].size-- ; 
		    queue[dyno].spots[ball.spot]=0; 
		    queue[dyno].text.text(queue[dyno].size);
		}, [], this, "+=3");
	anim_leaveDyno(tl, ball, dyno);
    }
    tl.call(function() { ball.obj.remove(); });

    tl.resume();
}

function anim_fromRouterToDyno(tl, ball, i)
{
    var spot_found = false;
    for (var j=0 ; j<queue[i].spots.length && !spot_found ; j++)
    {
        if (queue[i].spots[j] == 0)
        {
            ball.spot = j;
            queue[i].spots[j] = 1;
            spot_found = true;
        }
    }
    queue[i].size++;
    queue[i].text.text(queue[i].size);

    var dX = queue[i].obj.offset().left-router.offset().left - 5; 
    var dY = queue[i].obj.offset().top-router.offset().top - 25;

    tl.add( TweenMax.to(ball.obj, 2, {bezier: {
	type: "soft",
	values: [{x:dX, y:dY}, 
		 {x:dX, y:dY + 10}, 
         {x:dX, y:dY + 20 }],
		 // {x:dX, y:280 - ball.spot*22 }],
	autoRotate: true
    }}));
}

function anim_fromRouterToExit(tl, ball)
{
    tl.add( TweenMax.to(ball.obj, 2, {bezier: {
	type: "soft",
	values: [{x:0, y:0}, {x:400, y:0}, {x:450, y:150}, {x:450, y:200}],
	autoRotate: true
    }}));
}

function anim_leaveDyno(tl, ball, i)
{
    debugger;
    var dX = ball.obj.offset().left-router.offset().left - 5 + Math.random()*internet.width()/2 - internet.width()/4; 
    var dY = internet.offset().top - ball.obj.offset().top + Math.random()*(internet.height()-ball.obj.height());

    tl.add(TweenMax.to(ball.obj, 3, 
	   {bezier: {
	       type: "soft",
	       values: [
                    {x:dX, y:dY},
                    {x:dX, y:dY}
                   ],
	       autoRotate: true
	   }}));

    tl.add(TweenLite.to(ball.obj, 5,
	   {css: {
	       opacity: "0"
	   }}));
}


setup(100);
