USE master
GO

--CREACIÓN DE OBJETOS

--Cree la base de datos, entidades y relaciones. Incluya restricciones y claves.

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CureSA')
	CREATE DATABASE CureSA
ELSE
BEGIN
	DROP DATABASE CureSA
	CREATE DATABASE CureSA
END
GO

ALTER DATABASE CureSA 
SET COMPATIBILITY_LEVEL = 140
GO

USE CureSA
GO

-- Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto en la creación de objetos. 

CREATE SCHEMA Pacientes
GO

CREATE SCHEMA Medicos
GO

CREATE SCHEMA Hospital
GO

CREATE SCHEMA Gestion
GO

--Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. 

CREATE TABLE Medicos.Especialidad
(
	ID int identity (1,1) CONSTRAINT PKEspecialidad PRIMARY KEY,
	Nombre varchar (30) UNIQUE
)
GO

CREATE TABLE Medicos.Medico
(
	ID int identity (1,1) CONSTRAINT PKMedico PRIMARY KEY,
	Nombre varchar(20),
	Apellido varchar (20),
	Nro_matricula int UNIQUE,
	ID_especialidad int CONSTRAINT FK1Medico FOREIGN KEY REFERENCES Medicos.Especialidad (ID)
)
GO

CREATE TABLE Hospital.Sede
(
	ID int identity (1,1) CONSTRAINT PKSede PRIMARY KEY,
	Nombre varchar (20),
	Direccion varchar(max)
)
GO

CREATE TABLE Gestion.Dias_por_sede
(
	ID_sede int,
	ID_medico int,
	Dia varchar (15),
	Hora_inicio time,
	CONSTRAINT PKDias_por_sede PRIMARY KEY (ID_sede, ID_medico),
	CONSTRAINT FK1Dias_por_sede FOREIGN KEY (ID_sede) REFERENCES Hospital.Sede (ID),
	CONSTRAINT FK2Dias_por_sede FOREIGN KEY (ID_medico) REFERENCES Medicos.Medico (ID)
)
GO

CREATE TABLE Gestion.Estado_turno
(
	ID int identity (1,1) CONSTRAINT PKEstado_turno PRIMARY KEY,
	Nombre varchar (10) DEFAULT 'Disponible' CHECK (Nombre LIKE 'Disponible' OR Nombre LIKE 'Pendiente' OR Nombre LIKE 'Atendido' OR Nombre LIKE 'Ausente' OR Nombre LIKE 'Cancelado')
)
GO

CREATE TABLE Gestion.Tipo_turno
(
	ID int identity (1,1) CONSTRAINT PKTipo_turno PRIMARY KEY,
	Nombre varchar (10) CHECK (Nombre LIKE 'Presencial' OR Nombre LIKE 'Virtual')
)
GO

CREATE TABLE Gestion.Turno
(
	ID int identity (1,1) CONSTRAINT PKTurno PRIMARY KEY,
	Fecha date,
	Hora time,
	ID_medico int,
	ID_sede int,
	ID_estado_turno int CONSTRAINT FK1Turno FOREIGN KEY REFERENCES Gestion.Estado_turno (ID),
	ID_tipo_turno int CONSTRAINT FK2Turno FOREIGN KEY REFERENCES Gestion.Tipo_turno (ID),
	CONSTRAINT FK3Turno FOREIGN KEY (ID_medico, ID_sede) REFERENCES Gestion.Dias_por_sede (ID_sede, ID_medico)
)
GO

CREATE TABLE Pacientes.Usuario
(
	ID int identity (1,1) CONSTRAINT PKUsuario PRIMARY KEY,
	Contraseña varchar(30),
	Fecha_creacion date DEFAULT GETDATE()
)
GO

CREATE TABLE Pacientes.Domicilio --asumo que cada paciente puede tener un único domicilio para nuestra base de datos.
(
	ID int identity (1,1) CONSTRAINT PKDomicilio PRIMARY KEY,
	Calle varchar(80),
	Numero int CHECK (Numero > 0),
	Piso varchar(20),
	Departamento varchar(10),
	Cod_postal int,
	Pais varchar(30),
	Provincia varchar(40),
	Localidad varchar(40)
)
GO

CREATE TABLE Pacientes.Prestador
(
	ID int identity (1,1) CONSTRAINT PKPrestador PRIMARY KEY,
	Nombre varchar(30),
	nombre_plan varchar(30)
)
GO

CREATE TABLE Pacientes.Cobertura
(
	ID int identity (1,1) CONSTRAINT PKCobertura PRIMARY KEY,
	Imagen_credencial varchar(max),
	Nro_socio int UNIQUE,
	Fecha_registro date DEFAULT GETDATE(),
	ID_Prestador int CONSTRAINT FK1Cobertura FOREIGN KEY REFERENCES Pacientes.Prestador (ID)
)
GO

