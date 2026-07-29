# autogenos_app

# Autogenos App

Aplicación móvil para la plataforma Autogenos. Permite la gestión de intervenciones y el uso de diagnósticos asistidos por Inteligencia Artificial.

## Roles de Usuario

La aplicación está diseñada para manejar diferentes roles de usuario, lo que afecta las funcionalidades disponibles:

- **Técnico (`technician`)**: Tiene acceso a la lista de intervenciones asignadas y puede solicitar diagnósticos mediante Inteligencia Artificial para las mismas.
- **Administrador (`admin`)**: Tiene un nivel de acceso similar al técnico en la aplicación móvil, con la capacidad de gestionar las intervenciones.
- **Cliente (`client`)**: Posee una vista diferenciada y limitada, orientada al seguimiento de sus propios servicios.

## Endpoints de la API

La aplicación se comunica con un backend a través de los siguientes endpoints. La URL base depende del entorno (desarrollo o producción).

Todos los endpoints (a excepción de `/login`) **requieren autenticación**. Es necesario incluir el token obtenido durante el inicio de sesión en el header `Authorization` con el formato `Bearer <token>`.

### Autenticación y Usuario
- `POST /login`
  - **Acceso:** Público (No requiere token).
  - **Uso:** Autentica a un usuario utilizando sus credenciales. Retorna el token de acceso que debe guardarse de forma segura.
- `POST /logout`
  - **Acceso:** Privado (Requiere token).
  - **Uso:** Cierra la sesión activa del usuario y revoca el token actual.
- `GET /me`
  - **Acceso:** Privado (Requiere token).
  - **Uso:** Obtiene la información del usuario autenticado actualmente, incluyendo su rol (`admin`, `technician`, `client`).

### Intervenciones
- `GET /interventions`
  - **Acceso:** Privado (Requiere token).
  - **Uso:** Obtiene la lista de intervenciones disponibles para el usuario, dependiendo de su rol.
- `POST /interventions/{id}/ai-diagnostic`
  - **Acceso:** Privado (Requiere token).
  - **Uso:** Solicita la generación de un diagnóstico asistido por IA para una intervención específica.
