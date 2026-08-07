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