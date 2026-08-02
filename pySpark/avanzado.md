# Almacenamiento en cache y persistencia

El almacenamiento en caché y la persistencia son técnicas de optimización cruciales en Spark, estos permiten guardar los resultados de un DataFrame o RDD en memoria o disco para que si se vuelve a utilizar el mismo conjunto de datos en pasos posteriores del script, Spark no tenga que recalcular todo el DAG desde cero.

Estas dos operaciones son perezosas (Lazy), la persistencia solo ocurre cuando se ejecuta la primera acción sobre ese DataFrame.

## Cache y Persistencia

El almacenamiento en cache coloca el DataFrame o RDD en un almacenamiento temporal ya sea memoria o disco distribuido entre los ejecutores del clúster, lo que acelera las lecturas posteriores.  
El almacenamiento en caché es una operación diferida, lo que significa que los datos se almacenan en cahcé solo cuando se acceden a ellos.

La persistencia ofrece mayor control sobre los niveles de almacenamiento, permitiendo el almacenamiento en memoria, disco o una combinación de ambos.

### Niveles de almacenamiento

Existen varios niveles de alamacenamiento:

|StorageLevel|Descripción|Uso de Memoria|Uso de Disco|Replicación|Caso de Uso|
|:--:|:--:|:--:|:--:|:--:|:--:|
|`DISK_ONLY`|Almacena los datos únicamente en disco. Recalcula los datos cuando se accede a ellos desde el disco.|Ninguno|Sí|Ninguna|Cuando la memoria es limitada y el costo de recalcular es bajo.|
|`DISK_ONLY_2`|Almacena los daots únicamente en disco con replicación 2x, es decir, cada partición se escribe en 2 nodos|Ninguno|Si (replicado)|Replicación 2x|Cuando la tolerancia a fallos es crítica y la memoria limitada|
|`DISK_ONLY_3`|Almacena los datos únicamente en disco con replicación 3x|ninguna|Si (altamente replicado)|Replicación 3x|Alta tolerancia a fallos para datos críticos en entornos de memoría limitada|
|`MEMORY_ONLY`|Almacena los datos únicamente en memoria. Recalculando los datos si no caben en memoria|Sí (serializados o deserializados)|No|Ninguna|Trabajos de alto rendimiento donde la recalculación es aceptable si la memoria se agota|
|`MEMORY_ONLY_2`|Almacena los datos en memoria con replicación 2x. Recalcula si no cabe|Sí (replicado)|No|Replicación 2x|Trabajos de alto rendimiento que requieren redundancia para conjuntos de datos críticos en memoria|
|`MEMORY_ONLY_SER`|Almacenamiento serializado|Reducido (Serializado)|No|Ninguna|Opción eficiente para trabajos con restricciones de memoria|
|`MEMORY_ONLY_SER_2`|Almacenamiento serializado en memoria con replicación 2x|Reducido (serializado, replicado)|No|Replicación 2x|Redundancia y eficiencia de memoria para conjuntos de datos críticos almacenados en memoria|
|`MEMORY_AND_DISK`|Almacena los datos en memoria cuando es posible. Si la memoria es insuficiente, los escribe en disco|Sí|Sí (si la memoria se llena)|Ninguna|Trabajos con grandes volúmenes de datos que exceden la memoria, aprovechando el disco sin necesidad de recalcular.|
|`MEMORY_AND_DISK_2`|Almacena los datos en memoria con replicación 2x. Si la memoria es insuficiente, los escribe en disco|Sí (replicado)|Sí (replicado si la memoria se llena)|Replicación 2x|Trabajos de gran escala con tolerancia a fallos y posible desbordamiento de memoria hacia disco.|
|`MEMORY_AND_DISK_SER`|Almacena los datos en memoria en formato serializado para ahorrar espacio. Si la memoria es insuficiente los escribe en disco|Reducido (serializado)|Sí (si la memoria se llena)|Ninguna|Opción eficiente en memoria para trabajos donde el formato serializado es suficiente|
|`MEMORY_AND_DISK_SER_2`|Almacenamiento serializado en memoria y disco con replicación 2x|Reducido (serializado, replicado)|Sí (replicado si la memoria se llena)|Replicación 2x|Redundancia, eficiencia de memoria y soporte para trabajos de gran escala que requieren almacenamiento en disco|
|`OFF_HEAP`|Almacena los datos en memoria fuera del heap (asignación directa de memoria)|Memoria fuera del heap|No|Ninguna|Casos avanzados que requieren almacenamientos fuera del heap para minimizar el impacto del recolector de basura (GC) y obtener alto rendimiento|


