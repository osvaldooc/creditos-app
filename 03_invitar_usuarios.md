# 3. Enviar el link de invitación a clientes, agentes y gerentes

## Repositorio público

Copia este link (cambia `USUARIO` y `creditos-app` por los tuyos) y mándalo por WhatsApp:

- Página con la última versión:
  `https://github.com/USUARIO/creditos-app/releases/latest`
- Descarga directa del APK:
  `https://github.com/USUARIO/creditos-app/releases/latest/download/creditos.apk`

Ejemplo de mensaje:

> Hola, instala la app de préstamos desde este link: https://github.com/USUARIO/creditos-app/releases/latest/download/creditos.apk
> Al abrirlo, permite "instalar apps de esta fuente" y toca "Instalar de todos modos".

## Repositorio privado

Los links de GitHub piden iniciar sesión, así que mejor envía el archivo:

1. Descarga `creditos.apk` de la Release.
2. Mándalo por WhatsApp, correo o Google Drive (link compartido).

## Instrucciones para quien lo recibe

1. Abrir el link o el archivo en el celular Android.
2. Permitir la instalación desde esa fuente.
3. Si aparece Play Protect, tocar **Instalar de todos modos**.

## Límites que debes saber

- **No hay inicio de sesión ni roles todavía.** Cualquiera que instale el APK ve todas las pantallas.
  El esquema ya tiene usuarios y roles; falta programar el login.
- **Cada celular tiene su propia base.** Los pagos que capture un agente no aparecen en el celular
  del gerente. Para compartir información entre todos hay que conectar la app a un servidor
  (por ejemplo Supabase con PostgreSQL). Es el siguiente paso recomendado.
- No es una app de Play Store, por eso aparece el aviso de seguridad al instalar.
- Solo Android. iPhone requiere otro proceso.
