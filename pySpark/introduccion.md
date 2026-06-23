# Introducción a PySpark

## ¿Qué es PySpark?

Es el API de Spark pero escrito y utilizado en Python, esta diseñado para el procesamiento y análisis de big data. Permite utilizar la computación distribuida de Spark con Python y así procesar de forma eficiente grandes conjuntos de datos en clústers.

Algunas características son:

- **Computación distribuida:** PySpark ejecuta cálculos en paralelo en un clúster, lo que permite un procesamiento rápido de datos.
- **Tolerancia de fallos:** Spark recupera los datos perdidos utilizando información de linaje en conjuntos de datos distribuidos resilentes (RDD)
- **Evaluación diferida:** Las transformaciones no se ejecutan hasta que se llama a una acción, lo que permite la optimización