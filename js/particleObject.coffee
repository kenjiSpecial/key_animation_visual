DistanceBetween = (p1, p2)->
  dx = p2.x - p1.x
  dy = p2.y - p2.y
  Math.sqrt(dx*dx+dy*dy)

#CalculationForce = ( currentParticle, previousParticle, nextParticle)->

TweenCalculation = (rate, startVal, endVal) ->
#  easeOutQuad
  val = -1 * (endVal - startVal) * rate * (rate - 2) + startVal
  val


class this.ParticleObject
  constructor: ( context1, context2) ->
#    the attribute of the canvas
    this.Width = window.innerWidth
    this.Height = window.innerHeight

    this.context1 = context1
    this.context2 = context2

#    the attribute of the particleObject
    this.lastTime = new Date().getTime()
    this.timeSum = 0

#    the attribute of the wave
    this.DENSITY = .75
    this.FRICTION = 1.14
    this.Mouse_Pull = 0.2
    this.DETAIL = 16
    this.AOE = 100
    this.rad = 150
    this.TWITCH_INTERVAL = .8
    this.FORM_CHANGE_INTERVAL = 4

#    the status for the shape
    this.waveStatus = false
    this.openingStatus = false

#    the status of the animation of the particle
    this.particleObjectAnimation = true


#    shapeID is id for detecting the shape itself
    this.shapeID = 0

#    the values of the mouse spped and position.
    this.ms = {x: 0, y: 0}
    this.mp = {x: 0, y: 0}


    this.particles1 = []
    this.particles2 = []


    $(document).bind 'mousemove', (event) =>

      this.mouseMoveFunc(event.pageX, event.pageY)

  init: ->
    switch this.shapeID
      when 0
        for i in [0..this.DETAIL-1]
          forceRandom = Math.random() * 100 - 50
          theta = i / this.DETAIL * Math.PI * 2
          rRan = 80 * Math.random()

          particle = {
          x: this.Width / 2 + (this.rad + rRan) * Math.cos(theta),
          y: this.Height / 2 + (this.rad + rRan) * Math.sin(theta),
          original: {x: this.Width/ 2 + (this.rad + rRan) * Math.cos(theta), y: this.Height/ 2 + (this.rad + rRan) * Math.sin(theta)},
          velocity: {x: 0, y: 0},
          force: {x: forceRandom * Math.cos(theta), y: forceRandom * Math.sin(theta)},
          mass: 10}
          this.particles1.push(particle)


        for i in [0..this.DETAIL-1]
          forceRandom = Math.random() * 100 - 50
          theta = i / this.DETAIL * Math.PI * 2
          rRan = 80 * Math.random()

          particle = {
          x: this.Width / 2 + (this.rad + rRan) * Math.cos(theta),
          y: this.Height / 2 + (this.rad + rRan) * Math.sin(theta),
          original: {x: this.Width/ 2 + (this.rad + rRan) * Math.cos(theta), y: this.Height/ 2 + (this.rad + rRan) * Math.sin(theta)},
          velocity: {x: 0, y: 0},
          force: {x: forceRandom * Math.cos(theta), y: forceRandom * Math.sin(theta)},
          mass: 10}
          this.particles2.push(particle)

      when 2
        for i in [0..this.DETAIL-1]
          forceRandom = Math.random() * 100 - 50
          theta = i / this.DETAIL * Math.PI * 2
          rRan = 80 * Math.random()

          particle = {
          x: this.Width / (this.DETAIL - 5) * (i - 2),
          y: 2/5 * this.Height,
          original: {x: this.Width / (this.DETAIL - 5) * (i - 2), y: 2/5 * this.Height},
          velocity: {x: 0, y: 0},
          force: {x: 0, y: 60 * Math.random() - 30}
          mass: 10}
          this.particles1.push(particle)


        for i in [0..this.DETAIL-1]
          forceRandom = Math.random() * 100 - 50
          theta = Math.PI / 2
          rRan = 80 * Math.random()

          particle = {
          x: this.Width / (this.DETAIL - 5) * (i - 2),
          y: 3/5 * this.Height,
          original: {x: this.Width / (this.DETAIL - 5) * (i - 2), y: 3/5 * this.Height},
          velocity: {x: 0, y: 0},
          force: {x: forceRandom * Math.cos(theta), y: forceRandom * Math.sin(theta)},
          mass: 10}
          this.particles2.push(particle)


  mouseMoveFunc: (posX, posY)->
