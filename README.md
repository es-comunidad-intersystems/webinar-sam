# webinar-sam
## Monitorizando InterSystems IRIS con Grafana y Prometheus, usando Intersystem SAM

![image](https://user-images.githubusercontent.com/3267753/171156424-4173e400-2db3-4cbb-8002-19960f1788f1.png)

## Introducción
SAM o "System Alerting and Monitoring" es la infrastructura de Intersystems para la monitorización de instancias de Intersystems IRIS. Basado en las herramientas open-source Prometheus y Grafana, SAM permite agrupar en un cluster multiples instancias de IRIS locales o remotas a monitorizar como una sola entidad. Grafana proporciona Dashboards pre-construidos y extensibles, y Prometheus permite añadir reglas y gestionar alertas con su componente AlertManager.
La Monitorización esta compuesta de 2 partes:

* Cada InterSystems IRIS 2020.1(o más reciente) incluye 2 APIs que exponen Metricas y Alertas
* El componente SAM se connecta a los sistemas monitorizados y proporciona cuadros de mandos y gestiona alertas

SAM es extensible y permite:
* Añadir facilmente metricas de aplicación adicionales
* Usar PromQL para definir nuevas reglas y generar alertas
* Modificar o Crear nuevos Cuadros de mando de Grafana
* mantener un historico de las metricas dentr

El componente SAM se instala en forma de un docker-compose (disponible en wrc.intersystems.com) que arranca los varios componentes docker.

## ¿Qué necesitas?
* Docker y docker-compose - para arrancar el componente SAM, preferiblemente desde un shell de Linux/Unix
* un browser - para acceder a los cuadros de mando

## Instalación y Arranque

El repositorio git contiene todos los componentes necesarios para arrancar SAM.
1- clonear el repositorio

```
git clone <this repository>
```

2- cambiar permisos del sub-directorio config/prometheus

```
chmod 777 ./sam-1.1.0.107-unix/config/prometheus
```

3- Arrancar SAM 
* En unix/linux, se pueden usar los scripts start.sh y stop.sh ubicados en .\sam-1.1.0.107-unix\
Es necesario permitir la ejecución de los scripts:

```
chmod +x *.sh
```

Los Componentes de SAM arrancan con esta notificación:
```
Creating sam_iris_1 ...         done
Creating sam_prometheus_1 ...   done
Creating sam_alertmanager_1 ... done
Creating sam_grafana_1      ... done
Creating sam_nginx_1        ... done
```

* en Windows, aunque sea una configuración no soportada, es posible arrancar SAM con los comandos siguientes:

```
.\sam-1.1.0.107-unix\docker-compose -p sam up 
o, para background:
.\sam-1.1.0.107-unix\docker-compose -p sam up -d
```
En este caso de Windows, se tiene que hacer click en acceptar en la ventana de compartir ficheros entre el host y docker.

4- Cambio de contraseña

Como primera tarea es imprescindible cambiar la contraseña del usuario Administrador (Admin o Superuser) de la instancia de IRIS incluida en SAM haciendo un primer login en el portal de gestión:

```
 http://127.0.0.1:8080/csp/sys/UtilHome.csp
```
SAM esta ahora accesible en la URL:

```
 http://127.0.0.1:8080/api/sam/app/index.csp
```
## Preparación de la Demo

Este repositorio git viene con 2 instancias IRIS que se pueden arrancar para después monitorizarlas con SAM.
Para arrancar las instancias

```
cd iris
docker-compose up -d
```
Las instancias estan disponibles en los puertos:

|   irisA                                |   irisB                                     |
| -------------------------------------- | ------------------------------------------- |
|   http://host.docker.internal:9191     |   http://host.docker.internal:9291          |

## Metricas Disponibles

Cada instancia de IRIS proporciona 2 puntos de acceso REST a los cuales se acceden desde SAM. 

Ahora se puede mirar el contenido de cada endpoint desde un browser:

Metricas: `http://host.docker.internal:9191/api/monitor/metric`

Alertas: `http://host.docker.internal:9191/api/monitor/alerts`



## Monitorizar un cluster

SAM agrupa los servidores a monitorizar en "Clusters". Las condiciones de alertas se definen a nivel del cluster y aplican a todas las instancias del cluster. Por esto es frecuente definir cluster de "producción", clusters de "desarrollo/test"..

Acceder al portal de SAM: http://localhost:8080/api/sam/app/index.csp

En el portal de SAM, seleccionar "Create your first Cluster", añadir un nombre `IrisDev-Cluster` y una descripción antes de validar con el botón "Add Cluster".

Ahora, se puede añadir cada instancia irisA e irisB con el botón "New". Después de unos segundos, las instancias deben aparecer como "Accesibles" y "OK".



### Definir unas Reglas de Alertas para el Cluster

SAM recoje automaticamente las alertas generadas por las instancias de IRIS.

Más ejemplos de Alertas en 



### Metricas a Medida 

Las metricas de SAM generadas por las instancias de IRIS se pueden extender facilmente:

1. Subclase de %SYS.Monitor.SAM.Abstract
2. Metodo GetSensors() par el calculo de las metricas
3. **Añadir Privilegios** a la Aplicación Web /api/monitor para ejecutar código en el namespace correcto.
4. Registrar la nueva metrica con `AddApplicationClass(<clase>,<Namespace>)`

#### Ejemplo de Metrica en Python

​	Este ejemplo esta pre-cargado en irisA:

```
Class SAMDemo.PythonMetric Extends %SYS.Monitor.SAM.Abstract
{
Parameter PRODUCT = "SAMDemo";
Method GetSensors() As %Status [ Language = python ]
{
import psutil
self.SetSensor("batterypercent",psutil.sensors_battery().percent)
if (psutil.sensors_battery().power_plugged==True):
        self.SetSensor("batterysecsleft",-1)
else:
        self.SetSensor("batteryminutesleft",psutil.sensors_battery().secsleft//60)
}
}
```

​	Se puede activar con un WebTerminal:

```
http://localhost:9191/terminal/
```

​	Y los comandos

```
zn "%SYS"
set sc=##class(SYS.Monitor.SAM.Config).AddApplicationClass("SAMDemo.PythonMetric","USER")
```

​	Después, se puede validar que la metrica aparece en la lista

```
http://localhost:9191/api/monitor/metrics
```



### Metricas de Estadisticas de SQL

InterSystems IRIS 2021 y siguientes generan automaticamente metricas del motor SQL, a nivel de cada namespace y en agregado:

```
iris_sql_queries_avg_runtime{id="all"}
iris_sql_queries_avg_runtime_std_dev{id="all"}
iris_sql_queries_per_second{id="all"}
```

A continuación se añade un elemento de Dashboard basado en el "Average SQL Query Time". 

En SAM, ver el Dashboard en Grafana y editarlo para añadir:

SAM Collector: 

	* Metrics: iris_sql_queries_avg_runtime
	* Legend: SQLAvgQryTime_{{id}}
	* Format: Time series

Visualization: 

* Graph: Lines

Ahora, desde el WebTermina, Ejecutar el siguiente codigo.



### Metricas de Interoperabilidad

InterSystems IRIS 2021 y siguientes permiten la colección de estadicticas de las producciones de Interoperabilidad 