CREATE TABLE Pacientes.Paciente
(
	ID int identity (1,1) CONSTRAINT PKPaciente PRIMARY KEY,
	Nombre varchar(80),
	Apellido varchar(80),
	Apellido_materno varchar(20),
	Fecha_nac date,
	Tipo_doc varchar(20),
	Nro_doc int UNIQUE CHECK (Nro_doc > 0),
	Sexo char(9) CHECK (Sexo LIKE 'Masculino' or Sexo LIKE 'Femenino'),
	Genero varchar (15),
	Nacionalidad varchar(20),
	Foto_perfil varchar(max),
	Mail varchar(30),
	Tel_fijo char(14) CHECK (Tel_fijo LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	Tel_alternativo int CHECK (Tel_alternativo > 0),
	Tel_laboral int CHECK (Tel_laboral > 0),
	Fecha_registro date DEFAULT GETDATE(),
	Fecha_actualizacion date,
	Usuario_actualizacion int CONSTRAINT FK1Paciente FOREIGN KEY REFERENCES Pacientes.Usuario(ID),
	ID_domicilio int CONSTRAINT FK2Paciente FOREIGN KEY REFERENCES Pacientes.Domicilio (ID),
	ID_cobertura int CONSTRAINT FK3Paciente FOREIGN KEY REFERENCES Pacientes.Cobertura (ID)
)
GO

CREATE TABLE Gestion.Estudio
(
	ID int identity (1,1) CONSTRAINT PKEstudio PRIMARY KEY,
	Area varchar(50),
	Nombre varchar(80),
	Prestador varchar(50),
	Nombre_plan varchar(50),
	Porcentaje_cobertura int CHECK (Porcentaje_cobertura BETWEEN 0 AND 100),
	Costo int CHECK (Costo >= 0),
	Autorizado bit, --1 SI, 0 NO
)
GO

CREATE TABLE Gestion.Estudio_por_paciente
(
	ID_estudio int,
	ID_paciente int,
	fecha date,
	Documento_resultado varchar(max),
	Imagen_resultado varchar(max),
	CONSTRAINT PKEstudio_por_paciente PRIMARY KEY (ID_estudio, ID_paciente),
	CONSTRAINT FK1Estudio_por_paciente FOREIGN KEY (ID_estudio) REFERENCES Gestion.Estudio (ID),
	CONSTRAINT FK2Estudio_por_paciente FOREIGN KEY (ID_paciente) REFERENCES Pacientes.Paciente (ID)
)

CREATE TABLE Gestion.Reserva --tabla hecha para que sea más simple agregar o eliminar reservas de turnos.
(
	ID_paciente int,
	ID_turno int,
	CONSTRAINT PKReserva PRIMARY KEY (ID_paciente,ID_turno),
	CONSTRAINT FK1Reserva FOREIGN KEY (ID_paciente) REFERENCES Pacientes.Paciente (ID),
	CONSTRAINT FK2Reserva FOREIGN KEY (ID_turno) REFERENCES Gestion.Turno (ID)
)
GO

/*
Los prestadores están conformados por Obras Sociales y Prepagas con las cuales se establece
una alianza comercial. Dicha alianza puede finalizar en cualquier momento, por lo cual debe
poder ser actualizable de forma inmediata si el contrato no está vigente. En caso de no estar
vigente el contrato, deben ser anulados todos los turnos de pacientes que se encuentren
vinculados a esa prestadora y pasar a estado disponible.
*/

CREATE OR ALTER PROCEDURE Gestion.Eliminar_cobertura @id int
AS
BEGIN
IF EXISTS (SELECT 1 FROM Pacientes.Cobertura
		   WHERE ID = @ID)
BEGIN
	WITH CTE (ID_paciente) --ids de los pacientes cuya cobertura finalizó su alianza con el hospital.
	AS
	(
		SELECT P.ID
		FROM Pacientes.Paciente P
		WHERE P.ID_cobertura = @id
	)
	UPDATE Gestion.Turno 
	SET ID_estado_turno = (SELECT E.ID
						   FROM Gestion.Estado_turno E
						   WHERE E.Nombre = 'Disponible')
	WHERE ID IN (SELECT R.ID_turno
				 FROM Gestion.Reserva R
				 WHERE R.ID_paciente IN (SELECT *
										 FROM CTE));
	WITH CTE2 (ID_paciente)
	AS
	(
		SELECT P.ID
		FROM Pacientes.Paciente P
		WHERE P.ID_cobertura = @id
	)
	DELETE FROM Gestion.Reserva
	WHERE ID_paciente IN (SELECT *
						  FROM CTE2)

	UPDATE Pacientes.Paciente
	SET ID_cobertura = NULL
	WHERE ID_cobertura = @id

	DELETE FROM Pacientes.Cobertura
	WHERE ID = @id
	PRINT 'Cobertura eliminada.';
END
ELSE
	PRINT 'Cobertura no existente.'

END

GO

/*
Se requiere que importe toda la información antes mencionada a la base de datos. Genere los
objetos necesarios (store procedures, funciones, etc.) para importar los archivos antes
mencionados. Tenga en cuenta que cada mes se recibirán archivos de novedades con la misma
estructura pero datos nuevos para agregar a cada maestro. Considere este comportamiento al
generar el código. Debe admitir la importación de novedades periódicamente.
La estructura/esquema de las tablas a generar será decisión suya. Puede que deba realizar
procesos de transformación sobre los maestros recibidos para adaptarlos a la estructura
requerida.
Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal cargados,
incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones en el fuente SQL.
(Sería una excepción si el archivo está malformado y no es posible interpretarlo como JSON o
CSV). Documente las correcciones que haga indicando número de línea, contenido previo y
contenido nuevo. Esto se cotejará para constatar que cumpla correctamente la consigna.
*/

CREATE OR ALTER PROCEDURE Gestion.Importar_medicos @filepath varchar(max)
AS
BEGIN
DECLARE @SQL nvarchar(max)
CREATE TABLE #Temporal
(
	nombre varchar(30),
	apellido varchar(30),
	especialidad varchar(30),
	nro_colegiado int
)
SET @SQL= '
BULK INSERT #Temporal
FROM ''' + @filepath + '''
WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n''
	 )'
