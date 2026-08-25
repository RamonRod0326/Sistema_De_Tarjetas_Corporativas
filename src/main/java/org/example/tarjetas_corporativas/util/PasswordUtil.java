package org.example.tarjetas_corporativas.util;

import at.favre.lib.crypto.bcrypt.BCrypt;

public final class PasswordUtil {

    private static final int COST = 12;

    private PasswordUtil() {}

    public static String hash(String plaintext) {
        return BCrypt.withDefaults().hashToString(COST, plaintext.toCharArray());
    }

    public static boolean verify(String plaintext, String hash) {
        return BCrypt.verifyer().verify(plaintext.toCharArray(), hash).verified;
    }

    /** Mínimo 8 caracteres y al menos un dígito. */
    public static boolean isValid(String password) {
        if (password == null || password.length() < 8) return false;
        for (char c : password.toCharArray()) {
            if (Character.isDigit(c)) return true;
        }
        return false;
    }

    public static final String POLICY_MSG = "La contraseña debe tener al menos 8 caracteres y contener al menos un número.";
}
