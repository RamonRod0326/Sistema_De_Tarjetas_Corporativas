package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;

public class AdminDashboardStatsDTO {
    private final BigDecimal saldoGlobal;
    private final long       cuentasActivas;
    private final long       tarjetasEmitidas;
    private final long       empleadosActivos;
    private final BigDecimal transferidoMes;

    public AdminDashboardStatsDTO(BigDecimal saldoGlobal, long cuentasActivas,
                                  long tarjetasEmitidas, long empleadosActivos,
                                  BigDecimal transferidoMes) {
        this.saldoGlobal      = saldoGlobal;
        this.cuentasActivas   = cuentasActivas;
        this.tarjetasEmitidas = tarjetasEmitidas;
        this.empleadosActivos = empleadosActivos;
        this.transferidoMes   = transferidoMes;
    }

    public BigDecimal getSaldoGlobal()      { return saldoGlobal; }
    public long       getCuentasActivas()   { return cuentasActivas; }
    public long       getTarjetasEmitidas() { return tarjetasEmitidas; }
    public long       getEmpleadosActivos() { return empleadosActivos; }
    public BigDecimal getTransferidoMes()   { return transferidoMes; }
}
