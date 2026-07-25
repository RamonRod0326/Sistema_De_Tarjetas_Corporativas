package org.example.tarjetas_corporativas.service;

import org.example.tarjetas_corporativas.config.DataSourceProvider;
import org.example.tarjetas_corporativas.dao.CatalogoDAO;
import org.example.tarjetas_corporativas.dao.impl.CatalogoDAOImpl;
import org.example.tarjetas_corporativas.dto.CatalogoItemDTO;
import org.example.tarjetas_corporativas.exception.ServiceException;
import java.sql.*;
import java.util.List;

public class CatalogoService {

    private final CatalogoDAO catalogoDAO;

    public CatalogoService() {
        this.catalogoDAO = new CatalogoDAOImpl();
    }

    public List<CatalogoItemDTO> getDepartamentos() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findDepartamentosActivos(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar departamentos", e);
        }
    }

    public List<CatalogoItemDTO> getCargos() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findCargosActivos(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar cargos", e);
        }
    }

    public List<CatalogoItemDTO> getCategorias() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findCategoriasActivas(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar categorías", e);
        }
    }

    public void insertarDepartamento(String nombre) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.insertDepartamento(con, nombre.trim());
            con.commit();
        } catch (SQLException e) {
            throw new ServiceException("Error al insertar departamento", e);
        }
    }

    public void insertarCargo(String nombre) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.insertCargo(con, nombre.trim());
            con.commit();
        } catch (SQLException e) {
            throw new ServiceException("Error al insertar cargo", e);
        }
    }

    public void insertarCategoria(String nombre) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.insertCategoria(con, nombre.trim());
            con.commit();
        } catch (SQLException e) {
            throw new ServiceException("Error al insertar categoría", e);
        }
    }

    public void actualizarDepartamento(long id, String nombre) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.updateDepartamento(con, id, nombre.trim());
            con.commit();
        } catch (SQLException e) {
            throw new ServiceException("Error al actualizar departamento", e);
        }
    }

    public void actualizarCargo(long id, String nombre) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.updateCargo(con, id, nombre.trim());
            con.commit();
        } catch (SQLException e) {
            throw new ServiceException("Error al actualizar cargo", e);
        }
    }

    public void actualizarCategoria(long id, String nombre) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.updateCategoria(con, id, nombre.trim());
            con.commit();
        } catch (SQLException e) {
            throw new ServiceException("Error al actualizar categoría", e);
        }
    }

    public void eliminarDepartamento(long id) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.deactivateDepartamento(con, id);
            con.commit();
        } catch (SQLException e) {
            if (e.getErrorCode() == 2292)
                throw new ServiceException("El departamento está asignado a empleados activos", "catalogo_en_uso");
            throw new ServiceException("Error al eliminar departamento", e);
        }
    }

    public void eliminarCargo(long id) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.deactivateCargo(con, id);
            con.commit();
        } catch (SQLException e) {
            if (e.getErrorCode() == 2292)
                throw new ServiceException("El cargo está asignado a empleados activos", "catalogo_en_uso");
            throw new ServiceException("Error al eliminar cargo", e);
        }
    }

    public List<Object[]> getCargosConCount() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findCargosConCount(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar cargos", e);
        }
    }

    public List<Object[]> getDepartamentosConCount() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findDepartamentosConCount(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar departamentos", e);
        }
    }

    public List<Object[]> getEmpleadosByDepartamento(long deptId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findEmpleadosByDepartamento(con, deptId);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar empleados del departamento", e);
        }
    }

    public List<Object[]> getCategoriasConCount() {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findCategoriasConCount(con);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar categorías", e);
        }
    }

    public List<Object[]> getCuentasByCategoria(long categoriaId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findCuentasByCategoria(con, categoriaId);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar cuentas de la categoría", e);
        }
    }

    public List<Object[]> getEmpleadosByCargo(long cargoId) {
        try (Connection con = DataSourceProvider.getConnection()) {
            return catalogoDAO.findEmpleadosByCargo(con, cargoId);
        } catch (SQLException e) {
            throw new ServiceException("Error al cargar empleados del cargo", e);
        }
    }

    public void eliminarCategoria(long id) {
        try (Connection con = DataSourceProvider.getConnection()) {
            catalogoDAO.deactivateCategoria(con, id);
            con.commit();
        } catch (SQLException e) {
            if (e.getErrorCode() == 2292)
                throw new ServiceException("La categoría está asignada a cuentas activas", "catalogo_en_uso");
            throw new ServiceException("Error al eliminar categoría", e);
        }
    }
}
