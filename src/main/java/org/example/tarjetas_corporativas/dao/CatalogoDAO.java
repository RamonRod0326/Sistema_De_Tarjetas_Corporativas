package org.example.tarjetas_corporativas.dao;

import org.example.tarjetas_corporativas.dto.CatalogoItemDTO;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * DAO para las tablas de catálogo: {@code DEPARTAMENTOS}, {@code CARGOS} y {@code CATEGORIAS_CUENTA}.
 */
public interface CatalogoDAO {

    List<CatalogoItemDTO> findDepartamentosActivos(Connection con) throws SQLException;
    List<CatalogoItemDTO> findCargosActivos(Connection con) throws SQLException;
    List<CatalogoItemDTO> findCategoriasActivas(Connection con) throws SQLException;

    void insertDepartamento(Connection con, String nombre) throws SQLException;
    void insertCargo(Connection con, String nombre) throws SQLException;
    void insertCategoria(Connection con, String nombre) throws SQLException;

    void updateDepartamento(Connection con, long id, String nombre) throws SQLException;
    void updateCargo(Connection con, long id, String nombre) throws SQLException;
    void updateCategoria(Connection con, long id, String nombre) throws SQLException;

    void deactivateDepartamento(Connection con, long id) throws SQLException;
    void deactivateCargo(Connection con, long id) throws SQLException;
    void deactivateCategoria(Connection con, long id) throws SQLException;

    // Cargos con conteo de empleados enlazados (para API JSON)
    List<Object[]> findCargosConCount(Connection con) throws SQLException;
    // Empleados vinculados a un cargo específico (para API JSON)
    List<Object[]> findEmpleadosByCargo(Connection con, long cargoId) throws SQLException;

    // Departamentos con conteo de empleados
    List<Object[]> findDepartamentosConCount(Connection con) throws SQLException;
    // Empleados vinculados a un departamento específico
    List<Object[]> findEmpleadosByDepartamento(Connection con, long deptId) throws SQLException;

    // Categorías de cuenta con conteo de cuentas activas
    List<Object[]> findCategoriasConCount(Connection con) throws SQLException;
    // Cuentas vinculadas a una categoría específica
    List<Object[]> findCuentasByCategoria(Connection con, long categoriaId) throws SQLException;
}
