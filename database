CREATE DATABASE Mensajeria
USE Mensajeria

CREATE TABLE Usuarios ( 
    UsuarioID INT PRIMARY KEY IDENTITY, 
    Nombre VARCHAR(100), 
    Telefono VARCHAR(15) UNIQUE,
    Email VARCHAR(100), 
    Rol VARCHAR(50) 
);

CREATE TABLE Contactos (
    ContactoID INT PRIMARY KEY IDENTITY,
    UsuarioID INT, 
    Nombre VARCHAR(100), 
    Telefono VARCHAR(15), 
    Email VARCHAR(100), 
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE Grupos (
    GrupoID INT PRIMARY KEY IDENTITY,
    Nombre VARCHAR(100)
);

CREATE TABLE MiembrosGrupo (
    GrupoID INT,
    UsuarioID INT,
    PRIMARY KEY (GrupoID, UsuarioID),
    FOREIGN KEY (GrupoID) REFERENCES Grupos(GrupoID),
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE Mensajes (
    MensajeID INT PRIMARY KEY IDENTITY,
    RemitenteID INT,
    Contenido VARCHAR(MAX),
    FechaEnvio DATETIME,
    FechaProgramada DATETIME NULL,
    FOREIGN KEY (RemitenteID) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE MensajesDestinatarios (
    MensajeID INT,
    DestinatarioID INT,
    Estado VARCHAR(20),
    FechaEstado DATETIME,
    PRIMARY KEY (MensajeID, DestinatarioID),
    FOREIGN KEY (MensajeID) REFERENCES Mensajes(MensajeID),
    FOREIGN KEY (DestinatarioID) REFERENCES Usuarios(UsuarioID)
);

CREATE TABLE Auditoria (
    AuditoriaID INT PRIMARY KEY IDENTITY,
    UsuarioID INT,
    Accion VARCHAR(100),
    Fecha DATETIME,
    Descripcion VARCHAR(255),
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);
