# **Notas sobre Numpy**

## **Creación de una array**

Se debe importar la libreria `numpy` de la siguiente forma: `import numpy as np`, existen 6  maneras de crear un matrices de numpy o mejor conocidos como `ndarray`

### **Convirtiendo una lista o tupla**  
  
Se pueden definir utilizando secuencias de Python como listas `[...]` o tuplas `(...)`, se pueden definir de la siguiente manera:  

> - Una lista de número creará una matriz de 1 dimensión  
> - Una lista de listas creará una matriz de 2 dimensiones  
> - Otra lista anidadas crearán matrices de dimensiones superiores.  
  
al momento de crear una nueva matriz se debe hacer consideración del tipo de dato que se va asignar a esa matriz, ya que eso más adelante nos brinda un mejor control sobre las estructuras de datos subyacentes y cómo funcionan los elementos.

~~~python
import numpy as np
a1D = np.array([1, 2, 3, 4]) # Matriz de una dimensión
a2D = np.array([[1, 2], [3, 4]]) # Matriz de dos dimensiones
a3D = np.array([[[1, 2], [3, 4]], [[5, 6], [7, 8]]]) # Matriz de n dimensiones

# Error al momento de utilizar un tipo de dato especifico y este se sale del rango o no concuerda
np.array([127, 128, 129], dtype=np.int8)
>>> Traceback (most recent call last):
...
>>> OverflowError: Python integer 128 out of bounds for int8
~~~  
  
El comportamiento adecuado de Numpy es crear matrices con signo de 32 o 64 bits dependiendo de la plataforma o números de doble presición.

### **Creación de uno por medio de la funciones intrinsecas de numpy (arange, ones, zeros, etc...)**  
  
Existen aproximadamente 40 funciones para crear matrices, todo depende según la dimensión de la matriz que se crea:  
  
- Funciones de creación de matrices de 1 dimensión: estas solamente necesitan dos valores, inicio y final  
  
`numpy.arange:` crea matrices con valores que se incrementan de forma periodica  
  
~~~python
import numpy as np
np.arange(10)
>> array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
np.arange(2, 10, dtype=float)
>> array([2., 3., 4., 5., 6., 7., 8., 9.])
np.arange(2, 3, 0.1)
>> array([2. , 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9])
~~~  
  
`numpy.linspace:` Crea matrices con una cantidad especifica de elementos y espaciados equitativamente entre los valores iniciales y finales especificados.  
  
~~~python
import numpy as np
np.linspace(1., 4., 6)
>> array([1. ,  1.6,  2.2,  2.8,  3.4,  4. ])
~~~

- Funciones de creación de matrices de dos dimensiones: algunas de las funciones de creaciónde matrices de 2 dimensiones son:  
  
`numpy.eye(n,m):` define una matriz de identidad 2D. Los elementos donde i=j son iguales a 1 y los demás son 0.  
  
~~~python
import numpy as np
np.eye(3)
>> array([[1., 0., 0.],
       [0., 1., 0.],
       [0., 0., 1.]])
np.eye(3, 5)
>> array([[1., 0., 0., 0., 0.],
       [0., 1., 0., 0., 0.],
       [0., 0., 1., 0., 0.]])
~~~  
  
`numpy.diag(v,n): ` define una matriz cuadrada de 2 dimensiones con valores dados a lo largo de la diagonal  
~~~python
import numpy as np
np.diag([1, 2, 3])
array([[1, 0, 0],
       [0, 2, 0],
       [0, 0, 3]])
np.diag([1, 2, 3], 1)
array([[0, 1, 0, 0],
       [0, 0, 2, 0],
       [0, 0, 0, 3],
       [0, 0, 0, 0]])
a = np.array([[1, 2], [3, 4]])
np.diag(a)
array([1, 4])
~~~  
  
`numpy.vander:` define una matriz Vandermonde como una matriz de Numpy 2D. Cada columna de la matriz es una potencia decreciente de la matriz 1D de entrada o lista o tupla. Este modelo es útil para generar modelos de mínimos cuadrados lineales.  
  
~~~python
import numpy as np
np.vander(np.linspace(0, 2, 5), 2)
>> array([[0. , 1. ],
      [0.5, 1. ],
      [1. , 1. ],
      [1.5, 1. ],
      [2. , 1. ]])
np.vander([1, 2, 3, 4], 2)
>> array([[1, 1],
       [2, 1],
       [3, 1],
       [4, 1]])
np.vander((1, 2, 3, 4), 4)
>> array([[ 1,  1,  1,  1],
       [ 8,  4,  2,  1],
       [27,  9,  3,  1],
       [64, 16,  4,  1]])
~~~

3. **Replicando, agregando o mutando matrices existentes**
4. **Lectura de matrices desde el disco, ya sea desde formatos estándar o personalizados**
5. **Creación de matrices a partir de bytes sin procesar mediante el uso de cadenas o buffers**
6. **Uso de funciones especiales de la biblioteca (random)**

