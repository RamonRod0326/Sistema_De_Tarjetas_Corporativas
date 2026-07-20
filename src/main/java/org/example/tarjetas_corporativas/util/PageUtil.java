package org.example.tarjetas_corporativas.util;

import jakarta.servlet.http.HttpServletRequest;

public final class PageUtil {

    public static final int MAX_PAGE_SIZE = 50;
    public static final int PAGE_SIZE     = 6;

    private PageUtil() {}

    public static int parsePage(HttpServletRequest request) {
        try {
            int p = Integer.parseInt(request.getParameter("page"));
            return p > 0 ? p : 1;
        } catch (NumberFormatException | NullPointerException e) {
            return 1;
        }
    }

    public static int parsePageSize(HttpServletRequest request, int defaultSize) {
        try {
            int s = Integer.parseInt(request.getParameter("size"));
            return Math.min(Math.max(s, 1), MAX_PAGE_SIZE);
        } catch (NumberFormatException | NullPointerException e) {
            return defaultSize;
        }
    }

    /** Calcula el offset para OFFSET ? ROWS FETCH NEXT ? ROWS ONLY. */
    public static int offset(int page, int pageSize) {
        return Math.max(0, (page - 1)) * pageSize;
    }

    /** Normaliza page para que quede en [1, totalPages]. */
    public static int clampPage(int page, int totalPages) {
        if (totalPages <= 0) return 1;
        return Math.min(Math.max(page, 1), totalPages);
    }

    /** Trimea y devuelve null cuando la cadena está vacía o es nula. */
    public static String blankToNull(String s) {
        if (s == null || s.isBlank()) return null;
        return s.trim();
    }
}
