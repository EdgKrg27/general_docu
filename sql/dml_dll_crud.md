# Creación de tablas utilizando DDL, DML y CRUD

Existen cinco grupos para poder englobar todo lo necesario con SQL

## 1. **DDL (Lenguaje de Definición de Datos):**

Subconjunto de comandos en SQL que se utilizan exclusivamente para diseñar, crear, modificar y destruir la estructura de los objetos dentro de una base de datos.

- `CREATE` Sirve para crear desde cero un nuevo objeto como una base de datos o una tabla en la base de datos. Por ejemplo:

```sql
CREATE TABLE Series(
    serie_id INT AUTO_INCREMENT PRIMARY KEY
)

CREATE DATABASE <base_datos>
```

- `ALTER`: Se utiliza cuando el objeto ya existe, pero necesitas cambiar su estructura sin borrarlo, por ejemplo, cuando se quiere agregar una columna nueva, borrar una columna existente o cambiar el tipo de dato.

```sql
ALTER TABLE Series
ADD COLUMN rating DECIMAL(3,2);
```

- `DROP` Borra definitivamente un objeto y toda su estructura de la base de datos. Si lo usas con una tabla, la tabla desaparece por completo del mapa junto con todos los datos que tenía dentro. Este comando s debe tener cuidado ya que no hay manera de recuperar la información.

```sql
DROP TABLE Series;
```

- `TRUNCATE` Este comando es un híbrido, sirve para borrar todos los datos de una tabla de golpe, pero mantiene la estructura intacta para que puedas seguir usándola. Además, reinicia los contadores automáticos (`AUTO_INCREMENT`)

```sql
TRUNCATE TABLE Series;
```

#### Comando clave para DDL

### 2. **DML (Lenguaje de Manipulación de Datos):**

Subconjunto de comandos de SQL que se utilizan para gestionar, modificar y consultar los datos que ya están guardados dentro de la tablas de la base de datos.

#### Comandos Clave para el DML

- `INSERT`: Se utiliza para añadir nuevas filas a tus tablas, este tiene cuatro variantes estandar:

1. _Estructura estándar (especificando columnas)_: Es la forma más segura y recomendada. Mapeas directamente los campos con los valores

```sql
INSERT INTO Series (titulo, descripcion, anio_lanzamiento, genero)
VALUES ('Better Call Saul', 'El viaje del abogado Jimmy McGill antes de Breaking Bad.', 2015, 'Drama');
```

2. _Inserción masiva o múltiple_: Permite insertar varias filas en una sola sentencia separándolas por comas.

```sql
INSERT INTO Series (titulo, descripcion, anio_lanzamiento, genero) VALUES
('Mindhunter', 'Agentes del FBI entrevistan a asesinos seriales.', 2017, 'Drama'),
('Dark', 'La desaparición de un niño expone secretos de cuatro familias.', 2017, 'Ciencia ficción');
```

3. _Inserción posicional_: No se especifica la columna, pero te obliga a poner los valores en el orden exacto en lo que fueron creados en la estructura de la tabla.

```sql
-- Asumiendo que serie_id es AUTO_INCREMENT, ponemos NULL o DEFAULT al inicio
INSERT INTO Series
VALUES (DEFAULT, 'Peaky Blinders', 'Una familia de gánsteres en el Birmingham de los años 20.', 2013, 'Drama histórico');
```

4. _INSERT INTO ... SELECT_: Ideal. para migrar datos, inserta filas que se extraen como resultado de otra consulta.

```sql
INSERT INTO Series_Historicas (titulo, anio_lanzamiento)
SELECT titulo, anio_lanzamiento
FROM Series
WHERE genero = 'Drama histórico';
```

- `UPDATE`: Sirve para edigtar registros existentes, su potencia (y peligro) radica en los filtros.

1. _Actualización simple con filtro único_: Modifica uno o varios campos de una fila especifica utilizando una condición inequívoca (generalmente `PRIMARY KEY`)

```sql
UPDATE Series
SET genero = 'Drama Criminal', anio_lanzamiento = 2015
WHERE serie_id = 1; -- Afecta solo a Breaking Bad
```

2. _Actualización condicional basada en expresiones_: Modifica datos de forma masiva basándose en un cálculo numérico o de texto.

```sql
-- Si necesitas corregir un desfase masivo de años en los episodios de una serie
UPDATE Episodios
SET anio_lanzamiento = anio_lanzamiento + 1
WHERE serie_id = 2;
```

3. _UPDATE con subconsultas_: Modifica una tabla utilizando información almacenada en otra tabla distinta.

```sql
UPDATE Series
SET descripcion = 'Contiene actores galardonados'
WHERE serie_id IN (
    SELECT serie_id
    FROM Actores_Series
    WHERE actor_id = 12 -- ID de un actor específico
);
```

