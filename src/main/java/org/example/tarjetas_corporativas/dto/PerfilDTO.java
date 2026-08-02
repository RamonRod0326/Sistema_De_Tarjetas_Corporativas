package org.example.tarjetas_corporativas.dto;

public class PerfilDTO {
    private final String nombre;
    private final String email;
    private final String empleadoId;
    private final String cargo;
    private final String departamento;
    private final String iniciales;

    public PerfilDTO(String nombre, String email, String empleadoId,
                     String cargo, String departamento, String iniciales) {
        this.nombre       = nombre;
        this.email        = email;
        this.empleadoId   = empleadoId;
        this.cargo        = cargo;
        this.departamento = departamento;
        this.iniciales    = iniciales;
    }

    public String getNombre()       { return nombre; }
    public String getEmail()        { return email; }
    public String getEmpleadoId()   { return empleadoId; }
    public String getCargo()        { return cargo; }
    public String getDepartamento() { return departamento; }
    public String getIniciales()    { return iniciales; }
}
