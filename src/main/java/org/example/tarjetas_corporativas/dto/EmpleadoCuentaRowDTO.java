package org.example.tarjetas_corporativas.dto;

import java.math.BigDecimal;

public class EmpleadoCuentaRowDTO {
    private final long       id;
    private final String     nombre;
    private final String     cargo;
    private final String     departamento;
    private final long       numCuentas;
    private final long       numTarjetas;
    private final BigDecimal saldoTotal;
    private final String     estadoEmp;
    private final int        activo;

    public EmpleadoCuentaRowDTO(long id, String nombre, String cargo, String departamento,
                                long numCuentas, long numTarjetas,
                                BigDecimal saldoTotal, String estadoEmp, int activo) {
        this.id           = id;
        this.nombre       = nombre;
        this.cargo        = cargo;
        this.departamento = departamento;
        this.numCuentas   = numCuentas;
        this.numTarjetas  = numTarjetas;
        this.saldoTotal   = saldoTotal;
        this.estadoEmp    = estadoEmp;
        this.activo       = activo;
    }

    public long       getId()           { return id; }
    public String     getNombre()       { return nombre; }
    public String     getCargo()        { return cargo; }
    public String     getDepartamento() { return departamento; }
    public long       getNumCuentas()   { return numCuentas; }
    public long       getNumTarjetas()  { return numTarjetas; }
    public BigDecimal getSaldoTotal()   { return saldoTotal; }
    public String     getEstadoEmp()    { return estadoEmp; }
    public int        getActivo()       { return activo; }
}
