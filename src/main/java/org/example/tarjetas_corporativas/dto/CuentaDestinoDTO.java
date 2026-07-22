package org.example.tarjetas_corporativas.dto;

public class CuentaDestinoDTO {
    private final long   id;
    private final String numeroCuenta;
    private final String titular;
    private final String categoria;
    private final Long   categoriaId;

    public CuentaDestinoDTO(long id, String numeroCuenta, String titular,
                            String categoria, Long categoriaId) {
        this.id           = id;
        this.numeroCuenta = numeroCuenta;
        this.titular      = titular;
        this.categoria    = categoria;
        this.categoriaId  = categoriaId;
    }

    public long   getId()           { return id; }
    public String getNumeroCuenta() { return numeroCuenta; }
    public String getTitular()      { return titular; }
    public String getCategoria()    { return categoria; }
    public Long   getCategoriaId()  { return categoriaId; }
}
