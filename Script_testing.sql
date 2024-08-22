USE master
GO

USE CureSA
GO

--TESTING

EXEC Gestion.Importar_medicos 'C:\importar\Medicos.csv'

SELECT *
FROM Medicos.Medico M JOIN Medicos.Especialidad E ON M.ID_especialidad = E.ID 

EXEC Gestion.Importar_pacientes 'C:\importar\Pacientes.csv'

SELECT *
FROM Pacientes.Paciente P JOIN Pacientes.Domicilio D ON P.ID_domicilio = D.ID

EXEC Gestion.Importar_prestadores 'C:\importar\Prestador.csv'

SELECT *
FROM Pacientes.Prestador

EXEC Gestion.Importar_sedes 'C:\importar\Sedes.csv'

SELECT *
FROM Hospital.Sede

EXEC Gestion.Importar_estudios 'C:\importar\Centro_Autorizaciones.Estudios clinicos.json'

SELECT *
FROM Gestion.Estudio

----PRUEBA DE PROCEDURE Eliminar_cobertura----

--Ingresamos coberturas 1 y 2.
/*
INSERT INTO Pacientes.Cobertura (Imagen_credencial,Nro_socio,ID_Prestador)
VALUES (null,1,1),(null,2,2)*/
EXEC Gestion.Insertar_cobertura null,1,null,1
EXEC Gestion.Insertar_cobertura null,2,null,2

SELECT *
from Pacientes.Cobertura
/*
INSERT INTO Gestion.Tipo_turno
VALUES ('Presencial'),('Virtual')*/
EXEC Gestion.Insertar_Tipo_Turno 'Presencial'
EXEC Gestion.Insertar_Tipo_Turno 'Virtual'

SELECT *
from Gestion.Tipo_turno
/*
INSERT INTO Gestion.Estado_turno
VALUES ('Disponible'),('Pendiente'),('Atendido'),('Ausente'),('Cancelado')*/
EXEC Gestion.Insertar_Estado_Turno 'Disponible'
EXEC Gestion.Insertar_Estado_Turno 'Pendiente'
EXEC Gestion.Insertar_Estado_Turno 'Atendido'
EXEC Gestion.Insertar_Estado_Turno 'Ausente'
EXEC Gestion.Insertar_Estado_Turno 'Cancelado'

SELECT *
FROM Gestion.Estado_turno
/*
INSERT INTO Gestion.Dias_por_sede (ID_sede,ID_medico)
VALUES (1,1),(2,2)*/
EXEC Gestion.Insertar_Dias_Por_Sede 1,1,null,null
EXEC Gestion.Insertar_Dias_Por_Sede 2,2,null,null

SELECT *
FROM Gestion.Dias_por_sede

--Ingresamos dos turnos.
/*
INSERT INTO Gestion.Turno (Fecha,ID_medico,ID_sede,ID_estado_turno,ID_tipo_turno)
VALUES ('20231120',1,1,2,1),('20231123',2,2,2,1)*/
EXEC Gestion.Insertar_Turno '20231120',null,1,1,2,1
EXEC Gestion.Insertar_Turno '20231123',null,2,2,2,1

--Vemos que se encuentran pendientes.
SELECT T.*, E.Nombre as Estado
FROM Gestion.Turno T JOIN Gestion.Estado_turno E ON T.ID_estado_turno = E.ID

--Reservamos el primer turno para el paciente 1 y el segundo para el 2.
/*
INSERT INTO Gestion.Reserva
VALUES (1,1),(2,2)*/
EXEC Gestion.Insertar_Reserva 1,1
EXEC Gestion.Insertar_Reserva 2,2

SELECT *
FROM Gestion.Reserva

--Asignamos al paciente 1 la cobertura 1 y al paciente 2 la cobertura 2.
/*
UPDATE Pacientes.Paciente
SET ID_cobertura = 1
WHERE ID = 1*/
EXEC Gestion.Actualizar_Paciente 1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1
/*
UPDATE Pacientes.Paciente
SET ID_cobertura = 2
WHERE ID = 2*/
EXEC Gestion.Actualizar_Paciente 2,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,2

SELECT P.ID,P.Nombre,P.Apellido,C.ID as ID_Cobertura
FROM Pacientes.Paciente P JOIN Pacientes.Cobertura C ON P.ID_cobertura = C.ID

