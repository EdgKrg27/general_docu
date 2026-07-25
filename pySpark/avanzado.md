# Almacenamiento en cache y persistencia

El almacenamiento en caché y la persistencia son técnicas de optimización cruciales en Spark, estos permiten guardar los resultados de un DataFrame o RDD en memoria o disco para que si se vuelve a utilizar el mismo conjunto de datos en pasos posteriores del script, Spark no tenga que recalcular todo el DAG desde cero.

Estas dos operaciones son perezosas (Lazy), la persistencia solo ocurre cuando se ejecuta la primera acción sobre ese DataFrame.

## Cache y Persistencia

El almacenamiento en cache coloca el DataFrame o RDD en un almacenamiento temporal ya sea memoria o disco distribuido entre los ejecutores del clúster, lo que acelera las lecturas posteriores.  
El almacenamiento en caché es una operación diferida, lo que significa que los datos se almacenan en cahcé solo cuando se acceden a ellos.

La persistencia ofrece mayor control sobre los niveles de almacenamiento, permitiendo el almacenamiento en memoria, disco o una combinación de ambos.

## Niveles de almacenamiento

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

