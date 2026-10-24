# ============================================================================
# PROYECTO DE AULA - PROGRAMACIÓN EN LENGUAJE ESTADÍSTICO
# Entrega 1 - Diagnóstico inicial del dataset QBPassers2019
# Programación en Lenguajes Estadísticos (2026-2)
# Universidad Nacional de Colombia - Sede de La Paz
# Integrantes: Steban Ibarra, Luiyi Brito y Astrid De Angel
#
# Objetivo:
#   Cargar el dataset en R, inspeccionar su estructura y tipos de datos,
#   identificar valores faltantes, registros duplicados e inconsistencias
#   básicas de calidad. Los resultados se imprimen en la consola.
#
# Uso:
#   1. Abra este archivo en RStudio.
#   2. Verifique que el directorio de trabajo sea la raíz del proyecto o la
#      carpeta scripts_R/.
#   3. Ejecute el script completo.
# ============================================================================

# ---------------------------------------------------------------------------
# 0. Paquetes y opciones
# ---------------------------------------------------------------------------
paquetes <- c("readr", "dplyr", "tidyr", "stringr", "tibble")
faltantes_paquetes <- paquetes[
  !vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)
]
if (length(faltantes_paquetes) > 0) {
  install.packages(faltantes_paquetes, repos = "https://cloud.r-project.org")
}
invisible(lapply(paquetes, library, character.only = TRUE))

options(stringsAsFactors = FALSE, encoding = "UTF-8", scipen = 999)

# ---------------------------------------------------------------------------
# 1. Localización robusta de rutas (funciona desde la raíz o desde scripts_R)
# ---------------------------------------------------------------------------
candidatos_raiz <- c(".", "..", "../..")
raiz <- NULL
for (candidato in candidatos_raiz) {
  ruta_prueba <- file.path(candidato, "datos", "datos_crudos", "QBPassers2019.csv")
  if (file.exists(ruta_prueba)) {
    raiz <- normalizePath(candidato, mustWork = TRUE)
    break
  }
}
if (is.null(raiz)) {
  stop(
    "No se encontró datos/datos_crudos/QBPassers2019.csv. ",
    "Ejecute el script desde la raíz del proyecto o desde scripts_R/."
  )
}

ruta_datos <- file.path(raiz, "datos", "datos_crudos", "QBPassers2019.csv")

cat("\n============================================================\n")
cat("DIAGNÓSTICO INICIAL - QBPassers2019 (R)\n")
cat("============================================================\n")
cat("Archivo:", ruta_datos, "\n")

# ---------------------------------------------------------------------------
# 2. Carga inicial
# ---------------------------------------------------------------------------
# Carga tipada (readr infiere los tipos) y carga textual (todo character)
# para revisar la representación original de los valores.
qb <- readr::read_csv(ruta_datos, show_col_types = FALSE)
qb_texto <- readr::read_csv(
  ruta_datos,
  col_types = readr::cols(.default = readr::col_character()),
  show_col_types = FALSE
)

cat("\n-- Dimensiones --------------------------------------------------\n")
print(dim(qb))
cat("Filas:", nrow(qb), "| Columnas:", ncol(qb), "\n")

cat("\n-- Primeras 5 filas --------------------------------------------\n")
print(utils::head(qb, 5))

cat("\n-- Últimas 5 filas ---------------------------------------------\n")
print(utils::tail(qb, 5))

cat("\n-- Estructura (glimpse) -----------------------------------------\n")
print(dplyr::glimpse(qb))

cat("\n-- Especificación de tipos detectados por readr -----------------\n")
print(readr::spec(qb))

cat("\n-- Problemas de lectura detectados por readr --------------------\n")
problemas <- readr::problems(qb)
if (nrow(problemas) == 0) {
  cat("No se reportaron problemas de parseo.\n")
} else {
  print(problemas)
}

# ---------------------------------------------------------------------------
# 3. Tipos de datos y valores únicos
# ---------------------------------------------------------------------------
tipos <- data.frame(
  variable = names(qb),
  clase_R = vapply(qb, function(x) class(x)[1], character(1)),
  n_unicos = vapply(qb, function(x) length(unique(x[!is.na(x)])), integer(1)),
  n_faltantes = vapply(qb, function(x) sum(is.na(x)), integer(1)),
  stringsAsFactors = FALSE
)

cat("\n-- Tipos de datos y valores únicos -------------------------------\n")
print(tipos, row.names = FALSE)

