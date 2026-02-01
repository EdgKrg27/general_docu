# Diccionarios

Los diccionarios son una estructura de datos que almacenan información en pares de `clave-valor`. A diferencia de las listas o tuplas, donde accedes a los elementos por su posición o índice, en un diccionario accedes a la información mediante una palabra clave única.  
  
## Sintaxis
Para obtener el valor asociado con una clave, daremos el nombre del diccionario y colocaremos la clave entre corchetes.  
Se definen usando llaves `{}` y el separador  `:` entre clave y valor.  
  
```python
usuario = {
    "nombre" : "Alex",
    "edad" : 25,
    "es_pro" : True,
    "habilidades" : ["Python", "SQL"]
}

print(usuario["nombre"])
> Alex
```
  
## Características fundamentales
* No puede tener dos claves iguales: Si intentas asignar un valor a una clave que ya existe, el valor antiguo se sobrescribe.
* Puedes agregar, eliminar o modificar elementos después de crear el diccionario.
* Las claves deben ser de un tipo de datos que no cambie (strings, números o tuplas). Los valores pueden ser cualquier cosa (lista, otros diccionarios, etc...).
* Están optimizados para encontrar datos instantáneamente, sin importar si el diccionariotiene 10 o 1 millón de elementos gracias al hashing.

## Métodos utiles
|Método |Descripción |
|----------|----------|
| .keys() | Devuelve una lista de todas las claves  |
| .values()  | Devuelve una lista de todos los valores |
| .items()  | Devuelve pares (tuplas) de calve-valor  |
| .pop("clave")  | Elimina la clave y devuelve su valor  |
| .update(otro_dict)  | Fusiona dos diccionarios  | 
  
## Cuando se debe usar un Diccionario
Un diccionario sde debe utilizar cuando los datos tienen una relación de pertenencia o descripción
* Mal uso: Utilizar un diccionario como lista
* Buen uso como diccionario. 
  
### [Operaciones con diccionarios](/python/Diccionarios/operaciones.ipynb)