EXEC sp_executesql @SQL
INSERT INTO Medicos.Especialidad --agregamos las especialidades nuevas a la tabla de especialidades.
SELECT DISTINCT T.especialidad
FROM #Temporal T
WHERE T.especialidad NOT IN (SELECT E.Nombre
							 FROM Medicos.Especialidad E)

INSERT INTO Medicos.Medico --agregamos los nuevos médicos.
SELECT T.nombre,T.apellido,T.nro_colegiado,E.ID
FROM #Temporal T JOIN Medicos.Especialidad E ON T.especialidad LIKE E.Nombre
WHERE T.nro_colegiado NOT IN (SELECT M.Nro_matricula
							  FROM Medicos.Medico M)

DROP TABLE #Temporal
END
GO

CREATE OR ALTER PROCEDURE Gestion.Importar_pacientes @filepath varchar(max)
AS
BEGIN
DECLARE @SQL nvarchar(max)
CREATE TABLE #Temporal
(
	nombre varchar(80),
	apellido varchar(30),
	fecha_nac varchar(20),
	tipo_doc varchar(30),
	nro_doc int,
	sexo varchar(10),
	genero varchar(20),
	tel_fijo char(14),
	nacionalidad varchar(30),
	mail varchar(30),
	direccion varchar(80),
	localidad varchar(40),
	provincia varchar(40)
)
SET @SQL= '
BULK INSERT #Temporal
FROM ''' + @filepath + '''
WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n''
	 )'
EXEC sp_executesql @SQL

INSERT INTO Pacientes.Domicilio (Calle, Localidad, Provincia) --ingreso domicilios.
SELECT DISTINCT T.direccion, T.localidad, T.provincia
FROM #Temporal T

INSERT INTO Pacientes.Paciente (Nombre,Apellido,Fecha_nac,Tipo_doc,Nro_doc,Sexo,Genero,Tel_fijo,Nacionalidad,Mail,ID_domicilio)
SELECT T.nombre, T.apellido, CONVERT(date,T.fecha_nac,103), T.tipo_doc, T.nro_doc, T.sexo, T.genero, T.tel_fijo, T.nacionalidad, T.mail, D.ID
FROM #Temporal T JOIN Pacientes.Domicilio D ON (T.direccion LIKE D.Calle AND T.localidad LIKE D.Localidad AND T.provincia LIKE D.Provincia)
WHERE NOT EXISTS (SELECT *
				  FROM Pacientes.Paciente P
				  WHERE P.Tipo_doc = T.tipo_doc AND P.Nro_doc = T.nro_doc)
--Tuvimos que adaptar la fecha del CSV que estaba en formato DD/MM/YYYY a la de nuestra base de datos que es YYYY-MM-DD.

DROP TABLE #Temporal
END
GO

CREATE OR ALTER PROCEDURE Gestion.Importar_prestadores @filepath varchar(max)
AS
BEGIN
DECLARE @SQL nvarchar(max)
CREATE TABLE #Temporal
(
	nombre varchar(80),
	nombre_plan varchar(80)
)
SET @SQL= '
BULK INSERT #Temporal
FROM ''' + @filepath + '''
WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n''
	 )'
EXEC sp_executesql @SQL

INSERT INTO Pacientes.Prestador --agregamos los prestadores nuevos a la tabla de prestadores.
SELECT DISTINCT T.nombre, T.nombre_plan
FROM #Temporal T
WHERE T.nombre + T.nombre_plan NOT IN (SELECT P.Nombre + P.nombre_plan
									   FROM Pacientes.Prestador P)
DROP TABLE #Temporal

END
GO 

CREATE OR ALTER PROCEDURE Gestion.Importar_sedes @filepath varchar(max)
AS
BEGIN
DECLARE @SQL nvarchar(max)
CREATE TABLE #Temporal
(
	nombre varchar(80),
	direccion varchar(80),
	localidad varchar(80),
	provincia varchar(80)
)
SET @SQL= '
BULK INSERT #Temporal
FROM ''' + @filepath + '''
WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n''
	 )'
EXEC sp_executesql @SQL

INSERT INTO Hospital.Sede --agregamos las sedes nuevas a la tabla de sedes.
SELECT DISTINCT T.nombre, T.direccion + ',' + T.localidad + ' (' + T.provincia + ')'
FROM #Temporal T
WHERE T.nombre NOT IN (SELECT S.Nombre
					   FROM Hospital.Sede S)

END
GO

CREATE OR ALTER PROCEDURE Gestion.Importar_estudios @filepath varchar(max)
AS
BEGIN
DECLARE @SQL nvarchar(max)
CREATE TABLE #Temporal
(
	Area varchar(50),
	Nombre varchar(80),
	Prestador varchar(50),
	Nombre_plan varchar(50),
	Porcentaje_cobertura int,
	Costo int,
	Autorizado bit, --1 SI, 0 NO
)

SET @SQL= '
INSERT INTO #Temporal (Area, Nombre, Prestador, Nombre_plan, Porcentaje_cobertura, Costo, Autorizado)
SELECT Area, Nombre, Prestador, Nombre_plan, Porcentaje_cobertura, Costo, Autorizado
FROM OPENROWSET (BULK '''+ @filepath +''', SINGLE_CLOB) AS JsonFile
CROSS APPLY OPENJSON(JsonFile.BulkColumn)
WITH (
		Area varchar(50) ''$."Area"'',
		Nombre varchar(80) ''$."Estudio"'',
		Prestador varchar(50) ''$."Prestador"'',
		Nombre_plan varchar(50) ''$."Plan"'',
		Porcentaje_cobertura int ''$."Porcentaje Cobertura"'',
		Costo int ''$."Costo"'',
		Autorizado bit ''$."Requiere autorizacion"''
	)'
