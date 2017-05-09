/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.conexion;
import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.ResultSetMetaData;
import javax.swing.table.DefaultTableModel;
import java.util.Vector;
import javax.swing.JOptionPane;
import java.util.List;
import java.util.ArrayList;

/**
 *
 * @author LGerardo
 */
public class ConexionPostgres {
    private Connection conexion;
    
    public ConexionPostgres(){
        this.conexion = null;
    }
    
    private void abreConexion() throws ClassNotFoundException, SQLException{
        String nombreDriver = "org.postgresql.Driver";
        int puerto = 5432;
        String baseDatos = "SERMAIPE";
        String nombreUsuario = "postgres";
        String contrasena = "posgrest";
        String url = String.format("jdbc:postgresql://localhost:%d/%s", puerto, baseDatos);
        
        Class.forName(nombreDriver);
        this.conexion = DriverManager.getConnection(url, nombreUsuario, contrasena);
    }
    
    private void cierraConexion() throws SQLException{
       this.conexion.close();
       this.conexion = null;
    }
    
    public String login(String usuario, String password) throws ClassNotFoundException, SQLException{
        String Resultado="";
        Statement stmt;
        ResultSet rs;
        String sql = String.format("SELECT rol FROM PERSONA.USUARIO WHERE usuario='%s' AND contrasena='%s'", usuario, password);

        this.abreConexion(); //Abre conexión
        stmt = this.conexion.createStatement(); //Crea sentencia
        rs = stmt.executeQuery(sql);
        while (rs.next()){
         Resultado = rs.getString(1);
        }
        stmt.close(); //Cierra sentencia
        this.cierraConexion(); //Cierra conexión
        return Resultado;
    }
    /** USUARIOS */
    public int insertaUsuario(String usuario, String contrasena, String privilegio) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO PERSONA.USUARIO(usuario, contrasena, rol) VALUES('%s','%s', '%s')", usuario, contrasena, privilegio);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void actualizaUsuario(String idUsuario, String usuario, String contrasena, String privilegio) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("UPDATE PERSONA.USUARIO SET usuario='%s', contrasena='%s', rol='%s' WHERE idusuario='%s'", usuario, contrasena, privilegio, idUsuario);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    public void eliminaUsuario(String idUsuario) throws ClassNotFoundException, SQLException{
        Statement stmt;
        String cmd = String.format("DELETE FROM PERSONA.USUARIO WHERE idusuario="+idUsuario);
        this.abreConexion();
        stmt = this.conexion.createStatement();
        stmt.executeUpdate(cmd);
        this.cierraConexion();
    }
   /** EMPLEADOS */
    public int insertaEmpleado(String nombres, String apellidop, String apellidom, String domicilio, String telefono, String celular, Float sueldo) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO PERSONA.EMPLEADO(nombres, apellidop, apellidom, domicilio, telefono, celular, sueldo) VALUES('%s', '%s', '%s', '%s', '%s', '%s', %.2f)", nombres, apellidop, apellidom, domicilio, telefono, celular, sueldo);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void actualizaEmpleado(String idEmpleado, String nombres, String apellidop, String apellidom, String domicilio, String telefono, String celular, Float sueldo) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("UPDATE PERSONA.EMPLEADO SET nombres='%s', apellidop='%s', apellidom='%s', domicilio='%s', telefono='%s', celular='%s', sueldo='%.2f' WHERE idempleado='%s'", nombres, apellidop, apellidom, domicilio, telefono, celular, sueldo, idEmpleado);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    public void eliminaEmpleado(String idEmpleado) throws ClassNotFoundException, SQLException{
        Statement stmt;
        String cmd = String.format("DELETE FROM PERSONA.EMPLEADO WHERE idempleado="+idEmpleado);
        this.abreConexion();
        stmt = this.conexion.createStatement();
        stmt.executeUpdate(cmd);
        this.cierraConexion();
    }
    /** CLIENTES */
    public int insertaCliente(String nombres, String apellidop, String apellidom, String domicilio, String telefono, String celular, Float credito) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO PERSONA.CLIENTE(nombres, apellidop, apellidom, domicilio, telefono, celular, credito) VALUES('%s', '%s', '%s', '%s', '%s', '%s', %.2f)", nombres, apellidop, apellidom, domicilio, telefono, celular, credito);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void actualizaCliente(String idCliente, String nombres, String apellidop, String apellidom, String domicilio, String telefono, String celular, Float credito) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("UPDATE PERSONA.CLIENTE SET nombres='%s', apellidop='%s', apellidom='%s', domicilio='%s', telefono='%s', celular='%s', credito='%.2f' WHERE idcliente='%s'", nombres, apellidop, apellidom, domicilio, telefono, celular, credito, idCliente);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    public void eliminaCliente(String idCliente) throws ClassNotFoundException, SQLException{
        Statement stmt;
        String cmd = String.format("DELETE FROM PERSONA.CLIENTE WHERE idcliente="+idCliente);
        this.abreConexion();
        stmt = this.conexion.createStatement();
        stmt.executeUpdate(cmd);
        this.cierraConexion();
    }
    /** PROVEEDORES */
    public int insertaProveedor(String nombres, String apellidop, String apellidom, String domicilio, String telefono, String celular, String email) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO PERSONA.PROVEEDOR(nombres, apellidop, apellidom, domicilio, telefono, celular, email) VALUES('%s', '%s', '%s', '%s', '%s', '%s', '%s')", nombres, apellidop, apellidom, domicilio, telefono, celular, email);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void actualizaProveedor(String idProveedor, String nombres, String apellidop, String apellidom, String domicilio, String telefono, String celular, String email) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("UPDATE PERSONA.PROVEEDOR SET nombres='%s', apellidop='%s', apellidom='%s', domicilio='%s', telefono='%s', celular='%s', email='%s' WHERE idproveedor='%s'", nombres, apellidop, apellidom, domicilio, telefono, celular, email, idProveedor);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    public void eliminaProveedor(String idProveedor) throws ClassNotFoundException, SQLException{
        Statement stmt;
        String cmd = String.format("DELETE FROM PERSONA.PROVEEDOR WHERE idproveedor="+idProveedor);
        this.abreConexion();
        stmt = this.conexion.createStatement();
        stmt.executeUpdate(cmd);
        this.cierraConexion();
    }
    /**MATERIALES*/
    public int insertaMaterial(String idproveedor, String nombre, String descripcion, Integer stock, Float precio_venta, Float precio_compra) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO INSUMO.MATERIAL(idproveedor, nombre, descripcion, stock, precio_venta, precio_compra) VALUES('%s', '%s', '%s', %d, %.2f, %.2f)", idproveedor, nombre, descripcion, stock, precio_venta, precio_compra);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void actualizaMaterial(String idMaterial, String idproveedor, String nombre, String descripcion, Integer stock, Float precio_venta, Float precio_compra) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("UPDATE INSUMO.MATERIAL SET idproveedor='%s', nombre='%s', descripcion='%s', stock=%d, precio_venta=%.2f, precio_compra=%.2f WHERE idmaterial='%s'", idproveedor, nombre, descripcion, stock, precio_venta, precio_compra, idMaterial);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    public void eliminaMaterial(String idMaterial) throws ClassNotFoundException, SQLException{
        Statement stmt;
        String cmd = String.format("DELETE FROM INSUMO.MATERIAL WHERE idmaterial="+idMaterial);
        this.abreConexion();
        stmt = this.conexion.createStatement();
        stmt.executeUpdate(cmd);
        this.cierraConexion();
    }
    /**
     *
     * SERVICIOS
     *
     */
    public int insertaServicio(String descripcion, String tiposervicio, Float costo) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO ADMINISTRACION.SERVICIO(descripcion, tiposervicio, costo) VALUES('%s', '%s', %.2f)", descripcion, tiposervicio, costo);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void actualizaServicio(String idServicio, String descripcion, String tiposervicio, Float costo) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("UPDATE ADMINISTRACION.SERVICIO SET descripcion='%s', tiposervicio='%s', costo=%.2f WHERE idservicio='%s'", descripcion, tiposervicio, costo, idServicio);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    public void eliminaServicio(String idServicio) throws ClassNotFoundException, SQLException{
        Statement stmt;
        String cmd = String.format("DELETE FROM ADMINISTRACION.SERVICIO WHERE idservicio="+idServicio);
        this.abreConexion();
        stmt = this.conexion.createStatement();
        stmt.executeUpdate(cmd);
        this.cierraConexion();
    }
    public int insertaEmpleadoServicio(String idServicio, String idEmpleado) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO ADMINISTRACION.SERVICIO_EMPLEADO(idservicio, idempleado) VALUES('%s', '%s')", idServicio, idEmpleado);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void eliminaEmpleadoServicio(String idServicio, String idEmpleado) throws ClassNotFoundException, SQLException{
        Statement stmt;
        String cmd = String.format("DELETE FROM ADMINISTRACION.SERVICIO_EMPLEADO WHERE idservicio="+idServicio+ " AND idempleado="+idEmpleado);
        this.abreConexion();
        stmt = this.conexion.createStatement();
        stmt.executeUpdate(cmd);
        this.cierraConexion();
    }
    /**
     * 
     * PEDIDOS
     * 
     */
    public int insertaPedido(String idcliente, String fechapedido, String fechaentrega, Float total) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO ADMINISTRACION.PEDIDO(idcliente, fechapedido, fechaentrega, total) VALUES('%s', '%s','%s', %.2f)", idcliente, fechapedido, fechaentrega, total);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void eliminaPedido(String idPedido) throws ClassNotFoundException, SQLException{
        Statement stmt;
        String cmd = String.format("DELETE FROM ADMINISTRACION.PEDIDO WHERE idpedido="+idPedido);
        this.abreConexion();
        stmt = this.conexion.createStatement();
        stmt.executeUpdate(cmd);
        this.cierraConexion();
    }
    public int insertaMaterialPedido(String idPedido, String idMaterial, Integer cantidad) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO ADMINISTRACION.PEDIDO_MATERIAL(idpedido, idmaterial, cantidad) VALUES('%s', '%s', %d)", idPedido, idMaterial, cantidad);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public int insertaServicioPedido(String idPedido, String idServicio) throws ClassNotFoundException, SQLException{
       Statement stmt;
       int filasAfectadas = 0;
       String dml = String.format("INSERT INTO ADMINISTRACION.PEDIDO_SERVICIO(idpedido, idservicio) VALUES('%s', '%s')", idPedido, idServicio);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       filasAfectadas = stmt.executeUpdate(dml);
       this.cierraConexion();
       return filasAfectadas;
    }
    public void actualizaMaterialPedido(String idPedido, String idMaterial, Integer cantidad) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("UPDATE ADMINISTRACION.PEDIDO_MATERIAL SET cantidad = %d WHERE idpedido = '%s' AND idmaterial=%s", cantidad, idPedido, idMaterial);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    public void eliminaMaterialPedido(String idPedido, String idMaterial) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("DELETE FROM ADMINISTRACION.PEDIDO_MATERIAL WHERE idpedido = '%s' AND idmaterial=%s", idPedido, idMaterial);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    public void eliminaServicioPedido(String idPedido, String idServicio) throws ClassNotFoundException, SQLException{
       Statement stmt;
       String cmd = String.format("DELETE FROM ADMINISTRACION.PEDIDO_SERVICIO WHERE idpedido = '%s' AND idservicio=%s", idPedido, idServicio);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       stmt.executeUpdate(cmd);
       this.cierraConexion();
    }
    /** CONSULTAS */
    /**Metodo que reliza consulta requerida*/
    public DefaultTableModel consulta(String sqla) throws ClassNotFoundException, SQLException{
       Statement stmt;
       ResultSet rs;
       DefaultTableModel dtm;
       String sql = String.format(sqla);
       this.abreConexion();
       stmt = this.conexion.createStatement();
       rs = stmt.executeQuery(sql);
       this.cierraConexion();
       dtm = this.construyeTableModel(rs);
       return dtm;
    }
    /**Metodo para convertir un ResultSet a TableModel*/
    private DefaultTableModel construyeTableModel(ResultSet rs)throws ClassNotFoundException, SQLException{
       ResultSetMetaData metadata = rs.getMetaData();
       int cantidadColumnas = metadata.getColumnCount();
       Vector<String> nombreColumnas = new Vector<String>();
       Vector<Vector<Object>> tuplas = new Vector<Vector<Object>>();   
       //Nombres de columnas
       for(int columna=1; columna<=cantidadColumnas; columna++)
           nombreColumnas.add(metadata.getColumnName(columna));
       //Recuperacion de tuplas
       while(rs.next()){
           Vector<Object> renglon = new Vector<Object>();
           for(int columna = 1; columna<= cantidadColumnas; columna++)
               renglon.add(rs.getObject(columna));
           tuplas.add(renglon);
       }
       return new DefaultTableModel(tuplas, nombreColumnas);
    }
    /** Método que devuelve nombre de un determinado proveedor */
    public String nombreProveedor(String idProveedor)throws ClassNotFoundException, SQLException{
        String nombrecompleto, sql;
        nombrecompleto = "";
        sql = String.format("SELECT concat(nombres, '_' ,apellidop, '_', apellidom) AS nombrecompleto FROM PERSONA.PROVEEDOR WHERE idproveedor='%s'", idProveedor);
        Statement stmt;
        ResultSet rs;
        
        this.abreConexion();
        stmt = this.conexion.createStatement();
        rs = stmt.executeQuery(sql);
        while(rs.next()){
            nombrecompleto = rs.getString("nombrecompleto");
        }
        this.cierraConexion();
        return nombrecompleto;
    }
    /**Método que devuelve el ID del determinada persona*/
    public String idPersona(String atributo, String tabla, String nombreCompleto)throws ClassNotFoundException, SQLException{
        String nombres, apellidop, apellidom, sql, idPersona;
        idPersona = "";
        nombres = nombreCompleto.split("_")[0];
        apellidop = nombreCompleto.split("_")[1];
        apellidom = nombreCompleto.split("_")[2];
        sql = String.format("SELECT %s FROM PERSONA.%s WHERE nombres='%s' AND apellidop='%s' AND apellidom='%s'", atributo, tabla, nombres, apellidop, apellidom);
        Statement stmt;
        ResultSet rs;
        
        this.abreConexion();
        stmt = this.conexion.createStatement();
        rs = stmt.executeQuery(sql);
        while(rs.next()){
            idPersona = rs.getString(atributo);
        }
        this.cierraConexion();
        return idPersona;
    }
    
    public String idMaterial(String descripcion)throws ClassNotFoundException, SQLException{
        String sql, idMaterial = "";
        sql = String.format("SELECT idmaterial FROM INSUMO.MATERIAL WHERE descripcion LIKE '%s'", descripcion);
        Statement stmt;
        ResultSet rs;
        
        this.abreConexion();
        stmt = this.conexion.createStatement();
        rs = stmt.executeQuery(sql);
        while(rs.next()){
            idMaterial = rs.getString("idmaterial");
        }
        this.cierraConexion();
        return idMaterial;
    }
    public String totalPedido(String idPedido)throws ClassNotFoundException, SQLException{
        String sql, total = "";
        sql = String.format("SELECT total FROM ADMINISTRACION.PEDIDO WHERE idpedido='%s'", idPedido);
        Statement stmt;
        ResultSet rs;
        
        this.abreConexion();
        stmt = this.conexion.createStatement();
        rs = stmt.executeQuery(sql);
        while(rs.next()){
            total = rs.getString("total");
        }
        this.cierraConexion();
        return total;
    }
            
    public String idServicio(String descripcion)throws ClassNotFoundException, SQLException{
        String sql, idServicio = "";
        sql = String.format("SELECT idservicio FROM ADMINISTRACION.SERVICIO WHERE descripcion LIKE '%s'", descripcion);
        Statement stmt;
        ResultSet rs;
        
        this.abreConexion();
        stmt = this.conexion.createStatement();
        rs = stmt.executeQuery(sql);
        while(rs.next()){
            idServicio = rs.getString("idservicio");
        }
        this.cierraConexion();
        return idServicio;
    }
    /**Método que devuelve una lista de atributos*/
    public List<String> listaRegistros(String atributo, String alias, String schema, String tabla) throws ClassNotFoundException, SQLException{
        String sql = String.format("SELECT %s AS %s FROM %s.%s", atributo, alias, schema, tabla);
        
        List<String> registros = new ArrayList<String>();
        String registro = "";
        Statement stmt;
        ResultSet rs;
        
        this.abreConexion();
        stmt = this.conexion.createStatement();
        rs = stmt.executeQuery(sql);
        while(rs.next()){
            registro = rs.getString(alias);
            registros.add(registro);
        }
        this.cierraConexion();
        return registros;
    }
}
