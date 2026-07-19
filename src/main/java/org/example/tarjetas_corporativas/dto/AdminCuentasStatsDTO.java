package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;

public class AdminCuentasStatsDTO {
    private final long       cuentasActivas;
    private final long       empConCuenta;
    private final BigDecimal totalCirculacion;
    private final long       congeladas;

    public AdminCuentasStatsDTO(long cuentasActivas, long empConCuenta,
                                BigDecimal totalCirculacion, long congeladas) {
        this.cuentasActivas   = cuentasActivas;
        this.empConCuenta     = empConCuenta;
        this.totalCirculacion = totalCirculacion;
        this.congeladas       = congeladas;
    }

    public long       getCuentasActivas()   { return cuentasActivas; }
    public long       getEmpConCuenta()     { return empConCuenta; }
    public BigDecimal getTotalCirculacion() { return totalCirculacion; }
    public long       getCongeladas()       { return congeladas; }
}
