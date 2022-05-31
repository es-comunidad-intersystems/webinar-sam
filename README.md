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
Creating sam_iris_1 ... done
Creating sam_prometheus_1 ... done
Creating sam_alertmanager_1 ... done
Creating sam_grafana_1      ... done
Creating sam_nginx_1        ... done
```

* en Windows, aunque sea una configuración no soportada, es posible arrancar SAM con los comandos siguientes:

```
.\sam-1.1.0.107-unix\docker-compose -p sam up 
or, for background:
.\sam-1.1.0.107-unix\docker-compose -p sam up -d
```
En este caso de Windows, se tiene que hacer click en acceptar en la ventana de compartir ficheros entre el host y docker.

4- Cambio de contraseña



