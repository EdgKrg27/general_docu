# Comandos conda

## Gestion de entornos  
  
- `conda create`: crea un nuevo entorno
> conda create --name <entorno> (python=3.xx)  
  
- `conda activate`: activa un entorno 
> conda activate <entorno>  
  
- `conda deactivate`: Desactiva el entorno actual 
> conda deactivate  
 
- `conda env list`: Muestra todos los entornos disponibles 
> conda env list 
  
- `conda info --envs`: Alias para conda env list 
> conda env list 
  
- `conda create --clone`: Crea una copia exacta de un entorno 
> conda create --name <copia_entorno> --clone <entorno>  
  
- `conda env remove`: Elimina un entorno por completo 
> conda env remove --name <entorno>  
  
- `conda env export`: Exporta la configuración de un entorno a un archivo YAML 
> conda env export > <entorno.yml> 
  
- `conda env create`: Crea un entorno a partir de un archiv YAML 
> conda env create -f <entorno.yml>  
 
- `conda env update`: Actualiza un entorno existente a partir de un archiv YAML  
> conda env update --name <entorno> --file <entorno.yml>  
  
## Gestion de paquetes  
  
- `conda install`: Instala uno o más paquetes en el entoorno activo  
> conda install <paquete>  
  
- `conda uninstall`: Desinstala uno o más paquetes del entorno activo 
> conda uninstall <paquete>  
  
- `conda remove`: Alias para conda unistall 
> conda remove <paquete>  
  
- `conda update`: Actualiza un paquete a su última versión compatible  
> conda update <paquete>  
  
- `conda update --all`: Actrualiza todos los paquetes en el entorno activo 
> conda update --all  
  
- `conda list`: Muestra todos los paquetes instalados en el entorno activo 
> conda list  
  
- `conda search`: Busca paquetes disponibles en los canales configurados 
> conda search "<paquete>"  
  
## gestion conda  
  
- `conda info`: Muestra información sobre la instalación actual de conda  
> conda info  
  
- `conda update conda`: Actualiza la herramienta conda a la última versión 
> conda update conda  
  
- `conda config`: Gestiona la configuración de conda (canales, etc...)  
> conda config --add channels conda-forge  
  
- `conda init`: Inicializa conda en tu shell (agrega la configuración al PATH)  
> conda init bash  
  
- `conda doctor`: Revisa la instalación de conda en busca de problemas  
> conda doctor  
  
- `conda run`: Ejecuta un comando dentro de un entorno específico sin activarlo  
> conda run -n <entorno> python <app.py>  
  
## Comandos de ayuda y misceláneos  
  
- `conda --version`: Muestra la versión de conda instalada  
> conda --version  
  
- `conda --help`: Muestra ayuda general de conda  
> conda --help 
  
- `[comando] --help`: Muestra la ayuda específic para un comando 
> conda install  
  
  