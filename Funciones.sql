-- <-Funciones-> --

-- 1. BUSCAR MENSAJES POR TEXTO
CREATE FUNCTION fn_BuscarMensajesPorTexto (@palabraClave NVARCHAR(100))
RETURNS TABLE
AS
RETURN (
    SELECT 
        M.MensajeID,
        U.Nombre AS Remitente,
        M.Contenido,
        M.FechaEnvio
    FROM Mensajes M
    INNER JOIN Usuarios U ON M.RemitenteID = U.UsuarioID
    WHERE M.Contenido LIKE '%' + @palabraClave + '%'
);



-- 2. BUSCAR MENSAJES POR FECHA
CREATE FUNCTION fn_BuscarMensajesPorFecha (@fecha DATE)
RETURNS TABLE
AS
RETURN (
    SELECT 
        M.MensajeID,
        U.Nombre AS Remitente,
        M.Contenido,
        M.FechaEnvio
    FROM Mensajes M
    INNER JOIN Usuarios U ON M.RemitenteID = U.UsuarioID
    WHERE CAST(M.FechaEnvio AS DATE) = @fecha
);


-- 3. BUSCAR MENSJAES POR REMITENTE (NOMBRE)
CREATE FUNCTION fn_BuscarMensajesPorRemitente (@nombreRemitente NVARCHAR(100))
RETURNS TABLE
AS
RETURN (
    SELECT 
        M.MensajeID,
        U.Nombre AS Remitente,
        M.Contenido,
        M.FechaEnvio
    FROM Mensajes M
    INNER JOIN Usuarios U ON M.RemitenteID = U.UsuarioID
    WHERE U.Nombre LIKE '%' + @nombreRemitente + '%'
);


-- 4. BUSQUEDA AVANZADA COMBINADA (TEXT, FECHA, REMITENTE)
CREATE FUNCTION fn_BuscarMensajesAvanzado (
    @palabraClave NVARCHAR(100) = NULL,
    @fecha DATE = NULL,
    @nombreRemitente NVARCHAR(100) = NULL
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        M.MensajeID,
        U.Nombre AS Remitente,
        M.Contenido,
        M.FechaEnvio
    FROM Mensajes M
    INNER JOIN Usuarios U ON M.RemitenteID = U.UsuarioID
    WHERE (@palabraClave IS NULL OR M.Contenido LIKE '%' + @palabraClave + '%')
      AND (@fecha IS NULL OR CAST(M.FechaEnvio AS DATE) = @fecha)
      AND (@nombreRemitente IS NULL OR U.Nombre LIKE '%' + @nombreRemitente + '%')
);
