# Login y ubicación en Flutter
APK:


## Herramientas

- Visual Studio Code
- Flutter
- Android Studio
- Node
- Firebase

## Descargar paquetes flutter

Ejecutar el siguiente comando para poder descargar todo lo necesario del proyecto

```bash
flutter pub get  
```

## Variables
### Ejecutar el siguiente comando para poder generar sus variables de Firebase como google-service.json

```bash
flutter pub global activate flutterfire_cli
flutterfire configure    
```

Editar la configuración del proyecto en Firebase para agregar las huellas digitales con el siguiente comando en cmd (generar 2 una para debug y la otra para release)
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android    
```
### Agregar Api Key de Google Maps
Gnerar su Api key de Google Maps directamente de la página de Google Developer y permitir todas las funciones de Maps para Android y Web
Agregar la Api key en el archivo con el nombre: GOOGLE_MAPS_API_KEY
- .env
- local.propierties

## Icono de notificacion
Generar un ícono simple para las notificaciones en segundo plano en cualquier página a su elección, y agregar el archivo "ic_launcher.xml" en la carpeta y en el resto de carpetas pegar el archivo "ic_launcher.png"

```bash
nombreproyecto/
├── android/
│   ├─── app/   <----------
│   │   ├── src/  <---------- 
│   │   │   ├─── main/ <---------- 
│   │   │   │   ├─── res/  <---------- 
│   │   │   │   │   ├─── drawable/  <---------- aqui pegar el archivo xml
│   │   │   │   │   ├─── resto de carpetas/  <---------- aqui pegar el archivo png
```

## Generar APK
Ejecutar el siguiente comando y buscar la APK generada en build/app/flutter-apk/
```bash
flutter build apk --release
```

## Capturas

### WEB:


### MOVIL:





