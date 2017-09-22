# Julia_On_Development_Boards
Using the Julia language with a Raspberry Pi, Beaglebone Black, UDOOx86, and NanoPi Duo

This is a work in progress. I am developing some ideas of being able to remotely control the GPIO pins on different development boards from the Julia language. I have 5 computers on a Beowulf cluster: a Dell Optiplex 755, a Raspberry Pi 3, a Beaglebone Black, a UDOOX86, and a NanoPi Duo. The Dell Optiplex 755 acts as the master node with the development boards acting as slave nodes. I want to be able to read and write to GPIO pins from the master node. A scenario would be to have each development board connected to different sensors. The boards might trigger an LED or something when a threshold is reached and report it to the master node. Of course, the world is wide open with applications.

See the videos for a demonstration: https://photos.app.goo.gl/0j8f1OwTQFWWTD052, https://photos.app.goo.gl/EI4JTKJqKwtJOWzk2
