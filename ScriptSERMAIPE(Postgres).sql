CREATE SCHEMA PERSONA;
CREATE SCHEMA INSUMO;
CREATE SCHEMA ADMINISTRACION;
---------------------------------------------------------
CREATE TABLE PERSONA.CLIENTE
(
	idCliente bigserial not null,
	nombres varchar(80) not null,
	apellidoP varchar(50) not null,
	apellidoM varchar(50) not null,
	domicilio varchar(200) not null,
	telefono varchar(7) not null,
	celular varchar(10) not null,
	credito decimal not null,
	CONSTRAINT PK_IDCLIENTE Primary Key(idCliente)
);
CREATE TABLE PERSONA.EMPLEADO
(
	idEmpleado bigserial not null,
	nombres varchar(80) not null,
	apellidoP varchar(50) not null,
	apellidoM varchar(50) not null,
	domicilio varchar(200) not null,
	telefono varchar(7) not null,
	celular varchar(10) not null,
	sueldo decimal not null,
	CONSTRAINT PK_IDEMPLEADO Primary Key(idEmpleado)
);
CREATE TABLE PERSONA.PROVEEDOR
(
	idProveedor bigserial not null,
	nombres varchar(80) not null,
	apellidoP varchar(50) not null,
	apellidoM varchar(50) not null,
	domicilio varchar(200) not null,
	telefono varchar(7) not null,
	celular varchar(10) not null,
	email varchar(50) not null,
	CONSTRAINT PK_IDPROVEEDOR Primary Key(idProveedor)
);

CREATE TABLE PERSONA.USUARIO(
	idUsuario bigserial not null,
    usuario varchar(50) not null,
    contrasena varchar(50) not null,
    rol varchar(20) not null,
    CONSTRAINT PK_IDUSUARIO Primary Key(idUsuario)
);
---------------------------------------------------------
CREATE TABLE INSUMO.MATERIAL
(
	idMaterial bigserial not null,
	idProveedor bigint not null,
	nombre varchar(50) not null,
	descripcion varchar(100) not null,
	stock int not null,
	precio_venta decimal not null,
	precio_compra decimal not null,
	CONSTRAINT PK_IDMATERIAL Primary Key(idMaterial),
	CONSTRAINT FK_ID_PROVEEDOR Foreign Key(idProveedor) REFERENCES PERSONA.PROVEEDOR(idProveedor)
);
---------------------------------------------------------
CREATE TABLE ADMINISTRACION.SERVICIO
(
	idServicio bigserial not null,
	descripcion varchar(200) not null,
	tipoServicio varchar(20) not null,
	costo decimal not null,

	CONSTRAINT PK_IDSERVICIO Primary Key(idServicio)
);

CREATE TABLE ADMINISTRACION.SERVICIO_EMPLEADO
(
	idServicio bigint not null,
	idEmpleado bigint not null,
	CONSTRAINT PK_SERVICIO_EMPLEADO Primary Key(idServicio, idEmpleado),
	CONSTRAINT FK_ID_SERVICIO Foreign Key(idServicio) REFERENCES ADMINISTRACION.SERVICIO(idServicio),
	CONSTRAINT FK_ID_EMPLEADO Foreign Key(idEmpleado) REFERENCES PERSONA.EMPLEADO(idEmpleado)
);