EXEC sp_executesql @SQL

INSERT INTO Gestion.Estudio --agregamos los estudios nuevos a la tabla de estudios.
SELECT DISTINCT T.Area, T.Nombre, T.Prestador, T.Nombre_plan, T.Porcentaje_cobertura, T.Costo, T.Autorizado
FROM #Temporal T
WHERE NOT EXISTS (SELECT 1
				  FROM Gestion.Estudio E
				  WHERE E.Area = T.Area AND E.Nombre = T.Nombre AND E.Prestador = T.Prestador AND E.Nombre_plan = T.Nombre_plan)
AND T.Nombre IS NOT NULL
AND T.Area IS NOT NULL

DROP TABLE #Temporal

END
GO  

/*
Adicionalmente se requiere que el sistema sea capaz de generar un archivo XML detallando los
turnos atendidos para informar a la Obra Social. El mismo debe constar de los datos del paciente
(Apellido, nombre, DNI), nombre y matrícula del profesional que lo atendió, fecha, hora,
especialidad. Los parámetros de entrada son el nombre de la obra social y un intervalo de fechas.
*/

CREATE OR ALTER FUNCTION Gestion.Turnos_atendidos (@obra_social varchar(80), @fecha_inicio date, @fecha_fin date)
RETURNS varchar(max)
AS
BEGIN
DECLARE @xml varchar(max)

SET @xml=(SELECT P.Apellido, P.Nombre nombre_paciente, P.Nro_doc, M.Nombre nombre_medico, M.Nro_matricula, T.Fecha, T.Hora, E.Nombre
		  FROM Gestion.Turno T JOIN Gestion.Reserva R ON R.ID_turno = T.ID
								JOIN Pacientes.Paciente P ON P.ID = R.ID_paciente
								JOIN Pacientes.Cobertura C ON C.ID = P.ID_cobertura
								JOIN Pacientes.Prestador Pr ON Pr.ID = C.ID_Prestador
								JOIN Medicos.Medico M ON M.ID = T.ID_medico
								JOIN Medicos.Especialidad E ON E.ID = M.ID_especialidad
								JOIN Gestion.Estado_turno ET ON ET.ID=T.ID_estado_turno
		  WHERE Pr.Nombre LIKE @obra_social
		  AND T.Fecha BETWEEN @fecha_inicio AND @fecha_fin
		  AND ET.Nombre LIKE 'Atendido'
		  FOR xml RAW ('Turno'), ELEMENTS XSINIL)
RETURN @xml
END
GO

--------------------------------------------------------------------------------------------------------------
/*
Genere store procedures para manejar la inserción, modificado, borrado
(si corresponde, también debe decidir si determinadas entidades solo
admitirán borrado lógico) de cada tabla.
*/
--------------------------------------------------------------------------------------------------------------

--PROCEDURES DE TABLAS DEL ESQUEMA MEDICOS--

---PARA INSERTAR MEDICOS 

CREATE OR ALTER PROCEDURE Gestion.Insertar_Medico
    @Nombre varchar(20),
    @Apellido varchar(20),
    @NroMatricula int,
    @IDEspecialidad int
AS
BEGIN
    INSERT INTO Medicos.Medico (Nombre, Apellido, Nro_matricula, ID_especialidad)
    VALUES (@Nombre, @Apellido, @NroMatricula, @IDEspecialidad)
END
GO


--- PARA ACTUALIZAR MEDICOS 

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Medico @ID int,
												    @Nombre varchar(20),
												    @Apellido varchar(20),
												    @Nro_matricula int,
												    @ID_especialidad int
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Nombre IS NOT NULL
		BEGIN
			UPDATE Medicos.Medico
			SET Nombre = @Nombre
			WHERE ID = @ID
		END
		IF @Apellido IS NOT NULL
		BEGIN
			UPDATE Medicos.Medico
			SET Apellido = @Apellido
			WHERE ID = @ID
		END
		IF @Nro_matricula IS NOT NULL
		BEGIN
			UPDATE Medicos.Medico
			SET Nro_matricula = @Nro_matricula
			WHERE ID = @ID
		END
		IF @ID_especialidad IS NOT NULL
		BEGIN
			UPDATE Medicos.Medico
			SET ID_especialidad = @ID_especialidad
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

---PARA ELIMINAR MEDICOS

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Medico
    @ID int
AS
BEGIN
    DELETE FROM Medicos.Medico
    WHERE ID = @ID
END
GO

-----------------------------------------------------------------------------------------

---PARA INSERTAR ESPECIALIDADES 

CREATE OR ALTER PROCEDURE Gestion.Insertar_Especialidad
    @Nombre varchar(30)
AS
BEGIN
    INSERT INTO Medicos.Especialidad (Nombre)
    VALUES (@Nombre)
END
GO

---PARA ACTUALIZARLAS

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Especialidad @ID int,
												   		  @Nombre varchar(30)												
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Nombre IS NOT NULL
		BEGIN
			UPDATE Medicos.Especialidad
			SET Nombre = @Nombre
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

---PARA ELIMINAR UNA ESPECIALIDAD 

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Especialidad
    @ID int
AS
BEGIN
    DELETE FROM Medicos.Especialidad
    WHERE ID = @ID
END
GO

