# EZBar Frontend

## Índice
1. [Arquitectura del Frontend](#1-arquitectura-del-frontend)  
2. [Instalación y Configuración](#2-instalación-y-configuración)  
3. [Funcionamiento de la Aplicación](#3-funcionamiento-de-la-aplicación)  
4. [Estado del Proyecto](#4-estado-del-proyecto)  
5. [Autores](#5-autores)  

---

## 1. Arquitectura del Frontend

El **Frontend** de EZBar está desarrollado en **Flutter**, orientado a dispositivos móviles Android e iOS.  
Su función principal es proporcionar una interfaz rápida, intuitiva y optimizada para el trabajo diario en hostelería.

El Frontend se comunica con el sistema mediante:

- **API Node.js:** Recibe y envía las peticiones realizadas por la aplicación.  
- **Backend Java:** Procesa la lógica de negocio y gestiona la base de datos.  

### Componentes principales del Frontend

- **Pantalla de Login:** Autenticación del usuario.  
- **Selector de Zonas:** Permite elegir entre Terraza, Barra, Comedor, etc.  
- **Mapa de Mesas:** Vista principal con el estado de cada mesa.  
- **Gestión de Pedidos:** Añadir productos, modificar cantidades, enviar a cocina/barra.  
- **Cierre de Mesa:** Finalización del servicio y liberación de la mesa.

La arquitectura está diseñada para ser **modular**, **escalable** y fácil de mantener, permitiendo añadir nuevas funcionalidades sin afectar al núcleo de la aplicación.

## 2. Instalación y Configuración

### Requisitos Previos

Antes de ejecutar el Frontend, asegúrate de tener instalado:

- Flutter 3.x o superior  
- Dart SDK (incluido con Flutter)  
- Android Studio o VS Code con extensiones de Flutter  
- Dispositivo físico o emulador Android/iOS  
- Conexión activa con la API Node.js y el Backend Java  

---

### Clonar el Repositorio

```bash
git clone https://github.com/Monti1751/EZBar_Frontend.git
cd EZBar_Frontend
```
## 3. Funcionamiento de la Aplicación

El Frontend de EZBar está diseñado para ofrecer una experiencia rápida, intuitiva y adaptada al flujo de trabajo real en hostelería. La aplicación permite gestionar mesas, zonas y pedidos de forma visual y eficiente.

---

### Flujo General de Uso

1. **Inicio de sesión**  
   El usuario introduce sus credenciales y accede según su rol.

2. **Selección de zona**  
   El camarero elige la zona del local (Terraza, Barra, Comedor, etc.).

3. **Mapa de mesas**  
   Se muestra una vista visual con el estado de cada mesa:  
   - Libre  
   - Ocupada  
   - Pendiente de pago  

4. **Gestión del pedido**  
   Al seleccionar una mesa, el usuario puede:  
   - Añadir productos  
   - Modificar cantidades  
   - Añadir notas  
   - Enviar el pedido a cocina/barra  

5. **Cierre de mesa**  
   Una vez finalizado el servicio, se procede al cobro y la mesa vuelve a estado libre.

---

### Comunicación con el Sistema

- El Frontend envía las acciones del usuario a la **API Node.js**.  
- La API procesa la petición y la envía al **Backend Java**, que ejecuta la lógica de negocio.  
- La respuesta vuelve al Frontend, actualizando el estado de la aplicación.

Este flujo garantiza una experiencia fluida y coherente entre todos los módulos del sistema.

---

### Objetivo del Funcionamiento

El Frontend está diseñado para:

- Reducir tiempos de espera.  
- Minimizar errores en pedidos.  
- Facilitar la gestión de zonas y mesas.  
- Mejorar la coordinación entre camareros y cocina/barra.  
- Ofrecer una interfaz clara y fácil de usar incluso en momentos de alta carga de trabajo.
  
## 4. Estado del Proyecto

El Frontend de EZBar se encuentra actualmente en **versión Alpha**, lo que significa que está en una fase temprana de desarrollo y pruebas.  
Durante esta etapa se están validando las funcionalidades principales y la correcta comunicación con la API Node.js y el Backend Java.

### Funcionalidades en Estado Alpha

- Interfaz funcional para la gestión de zonas y mesas.  
- Sistema básico de autenticación.  
- Creación y edición de pedidos.  
- Comunicación estable con la API Node.js.  
- Actualización del estado de mesas en tiempo real (según implementación actual).

### Próximos Objetivos

- Mejoras en la interfaz de usuario y experiencia de uso.  
- Optimización del rendimiento en dispositivos de gama baja.  
- Implementación de nuevas pantallas y flujos.  
- Preparación para una futura **versión Beta**, más estable y completa.

> El proyecto está en desarrollo activo, por lo que se esperan cambios frecuentes en la estructura y funcionamiento del Frontend.

## 5. Autores

Este módulo Frontend forma parte del proyecto completo **EZBar**, desarrollado por:

- **Miguel Tomás**  
  - GitHub: [Tommy23-has](https://github.com/Tommy23-has)  
  - GitHub: [ismigue23](https://github.com/ismigue23)

- **Francisco Montesinos**  
  - GitHub: [FranMontesinos](https://github.com/FranMontesinos)  
  - GitHub: [Monti1751](https://github.com/Monti1751)

- **Miguel Jiménez**  
  - GitHub: [MiguelJimenezSerrano](https://github.com/MiguelJimenezSerrano)

- **Miguel Duque**  
  - GitHub: [El-Mig](https://github.com/El-Mig)  
  - GitHub: [Mig56](https://github.com/Mig56)

> Para más información sobre el proyecto completo, consulta el README principal del repositorio.
