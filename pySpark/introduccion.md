# Introducción a PySpark

## ¿Qué es PySpark?

Es el API de Spark pero escrito y utilizado en Python, esta diseñado para el procesamiento y análisis de big data. Permite utilizar la computación distribuida de Spark con Python y así procesar de forma eficiente grandes conjuntos de datos en clústers.

Algunas características son:

- **Computación distribuida:** PySpark ejecuta cálculos en paralelo en un clúster, lo que permite un procesamiento rápido de datos.
- **Tolerancia de fallos:** Spark recupera los datos perdidos utilizando información de linaje en conjuntos de datos distribuidos resilentes (RDD)
- **Evaluación diferida:** Las transformaciones no se ejecutan hasta que se llama a una acción, lo que permite la optimización
- **Master-Slave:** Arquitectura basada en el modelo Maestro-Esclavo 
- **Driver Program:** Es el proceso central que ejecuta el código que se escribe, ya que coordina tareas y planifica el trabajo.
- **Cluster Manager:** Administra los recursos del clúster
- **Worker Nodes:** Son los nodos que realmente ejecutan las tareas de procesamiento de datos en paralelo y almacenan los resultados en memoria o disco

A diferencia de otros programas de procesamiento de datos como Pandas o Python nativo, PySpark utiliza **Lazy Evaluation (Evaluación Perezosa)**, así todas las operaciones de Spark se dividen en dos tipos:

1. **Transformaciones** (`map, filter, groupby`). Estas operaciones no se ejecutan inmediatamente, solo registran las operaciones en un grafo dirigido acíclico `(DAG)`.
2. **Acciones** (`count, show, collect, write`). Son las operaciones que disparan la ejecución real de todo el DAG acumulado. 

## Catalyst Optimizer

Componente que mejora el rendimiento de las aplicaciones en Spark optimizando la ejecución de las consultas de datos.  
Este es un marco de optimizacioń de consultas y esta diseñado para optimizar ejecuciones de consultas de datos mediante la aplicación de una serie de transformaciones al plan de consulta. Estas transformaciones se basan en un conjunto de reglas que pueden estar preconfiguradas o definidas a medida.

- El optimizador toma una consulta expresada en el DataFrame de Spark o en la API SQL, y la transforma enun plan físico optimizado para su ejecución
- Utiliza información sobre los datos y la propia consulta (como filtros o uniones) para apĺicar optimizaciones
- El objetivo de estas optimizaciones es reducir la cantidad de datos que se deben procesar y simplificar las operaciones

Como funciona el optimizador:

1. **Análisis**: En esta etapa el optimizador analiza el plan lógico para resolver referencias a expresiones con nombre, como nombres de columnas o tablas.
2. **Optimización lógica**: El optimizador aplica optimizaciones basadas en reglas de plan lógico, como la optimización de predicados o la optimización de constantes
3. **Planificación física**: El optimizador genera varios planes físicos a partir del plan lógico y elige el más eficiente según la estimación de costos
4. **Generación de código**: El optimizador genera código de bytes ejecutable para ejecutar una consulta


## SparkSession

Es el únto de entrada unificado para cualquier aplicación de PySpark. Este crea un Driver Program y su función principal es interactuar con el Cluster Manager para coordinar y distribuir el trabajo entre los ejecutores. 

Se necesita crear solamente un patron builder por aplicación, y para garantizar que solo exista una sesión activa por aplicación o reutilizar una existente, se utiliza las siguiente líneas.

```python
from pyspark.sql import SparkSession

# Creación de SparkSession
spark = SparkSession.builder \
    .appName("<nombre aplicación>") \
    .master("<url del cluster>") \
    .config() \
    .getOrCreate()
```

donde:
- `.appName()`: Define el nombre de la aplicación. Es el que aparecerá en SparkUI para monitorear el job
- `.master()`: Especifica el entorno de ejecución, si es la maquina local sería `local[*]` especificando `*` si se quiere utilizar todos los cores de la maquina o un número `n` que especifica el número de cores que se quiere utilizar. Para entornos de producción, aquí se define las URL del clúster a utilizar.
- `config()`: Permite pasara parámetros de optimización directos al motor de Spark, como manejo de memoria o número de paticiones
- `.getORCreate()`: crea o reutiliza la conexión de Spark con las especificaciones anteriores.