--PROCEDURES DE TABLAS DEL ESQUEMA HOSPITAL--

--PARA INSERTAR SEDE

CREATE OR ALTER PROCEDURE Gestion.Insertar_Sede
    @Nombre varchar(20),
    @Direccion varchar(max)
AS
BEGIN
    INSERT INTO Hospital.Sede (Nombre, Direccion)
    VALUES (@Nombre, @Direccion)
END
GO

--PARA ACTUALIZAR SEDE

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Sede @ID int,
												  @Nombre varchar(20),
												  @Direccion varchar(max)
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Nombre IS NOT NULL
		BEGIN
			UPDATE Hospital.Sede
			SET Nombre = @Nombre
			WHERE ID = @ID
		END
		IF @Direccion IS NOT NULL
		BEGIN
			UPDATE Hospital.Sede
			SET Direccion = @Direccion
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINAR SEDE

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Sede
    @ID int
AS
BEGIN
    DELETE FROM Hospital.Sede
    WHERE ID = @ID
END
GO

----PROCEDURES DE TABLAS DEL ESQUEMA GESTION--

--PARA INSERTAR DIAS POR SEDE

CREATE OR ALTER PROCEDURE Gestion.Insertar_Dias_Por_Sede
    @IDSede int,
    @IDMedico int,
    @Dia varchar(15),
    @HoraInicio time
AS
BEGIN
    INSERT INTO Gestion.Dias_por_sede (ID_sede, ID_medico, Dia, Hora_inicio)
    VALUES (@IDSede, @IDMedico, @Dia, @HoraInicio)
END
GO

--PARA ACTUALIZAR DIAS POR SEDE

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Dias_por_sede @ID_sede int,
												 		   @ID_medico int,
												   	 	   @Dia varchar(15),
												   		   @Hora_inicio time
AS
BEGIN
	IF @ID_sede IS NOT NULL AND @ID_medico IS NOT NULL
	BEGIN
		IF @Dia IS NOT NULL
		BEGIN
			UPDATE Gestion.Dias_por_sede
			SET Dia = @Dia
			WHERE ID_sede = @ID_sede
			AND ID_medico = @ID_medico
		END
		IF @Hora_inicio IS NOT NULL
		BEGIN
			UPDATE Gestion.Dias_por_sede
			SET Hora_inicio = @Hora_inicio
			WHERE ID_sede = @ID_sede
			AND ID_medico = @ID_medico
		END
	END
	ELSE
		PRINT 'Ingrese como primer y segundo parámetro los ID de sede y médico de la fila que desea actualizar.'
END
GO

--PARA ELIMINAR DIAS POR SEDE

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Dias_Por_Sede
    @IDSede int,
    @IDMedico int,
    @Dia varchar(15)
AS
BEGIN
    DELETE FROM Gestion.Dias_por_sede
    WHERE ID_sede = @IDSede AND ID_medico = @IDMedico AND Dia = @Dia
END
GO

---------------------------------------------------------------------------------------------

--PARA INSERTAR TURNO

CREATE OR ALTER PROCEDURE Gestion.Insertar_Turno
    @Fecha date,
    @Hora time,
    @IDMedico int,
    @IDSede int,
    @IDEstadoTurno int,
    @IDTipoTurno int
AS
BEGIN
    INSERT INTO Gestion.Turno (Fecha, Hora, ID_medico, ID_sede, ID_estado_turno, ID_tipo_turno)
    VALUES (@Fecha, @Hora, @IDMedico, @IDSede, @IDEstadoTurno, @IDTipoTurno)
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Turno @ID int,
												   @Fecha date,
												   @Hora time,
												   @ID_medico int,
												   @ID_sede int,
												   @ID_estado_turno int,
												   @ID_tipo_turno int
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Fecha IS NOT NULL
		BEGIN
			UPDATE Gestion.Turno
			SET Fecha = @Fecha
			WHERE ID = @ID
		END
		IF @Hora IS NOT NULL
		BEGIN
			UPDATE Gestion.Turno
			SET Hora = @Hora
			WHERE ID = @ID
		END
		IF @ID_medico IS NOT NULL
		BEGIN
			UPDATE Gestion.Turno
			SET ID_medico = @ID_medico
			WHERE ID = @ID
		END
		IF @ID_sede IS NOT NULL
		BEGIN
			UPDATE Gestion.Turno
			SET ID_sede = @ID_sede
			WHERE ID = @ID
		END
		IF @ID_estado_turno IS NOT NULL
		BEGIN
			UPDATE Gestion.Turno
			SET ID_estado_turno = @ID_estado_turno
			WHERE ID = @ID
		END
		IF @ID_tipo_turno IS NOT NULL
		BEGIN
			UPDATE Gestion.Turno
			SET ID_tipo_turno = @ID_tipo_turno
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Turno
    @IDTurno int
AS
BEGIN
    UPDATE Gestion.Turno
    SET ID_estado_turno = (SELECT E.ID
						   FROM Gestion.Estado_turno E
						   WHERE E.Nombre = 'Cancelado')
    WHERE ID = @IDTurno
END
GO

--------------------------------------------------------------------------------------------

--INSERTAR ESTADO DE TURNO

CREATE OR ALTER PROCEDURE Gestion.Insertar_Estado_Turno
    @Nombre varchar(10)
AS
BEGIN
    INSERT INTO Gestion.Estado_turno (Nombre)
    VALUES (@Nombre)
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Estado_turno @ID int,
												   		  @Nombre varchar(10)												
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Nombre IS NOT NULL
		BEGIN
			UPDATE Gestion.Estado_turno
			SET Nombre = @Nombre
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Estado_turno
    @ID int
