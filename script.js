(function(){
    function Wave(){
        /** The current dimensions of the screen (updated on resize) */
        var WIDTH = window.innerWidth;
        var HEIGHT = window.innerHeight;

        /** Wave settings */
        var DENSITY = .75;
        var FRICTION = 1.14;
        var MOUSE_PULL = 0.2; // The strength at which the mouse pulls particles within the AOE
        var AOE = 100; // Area of effect for mouse pull
        var DETAIL = 15; // The number of particles used to build up the wave
        var CircleR = 100;
        var CircleBigR = 150;
        var TWITCH_INTERVAL = 1200; // The interval between random impulses being inserted into the wave to keep it moving

        var mouseIsDown = false;
        var ms = {x:0, y:0}; // Mouse speed
        var mp = {x:0, y:0}; // Mouse position

        var canvas, context, uraCanvas, uraContext, particles, uraParticles;

        var timeUpdateInterval, twitchInterval;


        this.Initialize = function(canvasID, uraCanvasID){
            canvas = document.getElementById( canvasID );
            uraCanvas = document.getElementById(uraCanvasID);


            if( canvas && canvas.getContext){
                WIDTH = window.innerWidth;
                HEIGHT = window.innerHeight;

                canvas.width = WIDTH;
                canvas.height = HEIGHT;

                uraCanvas.width = WIDTH;
                uraCanvas.height = HEIGHT;

                context = canvas.getContext("2d");
                uraContext = uraCanvas.getContext("2d");

                particles = [];
                uraParticles = [];


                // Generate our wave particles
                for( var i = 0; i < DETAIL; i++ ) {
                    var velRan = Math.random() * 6 - 3;
                    var theta = i/DETAIL*Math.PI*2;
                    var rRan = 12 * Math.random();
                    particles.push( {
                        x: WIDTH/2 + (CircleR + rRan) * Math.cos(i/DETAIL*Math.PI*2),
                        y: HEIGHT/2 + (CircleR + rRan) * Math.sin(i/DETAIL*Math.PI*2),
                        original: {x: WIDTH/2 + (CircleR + rRan) * Math.cos(theta), y: HEIGHT/2 + (CircleR + rRan) * Math.sin(theta)},
                        velocity: {x: 0, y: 0}, // Random for some initial movement in the wave
                        force: {x: velRan * Math.cos(theta), y: velRan * Math.sin(theta)},
                        mass: 10
                    } );

                    rRan = 15 * Math.random();
                    uraParticles.push({
                        x: WIDTH/2 + (CircleBigR + rRan) * Math.cos(i/DETAIL*Math.PI*2),
                        y: HEIGHT/2 + (CircleBigR + rRan) * Math.sin(i/DETAIL*Math.PI*2),
                        original: {x: WIDTH/2 + (CircleBigR + rRan) * Math.cos(theta), y: HEIGHT/2 + (CircleBigR + rRan) * Math.sin(theta)},
                        velocity: {x: 0, y: 0}, // Random for some initial movement in the wave
                        force: {x: velRan * Math.cos(theta), y: velRan * Math.sin(theta)},
                        mass: 10
                    })
                }



                $(canvas).mousemove(MouseMove);
//                $(canvas).mousedown(MouseDown);
//                $(canvas).mouseup(MouseUp);
                $(window).resize(ResizeCanvas);

                timeUpdateInterval = setInterval( TimeUpdate, 40 );

                twitchInterval = setInterval( Twitch, TWITCH_INTERVAL );

            }

        };

        /**
         ******
         */

        function TimeUpdate(e) {
            // clear the display of the canvas.
            context.clearRect(0, 0, WIDTH, HEIGHT);
            uraContext.clearRect(0, 0, WIDTH, HEIGHT);


//            context.moveTo(particles[0].x, particles[0].y);

            var current, previous, next;

            var len = particles.length;
            var lastPt;
            var i;

            context.fillStyle = "#333";
            context.beginPath();
            for(i = 0; i < len; i++){
                current = particles[i];


                if(i == 0){
                    previous = particles[len - 1];
                }else{
                    previous = particles[i - 1];
                }

                if(i == len - 1){
                    next = particles[0];
                }else{
                    next = particles[i + 1];
                }

                var forceY = 0;
                var forceX = 0;

                forceY += -DENSITY * (previous.y - current.y);
                forceX += -DENSITY * (previous.x - current.x);

                forceY += DENSITY * (current.y - next.y);
                forceX += DENSITY * (current.x - next.x);

                forceY += DENSITY * (current.y - current.original.y);
                forceX += DENSITY * (current.x - current.original.x);
//
                current.velocity.y += -(forceY / current.mass) + current.force.y;
                current.velocity.x += -(forceX / current.mass) + current.force.x;

                current.velocity.y /= FRICTION;
                current.force.y /= FRICTION;
                current.y += current.velocity.y;

                current.velocity.x /= FRICTION;
                current.force.x /= FRICTION;
                current.x += current.velocity.x;

                var distance = DistanceBetween( mp, current);

                if(distance < AOE){
                    distance = DistanceBetween( mp, {x:current.original.x, y:current.original.y});

                    ms.x = ms.x * 0.98;
                    ms.y = ms.y * 0.98;

                    current.force.y += (MOUSE_PULL * ( 1 - (distance / AOE) )) * ms.y ;
                    current.force.x += (MOUSE_PULL * ( 1 - (distance / AOE) )) * ms.x ;
                }


                if(i == 0){
                    context.moveTo( (current.x + previous.x)/2,  ( current.y + previous.y)/2);
                    lastPt = {x:(current.x + previous.x)/2, y:( current.y + previous.y)/2};

                }else{
                    context.quadraticCurveTo( previous.x, previous.y, previous.x + (current.x - previous.x) / 2, previous.y + (current.y - previous.y) / 2);
                }
            }


            context.quadraticCurveTo( particles[particles.length - 1].x, particles[particles.length - 1].y, lastPt.x, lastPt.y);

            context.closePath();

            context.fill();

            //=========================

            uraContext.fillStyle = "#ccc";
            uraContext.beginPath();
            for(i = 0; i < len; i++){
                current = uraParticles[i];


                if(i == 0){
                    previous = uraParticles[len - 1];
                }else{
                    previous = uraParticles[i - 1];
                }

                if(i == len - 1){
                    next = uraParticles[0];
                }else{
                    next = uraParticles[i + 1];
                }

                forceY = 0;
                forceX = 0;

                forceY += -DENSITY * (previous.y - current.y);
                forceX += -DENSITY * (previous.x - current.x);

                forceY += DENSITY * (current.y - next.y);
                forceX += DENSITY * (current.x - next.x);

                forceY += DENSITY * (current.y - current.original.y);
                forceX += DENSITY * (current.x - current.original.x);
//
                current.velocity.y += -(forceY / current.mass) + current.force.y;
                current.velocity.x += -(forceX / current.mass) + current.force.x;

                current.velocity.y /= FRICTION;
                current.force.y /= FRICTION;
                current.y += current.velocity.y;

                current.velocity.x /= FRICTION;
                current.force.x /= FRICTION;
                current.x += current.velocity.x;

                distance = DistanceBetween( mp, current);

                if(distance < AOE){
                    distance = DistanceBetween( mp, {x:current.original.x, y:current.original.y});

                    ms.x = ms.x * 0.98;
                    ms.y = ms.y * 0.98;

                    current.force.y += (MOUSE_PULL * ( 1 - (distance / AOE) )) * ms.y * 1.25;
                    current.force.x += (MOUSE_PULL * ( 1 - (distance / AOE) )) * ms.x * 1.25;
                }


                if(i == 0){
                    uraContext.moveTo( (current.x + previous.x)/2,  ( current.y + previous.y)/2);
                    lastPt = {x:(current.x + previous.x)/2, y:( current.y + previous.y)/2};

                }else{
                    uraContext.quadraticCurveTo( previous.x, previous.y, previous.x + (current.x - previous.x) / 2, previous.y + (current.y - previous.y) / 2);
                }
            }


            uraContext.quadraticCurveTo( uraParticles[particles.length - 1].x, uraParticles[particles.length - 1].y, lastPt.x, lastPt.y);

            uraContext.closePath();

            uraContext.fill();

        }

        function Twitch(){
            for(var i = 0; i < particles.length; i++){
                particles[i].velocity.x += Math.random() * 6 - 3;
                particles[i].velocity.y += Math.random() * 6 - 3;

                uraParticles[i].velocity.x += Math.random() * 10 - 5;
                uraParticles[i].velocity.y += Math.random() * 10 - 5;
            }
        }

        function InsertImpulse( positionNum, force){
            var particle = particles[positionNum];
            var uraParticle = uraParticles[positionNum];


            if(particle){
                particle.force.x += force * Math.cos(positionNum/DETAIL * Math.PI * 2);
                particle.force.y += force * Math.sin(positionNum/DETAIL * Math.PI * 2);

                uraParticle.force.x += force * 1.25 * Math.cos(positionNum/DETAIL * Math.PI * 2);
                uraParticle.force.y += force * 1.25 * Math.sin(positionNum/DETAIL * Math.PI * 2);
            }

        }


        /**
         ******
         */
        function MouseMove(e){
//            if(mouseIsDown){
                var rect = canvas.getBoundingClientRect();

                var posX = e.clientX - rect.left;
                var posY = e.clientY - rect.top;

                ms.x = Math.max( Math.min( posX - mp.x, 40 ), -40 );
                ms.y = Math.max( Math.min( posY - mp.y, 40 ), -40 );

                mp.x = posX;
                mp.y = posY;
//            }
        }

        /*
         ******
         */
        function ResizeCanvas(e){
            WIDTH = window.innerWidth;
            HEIGHT = window.innerHeight;

            canvas.width = WIDTH;
            canvas.height = HEIGHT;

            for( var i = 0; i < DETAIL; i++ ) {
                particles[i].x = WIDTH/2 + CircleR * Math.cos(i/DETAIL*Math.PI*2);
                particles[i].y = HEIGHT/2 + CircleR * Math.sin(i/DETAIL*Math.PI*2);

                particles[i].original.x = particles[i].x;
                particles[i].original.y = particles[i].y;

                uraParticles[i].x = WIDTH/2 + CircleBigR * Math.cos(i/DETAIL*Math.PI*2);
                uraParticles[i].y = HEIGHT/2 + CircleBigR * Math.sin(i/DETAIL*Math.PI*2);


                uraParticles[i].original.x = uraParticles[i].x;
                uraParticles[i].original.y = uraParticles[i].y;
            }
        }



        /*
         ******
         */
        function DistanceBetween(p1, p2){
            var dx = p2.x - p1.x;
            var dy = p2.y - p1.y;
            return Math.sqrt(dx*dx + dy*dy);
        }

    }

    var myWave = new Wave();
    myWave.Initialize("myCanvas", "myUraCanvas");

})();