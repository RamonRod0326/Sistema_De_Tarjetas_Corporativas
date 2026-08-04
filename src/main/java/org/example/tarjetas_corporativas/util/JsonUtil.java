package org.example.tarjetas_corporativas.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class JsonUtil {

    private JsonUtil() {}

    public static String readBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }
        return sb.toString();
    }

    public static String getString(String json, String key) {
        Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
        Matcher m = p.matcher(json != null ? json : "");
        return m.find() ? m.group(1).replace("\\\"", "\"").replace("\\\\", "\\") : null;
    }

    public static long getLong(String json, String key) {
        Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(-?\\d+)");
        Matcher m = p.matcher(json != null ? json : "");
        return m.find() ? Long.parseLong(m.group(1)) : 0L;
    }

    public static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    public static void writeJson(HttpServletResponse res, String json) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setCharacterEncoding("UTF-8");
        try (PrintWriter out = res.getWriter()) { out.print(json); }
    }

    public static void writeOk(HttpServletResponse res, String msg) throws IOException {
        writeJson(res, "{\"ok\":true,\"msg\":\"" + escape(msg) + "\"}");
    }

    public static void writeError(HttpServletResponse res, int status, String msg) throws IOException {
        res.setStatus(status);
        writeJson(res, "{\"ok\":false,\"msg\":\"" + escape(msg) + "\"}");
    }
}
