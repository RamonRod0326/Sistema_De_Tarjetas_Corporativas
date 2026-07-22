package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class MovimientoGlobalDTO {
    private final String     tipo;
    private final BigDecimal monto;
    private final String     concepto;
    private final Timestamp  fecha;
    private final String     adminNombre;
    private final String     cuentaDestino;
    private final String     titularDestino;

    public MovimientoGlobalDTO(String tipo, BigDecimal monto, String concepto,
                               Timestamp fecha, String adminNombre,
                               String cuentaDestino, String titularDestino) {
        this.tipo           = tipo;
        this.monto          = monto;
        this.concepto       = concepto;
        this.fecha          = fecha;
        this.adminNombre    = adminNombre;
        this.cuentaDestino  = cuentaDestino;
        this.titularDestino = titularDestino;
    }

    public String     getTipo()           { return tipo; }
    public BigDecimal getMonto()          { return monto; }
    public String     getConcepto()       { return concepto; }
    public Timestamp  getFecha()          { return fecha; }
    public String     getAdminNombre()    { return adminNombre; }
    public String     getCuentaDestino()  { return cuentaDestino; }
    public String     getTitularDestino() { return titularDestino; }
}
