SET SERVEROUTPUT ON;
DECLARE
  v_in  CLOB;
  v_out CLOB;
  v_err VARCHAR2(4000);
BEGIN
  -- Definimos el JSON de entrada basado en entradaSolicitud.json
  -- Importante: "solicitud" debe ser null para que sea una creación nueva
  v_in := '{
    "solicitud": null,
    "cliente": "usr-88234",
    "direccion": "dir-55421",
    "tipo": "B",
    "estado": "A",
    "descripcion": "PRUEBA DE CREACION DESDE SCRIPT PLSQL",
    "factura": "F-TEST-001",
    "empresa": "Servicios Tech S.A.",
    "subtotal": 85.0,
    "descuento": 0.0,
    "impuesto": 10.2,
    "total": 95.2,
    "tecnico": null,
    "inicio": "2026-05-15T08:00:00Z",
    "fin": "2026-05-15T12:00:00Z",
    "servicios": [
      {
        "linea": null,
        "no_arti": "srv-101",
        "precio": 45.0,
        "cantidad": 1,
        "subtotal": 45.0,
        "descuento": 0.0,
        "impuesto": 5.4,
        "total": 50.4,
        "tecnico": null
      },
      {
        "linea": null,
        "no_arti": "srv-105",
        "precio": 40.0,
        "cantidad": 1,
        "subtotal": 40.0,
        "descuento": 0.0,
        "impuesto": 4.8,
        "total": 44.8,
        "tecnico": null
      }
    ]
  }';

  DBMS_OUTPUT.PUT_LINE('Iniciando prueba de creación de solicitud...');

  -- Llamada al procedimiento del package
  cz_mi.SKMI.SOLICITUD(
    P_IN    => v_in,
    P_OUT   => v_out,
    P_ERROR => v_err
  );

  -- Manejo de resultados
  IF v_err IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('❌ ERROR EN SP: ' || v_err);
    ROLLBACK;
  ELSE
    DBMS_OUTPUT.PUT_LINE('✅ EXITO: Solicitud procesada correctamente.');
    DBMS_OUTPUT.PUT_LINE('Respuesta JSON: ' || v_out);
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('💥 ERROR CRITICO: ' || SQLERRM);
    ROLLBACK;
END;
/