### En que momento utilizar cada nivel de almacenamiento

Elegir un nivel adecuado es un balance entre memoria RAM, uso de CPU y tolerancia a fallos.

1. Usar `MEMORY_ONLY` O `cache()` cuando: los datos caben perfectamente en la memoria RAM disponible de los ejecutores, o también cuando el rendimiento de la CPU es tu prioridad número uno (los datos ya están listos para usarse sin coste de deserialización)
2. Usar `MEMORY_AND_DISK` cuando el tamaño de los datos es grande o impredecible y no quires arriesgarte a que Spark descarte particiones (lo que obligaría a recaluclar el DAG completo si usaras MEMORY_ONLY), es la opción segura por defecto.
3. Usar `MEMORY_ONLY_SER` O `MEMORY_AND_DISK_SER` cuando: los datos son masivos y tienes problemas de espacio en memoria, es decir, Garbage Collection pesado o errores de OutOfMemory, además si se prefiere pagar un costo extra en CPU para desempaquetar los datos a cambio de ahorrar drásticamente espacio en la RAM.
4. Usar los niveles con réplica (`_2`) únicamente cuando: se está corriendo un job crítico muy largo en producción y tu infraestructura/clúster es inestable, esto evita recalcular horas de trabajo si un nodo muere.

Una regla indispensable es que cuando se termine de usar el DataFrame persistido, se debe liberar la memorua usando el comando `.unpersist()`, en caso de que no se haga se puede quedar el clúster sin RAM para los siguientes pasos o procesos.

**Ejemplo de implementación y liberación**

```python
from pyspark.sql import SparkSession
from pyspark import StorageLevel

spark = SparkSession.builder.appName("PersistenciaOptimizada").getOrCreate()

#Leer DataFrame pesado
df_pesado = spark.read.parquet("ventas_globales.parquet")

# Aplicar transformaciones complejas de alto costo (Join + Agregación)
df_analisis = df_pesado.filter("monto > 100").groupBy("pais_id").count()

# Persistencia: Se decide guardarlo serializado en memoria y disco
df_analisis.persist(StorageLevel.MEMORY_AND_DISK_SER)

# Acción1: Aquí se calcula el DataFrame anterior por primera vez y se persiste en memoria/disco
total_registros = df_analisis.count()

# Acción2: Aquí Spark NO recalcula nada, lee directamente de la persistencia velozmente
df_analisis.show(5)

# Liberar memoria: Ya no se usará este DataFrame en el resto del script
df_analisis.unpersist()

```

# Particionado

Esta es la división lógica de un conjutno de datos grande RDD o DataFrame en partes más pequeñas y manejables llamadas Particiones. Este es un concepto fundamental que influye significativamente en el rendimiento, la reorganización de datos, el paralelismo y la utilización de recursos en los trabajos de Spark.

La partición es importante por:

1. Spark procesa los datos en paralelo asignando una tarea por partición. Cada partición es gestionada por un único núcleo ejecutor
	- Spark asigna una **partición = una tarea = un núcleo de ejecutor a la vez**, por ejemplo hay 4 particiones y 16 núcleos de ejecución, Spark solo puede ejecutar 4 tareas en paralelo, incluso si se tiene 6 núleos, por otro lado, si se tiene 16 particiones y 16 núcleos de ejecución, Spark ejecuta 16 tareas en paralelo esto es conocido como **paralelismo máximo.**
