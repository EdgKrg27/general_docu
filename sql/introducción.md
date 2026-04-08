# SQL

## Qué es SQL.
Es un lenguaje de consulta estructurado, esta diseñado para permitir consultar, manipular y transformar datos de una base de datos relacional. 

## Bases de datos relacionales
La base de datos relacional representa una colección de tablas (bidimensionales) con un número fijo de columnas con nombre y cualquier número de filas de datos.  
Por ejemplo una tabla donde se almacenen toda la información de los autos conocidos actualmente.

| ID | Modelo | # Ruedas |# Puertas|Tipo|
|:----------:|:----------:|:----------:|:----------:|:----------:|
| 1 | Ford Focus | 4 | 4 | Sedán |
| 2 | Tesla Roadster | 4 | 2 | Deportivo |
| 3 | Kawasaki Ninja | 2 |0 | Motocicleta |
| 4 | MacLaren Fórmula 1 | 4 | 0 | Carrera |

También dentro de la misma base de datos podemos tener otra tabla donde se encuentren todos los registros de conductores registrados, permisos de conducir, etc...  

## Tipos de datos
**1. Cadenas de texto (Strings):** Utilizado para nombres, correos, descripciones o códigos

|Tipo de Dato|PostgreSQL|OracleDB|Nota|
|:----------:|:----------:|:----------:|:----------:|
|Longitud Variable|VARCHAR o TEXT|VARCHAR2|En ORacle, siempre usa VARCHAR2. TEXT en PostgreSQL es infinito y muy eficiente|
|Longitud Fija|CHAR(n)|CHAR(n)|Usado solo para códigos de longitud fija (como el ISO de un país: "MX", "US"|
|Grandes textos|TEXT|CLOB|Para guardar párrafos enteros o documentos|

**2. Números (Numeric):** 
|Tipo de Dato|PostgreSQL|OracleDB|Nota|
|:----------:|:----------:|:----------:|:----------:|
|Enteros|INT o BIGINT|NUMBER|Oracle usa NUMBER para todo pero se puede especificar NUMBER(p,s)|
|Decimales Exactos|NUMERIC(p,s)|NUMBER(p,s)|Este se debe utilizar para calculos de dinero ya que evita errores de redondeo|
|Decimales Flotantes|FLOAT|BINARY_FLOAT|Úsalos para datos científicos donde la precisión exacta no es crítica|

**3. Fechas y Tiempo (Date & Time):**
|Tipo de Dato|PostgreSQL|OracleDB|Nota|
|:----------:|:----------:|:----------:|:----------:|
|Solo fecha|DATE|DATE*|En Oracle DATE incluye hora. En PostgreSQL Date es solo día/mes/año|
|Fecha y Hora|TIMESTAMP|TIMESTAMP|PostgreSql permite TIMESTAMPZ que es por zona horaria|
|Intervalos|INTERVAL|INTERVAL|Para sumar "3 días" o "1 mes" a una fecha de forma sencilla|

**4. Tipos Especiales:**
* Booleanos
    - PostgreSql: Tiene el tipo BOOL (TRue, FALSE, NULL)
    - Oracle: No tiene un tipo booleano definido se suele utilizar NUMBER(1) donde 1=TRUE, 0=FALSE
* JSON
    - PostgreSql: utiliza JSONB como almaceniamiento binario rápido
    - Oracle: Utiliza JSONo BLOB/ClOB con restricciones de formato
* Identificadores Únicos
    - PostgreSql: UUID
    - Oracle: RAW(16) o generados por secuencia

## Tablas
Las tablas son la estructura fundamental de almacenamiento en una base de datos relacional, organizada en filas (registros) y columnas (campos).  
Casa columna define un atributo de datos y tipos de datos (nombre, edad, fecha) y cada fila contiene un conjunto de valores que son los que contienen los registros reales, permitiendo organizar y gestionar información eficiente y relacionadas entre sí.  
La estructura de una tabla es la siguiente:

* **Nombre de la tabla:** Identificador único de la base de datos
* **Columnas:** definen los atributos
* **Filas:** representan instancias de datos
* **Restricciones:** reglas aplicadas a las columnas

|id|nombre|email|ciudad|
|:-:|:-:|:-:|:-:|
|1|Ana|ana@email.com|Madrid|
|2|Luis|luis@email.com|Barcelona|
|3|Carla|carla@email.com|Madrid|

### Creacion de una tabla
Se debe utilizar la sentencia CREATE TABLE:  

```sql
CREATE TABLE clientes{
    id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    ciudad VARCHAR(100)
};
```