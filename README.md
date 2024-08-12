# Proyecto final Aplicaciones Móviles utilizando Flutter
Web: https://proyectofinalmoviles2024a.web.app/
Video: https://vm.tiktok.com/ZMrgsFGmJ/

# Integrantes
- Christian Pañora
- Alan Perez
- Ingrith Revelo


## Funcionalidades
- Login con Firebase y con Gmail
- Registro con Firebase
- Barra de navegación
- Administración de usuarios (admin y user)
- Ubicación en tiempo real
- Ubicación en segundo plano
- Cálculo de área del polígono

# Estructura 
### Main
- Inicialización de Firebase
- Carga del archivo env
### Login
- Pedir permisos de Ubicación
- Iniciar sesión
- Llamada a inicio de sesión con Gmail
### Login con Gmail
- Llamada a Firebase con Gmail
### Registro
- Llamada a Firebase para registrar un unevo usuario
### Navegación
- Barra de navegación con las diferentes opciones de la App
### Gestión
- Iniciación de servicio en segundo plano
- Gestion de usuarios registrados 
- Datos de usuario: su correo y su ultima ubicación
### Ubicación
- Permisos de ubicación
- Muestra Google Maps
- Ubicación en tiempo real
- Guardar ubicación actual
### Area
- Muestra Google Maps
- Muestra los diferentes marcadores con informacion del usuario al que pertenece
- Muestra el calculo del Area total dependiendo del número de marcadores/usuarios
  
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

# Generación de la firma en Flutter
## Generar un ícono
Añadir la dependencia 
```bash
flutter pub add flutter_launcher_icons
```
y añadir el sistema al cual le quieras añadir el ícono, el ícono se debe encontrar en una carpeta assets, esto se realiza en el archivo yalm
```bash
dev_dependencies:
  flutter_launcher_icons: "^0.13.1"

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/icon.png"
  min_sdk_android: 21 # android min sdk min:16, default 21
  web:
    generate: true
    image_path: "path/to/image.png"
    background_color: "#hexcode"
    theme_color: "#hexcode"
  windows:
    generate: true
    image_path: "path/to/image.png"
    icon_size: 48 # min:48, max:256, default: 48
  macos:
    generate: true
    image_path: "path/to/image.png"
```

Luego ejecutar el siguiente comando para generar los íconos en sus diferentes formatos para las diferentes plataformas que se hayan elegido
```bash
flutter pub run flutter_launcher_icons
```
## Gneración de llave 
Ejecutar el siguiente comando para poder generar la llave que se utiliza para firmar la app

```bash
macOS / Linux
keytool -genkey -v -keystore path/a/tu/carpeta -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload

Windows
keytool -genkey -v -keystore path/a/tu/carpeta `
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
        -alias upload
```

## Configuración en app
Primero agrefar la dependiencia en app/build.graddle
```bash
implementation("com.google.android.material:material:<version>")
```
Ahora creamos el archivo key.properties en la raiz de app, en esta vamos a ingresar los datos que nos pide para la generación de la llave
```bash
key.properties

storePassword=<password-from-previous-step>
keyPassword=<password-from-previous-step>
keyAlias=upload
storeFile=<keystore-file-location>
```
### Recordar que el path en storeFile no debe ser directamente en tu pc local si no en la carpeta dentro del proyecto para que al utilizar en otro dispositivo no de error al momento de encontrar la key

Ahora en app/build.graddle agregamos esto para configurar la llave y la firma en la versión release y que tome los datos del archivo key.properties

```bash
Configure signing in gradle
#
Antes del apartado android

   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

android {
        ..
}
-----------------------------------------
Dentro del apartado android
    android {
        ...

       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
        buildTypes {
           release {

                signingConfig signingConfigs.debug
                signingConfig signingConfigs.release
           }
        }
    ...
    }
```
# Generar APK firmada
Ejecutar el comando 
```bash
flutter build apk --release
o
flutter run --release
```

# APKPURE
![image](https://github.com/user-attachments/assets/5b9d5a12-1ba5-4ebb-b89a-81c5ce513560)