CREATE TABLE ADMINISTRACION.PEDIDO
(
	idPedido bigserial not null,
	idCliente bigint not null,
	fechaPedido date not null,
	fechaEntrega date not null,
	total decimal not null,
	CONSTRAINT PK_IDPEDIDO Primary key(idPedido),
	CONSTRAINT FK_ID_CLIENTE Foreign Key(idCliente) REFERENCES PERSONA.CLIENTE(idCliente)
);
CREATE TABLE ADMINISTRACION.PEDIDO_MATERIAL
(
	idPedido bigint not null,
	idMaterial bigint not null,
	cantidad int not null,
	CONSTRAINT FK_ID_PMATERIAL Foreign Key(idMaterial) REFERENCES INSUMO.MATERIAL(idMaterial)
);
CREATE TABLE ADMINISTRACION.PEDIDO_SERVICIO
(
	idPedido bigint not null,
    idServicio bigint not null,
    CONSTRAINT FK_ID_PSERVICIO Foreign Key(idServicio) REFERENCES ADMINISTRACION.SERVICIO(idServicio)
);
CREATE TABLE ADMINISTRACION.FACTURA
(
	idPedido bigint not null,
	idEmpleado bigint not null,
	fecha_factura date not null,
	tipo_pago varchar(30) not null,

	CONSTRAINT PK_IDFPEDIDO Primary Key(idPedido),
	CONSTRAINT FK_IDFPEDIDO Foreign Key(idPedido) REFERENCES ADMINISTRACION.PEDIDO(idPedido),
	CONSTRAINT FK_ID_EMPLEADO2 Foreign Key(idEmpleado) REFERENCES PERSONA.EMPLEADO(idEmpleado)
);
//Roles
1.-GERENTE 		(TODAS LAS PESTAÑAS + PESTAÑA USUARIOS)
2.-SUPERVISOR	(TODAS LAS PESTALAS)
3.-NORMAL		(SOLO PESTAÑAS PEDIDOS Y FACTURA) 
/** TRIGGERS (DISPARADORES) */

/** AL AGREGAR UN MATERIAL A UN PEDIDO: 
	-VERIFICA STOCK
		-SE DECREMENTA STOCK DE MATERIAL.
	-VERIFICA CREDITO
		-SE DECREMENTA CREDITO DEL CLIENTE.
	-SE ACTUALIZA TOTAL.
*/
CREATE OR REPLACE FUNCTION agregar_material() RETURNS TRIGGER AS $agregar_mat$
DECLARE 
	disponibles INTEGER;
    preciomaterial DECIMAL;
    subtotal DECIMAL;
    creditocliente DECIMAL;
BEGIN
	/**STOCK*/
	disponibles = (SELECT stock FROM INSUMO.MATERIAL WHERE idmaterial = NEW.idmaterial);
    IF disponibles >= NEW.cantidad THEN
    	preciomaterial = (SELECT precio_venta FROM INSUMO.MATERIAL WHERE idmaterial = NEW.idmaterial);
        subtotal = preciomaterial * NEW.cantidad;
        /**CREDITO*/
        creditocliente = (SELECT DISTINCT C.credito FROM PERSONA.CLIENTE C, ADMINISTRACION.PEDIDO P
                         	WHERE C.idcliente = P.idcliente AND
                         	P.idpedido = NEW.idpedido);
        IF creditocliente >= subtotal THEN
        	UPDATE INSUMO.MATERIAL SET stock=stock-NEW.cantidad WHERE idmaterial = NEW.idmaterial;
            UPDATE PERSONA.CLIENTE SET credito=credito-subtotal;
        	UPDATE ADMINISTRACION.PEDIDO set total=total+subtotal;	
        ELSE
			RAISE EXCEPTION 'CREDITO INSUFICIENTE';
        END IF;
    ELSE 
    	RAISE EXCEPTION 'STOCK INSUFICIENTE';
    END IF;
    RETURN NULL;
END;
$agregar_mat$ LANGUAGE plpgsql;
CREATE TRIGGER agregarMaterial AFTER INSERT ON ADMINISTRACION.PEDIDO_MATERIAL
FOR EACH ROW EXECUTE PROCEDURE agregar_material();

/** AL AGREGAR UN SERVICIO A UN PEDIDO: 
	-VERIFICA CREDITO
		-SE DECREMENTA CREDITO DEL CLIENTE.
	-SE ACTUALIZA TOTAL.
*/
CREATE OR REPLACE FUNCTION agregar_servicio() RETURNS TRIGGER AS $agregar_serv$
DECLARE 
    subtotal DECIMAL;
    creditocliente DECIMAL;
