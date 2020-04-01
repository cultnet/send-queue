export !function MultiSend
  queues = {}
  
  get-queue = (name) ~>
    if not queues.has-own-property name
      queues[name] = new SubQueue!
    queues[name]

  @push = (name, action) ~>
    queue = get-queue name
    queue.push action

  @throttle = (name, ms) ~>
    queue = get-queue name
    queue.throttle ms
  
  @purge = (name) ~>
    if queues.has-own-property name
      queues[name].purge!

export !function SendQueue
  throttle-ms = 1000
  sends = []
  timeout = null
  last-shift = null

  @push = (send) !~>
    sends.push send
    if timeout is null
      wait = Math.max 0 (throttle-ms - (Date.now! - last-shift))
      timeout := set-timeout fire, wait

  fire = ~>>
    send = sends.shift!
    last-shift := Date.now!
    try
      await send!
    catch e
      console.log e
    finally
      timeout :=
        if sends.length is 0 then null
        else set-timeout fire, throttle-ms

  @purge = !~>
    sends.splice(0);
    if timeout isnt null
      clear-timeout timeout
      timeout := null
  
  @throttle = !~> throttle-ms := it
