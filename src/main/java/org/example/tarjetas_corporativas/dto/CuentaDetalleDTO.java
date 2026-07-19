package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;

public class CuentaDetalleDTO {
    private final long       cuentaId;
    private final String     numeroCuenta;
    private final BigDecimal saldo;
    private final String     estado;
    private final String     categoria;
    private final long       tarjetas;

    public CuentaDetalleDTO(long cuentaId, String numeroCuenta, BigDecimal saldo, String estado,
                            String categoria, long tarjetas) {
        this.cuentaId     = cuentaId;
        this.numeroCuenta = numeroCuenta;
        this.saldo        = saldo;
        this.estado       = estado;
        this.categoria    = categoria;
        this.tarjetas     = tarjetas;
    }

    public long       getCuentaId()     { return cuentaId; }
    public String     getNumeroCuenta() { return numeroCuenta; }
    public BigDecimal getSaldo()        { return saldo; }
    public String     getEstado()       { return estado; }
    public String     getCategoria()    { return categoria; }
    public long       getTarjetas()     { return tarjetas; }
}
