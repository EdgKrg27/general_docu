# Normalización de los datos

La normalización es un proceso de diseño de bases de datos relacionales cuyo objetivo es organizar los dfatos para reducir redundancia y evitar inconsistencias, es decir, es mantener cada hecho en un solo lugar para evitar redundancia y anomalías al insertar, actualizar o eliminar datos.

## Primer forma normal (1FN)

La primer forma normal se cumple cuando:

- Las columnas y los valores almacenados en ellas, ya no se pueden dividir
- No deben existir valores repetidos en las columnas

**Ejemplo:**

<p align="center">
  <img src="./imagenes/1FN_1.jpeg" width="auto">
</p>

Teniendo la primer tabla, se puede observar que primero podemos dividir el *nombre* por *nombre*, *apellido paterno* y *apellido materno*, además la *dirección* se puede dividir en *calle*, *número* y *barrio*, esto para cumplir con la primer regla de que los datos no se puedan dividir.

<p align="center">
  <img src="./imagenes/1FN_2.jpeg" width="auto">
</p>

La nueva tabla tiene ahora separado el *nombre* por *nombre*, *apellido materno* y *apellido paterno*, además la *dirección* se separo por *calle*, *número* y *barrio*.  
Pero la tabla sigue sin cumplir completamente con la 1FN, ahora se tiene que dividir la tabla en partes ya que se puede dividir por *clientes*, *producto* y *compras*.

<p align="center">
  <img src="./imagenes/1FN_3.jpeg" width="auto">
</p>

Se ha logrado dividir la tabla por *clientes*, productos con un *id* por cada producto, *compras* con un *id* por cada compra.
Pero la tabla *clientes* todavía cuenta con información repetida que es la columna de *barrio*, esta se tiene que dividir creando una nueva tabla llamada *barrios*.

<p align="center">
  <img src="./imagenes/1FN_4.jpeg" width="auto">
</p>

Con esto la tabla incial se encuentra completamente en la primera forma normal.

## Segunda forma normal (2FN)

La segunda forma normal se centra en eliminar las dependencias parciales. Una dependencia parcial se produce cuando un atributo no primo (columna que no forma parte de ninguna clave candidata) depende sólo de una parte de un clave compuesta en lugar de toda la clave, esto garantiza que cada dato asociado a la clave que realmente lo determina.

Una tabla está en segunda forma normal (2NF) cuando:

1. Ya cumple con la regla 1FN
2. Cada columna que no forma parte de una clave candidata depende de la clave completa, no solamente de una parte de ella

**Ejemplo:**

Se tiene la tabla que cumple con 1FN

|pedido_id|producto_id|nombre_producto|cantidad|
|:--:|:--:|:--:|:--:|
|1|10|Teclado|2|
|1|20|Mouse|1|
|1|10|Teclado|5|

Aquí se tiene una clave compuesta: `(pedido_id, producto_id)` donde `cantidad` depende de pedido + producto, pero `nombre_producto` depende solamente de `producto_id`, esto es una dependencia parcial por lo cual no cumple con la regla 2NF.

Para que la tabla cuente con la regla 2NF se debe separar la información del producto.

|producto_id|nombre|
|:--:|:--:|
|10|Teclado|
|20|Mouse|

|pedido_id|producto_id|cantidad|
|:--:|:--:|:--:|
|1|10|2|
|1|20|1|
|2|10|5|

ahora esto cumple la regla 2NF ya que `producto_id` -> `nombre` y `(pedido_id, producto_id)` -> `cantidad`, cada dato está asociado a la clave que realmente lo determina

## Tercera forma normal (3FN)

Esta forma busca eliminar la dependencia transitiva, una columna que no pertenece a una clave candidata no debería depender de otra columna que tampoco pertenece a una clave candidata.  
Una tabla está en 3NF cuando:

1. Ya cumple 1FN
2. Ya cumple 2FN
3. Los atributos no clave dependen directamente de una clave candidata, no de otro atributo no clave

Para poder realizar estos cambios es necesario comprender que son las dependencias transitivas.  
Las dependencias transitivas se producen cuando un atributo no primario depende de otro atributo no primario, en lugar de depender directamente de la clave primaria. Esto puede generar redundancia e inconsistencias en la base de datos.  
Por ejemplo:

- A -> B (A determina B)
- B -> C (B determina C)

Esto significa que A determina indirectamente C a través de B, creando una dependencia transitiva.

**Condiciones para que una tabla esté en 3FN**

Una tabla está en 3FN si, para cada dependencia funcional no tricial X -> Y, se cumple al menos una de las siguientes condiciones.

- **X es una clave primaria:** Esto significa que los atributos del lado izquierdo de la dependencia funcional (X) deben ser una clave primaria
- **Y es un atributo principal:** Esto significa que cada elemento del conjunto de atributos Y debe ser parte de una clave candidata


