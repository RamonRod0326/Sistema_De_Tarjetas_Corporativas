package org.example.tarjetas_corporativas.dto;

public class EmpleadoStatsDTO {
    private final long totalEmpleados;
    private final long activosEmpleados;
    private final long totalDepts;
    private final long nuevosMes;

    public EmpleadoStatsDTO(long totalEmpleados, long activosEmpleados,
                            long totalDepts, long nuevosMes) {
        this.totalEmpleados   = totalEmpleados;
        this.activosEmpleados = activosEmpleados;
        this.totalDepts       = totalDepts;
        this.nuevosMes        = nuevosMes;
    }

    public long getTotalEmpleados()   { return totalEmpleados; }
    public long getActivosEmpleados() { return activosEmpleados; }
    public long getTotalDepts()       { return totalDepts; }
    public long getNuevosMes()        { return nuevosMes; }
}
