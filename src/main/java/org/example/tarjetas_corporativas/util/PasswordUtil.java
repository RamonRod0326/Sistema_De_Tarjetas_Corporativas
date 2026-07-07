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
}
