# Aspectos avanzados sobre RDD

## Almacenamiento en caché y persistencia

El almacenamiento en caché y la persistencia son técnicas de optimización, ya que permiten guardar los resultados de un DataFrame o RDD en memoria o disco para que si se vuelve a utilizar ese mismo conjunto de datos en pasos posteriores del script, Spark no tenga que recalcular todo el DAG desde cero. Ambas operaciones son perezosas (Lazy), la persistencia solo ocurre cuando ejecutas la primera acción sobre ese DataFrame.

### Diferencia entre `cache()` y `persist()`

- `cache()`: Es un caso simplificado de persistencia, almacena los datos por defecto en memoria únicamente como objetos deserializados (`MEMORY_ONLY` para RDDs y `MEMORY_AND_DISK` para DataFrames), este no acepta parámetros.
- `persist(storageLevel)`: Es la versión avanzada y flexible, te permite pasarle un parámetro (`StorageLevel`) para decidir exactamente dónde y cómo guardar los datos (Memoria, Disco, Serializado o Replicado).

|Nivel de Almacenamiento|¿Usa memoria?|¿Usa disco?|¿Serializado?|¿Réplica en nodos?|Descripción|
|:--:|:--:|:--:|:--:|:--:|:--:|
|`MEMORY_ONLY`|Sí|No|No|1|Guarda los datos como objetos Java puros. Si una partición no cabe en memoria, no se guarda y se recalcula cuando se necesita (Nivel por defecto en RDDs).|
|`MEMORY_AND_DISK`|Sí|Sí|No|1|Si las particiones caben en memoria, las guarda ahí. Las particiones que se desbordan de la memoria se escriben directamente a disco (Nivel por defecto en DataFrames)|
|`MEMORY_ONLY_SER`|Sí|No|Sí|1|Convierte los datos en arreglos de bytes serializados (formato mucho más compacto). Ocupa mucho menos espacio en memoria, pero consume más CPU para deserializar los datos cada vez que se lee
|`MEMORY_AND_DISK_SER`|Sí|Sí|Sí|1|Igual al anterior pero si los datos serializados no caben en memoria, los desborda al disco en formato serializado|
|`DISK_ONLY`|No|Sí|Sí|1|No ua la memoria en absoluto. Guarda todo el DataFrame directamente en el disco local del ejecutor|
|`MEMORY_AND_DISK_2`|-|-|-|2|Cualquier nivel que termine en `_2` duplica los datos en dos nodos trabajadores distintos. Si un nodo falla por completo, el job no se detiene porque lee la réplica del otro nodo|

### Criterios de decisión, ¿Cuándo usar cada nivel?

Elegir el nivel adecuado es un balance entre memoria RAM, uso de CPU y tolerancia a fallos.

1. Uso de `MEMORY_ONLY` o `cache()` cuando: Los datos caben perfectamente en la memoria RAM disponible en los ejecutores. El rendimiento de la CPU es prioridad número uno ya que los datos ya están listos para usarse sin coste de deserialización.

2. Uso `MEMORY_AND_DISK` cuando: EL tamaño de los datos es grande o impredecible y no se quiere arriesgar a que Spark descarte particiones lo que obligaria a recalcular el DAG completo. Esta es la opción segura por defecto.

3. Uso `MEMORY_ONLY_SER` o `MEMORY_AND_DISK_SER` cuando: Los datos son masivos y se tiene problemas de espacio en memoria (`Garbage Collection` pesado o errores de `OutOfMemory`). Se prefiere pagar un costo extra en CPU para desempaquetar datos a cambio de ahorrar drásticamente espacio en RAM.

4. Uso de niveles de replica `_2` únicamente cuando: Se esta corriendo un job crítico muy largo en producción y la infraestructura es inestable, por ejemplo usando instancias spot en AWS o nodos compartidos de alta rotación. Esto evita recalcular horas de trabajo si un nodo muere.

### **REGLA DE ORO**
Siempre que se termine de usar un DataFrame o RDD persistido, se debe liberar la memoria con el comando `.unpersist()`.

```python
from pyspark.sql import SparkSession
from pyspark import StorageLevel

spark = SparkSession.builder...

# Leer un DataFrame pesado
df_pesado = spark.read.parquet("ventas_globales.parquet")

# Aplicar transformaciones complejas de alto costo (Join + Agregación)
df_analisis = df_pesado.filter("monto > 100").groupBy("pais_id").count()

# PERSISTENCIA: Decidimos guardarlo serializado en memoria y disco
df_analisis.persist(StorageLevel.MEMORY_AND_DISK_SER)

# ACCIÓN 1: Aquí se calcula el DataFrame anterior por primera vez y se persiste en memoria/disco
total_registros = df_analisis.count()

# ACCIÓN 2: Aquí Spark NO recalcula nada; lee directamente de la persistencia velozmente
df_analisis.show(5)

# LIBERAR MEMORIA: Ya no se usará este DataFrame en el resto del script
df_analisis.unpersist()
```

## Particionado

