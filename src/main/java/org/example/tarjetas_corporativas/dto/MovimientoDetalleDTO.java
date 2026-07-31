package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class MovimientoDetalleDTO {
    private final String     tipo;
    private final BigDecimal monto;
    private final String     concepto;
    private final String     referencia;
    private final Timestamp  fecha;
    private final String     origenNum;
    private final String     destinoNum;
    private final String     direccion;

    public MovimientoDetalleDTO(String tipo, BigDecimal monto, String concepto,
                                String referencia, Timestamp fecha,
                                String origenNum, String destinoNum, String direccion) {
        this.tipo       = tipo;
        this.monto      = monto;
        this.concepto   = concepto;
        this.referencia = referencia;
        this.fecha      = fecha;
        this.origenNum  = origenNum;
        this.destinoNum = destinoNum;
        this.direccion  = direccion;
    }

    public String     getTipo()       { return tipo; }
    public BigDecimal getMonto()      { return monto; }
    public String     getConcepto()   { return concepto; }
    public String     getReferencia() { return referencia; }
    public Timestamp  getFecha()      { return fecha; }
    public String     getOrigenNum()  { return origenNum; }
    public String     getDestinoNum() { return destinoNum; }
    public String     getDireccion()  { return direccion; }
}
