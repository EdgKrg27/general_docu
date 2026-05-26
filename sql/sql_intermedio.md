# SQL INTERMEDIO

## Subconsulta

También conocida como Inner Query es una consulta dentro de otra consulta. Se utilizan para realizar operaciones que requieren dos pasos: primero obtener un dato o conjunto de datos y luego usar ese resultado para filtrar o calcular la consulta principal.

Las subconsultas simpre van encerradas entre paréntesis `()` y dependiendo de lo que necesites, se pueden ubicar en diferentes cláusulas.

### `WHERE` (filtrado dinámico): permite filtrar registros basados enun valor que no se conoce

**Ejemplo**

Obtener los episodios que tienen un rating mayor al promedio de toda las base de datos:

```sql
SELECT titulo, rating_imdb
FROM Episodios
WHERE rating_imdb > (SELECT avg(rating_imdb) FROM Episodios);
```

<p align="center">
  <img src="./imagenes/subquery_where.png" width="auto">
</p>

### `FROM` (tabla temporal): Aqui la subconsulta actúa como una tabla virtual a la que le puedes dar un alias.

**Ejemplo**  
Se quiere saber cuántos episodios tiene cada serie y filtrar solo las que tienen más de 10:

```sql
SELECT T.titulo, T.cantidad_episodios
FROM (
    SELECT s.titulo, COUNT(e.episodio_id) AS cantidad_episodios
    FROM Series s
    INNER JOIN Episodios e ON s.serie_id = e.serie_id
    GROUP BY s.titulo
) AS T
WHERE T.cantidad_episodios > 10;
```

<p align="center">
  <img src="./imagenes/subquery_from.png" width="auto">
</p>

### `SELECT` (para cálculos fila por fila): Se usa para traer un dato específico relacionado con cada fila de la consulta principal.

**Ejemplo**

Mostrar una lista de todas las Series, pero al lado de cada nombre, queremos ver cuántos Episodios tiene registrados en total.

```sql
SELECT
    titulo,
    genero,
    (SELECT COUNT(*)
    FROM Episodios
    WHERE Episodios.serie_id = Series.serie_id) AS total_episodios
FROM Series;
```

<p align="center">
  <img src="./imagenes/subquery_select.png" width="auto">
</p>

---

---

Dependiendo de qué devuelva la subconsulta, usarás operadosres distintos:

|  Tipo   |              Retorno               |          Operador común          |
| :-----: | :--------------------------------: | :------------------------------: |
| Escalar | Un único valor (1 fila, 1 columna) |           =, >, <, !=            |
|  Lista  |    Una columna con varias filas    |           IN, ANY, ALL           |
|  Tabla  |   Varias filas y varias columnas   | Se usa principalmente en el FROM |

---

---

Además las consultas pueden ser correlacionadas o no correlacionadas:

- **No correlacionadas:** La subconsulta es independiente, si se ejcuta aparte funciona correctamente.

- **Correlacionada:** La subconsulta hace referencia a una columna de lac onsulta principal, se ejecuta una vez por cada fila que procesa la consulta principal. Es más potente pero suele ser más lenta.

**Ejemplo**

Obtener las serires cuya descripción sea más larga que el promedio de las descripciones de su mismo género.

```sql
SELECT titulo, genero
FROM Series s1
WHERE LENGTH(descripcion) > (
    SELECT AVG(LENGTH(descripcion))
    FROM Series s2
    WHERE s1.genero = s2.genero
);
```

<p align="center">
  <img src="./imagenes/subquery_correlacionada.png" width="auto">
</p>

---

---

En que momento se debe utilizar una subconsulta o un JOIN:

- Se usa `JOIN` cuando se necesite mostrar columnas de ambas tablas en el resultado final (es más eficiente en la mayoría de los motores)

- Se usa una subconsulta cuando solo necesites un dato para filtrar o cuando la lógica sea más fácil de leer de esa manera

## IF condicional

Cláusula que funciona solamente en MySQL, tiene la funcionalidad de realizar condiciones binarias Sí o No.

**Sintaxis**  
`IF(condición, valor_si_verdadero, valor_si_falso)`

**Ejemplo**  
Queremos saber rápidamente si una serie es antigua o nueva basada en su año de lanzamiento

```sql
SELECT
    titulo,
    anio_lanzamiento,
    IF(anio_lanzamiento < 2015, 'Clasica', 'Moderna') AS era
FROM Series;
```

<p align="center">
  <img src="./imagenes/if_condicional.png" width="auto">
</p>

## CASE

Es la forma más común y es la forma más común de como funciona un "sí pasa esto, haz aquello"

**Sintaxis**

```sql
CASE
  WHEN <condición1> THEN <valor1>
  WHEN <condición2> THEN <valor2>
  WHEN <condición3> THEN <valor3>
  ...
  ELSE <valor_caso_contrario>
END AS <alias>
```

donde:

- `WHEN`: Evalúa la condición
- `THEN`: Es el resultado si la condición es verdadera
- `ELSE`: Es el valor por defecto si ninguna condición anterior se cumple

**Ejemplo**

Saber que episodios con Cortos o Largos y si su calificación en IMDb los posiciona como Populares.

