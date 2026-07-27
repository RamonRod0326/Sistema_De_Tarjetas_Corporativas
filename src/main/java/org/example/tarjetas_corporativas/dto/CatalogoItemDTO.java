package org.example.tarjetas_corporativas.dto;

public class CatalogoItemDTO {
    private final long   id;
    private final String nombre;

    public CatalogoItemDTO(long id, String nombre) {
        this.id     = id;
        this.nombre = nombre;
    }

    public long   getId()     { return id; }
    public String getNombre() { return nombre; }
}
