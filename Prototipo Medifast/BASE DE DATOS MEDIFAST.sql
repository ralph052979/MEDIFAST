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


INSERT INTO usuarios (nombre, apellido, correo, telefono, contrasena) VALUES
('Carlos', 'Martínez', 'carlos.martinez@example.com', '3001234567', '1234abcd'),
('Luisa', 'Gómez', 'luisa.gomez@example.com', '3009876543', 'abcd1234'),
('Pedro', 'López', 'pedro.lopez@example.com', '3011112222', 'passPedro'),
('Ana', 'Rodríguez', 'ana.rodriguez@example.com', '3022223333', 'anaSecure'),
('María', 'Pérez', 'maria.perez@example.com', '3033334444', 'mariaClave');

INSERT INTO medicamentos (nombre, descripcion, disponibilidad) VALUES
('Paracetamol', 'Analgésico y antipirético', TRUE),
('Ibuprofeno', 'Antiinflamatorio no esteroideo', TRUE),
('Amoxicilina', 'Antibiótico del grupo de las penicilinas', TRUE),
('Loratadina', 'Antihistamínico para alergias', TRUE),
('Salbutamol', 'Broncodilatador para el asma', TRUE);

INSERT INTO solicitudes (id_usuario, id_medicamento, estado) VALUES
(1, 1, 'pendiente'),
(2, 2, 'procesada'),
(3, 3, 'rechazada'),
(4, 4, 'pendiente'),
(5, 5, 'procesada');

INSERT INTO notificaciones (id_usuario, mensaje, leida) VALUES
(1, 'Su solicitud ha sido recibida', FALSE),
(2, 'Su solicitud fue procesada correctamente', TRUE),
(3, 'Su solicitud fue rechazada por falta de stock', TRUE),
(4, 'Nuevo medicamento disponible', FALSE),
(5, 'Actualización en su solicitud', FALSE);

INSERT INTO auditoria (id_usuario, accion, fecha) VALUES
(1, 'Inicio de sesión', NOW()),
(2, 'Actualizó contraseña', NOW()),
(3, 'Realizó una solicitud', NOW()),
(4, 'Leyó una notificación', NOW()),
(5, 'Cerró sesión', NOW());


DELIMITER //
CREATE PROCEDURE insertar_usuario(
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_correo VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_contrasena VARCHAR(255)
)
BEGIN
    INSERT INTO usuarios (nombre, apellido, correo, telefono, contrasena)
    VALUES (p_nombre, p_apellido, p_correo, p_telefono, p_contrasena);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE insertar_medicamento(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_disponibilidad BOOLEAN
)
BEGIN
    INSERT INTO medicamentos (nombre, descripcion, disponibilidad)
    VALUES (p_nombre, p_descripcion, p_disponibilidad);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE insertar_solicitud(
    IN p_id_usuario INT,
    IN p_id_medicamento INT,
    IN p_estado ENUM('pendiente', 'procesada', 'rechazada')
)
BEGIN
    INSERT INTO solicitudes (id_usuario, id_medicamento, estado)
    VALUES (p_id_usuario, p_id_medicamento, p_estado);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE insertar_notificacion(
    IN p_id_usuario INT,
    IN p_mensaje TEXT,
    IN p_leida BOOLEAN
)
BEGIN
    INSERT INTO notificaciones (id_usuario, mensaje, leida)
    VALUES (p_id_usuario, p_mensaje, p_leida);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE consultar_usuarios()
BEGIN
    SELECT * FROM usuarios;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE consultar_medicamentos()
BEGIN
    SELECT * FROM medicamentos;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE consultar_solicitudes()
BEGIN
    SELECT s.*, u.nombre AS usuario, m.nombre AS medicamento
    FROM solicitudes s
    JOIN usuarios u ON s.id_usuario = u.id_usuario
    JOIN medicamentos m ON s.id_medicamento = m.id_medicamento;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE consultar_notificaciones()
BEGIN
    SELECT n.*, u.nombre AS usuario
    FROM notificaciones n
    JOIN usuarios u ON n.id_usuario = u.id_usuario;
END //
DELIMITER ;


## vistas

CREATE VIEW vista_solicitudes_detalladas AS
SELECT 
    s.id_solicitud,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_usuario,
    u.correo,
    m.nombre AS nombre_medicamento,
    s.fecha_solicitud,
    s.estado
FROM solicitudes s
JOIN usuarios u ON s.id_usuario = u.id_usuario
JOIN medicamentos m ON s.id_medicamento = m.id_medicamento;

##------------------
CREATE VIEW vista_notificaciones_usuarios AS
SELECT 
    n.id_notificacion,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_usuario,
    u.correo,
    n.mensaje,
    n.leida,
    n.fecha_envio
FROM notificaciones n
JOIN usuarios u ON n.id_usuario = u.id_usuario;

##--------------------------

CREATE VIEW vista_auditoria_usuarios AS
SELECT 
    a.id_auditoria,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_usuario,
    u.correo,
    a.accion,
    a.fecha
FROM auditoria a
JOIN usuarios u ON a.id_usuario = u.id_usuario;

##-------------------

CREATE VIEW vista_usuarios_medicamentos_solicitados AS
SELECT 
    u.id_usuario,
    CONCAT(u.nombre, ' ', u.apellido) AS nombre_usuario,
    m.id_medicamento,
    m.nombre AS nombre_medicamento,
    s.fecha_solicitud,
    s.estado
FROM solicitudes s
JOIN usuarios u ON s.id_usuario = u.id_usuario
JOIN medicamentos m ON s.id_medicamento = m.id_medicamento;

##--------------------------

CREATE VIEW vista_medicamentos_solicitudes_estado AS
SELECT 
    m.nombre AS medicamento,
    s.estado,
    COUNT(*) AS cantidad_solicitudes
FROM solicitudes s
JOIN medicamentos m ON s.id_medicamento = m.id_medicamento
GROUP BY m.nombre, s.estado;

## activar consultas

SET profiling = 1;

SELECT * FROM vista_solicitudes_detalladas WHERE estado = 'pendiente';

SHOW PROFILE ALL FOR QUERY 1;

-- Mostrar toda la información disponible
SHOW PROFILE ALL FOR QUERY 1;

-- Mostrar información de operaciones de entrada/salida
SHOW PROFILE BLOCK IO FOR QUERY 1;

-- Mostrar número de cambios de contexto
SHOW PROFILE CONTEXT SWITCHES FOR QUERY 1;

-- Mostrar uso de CPU
SHOW PROFILE CPU FOR QUERY 1;

-- Mostrar uso de memoria
SHOW PROFILE MEMORY FOR QUERY 1;

-- Mostrar información de la fuente
SHOW PROFILE SOURCE FOR QUERY 1;

-- Mostrar número de swaps
SHOW PROFILE SWAPS FOR QUERY 1;
