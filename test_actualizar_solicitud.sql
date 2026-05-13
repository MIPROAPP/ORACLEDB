SET SERVEROUTPUT ON;
DECLARE
  v_in  CLOB;
  v_out CLOB;
  v_err VARCHAR2(4000);
BEGIN
  -- JSON para actualización de la solicitud SOL-3
  v_in := '{
    "solicitud": "SOL-3",
    "cliente": "usr-88234",
    "direccion": "AVENIDA MODIFICADA 123",
    "tipo": "B",
    "estado": "A",
    "descripcion": "SOLICITUD ACTUALIZADA - PRUEBA DE UPSERT",
    "factura": "F-UPD-999",
    "empresa": "Servicios Tech S.A.",
    "subtotal": 135.0,
    "descuento": 5.0,
    "impuesto": 15.6,
    "total": 145.6,
    "tecnico": 10,
    "inicio": "2026-05-15T10:00:00Z",
    "fin": "2026-05-15T14:00:00Z",
    "servicios": [
      {
        "linea": 1,
        "no_arti": "srv-101",
        "precio": 50.0,
        "cantidad": 1,
        "subtotal": 50.0,
        "descuento": 0.0,
        "impuesto": 6.0,
        "total": 56.0,
        "tecnico": 10
      },
      {
        "linea": 2,
        "no_arti": "srv-105",
        "precio": 40.0,
        "cantidad": 1,
        "subtotal": 40.0,
        "descuento": 0.0,
        "impuesto": 4.8,
        "total": 44.8,
        "tecnico": null
      },
      {
        "linea": null,
        "no_arti": "srv-NEW",
        "precio": 45.0,
        "cantidad": 1,
        "subtotal": 45.0,
        "descuento": 5.0,
        "impuesto": 4.8,
        "total": 44.8,
        "tecnico": 10
      }
    ]
  }';

  DBMS_OUTPUT.PUT_LINE('Iniciando prueba de ACTUALIZACIÓN de solicitud SOL-3...');

  -- Llamada al procedimiento
  cz_mi.SKMI.SOLICITUD(
    P_IN    => v_in,
    P_OUT   => v_out,
    P_ERROR => v_err
  );

  IF v_err IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('❌ ERROR EN SP: ' || v_err);
    ROLLBACK;
  ELSE
    DBMS_OUTPUT.PUT_LINE('✅ EXITO: Solicitud actualizada correctamente.');
    DBMS_OUTPUT.PUT_LINE('Respuesta JSON: ' || v_out);
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('💥 ERROR CRITICO: ' || SQLERRM);
    ROLLBACK;
END;
/