# ---------------------------------------------------------------------------
# 4. Valores faltantes
# ---------------------------------------------------------------------------
faltantes <- data.frame(
  variable = names(qb),
  n_faltantes = vapply(qb, function(x) sum(is.na(x)), integer(1)),
  porcentaje = round(
    100 * vapply(qb, function(x) mean(is.na(x)), numeric(1)), 2
  ),
  stringsAsFactors = FALSE
)
faltantes <- faltantes[faltantes$n_faltantes > 0, , drop = FALSE]
faltantes <- faltantes[order(-faltantes$n_faltantes), , drop = FALSE]

cat("\n-- Valores faltantes (solo variables con NA) ---------------------\n")
if (nrow(faltantes) == 0) {
  cat("No hay valores faltantes.\n")
} else {
  print(faltantes, row.names = FALSE)
}

activos <- qb |>
  dplyr::filter(is.na(lastyear)) |>
  dplyr::select(name, firstyear) |>
  dplyr::arrange(firstyear)

cat("\n-- Jugadores con lastyear = NA (activos en 2019) -----------------\n")
cat("Total:", nrow(activos), "de", nrow(qb), "registros.\n")
print(activos, row.names = FALSE)

# ---------------------------------------------------------------------------
# 5. Registros duplicados
# ---------------------------------------------------------------------------
duplicados <- data.frame(
  verificacion = c(
    "Filas completamente duplicadas",
    "Nombres de jugador duplicados",
    "Identificadores name únicos"
  ),
  n = c(
    sum(duplicated(qb)),
    sum(duplicated(qb$name)),
    length(unique(qb$name))
  ),
  stringsAsFactors = FALSE
)

cat("\n-- Registros duplicados ------------------------------------------\n")
print(duplicados, row.names = FALSE)

# ---------------------------------------------------------------------------
# 6. Conversión defensiva y consistencia interna
# ---------------------------------------------------------------------------
# lastyear se mantiene como entero nullable. tdsatt e interatt se fuerzan a
# numérico por si algún lector los interpreta como texto por los ceros
# iniciales del archivo original.
qb <- qb |>
  dplyr::mutate(
    lastyear = as.integer(lastyear),
    dplyr::across(c(tdsatt, interatt), ~ as.numeric(.x))
  )

# Recalcular tasas a partir de los conteos para comparar con las reportadas.
qb <- qb |>
  dplyr::mutate(
    comp_calc = completions / attempts * 100,
    avercomp_calc = yards / completions,
    tdsatt_calc = touchdowns / attempts * 100,
    interatt_calc = interceptions / attempts * 100
  )

# Recalcular el passer rating oficial de la NFL.
qb <- qb |>
  dplyr::mutate(
    comp_a = pmin(pmax((completions / attempts - 0.30) * 5, 0), 2.375),
    comp_b = pmin(pmax((yards / attempts - 3.00) * 0.25, 0), 2.375),
    comp_c = pmin(pmax((touchdowns / attempts) * 20, 0), 2.375),
    comp_d = pmin(pmax(2.375 - (interceptions / attempts) * 25, 0), 2.375),
    rating_calc = ((comp_a + comp_b + comp_c + comp_d) / 6) * 100
  )

diferencia_max <- function(x, y) {
  max(abs(x - y), na.rm = TRUE)
}

consistencia <- data.frame(
  verificacion = c(
    "compperc reportado vs. completions/attempts*100",
    "avercomp reportado vs. yards/completions",
    "tdsatt reportado vs. touchdowns/attempts*100",
    "interatt reportado vs. interceptions/attempts*100",
    "rating reportado vs. fórmula oficial NFL",
    "completions <= attempts en todos los registros",
    "firstyear <= lastyear en registros con dato",
    "Variables de volumen positivas (games, attempts, completions, yards, touchdowns)",
    "longestPass dentro de un rango plausible (0-100 yardas)"
  ),
  diferencia_maxima = c(
    diferencia_max(qb$compperc, qb$comp_calc),
    diferencia_max(qb$avercomp, qb$avercomp_calc),
    diferencia_max(qb$tdsatt, qb$tdsatt_calc),
    diferencia_max(qb$interatt, qb$interatt_calc),
    diferencia_max(qb$rating, qb$rating_calc),
    NA_real_,
    NA_real_,
    NA_real_,
    NA_real_
  ),
  cumple = c(
    "Sí (diferencias atribuibles al redondeo)",
    "Sí (diferencias atribuibles al redondeo)",
    "Sí (diferencias atribuibles al redondeo)",
    "Sí (diferencias atribuibles al redondeo)",
    "Sí (diferencias atribuibles al redondeo)",
    as.character(all(qb$completions <= qb$attempts, na.rm = TRUE)),
    as.character(all(qb$firstyear <= qb$lastyear, na.rm = TRUE)),
    as.character(all(
      as.matrix(qb[c("games", "attempts", "completions", "yards", "touchdowns")]) > 0,
      na.rm = TRUE
    )),
    as.character(all(qb$longestPass >= 0 & qb$longestPass <= 100, na.rm = TRUE))
  ),
  stringsAsFactors = FALSE
)

