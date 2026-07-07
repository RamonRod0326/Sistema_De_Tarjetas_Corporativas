package org.example.tarjetas_corporativas.exception;

public class ServiceException extends RuntimeException {

    private final String toastKey;

    public ServiceException(String message, String toastKey) {
        super(message);
        this.toastKey = toastKey;
    }

    public ServiceException(String message, String toastKey, Throwable cause) {
        super(message, cause);
        this.toastKey = toastKey;
    }

    public ServiceException(String message, Throwable cause) {
        super(message, cause);
        this.toastKey = "error";
    }

    public String getToastKey() { return toastKey; }
}
