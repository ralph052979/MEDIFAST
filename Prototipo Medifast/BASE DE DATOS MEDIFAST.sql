-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS medifast_db;
USE medifast_db;

-- Tabla: usuarios
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    contrasena VARCHAR(255) NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: medicamentos
CREATE TABLE medicamentos (
    id_medicamento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    disponibilidad BOOLEAN DEFAULT TRUE,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: solicitudes
CREATE TABLE solicitudes (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_medicamento INT,
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('pendiente', 'procesada', 'rechazada') DEFAULT 'pendiente',
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
);

-- Tabla: notificaciones
CREATE TABLE notificaciones (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    mensaje TEXT NOT NULL,
    leida BOOLEAN DEFAULT FALSE,
    fecha_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- Tabla: auditoria (opcional para seguimiento)
CREATE TABLE auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    accion VARCHAR(100),
    descripcion TEXT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);
