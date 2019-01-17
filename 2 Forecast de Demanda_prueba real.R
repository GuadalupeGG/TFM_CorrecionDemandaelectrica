
##### Cargamos librerias #####

# Primero de todo, si es necesario instalamos libreria y la cargamos

if (!require("forecast")){
  install.packages("forecast") 
  library(forecast)
}

if (!require("lubridate")){
  install.packages("lubridate") 
  library(lubridate)
}

## -------------------------------------------------------------------------

##### Establecemos directorio de trabajo #####

setwd("~/TFM/TFM_CorrecionDemandaelectric")

## -------------------------------------------------------------------------

##### Cargamos los datos #####

# Cargo el data frame resultado del notebook de python

Medidas=read.csv2("./Modelo/Bridgestone.csv",stringsAsFactors = FALSE, sep = ',')

## -------------------------------------------------------------------------

##### Hacemos una revisión de los datos del data frame #####


str(Medidas)
summary(Medidas)
head(Medidas)
tail(Medidas)

## -------------------------------------------------------------------------

##### Formateamos las variables #####


Medidas$Cups=as.factor(Medidas$Cups)


Medidas$Active=as.numeric(Medidas$Active)

# para asegurarnos que las fechas tienen un formato correcto
lct <- Sys.getlocale("LC_TIME"); Sys.setlocale("LC_TIME", "Spanish_Spain.1252") 

Medidas$datetime=ymd_hms(Medidas$datetime)

# para poner todas las fechas en el mismo formato

Sys.setlocale("LC_TIME", lct) 

# Volvemos a revisar los datos

str(Medidas)
head(Medidas)
summary(Medidas)

## -------------------------------------------------------------------------

##### Seleccionamos los datos a pasar a los modelos #####

#Aunque el fichero trae medida de cuatro puntos, vamos realizar el estudio del punto 3.

Medidas_1=Medidas[Medidas$Cups=="Cups_3",]

# Revisamos los datos de este filtro de datos

str(Medidas_1)
head(Medidas_1)
summary(Medidas_1)

Medidas_1=Medidas_1[order(Medidas_1$datetime),]
plot(Medidas_1$Active, type="l")
plot(Medidas_1$datetime,Medidas_1$Active, type="l")

## -------------------------------------------------------------------------

##### Seleccionamos las fechas para el analisis y el periodo #####

FECHA_ANALISIS=as.Date("2018-11-15")
PERIODO_PREVIO=140
PERIODO_PRUEBA=7


Medidas_1_HIS=Medidas_1[Medidas_1$datetime<=FECHA_ANALISIS & Medidas_1$datetime>FECHA_ANALISIS-PERIODO_PREVIO,]
Medidas_1_NEW=Medidas_1[Medidas_1$datetime<=FECHA_ANALISIS + PERIODO_PRUEBA & Medidas_1$datetime>FECHA_ANALISIS,c("datetime","Active")]

plot(Medidas_1_HIS$datetime,Medidas_1_HIS$Active, type="l")
plot(Medidas_1_NEW$datetime,Medidas_1_NEW$Active, type="l")

## -------------------------------------------------------------------------

##### Formateo de Serie Temporal #####

# le damos un patron de estacionalidad de 365 días
Centro = ts(Medidas_1_HIS$Active,start=c(2017,07,01), frequency=365) 

# Vemos un resumen completo de la serie temporal donde el grafico ACF es la autocorrealción y el grafico PACF es el grafico de autocorrelación parcial
tsdisplay(Centro)

# Vamos a descomponer esta serie temporal en los tres componentes principales: estacionalidad + tendencia + ruido

des.oro<-stl(Centro,s.window = "periodic" )
plot(des.oro, main="Descomposición de la demanda electrica")
plot(decompose(Centro))


plot(Centro)
print(Centro)

Medidas_ts = ts(Medidas_1_HIS$Active, start = c(2017,07,01),  frequency = 365)

## -------------------------------------------------------------------------

##### MODELO ARIMA #####

#(o modelos de media movil integrada autoregresiva)
# El modelo Auto Arima prueba todas las opciones que hay y elige en mejor.

help(auto.arima)

model_arima=auto.arima(Centro,seasonal=TRUE,trace=TRUE,stepwise=FALSE) 
plot(forecast(model_arima,h=24)) # muestrame los 24 siguientes datos

# Calculamos los residuos de nuestro modelo
checkresiduals(model_arima)
summary(model_arima)

# Pintamos el pronostico para un año
model_arima %>% forecast(h = 24) %>% autoplot()
forecast(model_arima,h=24)

Medidas_1_NEW$Arima=forecast(model_arima,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### MEDIDA MOVIL #####

model_ma=ma(Medidas_ts,order=3)
summary(model_ma)
plot(forecast(model_ma, fan=TRUE,h=24))
forecast(model_ma, level=c(80,95),h=24)

Medidas_1_NEW$MA=forecast(model_ma,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### HOLT-WINTERS #####

model_hw=HoltWinters(Medidas_ts)
summary(model_hw)
plot(forecast(model_hw, fan=TRUE,h=24))
forecast(model_hw,level=c(80,95),h=24)

Medidas_1_NEW$HW=forecast(model_hw,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### MODELO LINEAL #####

model_tslm=tslm(Medidas_ts~trend + season,data=Medidas_ts)
summary(model_tslm)
plot(forecast(model_tslm, fan=TRUE,h=24))
forecast(model_tslm,level=c(80,95),h=24)

Medidas_1_NEW$tslm=forecast(model_tslm,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### PRESENTACION RESULTADOS #####

YMAX=max(Medidas_1_NEW[,-1])
YMIN=min(Medidas_1_NEW[,-1])

plot(Medidas_1_NEW$Active,type="l", ylim=c(YMIN,YMAX),lwd=2)
lines(c(Medidas_1_NEW$Arima),col="blue")
lines(c(Medidas_1_NEW$MA),col="red") # las ventas de hoy son la media de los tres ultimos dias. Tiene sentido sin estacionalidad, pero no con ella.
lines(c(Medidas_1_NEW$HW),col="green")
lines(c(Medidas_1_NEW$tslm),col="cyan")

Medidas_1_NEW

## -------------------------------------------------------------------------

# A la vista de los resultado mis modelos de predicción de demandas son altamente mejorables. 
# Con estos resultados vemos que el que mejor funciona es el modelo ARIMA a pesar que también es muy mejorable. 
# Pero con el tiempo de que he dispuesto es el resultado al que he llegado.