#    console.log("#{posX}, #{posY}")
    this.ms.x = Math.max( Math.min( posX - this.mp.x, 40 ), -40 );
    this.ms.y = Math.max( Math.min( posY - this.mp.y, 40 ), -40 );

    this.mp.x = posX
    this.mp.y = posY



  resetTimer: ->
    this.timeSum = 0
    this.lastTime = new Date().getTime()

#    console.log this.shapeID
    if this.shapeID is 0

      this.twitchTime = 0
      this.formChangeTImer = 0

  transfer: () ->
#    chage the shapeID value from 0 to 1
    if this.shapeID is 0
      this.shapeID = 1
      this.waveStatus = true

#    change the shapeID value from  2 to 3
    if this.shapeID is 2
      this.shapeID = 3
      this.openingStatus  = true

#    saving the temp original particle position for creating the animation
    if this.shapeID is 1 && this.waveStatus
      this.waveStatus = false

      this.tempParticle01 = []
      this.futureParticle01 = []

      this.tempParticle02 = []
      this.futureParticle02 = []

      for particle, i in this.particles1
        pt = {x: particle.original.x, y: particle.original.y}
        this.tempParticle01.push(pt)

        futurePt = {x: this.Width / (this.DETAIL - 5) * (i - 2), y: 3/5 * this.Height}
        this.futureParticle01.push(futurePt)

  #      ---------------------

      for particle, i in this.particles2
        pt = {x: particle.original.x, y: particle.original.y}
        this.tempParticle02.push(pt)

        futurePt = {x: this.Width / (this.DETAIL - 5) * (i - 2), y: 2/5 * this.Height}
        this.futureParticle02.push(futurePt)

      this.transferTimer = 0
      this.transferDuration = .3
      this.TWITCH_INTERVAL = .6
      this.twitchTime = 0

      this.lastTime = new Date().getTime()

    if this.shapeID is 3  && this.openingStatus
      this.openingStatus = false;

      AOEE = 1200
      this.tempParticle01 = []
      this.futureParticle01 = []

