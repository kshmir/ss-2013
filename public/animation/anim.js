var main_queue_size = 0
var queue = new Array();
var playground;
var orig;
var router;

function setup(numberOfQueues)
{
    playground = $("#playground");
    orig = playground.offset();

    router = $('<div class="router"/>');
    router.css("left",playground.width()/2);
    router.css("top",30);
    playground.append(router);

    var hspace = playground.width() / 6;
    for (var i=0 ; i<numberOfQueues ; i++)
    {
	queue[i] =
	    {spots: [0,0,0,0],
	     obj: $('<div class="queue"/>'),
	     text: $('<p></p>'),
	     size: 0};
	queue[i].obj.css("left",orig.left+(i+1)*hspace);
	queue[i].obj.css("top", orig.top+240);
	queue[i].obj.append(queue[i].text);
	playground.append(queue[i].obj);
    }
}


function createAnimation() 
{
    var ball = {obj: $('<div class="ball"></div>'), 
		spot: -1};
    ball.obj.css("top",router.offset().top);
    ball.obj.css("left",router.offset().left);
    playground.append(ball.obj);

//random routing
//var dyno = Math.floor(Math.random()*5+1)-1;

//pseudo-smart routing
    var dyno = -1;
    for (var i = 0, tried = Math.floor(Math.random()*5); i < 5 && dyno == -1 ; i++)
    {
        if (queue[tried].size < queue[tried].spots.length)
        {
	    dyno = tried;
        }
        else
        {
	    tried = (tried + 1) % 5;
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

    var destination_left = queue[i].obj.offset().left-router.offset().left+5;
    tl.add( TweenMax.to(ball.obj, 2, {bezier: {
	type: "soft",
	values: [{x:destination_left, y:80}, 
		 {x:destination_left, y:140}, 
		 {x:destination_left, y:280 - ball.spot*22 }],
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
    tl.add(TweenMax.to(ball.obj, 3, 
	   {bezier: {
	       type: "soft",
	       values: [{x:-115+i*60, y:280}, {x:-115+i*60, y:440}],
	       autoRotate: true
	   }}));

    tl.add(TweenLite.to(ball.obj, 5,
	   {css: {
	       opacity: "0"
	   }}));
}
