## -------------------------------------------------------------------------
## SCRIPT: Clustering de clientes RFM.R
## CURSO: Master en Data Science
## PROFESOR: Antonio Pita
## Paquetes Necesarios: forecast
## -------------------------------------------------------------------------

## -------------------------------------------------------------------------

##### 1. Bloque de inicializacion de librerias y establecimiento de directorio #####

if (!require("forecast")){
  install.packages("forecast") 
  library(forecast)
}

## -------------------------------------------------------------------------

##### 2. Bloque de establecimiento de directorio #####

setwd("D:/Documentos, Trabajos y Demás/Formación/Kschool/201711 Clase V Master Data Science/6 Casos de Exito de Negocio")

## -------------------------------------------------------------------------

##### 3. Bloque de carga de datos #####



Medidas=read.csv2("./data/Medidas_Manual.csv",stringsAsFactors = FALSE)
## -------------------------------------------------------------------------

##### 4. Bloque de revisión básica del dataset #####


str(Medidas)
summary(Medidas)
head(Medidas)
tail(Medidas)

## -------------------------------------------------------------------------

##### 5. Bloque de formateo de variables #####


Medidas$Provincia=as.factor(Medidas$Provincia)

lct <- Sys.getlocale("LC_TIME"); Sys.setlocale("LC_TIME", "Spanish_Spain.1252") # para poner las fechas en buen formato


Medidas$Fecha=as.Date(Medidas$Fecha, format="%d/%m/%y")

Sys.setlocale("LC_TIME", lct) # para poner las fechas en el mismo formato todos

str(Medidas)
head(Medidas)
summary(Medidas)

## -------------------------------------------------------------------------

##### 6. Bloque de selección de producto #####

Medidas_Madrid=Medidas[Medidas$Provincia=="Madrid",]

str(Medidas_Madrid)
head(Medidas_Madrid)
summary(Medidas_Madrid)

Medidas_Madrid=Medidas_Madrid[order(Medidas_Madrid$Fecha),]
plot(Medidas_Madrid$Tanto1, type="l")
plot(Medidas_Madrid$Fecha,Medidas_Madrid$Tanto1, type="l")


## -------------------------------------------------------------------------

##### 7. Bloque de selección de fecha de analisis y periodo #####

FECHA_ANALISIS=as.Date("2018-01-01")
PERIODO_PREVIO=365
PERIODO_PRUEBA=140


Medidas_Madrid_HIS=Medidas_Madrid[Medidas_Madrid$Fecha<=FECHA_ANALISIS & Medidas_Madrid$Fecha>FECHA_ANALISIS-PERIODO_PREVIO,]
Medidas_Madrid_NEW=Medidas_Madrid[Medidas_Madrid$Fecha<=FECHA_ANALISIS + PERIODO_PRUEBA & Medidas_Madrid$Fecha>FECHA_ANALISIS,c("Fecha","Tanto1")]

plot(Medidas_Albacete_HIS$Fecha,Medidas_Albacete_HIS$Tanto1, type="l")
plot(Medidas_Albacete_NEW$Fecha,Medidas_Albacete_NEW$Tanto1, type="l")

## -------------------------------------------------------------------------

##### 8. Bloque de formateo de serie #####

Madrid = ts(Medidas_Madrid_HIS$Tanto1,start=c(2017,1,1),end = c(2018,1,1),frequency=7) # frequency, porque el patron de estacionalidad son días, 7 días de la semana
plot(Madrid)
print(Madrid)

Medidas_ts = ts(Medidas$VALUE, start = c(2017,1,1), frequency = 7)
## -------------------------------------------------------------------------

##### 9. Bloque de modelo Arima #####

model_arima=auto.arima(Madrid,seasonal=TRUE,trace=TRUE) # el prueba todos los que hay y elige en mejor.
plot(forecast(model_arima,h=24)) # muestrame los 24 siguientes datos
summary(model_arima)
forecast(model_arima,h=24)
Albacete$Arima=forecast(model_arima,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### 10. Bloque de modelo Media Movil #####

model_ma=ma(Ventas_ts,order=3)
summary(model_ma)
plot(forecast(model_ma, fan=TRUE,h=24))
forecast(model_ma, level=c(80,95),h=24)

Ventas_A0351_NEW$MA=forecast(model_ma,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### 11. Bloque de modelo Holt-Winters #####

model_hw=HoltWinters(Ventas_ts)
summary(model_hw)
plot(forecast(model_hw, fan=TRUE,h=24))
forecast(model_hw,level=c(80,95),h=24)

Ventas_A0351_NEW$HW=forecast(model_hw,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### 12. Bloque de modelo lineal #####

model_tslm=tslm(Ventas_ts~trend + season,data=Ventas_ts)
summary(model_tslm)
plot(forecast(model_tslm, fan=TRUE,h=24))
forecast(model_tslm,level=c(80,95),h=24)

Ventas_A0351_NEW$tslm=forecast(model_tslm,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### 13. Bloque de presentación de resultados #####

YMAX=max(Ventas_A0351_NEW[,-1])
YMIN=min(Ventas_A0351_NEW[,-1])

plot(Ventas_A0351_NEW$Cantidad,type="l", ylim=c(YMIN,YMAX),lwd=2)
lines(c(Ventas_A0351_NEW$Arima),col="blue")
lines(c(Ventas_A0351_NEW$MA),col="red") # las ventas de hoy son la media de los tres ultimos dias. Tiene sentido sin estacionalidad, pero no con ella.
lines(c(Ventas_A0351_NEW$HW),col="green")
lines(c(Ventas_A0351_NEW$tslm),col="cyan")

Ventas_A0351_NEW

## -------------------------------------------------------------------------