#      this.particles1[this.DETAIL / 2].force.y += 500

      for particle, i in this.particles1
        pt = {x: particle.original.x, y: particle.original.y}
        this.tempParticle01.push(pt)

        futurePt = {x: particle.original.x, y: 0}
        this.futureParticle01.push(futurePt)

        distance = DistanceBetween(this.mp, particle)
        distance = DistanceBetween( this.mp, {x: particle.original.x, y:particle.original.y})
        particle.force.y += ( 1 - (distance / AOEE)) * 90 * (0.7 + 0.3 * Math.random());

      this.transferTimer = 0
      this.transferDuration = 1.2


  update: ->
    curTime = new Date().getTime()
    dt = (curTime - this.lastTime) / 1000

    switch this.shapeID
      when 0 then this.slime(dt) #calculating the particle and painting it
      when 1 then this.slimeToWave(dt) #calculating the particle and painting it
      when 2 then this.wave(dt) #calculating the particle and painting it
      when 3 then this.waveToOpen(dt)

    this.lastTime = curTime


  slime: (dt)->
    this.twitchTime += dt
    this.formChangeTImer += dt

    if this.twitchTime > this.TWITCH_INTERVAL
      for i in [0..this.DETAIL-1]
        this.particles1[i].velocity.x += Math.random() * 10 - 5
        this.particles1[i].velocity.x += Math.random() * 10 - 5

        this.particles2[i].velocity.x += Math.random() * 10 - 5
        this.particles2[i].velocity.x += Math.random() * 10 - 5

      this.twitchTime -= this.TWITCH_INTERVAL

    if this.formChangeTImer > this.FORM_CHANGE_INTERVAL
      for i in [0..this.DETAIL-1]
        theta = i / this.DETAIL * Math.PI * 2

        forceRandom = Math.random() * 60 - 30
        rRan = 80 * Math.random() - 40
        this.particles1[i].original.x += rRan * Math.cos(theta)
        this.particles1[i].original.y += rRan * Math.sin(theta)
        this.particles1[i].force.x += forceRandom * Math.cos(theta)
        this.particles1[i].force.y += forceRandom * Math.sin(theta)

        forceRandom = Math.random() * 60 - 30
        rRan = 80 * Math.random() - 40
        this.particles2[i].original.x += rRan * Math.cos(theta)
        this.particles2[i].original.y += rRan * Math.sin(theta)
        this.particles2[i].force.x += forceRandom * Math.cos(theta)
        this.particles2[i].force.y += forceRandom * Math.sin(theta)

      this.formChangeTImer -= this.FORM_CHANGE_INTERVAL



    this.context1.fillStyle = "rgba(30, 30, 30, .3)";
    this.context1.beginPath();
    for particle,i in this.particles1

      if i is 0
        previous = this.particles1[this.DETAIL - 1]
      else
        previous = this.particles1[i - 1]

      if i is this.DETAIL - 1
        next = this.particles1[0]
      else
        next = this.particles1[i + 1]


      force = {x:0, y:0}
      force.y += -this.DENSITY * (previous.y - particle.y)
      force.x += -this.DENSITY * (previous.x - particle.x)

      force.y += this.DENSITY * (particle.y - next.y)
      force.x += this.DENSITY * (particle.x - next.x)

      force.y += this.DENSITY * (particle.y - particle.original.y)
      force.x += this.DENSITY * (particle.x - particle.original.x)

      particle.velocity.y += -(force.y / particle.mass) + particle.force.y
      particle.velocity.x += -(force.x / particle.mass) + particle.force.x

      particle.velocity.x /= this.FRICTION
      particle.force.x /= this.FRICTION
      particle.x += particle.velocity.x

      particle.velocity.y /= this.FRICTION
      particle.force.y /= this.FRICTION
      particle.y += particle.velocity.y

      distance = DistanceBetween(this.mp, particle)
      if(distance < this.AOE)
        distance = DistanceBetween( this.mp, {x: particle.original.x, y:particle.original.y})

        this.ms.x = this.ms.x * 0.98
        this.ms.y = this.ms.y * 0.98

        particle.force.y += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.y * 1.25;
        particle.force.x += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.x * 1.25;


      if i is 0
        lastPt = {x: (particle.x + previous.x) / 2, y: (particle.y + previous.y) / 2}
        this.context1.moveTo( lastPt.x, lastPt.y)
      else
        this.context1.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

    this.context1.quadraticCurveTo( this.particles1[this.DETAIL - 1].x, this.particles1[this.DETAIL - 1].y, lastPt.x, lastPt.y)
    this.context1.closePath()
    this.context1.fill()

    #    ---------------------

    this.context2.fillStyle = "rgba(120, 120, 120, .3)";
    this.context2.beginPath();
    for particle, i in this.particles2

      if i is 0
        previous = this.particles2[this.DETAIL - 1]
      else
        previous = this.particles2[i - 1]

      if i is this.DETAIL - 1
        next = this.particles2[0]
      else
        next = this.particles2[i + 1]

