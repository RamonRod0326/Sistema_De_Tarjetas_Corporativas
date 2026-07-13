package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class MovimientoDashboardDTO {
    private final String     tipo;
    private final BigDecimal monto;
    private final String     concepto;
    private final Timestamp  fecha;
    private final String     origenNum;
    private final String     destinoNum;
    private final String     catOrigen;
    private final String     catDestino;

    public MovimientoDashboardDTO(String tipo, BigDecimal monto, String concepto,
                                  Timestamp fecha, String origenNum, String destinoNum,
                                  String catOrigen, String catDestino) {
        this.tipo       = tipo;
        this.monto      = monto;
        this.concepto   = concepto;
        this.fecha      = fecha;
        this.origenNum  = origenNum;
        this.destinoNum = destinoNum;
        this.catOrigen  = catOrigen;
        this.catDestino = catDestino;
    }

    public String     getTipo()       { return tipo; }
    public BigDecimal getMonto()      { return monto; }
    public String     getConcepto()   { return concepto; }
    public Timestamp  getFecha()      { return fecha; }
    public String     getOrigenNum()  { return origenNum; }
    public String     getDestinoNum() { return destinoNum; }
    public String     getCatOrigen()  { return catOrigen; }
    public String     getCatDestino() { return catDestino; }
}
