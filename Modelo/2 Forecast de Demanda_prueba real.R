
##### Cargamos librerias #####

# Primero de todo, si es necesario instalamos libreria y la cargamos

if (!require("forecast")){
  install.packages("forecast") 
  library(forecast)
}

## -------------------------------------------------------------------------

##### Establecemos directorio de trabajo #####

setwd("~/TFM/TFM_CorrecionDemandaelectric")

## -------------------------------------------------------------------------

##### Cargamos los datos #####

# Cargo el data frame resultado del notebook de python

Medidas=read.csv2("./df_group_sum.csv",stringsAsFactors = FALSE, sep = ',')

## -------------------------------------------------------------------------

##### Hacemos una revisión de los datos del data frame #####


str(Medidas)
summary(Medidas)
head(Medidas)
tail(Medidas)

## -------------------------------------------------------------------------

##### Formateamos las variables #####


Medidas$Zona=as.factor(Medidas$Zona)
Medidas$Tarifa=as.factor(Medidas$Tarifa)

Medidas$Active=as.numeric(Medidas$Active)

# para asegurarnos que las fechas tienen un formato correcto
lct <- Sys.getlocale("LC_TIME"); Sys.setlocale("LC_TIME", "Spanish_Spain.1252") 

Medidas$Fecha=as.Date(Medidas$Fecha)

# para poner todas las fechas en el mismo formato

Sys.setlocale("LC_TIME", lct) 

# Volvemos a revisar los datos

str(Medidas)
head(Medidas)
summary(Medidas)

## -------------------------------------------------------------------------

##### Seleccionamos los datos a pasar a los modelos #####

Medidas_Centro=Medidas[Medidas$Zona=="Centro" & Medidas$Tarifa=='2A',]

# Revisamos los datos de este filtro de datos

str(Medidas_Centro)
head(Medidas_Centro)
summary(Medidas_Centro)

Medidas_Centro=Medidas_Centro[order(Medidas_Centro$Fecha),]
plot(Medidas_Centro$Active, type="l")
plot(Medidas_Centro$Fecha,Medidas_Centro$Active, type="l")


## -------------------------------------------------------------------------

##### Seleccionamos las fechas para el analisis y el periodo #####

FECHA_ANALISIS=as.Date("2018-07-31")
PERIODO_PREVIO=140
PERIODO_PRUEBA=31


Medidas_Centro_HIS=Medidas_Centro[Medidas_Centro$Fecha<=FECHA_ANALISIS & Medidas_Centro$Fecha>FECHA_ANALISIS-PERIODO_PREVIO,]
Medidas_Centro_NEW=Medidas_Centro[Medidas_Centro$Fecha<=FECHA_ANALISIS + PERIODO_PRUEBA & Medidas_Centro$Fecha>FECHA_ANALISIS,c("Fecha","Active")]

plot(Medidas_Centro_HIS$Fecha,Medidas_Centro_HIS$Active, type="l")
plot(Medidas_Centro_NEW$Fecha,Medidas_Centro_NEW$Active, type="l")

## -------------------------------------------------------------------------

##### 8. Bloque de formateo de serie #####

Centro = ts(Medidas_Centro_HIS$Active,start=c(2018,01,01), end = c(2018,12,31),frequency=7) # frequency, porque el patron de estacionalidad son días, 7 días de la semana
plot(Centro)
print(Centro)

Medidas_ts = ts(Medidas$Active, start = c(2018,01,01), end = c(2018,12,31), frequency = 7)
## -------------------------------------------------------------------------

##### 9. Bloque de modelo Arima #####

model_arima=auto.arima(Centro,seasonal=TRUE,trace=TRUE) # el prueba todos los que hay y elige en mejor.
plot(forecast(model_arima,h=24)) # muestrame los 24 siguientes datos
summary(model_arima)
forecast(model_arima,h=24)
Centro$Arima=forecast(model_arima,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### 10. Bloque de modelo Media Movil #####

model_ma=ma(Medidas_ts,order=3)
summary(model_ma)
plot(forecast(model_ma, fan=TRUE,h=24))
forecast(model_ma, level=c(80,95),h=24)

Medidas_Centro_NEW$MA=forecast(model_ma,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### 11. Bloque de modelo Holt-Winters #####

model_hw=HoltWinters(Medidas_ts)
summary(model_hw)
plot(forecast(model_hw, fan=TRUE,h=24))
forecast(model_hw,level=c(80,95),h=24)

Medidas_Centro_NEW$HW=forecast(model_hw,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### 12. Bloque de modelo lineal #####

model_tslm=tslm(Medidas_ts~trend + season,data=Medidas_ts)
summary(model_tslm)
plot(forecast(model_tslm, fan=TRUE,h=24))
forecast(model_tslm,level=c(80,95),h=24)

Medidas_Centro_NEW$tslm=forecast(model_tslm,h=PERIODO_PRUEBA)$mean

## -------------------------------------------------------------------------

##### 13. Bloque de presentación de resultados #####

YMAX=max(Medidas_Centro_NEW[,-1])
YMIN=min(Medidas_Centro_NEW[,-1])

plot(Medidas_Centro_NEW$Active,type="l", ylim=c(YMIN,YMAX),lwd=2)
lines(c(Medidas_Centro_NEW$Arima),col="blue")
lines(c(Medidas_Centro_NEW$MA),col="red") # las ventas de hoy son la media de los tres ultimos dias. Tiene sentido sin estacionalidad, pero no con ella.
lines(c(Medidas_Centro_NEW$HW),col="green")
lines(c(Medidas_Centro_NEW$tslm),col="cyan")

Medidas_Centro_NEW

## -------------------------------------------------------------------------