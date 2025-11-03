# Pasos para configurar terminal con GitHub por medio de SSH

### Generar clave SSH

Abrir terminal y ejecutar el siguiente comando: `ssh-keygen -t ed25519 -C "tu_correo_de_github@example.com"`  

1. Ubicación del archivo: La terminal preguntará dónde guardar la clave.
2. Frase de contraseña: Se te pedirá ingresar una frase de contraseña. Es altamente recomendable establecer una, ya que añade una capa extra de seguridad.
3. Resultado: Se generará dos archivos:  
    - `id_ed25519` clave privada
    - `id_ed25519.pub` clave pública


### Agregar la clave al agente SSH  
  
El agente SSH es un programa que corre en segudno plano y almacena tus calves privadas, permitiéndote usarlas sin tener que escribir la frase de contraseña.  
  
1. Iniciar agente SSH: `eval "$(ssh-agent -s)"`
2. Añadir la clave privada: `ssh-add ~/.ssh/id_ed25519` NOTA. si se establecio una frase de contraseña, la pedirá en este paso

### Añadir la clave pública en GitHub  
  
Solamente falta añadir la clave pública generada en las opcines de GitHub y hacer la prueba de conectividad con: `ssh -T git@github.com`