#      if i is 0
      force = {x:0, y:0}
      force.y += -this.DENSITY * (previous.y - particle.y)
      force.x += -this.DENSITY * (previous.x - particle.x)

      force.y += this.DENSITY * (particle.y - next.y)
      force.x += this.DENSITY * (particle.x - next.x)

      force.y += this.DENSITY * (particle.y - particle.original.y)
      force.x += this.DENSITY * (particle.x - particle.original.x)

      particle.velocity.y += -(force.y / particle.mass) + particle.force.y
      particle.velocity.x += -(force.x / particle.mass) + particle.force.x

      particle.velocity.x /= this.FRICTION
      particle.force.x /= this.FRICTION
      particle.x += particle.velocity.x

      particle.velocity.y /= this.FRICTION
      particle.force.y /= this.FRICTION
      particle.y += particle.velocity.y

      distance = DistanceBetween(this.mp, particle)
      if(distance < this.AOE)
        distance = DistanceBetween( this.mp, {x: particle.original.x, y:particle.original.y})

        this.ms.x = this.ms.x * 0.98
        this.ms.y = this.ms.y * 0.98

        particle.force.y += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.y;
        particle.force.x += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.x;


      if i is 0
        lastPt = {x: (particle.x + previous.x) / 2, y: (particle.y + previous.y) / 2}
        this.context2.moveTo( lastPt.x, lastPt.y)
      else
        this.context2.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

    this.context2.quadraticCurveTo( this.particles2[this.DETAIL - 1].x, this.particles2[this.DETAIL - 1].y, lastPt.x, lastPt.y)
    this.context2.closePath()
    this.context2.fill()

  slimeToWave: (dt)->
    this.twitchTime += dt
    if this.twitchTime > this.TWITCH_INTERVAL
      for i in [1..this.DETAIL-2]
        this.particles1[i].force.x += Math.random() * 10 - 5
        this.particles1[i].force.y += Math.random() * 10 - 5

        this.particles2[i].force.x += Math.random() * 10 - 5
        this.particles2[i].force.y += Math.random() * 10 - 5

      this.twitchTime -= this.TWITCH_INTERVAL


    this.transferTimer += dt
    rate = this.transferTimer / this.transferDuration



    if rate < 1
      this.context1.fillStyle = "rgba(30, 30, 30, #{.3 * (1-rate)})";
      this.context1.beginPath();

      for particle, i in this.particles1
        particle.original.x = TweenCalculation(rate, this.tempParticle01[i].x, this.futureParticle01[i].x)
        particle.original.y = TweenCalculation(rate, this.tempParticle01[i].y, this.futureParticle01[i].y)
        if i is 0
          previous = this.particles1[this.DETAIL - 1]
        else
          previous = this.particles1[i - 1]

        force = {x:0, y:0}
        force.y += this.DENSITY * (particle.y - particle.original.y) * 40
        force.x += this.DENSITY * (particle.x - particle.original.x) * 40

        particle.velocity.y += -(force.y / particle.mass) + particle.force.y
        particle.velocity.x += -(force.x / particle.mass) + particle.force.x

        particle.velocity.x /= this.FRICTION
        particle.force.x /= this.FRICTION
        particle.x += particle.velocity.x

        particle.velocity.y /= this.FRICTION
        particle.force.y /= this.FRICTION
        particle.y += particle.velocity.y

        if i is 0
          lastPt = {x: (particle.x + previous.x) / 2, y: (particle.y + previous.y) / 2}
          this.context1.moveTo( lastPt.x, lastPt.y)
        else
          this.context1.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

      this.context1.quadraticCurveTo( this.particles1[this.DETAIL - 1].x, this.particles1[this.DETAIL - 1].y, lastPt.x, lastPt.y)
      this.context1.closePath()
      this.context1.fill()

#      ------------

      this.context1.fillStyle = "rgba(30, 30, 30, #{ rate })";
      this.context1.beginPath();
      this.context1.moveTo(this.particles1[1].x, this.particles1[1].y)

      for particle, i in this.particles1
        previous = this.particles1[i - 1]
        next = this.particles1[i + 1]
        if previous && next
          this.context1.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

      this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.particles1[this.DETAIL - 1].y)
      this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.Height)
      this.context1.lineTo(this.particles1[0].x, this.Height)

      this.context1.closePath()
      this.context1.fill()

