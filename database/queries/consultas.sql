-- =====================================================
-- CONSULTAS DEL PROYECTO
-- Clínica San Rafael
-- =====================================================


-- 1. Listado de citas con paciente, médico y especialidad
SELECT
    c.IdCita,
    p.Nombres + ' ' + p.Apellidos AS Paciente,
    m.Nombres + ' ' + m.Apellidos AS Medico,
    e.Nombre AS Especialidad,
    c.FechaHora,
    c.Estado
FROM Cita c
INNER JOIN Paciente p
    ON c.IdPaciente = p.IdPaciente
INNER JOIN Medico m
    ON c.IdMedico = m.IdMedico
INNER JOIN Especialidad e
    ON m.IdEspecialidad = e.IdEspecialidad;


-- 2. Cantidad de citas por especialidad
SELECT
    e.Nombre AS Especialidad,
    COUNT(c.IdCita) AS TotalCitas
FROM Especialidad e
INNER JOIN Medico m
    ON e.IdEspecialidad = m.IdEspecialidad
INNER JOIN Cita c
    ON m.IdMedico = c.IdMedico
GROUP BY e.Nombre
ORDER BY TotalCitas DESC;


-- 3. Total facturado, pagado y saldo pendiente
SELECT
    f.IdFactura,
    f.Total AS TotalFactura,
    ISNULL(SUM(p.Monto), 0) AS TotalPagado,
    f.Total - ISNULL(SUM(p.Monto), 0) AS SaldoPendiente
FROM Factura f
LEFT JOIN Pago p
    ON f.IdFactura = p.IdFactura
GROUP BY
    f.IdFactura,
    f.Total;


-- =====================================================
-- 4. Historial de atenciones de un paciente
-- =====================================================

SELECT
    p.DNI,
    p.Nombres + ' ' + p.Apellidos AS Paciente,
    c.FechaHora AS FechaCita,
    a.FechaHoraInicio,
    d.CodigoCIE10,
    d.Descripcion AS Diagnostico
FROM Paciente p
INNER JOIN Cita c
    ON p.IdPaciente = c.IdPaciente
INNER JOIN Atencion a
    ON c.IdCita = a.IdCita
INNER JOIN Diagnostico d
    ON a.IdAtencion = d.IdAtencion
WHERE p.DNI = '74852136'
ORDER BY c.FechaHora DESC;

-- =====================================================
-- 5. Citas pendientes o programadas
-- =====================================================

SELECT
    c.IdCita,
    p.Nombres + ' ' + p.Apellidos AS Paciente,
    m.Nombres + ' ' + m.Apellidos AS Medico,
    c.FechaHora,
    c.Motivo,
    c.Estado
FROM Cita c
INNER JOIN Paciente p
    ON c.IdPaciente = p.IdPaciente
INNER JOIN Medico m
    ON c.IdMedico = m.IdMedico
WHERE c.Estado IN ('Programada', 'Confirmada')
ORDER BY c.FechaHora;

-- =====================================================
-- 6. Médicos y cantidad de citas atendidas
-- =====================================================

SELECT
    m.IdMedico,
    m.Nombres + ' ' + m.Apellidos AS Medico,
    e.Nombre AS Especialidad,
    COUNT(c.IdCita) AS CitasAtendidas
FROM Medico m
INNER JOIN Especialidad e
    ON m.IdEspecialidad = e.IdEspecialidad
LEFT JOIN Cita c
    ON m.IdMedico = c.IdMedico
    AND c.Estado = 'Atendida'
GROUP BY
    m.IdMedico,
    m.Nombres,
    m.Apellidos,
    e.Nombre
ORDER BY CitasAtendidas DESC;


-- =====================================================
-- 7. Pacientes con más de una cita
-- =====================================================

SELECT
    p.IdPaciente,
    p.Nombres + ' ' + p.Apellidos AS Paciente,
    COUNT(c.IdCita) AS CantidadCitas
FROM Paciente p
INNER JOIN Cita c
    ON p.IdPaciente = c.IdPaciente
GROUP BY
    p.IdPaciente,
    p.Nombres,
    p.Apellidos
HAVING COUNT(c.IdCita) > 1
ORDER BY CantidadCitas DESC;


-- =====================================================
-- 8. Facturas superiores al promedio
-- =====================================================

SELECT
    IdFactura,
    FechaEmision,
    Total,
    Estado
FROM Factura
WHERE Total > (
    SELECT AVG(Total)
    FROM Factura
)
ORDER BY Total DESC;

