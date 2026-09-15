# Scripts de configuración de base de datos

Esta carpeta contiene los scripts administrativos necesarios para preparar
el entorno PostgreSQL de MIA antes de ejecutar las migraciones de Flyway.

Estos scripts **no son migraciones de Flyway** y no forman parte del historial
de versiones administrado por Flyway.

## Estructura

Los scripts están numerados de acuerdo con su orden lógico de ejecución:

1. `01-create-sandbox-database.sql`
2. `02-flyway-setup.sql`
3. `03-create-flyway-permissions.sql`

---

## 01-create-sandbox-database.sql

Crea la base de datos:

`mia_sandbox`

Esta base se utiliza como laboratorio para realizar pruebas manuales de:

- DDL.
- Relaciones entre tablas.
- Constraints.
- Permisos.
- Comportamiento de PostgreSQL.
- Cambios de estructura antes de llevarlos a las migraciones de Flyway.

La base `mia_sandbox` **no es administrada por Flyway**.

Su propietario es:

`mia_dba`

Este script solamente debe ejecutarse cuando sea necesario crear el sandbox.

---

## 02-flyway-setup.sql

Crea y configura el rol técnico utilizado exclusivamente por Flyway:

`flyway_mia`

### Autenticación

Flyway utiliza autenticación mediante **Amazon RDS IAM Database Authentication**.

Por esta razón, `flyway_mia` no utiliza una contraseña PostgreSQL estática.

El rol recibe la membresía:

`rds_iam`

para permitir la autenticación mediante IAM.

La identidad de AWS utilizada por el entorno que ejecuta Flyway debe tener
también el permiso correspondiente `rds-db:connect` para conectarse a
`flyway_mia`.

Las credenciales y tokens utilizados para la autenticación IAM no deben
almacenarse en el repositorio.

### Atributos del rol

`flyway_mia` se configura con:

- `LOGIN`: permite que Flyway se conecte a PostgreSQL.
- `CREATEROLE`: permite que las migraciones creen los roles PostgreSQL
  requeridos por las APIs de MIA.
- `NOSUPERUSER`: Flyway no es un superusuario.
- `NOCREATEDB`: Flyway no puede crear bases de datos.
- `NOBYPASSRLS`: Flyway no puede omitir las políticas de Row-Level Security.
- `NOREPLICATION`: Flyway no tiene privilegios especiales de replicación.

`flyway_mia` es una identidad técnica y no debe utilizarse para:

- Acceso interactivo de usuarios.
- Conexiones de las APIs en tiempo de ejecución.
- Acceso general de desarrolladores.

---

## 03-create-flyway-permissions.sql

Configura los permisos que `flyway_mia` necesita sobre la base:

`mia`

Actualmente se otorgan:

### CONNECT

Permite que `flyway_mia` se conecte a la base `mia`.

### CREATE

Permite que `flyway_mia` cree schemas dentro de la base `mia`.

Los schemas de MIA son creados y administrados mediante las migraciones
de Flyway.

### Schema `public`

MIA no utiliza el schema `public` para objetos de negocio.

El schema `public` se reserva para objetos técnicos de infraestructura
requeridos por herramientas de administración de la base de datos.

Flyway utilizará este schema exclusivamente para almacenar su tabla de
historial:

`flyway_schema_history`

No se deben crear tablas, vistas, funciones u otros objetos funcionales
de los dominios de MIA directamente en `public`.

Los objetos de negocio deben crearse dentro de los schemas definidos por
la arquitectura de MIA.

---

## Ownership

El usuario administrativo existente de la base es:

`mia_dba`

`flyway_mia` ejecuta las migraciones utilizando su propia identidad.

No se utiliza:

```sql
SET ROLE mia_dba;
```

Por lo tanto, los objetos creados directamente por las migraciones de Flyway
quedan bajo el contexto de ownership de `flyway_mia`.

`mia_dba` continúa siendo el usuario administrativo de la base de datos.

No se realizan transferencias automáticas de ownership a `mia_dba`.

---

## Roles de las APIs

Los roles PostgreSQL utilizados por las APIs forman parte de la configuración
versionada de la aplicación.

Las migraciones de Flyway son responsables de:

- Crear los roles de las APIs.
- Configurar sus privilegios.
- Modificar sus privilegios cuando sea necesario mediante nuevas migraciones.

Ejemplo conceptual:

```sql
CREATE ROLE api_example NOLOGIN;

GRANT USAGE ON SCHEMA example TO api_example;

GRANT SELECT, INSERT, UPDATE
ON example.example_table
TO api_example;
```

Cada API debe recibir únicamente los privilegios que necesita para realizar
sus operaciones.

Se aplica el principio de **mínimo privilegio**.

---

## Datos iniciales y Seeds

No todos los datos iniciales tienen el mismo propósito.

### Datos obligatorios

Los datos que deben existir en toda instalación de MIA forman parte de las
migraciones de Flyway.

Por ejemplo:

- Países.
- Monedas.
- Productos.
- Otros valores obligatorios de `reference_data`.

Estos datos deben existir también en producción.

### Datos de prueba

Los datos utilizados únicamente para desarrollo o pruebas no forman parte
obligatoria de las migraciones.

Por ejemplo:

- Customer de prueba.
- Loan de prueba.
- Payment de prueba.

Estos scripts se encuentran en:

`scripts/seed/`

y pueden ejecutarse únicamente en los ambientes donde sean necesarios.

---

## Orden de preparación

Para preparar un entorno desde cero:

### 1. Crear el sandbox

Ejecutar:

`01-create-sandbox-database.sql`

Este paso solamente es necesario si se requiere el laboratorio manual.

### 2. Configurar el rol de Flyway

Ejecutar:

`02-flyway-setup.sql`

Debe ejecutarse utilizando el usuario administrativo correspondiente,
por ejemplo `mia_dba`.

### 3. Configurar los permisos de Flyway

Ejecutar:

`03-create-flyway-permissions.sql`

Debe ejecutarse conectado a la base:

`mia`

utilizando `mia_dba` o un rol administrativo autorizado.

### 4. Ejecutar Flyway

Una vez configurado el rol y sus permisos, Flyway se conecta a:

`mia`

utilizando:

`flyway_mia`

y autenticación mediante Amazon RDS IAM.

---

## Principios de seguridad

La configuración de Flyway sigue el principio de **mínimo privilegio**.

`flyway_mia`:

- No es `SUPERUSER`.
- No puede crear bases de datos.
- No puede omitir Row-Level Security.
- No tiene privilegios de replicación.
- Utiliza el schema `public` para la creación de sus tablas propias.
- Utiliza autenticación IAM.
- Tiene `CREATEROLE` porque las migraciones deben crear los roles
  PostgreSQL de las APIs.
- No se utiliza como usuario de runtime de las APIs.
- No debe utilizarse para acceso interactivo humano.

El acceso IAM que permite autenticarse como `flyway_mia` debe estar restringido
al entorno autorizado para ejecutar Flyway.

---

## Relación con Flyway

La carpeta `setup/` prepara las condiciones necesarias para que Flyway pueda
operar.

Las migraciones propiamente dichas se encuentran en:

```text
migrations/
```

y son las únicas responsables de versionar la evolución del esquema y los
datos obligatorios de la base de datos.

Los scripts de esta carpeta no deben utilizarse como sustituto de una
migración una vez que Flyway esté administrando la base `mia`.