AS
BEGIN
    DELETE FROM Gestion.Estado_turno
    WHERE ID = @ID
END
GO

--INSERTAR ESTUDIO

CREATE OR ALTER PROCEDURE Gestion.Insertar_Estudio	 @Area varchar(50),
												   	 @Nombre varchar(80),
												   	 @Prestador varchar(50),
												   	 @Nombre_plan varchar(50),
												   	 @Porcentaje_cobertura int,
												   	 @Costo int,
												   	 @Autorizado bit
AS
BEGIN
    INSERT INTO Gestion.Estudio
    VALUES (@Area,@Nombre,@Prestador,@Nombre_plan,@Porcentaje_cobertura,@Costo,@Autorizado)
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Estudio @ID int,
												   	 @Area varchar(50),
												   	 @Nombre varchar(80),
												   	 @Prestador varchar(50),
												   	 @Nombre_plan varchar(50),
												   	 @Porcentaje_cobertura int,
												   	 @Costo int,
												   	 @Autorizado bit
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Area IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio
			SET Area = @Area
			WHERE ID = @ID
		END
		IF @Nombre IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio
			SET Nombre = @Nombre
			WHERE ID = @ID
		END
		IF @Prestador IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio
			SET Prestador = @Prestador
			WHERE ID = @ID
		END
		IF @Nombre_plan IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio
			SET Nombre_plan = @Nombre_plan
			WHERE ID = @ID
		END
		IF @Porcentaje_cobertura IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio
			SET Porcentaje_cobertura = @Porcentaje_cobertura
			WHERE ID = @ID
		END
		IF @Costo IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio
			SET Costo = @Costo
			WHERE ID = @ID
		END
		IF @Autorizado IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio
			SET Autorizado = @Autorizado
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Estudio
    @ID int
AS
BEGIN
    DELETE FROM Gestion.Estudio
    WHERE ID = @ID
END
GO

--INSERTAR ESTUDIO POR PACIENTE

CREATE OR ALTER PROCEDURE Gestion.Insertar_Estudio_por_paciente @ID_estudio int,
												 		   		@ID_paciente int,
												   	 	   		@fecha date,
												   		   		@Documento_resultado varchar(max),
												   		   		@Imagen_resultado varchar(max)
AS
BEGIN
    INSERT INTO Gestion.Estudio_por_paciente
    VALUES (@ID_estudio,@ID_paciente,@fecha,@Documento_resultado,@Imagen_resultado)
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Estudio_por_paciente @ID_estudio int,
												 		   		  @ID_paciente int,
												   	 	   		  @fecha date,
												   		   		  @Documento_resultado varchar(max),
												   		   		  @Imagen_resultado varchar(max)
AS
BEGIN
	IF @ID_estudio IS NOT NULL AND @ID_paciente IS NOT NULL
	BEGIN
		IF @fecha IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio_por_paciente
			SET fecha = @fecha
			WHERE ID_estudio = @ID_estudio
			AND ID_paciente = @ID_paciente
		END
		IF @Documento_resultado IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio_por_paciente
			SET Documento_resultado = @Documento_resultado
			WHERE ID_estudio = @ID_estudio
			AND ID_paciente = @ID_paciente
		END
		IF @Imagen_resultado IS NOT NULL
		BEGIN
			UPDATE Gestion.Estudio_por_paciente
			SET Imagen_resultado = @Imagen_resultado
			WHERE ID_estudio = @ID_estudio
			AND ID_paciente = @ID_paciente
		END
	END
	ELSE
		PRINT 'Ingrese como primer y segundo parámetro los ID de estudio y paciente de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Estudio_por_paciente
    @ID_estudio int, @ID_paciente int
AS
BEGIN
    DELETE FROM Gestion.Estudio_por_paciente
    WHERE ID_estudio = @ID_estudio
    AND ID_paciente = @ID_paciente
END
GO

--INSERTAR TIPO DE TURNO

CREATE OR ALTER PROCEDURE Gestion.Insertar_Tipo_Turno
    @Nombre varchar(10)
AS
BEGIN
    INSERT INTO Gestion.Tipo_turno (Nombre)
    VALUES (@Nombre)
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Tipo_turno @ID int,
												   		@Nombre varchar(10)												
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Nombre IS NOT NULL
		BEGIN
			UPDATE Gestion.Tipo_turno
			SET Nombre = @Nombre
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Tipo_turno
    @ID int
AS
BEGIN
    DELETE FROM Gestion.Tipo_turno
    WHERE ID = @ID
END
GO

--PARA INSERTAR RESERVA

CREATE OR ALTER PROCEDURE Gestion.Insertar_Reserva
    @ID_paciente int, @ID_turno int
AS
BEGIN
    INSERT INTO Gestion.Reserva (ID_paciente,ID_turno)
    VALUES (@ID_paciente,@ID_turno)
END
GO

--Para la tabla Gestion.Reserva no tiene sentido el procedure de actualización ya que solo posee la PK. Simplemente se elimina la fila y se inserta la nueva deseada.

--PARA ELIMINARLA

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Reserva
    @ID_paciente int, @ID_turno int
AS
BEGIN
    DELETE FROM Gestion.Reserva
    WHERE ID_paciente = @ID_paciente
    AND ID_turno = @ID_turno
END
GO

----PROCEDURES DE TABLAS DEL ESQUEMA PACIENTES----

--PARA INSERTAR PACIENTE

