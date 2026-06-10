# PROGRAMACIÓN EN SQL

## Procedimientos almacenados

Son un conjunto de instrucciones SQl que se crea y se compilan una sola vez, quedando guardadas directamente en el servidor de la base de datos para ser ejecutadas o reutilizadas en cualquier momento.  
Para crear un procedimiento almacenado se utiliza el comando `CREATE PROCEDURE`.

**Sintaxis**

```sql
DELIMITER //

CREATE PROCEDURE nombre_del_procedimiento(
    [IN | OUT | INOUT] nombre_parametro tipo_dato
)
BEGIN
    -- Aquí se escribe todo el código SQL (DQL, DML, TCL, etc...)
END //

DELIMITER;
```

Para hacer la llamada de este procedimiento se utiliza el comando `CALL`

`CALL nombre_del_procedimiento();`

### Tipos de parámetros (Entradas y Salidas)

Los procedimientos almacenados son como pequeñas funciones de programación, pueden recibir datos, procesarlos y devolver los resultados. Existen tres tipos de parámetros.

1. `IN` (Entrada): Es el valor que tú le envías desde afuera para que el procedimiento lo use en sus filtros o lógica. (Es el tipo por defecto si no se pone nada).
2. `OUT` (Salida): Es una variable vacía que le pasas al procedimiento para que este la llene con un resultado y la devuelva.
3. `INOUT` (Entrada/Salida): Una mezcla de ambos, son las que envías un dato, el procedimiento lo modifica y devuelve el valor cambiando en la misma variable.

**Ejemplo**

Usarios buscan constantemente series por género. Crear un procedimiento almacenado que haga las consultas comunes.

```sql
-- procedimiento con IN
CREATE PROCEDURE ObtenerSeriesPorGenero(IN nombre_genero VARCHAR(255))
BEGIN
    SELECT titulo, anio_lanzamiento, descripcion
    FROM Series
    WHERE genero = nombre_genero
    ORDER BY anio_lanzamiento DESC;
END;

-- la forma de llamarlos es la siguiente:
CALL ObtenerSeriesPorGenero('Drama');
```

```sql
-- procedimiento con OUT
CREATE PROCEDURE ContarEpisodiosDeSerie (
    IN id_de_serie INT,
    OUT total_episodios INT
)
BEGIN
    SELECT count(*) INTO total_episodios
    FROM Episodios
    WHERE serie_id = id_de_serie;
END;

-- la forma de llamarlo es la siguiente:
CALL ContarEpisodiosDeSerie(1, @resultado);
SELECT @resultado AS episodios_totales;
```

Las ventajas de usar procedimiento almacenados son las siguiente:

- **Rendimiento:** Al estar pre-compilados en el servidor, el motor de la base de datos no tiene que analizar sintaxis ni crear un plan de ejecución vada vez que sea invocado. Corren mucho más rápido que una consulta plana enviada desde una aplicación web.
- **Seguridad (Reducción de tráfico e inyección SQL):** En lugar de enviar un script con varias líneas de código, aquí solamente se envía una sola línea de código comenzando con `CALL` el cual evita ataques de inyección de código.
- **Centralización de la lógica:** Si las reglas de negocio cambian solo basta con hacer el cambio en el procedimiento almacenado directamente en la base de datos una sola vez.

## Transacciones

Conjunto de uno o más operaciones SQL (como `INSERT`, `UPDATE`, `DELETE`) que se ejecuta como una única unidad de trabajo lógica e indivisible, es decir, todas las operaciones se tiene que hacer, con una operación que no se haga las demás operaciones no se realizan y la base de datos regresa al estado original.

Para que una base de datos pueda realizar transacciones de seguir las propiedades ACID.

- **Atomicidad** La transacción es un bloque atómico (indivisible), no puede quedart a medias, o se consolida completo (commit) o se revierte por completo (rollback).
- **Consistencia** Una transacción solo puede llevar a la base de datos de un estado válido a otro estado válido, respetando todas las reglas, restricciones de integridad (`FOREIGN KEY`, `UNIQUE`, etc...) y validaciones del sistema.
- **Aislamiento** Si hay múltiples transacciones ejecutándose al mismo tiempo, cada transacción debe operar de forma aislada. Ninguna transacción puede ver los cambios temporales de otra hasta que esos cambios se hayan guardado definitivamente.
- **Durabilidad** Una vez aque la transacción se complete con éxito y se confirme, los cambios se graban de manera permanente en el almacenamiento físico (disco duro) y no se perderán aunque el servidor sufra un apagón inmediatamente después.

El ciclo de vida de una transacción es la siguiente:

1. `START TRANSACTION` Abre la compuerta. Le avisa al motor de la base de datos que los cambios siguientes son temporales.
2. `COMMIT` Guarda de forma definitiva y permanente en el disco todo lo hecho en la transacción.
3. `ROLLBACK` El botón de pánico. Cancela todo el bloque y limpia los cambios temporales si algo salió mal.

**Ejemplo**

Se debe registrar el estreno de una nueva serie y al mismo tiempo, quiere meter su episodio piloto. Ambas cosas debe quedar registradas juntas para evitar que el episodio quede huerfano si la serie no se crea.

```sql
-- 1. Iniciamos el bloque seguro
START TRANSACTION;

-- 2. Intentamos insertar la serie
INSERT INTO Series (titulo, descripcion, anio_lanzamiento, genero)
VALUES ('Wednesday', 'Merlina Addams investiga una ola de asesinatos.', 2022, 'Fantasía');

-- 3. Intentamos insertar su primer episodio (asumiendo que generó el serie_id = 15)
INSERT INTO Episodios (serie_id, titulo_episodio, anio_lanzamiento)
VALUES (15, 'Y un sombrío día nació', 2022);

-- 4. Si el motor no arrojó ningún error en los pasos anteriores, confirmamos:
COMMIT;
```