BEGIN
	subtotal = (SELECT costo FROM ADMINISTRACION.SERVICIO WHERE idservicio = NEW.idservicio);
	/*CREDITO*/	
    creditocliente = (SELECT DISTINCT C.credito FROM PERSONA.CLIENTE C, ADMINISTRACION.PEDIDO P
                      WHERE C.idcliente = P.idcliente AND
                      P.idpedido = NEW.idpedido);
    IF creditocliente >= subtotal THEN
    	UPDATE PERSONA.CLIENTE SET credito=credito-subtotal;
		UPDATE ADMINISTRACION.PEDIDO set total=total+subtotal;	
    ELSE
    	RAISE EXCEPTION 'CREDITO INSUFICIENTE';
    END IF;
    RETURN NULL;
END;
$agregar_serv$ LANGUAGE plpgsql;
CREATE TRIGGER agregarServicio AFTER INSERT ON ADMINISTRACION.PEDIDO_SERVICIO
FOR EACH ROW EXECUTE PROCEDURE agregar_servicio();

/** AL ELIMINAR UN MATERIAL DE UN PEDIDO: 
	-SE INCREMENTA EL STOCK
	-SE INCREMENTA CREDITO DEL CLIENTE.
	-SE ACTUALIZA TOTAL.
*/
CREATE OR REPLACE FUNCTION eliminar_material() RETURNS TRIGGER AS $eliminar_mat$
DECLARE 
    preciomaterial DECIMAL;
    subtotal DECIMAL;
    creditocliente DECIMAL;
BEGIN
    preciomaterial = (SELECT precio_venta FROM INSUMO.MATERIAL WHERE idmaterial = OLD.idmaterial);
	subtotal = preciomaterial * OLD.cantidad;
    creditocliente = (SELECT DISTINCT C.credito FROM PERSONA.CLIENTE C, ADMINISTRACION.PEDIDO P
                      WHERE C.idcliente = P.idcliente AND
                      P.idpedido = OLD.idpedido);
    UPDATE INSUMO.MATERIAL SET stock=stock+OLD.cantidad WHERE idmaterial = OLD.idmaterial;
    UPDATE PERSONA.CLIENTE SET credito=credito+subtotal;
    UPDATE ADMINISTRACION.PEDIDO set total=total-subtotal;
    RETURN NULL;
END;
$eliminar_mat$ LANGUAGE plpgsql;
CREATE TRIGGER eliminarMaterial AFTER DELETE ON ADMINISTRACION.PEDIDO_MATERIAL
FOR EACH ROW EXECUTE PROCEDURE eliminar_material();

/** AL ELIMINAR UN SERVICIO DE UN PEDIDO: 
	-SE INCREMENTA CREDITO DEL CLIENTE.
	-SE ACTUALIZA TOTAL.
*/
CREATE OR REPLACE FUNCTION eliminar_servicio() RETURNS TRIGGER AS $eliminar_serv$
DECLARE 
    subtotal DECIMAL;
    creditocliente DECIMAL;
BEGIN
	subtotal = (SELECT costo FROM ADMINISTRACION.SERVICIO WHERE idservicio = OLD.idservicio);
    creditocliente = (SELECT DISTINCT C.credito FROM PERSONA.CLIENTE C, ADMINISTRACION.PEDIDO P
                      WHERE C.idcliente = P.idcliente AND
                      P.idpedido = OLD.idpedido);
   	UPDATE PERSONA.CLIENTE SET credito=credito+subtotal;
    UPDATE ADMINISTRACION.PEDIDO set total=total-subtotal;	
    RETURN NULL;
END;
$eliminar_serv$ LANGUAGE plpgsql;
CREATE TRIGGER eliminarServicio AFTER DELETE ON ADMINISTRACION.PEDIDO_SERVICIO
FOR EACH ROW EXECUTE PROCEDURE eliminar_servicio();
/*ACTUALIZAR MATERIAL PEDIDO*/
CREATE OR REPLACE FUNCTION actualizar_material() RETURNS TRIGGER AS $actualizar_mat$
DECLARE 
	disponibles INTEGER;
    preciomaterial DECIMAL;
    subtotal_old DECIMAL;
    subtotal_new DECIMAL;
    creditocliente DECIMAL;
