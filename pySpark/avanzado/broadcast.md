# Variables Broadcast

Estas variables también conocidas como variables de difusión, son variables de solo lectura que Spark envía y almacena en caché en la memoria RAM de cada nodo executor, esta operación se realiza una sola vez, en lugar de enviar una copia duplicada adjunta con cada una de las tareas (taks).  
Este envio de información es para evitar las operaciones de mezcla, estos sirven como mecanismo para compartir de manera eficiente estructuras de datos inmutables entre un clúster de máquinas, minimizando la necesidad de transferencias de datos redundantes.

Cuando se utiliza una variable local de Python (como un diccionario de búsqueda o catálogo) dentro de una UDF o una transformación:

- Sin broadcast: Spark serializa y transmite esa variable dentro del paquete de cada Task, si tienes 1000 tareas ejecutandose en el clúster y el diccionario pesa 10MB, transferirás 10GB de datos por la red

- Con broadcast: Spark envía los 10MB una sola vez por nodo ejecutor, estas 1000 tareas leen directamente la variable desde la memoria RAM local del ejecutor sin tráfico adicional de red.


<p align="center">
  <img src="./img/broadcast_1.png" width="350">
</p>

Las características clave que tiene los broadcast son:

1. **Inmutables:** No se puede alterar el valor de una variable dentro de los ejecutores ya que solamente de lectura
2. **Difusión P2P:** Spark utiliza un protocolo de transferencia tipo *peer-to-peer* para distribuir la variable entre los nodos de forma paralela sin saturar la red del driver
3. **Casos de uso ideal:** Tablas de catálogo pequeñas, diccionarios de mapeo o parámetros de modelos de Machine Learning.

## Buenas practicas y limites

- **Tamaño del límite:** Se debe mantener la variable en un tamaño reducido (< 100 MB idealmente). Si la variable es demasiado grande, se puede agotar la memoria de los ejecutores.
- **Broadcast JOINS:** Para DataFrames en lugar de usar UDFs con variables Broadcast, es preferible utilizar `pyspark.sql.functions.broadcast()` en un `JOIN` para que el Catalyst Optimizer ejecute un Broadcast Hash Join automático.

*Ejemplo*

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType

spark = SparkSession.builder.appName("EjemploBroadcast").getOrCreate()

# 1. Diccionario pequeño en el Driver
catalogo_paises = {
    "MX": "México",
    "AR": "Argentina",
    "CL": "Chile"
}

# 2. CREACIÓN DE LA VARIABLE BROADCAST
broadcast_paises = spark.sparkContext.broadcast(catalogo_paises)

# 3. Uso dentro de una UDF accediendo a la propiedad .value
@udf(returnType=StringType())
def obtener_nombre_pais(codigo):
    # Lectura veloz directamente desde la memoria RAM del Executor
    return broadcast_paises.value.get(codigo, "Desconocido")

# Aplicación sobre un DataFrame
data = [("101", "MX"), ("102", "AR"), ("103", "US")]
df = spark.createDataFrame(data, ["usuario_id", "codigo_pais"])

df_resultado = df.withColumn("pais_nombre", obtener_nombre_pais("codigo_pais"))
df_resultado.show()

# 4. LIMPIEZA DE MEMORIA (Buena práctica en producción)
broadcast_paises.unpersist() # Elimina la variable de la RAM de los Executors
```