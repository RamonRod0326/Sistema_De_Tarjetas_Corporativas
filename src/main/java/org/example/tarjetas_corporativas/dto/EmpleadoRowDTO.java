package org.example.tarjetas_corporativas.dto;

public class EmpleadoRowDTO {
    private final long   id;
    private final String nombre;
    private final String email;
    private final int    activo;
    private final String departamento;
    private final String cargo;

    public EmpleadoRowDTO(long id, String nombre, String email,
                          int activo, String departamento, String cargo) {
        this.id           = id;
        this.nombre       = nombre;
        this.email        = email;
        this.activo       = activo;
        this.departamento = departamento;
        this.cargo        = cargo;
    }

    public long   getId()           { return id; }
    public String getNombre()       { return nombre; }
    public String getEmail()        { return email; }
    public int    getActivo()       { return activo; }
    public String getDepartamento() { return departamento; }
    public String getCargo()        { return cargo; }
}
