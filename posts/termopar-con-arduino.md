---
title: Termopar con Arduino
author: cnidario
date: 2020-01-07
publishDate: 2020-01-07
tags:
- arduino
categories: 
- electronics
draft: true
---

## Termopares (o termocuplas)

Debido al [efecto termoeléctrico](https://es.wikipedia.org/wiki/Efecto%5Ftermoel%C3%A9ctrico) se genera un campo eléctrico a través de un conductor debido a diferencias de temperatura.
Un [termopar](https://es.wikipedia.org/wiki/Termopar) se vale de este efecto, juntando dos metales y controlando la temperatura de la unión (llamada unión fría), se producirán variaciones de voltaje debido
a cambios de temperatura en el extremo. Permiten conseguir un **amplio rango** de medidas y **alta precisión**.

![Esquema de termocupla](../img/scheme-thermocouple.png "Esquema de termocupla")

Según el modo de fabricación se agrupan en distintos tipos. Usé un termopar tipo K que se construye con cromel y alumel. 1,60€ por Aliexpress.

![Mi termopar tipo K](../img/termopar-tipo-k.jpg "Mi termopar tipo K")

La temperatura no es una medida absoluta. Sino que viene en función de la diferencia de temperatura entre los extremos de la unión y de donde se conecte el voltímetro. Por lo que
necesitamos controlar o conocer la temperatura de este último. A esto es lo que se llama _cold junction compensation_


## Utilización del termopar

Las señales son muy pequeñas y se deben amplificar. Además hay que compensarlas con las de la unión fría. Finalmente para llevarlas a un sistema digital habrá que hacer la conversión.
Hay muchos ICs que traen todas estas funciones ya empaquetadas. Yo usé el [MAX31855](https://datasheets.maximintegrated.com/en/ds/MAX31855.pdf) que es una versión mejorada del MAX6675 (creo que la única diferencia es la resolución del ADC 14-bits
vs 12 en el 6675). 1,57€ en Aliexpress.


## MAX31855

Es un IC especializado para termocuplas tipo K. Nos da temperaturas con resolución de 0.25ºC y permite medidas en un rango (-270ºC, 1800ºC).
Con una exactitud de +-2ºC en el rango (-200ºC, 700ºC).

![Uso del MAX31855](../img/max31855/application-diagram.png "Uso del MAX31855")


### Uso del MAX31855

Para interface con el micro utiliza SPI de sólo lectura. En flanco ascendente y polaridad GND. Opera a un máximo de 5MHz. Todo esto se saca de la especificación del [MAX31855](https://datasheets.maximintegrated.com/en/ds/MAX31855.pdf).

![Diagrama de señales de la comunicación por SPI](../img/max31855/spi-clk-diagram.png "Diagrama de señales de la comunicación por SPI")

![](../img/max31855/spi-data.png)

Utilicé el SPI hardware que tiene el Arduino Uno
(es decir el del ATmega328P). Por eso hay que utilizar los pin específicos que son del 13 al 11, dejando el de selección de chip a libre elección (i.e. controlado por software).
Así utilizaré la librería SPI de Arduino directamente.

![](../img/max31855/reading-map.png)

![](../img/max31855/reading-map-descs.png)
