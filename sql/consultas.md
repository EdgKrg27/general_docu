# Consultas

## SELECT

SELECT es la instrucción fundamental para consultar/recuperar datos de una base de datos.

**Syntaxis**

`SELECT column1, column2, ... FROM <table_name>`

**Ejemplo**

Obtener todos los Episodios de Series:  

`SELECT * FROM Series;`

<p align="center">
  <img src="imagenes/consulta_select_01.png" width="750">
</p>

## DISTINCT

Es una claúsula que se utiliza para eliminar duplicados de los resultados de una consulta, mostrando unicamente valores unicos.  

**Sintaxis**

`SELECT DISTINCT column1, column2, ... FROM <table_name>` 

**Ejemplo**  

Obtener los generos de las Series:  

`SELECT DISTINCT genero FROM Series;`
 
<p align="center">
  <img src="imagenes/clausula_distinct.png" width="200">
</p>

## ORDER BY

Utilizado para ordenar los resultados de una consulta en orden ascendente (ASC) o descendente (DESC).

**Sintaxis**

`SELECT column1, column2, ... FROM <table_name> ORDER BY column1 [ASC, DESC], column2 [ASC, DESC], ...;`

**Ejemplo**

Obtener los titulos de las serires ordenados de forma descendente:

`SELECT titulo FROM Series ORDER BY titulo DESC;`

<p align="center">
  <img src="imagenes/clausula_orderby.png" width="150">
</p>

## LIMIT  
  
Utilizado para restringir la cantidad de filas que devuelve una consulta, es sumanet útil cuando solament se necesita ver un número específico de resultados.  

**Sintaxis**
  
`SELECT column1, column2, ... FROM <table_name> LIMIT n;`  
  
**Ejemplo**  
  
Se hace un limit de los 5 episodios conmayir duración  

`SELECT titulo, duracion FROM Episodios ORDER BY duracion DESC LIMIT 5;`

<p align="center">
  <img src="imagenes/clausula_limit.png" width="300">
</p>

## WHERE

Utilizado para filtrar registros en una consulta, ya que permite especificar condiciones para que la base de datos devuelva solo las filas que cumplan ciertos criterios.

**Sintaxis**

`SELECT column1, column2, ... FROM <table_name> WHERE column (=,<,>,>=,<=,<> o !=) 'condition';`

**Ejemplo**

Todas las series donde su genero sea drama  

`SELECT * FROM Series WHERE genero='Drama'`

<p align="center">
  <img src="imagenes/clausula_where.png" width="700">
</p>

Todas las series donde el año de lanzamiento sea mayor a 2010  

`SELECT * FROM Series WHERE anio_lanzamiento > 2010;`

<p align="center">
  <img src="imagenes/clausula_where.png" width="700">
</p>

## Operadores lógicos y operadores de comparación  
  
Son utilizados para tener condiciones en las consultas, los oepradores de comparación se utilizan para comparar valores entre columnas o con valores específicos, los operadores lógicos se utilizan para combiarn varias condiciones.  
  
| Operador | Significado | Ejemplo |  
|:--------: |:--------:| :--------:|  
| =  | Igual a  | precio = 100  |  
| <> o !=  | Diferente de  | precio <> 100  |  
| >  | Mayor que  | edad > 18  |  
| <  | Menor que  | edad < 18  |  
| >=  | Mayor igual que  | salario >= 2000  |  
| <=  | Menor igual que  | salario <= 2000  |  
| AND  | todas las condiciones deben cumplirse  | edad > 18 AND pais = 'Mexico'  |  
| OR  | al menos una condición debe cumplirse  | pais = 'Mexico' OR pais = 'España'  |  
| NOT  | Niega la condición  | NOT edad = 18  |  
| BETWEEN  | Busca valores entre un rango  | BETWEEN 100 AND 500  |  