BEGIN
	/**STOCK*/
	disponibles = (SELECT stock FROM INSUMO.MATERIAL WHERE idmaterial = NEW.idmaterial) + OLD.cantidad;
    IF disponibles >= NEW.cantidad THEN
    	preciomaterial = (SELECT precio_venta FROM INSUMO.MATERIAL WHERE idmaterial = NEW.idmaterial);
        subtotal_old = preciomaterial * OLD.cantidad;
        subtotal_new = preciomaterial * NEW.cantidad;
        /**CREDITO*/
        creditocliente = (SELECT DISTINCT C.credito FROM PERSONA.CLIENTE C, ADMINISTRACION.PEDIDO P
                         	WHERE C.idcliente = P.idcliente AND
                         	P.idpedido = NEW.idpedido)+subtotal_old;
        IF creditocliente >= subtotal_new THEN
        	UPDATE INSUMO.MATERIAL SET stock=disponibles-NEW.cantidad WHERE idmaterial = NEW.idmaterial;
            UPDATE PERSONA.CLIENTE SET credito=creditocliente-subtotal_new;
        	UPDATE ADMINISTRACION.PEDIDO set total=total+subtotal_new-subtotal_old;	
        ELSE
			RAISE EXCEPTION 'CREDITO INSUFICIENTE';
        END IF;
    ELSE 
    	RAISE EXCEPTION 'STOCK INSUFICIENTE';
    END IF;
    RETURN NULL;
END;
$actualizar_mat$ LANGUAGE plpgsql;
CREATE TRIGGER actualizarMaterial AFTER UPDATE ON ADMINISTRACION.PEDIDO_MATERIAL
FOR EACH ROW EXECUTE PROCEDURE actualizar_material();




SELECT credito FROM PERSONA.CLIENTE;
SELECT total FROM ADMINISTRACION.PEDIDO;
SELECT stock FROM INSUMO.MATERIAL;
INSERT INTO ADMINISTRACION.PEDIDO(idcliente, fechapedido, fechaentrega, total) VALUES(2, '19/04/2017', '19/04/2017', 0);

SELECT * FROM ADMINISTRACION.PEDIDO_MATERIAL;
DELETE FROM ADMINISTRACION.PEDIDO_MATERIAL;
INSERT INTO ADMINISTRACION.PEDIDO_MATERIAL(idpedido, idmaterial, cantidad) VALUES(1, 1, 2);
UPDATE ADMINISTRACION.PEDIDO_MATERIAL SET cantidad = 1 WHERE idpedido = 1;
INSERT INTO INSUMO.MATERIAL(idproveedor, nombre, descripcion, stock, precio_venta, precio_compra) VALUES (4, 'Taladro', 'Taladro de uso industrial', 5, 2000, 1600);
UPDATE ADMINISTRACION.PEDIDO SET total = 1450 WHERE idpedido = 1;

DELETE FROM ADMINISTRACION.PEDIDO_SERVICIO;
SELECT * FROM ADMINISTRACION.PEDIDO_SERVICIO;
SELECT * FROM ADMINISTRACION.SERVICIO;
INSERT INTO ADMINISTRACION.PEDIDO_SERVICIO(idpedido, idservicio)VALUES(1, 1); 

SELECT CASE WHEN EXISTS (SELECT PM.idmaterial FROM ADMINISTRACION.PEDIDO_MATERIAL PM WHERE PM.idpedido=1)THEN 1 ELSE 0 END

SELECT concat(C.nombres, '_', C.apellidop, '_', C.apellidom), P.fechapedido, P.fechaentrega, P.total 
FROM ADMINISTRACION.PEDIDO P, PERSONA.CLIENTE C WHERE P.idcliente = C.idcliente;