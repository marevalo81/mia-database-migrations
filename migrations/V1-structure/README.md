# V1-structure — MIA AVANZA CONTIGO

## Qué es esta familia de migraciones

`V1-structure` es la primera familia de migraciones Flyway del repositorio de base de datos de MIA. Todas las migraciones dentro de esta carpeta usan versión **`V1.x`** y son responsables, exclusivamente, de la **estructura física completa de PostgreSQL**: schemas, tablas, tipos de columna, `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE` y `CHECK` explícitamente definidos en el modelo de datos de MIA.

`V1.x` cubre la estructura física de **todos** los dominios del modelo — General/capacidades compartidas, Admin, App/Customer & Identity, Financial Core, Risk & Controls, Legal, Reporting y Customer Support — independientemente de a qué responsabilidad funcional pertenezca cada tabla. La agrupación por dominio funcional (`V2`–`V5`) es una preocupación distinta de _cuándo se crea la tabla_ (`V1`).

## Qué NO contiene V1

Por diseño, ninguna migración `V1.x` contiene:

- `INSERT`, `UPDATE`, `DELETE` ni datos semilla (seeds).
- Vistas, funciones, procedimientos ni triggers.
- Lógica de negocio o de acceso.
- Configuración funcional.

Estos artefactos pertenecen a las familias posteriores (`V2`–`V5`).

## V1-structure es una familia, no una migración congelada

`V1-structure` no es "la migración inicial" que se cierra después de esta entrega. Es la familia completa de migraciones estructurales del proyecto. **Cualquier cambio estructural futuro** — crear una tabla nueva, modificar una columna, agregar o quitar una FK, agregar un `CHECK` — debe seguir haciéndose mediante una **nueva migración `V1.x`**, sin importar a qué dominio funcional pertenezca la tabla.

Ejemplo: si en el futuro se necesita crear `lending.loan_restructurings`, esa creación física es `V1.xx__create_loan_restructurings.sql`, aunque la tabla pertenezca funcionalmente a Financial Core. La lógica que opera sobre esa tabla (procedimientos, vistas, reglas) sí pertenecerá al bloque `V4.x` (Financial Core).

## Responsabilidades por rango de versión

| Rango  | Responsabilidad                                |
| ------ | ---------------------------------------------- |
| `V1.x` | Estructura física de PostgreSQL (esta familia) |
| `V2.x` | Admin                                          |
| `V3.x` | App                                            |
| `V4.x` | Financial Core                                 |
| `V5.x` | Risk & Controls                                |

Flyway ejecuta las migraciones **en orden de número de versión**, no en orden de fecha de creación ni de incorporación al repositorio. Por eso `V1.x` siempre se ejecuta antes que `V2.x`, `V2.x` antes que `V3.x`, y así sucesivamente. Dentro de `V1.x`, el orden numérico (`V1.1`, `V1.2`, `V1.3`...) refleja las dependencias físicas reales del modelo — ver la tabla de orden de ejecución en el reporte de validación adjunto.

## Cómo ejecutar

Con Flyway apuntando a una base PostgreSQL vacía, coloca esta carpeta en el `locations` configurado (p. ej. `filesystem:migrations/V1-structure`) y ejecuta `flyway migrate`.
