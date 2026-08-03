# Acciones

Las acciones son operaciones en PySpark que estos si ejecutan el procesamiento real de los datos acumulados en el DAG. Una acción toma los datos distribuidos del clúster ya sea RDD o DataFrame y realiza el cómputo final y devuelve un resultado al Driver Program o escribe los datos directamente en un sistema de almacenamiento externo.  
Las acciones principales son:

1. `collect()`: trae todos los elementos del RDD o DataFrame desde los nodos trabajadores (workers) de vuelta al nodo central (driver). El uso principal de este es para poder ver los resultados finale en tu consola o guardarlos en una variable nativa de Python.  
Esta acción se debe ejecutar únicamente con datasets pequeños o filtrados, si se ejecuta en un conjunto muuuy grande se desbordará la memoria del Driver y provocará un error `OutOfMemoryError` (OOM).

```python
rdd = sc.parallelize([1,2,3,4,5])
rdd.collect()
>> [1,2,3,4,5]
```

2. `count()`: Cuenta el número total de elementos o filas que contiene el RDD o DataFrame. El uso principal es la validación rápida de calidad de datos para confirmar cuántos registros sobrevivieron a un filtro o transformación.

```python
rdd = sc.parallelize([1,2,3])
rdd.count()
>> 3
```

3. `take()`: Devuelve los primeros `n` elementos del conjunto de datos en forma de lista al Driver. El uso principal es inspeccionar una pequeña muestra de los datos de manera segura sin el riesgo de colapsar la memoria. Lo que realiza Spark es procesar las particiones necesarias para alcanzar el número.

```python
rdd = sc.parallelize(range(100000000))
rdd.take(5)
>> [0,1,2,3,4]
```

4. `first()`: Caso específico de `take`, este devuelve estrictamente el primer elemento del RDD o DataFrame, este es equivalente a ejecutar `.take(1)[0]`

```python
rdd = sc.parallelize(["Primer", "Segundo", "Tercero"])
print(rdd.first())
>> Primer
```


5. `top(n, key=None)`: Devuelve los primeros n elementos ordenados de manera descendente según su valor por defecto o basándose en una función clave personalizada.

```python
rdd = sc.parallelize([10,4,25,7,2])
print(rdd.top(3))
>> [25, 10, 7]
```

6. `reduce()`: Agrega todos los elementos del conjunto de datos utilizando una función binraia asociativa y conmutativa de manera puramente funcional. Reduce todo el dataset a un único valor final de vuelta en el Driver.

```python
rdd = sc.parallelize([1,2,3,4])
rdd.reduce(lambda x, y: x + y) # suma acumulativa de todo el RDD
>> 10
```

7. `countByKey()`: Está disponible únicamente en RDDs de tipo clave-valor `(K,V)`, cuenta el número de elementos para cada clave única y devuelve los resultados directamente al Driver en forma de un diccionario `(dict)`.

```python
rdd = sc.parallelize([("Ventas", 1), ("TI", 1), ("Ventas", 1)])
print(rdd.countByKey())
>> {"Ventas":2, "TI", 1}
```

8. `saveTextAsFile(path) / write`: Escribe los elementos del dataset directamente a una ruta del sistema de archivos. Cada partición de los ejecutores escribirá su propio fragmento de archivo en paralelo de forma directa, sin pasar los datos a través del Driver. Es la acción estándar al finalizar un Job de Big Data.

```python
rdd = sc.parallelize(["Linea 1", "Linea 2"])
rdd.saveAsTextFile("ruta/salida/...")
```

Ver ejercicios [link]()