2. La redistribución de datos consiste en la redistribución de datos entre particiones, generalmente durante operaciones de unión, agrupación, distinción o reparticionamiento.

Porque es crítico un buen particionado, si los datos no están bien particionados, se pueden presentar dos problemas gravés:

1. **Data Skew (Sesgo de Datos):** Ocurre cuando unas pocas particiones contienen el 90% de los datos y el resto están casi vacías. El job tardará lo que tarde en procesar la partición más pesada, dejando a los demás nodos del clúster desperdiciados e inactivos.
2. **Problema de archivos pequeños (Small File Problem):** Si se tiene demasiadas particiones, por ejemplo 10000 para 1GB de datos, Spark generará 10000 archivos independientes al guardar. Esto destruye el rendimiento de sistemas de almacenamiento comoo HDFS, S3 o ADLS debido a la sobrecarga de metadatos.

## Tipos de particionado

Spark maneja los datos mediante tres estrategias principales de particionado.

### **Particionado por defecto (Hash Padrtitioning):**

Es el más común, Spark toma una clave o una fila completa, calcula su valor Hash y aplica un módulo matemático basados en el número de particiones objetivo. Este particionado contribuye a lograr el paralelismo de datos mediante una distribución uniforme de los datos entre las particiones.

`Partición = Hash(Clave)mod(número de particiones)`

**Función Hash:** Spark utiliza una función hash para calcular un valor hash para cada registro en función de las columnas o expresiones especificas.  
**Número de particiones:** Se debe especificar el número de particiones que se desea crear. Spark divide los valores hash en estas particiones  
**Asignación de particiones:** Cada registro se asigna a una partición según su valor hash. Los registros con el mismo valor hash se asignan a la misma partición. El objetivo es distribuir los datos de manera uniforme entre las particiones para garantizar una carga de trabajo equilibrada durante el procesamiento.

El particionado HASH es especialmente útil cuando se desean realizar operaciones como uniones o agregaciones. Al particionar los datos mediante un enfoque basado en hash, Spark puede optimizar las operaciones que requieren la redistribución o el intercambio de datos, lo que reduce el movimiento de datos en el clúster y mejora el rendimiento.

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("Ejemplo HASH").getOrCreate()

datos = [
	(1,"Ana", "Ventas"),
	(2, "Luis", "TI"),
	(3, "Carlos", "Ventas"),
	(4, "Maria", "HR"),
	(5, "Pedro", "TI")
]

df = spark.createDataFrame(datos, ["id", "nombre", "departamento"])

# Aplicación de particionado HASH porla columna "departamento" en 4 particiones
df_hash_particionado = df.repartition(4, "departamento")

# Comprobar el número de particiones resultantes
print("Número de particiones: ", df_hash_particionado.rdd.getNumPartitions())

>> 4 
```

los puntos clave del código anterior son los siguientes:

- La función `df.repartition(numPartitions, col)` reparte los datos por red (shuffle) usando un código hash sobre la columna elegida.  
- Agrupa registros con el mismo valor de la clave en la misma partición, optimizando operaciones futuras como `join` o `groupBy`.

### **Particionado por Rango**

Distribuye los datos basándose en rangos ordenados de una clave por ejemplo de la A a la F a la partición 1,  de la G a la M a la partición 2, es decir, organiza un DataFrame o RDD agrupando valores similares de una o más columnas en particiones ordenadas, lo cual esto optimiza las uniones y consultas por intervalos.  
Este particionado se realiza con el comando `rapartitionByRange()`.

Para poder aplicar el particionado se debe indicar el número de particiones y las columnas del orden:

- **Definir columnas:** Seleccionar la variable nuḿerica o de fecha
- **Indicar particiones:** Fijar el número total de divisiones deseadas para el DataFrame
- **Ejecutar método:** Invocar `df.repartitionByRange(numPartitions, "columna")`

```python
from pyspark.sql import functions as sf