#     -----------------
#     -----------------

      this.context2.fillStyle = "rgba(120, 120, 120, #{.3 * (1-rate)})";
      this.context2.beginPath()
      for particle, i in this.particles2
        particle.original.x = TweenCalculation(rate, this.tempParticle02[i].x, this.futureParticle02[i].x) #this.futureParticle02[i].x * rate + this.tempParticle02[i].x * (1 - rate)
        particle.original.y = TweenCalculation(rate, this.tempParticle02[i].y, this.futureParticle02[i].y) #this.futureParticle02[i].y * rate + this.tempParticle02[i].y * (1 - rate)

        if i is 0
          previous = this.particles2[this.DETAIL - 1]
        else
          previous = this.particles2[i - 1]

        force = {x:0, y:0}

        force.y += this.DENSITY * (particle.y - particle.original.y) * 40
        force.x += this.DENSITY * (particle.x - particle.original.x) * 40

        particle.velocity.y += -(force.y / particle.mass) + particle.force.y
        particle.velocity.x += -(force.x / particle.mass) + particle.force.x

        particle.velocity.x /= this.FRICTION
        particle.force.x /= this.FRICTION
        particle.x += particle.velocity.x

        particle.velocity.y /= this.FRICTION
        particle.force.y /= this.FRICTION
        particle.y += particle.velocity.y

        if i is 0
          lastPt = {x: (particle.x + previous.x) / 2, y: (particle.y + previous.y) / 2}
          this.context2.moveTo( lastPt.x, lastPt.y)
        else
          this.context2.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

      this.context2.quadraticCurveTo( this.particles2[this.DETAIL - 1].x, this.particles2[this.DETAIL - 1].y, lastPt.x, lastPt.y)
      this.context2.closePath()
      this.context2.fill()

      #     -----------------

      this.context2.fillStyle = "rgba(120, 120, 120, #{ rate })";
      this.context2.beginPath();
      this.context2.moveTo(this.particles1[1].x, this.particles1[1].y)

      for particle, i in this.particles2
        previous = this.particles2[i - 1]
        next = this.particles2[i + 1]
        if previous && next
          this.context2.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

      this.context2.lineTo( this.particles2[this.DETAIL - 1].x, this.particles2[this.DETAIL - 1].y)
      this.context2.lineTo( this.particles2[this.DETAIL - 1].x, this.Height)
      this.context2.lineTo(this.particles2[0].x, this.Height)

      this.context2.closePath()
      this.context2.fill()

    else if rate < 5 && rate > 1 # rate is 1 - 5
      this.context1.fillStyle = "rgba(30, 30, 30, 1)";
      this.context1.beginPath();

      this.context1.moveTo(this.particles1[1].x, this.particles1[1].y)

      for particle, i in this.particles1
        force = {x:0, y:0}

        force.y += this.DENSITY * (particle.y - particle.original.y)
        force.x += this.DENSITY * (particle.x - particle.original.x)

        particle.velocity.y += -(force.y / particle.mass) + particle.force.y
        particle.velocity.x += -(force.x / particle.mass) + particle.force.x

        distance = DistanceBetween(this.mp, particle)
        if(distance < this.AOE)
          distance = DistanceBetween( this.mp, {x: particle.original.x, y:particle.original.y})

          this.ms.x = this.ms.x * 0.98
          this.ms.y = this.ms.y * 0.98

          particle.force.y += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.y;
          particle.force.x += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.x;

        particle.velocity.x /= this.FRICTION
        particle.force.x /= this.FRICTION
        particle.x += particle.velocity.x

        particle.velocity.y /= this.FRICTION
        particle.force.y /= this.FRICTION
        particle.y += particle.velocity.y

        previous = this.particles1[i - 1]
        next = this.particles1[i + 1]

        if previous && next
          this.context1.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

      this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.particles1[this.DETAIL - 1].y)
      this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.Height)
      this.context1.lineTo(this.particles1[0].x, this.Height)

      this.context1.closePath()
      this.context1.fill()

      #     -----------------

      this.context2.fillStyle = "rgba(120, 120, 120, 1)";
      this.context2.beginPath();

      this.context2.moveTo(this.particles2[1].x, this.particles2[1].y)

      for particle, i in this.particles2
        force = {x:0, y:0}

        force.y += this.DENSITY * (particle.y - particle.original.y)
        force.x += this.DENSITY * (particle.x - particle.original.x)

        particle.velocity.y += -(force.y / particle.mass) + particle.force.y
        particle.velocity.x += -(force.x / particle.mass) + particle.force.x

        distance = DistanceBetween(this.mp, particle)
        if(distance < this.AOE)
          distance = DistanceBetween( this.mp, {x: particle.original.x, y:particle.original.y})

          this.ms.x = this.ms.x * 0.98
          this.ms.y = this.ms.y * 0.98

          particle.force.y += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.y;
          particle.force.x += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.x;

        particle.velocity.x /= this.FRICTION
        particle.force.x /= this.FRICTION
        particle.x += particle.velocity.x

        particle.velocity.y /= this.FRICTION
        particle.force.y /= this.FRICTION
        particle.y += particle.velocity.y

        previous = this.particles2[i - 1]
        next = this.particles2[i + 1]

        if previous && next
          this.context2.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

      this.context2.lineTo( this.particles2[this.DETAIL - 1].x, this.particles2[this.DETAIL - 1].y)
      this.context2.lineTo( this.particles2[this.DETAIL - 1].x, this.Height)
      this.context2.lineTo(this.particles2[0].x, this.Height)

      this.context2.fill()
      this.context2.closePath()

    else
      this.TWITCH_INTERVAL = 1.2
      this.twitchTime = 0
      this.wave(0)
      this.shapeID = 2

  wave: (dt)->
    this.twitchTime += dt
    if this.twitchTime > this.TWITCH_INTERVAL
      for i in [1..this.DETAIL-2]
        this.particles1[i].force.x += Math.random() * 10 - 5
        this.particles1[i].force.y += Math.random() * 10 - 5

        this.particles2[i].force.x += Math.random() * 10 - 5
        this.particles2[i].force.y += Math.random() * 10 - 5

      this.twitchTime -= this.TWITCH_INTERVAL

    this.context1.fillStyle = "rgb(30, 30, 30)";
    this.context1.beginPath();
    this.context1.moveTo(this.particles1[1].x, this.particles1[1].y)

    for particle,i in this.particles1

      previous = this.particles1[i - 1]
      next = this.particles1[i + 1]

      if previous && next