CREATE OR ALTER PROCEDURE Gestion.Insertar_Paciente
    @Nombre varchar(80),
    @Apellido varchar(80),
    @ApellidoMaterno varchar(20),
    @FechaNac date,
    @TipoDoc varchar(20),
    @NroDoc int,
    @Sexo char(9),
    @Genero varchar(15),
    @Nacionalidad varchar(20),
    @FotoPerfil varchar(max),
    @Mail varchar(30),
    @TelFijo char(14),
    @TelAlternativo int,
    @TelLaboral int,
    @FechaRegistro date,
    @FechaActualizacion date,
    @UsuarioActualizacion int,
    @IDDomicilio int,
    @IDCobertura int
AS
BEGIN
    INSERT INTO Pacientes.Paciente (
        Nombre, Apellido, Apellido_materno, Fecha_nac, Tipo_doc, Nro_doc,
        Sexo, Genero, Nacionalidad, Foto_perfil, Mail, Tel_fijo, Tel_alternativo,
        Tel_laboral, Fecha_registro, Fecha_actualizacion, Usuario_actualizacion,
        ID_domicilio, ID_cobertura
    )
    VALUES (
        @Nombre, @Apellido, @ApellidoMaterno, @FechaNac, @TipoDoc, @NroDoc,
        @Sexo, @Genero, @Nacionalidad, @FotoPerfil, @Mail, @TelFijo, @TelAlternativo,
        @TelLaboral, @FechaRegistro, @FechaActualizacion, @UsuarioActualizacion,
        @IDDomicilio, @IDCobertura
    )
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Paciente @ID int,
												   	  @Nombre varchar(80),
												   	  @Apellido varchar(80),
												   	  @Apellido_materno varchar(20),
												   	  @Fecha_nac date,
												   	  @Tipo_doc varchar(20),
												   	  @Nro_doc int,
												   	  @Sexo char(9),
												   	  @Genero varchar (15),
												   	  @Nacionalidad varchar(20),
												   	  @Foto_perfil varchar(max),
												   	  @Mail varchar(30),
												   	  @Tel_fijo char(14),
												   	  @Tel_alternativo int,
												   	  @Tel_laboral int,
												   	  @Fecha_registro date,
												   	  @Fecha_actualizacion date,
												   	  @Usuario_actualizacion int,
												   	  @ID_domicilio int,
												   	  @ID_cobertura int
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Nombre IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Nombre = @Nombre
			WHERE ID = @ID
		END
		IF @Apellido IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Apellido = @Apellido
			WHERE ID = @ID
		END
		IF @Apellido_materno IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Apellido_materno = @Apellido_materno
			WHERE ID = @ID
		END
		IF @Fecha_nac IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Fecha_nac = @Fecha_nac
			WHERE ID = @ID
		END
		IF @Tipo_doc IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Tipo_doc = @Tipo_doc
			WHERE ID = @ID
		END
		IF @Nro_doc IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Nro_doc = @Nro_doc
			WHERE ID = @ID
		END
		IF @Sexo IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Sexo = @Sexo
			WHERE ID = @ID
		END
		IF @Genero IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Genero = @Genero
			WHERE ID = @ID
		END
		IF @Nacionalidad IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Nacionalidad = @Nacionalidad
			WHERE ID = @ID
		END
		IF @Foto_perfil IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Foto_perfil = @Foto_perfil
			WHERE ID = @ID
		END
		IF @Mail IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Mail = @Mail
			WHERE ID = @ID
		END
		IF @Tel_fijo IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Tel_fijo = @Tel_fijo
			WHERE ID = @ID
		END
		IF @Tel_alternativo IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Tel_alternativo = @Tel_alternativo
			WHERE ID = @ID
		END
		IF @Tel_laboral IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Tel_laboral = @Tel_laboral
			WHERE ID = @ID
		END
		IF @Fecha_registro IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Fecha_registro = @Fecha_registro
			WHERE ID = @ID
		END
		IF @Fecha_actualizacion IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Fecha_actualizacion = @Fecha_actualizacion
			WHERE ID = @ID
		END
		IF @Usuario_actualizacion IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET Usuario_actualizacion = @Usuario_actualizacion
			WHERE ID = @ID
		END
		IF @ID_domicilio IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET ID_domicilio = @ID_domicilio
			WHERE ID = @ID
		END
		IF @ID_cobertura IS NOT NULL
		BEGIN
			UPDATE Pacientes.Paciente
			SET ID_cobertura = @ID_cobertura
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Paciente
    @IDPaciente int
AS
BEGIN
    DELETE FROM Pacientes.Paciente
    WHERE ID = @IDPaciente
END
GO

--PARA INSERTAR USUARIO

CREATE OR ALTER PROCEDURE Gestion.Insertar_Usuario
    @Contraseña varchar(30)
AS
BEGIN
    INSERT INTO Pacientes.Usuario (Contraseña)
    VALUES (@Contraseña)
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Usuario @ID int,
												  	 @Contraseña varchar(30),
												  	 @Fecha_creacion date
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Contraseña IS NOT NULL
		BEGIN
			UPDATE Pacientes.Usuario
			SET Contraseña = @Contraseña
			WHERE ID = @ID
		END
		IF @Fecha_creacion IS NOT NULL
		BEGIN
			UPDATE Pacientes.Usuario
			SET Fecha_creacion = @Fecha_creacion
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Usuario
    @ID int
AS
BEGIN
    DELETE FROM Pacientes.Usuario
    WHERE ID = @ID
END
GO

