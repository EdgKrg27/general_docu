# Mezcla de datos (Shuffling)

Este es el proceso mediante el cual Spark redistribuye y reorganiza los datos a través de los diferentes nodos del clúster. Esto ocurre cuando una operación requiere agrupar o combinar registos que comparten una mismca clave, pero que actualmente están esparcidos en distintas particiones físicas.  
Esta es la operación más costosa en términos de tiempo, memoria, red y disco en todos los ecosistemas de PySpark.

## Las 2 fases del Shuffling a nivel físico

El shuffling divide el trabajo internamente en dos fases estrictas:

`[Fase Shuffle Write (Origen)0] -> [Red / Transferencia] -> [Fase Shuffle Read (Destino)]`

1. Suffle Write (Escritura)
	- Los ejecutores de origen leen los datos de sus particiones locales
	- Aplican una función hash sobre la clave para calcular a qué partición de destino debe ir cada registro
	- Escriben los resultados intermedios en archivos temporales en el disco local del nodo
2. Shuffle Read (Lectura)
	- Los executores de dstino realizan peticiones de red para leer los archivos temporales desde los discos de todos los demás nodos de origen
	- Los datos viajan por red
	- El executor de destino combina y ordena los datos recibidos en memoria RAM para procesar la acción o transformación final

Cuando un script de PySpark tarda demasiado tiempo, el 90% de las veces la cuasa es el Shuffle por estos 4 factores:

- **I/O Disco:** Escribir y leer GB de archivos temproales de Shuffle en los discos de los servidores
- **Sobrecarga de red:** El ancho de banda del clúster se stura enviando datos entre nodos
- **Uso de memoria/Garbage Collection:** Si una clave tiene demasiados datos, puede saturar la RAM del executor de destino
- **Deserialización:** Convertir objetos de Java/Python a bytes para enviarlos por la red y deserializar al recibir los datos consume mucha CPU

## Estrategias de optimización para reducir o evitar el shuffling

1. **Utilizar Broadcast Joins** (Para tablas pequeñas)

Si es necesario realizar un `JOIN` entre una tabla gigante y una pequeña (menor a 10MB),se puede enviar una copia de la tabla pequeña a todos los nodos. Esto elimina el Shuffle por completo.

```python
from pyspark.sql.functions import broadcast

# Evita el shuffle distribuyendo la tabla pequeña
df_resultado = df_grande.join(broadcast(df_paises), "id_pais")
```

2. Ajustar la particiones de Shuffle

Spark crea por defecto 200 particiones para operaciones Shuffle, si los datos son pequeños, como unos 500MB, 200 particiones creará miles de archivos minúsculos perdiendo rendimiento, se puede hacer la reducción a 10 o 20. Si los datos son gigantes, más de un TB de memoria, 200 particiones causará que cada partición tenga 5GB y el nodo se que sin memoria, se puede aumentar a 1000 particiones o más.  
Todo esto depende de la cantidad de memoria que se quiera procesar.

```python
`spark.conf.set("spark.sql.shuffle.partitions", "50")
```