- `DELETE`: Elimina físicamente filas de una tabla. Al igual que el `UPDATE`, dependiendo críticamente del `WHERE`

1. _Eliminación específica con filtro_: Borra únicamente los registros que coinciden de manera exacta con el criterio.

```sql
DELETE FROM Episodios
WHERE episodio_id = 45;
```

2. _Eliminación masiva por criterio de categoría_: Borra grupos enteros de datos.

```sql
DELETE FROM Series
WHERE anio_lanzamiento < 2000;
```

3. _DELETE con subconsultas_: Borra registros basándose en el estado o la existencia de datos en tablas relacionadas.

```sql
-- Borrar las series que no tienen ningún actor asignado en la tabla intermedia
DELETE FROM Series
WHERE serie_id NOT IN (
    SELECT DISTINCT serie_id FROM Actores_Series
);
```

4. _Eliminación total de registros_: Elimina todas las filas de la tabla una por una, manteniendo la estructura intacta. Para campos `AUTOINCREMENT` mantiene el último número registrado, además de que si se pude deshacer la operación si estás dentro de una transacción o la información este en una copia de seguridad.

```sql
DELETE FROM Episodios;
```

Se pued utilizar también `TRUNCATE` pero este comando no puede borrar información específica, este borra completamente la tabla, es extremadamente rápido ya que libera espacio de almacenamiento, en la mayoría de los motores de SQL no se puede deshacer la operación porque hace inmediatamente un commit de la operación.  
Para los campos `AUTOINCREMENT` reinicia el conteo desde 1.

```sql
TRUNCATE TABLE Actores_Series;
```

## 3. **DQL (Lenguaje de Consulta de Datos):**

Subconjunto de comandos de SQL que tienen como objetivo consultar, recuperar datos de las base de datos sin alterar absolutamente nada.

En el DQL el unico comando que se utiliza es el `SELECT`, este comando es sumamente complejo ya que se expande utilizando diversas cláusulas para filtrar, agrupar y ordenar la información.  
Las cláusulas son:

```sql
SELECT columnas, FUNCIONES_VENTANA()    -- 5. Que datos quieres ver y qué calculos mostrar
FROM tabla_principal                    -- 1. De dónde salen los datos originalmente
INNER JOIN otra_tabla ON  condicion     -- 2. Con qué otras tablas se van a conectar
WHERE filtros_de_filas                  -- 3. Que filas individuales se descartan
GROUP BY columnas_a_agrupar             -- 4. Cómo se van agrupar los resultados
HAVING filtros_de_grupos                -- 6. Que grupos se descartan tras el cálculo
ORDER BY columnas_a_ordenar             -- 7. En qué orden se despliega el resultado final
LIMIT cantidad_de_filas                 -- 8. Cuántos registros mostrar en pantalla
```

los números mostrados en los comentarios, son el orden de ejecución interno que sigue el motor de la base de datos.

## 4. **DCL (Lenguaje de Control de Datos):**

Subconjunto fundamental de comandos de SQL y se encarga exclusivamente de la seguridad, los permisos y los accesos dentro de la base de datos.  
Este se compone exactamente de dos comandos, ya que es muy directo el DCL.

- `GRANT (Otorgar)`: Sirve para dar permisos a un usuario o rol específico para que puedan realizar ciertas acciones (como consultar, insertar o modificar) sobre objetos de la base de datos.

**Ejemplo**  
Solo se puede ver la tabla Series, pero no se puede borrar ni modificar nada.

```sql
GRANT SELECT ON netflixdb.Series TO 'newanalista'@'localhost';
```

En caso de que queramos dar acceso total a la tabla (insertar, actualizar y borrar).

```sql
GRANT INSERT, UPDATE, DELETE ON netflixdb.Series TO 'newanalista'@'localhost';
```

- `REVOKE`: Sirve para quitar o cancelar los permisos que habías otorgado previamente con `GRANT`

**Ejemplo**

Ya no se debe ver la tabla Series, se requiere revocar el permiso.

```sql
REVOKE SELECT ON netflixdb.Series FROM 'newanalista'@'localhost';
```

## 5. **TCL (Lenguaje de Control de Transacciones):**

Es el encargado de gestionar la integridad y la seguridad de los cambios que haces con los comandos DML, es decir, una transacción es un conjunto de operaciones que se ejecutan como si fueran un único bloque, o se guardan todas con éxito o no se guarda ninguna.
Es decir, TCL evita evita que haya perdida de información ya que si falla a mitad de camino, todo regresa a su estado original.

### Los comandos clave son:

- `BEGIN TRANSACTION`: Es el comando que le dice al motor de la base de datos, "A partir de aquí, todo lo que se haga es temporal"

- `COMMIT`: Escribe los cambios de forma permanente en el disco duro de la base de datos, una vez hecho un commit, ya no hay marcha atras.

