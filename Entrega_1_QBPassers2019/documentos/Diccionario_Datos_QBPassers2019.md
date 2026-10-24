# Diccionario de datos — QBPassers2019

**Archivo:** `datos/datos_crudos/QBPassers2019.csv`  
**Unidad de análisis:** carrera profesional de un quarterback de la NFL hasta 2019.  
**Registros:** 50.  
**Variables:** 15.  
**Codificación:** UTF-8.  
**Separador:** coma.  
**Valores faltantes:** campo vacío (`""`), leído como `NA` en R y `NaN` en Python.

## Convenciones de tipo

- **Cualitativa nominal:** etiqueta sin orden.
- **Cuantitativa discreta:** conteo entero.
- **Cuantitativa continua:** valor numérico con decimales.
- **Año:** entero de cuatro dígitos.
- **Tasa:** valor porcentual expresado sobre 100 unidades.

## Variables

| # | Variable | Tipo estadístico | Tipo de dato | Unidad | Descripción | Rango observado | Faltantes |
|---:|---|---|---|---|---|---|---:|
| 1 | `name` | Cualitativa nominal | Texto | — | Nombre del quarterback. Identificador natural del registro. | 50 valores únicos | 0 |
| 2 | `firstyear` | Cuantitativa discreta | Entero | Año | Primer año del jugador en la NFL. | 1969–2016 | 0 |
| 3 | `lastyear` | Cuantitativa discreta | Entero (nullable) | Año | Último año del jugador en la NFL. `NA` indica que el jugador seguía activo en 2019. | 1979–2019 | 23 |
| 4 | `games` | Cuantitativa discreta | Entero | Partidos | Total de partidos jugados en su carrera. | 54–302 | 0 |
| 5 | `attempts` | Cuantitativa discreta | Entero | Intentos | Total de intentos de pase en su carrera. | 1.692–10.169 | 0 |
| 6 | `completions` | Cuantitativa discreta | Entero | Pases | Total de pases completados en su carrera. | 1.011–6.867 | 0 |
| 7 | `compperc` | Cuantitativa continua | Decimal | % | Porcentaje de pases completados: `completions / attempts × 100`. | 57,0–67,6 | 0 |
| 8 | `avercomp` | Cuantitativa continua | Decimal | Yardas | Promedio de yardas por pase completado: `yards / completions`. | 10,5–13,5 | 0 |
| 9 | `yards` | Cuantitativa discreta | Entero | Yardas | Total de yardas lanzadas por pase en su carrera. | 11.901–77.416 | 0 |
| 10 | `interceptions` | Cuantitativa discreta | Entero | Pases | Total de pases interceptados en su carrera. | 30–336 | 0 |
| 11 | `interatt` | Cuantitativa continua | Decimal | Por 100 intentos | Intercepciones por cada 100 intentos: `interceptions / attempts × 100`. | 1,39–3,68 | 0 |
| 12 | `touchdowns` | Cuantitativa discreta | Entero | Pases | Total de touchdowns lanzados en su carrera. | 71–547 | 0 |
| 13 | `tdsatt` | Cuantitativa continua | Decimal | Por 100 intentos | Touchdowns por cada 100 intentos: `touchdowns / attempts × 100`. | 3,47–6,01 | 0 |
| 14 | `longestPass` | Cuantitativa discreta | Entero | Yardas | Pase más largo completado en un partido de temporada regular durante su carrera. | 69–99 | 0 |
| 15 | `rating` | Cuantitativa continua | Decimal | Índice | Índice de pasador (passer rating) de la NFL, métrica compuesta de eficiencia. | 82,7–102,4 | 0 |

## Fórmulas de referencia

Las tasas reportadas pueden verificarse a partir de los conteos:

```text
compperc = completions / attempts × 100
avercomp = yards / completions
interatt = interceptions / attempts × 100
tdsatt   = touchdowns / attempts × 100
```

El `rating` sigue la fórmula oficial de la NFL. Para cada componente se define:

```text
A = ((completions / attempts) - 0.30) × 5
B = ((yards / attempts) - 3.00) × 0.25
C = (touchdowns / attempts) × 20
D = 2.375 - (interceptions / attempts) × 25

rating = ((min(max(A, 0), 2.375) + min(max(B, 0), 2.375)
          + min(max(C, 0), 2.375) + min(max(D, 0), 2.375)) / 6) × 100
```

## Variables derivadas previstas para la Entrega 2

| Variable | Tipo | Definición | Propósito |
|---|---|---|---|
| `activo_2019` | Cualitativa nominal (booleana) | `TRUE` si `lastyear` es `NA`, `FALSE` en caso contrario. | Recuperar información del faltante estructural. |
| `lastyear_ajustado` | Cuantitativa discreta | `lastyear` si existe; 2019 si el jugador estaba activo. | Calcular duración de carrera sin perder registros. |
| `years_played` | Cuantitativa discreta | `lastyear_ajustado - firstyear + 1`. | Medir longevidad. |
| `tier_carrera` | Cualitativa ordinal | Corta (< 8 años), media (8–14), larga (> 14). | Agrupaciones y comparaciones. |
| `perfil_desempeno` | Cualitativa nominal | Cuadrante volumen/eficiencia según medianas. | Análisis de perfiles. |

## Advertencias de calidad

1. **Faltante estructural:** los 23 `NA` de `lastyear` no son errores de captura; representan jugadores activos en 2019. No deben imputarse con la media.
2. **Formato textual:** algunos valores de `tdsatt` e `interatt` aparecen con cero inicial (por ejemplo, `06.01` y `02.06`). Los lectores numéricos los convierten correctamente, pero se recomienda normalizar la representación en la fase de limpieza.
3. **Muestra no probabilística:** los 50 jugadores son casos destacados, no una muestra aleatoria de toda la NFL. Las conclusiones se refieren a este conjunto y no deben generalizarse sin cautela.
4. **Datos acumulados:** las variables de volumen dependen de la duración de la carrera. Para comparar jugadores deben usarse tasas por intento o por partido, o controlar por `years_played`.