--Eliminamos la cobertura 1.
EXEC Gestion.Eliminar_cobertura 1

--Vemos que se eliminó la cobertura 1.
SELECT *
FROM Pacientes.Cobertura

--Vemos que se eliminó la reserva del turno 1.
SELECT *
FROM Gestion.Reserva

--Vemos que el turno 1 ahora aparece como disponible.
SELECT *
FROM Gestion.Turno T JOIN Gestion.Estado_turno E ON T.ID_estado_turno = E.ID

--Vemos que el paciente 1 que tenía la cobertura 1 ahora no tiene cobertura.
SELECT *
FROM Pacientes.Paciente
WHERE ID = 1

--Vemos que si quisiéramos eliminar la cobertura 1 denuevo no se podría.
EXEC Gestion.Eliminar_cobertura 1

------------------------------------------------------------------------------------------

----PRUEBA DE FUNCIÓN Turnos_atendidos----

--Insertamos turnos atendidos
/*INSERT INTO Gestion.Turno (Fecha,ID_medico,ID_sede,ID_estado_turno,ID_tipo_turno)
VALUES ('20110626',1,1,3,1),('20221218',2,2,3,1)*/
EXEC Gestion.Insertar_Turno '20110626',null,1,1,3,1
EXEC Gestion.Insertar_Turno '20221218',null,2,2,3,1

SELECT *
FROM Gestion.Turno T JOIN Gestion.Estado_turno E ON T.ID_estado_turno = E.ID

--Asignamos la cobertura 2 (cuyo prestador es el 2, Medicus con plan Celeste) a los pacientes 10 y 20
/*
UPDATE Pacientes.Paciente
SET ID_cobertura = 2
WHERE ID = 10

UPDATE Pacientes.Paciente
SET ID_cobertura = 2
WHERE ID = 20*/
EXEC Gestion.Actualizar_Paciente 10,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,2
EXEC Gestion.Actualizar_Paciente 20,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,2

--Reservamos los turnos 3 y 4 para los pacientes 10 y 20 respectivamente.
/*
INSERT INTO Gestion.Reserva
VALUES (10,3),(20,4)*/
EXEC Gestion.Insertar_Reserva 10,3
EXEC Gestion.Insertar_Reserva 20,4

--Generamos XML de los turnos atendidos para el prestador 2 "Medicus" entre las fechas pasadas por parámetro.

SELECT Gestion.Turnos_atendidos('Medicus','20110625','20221219')
/*
<Turno xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<Apellido>Figueroa</Apellido>
	<nombre_paciente>Rosario Paz </nombre_paciente>
	<Nro_doc>28321022</Nro_doc>
	<nombre_medico>Dr. BEVACQUA</nombre_medico>
	<Nro_matricula>119918</Nro_matricula>
	<Fecha>2011-06-26</Fecha>
	<Hora xsi:nil="true"/>
	<Nombre>ALERGIA</Nombre>
</Turno>
	<Turno xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<Apellido>Borrell</Apellido>
	<nombre_paciente>Araceli </nombre_paciente>
	<Nro_doc>30148246</Nro_doc>
	<nombre_medico>Dr. BELZITI</nombre_medico>
	<Nro_matricula>119919</Nro_matricula>
	<Fecha>2022-12-18</Fecha>
	<Hora xsi:nil="true"/>
	<Nombre>CARDIOLOGIA</Nombre>
</Turno>
*/

--Vemos que con las siguientes fechas solo debería mostrar el primero:
SELECT Gestion.Turnos_atendidos('Medicus','20110625','20120101')

/*
<Turno xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<Apellido>Figueroa</Apellido>
	<nombre_paciente>Rosario Paz </nombre_paciente>
	<Nro_doc>28321022</Nro_doc>
	<nombre_medico>Dr. BEVACQUA</nombre_medico>
	<Nro_matricula>119918</Nro_matricula>
	<Fecha>2011-06-26</Fecha>
	<Hora xsi:nil="true"/>
	<Nombre>ALERGIA</Nombre>
</Turno>
*/

--Vemos que con las siguientes fechas no debería mostrar ninguno:
SELECT Gestion.Turnos_atendidos('Medicus','20100101','20100102')

--Vemos que para el prestador "Prueba" no hay turnos atendidos:
SELECT Gestion.Turnos_atendidos('Prueba','20110625','20221219')
