# 4. Usar la base con la app SQLite Browser

App: https://play.google.com/store/apps/details?id=com.dya.sqlitebrowser

La base de Créditos App es privada, así que se trabaja con copias.

## Ver o editar la base en SQLite Browser

1. En Créditos App: pestaña **Base de datos → Guardar copia en el teléfono**.
   Elige Descargas y guarda `creditos.db`.
   (También puedes usar **Exportar / compartir** y elegir SQLite Browser si aparece en la lista.)
2. Abre **SQLite Browser** y busca la opción para abrir o importar una base de datos.
   Selecciona `creditos.db` desde Descargas.
3. Consulta tablas, ejecuta SQL o edita registros.

## Volver a cargar los cambios en Créditos App

1. Guarda los cambios en SQLite Browser (o exporta el archivo editado).
2. En Créditos App: **Base de datos → Importar creditos.db** y elige el archivo.
3. Confirma. Importar reemplaza TODOS los datos actuales.

## Recomendaciones

- Antes de importar, guarda una copia de seguridad de la base actual.
- Activa `PRAGMA foreign_keys = ON;` al ejecutar SQL manual.
- No subas a GitHub ni compartas bases con datos reales de clientes.
