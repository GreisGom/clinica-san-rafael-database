-- =====================================================
-- PROYECTO: CLÍNICA SAN RAFAEL
-- Sistema de Gestión de Información Clínica
-- Motor: SQL Server
-- Lenguaje: T-SQL
-- =====================================================

CREATE DATABASE ClinicaSanRafael;
GO

USE ClinicaSanRafael;
GO


-- =====================================================
-- TABLA: Paciente
-- =====================================================

CREATE TABLE Paciente (
    IdPaciente INT IDENTITY(1,1) PRIMARY KEY,
    DNI VARCHAR(8) NOT NULL UNIQUE,
    Nombres VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Sexo CHAR(1) NOT NULL,
    Direccion VARCHAR(200),
    Telefono VARCHAR(15),
    Correo VARCHAR(100),
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Paciente_Sexo
        CHECK (Sexo IN ('F', 'M'))
);


-- =====================================================
-- TABLA: Especialidad
-- =====================================================

CREATE TABLE Especialidad (
    IdEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL UNIQUE,
    Descripcion VARCHAR(200)
);


-- =====================================================
-- TABLA: Medico
-- =====================================================

CREATE TABLE Medico (
    IdMedico INT IDENTITY(1,1) PRIMARY KEY,
    CMP VARCHAR(20) NOT NULL UNIQUE,
    Nombres VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    Telefono VARCHAR(15),
    Correo VARCHAR(100),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Activo',
    IdEspecialidad INT NOT NULL,

    CONSTRAINT CK_Medico_Estado
        CHECK (Estado IN ('Activo', 'Inactivo')),

    CONSTRAINT FK_Medico_Especialidad
        FOREIGN KEY (IdEspecialidad)
        REFERENCES Especialidad(IdEspecialidad)
);


-- =====================================================
-- TABLA: Consultorio
-- =====================================================

CREATE TABLE Consultorio (
    IdConsultorio INT IDENTITY(1,1) PRIMARY KEY,
    Numero VARCHAR(10) NOT NULL UNIQUE,
    Piso INT NOT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Disponible',

    CONSTRAINT CK_Consultorio_Estado
        CHECK (Estado IN ('Disponible', 'Ocupado', 'Mantenimiento'))
);


-- =====================================================
-- TABLA: Cita
-- =====================================================

CREATE TABLE Cita (
    IdCita INT IDENTITY(1,1) PRIMARY KEY,
    IdPaciente INT NOT NULL,
    IdMedico INT NOT NULL,
    IdConsultorio INT NOT NULL,
    FechaHora DATETIME NOT NULL,
    Motivo VARCHAR(250),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Programada',

    CONSTRAINT FK_Cita_Paciente
        FOREIGN KEY (IdPaciente)
        REFERENCES Paciente(IdPaciente),

    CONSTRAINT FK_Cita_Medico
        FOREIGN KEY (IdMedico)
        REFERENCES Medico(IdMedico),

    CONSTRAINT FK_Cita_Consultorio
        FOREIGN KEY (IdConsultorio)
        REFERENCES Consultorio(IdConsultorio),

    CONSTRAINT CK_Cita_Estado
        CHECK (Estado IN (
            'Programada',
            'Confirmada',
            'Atendida',
            'Cancelada',
            'No asistio'
        ))
);


-- =====================================================
-- TABLA: Atencion
-- =====================================================

CREATE TABLE Atencion (
    IdAtencion INT IDENTITY(1,1) PRIMARY KEY,
    IdCita INT NOT NULL UNIQUE,
    FechaHoraInicio DATETIME NOT NULL,
    FechaHoraFin DATETIME,
    Observaciones VARCHAR(500),

    CONSTRAINT FK_Atencion_Cita
        FOREIGN KEY (IdCita)
        REFERENCES Cita(IdCita),

    CONSTRAINT CK_Atencion_Horas
        CHECK (
            FechaHoraFin IS NULL
            OR FechaHoraFin >= FechaHoraInicio
        )
);


-- =====================================================
-- TABLA: Diagnostico
-- =====================================================

CREATE TABLE Diagnostico (
    IdDiagnostico INT IDENTITY(1,1) PRIMARY KEY,
    IdAtencion INT NOT NULL,
    CodigoCIE10 VARCHAR(10) NOT NULL,
    Descripcion VARCHAR(250) NOT NULL,
    Observaciones VARCHAR(500),

    CONSTRAINT FK_Diagnostico_Atencion
        FOREIGN KEY (IdAtencion)
        REFERENCES Atencion(IdAtencion)
);


-- =====================================================
-- TABLA: Factura
-- =====================================================

