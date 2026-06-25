# Transformaciones en RDD

Las transformaciones en un RDD son operaciones que toman un RDD existente como entrada y devuelven un nuevo RDD como salida.  
Debido a la Lazy Evaluation las transformaciones no calculan el resultado de inmediato, simplemente registran las operaciones en el DAG, así los datos reales no se procesan hasta que se ejecuta una acción.  
Las transformaciones se dividen estrictamente en dos categorias según como muevan los datos a través del clúster.

## **Transformaciones Estrechas (Narrow Transformations)**

Cada partición del RDD padre se utiliza por máximo una partición del RDD hijo, las características son que no requieren mover datos a través de la red entre los nodos del clúster. El procesamiento se realiza de forma completamente local e independiente de cada nodo, lo que las hace extremadamente rápidas. Las transformaciones son las siguientes:

- `map(func)`: para cada elemento del RDD a través de una función y devuelve un nuevo RDD con los resultados. Mantiene una relación estricta de 1 a 1

```python
rdd = sc.parallelize([1,2,3])
rdd_map = rdd.map(lambda x: x * 2)
>> [2,4,6]
```

- `filter(func)`: Evalúa cada elemento con una función booleana. El nuevo RDD contendrá únicamente los elementos que devolvieron `True`.

```python
rdd = sc.parallelize([1,2,3])
rdd_filter = rdd.filter(lambda x: x % 2 == 0)
>> [2,4]
```

- `flatMap(func)`: Similar a `map`, pero cada elemento de entrada se puede mapear a 0,1 o más elementos de salida. Al final aplana todas las colecciones resultantes en un solo RDD continuo. Es la transformación estándar para tokenizar texto.

```python
rdd = sc.parallelize(["Hola Mundo", "PySpark Spark"])
rdd_flatmap = rdd.flatMap(lambda x: x.split(" "))
>> ['Hola', 'Mundo', 'PySpark', 'Spark']
```

- `mapPartitions(func)`: Igual que la función `map` la diferencia radica en que permite realizar inicializaciones complejas una sola vez por cada partición, en lugar de hacerlo en cada fila. ESto mejora el rendimiento cuando se trabaja con inicializaciones complejas en conjuntos de datos grandes.

```python
rdd = sc.parallelize([1,2,3,4],2) # 2 particiones
def suma_particion(iterator):
	yield sum(iterator)
rdd_partitions = rdd.mapPartitions(suma_particion)
>> [3,7]
```

- `mapPartitionsWithIndex(func)`: Funciona exactamente igual a `mapPArtitions`, pero la función recibe dos argumentos, el índice de la partición (`int`) y el iterador de los datos. Te permite saber exactamente en que nodo/partición física del clúster está corriendo tu código.

```python
def mostrar_indice(index, iterator):
	yield f"Partición: {index}, Datos: {list(iterator)}"
rdd_index = rdd.mapPartitionsWithIndex(mostrar_indice)
```

- `sample(withReplacement, fraction, seed)`: Devuelve un subconjunto aleatorio de los datos del RDD de manera local para partición
	- `withRaplacement`: `True` si los elementos pueden repetirse en la muestra
	- `fraction`: Fruto porcentual esperado del tamaño de la muestra (0.1 para el 10%)

```python
rdd = sc.parallelize(range(100))
rdd_muestra = rdd.sample(False, 0.1, 42) # Muestra aprox. del 10% fija con semilla 42
```

- `union(otherDataset)`: Combina los elementos de dos RDDS para formar uno solo. Es una transformación estrecha porque Spark simplemente concatena conceptualmente las particiones del primer RDD con las del segundo, sin necesidad de reordenar o evaluar duplicados en esta etapa.

```python
rdd1 = sc.parallelize([1,2])
rdd2 = sc.parallelize([3,4])
rdd_union = rdd1.union(rdd2)
>> [1,2,3,4]
```

- `coalesce(numPartitions)`: Se utiliza para reducir el número de particiones de un RDD o DAtaFrame de la manera más eficiente posible. Este no dispara un Shuffle completo. En lugar de barajear y mover todos los datos a través de la red, simplemente une las particiones existentes en el mismo nodo o nodos cercanos para consolidarlos en un número menor.

## **Transformaciones Anchas (Wide Transformations)**

En una transformación ancha, múltiples particiones del RDD padre son requeridas para crear una sola partición del RDD hijo. Su característica es que obligan a Spark realizar Shuffle (reorganización de datos). Esto significa que los datos se escriben en el disco de los nodos origen, se transmiten a través de la red del clúster y se agrupan en los nodos destino según una clave común. Son operaciones costosas en tiempo y recursos. Las transformaciones son las siguientes:

- `reduceByKey(func)`: Agrupa los elementos de un RDD de tipo clave-valor `(K,V)` basados en su calve y aplica una funcioń asociativa y conmutativa para reducir los valores. Cabe mencionar que aunque es una transformación ancha, es altamente eficiente porque realiza una pre-reducción local en cada partición antes de enviar los datos por la red (Map-side combine).

```python
rdd = sc.parallelize([("A", 1),("B",2),("A",3)])
rdd_reduce = rdd.reduceByKey(lambda a, b: a + b)
>> [('A', 4), ('B', 2)]
```

- `groupByKey()`: Agrupa todos los valores de un RDD de tipo clave-valor `(K,V)` para cada clave única en el RDD. A diferencia de `reduceByKey`, `groupByKey` envia todos los datos a través de la red sin combinarlos previamente. Puede causar errores de falta de memoria (`OutOfMemoryError`) si una sola clave tiene demasiados elementos.  
Si se puede utilizar `reduceByKey` en lugar de `groupByKey`, es mejor utilizarlo.

```python
rdd = sc.parallelize([("A", 1),("B", 2), ("A", 3)])
rdd_groupby = rdd.groupByKey().mapValues(list)
>> [('A', [1, 3]), ('B', [2])]
```

- `aggregateByKey(zeroValue, seqFunc, combFunc)`: Es la versión más flexible y avanzada de `reduceByKey`. Es una transformación que permite combinar los valores de cada clave utilizando funcions personalizadas y un valor inicial neutro (cero), es muy útil cuando el tipo de datos de salida que se desea obtener es difernte al tiṕo de dato original de los valores.

	- `zeroValue`: El valor incial para la acumulación
	- `seqFunc`: Combna valores de una misma clave dentro de una misma partición
	- `CombFunc`: Combina los resultados acumulados de distintas particiones

```python
# Calcular el promedio (Suma, Contador) por clave
rdd = sc.parallelize([("A", 10), ("B", 20), ("A", 30)])
zero_value = (0,0) # (suma, contador)
seqFunc = lambda x, y: (x[0] + y,  x[1] +1)
combFunc = lambda x, y: (x[0] + y[0], x[1] + y[1])
rdd_avg = rdd.aggregateByKey(zero_val, seqFunc, combFunc)
>> [('A', (40, 2)), ('B', (20, 1))]
```

- `join(otherDataset)`: Combian dos RDDs de tipo clave-valor `(K,V)` y `(K,W)`, basándose en sus claves comunes . El resultado es un RDD de tipo `(K, (V,W))`. Requiere un shuffle masivo para alinear las claves de ambos datasets en los mismos nodos. Además también existen `leftOuterJoin`, `rightOuterJoin`, `fullOuterJoin`, todas estas son igual tranformaciones anchas y que cosumen muchos recursos.

```python
rdd1 = sc.parallelize([("A", 1), ("B", 2)])
rdd2 = sc.parallelize([("A", "X"), ("C", "Y")])
rdd_joined = rdd1.join(rdd2)
>> [('A', (1, 'X'))]
```

- `distinct()`: Elimina los elementos duplicados de todo el RDD, esto obliga a realizar unshuffle completo porque Spark necesita enviar todos los elementos con el mismo valor numérico o de texto al mismo executor para verificar si son idénticos y descartar las copias

```python
rdd = sc.parallelize([1,2,3,2,2,1,3])
rdd_distinct = rdd.distinct()
>> [2, 1, 3]
```

- `repartition(numPartitions)`: Aumenta o disminuye dinámicamente el número de particiones del RDD en el clúster. Rebalancea los datos de forma completamente uniforme a través de la red mediante un Full Shuffle. Sí lo único que buscars es disminuir el número de particiones, se debe utlizar `coalesce()`.

```python 
rdd = sc.parallelize([1,2,3,4,5,6,7,8,9], 2) # 2 particiones
rdd_partition = rdd.repartition(4) # 4 particiones
>> 4
```

- `sortBy(keyFunc, ascending=True)`: Ordena los elementos del RDD según los criterios definidiso en la función. Para poder garantizar que el orden se mantenga de manera global a través de todo el clúster, Spark necesita redistribuir los rangos de datos entre las particiones utilizando un shuffle.

```python
rdd = sc.parallelize([3,1,4,2])
rdd_sorted = rdd.sortBy(lambda x: x)
>> [1, 2, 3, 4]
``` 

Ver ejercicios [link](02_transformaciones.ipynb)