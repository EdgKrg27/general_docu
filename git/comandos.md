# Comandos para uso de Git  
  
## Configuración inicial  
  
- `git config` configura opciones git como el usuario, email, editor, etc...  
~~~bash
git config --global user.name "<nombre"
git config --global user.email "<email>"
~~~  
  
## Repositorios 
  
- `git init` inicializaun nuevo repositorio Git en el directorio actual, crea el subdirectorio `.git` que contiene todos los archivos necesarios para el control de versiones  
- `git clone [url]` descarga un repositorio remoto a la maquina local  
  
## Flujo básico de trabajo  
  
- `git status` muestra el estado de los archivos (modificaciones, en staging, etc...)
- `git add [archivo (--all)]` añade arhivos al área de staging para el proximo commit
  - `git add .` añade todos los archivos modificados/nuevos
  - `git add -A` añade todfos los cambios incluidos los eliminados
- `git commit -m "[mensaje]"` guarda los cambios del staging en el respositorio local
  - `git commit --ammend` modifica el último commit (mensaje o archivos)
- `git restore [archivo]` descarta cambios en el directorio de trabajo (version >= 2.23)
  - `git restore --staged <archivo>` saca un archivo del staging
- `git reset [commit]` Desase commits o saca archivos del staging
  - `git reset --soft [commit]` mantiene los cambios en el directorio
  - `git reset --hard [commit]` elimina todos los cambios (¡¡¡PELIGROSO!!!)  
  

## Hisotorial y diferencias  
  
- `git log` muestra el historial de commits
  - `git log --oneline` version resumida
  - `git log --graph` muestra ramas y fusiones
- `git diff` compara cambios entre commits, ramas o el direcrtorio de trabajo
- `git diff --staged` cambios en el staging vs el último commit  
  
## Ramas  
  
- `git branch` lista todas las ramas locales
  - `git branch [nombre]` crea una nueva rama
  - `git branch -d [nombre]` elimina una rama (segura)
  - `git branch -D [nombre]` fuerza eliminación (incluido sin fusionar)
  - `git branch -r` lista las ramas disponibles en el respositorio remoto, usualmente con el prefijo del remoto
- `git checkout [rama]` cambia a otra rama
  - `git checkout -b [rama]` crea y cambia a una nueva rama
- `git switch [rama]` alternativa para creación de ramas, vesión más intuitiva para cambiar entre rama
- `git merge [rama]` fusiona una rama con la rama actual
- `git rebase [rama]` re-ubica los commits de la rama actual sobre otra rama (re-escribe historia)  
  
## Respositorios remotos  
  
- `git remote add [alias][url]` añade un repositorio remoto con una alias (ej. origin)
- `git remote -v` lista repositorios remotos configurados
- `git fetch [remoto]` descarga cambios del remoto sin fusionar
- `git pull [remoto][rama]` descarga cambios y los fusiona con tu rama local (equivale a fetch + merge)
- `git push [remoto][rama]` sube cambios locales al repositorio remoto
  - `git push -u origin main` configura rama local para rastrear remota 