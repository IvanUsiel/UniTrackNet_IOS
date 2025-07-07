![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-343434?style=for-the-badge&logo=apple&logoColor=white)
![Storyboard](https://img.shields.io/badge/Storyboard-FFD700?style=for-the-badge)
![MapKit](https://img.shields.io/badge/MapKit-339933?style=for-the-badge&logo=apple&logoColor=white)
![MKRingProgress](https://img.shields.io/badge/MKRingProgress-8E44AD?style=for-the-badge)
![BackgroundTasks](https://img.shields.io/badge/Background_Processing-FF6F61?style=for-the-badge)
![Cisco](https://img.shields.io/badge/Cisco-Networking-blue?style=for-the-badge&logo=cisco&logoColor=white)
![Juniper](https://img.shields.io/badge/Juniper-Networking-005073?style=for-the-badge)
![Cisco ISE](https://img.shields.io/badge/Cisco%20ISE-NAC%20%7C%20AAA-blue?style=for-the-badge&logo=cisco&logoColor=white)



# UniTrackNet iOS

**UniTrackNet** es una aplicación iOS de monitoreo y gestión de redes, diseñada para optimizar el control de enlaces y sesiones de routers utilizados por **UNINET**, especialmente aquellos que operan con los protocolos **BGP** y **OSPF** entre **Estados Unidos y México**.  
Está enfocada en la **detección temprana de fallas de red**, alertas en tiempo real y acciones proactivas desde una interfaz intuitiva para operadores.

---

## Objetivo del App

El objetivo principal de UniTrackNet iOS es:

- Proporcionar monitoreo en tiempo real de sesiones BGP/OSPF.
- Visualizar el estado de enlaces y sesiones activas en routers UNINET.
- Ofrecer acceso móvil al personal para una respuesta rápida y remota.
- Facilitar el monitoreo remoto desde cualquier ubicación, eliminando la dependencia de consolas físicas o herramientas de escritorio.
- Visualizar el estado actual de la red mediante paneles dinámicos y representaciones gráficas accesibles desde dispositivos
- Notificar de forma proactiva a los operadores ante degradaciones de servicio, desconexiones críticas o comportamientos fuera de lo esperado.
- Permitir el acceso seguro a la información de red a través de autenticación con credenciales y control de sesiones activas.
- Integrarse con sistemas existentes mediante interfaces seguras (API REST o WebSockets) adaptadas a la infraestructura interna de UNINET.
---

## Descripción del Logo

>El logo de UniTrackNet muestra una red de puntos conectados entre sí, representando cómo se comunican los routers en una red real.
>Las líneas grises simbolizan los enlaces entre dispositivos, mientras que los círculos verdes representan los nodos activos que están enviando o recibiendo información.

>Es un diseño simple pero moderno, pensado para transmitir conexión, tecnología y monitoreo constante. Además, los colores reflejan estabilidad y energía, dos cosas claves para el funcionamiento de una red confiable.

![unitracknet_icon_logo](https://github.com/user-attachments/assets/e04d1a55-741d-431e-ab16-ba1901af77b6)

## Justificación técnica

**Dispositivo:**  
La aplicación está desarrollada para **iPhone**, ya que es el dispositivo más práctico y accesible para operadores de red que necesitan monitorear en movimiento o fuera de oficina.

**Versión mínima de iOS:**  
Se requiere **iOS 15.0** o superior para garantizar compatibilidad con funciones modernas como tareas en segundo plano, manejo eficiente de recursos y una experiencia fluida.

**Orientaciones soportadas:**  
La app está diseñada exclusivamente para funcionar en **orientación vertical (portrait)**. Esto mejora la usabilidad con una sola mano y se adapta mejor a contextos operativos móviles.

## Credenciales de acceso

Estas credenciales te permiten acceder a una versión de prueba que simula el funcionamiento general del monitoreo de red:

```
Usuario: irjarqui
Contraseña: UnitrackNet
```

---

### Versión de producción

El acceso a la versión de producción está restringido por razones de seguridad y requiere lo siguiente:

- Conexión a través de **VPN corporativa**
- Códigos de acceso dinámicos generados al momento
- Credenciales individuales de acceso autorizadas

Si gustan en probar la versión de producción o necesitas acceso completo, por favor **contáctame directamente**.
 sobre todo por la cuestion de los codigos de acceso en tiempo real.

## Dependencias del proyecto

- **UIKit (construcción en código)** – Para toda la interfaz de usuario.
- **Foundation** – Para estructuras base y tipos como `Date`, `Data`, etc.
- **UserDefaults** – Para guardar configuraciones locales y preferencias.
- **Keychain** – Para el almacenamiento seguro de credenciales.
- **URLSession** – Para realizar conexiones de red (HTTP/HTTPS) a APIs internas o externas.
- **Codable** – Para codificar y decodificar datos JSON de forma segura y rápida.
- **MapKit** – Para visualizar nodos, enlaces y ubicaciones en un mapa.
- **BackgroundTasks** – Para tareas automatizadas en segundo plano.
- **UserProfileStore** – Clase interna para gestionar la información del usuario autenticado.

## Autor

**Ivan Usiel Ramírez Jarquín**  
[GitHub: @IvanUsiel](https://github.com/IvanUsiel)  
Contacto directo: usiel_jarquin@outlook.com; irjarqui@uninet.com.mx;

---
