package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class TarjetaAdminDTO {
    private final long      id;
    private final String    numeroTarjeta;
    private final String    modalidad;
    private final String    estado;
    private final int       activo;
    private final Timestamp fechaEmision;
    private final long      cuentaId;
    private final String    numeroCuenta;
    private final BigDecimal saldo;
    private final String    categoria;
    private final String    titular;
    private final String    departamento;

    public TarjetaAdminDTO(long id, String numeroTarjeta, String modalidad, String estado,
                           int activo, Timestamp fechaEmision, long cuentaId,
                           String numeroCuenta, BigDecimal saldo,
                           String categoria, String titular, String departamento) {
        this.id            = id;
        this.numeroTarjeta = numeroTarjeta;
        this.modalidad     = modalidad;
        this.estado        = estado;
        this.activo        = activo;
        this.fechaEmision  = fechaEmision;
        this.cuentaId      = cuentaId;
        this.numeroCuenta  = numeroCuenta;
        this.saldo         = saldo;
        this.categoria     = categoria;
        this.titular       = titular;
        this.departamento  = departamento;
    }

    public long      getId()            { return id; }
    public String    getNumeroTarjeta() { return numeroTarjeta; }
    public String    getModalidad()     { return modalidad; }
    public String    getEstado()        { return estado; }
    public int       getActivo()        { return activo; }
    public Timestamp getFechaEmision()  { return fechaEmision; }
    public long      getCuentaId()      { return cuentaId; }
    public String    getNumeroCuenta()  { return numeroCuenta; }
    public BigDecimal getSaldo()        { return saldo; }
    public String    getCategoria()     { return categoria; }
    public String    getTitular()       { return titular; }
    public String    getDepartamento()  { return departamento; }

    /** Número enmascarado: últimos 4 dígitos visibles, resto con asteriscos. */
    public String getNumeroMask() {
        if (numeroTarjeta == null || numeroTarjeta.length() < 4) return numeroTarjeta;
        return "**** **** **** " + numeroTarjeta.substring(numeroTarjeta.length() - 4);
    }
}
