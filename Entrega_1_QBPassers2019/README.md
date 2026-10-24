# Proyecto de Aula Programación en Lenguaje Estadístico

**Entrega 1:** Formulación del problema y diagnóstico inicial del dataset  
**Asignatura:** Programación en Lenguajes Estadísticos (2026-2)  
**Docente:** Yoselin Nieto G.  
**Integrantes:** Steban Ibarra, Luiyi Brito y Astrid De Angel  
**Universidad Nacional de Colombia — Sede de La Paz**  
**Fecha de entrega:** miércoles 28 de octubre de 2026

---

## 1. Descripción

Este proyecto analiza el desempeño de carrera de 50 quarterbacks de la NFL a partir del conjunto de datos `QBPassers2019.csv`. La investigación distingue dos dimensiones del rendimiento:

- **Volumen acumulado:** partidos, intentos, pases completados y yardas.
- **Eficiencia por intento:** porcentaje de pases completos, touchdowns por cada 100 intentos e intercepciones por cada 100 intentos.

La pregunta central busca determinar en qué medida el *rating* de carrera se explica por la eficiencia frente al volumen, controlando por la duración de la carrera, y qué perfiles de jugadores emergen al combinar ambas dimensiones. El trabajo se desarrolla de forma paralela en **R** (RStudio) y **Python** (Google Colab).

Esta primera entrega se limita a la formulación del problema y al diagnóstico inicial: estructura del proyecto, pregunta y objetivos, carga del dataset, tipos de datos, valores faltantes y registros duplicados. La limpieza y las transformaciones se desarrollarán en la Entrega 2.

---

## 2. Estructura de la entrega

```text
Entrega_1_QBPassers2019/
├── README.md
├── datos/
│   ├── datos_crudos/
│   │   └── QBPassers2019.csv
│   └── datos_limpios/          # se completa en la Entrega 2
├── scripts_R/
│   └── 01_diagnostico_inicial.R
├── notebooks_Python/
│   └── 01_Diagnostico_Inicial_QBPassers2019.ipynb
└── documentos/
    ├── Entrega_1_Formulacion_Problema_y_Diagnostico.pdf
    ├── Entrega_1_Formulacion_Problema_y_Diagnostico.tex
    └── Diccionario_Datos_QBPassers2019.md
```

---

## 3. Dataset

- **Archivo original:** `datos/datos_crudos/QBPassers2019.csv`
- **Registros:** 50 quarterbacks.
- **Variables:** 15 (1 cualitativa nominal y 14 numéricas).
- **Unidad de análisis:** carrera profesional de cada jugador hasta la temporada 2019.
- **Diccionario:** `documentos/Diccionario_Datos_QBPassers2019.md`.

> **Nota importante:** `lastyear` presenta 23 valores faltantes. No son errores: corresponden a jugadores activos en 2019. Por ello, el faltante es **estructural** y no debe imputarse con la media ni eliminarse sin justificación.

---

## 4. Cómo reproducir

### 4.1 Python (Google Colab)

1. Abra `notebooks_Python/01_Diagnostico_Inicial_QBPassers2019.ipynb` en Google Colab.
2. Ejecute la primera celda. El cuaderno monta Google Drive si está disponible, busca el dataset en rutas conocidas y, si no lo encuentra, solicita subir `QBPassers2019.csv`.
3. Ejecute todas las celdas (`Entorno > Ejecutar todo`).

El cuaderno muestra en pantalla los tipos de datos, los faltantes y los duplicados; no genera archivos auxiliares ni modifica el dataset original.

### 4.2 R (RStudio)

1. Abra `scripts_R/01_diagnostico_inicial.R`.
2. Verifique que el directorio de trabajo sea la raíz del proyecto o la carpeta `scripts_R/`.
3. Ejecute el script completo. Las rutas son relativas y los resultados se imprimen en la consola.

Paquetes utilizados: `readr`, `dplyr` y `stringr`. Si faltan, el script intenta instalarlos con `install.packages()`.

---

## 5. Entregables de la Entrega 1

| Entregable | Ubicación | Estado |
|---|---|---|
| Estructura de carpetas estandarizada | raíz del proyecto | Cumplido |
| Pregunta de investigación y objetivos | informe PDF, secciones 2 y 3 | Cumplido |
| Diagnóstico inicial en R | `scripts_R/01_diagnostico_inicial.R` | Cumplido |
| Diagnóstico inicial en Python | `notebooks_Python/01_Diagnostico_Inicial_QBPassers2019.ipynb` | Cumplido |
| Informe de la entrega | `documentos/Entrega_1_Formulacion_Problema_y_Diagnostico.pdf` | Cumplido |
| Diccionario de datos | `documentos/Diccionario_Datos_QBPassers2019.md` | Cumplido |

---

## 6. Declaración de uso de inteligencia artificial

Para esta entrega se utilizó un asistente de IA como apoyo en la organización de la carpeta, la redacción preliminar del informe y la revisión de estilo del código. Todas las rutinas fueron ejecutadas, verificadas y ajustadas por los integrantes. Los resultados numéricos reportados provienen directamente del dataset y de la ejecución de los scripts y el cuaderno incluidos. La responsabilidad sobre el contenido, la interpretación y la sustentación es de los autores.
