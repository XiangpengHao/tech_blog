---
title: "My Privacy Preserved Smart Home"
date: 2019-12-15T22:48:32-08:00
draft: false 
---

I've been looking for an ultimate smart home solution for a while, yet none of them fit my needs.

In an ideal world, a smart home will have the following features:

1. What happens in my room stays in my room. Privacy is my first concern when considering a smart home. I don't trust big evil companies. Thus any products from Google or Amazon lose the competition.

2. It should be highly customizable. I have an indoor Pachira Aquatica, which needs extra plant light during the daytime. But the plant light is annoying that I would like to turn it off when I'm at home. I also want to turn off my lamp when I'm not at home. 

3. It should be hassle-free. No ads, no unrelated notifications, no intrusive messages. It should just work.

Unfortunately, none of the existing smart home solutions meet these requirements. So I decided to build my own, and it turns out to be cheap and straightforward.

### Architecture

<img src="/img/smart_home.png" height="500px" />

The figure above shows the overall architecture of my smart home solution. 
Three services can manipulate the room state: the telegram bot, the smartwatch, and the sensors. 

The user (me) can manually toggle the lights via Telegram messages or smartwatch buttons, and the sensors can turn on the light when detecting the user arrives home and turn off when detecting leaving.

The end devices (light bulbs, sensors) are either physically connected to the raspberry pi or logically connect to third party service. 
Thus a low-power raspberry pi can control them all.


### Real world build

The project is fully open sourced at https://github.com/XiangpengHao/IoTHome, feel free to star or create issues!

The total loc is less than 300 in **asynchronous** Python!

**The e-paper display and sensors**

1. Adafruit AM 2302 humidity and temperature sensor
2. PIR motion sensor
3. Acrylic board & M3 screws to support the sensors
4. Waveshare e-paper, from Taobao
![](https://raw.githubusercontent.com/XiangpengHao/IoTHome/master/images/smart_home.jpg)


**Altogether**
![](https://raw.githubusercontent.com/XiangpengHao/IoTHome/master/images/plant-may.png)
