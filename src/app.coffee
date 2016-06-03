# hardware control
wpi = require 'wiring-pi'

wpi.setup 'wpi'

# pin setup
wpi.pinMode 1, wpi.INPUT # hall sensor input
wpi.pullUpDnControl 1, wpi.PUD_UP

# motor control
wpi.pinMode 4, wpi.OUTPUT
wpi.pinMode 5, wpi.OUTPUT

Door = ->
    startClosing = ->
        wpi.digitalWrite(5, wpi.LOW)
        wpi.digitalWrite(4, wpi.HIGH)
    startOpening = ->
        wpi.digitalWrite(4, wpi.LOW)
        wpi.digitalWrite(5, wpi.HIGH)
    stop = ->
        wpi.digitalWrite(4, wpi.LOW)
        wpi.digitalWrite(5, wpi.LOW)
    detectEnd = (callback) ->
        end = no
        onEnd = (error) ->
            return if end
            end = yes
            wpi.wiringPiISRCancel 1 if error
            stop()
            callback?(error)
        setTimeout onEnd.bind(this, yes), 7000
        wpi.wiringPiISR 1, wpi.INT_EDGE_FALLING, onEnd.bind(this, no)
    halfClose = (callback) ->
        startClosing()
        detectEnd callback
    halfOpen = (callback) ->
        startOpening()
        detectEnd callback
    return {
        close: (callback) ->
            halfClose (err) ->
                callback?(err) if err
                halfClose(callback) unless err
        open: (callback) ->
            halfOpen (err) ->
                callback?(err) if err
                halfOpen(callback) unless err
    }
door = Door()

# server link
socket = require('socket.io-client')('http://abonetti.fr:3005/')
socket.on 'connect', ->
    console.log 'Connected to the server'
socket.on 'disconnect', ->
    console.log 'Disconnected from the server'

socket.on 'close', ->
    door.close (err) ->
        socket.emit 'closed', err
socket.on 'open', ->
    door.open (err) ->
        socket.emit 'opened', err

door.open (err) ->
    console.log "open, error : ", err
    door.close (err) ->
    	console.log "close, error : ", err
