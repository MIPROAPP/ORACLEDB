CREATE OR REPLACE PACKAGE BODY cz_mi.SKMI AS


  ------------------------------------------------------------------------------
  PROCEDURE SOLICITUD(P_IN    IN     CLOB,
                      P_OUT      OUT CLOB,
                      P_ERROR IN OUT VARCHAR2) IS
    v_step             VARCHAR2(200) := 'INICIO';
    ji                 json_object_t;
    ja                 json_array_t;
    jo                 json_object_t;
    v_id_sol           VARCHAR2(40);
    v_nuevo            BOOLEAN;
    v_cliente          VARCHAR2(36);
    v_direccion        VARCHAR2(36);
    v_desc             VARCHAR2(2000);
    v_empresa          VARCHAR2(200);
    v_factura_cab      VARCHAR2(100);
    v_subtotal         NUMBER;
    v_total            NUMBER;
    v_descuento        NUMBER := 0;
    v_impuesto         NUMBER := 0;
    v_tipo             VARCHAR2(36);
    v_estado           VARCHAR2(36);
    v_tecnico          NUMBER;
    v_inicio           DATE;
    v_fin              DATE;
    n                  PLS_INTEGER;
    v_no_arti          VARCHAR2(15);
    v_precio           NUMBER;
    v_cant             NUMBER;
    v_linea            NUMBER;
    v_err              VARCHAR2(4000);
    v_sp_hecho         BOOLEAN := FALSE;
  BEGIN
    P_ERROR := NULL;
    v_step  := 'JSON';
    ji      := json_object_t(P_IN);

    v_step := 'PARSE-ID';
    v_id_sol := ji.get_string('solicitud');
    v_nuevo  := (v_id_sol IS NULL);

    v_step := 'PARSE-CLIENTE-DIR';
    v_cliente := ji.get_string('cliente');
    IF v_cliente IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'cliente obligatorio e inválido');
    END IF;

    v_direccion := ji.get_string('direccion');
    IF v_direccion IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'direccion obligatoria e inválida');
    END IF;

    v_step := 'PARSE-CABECERA';

    v_desc := TRIM(ji.get_string('descripcion'));
    IF v_desc IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'descripcion obligatoria o inválida'); END IF;

    v_empresa := ji.get_string('empresa');

    v_subtotal := ji.get_number('subtotal');
    IF v_subtotal IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'subtotal de cabecera obligatorio o inválido'); END IF;

    v_total := ji.get_number('total');
    IF v_total IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'total de cabecera obligatorio o inválido'); END IF;

    v_descuento := ji.get_number('descuento');
    IF v_descuento IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'descuento de cabecera obligatorio o inválido'); END IF;

    v_impuesto := ji.get_number('impuesto');
    IF v_impuesto IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'impuesto de cabecera obligatorio o inválido'); END IF;

    v_factura_cab := ji.get_string('factura');

    v_tipo := TRIM(ji.get_string('tipo'));
    IF v_tipo IS NULL OR LENGTH(v_tipo) = 0 THEN RAISE_APPLICATION_ERROR(-20001, 'tipo obligatorio o inválido'); END IF;

    v_estado := TRIM(ji.get_string('estado'));
    IF v_estado IS NULL OR LENGTH(v_estado) = 0 THEN RAISE_APPLICATION_ERROR(-20001, 'estado obligatorio o inválido'); END IF;

    v_tecnico := ji.get_number('tecnico');
    IF ji.has('inicio') AND ji.get_string('inicio') IS NOT NULL THEN
       v_inicio := CAST(ji.get_timestamp('inicio') AS DATE);
    END IF;
    IF ji.has('fin') AND ji.get_string('fin') IS NOT NULL THEN
       v_fin := CAST(ji.get_timestamp('fin') AS DATE);
    END IF;

    -- Validación de servicios (obligatorio al menos uno)
    IF NOT ji.has('servicios') THEN
       RAISE_APPLICATION_ERROR(-20001, 'El campo servicios es obligatorio');
    END IF;
    
    ja := ji.get_array('servicios');
    IF ja IS NULL OR ja.get_size = 0 THEN
       RAISE_APPLICATION_ERROR(-20001, 'La solicitud debe tener al menos un servicio');
    END IF;
    
    n := ja.get_size - 1;

    SAVEPOINT sp_skmi_solicitud;
    v_sp_hecho := TRUE;

    IF v_nuevo THEN
      v_step := 'INS-ARMISO';

      INSERT INTO cz_mi.armiso (
        cliente,
        direccion,
        tipo,
        estado,
        descripcion,
        factura,
        empresa,
        subtotal,
        descuento,
        impuesto,
        total,
        tecnico,
        inicio,
        fin
      )
      VALUES (
        v_cliente,
        v_direccion,
        v_tipo,
        v_estado,
        v_desc,
        v_factura_cab,
        v_empresa,
        v_subtotal,
        v_descuento,
        v_impuesto,
        v_total,
        v_tecnico,
        v_inicio,
        v_fin
      )
      RETURNING solicitud INTO v_id_sol;
    ELSE
      v_step := 'EXISTE-SOL';
      BEGIN
        SELECT s.solicitud
          INTO v_id_sol
          FROM cz_mi.armiso s
         WHERE s.solicitud = v_id_sol;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20001, 'Solicitud no existe: ' || v_id_sol);
      END;

      v_step := 'UPD-ARMISO';

      UPDATE cz_mi.armiso s
         SET s.cliente             = v_cliente,
             s.direccion           = v_direccion,
             s.tipo                = v_tipo,
             s.estado              = v_estado,
             s.descripcion         = v_desc,
             s.factura             = v_factura_cab,
             s.empresa             = v_empresa,
             s.subtotal            = v_subtotal,
             s.descuento           = v_descuento,
             s.impuesto            = v_impuesto,
             s.total               = v_total,
             s.tecnico             = v_tecnico,
             s.inicio              = v_inicio,
             s.fin                 = v_fin
       WHERE s.solicitud = v_id_sol;

      IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo actualizar la solicitud');
      END IF;
    END IF;

    v_step := 'INS-ARMISOS';

    FOR i IN 0 .. n LOOP
      jo := json_object_t(ja.get(i));
      v_no_arti := TRIM(jo.get_string('no_arti'));
      v_precio := jo.get_number('precio');
      v_cant   := NVL(jo.get_number('cantidad'), 1);
      v_subtotal := jo.get_number('subtotal');
      IF v_subtotal IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'subtotal de servicio obligatorio o inválido'); END IF;

      v_descuento := jo.get_number('descuento');
      IF v_descuento IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'descuento de servicio obligatorio o inválido'); END IF;

      v_impuesto := jo.get_number('impuesto');
      IF v_impuesto IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'impuesto de servicio obligatorio o inválido'); END IF;

      v_total := jo.get_number('total');
      IF v_total IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'total de servicio obligatorio o inválido'); END IF;

      v_linea := jo.get_number('linea');
      IF v_linea IS NULL THEN
        SELECT NVL(MAX(linea), 0) + 1 
          INTO v_linea 
          FROM cz_mi.armisos 
         WHERE solicitud = v_id_sol;
      END IF;

      MERGE INTO cz_mi.armisos t
      USING (SELECT v_id_sol   AS solicitud,
                    v_linea    AS linea,
                    v_no_arti  AS no_arti,
                    v_precio   AS precio,
                    v_cant     AS cantidad,
                    v_subtotal AS subtotal,
                    v_descuento AS descuento,
                    v_impuesto AS impuesto,
                    v_total    AS total,
                    jo.get_number('tecnico') AS tecnico
               FROM DUAL) s
      ON (t.solicitud = s.solicitud AND t.linea = s.linea AND t.no_arti = s.no_arti)
      WHEN MATCHED THEN
        UPDATE SET t.precio    = s.precio,
                   t.cantidad  = s.cantidad,
                   t.subtotal  = s.subtotal,
                   t.descuento = s.descuento,
                   t.impuesto  = s.impuesto,
                   t.total     = s.total,
                   t.tecnico   = s.tecnico
      WHEN NOT MATCHED THEN
        INSERT (solicitud, linea, no_arti, precio, cantidad, subtotal, descuento, impuesto, total, tecnico)
        VALUES (s.solicitud, s.linea, s.no_arti, s.precio, s.cantidad, s.subtotal, s.descuento, s.impuesto, s.total, s.tecnico);
    END LOOP;

    v_step := 'OUT';

    SELECT JSON_OBJECT(
             'solicitud' VALUE v_id_sol,
             'error'     VALUE ''
             RETURNING CLOB)
      INTO P_OUT
      FROM DUAL;

  EXCEPTION
    WHEN OTHERS THEN
      IF v_sp_hecho THEN
        BEGIN
          ROLLBACK TO sp_skmi_solicitud;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
      v_err := SUBSTR(NVL(v_err, v_step || ':' || SQLERRM), 1, 4000);
      P_ERROR := v_err;
      SELECT JSON_OBJECT(
               'solicitud' VALUE '',
               'error'     VALUE P_ERROR
               RETURNING CLOB)
        INTO P_OUT
        FROM DUAL;
  END SOLICITUD;

  ------------------------------------------------------------------------------
  PROCEDURE CONSULTA_SOLICITUD(P_IN    IN     CLOB,
                             P_OUT      OUT CLOB,
                             P_ERROR IN OUT VARCHAR2) IS
    v_step    VARCHAR2(200) := 'INICIO';
    ji        json_object_t;
    v_id_sol  VARCHAR2(40);
    v_err     VARCHAR2(4000);
  BEGIN
    P_ERROR := NULL;
    v_step  := 'JSON';
    ji      := json_object_t(P_IN);

    v_step := 'PARSE-SOLICITUD';
    v_id_sol := ji.get_string('solicitud');
    IF v_id_sol IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'solicitud obligatoria o invalida'); END IF;

    v_step := 'SEL-SOLICITUD';
    SELECT JSON_OBJECT(
             'solicitud' VALUE JSON_OBJECT(
               'solicitud' VALUE s.solicitud,
               'cliente' VALUE s.cliente,
               'direccion' VALUE s.direccion,
               'descripcion' VALUE s.descripcion,
               'empresa' VALUE s.empresa,
               'factura' VALUE s.factura,
               'tipo' VALUE NVL(tt.nombre, s.tipo),
               'impuesto' VALUE s.impuesto,
               'descuento' VALUE s.descuento,
               'subtotal' VALUE s.subtotal,
               'total' VALUE s.total,
               'servicios' VALUE (
                 SELECT COALESCE(
                          JSON_ARRAYAGG(
                            JSON_OBJECT(
                              'linea' VALUE x.linea,
                              'no_arti' VALUE x.no_arti,
                              'precio' VALUE x.precio,
                              'cantidad' VALUE NVL(x.cantidad, 0),
                              'subtotal' VALUE NVL(x.subtotal, 0),
                              'descuento' VALUE NVL(x.descuento, 0),
                              'impuesto' VALUE NVL(x.impuesto, 0),
                              'total' VALUE NVL(x.total, 0))
                            ORDER BY x.linea
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armisos x
                  WHERE x.solicitud = s.solicitud
               )
               RETURNING CLOB),
             'error' VALUE ''
             RETURNING CLOB)
      INTO P_OUT
      FROM cz_mi.armiso s
      LEFT JOIN cz_mi.armisot tt ON tt.tipo = s.tipo
     WHERE s.solicitud = v_id_sol;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      P_ERROR := SUBSTR(v_step || ':Solicitud no existe: ' || v_id_sol,
                        1,
                        4000);
      SELECT JSON_OBJECT(
               'solicitud' VALUE '',
               'error' VALUE P_ERROR
               RETURNING CLOB)
        INTO P_OUT
        FROM DUAL;
    WHEN OTHERS THEN
      v_err := SUBSTR(v_step || ':' || SQLERRM, 1, 4000);
      P_ERROR := v_err;
      SELECT JSON_OBJECT(
               'solicitud' VALUE '',
               'error' VALUE P_ERROR
               RETURNING CLOB)
        INTO P_OUT
        FROM DUAL;
  END CONSULTA_SOLICITUD;

  ------------------------------------------------------------------------------
  PROCEDURE CATALOGOS(P_OUT OUT CLOB, P_ERROR IN OUT VARCHAR2) IS
    v_step VARCHAR2(200) := 'INICIO';
  BEGIN
    P_ERROR := NULL;
    v_step  := 'CATALOGOS-JSON';

    SELECT JSON_OBJECT(
             'catalogos' VALUE JSON_OBJECT(
               'tipo_solicitud' VALUE (
                 SELECT COALESCE(
                          JSON_ARRAYAGG(
                            JSON_OBJECT('id' VALUE t.tipo, 'nombre' VALUE t.nombre)
                            ORDER BY t.id
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armisot t
               ),
               'estado_solicitud' VALUE (
                 SELECT COALESCE(
                          JSON_ARRAYAGG(
                            JSON_OBJECT('id' VALUE e.estado, 'nombre' VALUE e.nombre)
                            ORDER BY e.id
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armisoe e
               )
             ),
             'error' VALUE ''
             RETURNING CLOB)
      INTO P_OUT
      FROM DUAL;

  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR := SUBSTR(v_step || ':' || SQLERRM, 1, 4000);
      SELECT JSON_OBJECT(
               'catalogos' VALUE JSON_OBJECT(
                 'tipo_solicitud' VALUE TO_CLOB('[]'),
                 'estado_solicitud' VALUE TO_CLOB('[]')
               ),
               'error' VALUE P_ERROR
               RETURNING CLOB)
        INTO P_OUT
        FROM DUAL;
  END CATALOGOS;

END SKMI;
/
