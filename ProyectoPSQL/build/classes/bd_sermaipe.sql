-- Database: bd_sermaipe

-- DROP DATABASE bd_sermaipe;

CREATE DATABASE bd_sermaipe
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'Spanish_Spain.1252'
       LC_CTYPE = 'Spanish_Spain.1252'
       CONNECTION LIMIT = -1;

CREATE SCHEMA PERSONA
CREATE SCHEMA INSUMO
CREATE SCHEMA ADMINISTRACION

CREATE TABLE PERSONA.EMPLEADO(
	idEmpleado bigserial NOT NULL,
	nombres varchar(50) NOT NULL,
	apellidoP varchar(15) NOT NULL,
	apellidoM varchar(15) NOT NULL,
	domicilio varchar(60) NOT NULL,
	telefono varchar(7) NOT NULL,
	celular varchar(10) NOT NULL,
	sueldo float NOT NULL,
	
	CONSTRAINT PK_ID_EMPLEADO PRIMARY KEY(idEmpleado)
);

CREATE TABLE PERSONA.CLIENTE(
	idCliente bigserial NOT NULL,
	nombres varchar(50) NOT NULL,
	apellidoP varchar(15) NOT NULL,
	apellidoM varchar(15) NOT NULL,
	domicilio varchar(60) NOT NULL,
	telefono varchar(7) NOT NULL,
	celular varchar(10) NOT NULL,
	credito float NOT NULL,
	
	CONSTRAINT PK_ID_CLIENTE PRIMARY KEY (idCliente)
);


CREATE TABLE PERSONA.PROVEEDOR(
	idProveedor bigserial NOT NULL,
	nombres varchar(50) NOT NULL,
	apellidoP varchar(15) NOT NULL,
	apellidoM varchar(15) NOT NULL,
	domicilio varchar(50) NOT NULL,
	telefono varchar(7) NOT NULL,
	celular varchar(10) NOT NULL,
	email varchar(30) NOT NULL,

	CONSTRAINT PK_ID_PROVEEDOR PRIMARY KEY(idProveedor)
);


CREATE TABLE INSUMO.MATERIAL(
	idMaterial bigserial NOT NULL,
	idProveedor bigint NOT NULL,	
	nombre varchar(40) NOT NULL,
	descripcion varchar(100) NULL,
	stock int NOT NULL,
	precio_compra float NOT NULL,
	precio_venta float NOT NULL,

	CONSTRAINT PK_ID_MATERIAL PRIMARY KEY(idMaterial),
	CONSTRAINT FK_ID_PROVEEDOR FOREIGN KEY(idProveedor) REFERENCES PERSONA.PROVEEDOR(idProveedor)
);


CREATE TABLE ADMINISTRACION.PEDIDO(
	idPedido bigserial NOT NULL,
	idCliente bigint NOT NULL,
	fechaPedido date NOT NULL,
	fechaEntrega date NOT NULL,
	diasParaPagar int NOT NULL,
	total float NOT NULL,
	pagado boolean NOT NULL,

	CONSTRAINT PK_ID_PEDIDO PRIMARY KEY(idPedido),
	CONSTRAINT FK_ID_CLIENTE FOREIGN KEY(idCliente) REFERENCES PERSONA.CLIENTE(idCliente)
);
INSERT INTO PERSONA.CLIENTE(nombres, apellidop, apellidom, domicilio, telefono, celular, credito) VALUES('Luis Gerardo', 'Santos', 'Miranda', 'Pavo Real 212 ', '8098562', '4443189483', 5000)
SELECT * FROM PERSONA.CLIENTE
INSERT INTO ADMINISTRACION.PEDIDO(idCliente, fechaPedido, fechaEntrega, diasParaPagar, total, pagado) VALUES (1, '21/10/2016', '31/10/2016', 10, 2000, false);
SELECT * FROM ADMINISTRACION.PEDIDO

