# Usuarios y permisos

La gestion de permisos y usuarios deben aplicar el principio de menor privilegio asegurando que los desarrolladores, etc ... tengan acceso estrictamente a lo que necesitan para cumplir las funciones, reduciendo al máximo el riesgo de errores.

1. **Creación de usuarios**

```sql
CREATE USER 'nombre_usuario'@'origen_conexion' IDENTIFIED BY 'contraseña';
```

Tipos de origen de conexión:

- `localhost`: El usuario solo puede conectarse si está ejecutando comandos desde la misma máquina donde está instalada la base de datos (ideal para aplicaciones backend en el mismo servidor)
- `%`: El usuario puede conectarse desde cualquier dirección IP
- `192.168.1.50`: El usuario solo puede conectarse desde esa dirección IP especifica dentro de una red privada

2. **Otorgar permisos**

Cuando se crea el usuario se crea vacío, sin permisos. Se utiliza el comando `GRANT` para asignarle permisos especificos.

- Métricas de Lectura: `SELECT` (DQL)
- Métricas de Escritura: `INSERT`, `UPDATE`, `DELETE` (DML)
- Métricas de Estructura: `CREATE`, `ALTER`, `DROP` (DDL)
- Control total: `ALL PRIVILEGES`

3. **Quitar permisos (REVOKE)**

```sql
REVOKE SELECT ON data_base_name.* FROM 'nombre_usuario'@'origen_conexion';
```

4. **Guardar cambios en memporia (FLUSH PRIVILEGES)**

Cuando se hacen cambios directos en permisos o usuarios, estos se guardan en tablas internas de configuración, para obligar al servidor a leer los nuevos cambios de forma inmediata e ignorar al caché antiguo, se ejecuta este comando al terminar:

```sql
FLUSH PRIVILEGES;
```

5. **AUDITORIA**

- Ver que permisos existen.

```sql
SHOW GRANTS FOR 'nombre_usuario'@'origen_conexion'
```

- Eliminar un usuario

```sql
DROP USER 'nombre_usuario'@'origen_conexion'
```
