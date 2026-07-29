# 🎵 Kuromi — Reproductor de Música

Kuromi es un reproductor de música personal para Android inspirado en Namida, con su propia personalidad y estilo únicos.

## ✨ Funciones

- 🎵 Reproductor completo con controles de reproducción
- 📋 Listas de reproducción personalizadas
- ❤️ Sistema de favoritos
- 📁 Explorador de carpetas de música
- 🎤 Soporte de letras (archivos `.lrc`)
- 🌙 Temporizador de sueño
- 🎨 **Color de acento personalizable** (8 presets + selector libre)
- 🖼️ **Fondo de pantalla desde tu galería**
- 🌓 Tema oscuro / claro
- 🔔 Control desde notificaciones y pantalla de bloqueo
- 🔀 Aleatorio y repetición

---

## 🚀 Cómo compilar el APK (sin necesitar PC)

### Método 1: GitHub Actions (recomendado, 100% gratis)

1. **Crea una cuenta en [GitHub](https://github.com)** si no tienes una
2. **Sube este código a un repositorio nuevo** en GitHub
   - Crea un repo nuevo en GitHub
   - Sube todos los archivos de esta carpeta `kuromi/`
3. **GitHub compila el APK automáticamente** — ve a la pestaña `Actions` de tu repo
4. Cuando termine (≈5-8 minutos), descarga el APK desde `Actions → tu build → Artifacts`
5. En los siguientes pushes, también se crea un **Release** con el APK descargable

### Método 2: Con PC (Android Studio)

1. Instala [Flutter](https://flutter.dev/docs/get-started/install)
2. Instala [Android Studio](https://developer.android.com/studio)
3. Abre la terminal en la carpeta `kuromi/`
4. Ejecuta:
   ```bash
   flutter pub get
   flutter build apk --release
   ```
5. El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📁 Estructura del proyecto

```
kuromi/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── models/                # Song, Playlist
│   ├── providers/             # Estado (audio, tema, biblioteca)
│   ├── screens/               # Pantallas de la app
│   └── widgets/               # Componentes reutilizables
├── android/                   # Configuración Android
├── assets/                    # Imágenes, íconos, fuentes
├── .github/workflows/         # GitHub Actions (compilación automática)
└── pubspec.yaml               # Dependencias Flutter
```

---

## 🎤 Letras de canciones

Para mostrar letras, coloca un archivo `.lrc` con el mismo nombre que tu canción en la misma carpeta:

```
/Music/
  cancion.mp3
  cancion.lrc    ← mismo nombre, extensión .lrc
```

---

## 🎨 Personalización

En **Ajustes** puedes:
- Cambiar el color de acento (8 colores predefinidos o selector libre)
- Poner una imagen de tu galería como fondo
- Alternar entre tema oscuro y claro

---

## 🛠️ Fuentes

Las fuentes Nunito deben descargarse y colocarse en `assets/fonts/`:
- `Nunito-Regular.ttf`
- `Nunito-Bold.ttf`
- `Nunito-SemiBold.ttf`

Descárgalas gratis en: https://fonts.google.com/specimen/Nunito

O elimina la sección `fonts:` del `pubspec.yaml` para usar la fuente del sistema.

---

*Kuromi — Hecho con ❤️ en Flutter*