--	Un cliente puede tener varios pedidos, pero si solicita un pedido, 
--	buscará que no tenga ningún pedido:
-- 	Con 'Fecha limite pago' retrasado
--	TRIGGER ( Fecha del sistema - FechaEntrega > diasParaPagar ) 
--	ENTONCES: Dejarle credito negativo (-1) hasta que pague el pedido
CREATE O REPLACE FUNCTION cambiaCredito() RETURNS TRIGGER AS $Trigger_AnulaCredito$
BEGIN
	NEW.credito := -1;
	RETURN NEW;
END;
$Trigger_AnulaCredito$ LANGUAGE plpgsql;
	
CREATE TRIGGER fechaRetrasada
	BEFORE INSERT OR UPDATE ON ADMINISTRACION.PEDIDO
	FOR EACH ROW EXECUTE PROCEDURE cambiaCredito();
	RAISE NOTICE 'Trigger ejecutado, acción = %', TG_OP;
	

--	Un cliente puede pagar su deuda y su 'Credito vuelve a 0'

CREATE TABLE ADMINISTRACION.DETALLE_PEDIDO(
	idPedido bigint NOT NULL,
	idMaterial bigint NULL,
	cantidad int NULL,
	idServicio bigint NULL,
	cargoServicio float NULL,
	subtotal float NULL,
	CONSTRAINT FK_ID_PEDIDO FOREIGN KEY(idPedido) REFERENCES ADMINISTRACION.PEDIDO(idPedido),
	CONSTRAINT FK_ID_MATERIAL FOREIGN KEY(idMaterial) REFERENCES INSUMO.MATERIAL(idMaterial)
);

DROP TABLE ADMINISTRACION.DETALLE_PEDIDO

CREATE TABLE ADMINISTRACION.FACTURA(
	idPedido bigint NOT NULL,
	idEmpleado bigint NOT NULL,
	fecha_factura date NOT NULL,
	total_factura float NOT NULL,
	tipoPago varchar(30) NOT NULL,
	CONSTRAINT PK_FID_PEDIDO PRIMARY KEY(idPedido),
	CONSTRAINT FK_FID_PEDIDO FOREIGN KEY(idPedido) REFERENCES ADMINISTRACION.PEDIDO(idPedido),
	CONSTRAINT FK_FID_EMPLEADO FOREIGN KEY(idEmpleado) REFERENCES PERSONA.EMPLEADO(idEmpleado)
);
--Agregar regla para el campo ADMINISTRACION.FACTURA(tipoPago) para que solo acepte: 'Efectivo','Tarjeta de credito' ... etc
CREATE RULE TIPO_PAGO AS @var IN ('Efectivo','Tarjeta de debito','Tarjeta de credito', 'Cheque', 'Transferencia electronica')
EXEC sp_bindrule 'TIPO_PAGO','ADMINISTRACION.FACTURA.tipoPago'


CREATE TABLE ADMINISTRACION.SERVICIO(
	idServicio bigint IDENTITY(1,1) NOT NULL,
	tipoServicio varchar(15) NOT NULL,
	descripcion varchar(100) NOT NULL,
	costo float NOT NULL,
	
	CONSTRAINT PK_ID_SERVICIO PRIMARY KEY (idServicio)
);
--Agregar regla para el campo ADMINISTRACION.SERVICIO(tipoServicio) para que solo acepte: 'Instalacion','Mantenimiento','Reparacion'
CREATE RULE TIPO_SERVICIO AS @var IN ('Instalacion', 'Mantenimiento', 'Reparacion')
EXEC sp_bindrule 'TIPO_SERVICIO','ADMINISTRACION.SERVICIO.tipoServicio'

CREATE TABLE ADMINISTRACION.SERVICIO_EMPLEADO
(
	idServicio bigint not null,
	idEmpleado bigint not null,
	
	CONSTRAINT FK_P_EMPLEADO FOREIGN KEY(idEmpleado) REFERENCES PERSONA.EMPLEADO(idEmpleado),
	CONSTRAINT FK_P_SERVICIO FOREIGN KEY(idServicio) REFERENCES ADMINISTRACION.SERVICIO(idServicio)
);