#        if i == this.DETAIL - 1

        force = {x:0, y:0}
        force.y += -this.DENSITY * (previous.y - particle.y)
        force.x += -this.DENSITY * (previous.x - particle.x)

        force.y += this.DENSITY * (particle.y - next.y)
        force.x += this.DENSITY * (particle.x - next.x)

        force.y += this.DENSITY / 15 * (particle.y - particle.original.y)
        force.x += this.DENSITY / 15 * (particle.x - particle.original.x)

        particle.velocity.y += -(force.y / particle.mass) + particle.force.y
        particle.velocity.x += -(force.x / particle.mass) + particle.force.x
#
        particle.velocity.x /= this.FRICTION
        particle.force.x /= this.FRICTION
        particle.x += particle.velocity.x

        particle.velocity.y /= this.FRICTION
        particle.force.y /= this.FRICTION
        particle.y += particle.velocity.y

        distance = DistanceBetween(this.mp, particle)
        if(distance < this.AOE)
          distance = DistanceBetween( this.mp, {x: particle.original.x, y:particle.original.y})

          this.ms.x = this.ms.x * 0.98
          this.ms.y = this.ms.y * 0.98

          randomVal = Math.random()
          particle.force.y += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.y * .75 * randomVal;
          particle.force.x += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.x * .75 * randomVal;


        this.context1.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

    this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.particles1[this.DETAIL - 1].y)
    this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.Height)
    this.context1.lineTo(this.particles1[0].x, this.Height)
#    this.context1.lineTo(this.particles1[0].x, this.particles1[0].y)

    this.context1.closePath()
    this.context1.fill()