CREATE TABLE Factura (
    IdFactura INT IDENTITY(1,1) PRIMARY KEY,
    IdAtencion INT NOT NULL,
    FechaEmision DATETIME NOT NULL DEFAULT GETDATE(),
    Subtotal DECIMAL(10,2) NOT NULL,
    IGV DECIMAL(10,2) NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',

    CONSTRAINT FK_Factura_Atencion
        FOREIGN KEY (IdAtencion)
        REFERENCES Atencion(IdAtencion),

    CONSTRAINT CK_Factura_Montos
        CHECK (
            Subtotal >= 0
            AND IGV >= 0
            AND Total >= 0
        ),

    CONSTRAINT CK_Factura_Estado
        CHECK (Estado IN ('Pendiente', 'Pagada', 'Anulada'))
);


-- =====================================================
-- TABLA: Pago
-- =====================================================

CREATE TABLE Pago (
    IdPago INT IDENTITY(1,1) PRIMARY KEY,
    IdFactura INT NOT NULL,
    FechaPago DATETIME NOT NULL DEFAULT GETDATE(),
    Monto DECIMAL(10,2) NOT NULL,
    MetodoPago VARCHAR(30) NOT NULL,
    NumeroOperacion VARCHAR(50),

    CONSTRAINT FK_Pago_Factura
        FOREIGN KEY (IdFactura)
        REFERENCES Factura(IdFactura),

    CONSTRAINT CK_Pago_Monto
        CHECK (Monto > 0),

    CONSTRAINT CK_Pago_Metodo
        CHECK (MetodoPago IN (
            'Efectivo',
            'Tarjeta',
            'Transferencia',
            'Yape',
            'Plin'
        ))
);


-- =====================================================
-- DATOS DE PRUEBA
-- =====================================================

INSERT INTO Paciente
(DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Direccion, Telefono, Correo)
VALUES
('74852136', 'Ana', 'Torres Mendoza', '1998-04-15', 'F',
 'Av. Brasil 1250', '987654321', 'ana.torres@gmail.com'),

('70321458', 'Luis', 'Ramirez Soto', '1992-09-21', 'M',
 'Av. La Marina 850', '956123478', 'luis.ramirez@gmail.com'),

('76543210', 'Carla', 'Vega Ruiz', '2001-01-10', 'F',
 'Jr. Tacna 420', '945678123', 'carla.vega@gmail.com');


INSERT INTO Especialidad (Nombre, Descripcion)
VALUES
('Medicina General', 'Atención médica general'),
('Cardiología', 'Diagnóstico y tratamiento cardiovascular'),
('Dermatología', 'Diagnóstico y tratamiento de enfermedades de la piel');


INSERT INTO Medico
(CMP, Nombres, Apellidos, Telefono, Correo, Estado, IdEspecialidad)
VALUES
('CMP10001', 'Carlos', 'Perez Gomez', '987111222',
 'carlos.perez@clinica.com', 'Activo', 1),

('CMP10002', 'Maria', 'Lopez Vargas', '987333444',
 'maria.lopez@clinica.com', 'Activo', 2),

('CMP10003', 'Jorge', 'Castro Diaz', '987555666',
 'jorge.castro@clinica.com', 'Activo', 3);


INSERT INTO Consultorio (Numero, Piso, Estado)
VALUES
('101', 1, 'Disponible'),
('201', 2, 'Disponible'),
('202', 2, 'Disponible');


INSERT INTO Cita
(IdPaciente, IdMedico, IdConsultorio, FechaHora, Motivo, Estado)
VALUES
(1, 1, 1, '2026-08-10 09:00:00',
 'Dolor de cabeza recurrente', 'Atendida'),

(2, 2, 2, '2026-08-11 10:30:00',
 'Control cardiológico', 'Atendida'),

(3, 3, 3, '2026-08-25 11:00:00',
 'Irritación en la piel', 'Programada');


INSERT INTO Atencion
(IdCita, FechaHoraInicio, FechaHoraFin, Observaciones)
VALUES
(1, '2026-08-10 09:05:00', '2026-08-10 09:35:00',
 'Paciente estable durante la consulta'),

(2, '2026-08-11 10:35:00', '2026-08-11 11:10:00',
 'Se recomienda continuar con controles periódicos');


INSERT INTO Diagnostico
(IdAtencion, CodigoCIE10, Descripcion, Observaciones)
VALUES
(1, 'R51', 'Cefalea',
 'Se recomienda seguimiento si persisten los síntomas'),

(2, 'I10', 'Hipertensión esencial',
 'Continuar control de presión arterial');


INSERT INTO Factura
(IdAtencion, Subtotal, IGV, Total, Estado)
VALUES
(1, 100.00, 18.00, 118.00, 'Pagada'),
(2, 150.00, 27.00, 177.00, 'Pagada');


INSERT INTO Pago
(IdFactura, Monto, MetodoPago, NumeroOperacion)
VALUES
(1, 118.00, 'Yape', 'YP000001'),
(2, 177.00, 'Tarjeta', 'TC000002');


-- =====================================================
-- ÍNDICES
-- =====================================================

CREATE INDEX IX_Cita_FechaHora
ON Cita(FechaHora);

CREATE INDEX IX_Cita_IdPaciente
ON Cita(IdPaciente);
