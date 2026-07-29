package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;

public class CuentaUserDTO {
    private final long       id;
    private final String     numeroCuenta;
    private final BigDecimal saldo;
    private final String     estado;
    private final String     categoria;
    private final Long       categoriaId;

    public CuentaUserDTO(long id, String numeroCuenta, BigDecimal saldo, String estado,
                         String categoria, Long categoriaId) {
        this.id           = id;
        this.numeroCuenta = numeroCuenta;
        this.saldo        = saldo;
        this.estado       = estado;
        this.categoria    = categoria;
        this.categoriaId  = categoriaId;
    }

    public long       getId()           { return id; }
    public String     getNumeroCuenta() { return numeroCuenta; }
    public BigDecimal getSaldo()        { return saldo; }
    public String     getEstado()       { return estado; }
    public String     getCategoria()    { return categoria; }
    public Long       getCategoriaId()  { return categoriaId; }
}
