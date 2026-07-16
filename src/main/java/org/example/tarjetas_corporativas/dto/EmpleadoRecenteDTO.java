package org.example.tarjetas_corporativas.dto;

public class EmpleadoRecenteDTO {
    private final long   id;
    private final String nombre;
    private final String email;
    private final String departamento;

    public EmpleadoRecenteDTO(long id, String nombre, String email, String departamento) {
        this.id           = id;
        this.nombre       = nombre;
        this.email        = email;
        this.departamento = departamento;
    }

    public long   getId()           { return id; }
    public String getNombre()       { return nombre; }
    public String getEmail()        { return email; }
    public String getDepartamento() { return departamento; }
}
