package org.example.tarjetas_corporativas.service;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;
import java.util.logging.Logger;

/** Servicio para envío de correos institucionales vía SMTP. */
public class EmailService {

    private static final Logger LOG = Logger.getLogger(EmailService.class.getName());

    /**
     * Envía el código de recuperación al destinatario indicado.
     * Las variables de entorno se leen en cada llamada para que cambios en la
     * configuración de Tomcat no requieran reiniciar la JVM completa.
     *
     * @param destinatario correo destino del usuario
     * @param codigo       código de 6 dígitos
     * @throws MessagingException si el envío SMTP falla
     */
    public void enviarCodigoReset(String destinatario, String codigo) throws MessagingException {
        // Leer variables en tiempo de ejecución (no static) para garantizar valores actuales
        String mailHost     = System.getenv("MAIL_HOST");
        String mailPort     = System.getenv("MAIL_PORT") != null ? System.getenv("MAIL_PORT") : "587";
        String mailUser     = System.getenv("MAIL_USER");
        String mailPassword = System.getenv("MAIL_PASSWORD");
        String mailFrom     = System.getenv("MAIL_FROM") != null ? System.getenv("MAIL_FROM") : mailUser;

        LOG.info("[EmailService] MAIL_HOST=" + mailHost +
                 " | MAIL_USER=" + mailUser +
                 " | MAIL_FROM=" + mailFrom +
                 " | destino=" + destinatario);

        if (mailHost == null || mailUser == null || mailPassword == null) {
            LOG.severe("[EmailService] Variables SMTP no configuradas. " +
                       "Código para " + destinatario + " (sin enviar): " + codigo);
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            mailHost);
        props.put("mail.smtp.port",            mailPort);
        props.put("mail.smtp.ssl.trust",       mailHost);
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout",           "10000");

        final String finalUser     = mailUser;
        final String finalPassword = mailPassword;

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(finalUser, finalPassword);
            }
        });

        session.setDebug(true); // imprime tráfico SMTP en la consola de Tomcat

        Message msg = new MimeMessage(session);
        try {
            msg.setFrom(new InternetAddress(mailFrom, "FinTech Corp", "UTF-8"));
        } catch (java.io.UnsupportedEncodingException e) {
            msg.setFrom(new InternetAddress(mailFrom));
        }
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
        msg.setSubject("Codigo de verificacion - FinTech Corp");
        msg.setContent(buildHtml(codigo), "text/html;charset=UTF-8");

        LOG.info("[EmailService] Enviando correo via " + mailHost + ":" + mailPort + " ...");
        Transport.send(msg);
        LOG.info("[EmailService] Correo enviado exitosamente a " + destinatario);
    }

    private String buildHtml(String codigo) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head><body>" +
               "<div style='font-family:Arial,sans-serif;max-width:480px;margin:40px auto;" +
               "background:#0d1520;color:#fff;border-radius:12px;padding:2rem;'>" +
               "<h2 style='color:#00ffff;margin:0 0 0.5rem;'>FinTech Corp</h2>" +
               "<p style='color:#8892a4;margin:0 0 1.5rem;'>Codigo para recuperar tu contrasena:</p>" +
               "<div style='background:#111827;border:1px solid rgba(0,255,255,0.3);border-radius:8px;" +
               "padding:1.5rem;text-align:center;margin-bottom:1.5rem;'>" +
               "<span style='font-size:2.2rem;font-weight:700;letter-spacing:8px;color:#00ffff;'>" +
               codigo + "</span></div>" +
               "<p style='color:#8892a4;font-size:0.85rem;margin:0 0 0.5rem;'>" +
               "Este codigo expira en <strong style='color:#fff;'>15 minutos</strong>.</p>" +
               "<p style='color:#6B7084;font-size:0.75rem;margin:0;'>" +
               "Si no solicitaste este codigo, ignora este mensaje.</p>" +
               "</div></body></html>";
    }
}