Una vez que tengamos inciado el SparkSessión, se desbloquean las siguiente funciones:

1. Lectura de datos (`spark.read`): Es el punto de partida para crear DataFrames desde fuentes externas (CSV,Parquet, Json, etc...)

`df = spark.read.format("parquet").load("<ruta del archivo>")`

2. Ejecuciones de consultas SQL directas (`spark.sql`): Permite registrar DataFrames como vistas temporales y consultarlos usando sintaxis SQL estándar.

```python
df.createOrReplaceTempView("usuarios")
df_resultado = spark.sql("SELECT edad, COUNT(*) FROM usuarios GROUP BY edad")
```

3. Acceso de catalogo (`spark.catalog`): Permite administrar los metadatos del clúster (listar tablas, bases de datos, funciones registradas o vaciar caché)

`spark.catalog.listTables()`

4. Acceso a SparkContext subyacente (`spark.sparkContext`): Si se necesita realizar operaciones de muy bajo nivel directamente con RDDs o interactuar de forma nativa con el clúster

`rdd = spark.sparkContext.parallelize([1,2,3,4,5])`

## RDD (Resilient Distributed Dataset)

Es la abstracción de datos fundamental y de más bajo nivel de Apache Spark, este representa una colección de elementos que es tolerante a fallos y que se puede operar en paralelo a lo largo de los nodos de un clúster. Estos son la base donde corre todo el motor de Spark.

Su características clave son:

1. **Tolerante a fallos**: Si un nodo del clúster que contiene una partición del RDD falla, Spark no pierde los datos. Spark recuerda el DAG o el linaje de la transformación que dieron origen a ese RDD, permitiendo reconstruir la partición perdida automáticamente.
2. **Distribuido**: Los datos que componen un RDD no residen en una sola máquina, se dividen en partes lógicas llamadas particiones, las cuales se distribuyen y procesan en paralelo a través de los diferentes nodos del clúster.
3. **Conjunto de datos**: Es la colección de objetos con la que se trabaja, estos pueden contener casi cualquier tipo de objeto de Python
4. **Inmutabilidad**: Los RDDs son estrictamente inmutables (no se pueden modificar una vez creados). Si se aplica una transformación a un RDD no se cambia el RDD original, Spark genera un nuevo RDD con los resultados de la transformación.

### Formas de crear un RDD

```python
sc = spark.sparkContext

# Creación de un RDD vacio
rdd_vacio = sc.emptyRDD
rdd_vacio.collect() # obtener los datos dentro del RDD
>> []

# Creación de RDD vacio con tres particiones
rdd_vacio_3particiones = sc.parallelize([], 3)
rdd_vacio_3particiones.getNumPartitions()
>> 3

# creación de un RDD a partir de una lista
rdd = sc.parallelize([1,2,3,4,5,6,7,8,9])
rdd.collect()
>> [1, 2, 3, 4, 5, 6, 7, 8, 9]

# Creación de un RDD a partir de un archivo de texto
rdd_texto = sc.textFile('./data.txt')
rdd_texto.collect()
>>['Esto es una prueba para PySpark', 'Hola', 'Edgar', 'Deyanira', 'Maya']

# Creación de un RDD a partir de una operación
rdd_suma = rdd.map(lambda x: x**2)
rdd_suma.collect()
>> [1, 4, 9, 16, 25, 36, 49, 64, 81]

# Creacioń de un DataFrame
df = spark.createDataFrame([(1,'Jose'), (2,'Juan')], ['id', 'nombre'])

# Convertir DataFrame a RDD
rdd_df = df.rdd
rdd_df.collect()
>> [Row(id=1, nombre='Jose'), Row(id=2, nombre='Juan')]
```

Ver ejercicios adjuntos [link](./pySpark/Introduccion_RDD.ipynb)