```sql
START TRANSACTION;

-- Insertamos una nueva serie
INSERT INTO Series (titulo, descripcion, anio_lanzamiento, genero)
VALUES ('Gambito de Dama', 'Una huérfana se convierte en prodigio del ajedrez.', 2020, 'Drama');

-- Insertamos su primer episodio (necesitamos que la serie exista)
INSERT INTO Episodios (serie_id, titulo_episodio, anio_lanzamiento)
VALUES (14, 'Aperturas', 2020);

-- Como todo salió bien, guardamos definitivamente ambos registros
COMMIT;
```

- `ROLLBACK`: La base de datos, cancela todas las operaciones hechas desde el STAR TRANSACTION y deja todo exactamente igual.

```sql
START TRANSACTION;

-- ¡Oh no! Olvidé el WHERE y modifiqué todas las series de Netflix por error
UPDATE Series SET anio_lanzamiento = 2026;

-- Al darme cuenta del desastre, invoco el salvavidas:
ROLLBACK;
-- Todo volvió a la normalidad, la base de datos intacta.
```

- `SAVEPOINT`: Es un punto de control, te permite hacer un `ROLLBACK` parcial.

```sql
START TRANSACTION;
INSERT INTO Series ... -- Operación 1
SAVEPOINT punto_uno;   -- Creamos el punto de control

INSERT INTO Series ... -- Operación 2 (Imagina que esta falla)

ROLLBACK TO punto_uno; -- Deshacemos solo la operación 2
COMMIT;                -- Guardamos la operación 1 de forma segura
```

## Índices

Son una estructura de datos secundaria quew sirve para acelerar drásticamente la velocidad de búsqueda y recuperación de registros en una tabla.

La funcionalidad interna de un índice es que cuando se crea sonbre una columna el motor de la base de datos crea una estructura separada usualmente un árbol binario balanceado o B-Tree.

Esta estructura guarda una copia ordenada de los titulos junto con un "puntero". Cuando se hace un SELECT el motor busca en el árbol ordenado en microsegundos y salta directo al registro.

_Sintaxis_

```sql
CREATE INDEX index_name
ON table_name (columna1, columna2, ...);
```

### Tipos de índices

1. **Índice primario (Clustered Index / Llave primaria)**  
   Es el índice que se crea automáticamente cuando defines un campo como `PRIMARY KEY`. Su características son que determinan el orden físico en el que se almacenan los datos en el disco duro, solo puede haber uno por tabla.

2. **Índice secundario**  
   Es un índice que se crea manualmente sobre columnas que se consultan constantemente pero que no son lalve primaria. Su característica es que no cambia el orden físico de la tabla, crea un objeto separado para la búsqueda, se puede tener múltiples índices secundarios en una tabla.

_Ejemplo_
Se tiene una tabla que se busca constantemene el nombre de una serie, se puede crear un índice en la columna `titulo`.

```sql
CREATE INDEX idx_series_titulo ON Series(titulo);
```

3. **Índice único (Unique Index)**  
   Asegura que todos los valores de la columna sean diferentes. Se crea automáticamente con la restricción `UNIQUE`

_Ejemplo_

Si no se desea que existan dos usuarios con el mismo correo

```sql
CREATE UNIQUE INDEX idx_usuarios_email ON Usuarios(email)
```

4. **Índice compuesto (Composite Index)**  
   Es un índice que abarca dos o más columnas al mismo tiempo. Es extremadamente útil cuando los filtros `WHERE` suelen combinar los mismos campos siempre

_Ejemplo_

Tenemos una consulta que siempre busca episodios filtrando por la serie y el año de lanzamiento al mismo tiempo.

```sql
CREATE INDEX idx_episodios_serie_anio ON Episodios(serie_id, anio_lanzamiento);
```

Los índices son buenos pero tienen un costo, los índices hacen que las consultas sean ultrarrápidas, pero no se deben utilizar siempre ya que se debe tener un balance para el rendimiento.

- Aceleran la lectura _R_ (READ / `SELECT`), las búsquedas se vuelven inmediatas
- Frenan en _CUD_ (`CREATE` / `INSERT`, `UPDATE`, `DELETE`), cada vez que se agrega un nuevo registro, el motor no solo tiene que alterar la tabla real, además tiene que ir a reordenar y actualizar todos los índices que afectan a esa columna.

Además los índices ocupan espacio real en el disco duro, si una tabla pesa 1GB, tener demasiados índices puede hacer que el espacio se duplique.

#### Cuando útilizar índices:

1. Columnas que se usan frecuentemente en cláusulas `WHERE`
2. Columnas que se utilicen para hacer uniones entre tablas (`JOIN`) como las llaves foráneas
3. Columnas que se utilizan constantemente para ordenar resultados (`ORDER BY`)

Se deben evitar completamente en tablas que cambien millones de veces la información por segundo (mucha escritura y poca lectura) o en columnas con datos muy repetitivos.
