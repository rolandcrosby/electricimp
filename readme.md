# Electric Imp LED strip controller 

This code is what I used to control a [Seeed Grove LED Strip Driver](http://www.seeedstudio.com/depot/Grove-LED-Strip-Driver-p-1197.html) with an [Electric Imp](https://www.sparkfun.com/products/11395).

Components:

* **imp** -- Electric Imp agent and device code. Exposes an HTTP endpoint on Electric Imp's hosted service that lets you send commands to control an LED strip driver.
* **html** -- Basic mobile web page to control a two-channel LED strip by making requests to that endpoint.
