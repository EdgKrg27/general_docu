# Programación y Automatización en SQL

## Vistas (View)

Es una tabla virtual cuyo contenido está definido por el resultado de una consulta SQL preexistente. La vista no almacena datos físicamente en el disco duro, cada vezs que se consulta una vista, está mira en tiempo real dentro de las tablas reales para mostrar la información actualizada.

**Sintaxis**

```sql
CREATE VIEW nombre_vista AS
SELECT columnas
FROM nombre_tabla
WHERE condiciones;
```

Una vez que se encuentra creada la vista, se puede consultar exactamente igual que una tabla normal, es decir, con un `SELECT`.

**Ejemplo**

El equipo de marqueting necesita constantemente un reporte con el título de la serie, el título del episodio y el año de lanzamiento para las redes sociales.

```sql
CREATE VIEW Vista_Catalogo_Episodios AS
SELECT
    s.titulo AS nombre_serie,
    s.genero AS genero_serie,
    e.titulo_episodio AS nombre_episodio,
    e.anio_lanzamiento AS anio_estreno_episodio
FROM Series AS s
INNER JOIN Episodios AS e ON s.serie_id = e.serie_id;
```

Para la ejecución solamente se realiza una consulta directo a la vista

```sql
SELECT * FROM Vista_Catalogo_Episodios
WHERE genero_serie = 'Ciencia ficción';
```

Las ventajas de utiliar vistas son las siguiente:

1. **Simplifica el código (Abstracción)**: Ocultan la complejidad de consultas gigantescas con múltiples `JOINS`, funciones ventana o subconsultas complejas detras de un simple `SELECT`
2. **Seguridad de los datos**: Permiten restringir el aceso a la información confidencial.
3. **Consistencia de lógica**: Si los nombres de las tablas reales cambien en un futuro, solamente basta con corregir el código interno de la vista una sola vez.

## Disparadores (Triggers)

Bloque de código asociado a una tabla específica que se ejecuta de forma automática cuando ocurre un evento de modificación de datos (DML -> `UPDATE`, `INSERT`, `DELETE`) en esta tabla.

Un trigger tiene 3 componentes:

1. **El evento**: Que acción del usuario activa el trigger (`INSERT`, `UPDATE`, `DELETE`)
2. **El momento**: Cuándo debe ejecutarse el código respecto al evento
   - `BEFORE` (Ántes): útil para validar o modificar los datos antes de que se guarden en la tabla
   - `AFTER` (Después): útil para registrar auditorías o replicar cambios en otras tablas después de que el cambio ya se consolidó
3. **El ámbito** (`FOR EACH ROW`): índica que un trigger se ejecutará individualmente por cada una de las filas que resulten afectadas por la consulta.

Variables especiales:

- `NEW`: Contiene los valores de la fila entrante (los nuevos datos que se quieren guardar), este se encuentra disponible con `INSERT` y `UPDATE`
- `OLD`: Contiene los valores de la fila original (los datos viejos que ya existían antes del cambio), este se encuentra dispoible en `UPDATE` y `DELETE`

**Ejemplo**

Imagina que la base de datos de NetflixDB tiene una tabla llamada Historial_Video donde guardas qué episodios ve cada usuario. Quieres crear una tabla de auditoría para saber cuándo se modificó un registro y qué valor tenia antes.

#### Estructura del trigger (`AFTER UPDATE`)

```sql
DELIMITER $$

CREATE TRIGGER AuditarHistorialVideo
AFTER UPDATE ON Historial_Video
FOR EACH ROW
BEGIN
    -- Si el usuario cambia el estado de un video (ej. de 'Pausado' a 'Finalizado')
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO Log_Auditoria (usuario_id, video_id, estado_anterior, estado_nuevo, fecha_cambio)
        VALUES (OLD.usuario_id, OLD.video_id, OLD.estado_anterior, NEW.estado, NOW());
    END IF;
END $$

DELIMITER ;
```

#### Como se ejecuta

En este caso solamente ejecutando un `UPDATE` normal

```sql
UPDATE Historial_Video SET estado = 'Finalizado' WHERE historial_id = 45;
```

Al activar la línea el trigger se activa e inserta la fila de control en la tabla `Log_Auditoria` de forma automática.
