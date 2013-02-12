window.requestAnimationFrame = do ->
  window.requestAnimationFrame       ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback) -> window.setTimeout(callback, 1000 / 60)

canvas01 = document.getElementById 'myCanvas'
canvas02 = document.getElementById 'myUraCanvas'

contex01 = canvas01.getContext("2d")
contex02 = canvas02.getContext("2d")

wid = window.innerWidth
hig = window.innerHeight

canvas01.width = window.innerWidth
canvas01.height = window.innerHeight

canvas02.width = window.innerWidth
canvas02.height = window.innerHeight

myParticleObject = new ParticleObject contex01, contex02
myParticleObject.init()
myParticleObject.resetTimer()


step =  ->
  if(myParticleObject.particleObjectAnimation)
    requestAnimationFrame(step)
    contex01.clearRect(0, 0, wid, hig)
    contex02.clearRect(0, 0, wid, hig)

    myParticleObject.update()


step()

#-------------------
#--- mouse event ---
#-------------------
click = (event)->
  myParticleObject.transfer()
#  alert("click");



$(window).bind 'click', (event)->
  click(event)

$(window).bind 'resize', (event)->
  if(myParticleObject.particleObjectAnimation)
    wid = window.innerWidth
    hig = window.innerHeight

    canvas01.width = wid
    canvas01.height = hig
    canvas02.width = wid
    canvas02.height = hig

    myParticleObject.resize(event)