# Creación de DF
df = spark.createDataFrame(
	[(14,"Tom"), (23, "Alice"), (16, "Bob")]. ["age", "name"]
)

# Particionado por rango usando la columna "age" en 2 particiones
df_repart = df.repartitionByRange(2, "age")

# Ver el resultado con el ID de partición
df_repart.select("age", "name", sf.spark_partition_id()).show()
>> 
```

Las ventajas que tiene la repartición por rango son:

1. **Orden lógico:** mantiene los datos cercanod según su valor de rango, a diferencia del hash.
2. **Consultas eficientes:** acelera las operaciones de filtrado por rangos y uniones al evitar explorar todo el clúster.

Se debe de utilizar el particionado por rango antes de ordenar grandes volúmenes de datos, al realizar uniones basadas en intervalos numéricos o temporales, además para prevenir la asimetria de datos (skew). En otras palabras:

- **Antes de ordenar los datos:** Si se planea ordenar un DataFrame masivo por una columna com ofechas o IDs, se debe utilizar el particionado por rango, ya que agrupa los datos de forma ordenada en cada partición. Esto reduce frásticamente el trabajo de orden global en el clúster.
- **Uniones por intervalos:** Al cruzar dos tablas usando condiciones de rango, por ejemplo cuando se busca eventos cuyas marcas de tiempo caigan entre dos fechas, se recomienda tener ambos DataFrames particionados por rango en esas mismas columnas acelera la operación.
- **Evitar Data Skew con claves continuas:** A diferencia de un `HASH`  normal, que puede mandar datos desproporcionados a una sola partición si hay valores repetidos o sesgados, el método por rango analiza una muestra de los datos para asegurar particiones con tamaños y límites equitativos.
- **Optimizar consultas repetitivas de rango:** Cuando se sabe de antemano que los filtros buscarán bloques esécíficos de datos numéricos o cronológicos continuos.

Se debe tener en consideración que esta función realiza un muestreo de los datos y un shuffle completo, se debe utilizar solo si el costo se compensa con las operaciones de joins o escrituras ordenadas.
Este funciona mejro con valores continuos y ordinales, por ejemplo números, marcas de tiempo, fechas donde se puede establecer un orden menor o mayor.

### **Particionado por Disco**

Ocurre al momento de escribir los datos a sistemas de archivos. Creará carpetas físicas basadas en el valor de una columna, permitiendo que futuras levturas filteren directorios enteros sin leer el dataset completo.

El funcionamiento principal es:

- Crea subdirectorios con nombres como `columna = valor` en lugar de guardar un solo archivo gigante
- Cuando se busac un dato especifico, PySpark va directo a la carpeta e ignora el resto, por ejemplo `año = 2025`
- Se utiliza con el comando `.write.partitionBy("nombre_columna")` al exportar a formatos como parquet o CSV

Los beneficios principales son:

- **Menos lectura:** Se leen muchos menos datos del disco porque solo se abre la parte útil
- **Más velocidad:** Las consultas de SQL o PySpark terminan mucho más rápido
- **Mejor orden:** Evita saturar la memoria o el procesador al no tener que buscar en todo el conjunto de datos a la vez

# Mezcla de datos (Shuffling)

Este es el proceso mediante el cual Spark redistribuye y reorganiza los datos a través de los diferentes nodos del clúster. Esto ocurre cuando una operación requiere agrupar o combinar registos que comparten una mismca clave, pero que actualmente están esparcidos en distintas particiones físicas.  
Esta es la operación más costosa en términos de tiempo, memoria, red y disco en todos los ecosistemas de PySpark.

## Porque ocurre el Shuffling???

