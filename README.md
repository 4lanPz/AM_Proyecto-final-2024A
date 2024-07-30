# Login y ubicación en Flutter
APK: https://www.mediafire.com/file/m9jq5kft5p9ktti/ProyectoFinal.apk/file

Web: https://proyectofinalmoviles2024a.web.app/

## Funcionalidades
- Login con Firebase y con Gmail
- Registro con Firebase
- Barra de navegación
- Administración de usuarios (admin y user)
- Ubicación en tiempo real
- Ubicación en segundo plano
- Cálculo de área del polígono

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

## Deploy Web
Primero ejecutar los siguientes comandos para poder tener las herramientas necesarias
```bash
npm install -g firebase-tools
npx firebase login
npx firebase hosting init
```
Configurar nuestra pagina web en nuestra apliacion de Firebase para permitir generar un dominio personalizado.


Agregar las variables web para iniciar sesion en web y agregarlas en index.html, estas se pueden conseguir en la configuracion de Firebase


Ahora  primero haremos el build web para poder copiar el contenido a la carpeta public, ahora añadir el nombre personalizado de su app en el archivo firebase.json de hosting
```bash
flutter deploy web
```
Finalmente luego de copiar el contenido de build/web a public ejecutamos el siguiente comando

```bash
npx firebase deploy --only hosting:nombredesuproyecto
```

## Capturas

### WEB:
![image](https://github.com/user-attachments/assets/d233633e-ace8-4c46-ae7a-7091ee8c4c2d)


![image](https://github.com/user-attachments/assets/1ae3a6a3-62be-4eca-addd-06af1e88c7e6)

### MOVIL:
![image](https://github.com/user-attachments/assets/2b2d433f-0938-4ece-9590-e245938cf61d)

![image](https://github.com/user-attachments/assets/77761d16-b8cb-4f18-bec3-89de932815c7)






