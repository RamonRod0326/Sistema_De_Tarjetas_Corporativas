package org.example.tarjetas_corporativas.dto;

public class EmpleadoFormDTO {
    private final long   id;
    private final String nombre;
    private final String apellidoPaterno;
    private final String apellidoMaterno;
    private final String email;
    private final String rol;
    private final long   departamentoId;
    private final long   cargoId;
    private final String cargoNombre;
    private final String depNombre;
    private final String iniciales;

    public EmpleadoFormDTO(long id, String nombre, String apellidoPaterno, String apellidoMaterno,
                           String email, String rol,
                           long departamentoId, long cargoId,
                           String cargoNombre, String depNombre, String iniciales) {
        this.id              = id;
        this.nombre          = nombre;
        this.apellidoPaterno = apellidoPaterno != null ? apellidoPaterno : "";
        this.apellidoMaterno = apellidoMaterno != null ? apellidoMaterno : "";
        this.email           = email;
        this.rol             = rol;
        this.departamentoId  = departamentoId;
        this.cargoId         = cargoId;
        this.cargoNombre     = cargoNombre;
        this.depNombre       = depNombre;
        this.iniciales       = iniciales;
    }

    public long   getId()              { return id; }
    public String getNombre()          { return nombre; }
    public String getApellidoPaterno() { return apellidoPaterno; }
    public String getApellidoMaterno() { return apellidoMaterno; }
    public String getEmail()           { return email; }
    public String getRol()             { return rol; }
    public long   getDepartamentoId()  { return departamentoId; }
    public long   getCargoId()         { return cargoId; }
    public String getCargoNombre()     { return cargoNombre; }
    public String getDepNombre()       { return depNombre; }
    public String getIniciales()       { return iniciales; }
}
