# Créditos App

App Android (Flutter) para préstamos personales con base de datos SQLite local.

## Contenido del repositorio

| Archivo / carpeta | Para qué sirve |
|---|---|
| `lib/main.dart` | Pantallas de la app (Personas, Solicitudes, Base de datos) |
| `lib/db.dart` | Acceso a la base SQLite |
| `assets/creditos.db` | Base de datos vacía que se copia al abrir la app por primera vez |
| `sql/creditos_sqlite.sql` | Esquema completo en SQL |
| `pubspec.yaml` | Dependencias |
| `.github/workflows/build-apk.yml` | Compila el APK automáticamente en GitHub |
| `docs/01_publicar_github.md` | Paso a paso para subir el proyecto a GitHub |
| `docs/02_instalar_en_celular.md` | Paso a paso para instalar la app en tu celular |
| `docs/03_invitar_usuarios.md` | Cómo enviar el link a agentes y gerentes |
| `docs/04_usar_con_sqlite_browser.md` | Abrir la base con la app SQLite Browser |

## Importante

- Cada celular tiene su **propia** base de datos. Lo que captura un agente no lo ve un gerente.
  Para compartir datos entre usuarios hace falta un servidor (por ejemplo Supabase).
- No subas nunca a GitHub bases con datos reales de clientes (CURP, ingresos, etc.).