-----------------------------------------------------------------------------------------
--PARA INSERTAR DOMICILIO

CREATE OR ALTER PROCEDURE Gestion.Insertar_Domicilio
    @Calle varchar(80),
    @Numero int,
    @Piso varchar(20),
    @Departamento varchar(10),
    @CodPostal int,
    @Pais varchar(30),
    @Provincia varchar(40),
    @Localidad varchar(40)
AS
BEGIN
    INSERT INTO Pacientes.Domicilio (Calle, Numero, Piso, Departamento, Cod_postal, Pais, Provincia, Localidad)
    VALUES (@Calle, @Numero, @Piso, @Departamento, @CodPostal, @Pais, @Provincia, @Localidad)
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Domicilio @ID int,
												   	   @Calle varchar(80),
												   	   @Numero int,
												   	   @Piso varchar(20),
												   	   @Departamento varchar(10),
												   	   @Cod_postal int,
												   	   @Pais varchar(30),
												   	   @Provincia varchar(40),
												   	   @Localidad varchar(40)
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Calle IS NOT NULL
		BEGIN
			UPDATE Pacientes.Domicilio
			SET Calle = @Calle
			WHERE ID = @ID
		END
		IF @Numero IS NOT NULL
		BEGIN
			UPDATE Pacientes.Domicilio
			SET Numero = @Numero
			WHERE ID = @ID
		END
		IF @Piso IS NOT NULL
		BEGIN
			UPDATE Pacientes.Domicilio
			SET Piso = @Piso
			WHERE ID = @ID
		END
		IF @Departamento IS NOT NULL
		BEGIN
			UPDATE Pacientes.Domicilio
			SET Departamento = @Departamento
			WHERE ID = @ID
		END
		IF @Cod_postal IS NOT NULL
		BEGIN
			UPDATE Pacientes.Domicilio
			SET Cod_postal = @Cod_postal
			WHERE ID = @ID
		END
		IF @Pais IS NOT NULL
		BEGIN
			UPDATE Pacientes.Domicilio
			SET Pais = @Pais
			WHERE ID = @ID
		END
		IF @Provincia IS NOT NULL
		BEGIN
			UPDATE Pacientes.Domicilio
			SET Provincia = @Provincia
			WHERE ID = @ID
		END
		IF @Localidad IS NOT NULL
		BEGIN
			UPDATE Pacientes.Domicilio
			SET Localidad = @Localidad
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Domicilio
    @ID int
AS
BEGIN
    DELETE FROM Pacientes.Domicilio
    WHERE ID = @ID
END
GO

----------------------------------------------------------------------------------------

--PARA INSERTAR PRESTADOR
CREATE OR ALTER PROCEDURE Gestion.Insertar_Prestador
    @Nombre varchar(30),
    @NombrePlan varchar(30)
AS
BEGIN
    INSERT INTO Pacientes.Prestador (Nombre, nombre_plan)
    VALUES (@Nombre, @NombrePlan)
END
GO

--PARA ACTUALIZARLO

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Prestador @ID int,
												  	   @Nombre varchar(30),
												  	   @nombre_plan varchar(30)
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Nombre IS NOT NULL
		BEGIN
			UPDATE Pacientes.Prestador
			SET Nombre = @Nombre
			WHERE ID = @ID
		END
		IF @nombre_plan IS NOT NULL
		BEGIN
			UPDATE Pacientes.Prestador
			SET nombre_plan = @nombre_plan
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLO

CREATE OR ALTER PROCEDURE Gestion.Eliminar_Prestador
    @ID int
AS
BEGIN
    DELETE FROM Pacientes.Prestador
    WHERE ID = @ID
END
GO

-------------------------------------------------------------------------------------------

--PARA INSERTAR COBERTURA

CREATE OR ALTER PROCEDURE Gestion.Insertar_Cobertura
    @ImagenCredencial varchar(max),
    @NroSocio int,
    @FechaRegistro date,
    @IDPrestador int
AS
BEGIN
    INSERT INTO Pacientes.Cobertura (Imagen_credencial, Nro_socio, Fecha_registro, ID_Prestador)
    VALUES (@ImagenCredencial, @NroSocio, @FechaRegistro, @IDPrestador)
END
GO

--PARA ACTUALIZARLA

CREATE OR ALTER PROCEDURE Gestion.Actualizar_Cobertura @ID int,
												   	   @Imagen_credencial varchar(max),
												   	   @Nro_socio int,
												  	   @Fecha_registro date,
												   	   @ID_Prestador int
AS
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF @Imagen_credencial IS NOT NULL
		BEGIN
			UPDATE Pacientes.Cobertura
			SET Imagen_credencial = @Imagen_credencial
			WHERE ID = @ID
		END
		IF @Nro_socio IS NOT NULL
		BEGIN
			UPDATE Pacientes.Cobertura
			SET Nro_socio = @Nro_socio
			WHERE ID = @ID
		END
		IF @Fecha_registro IS NOT NULL
		BEGIN
			UPDATE Pacientes.Cobertura
			SET Fecha_registro = @Fecha_registro
			WHERE ID = @ID
		END
		IF @ID_Prestador IS NOT NULL
		BEGIN
			UPDATE Pacientes.Cobertura
			SET ID_Prestador = @ID_Prestador
			WHERE ID = @ID
		END
	END
	ELSE
		PRINT 'Ingrese como primer parámetro el ID de la fila que desea actualizar.'
END
GO

--PARA ELIMINARLA
--PROCEDURE CREADO ANTERIORMENTE.