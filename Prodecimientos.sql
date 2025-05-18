
CREATE PROCEDURE sp_EnviarMensaje
    @RemitenteID INT,                  -- ID del usuario que envía el mensaje
    @Contenido VARCHAR(MAX),           -- Texto del mensaje a enviar
    @Destinatarios VARCHAR(MAX)        -- Lista de IDs de destinatarios separados por coma (ejemplo: '2,3,5')
AS
BEGIN
    SET NOCOUNT ON;                    -- Evita que el conteo de filas afectadas se muestre (mejora rendimiento)

    DECLARE @MensajeID INT;            -- Variable para guardar el ID del mensaje insertado
    DECLARE @FechaActual DATETIME = GETDATE();  -- Fecha y hora actual

    -- Insertar el mensaje en la tabla Mensajes
    INSERT INTO Mensajes (RemitenteID, Contenido, FechaEnvio)
    VALUES (@RemitenteID, @Contenido, @FechaActual);

    SET @MensajeID = SCOPE_IDENTITY(); -- Obtener el ID generado automáticamente del mensaje insertado

    -- Variables para el proceso de separación de IDs de destinatarios
    DECLARE @ID INT;                   -- Variable temporal para almacenar un ID de destinatario
    DECLARE @Pos INT = 1;              -- Posición inicial para buscar comas en la cadena
    DECLARE @DestinatariosTemp VARCHAR(MAX) = @Destinatarios + ','; -- Añadir coma al final para facilitar el procesamiento

    -- Ciclo para extraer cada ID separado por coma y hacer inserción en MensajesDestinatarios
    WHILE CHARINDEX(',', @DestinatariosTemp, @Pos) > 0
    BEGIN
        -- Extraer la subcadena entre @Pos y la siguiente coma, convertir a INT
        SET @ID = CAST(
            SUBSTRING(
                @DestinatariosTemp,
                @Pos,
                CHARINDEX(',', @DestinatariosTemp, @Pos) - @Pos
            ) AS INT
        );
        
        -- Insertar registro que relaciona el mensaje con el destinatario
        INSERT INTO MensajesDestinatarios (MensajeID, DestinatarioID, Estado, FechaEstado)
        VALUES (@MensajeID, @ID, 'Enviado', @FechaActual);
        
        -- Mover la posición justo después de la coma encontrada para la siguiente iteración
        SET @Pos = CHARINDEX(',', @DestinatariosTemp, @Pos) + 1;
    END

    -- Registrar la acción de envío en la tabla Auditoria para seguimiento
    INSERT INTO Auditoria (UsuarioID, Accion, Fecha, Descripcion)
    VALUES (
        @RemitenteID,
        'Envio de mensaje',
        @FechaActual,
        CONCAT('Envió el mensaje ID ', @MensajeID, ' a: ', @Destinatarios)
    );
END;

-- Procedimiento 2: Mostrar mensajes recibidos por un usuario
CREATE PROCEDURE sp_VerMensajesRecibidos 
    @UsuarioID INT -- Parámetro: ID del usuario que quiere ver sus mensajes recibidos
AS
BEGIN
    SET NOCOUNT ON; -- Evita que el servidor envíe mensajes adicionales sobre filas afectadas, optimiza ejecución

    SELECT 
        M.MensajeID,          -- ID del mensaje
        U.Nombre AS Remitente, -- Nombre del usuario que envió el mensaje
        M.Contenido,          -- Texto del mensaje
        M.FechaEnvio,         -- Fecha y hora en que se envió el mensaje
        MD.Estado,            -- Estado del mensaje para el destinatario (ej. 'Enviado', 'Leído')
        MD.FechaEstado        -- Fecha en que se actualizó el estado
    FROM MensajesDestinatarios MD -- Tabla que relaciona mensajes y destinatarios
    INNER JOIN Mensajes M ON MD.MensajeID = M.MensajeID -- Unimos para obtener detalles del mensaje
    INNER JOIN Usuarios U ON M.RemitenteID = U.UsuarioID -- Unimos para obtener el nombre del remitente
    WHERE MD.DestinatarioID = @UsuarioID -- Filtramos sólo los mensajes que llegaron al usuario
    ORDER BY M.FechaEnvio DESC; -- Ordenamos los mensajes desde el más reciente al más antiguo
END;


-- Procedimiento 3: Actualizar el estado de un mensaje recibido (por ejemplo, marcar como leído)
CREATE PROCEDURE sp_ActualizarEstadoMensaje
    @MensajeID INT,          -- ID del mensaje a actualizar
    @UsuarioID INT,          -- ID del usuario que está actualizando el estado
    @NuevoEstado VARCHAR(20) -- Nuevo estado que se asignará (ej. 'Leído', 'Archivado')
AS
BEGIN
    SET NOCOUNT ON; -- Evita mensajes extras de filas afectadas

    UPDATE MensajesDestinatarios
    SET Estado = @NuevoEstado, -- Cambia el estado del mensaje
        FechaEstado = GETDATE() -- Actualiza la fecha de cambio al momento actual
    WHERE MensajeID = @MensajeID AND DestinatarioID = @UsuarioID; -- Solo para ese usuario y mensaje específico

    -- Registrar esta acción en auditoría para control y seguimiento
    INSERT INTO Auditoria (UsuarioID, Accion, Fecha, Descripcion)
    VALUES (@UsuarioID, 'Actualización de estado', GETDATE(), 
           CONCAT('Mensaje ', @MensajeID, ' actualizado a "', @NuevoEstado, '"'));
END;


-- Procedimiento 4: Ver historial de auditoría de un usuario específico
CREATE PROCEDURE sp_VerHistorialAuditoria
    @UsuarioID INT -- ID del usuario cuyo historial queremos ver
AS
BEGIN
    SET NOCOUNT ON; -- Sin mensajes extras de filas afectadas

    SELECT 
        AuditoriaID, -- ID del registro de auditoría
        Accion,     -- Acción realizada
        Fecha,      -- Fecha y hora en que ocurrió la acción
        Descripcion -- Detalles adicionales sobre la acción
    FROM Auditoria
    WHERE UsuarioID = @UsuarioID -- Filtra solo registros del usuario dado
    ORDER BY Fecha DESC; -- Ordena desde el más reciente al más antiguo
END;
