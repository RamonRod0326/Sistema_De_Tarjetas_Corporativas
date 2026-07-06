package org.example.tarjetas_corporativas.dao;

import org.example.tarjetas_corporativas.dto.*;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public interface UsuarioDAO {

    // Auth
    Object[] findByEmailForAuth(Connection con, String email) throws SQLException;
    // [0]=id(Long), [1]=nombre, [2]=passwordHash, [3]=rol, [4]=cargo, [5]=departamento

    // Config profile
    PerfilDTO findPerfil(Connection con, long usuarioId) throws SQLException;

    // Empleados list page
    EmpleadoStatsDTO getEmpleadoStats(Connection con) throws SQLException;
    List<EmpleadoRowDTO> findAllEmpleados(Connection con) throws SQLException;

    List<EmpleadoRowDTO> findEmpleadosPaged(Connection con, String search, Boolean activo,
                                            int offset, int limit) throws SQLException;
    long countEmpleados(Connection con, String search, Boolean activo) throws SQLException;

    // Admin dashboard
    List<EmpleadoRecenteDTO> findRecientes(Connection con, int limit) throws SQLException;

    // Admin cuentas page
    List<EmpleadoCuentaRowDTO> findEmpleadosConCuentas(Connection con) throws SQLException;
    List<EmpleadoCuentaRowDTO> findEmpleadosConCuentasPaged(Connection con, String search,
                                                            int offset, int limit) throws SQLException;
    long countEmpleadosConCuentas(Connection con, String search) throws SQLException;

    // Empleado form
    EmpleadoFormDTO findForEdit(Connection con, long id) throws SQLException;

    // CuentaForm
    List<EmpleadoRowDTO> findEmpleadosActivosParaForm(Connection con) throws SQLException;

    // CRUD
    void insertEmpleado(Connection con, String nombre, String apellidoPaterno, String apellidoMaterno,
                        String email, String hash,
                        String rol, Long depId, Long cargoId) throws SQLException;

    void updateEmpleado(Connection con, long id, String nombre, String apellidoPaterno, String apellidoMaterno,
                        String email, String rol, Long depId, Long cargoId) throws SQLException;

    void updateEmpleadoConHash(Connection con, long id, String nombre, String apellidoPaterno, String apellidoMaterno,
                               String email, String rol, Long depId, Long cargoId, String hash) throws SQLException;

    // Profile update
    void updateNombre(Connection con, long id, String nombre) throws SQLException;
    void updatePasswordHash(Connection con, long id, String hash) throws SQLException;
    String findPasswordHash(Connection con, long id) throws SQLException;

    // Employee deactivation
    BigDecimal sumSaldoCuentasActivas(Connection con, long usuarioId) throws SQLException;
    void deactivate(Connection con, long id) throws SQLException;
    void reactivate(Connection con, long id) throws SQLException;
    String findNombreById(Connection con, long id) throws SQLException;
}
