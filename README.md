# TFM_CorrecionDemandaelectrica

La idea inicial de este TFM era crear un modelo que corrigiese la demanda electrica en función de las temperaturas esperadas. 

Actualmente trabajo con curvas de consumo de clientes, y tenemos comprobado, que para el cliente de baja tensión las olas de calor y las olas de frio afectan directamente en su consumo eléctrico, pero no tenemos ninguna herramienta que nos mida esa relación para que podamos corregir la compra de energía.

Sin embargo, debido a la dificultad que he tenido para conseguir los data set de medidas, he ido modificando el trabajo en función de los datos de los que dispongo.

Por motimos de confidencialidad el data set original de medidas no lo puedo subir a la plataforma, y la unica información que puedo subir es la medida agregada por zona geografica, por tarifa y por fecha y hora. 

He intentado reflejar la vida real de una comercializadora de electricidad con aproximadamente 5000 puntos de baja tensión, pero he tenido que ir simplificando mi escenario según iba tratando mi data set de medidas. 

Para obtener mi data set de medidas he dependido de que el equipo de IT de mi empresa me realizase una extracción de la bbdd de medidas, ya que por seguridad no se permite que nadie ajeno a este equipo realice consultas en la misma. Además, por temas de confidencialidad, por tema de los tiempos de los equipos, he tardado mucho mas delo esperado en conseguirlo, por lo que no he dispuesto del tiempo necesario para estudiarlo, tratarlo, limpiarlo y tomar las decisiones oportunas.

Por esta razón he tenido que ir moldeando y dando forma a este proyecto sobre la marcha intentando adaptarme a los problemas que han ido surgiendo.

# Detalle del proceso

A continuación paso a detallar como ha ido evolucionando mi proyecto cronologicamente: 

### Temperaturas_SGE.ipynb

En este notebook descargamos las temperaturas desde el dia 01/01/2017 por provincia, Fecha y Hora. Esta consulta nos devuelve un fichero csv que contiene las medidas de temperatura, o la previsión si fuese a futuro, de cada una de las estaciones metereologicas de España. Esta bbdd de temperaturas la tengo en mi trabajo alimentada por AEMET, por lo que no se puede reproducir el funcionamiento del notebook al no poder conectarse desde fuera de mi entorno de trabajo.

### Tratamiento temperaturas.ipynb

En este notebook trato el fichero descargado con el notebook anterior, limpiandolo y dejandolo listo para utlizar en los siguientes pasos.

### Tratamiento curvas.ipynb

Este es el notebook original con el que empiezo a tratar mi data set de medidas, en el mismo voy poniendo paso a paso lo que voy haciendo con mi data set, y voy comentando los problemas que me van surgiendo. Es en este notebook donde me voy dando cuenta que mi idea original no se puede llevar a termino y que me tengo que readaptar.

### Tratamiento curvas_2.ipynb

Una vez vistos los problemas del notebook anterior, no me queda mas remedio que ir transformando mi idea original. Al ver que no tengo toda los datos necesario para una red neuronal la descarto por completo. Si solo tengo un año de medidas mi modelo no podría aprender, sino solo replicar lo que pasó en 2018.

Por este motivo empiezo este nuevo notebook, me adapto a los datos de medidas de 2018, ya que veo que los perfiles de consumo de los que dispongo son totalmente diferentes para 2017 y 2018, mi data set está sesgado, tengo datos de muy poco puntos de medida. 

Por este motivo y para intentar solucionar estos problemas utilizo solo las curvas de medida de aquellos puntos para los que tengo la curva completa.

### Analisis de datos.ipynb

Este notebook tiene algunos graficos donde podemos ver las relaciones entre variables, y algunas maneras graficas de ver la información de la que dispongo.

### Modelo/Forecast de Demanda_prueba real.R

En este notebook de R intento utilizar las herramientas de que dispongo para predecir la demanda electrica de las proximas 24 horas utilizando varios modelos para ver cual se adapta mejor a la realidad.

En este caso, he seguido simplificando, y utilizado las curvas de consumo de cuatro clientes con los que tenemos problemas para predecir la demanda electrica. Son cuatro clientes que en mi trabajo me están generando mucho desvío, sigo intentando solucionar un problema real que tras este TFM pueda implementar en mi trabajo.

# Detalle datos

Los consumidores electricos en nuestro país se catalogan en función de su potencia contratada, según la potencia que cada consumidor contrata se le asigna una tarifa electrica u otra. 

### CUPS

Codigo universal de punto de suministro. Este es el codigo unico e invariable que tiene cada consumidor electrico. Un contrato de electricidad puede cambiar de titular pero no de CUPS. 

### Tarifa electrica

En el caso que nos aplica nos vamos centrar unicamente en las tarifas electricas de baja tensión, que son:

# 2.0A: Potencia contratada inferior o igual a 10KWh
# 2.1A: Potencia contratada entre 10KWh y 15KWh
# 2.0DHA: Potencia contratada inferior o igual a 10KWh
# 2.1DHA: Potencia contratada entre 10KWh y 15KWh

En lo que a perfiles de consumo se refiere las tarifas 2.0A y 2.1A son similares, y la tarifa 2.0DHA y la tarifa 2.1DHA también. Las tarifas 2.0A y 2.1A se caracterizan por no tener discriminación horaria.

