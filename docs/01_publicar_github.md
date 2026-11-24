# 1. Publicar el proyecto en GitHub (paso a paso)

No necesitas instalar Flutter: GitHub compilará el APK por ti.

## Parte A: crear el repositorio

1. Entra a https://github.com y crea una cuenta (o inicia sesión).
2. Toca **+ → New repository**.
3. Nombre: `creditos-app`.
4. Visibilidad:
   - **Public**: cualquiera con el link puede descargar el APK (lo más fácil para invitar).
   - **Private**: solo tú; el APK se manda por WhatsApp/Drive (ver `03_invitar_usuarios.md`).
5. Toca **Create repository**.

## Parte B: subir los archivos

### Opción 1: desde una computadora (la más fácil)
1. Descomprime el zip del proyecto.
2. En el repositorio: **Add file → Upload files**.
3. Arrastra TODO el contenido de la carpeta (`lib`, `assets`, `sql`, `docs`, `pubspec.yaml`, `README.md`, `.gitignore`).
4. Toca **Commit changes**.
5. La carpeta `.github` suele quedar oculta al arrastrar. Créala a mano:
   **Add file → Create new file**, en el nombre escribe exactamente
   `.github/workflows/build-apk.yml`, pega el contenido del archivo del zip y haz **Commit**.

### Opción 2: desde el celular con Termux
1. Instala **Termux** desde F-Droid.
2. Ejecuta:
   ```
   pkg update && pkg install git
   termux-setup-storage
   ```
3. Descomprime el zip en Descargas y entra a la carpeta:
   ```
   cd ~/storage/downloads/creditos_app
   ```
4. Sube los archivos:
   ```
   git init
   git add .
   git commit -m "Primera version"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/creditos-app.git
   git push -u origin main
   ```
5. Cuando pida contraseña, usa un **token**: GitHub → Settings → Developer settings →
   Personal access tokens → Generate new token (permiso `repo` y `workflow`).

## Parte C: compilar el APK

1. En el repositorio abre la pestaña **Actions** (si aparece un aviso, acepta habilitar workflows).
2. Elige **Compilar APK → Run workflow**.
3. Espera unos 5-10 minutos. Si sale ✅, abre la ejecución y descarga el archivo `creditos-apk`.
4. Si sale ❌, abre el paso que falló y envíame el mensaje de error.

## Parte D: publicar una versión (el link para tus usuarios)

1. En el repositorio: **Releases → Create a new release**.
2. En *Choose a tag* escribe `v1.0.0` y crea la etiqueta.
3. Título: `Versión 1.0.0`. Toca **Publish release**.
4. Se ejecuta el workflow solo y en unos minutos aparece `creditos.apk` dentro de la Release.

Para cada versión nueva repite la Parte D con otra etiqueta (`v1.0.1`, `v1.1.0`...).