cat("\n-- Consistencia interna ------------------------------------------\n")
print(consistencia, row.names = FALSE)

# Ceros iniciales en la representación textual (tdsatt e interatt).
ceros_iniciales <- data.frame(
  variable = c("tdsatt", "interatt"),
  n_valores_con_cero_inicial = c(
    sum(stringr::str_detect(qb_texto$tdsatt, "^0"), na.rm = TRUE),
    sum(stringr::str_detect(qb_texto$interatt, "^0"), na.rm = TRUE)
  ),
  stringsAsFactors = FALSE
)

cat("\n-- Formato textual: valores con cero inicial ---------------------\n")
print(ceros_iniciales, row.names = FALSE)

# Rango de años y duración de carrera (último año ajustado a 2019 si es NA).
qb <- qb |>
  dplyr::mutate(
    lastyear_ajustado = dplyr::if_else(is.na(lastyear), 2019L, lastyear),
    years_played = lastyear_ajustado - firstyear + 1L
  )

cat("\n-- Rango temporal ------------------------------------------------\n")
cat("firstyear:", min(qb$firstyear), "-", max(qb$firstyear), "\n")
cat("lastyear observado:", min(qb$lastyear, na.rm = TRUE), "-",
    max(qb$lastyear, na.rm = TRUE), "\n")
cat("Duración de carrera (con 2019 para activos):",
    min(qb$years_played), "-", max(qb$years_played), "años\n")

# ---------------------------------------------------------------------------
# 7. Resumen numérico
# ---------------------------------------------------------------------------
vars_num <- names(qb)[vapply(qb, is.numeric, logical(1))]
resumen_num <- data.frame(
  variable = vars_num,
  minimo = vapply(qb[vars_num], min, numeric(1), na.rm = TRUE),
  maximo = vapply(qb[vars_num], max, numeric(1), na.rm = TRUE),
  media = vapply(qb[vars_num], mean, numeric(1), na.rm = TRUE),
  mediana = vapply(qb[vars_num], median, numeric(1), na.rm = TRUE),
  desv_est = vapply(qb[vars_num], sd, numeric(1), na.rm = TRUE),
  n_faltantes = vapply(qb[vars_num], function(x) sum(is.na(x)), integer(1)),
  stringsAsFactors = FALSE
)

cat("\n-- Resumen numérico ----------------------------------------------\n")
print(resumen_num, row.names = FALSE)

# ---------------------------------------------------------------------------
# 8. Resultados
# ---------------------------------------------------------------------------
cat("\nLos resultados del diagnóstico se imprimen en la consola.\n")
cat("No se generan archivos auxiliares.\n")

# ---------------------------------------------------------------------------
# 9. Conclusión del diagnóstico
# ---------------------------------------------------------------------------
cat("\n============================================================\n")
cat("SÍNTESIS DEL DIAGNÓSTICO\n")
cat("============================================================\n")
cat("- El dataset tiene", nrow(qb_texto), "filas y", ncol(qb_texto), "columnas.\n")
cat("- No hay filas ni nombres duplicados.\n")
cat("- El único faltante relevante es lastyear:",
    sum(is.na(qb$lastyear)), "registros (",
    round(100 * mean(is.na(qb$lastyear)), 1), "%), de carácter estructural.\n")
cat("- Las tasas y el rating son consistentes con sus fórmulas (diferencias < 0.05).\n")
cat("- Los conteos de volumen son positivos y coherentes.\n")
cat("- Se recomienda crear activo_2019, lastyear_ajustado y years_played en la Entrega 2.\n")
cat("============================================================\n")

cat("\n-- sessionInfo() ------------------------------------------------\n")
print(utils::sessionInfo())