#    ------------------

    this.context2.fillStyle = "rgb(120, 120, 120)";
    this.context2.beginPath();
    this.context2.moveTo(this.particles2[1].x, this.particles2[1].y)

    for particle,i in this.particles2

      previous = this.particles2[i - 1]
      next = this.particles2[i + 1]

      if previous && next

        force = {x:0, y:0}
        force.y += -this.DENSITY * (previous.y - particle.y)
        force.x += -this.DENSITY * (previous.x - particle.x)

        force.y += this.DENSITY * (particle.y - next.y)
        force.x += this.DENSITY * (particle.x - next.x)

        force.y += this.DENSITY / 15 * (particle.y - particle.original.y)
        force.x += this.DENSITY / 15 * (particle.x - particle.original.x)

        particle.velocity.y += -(force.y / particle.mass) + particle.force.y
        particle.velocity.x += -(force.x / particle.mass) + particle.force.x

        particle.velocity.x /= this.FRICTION
        particle.force.x /= this.FRICTION
        particle.x += particle.velocity.x

        particle.velocity.y /= this.FRICTION
        particle.force.y /= this.FRICTION
        particle.y += particle.velocity.y

        distance = DistanceBetween(this.mp, particle)
        if(distance < this.AOE)
          distance = DistanceBetween( this.mp, {x: particle.original.x, y:particle.original.y})

          this.ms.x = this.ms.x * 0.98
          this.ms.y = this.ms.y * 0.98

          particle.force.y += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.y * .75;
          particle.force.x += (this.Mouse_Pull * ( 1 - (distance / this.AOE) )) * this.ms.x * .75;

        this.context2.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)


    this.context2.lineTo( this.particles2[this.DETAIL - 1].x, this.particles2[this.DETAIL - 1].y)
    this.context2.lineTo( this.particles2[this.DETAIL - 1].x, this.Height)
    this.context2.lineTo(this.particles2[0].x, this.Height)
    this.context2.closePath()
    this.context2.fill()

  waveToOpen: (dt)->
    this.transferTimer += dt
    rate = this.transferTimer / this.transferDuration

    if rate < 1
      this.context1.fillStyle = "rgb(30, 30, 30)";
      this.context1.beginPath();
      this.context1.moveTo(this.particles1[1].x, this.particles1[1].y)

      for particle, i in this.particles1
        particle.original.y = TweenCalculation(rate, this.tempParticle01[i].y, this.futureParticle01[i].y)

        force = {y:0}
        force.y += this.DENSITY * (particle.y - particle.original.y)

        particle.velocity.y += -(force.y / particle.mass) + particle.force.y

        particle.velocity.y /= this.FRICTION
        particle.force.y /= this.FRICTION
        particle.y += particle.velocity.y

        previous = this.particles1[i - 1]
        next = this.particles1[i + 1]
        if previous && next
          this.context1.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)

      this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.particles1[this.DETAIL - 1].y)
      this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.Height)
      this.context1.lineTo(this.particles1[0].x, this.Height)

      this.context1.closePath()
      this.context1.fill()

    else if rate > 1 && rate < 3
      this.context1.fillStyle = "rgba(30, 30, 30, #{(3 - rate) * (3 - rate) / 4})";
      this.context1.beginPath();
      this.context1.moveTo(this.particles1[1].x, this.particles1[1].y)

      for particle, i in this.particles1
        force = {y:0}
        force.y += this.DENSITY * (particle.y - particle.original.y)

        particle.velocity.y += -(force.y / particle.mass) + particle.force.y

        particle.velocity.y /= this.FRICTION
        particle.force.y /= this.FRICTION
        particle.y += particle.velocity.y


        previous = this.particles1[i - 1]
        next = this.particles1[i + 1]

        if previous && next
          this.context1.quadraticCurveTo( previous.x, previous.y, (previous.x + particle.x)/ 2, (previous.y + particle.y)/ 2)
      this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.particles1[this.DETAIL - 1].y)
      this.context1.lineTo( this.particles1[this.DETAIL - 1].x, this.Height)
      this.context1.lineTo(this.particles1[0].x, this.Height)

      this.context1.closePath()
      this.context1.fill()
    else
      this.particleObjectAnimation = false

  resize: (event)->
    prevWid = this.Width
    prevHig = this.Height

    this.Width = window.innerWidth
    this.Height = window.innerHeight


    if this.shapeID < 1
      dx = (this.Width - prevWid) / 2
      dy = (this.Height - prevHig) / 2

      for particle in this.particles1
        particle.original.x += dx
        particle.original.y += dy

      for particle in this.particles2
        particle.original.x += dx
        particle.original.y += dy

    else
#      console.log(this.Width)


#      for particle,i in this.particles1
      for i in [0..this.DETAIL-1]
        xPos = this.Width / (this.DETAIL - 5) * (i - 2)

        this.particles1[i].x = xPos
        this.particles1[i].y =  3/5 * this.Height

        this.particles1[i].original.x = xPos
        this.particles1[i].original.y =  3/5 * this.Height

#        ---------------

        this.particles2[i].x = xPos
        this.particles2[i].y = 2 / 5 * this.Height

        this.particles2[i].original.x = xPos
        this.particles2[i].original.y = 2 / 5 * this.Height

