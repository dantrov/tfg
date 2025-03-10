CREATE DATABASE domotica;
USE domotica;

--  Usuarios y Autenticación
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol ENUM('admin', 'usuario') DEFAULT 'usuario',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--  Seguridad y Auditoría

-- Intentos fallidos de acceso
CREATE TABLE intentos_fallidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50),
    ip_origen VARCHAR(15) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE SET NULL
);

-- Gestión de permisos específicos por usuario
CREATE TABLE permisos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    servicio ENUM('homeassistant', 'nas', 'vpn', 'proxy', 'admin') NOT NULL,
    nivel ENUM('lectura', 'escritura', 'admin') NOT NULL,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE CASCADE
);

-- Logs de Actividades (Home Assistant, NAS, VPN)
CREATE TABLE logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    servicio ENUM('homeassistant', 'nas', 'vpn', 'proxy') NOT NULL,
    accion TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE CASCADE
);

--  Administración de Domótica

-- Dispositivos Inteligentes Conectados
CREATE TABLE dispositivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('sensor', 'camara', 'luz', 'termostato', 'enchufe', 'pantalla') NOT NULL, /*Aumentar dependiendo de los dispositivos*/
    ip VARCHAR(15) NOT NULL UNIQUE,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    propietario VARCHAR(50),
    FOREIGN KEY (propietario) REFERENCES usuarios(usuario) ON DELETE SET NULL
);

-- Historial de cambios en los dispositivos
CREATE TABLE historial_dispositivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dispositivo_id INT NOT NULL,
    usuario VARCHAR(50),
    cambio TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dispositivo_id) REFERENCES dispositivos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE SET NULL
);

-- Programación de eventos y automatizaciones
CREATE TABLE automatizaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    dispositivo_id INT NOT NULL,
    accion VARCHAR(255) NOT NULL,
    hora_programada TIME NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE CASCADE,
    FOREIGN KEY (dispositivo_id) REFERENCES dispositivos(id) ON DELETE CASCADE
);

--  Configuración de la Red (VPN, VLANs y Proxy)
CREATE TABLE configuracion_red (
    id INT AUTO_INCREMENT PRIMARY KEY,
    servicio ENUM('vpn', 'proxy', 'vlan', 'firewall') NOT NULL, /*Se pueden añadir más en dependencia de los servicios*/
    descripcion VARCHAR(1000) NOT NULL, -- Para no usar 
    estado ENUM('habilitado', 'deshabilitado') DEFAULT 'habilitado'
);

--  Registros de Conexiones VPN
CREATE TABLE conexiones_vpn (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    ip_origen VARCHAR(15) NOT NULL,
    ancho_banda_utilizado INT NOT NULL, -- Control de ancho de banda
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE CASCADE
);

--  Reglas de Firewall Aplicadas
CREATE TABLE reglas_firewall (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    regla VARCHAR(255) NOT NULL,
    estado ENUM('habilitada', 'deshabilitada') DEFAULT 'habilitada',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE CASCADE
);

--  Archivos del NAS
CREATE TABLE archivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    tipo_archivo VARCHAR(255) NOT NULL,
    ruta VARCHAR(1000) NOT NULL,
    tamano INT NOT NULL,
    version INT DEFAULT 1, -- Control de versiones
    fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE CASCADE
);

--  Cuotas de Almacenamiento por Usuario
CREATE TABLE cuotas_almacenamiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    cuota_maxima INT NOT NULL,
    espacio_usado INT DEFAULT 0,
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE CASCADE
);

-- Reportes

CREATE TABLE reportes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('dispositivos', 'accesos', 'seguridad', 'almacenamiento') NOT NULL,
    usuario VARCHAR(50) NOT NULL,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datos TEXT NOT NULL, /*No tiene las limitaciones de VARCHAR pero consumen mas almacenamiento*/
    FOREIGN KEY (usuario) REFERENCES usuarios(usuario) ON DELETE CASCADE
);

