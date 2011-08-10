# There's some wierd interaction between Connfu::Queue::Resque and resque_unit that means we need to do this
# This is probably another indication that the current way of hiding the queue implementation in Connfu is flawed
Connfu::Queue.implementation = ::Resque