```sql
SELECT
    titulo,
    rating_imdb,
    duracion,
    -- Categoría por rating
    CASE
        WHEN rating_imdb >= 9.5 THEN '⭐⭐⭐⭐⭐ Obra Maestra'
        WHEN rating_imdb >= 8.5 THEN '⭐⭐⭐⭐ Muy Recomendado'
        WHEN rating_imdb >= 7.0 THEN '⭐⭐⭐ Aceptable'
        ELSE 'No Recomendado'
    END AS estatus_critica,
    -- Categoría por duración
    CASE
        WHEN duracion > 60 THEN 'Largo (Formato Cine)'
        WHEN duracion BETWEEN 40 AND 60 THEN 'Estandar TV'
        ELSE 'Corto /Sitcom'
    END AS formato
FROM Episodios
ORDER BY rating_imdb DESC;
```

<p align="center">
  <img src="./imagenes/clausula_case.png" width="auto">
</p>

## CAST

Sirve para cambiar el tipo de dato de una columna o valor durante la ejecución de la consulta. Es muy útil cuando quieres tratar un texto como número o un decimal como entero.

**Sintaxis**

`CAST(<column> AS <nuevo tipo>)`

**Ejemplo**

Ver todo los episodios donde la fecha de estreno sea mayor a 2010-01-01.

```sql
SELECT *
FROM Episodios
WHERE CAST(fecha_estreno AS UNSIGNED) > '2010-01-01';
```

<p align="center">
  <img src="./imagenes/cast_fecha.png" width="auto">
</p>

## FUNCIONES DE FECHA

Sirven para manipular, extraer y calcular tiempos. Las funciones más comunes son:

- `CURDATE() / NOW()`: Obtiene la fecha o la hora actual del servidor
- `YEAR() / MONTH() / DAY()`: Extrae una parte especifica de una fecha
- `DATEFIFF(fecha1, fecha2)`: Calcula cuántos días hay de diferencia entre dos fechas.
- `DATE_ADD(fecha1, INTERVAL number DAY)`: Agrega una cantidad de día a la fecha, es decir, suma días

**Ejemplo**

Crear una columan año y mes a partir de la fecha de estreno

```sql
SELECT
    fecha_estreno,
    YEAR(fecha_estreno) as AÑO,
    MONTH(fecha_estreno) as MES
FROM Episodios
```

<p align="center">
  <img src="./imagenes/fecha_estreno.png" width="300">
</p>

Calcular cuantos días han pasado desde la fecha de estreno a la actualidad

```sql
select *,
    DATEDIFF(CURDATE(), fecha_estreno)
FROM Episodios;
```

<p align="center">
  <img src="./imagenes/diff_date.png" width="auto">
</p>

Agregar 20 días a la fecha de estreno

```sql
SELECT
    fecha_estreno,
    DATE_ADD(fecha_estreno, INTERVAL 20 DAY)
from Episodios
```

<p align="center">
  <img src="./imagenes/date_add.png" width="300">
</p>

## MANIPULACIÓN DE CADENAS

Sirven para edigtar el texto en los resultados, las funciones más comunes son:

- `UPPER(columna)` / `LOWER(columna)`: Pasa todos los resultados a mayúsculas o minúsculas
- `SUBSTR(texto, posicion_inicial, longitud)`: Sirve para extraer una parte específica de una cadena de texto.
- `CONCAT(columna1, columna2)`: Une varios textos en uno solo
- `REPLACE()`: Cambia una palabra por otra dentro del texto

**Ejemplo**

Mayúsculas

```sql
SELECT
    UPPER(titulo) AS 'titulo_mayusculas'
FROM Series;
```

<p align="center">
  <img src="./imagenes/upper.png" width="350">
</p>

Mínusculas

```sql
SELECT
    LOWER(titulo) AS 'titulo_mayusculas'
FROM Series;
```

<p align="center">
  <img src="./imagenes/lower.png" width="350">
</p>

Substring

```sql
SELECT SUBSTR(fecha_estreno, 1, 4) FROM Episodios;
```

<p align="center">
  <img src="./imagenes/substring.png" width="450">
</p>

Replace

```sql
SELECT
    REPLACE(titulo, 'Breaking', 'Nuevo Nuevo')
FROM Series
LIMIT 1;
```

<p align="center">
  <img src="./imagenes/substring.png" width="450">
</p>

## Funciones Matemáticas

Funciones ideales para cálculos estadísticas rápidas, las funciones más comunes son:

- `ROUND(valor, decimales)` Redondea al número de decimales que pidas
- `FLOOR() / CEIL()`: Redondea hacia abajo o hacia arriba el entero más cercano
- `ABS()`: Valor absoluto (quita el signo negativo)

**Ejemplo**

Round

```sql
SELECT
    ROUND(rating_imdb)
FROM Episodios;
```

<p align="center">
  <img src="./imagenes/round.png" width="300">
</p>

Floor

```sql
SELECT
    FLOOR(rating_imdb)
FROM Episodios;
```

<p align="center">
  <img src="./imagenes/floor.png" width="300">
</p>

Ceil

```sql
SELECT
    CEIL(rating_imdb)
FROM Episodios;
```

<p align="center">
  <img src="./imagenes/ceil.png" width="300">
</p>

ABS

```sql
SELECT
  ABS(rating_imdb)
FROM Episodios;
```

<p align="center">
  <img src="./imagenes/abs.png" width="300">
</p>
