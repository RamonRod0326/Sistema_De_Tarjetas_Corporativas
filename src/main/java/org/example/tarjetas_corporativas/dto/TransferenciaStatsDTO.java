package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;

public class TransferenciaStatsDTO {
    private final long       totalMes;
    private final BigDecimal enviado;
    private final BigDecimal recibido;
    private final BigDecimal neto;

    public TransferenciaStatsDTO(long totalMes, BigDecimal enviado, BigDecimal recibido) {
        this.totalMes = totalMes;
        this.enviado  = enviado;
        this.recibido = recibido;
        this.neto     = recibido.subtract(enviado);
    }

    public long       getTotalMes() { return totalMes; }
    public BigDecimal getEnviado()  { return enviado; }
    public BigDecimal getRecibido() { return recibido; }
    public BigDecimal getNeto()     { return neto; }
}
