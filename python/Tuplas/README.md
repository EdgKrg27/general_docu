# Tuplas

Estructura de datos que se utiliza para almacenar una colección de elementos de forma ordenada. Estas se parecen a las listas pero con la diferencia que son inmutables.  
Las tuplas se definen utilizando paréntesis `()` y los elementos se separa por comas `,`.  
Las características principales son:  
* Inmutables: Una vez que se crea la tupla, no se puede cambair sus elementos, no se puede agregar, eliminar o modificar valores.  
* Ordenadas: Los elementos mantienen el orden en el que fueron definidos y se acceden mediante indices.  
* Permite duplicados: Puede tener el mismo valore varias veces en la misma tupla
* Heterogéneas: Pueden contener diferetntes tipos de datos al mismo tiempo.  
  
Las tuplas en que momento se debe utilizar en lugar de las listas?, esto depende totalmente del proposito de los datos:  
  
| Características | Lista `[]`| Tupla `()` |
|----------|----------|----------|
| Mutabilidad    | Mutable ( puedes cambiarla)   | Inmutable (estática)   |
| Rendimiento    | Más lenta   | Más rápida (usa menos memoria)   |
| Uso común    | Colecciones de datos que cambian   | Datos que deben protegerse (constantes)   |
| Como clave de diccionario | No se puede | Si se puede (porque es hashable) |
  
Algunos de los usos prácticos reales son:  
* Devolución de múltiples valores en una función. 
* Protección de datos. 
* Diccionarios con claves compuestas. 
  
## Sintaxis 
  
Se definen utilizando paréntesis `()`

```python
tupla_ (10,"Python", 3.14, True)
> (10, "Python", 3.14, True)
```

### [Operaciones con tuplas](/python/Tuplas/operaciones.ipynb)