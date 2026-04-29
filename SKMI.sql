CREATE OR REPLACE PACKAGE BODY cz_mi.SKMI AS

  ------------------------------------------------------------------------------
  FUNCTION EXTRAER_NUMERO_FINAL(P_TEXTO IN VARCHAR2) RETURN NUMBER IS
    v_txt    VARCHAR2(4000);
    v_numero VARCHAR2(4000);
  BEGIN
    IF P_TEXTO IS NULL THEN
      RETURN NULL;
    END IF;
    v_txt := TRIM(P_TEXTO);
    v_numero := REGEXP_SUBSTR(v_txt, '[0-9]+$');
    IF v_numero IS NOT NULL THEN
      RETURN TO_NUMBER(v_numero);
    END IF;
    RETURN TO_NUMBER(v_txt);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END EXTRAER_NUMERO_FINAL;

  ------------------------------------------------------------------------------
  FUNCTION NORMALIZAR_ID_SOLICITUD(P_ID IN VARCHAR2) RETURN VARCHAR2 IS
    v VARCHAR2(4000);
  BEGIN
    IF P_ID IS NULL THEN
      RETURN NULL;
    END IF;
    v := TRIM(P_ID);
    IF v IS NULL OR LENGTH(v) = 0 OR LOWER(v) IN ('null', 'undefined') THEN
      RETURN NULL;
    END IF;
    IF INSTR(v, 'SOL-') = 1 THEN
      RETURN v;
    END IF;
    IF REGEXP_LIKE(v, '^[0-9]+$') THEN
      RETURN 'SOL-' || v;
    END IF;
    RETURN v;
  END NORMALIZAR_ID_SOLICITUD;

  ------------------------------------------------------------------------------
  FUNCTION FECHA_DESDE_ISO(P_ISO IN VARCHAR2) RETURN DATE IS
    v VARCHAR2(100);
    v_ts TIMESTAMP WITH TIME ZONE;
  BEGIN
    IF P_ISO IS NULL THEN
      RETURN SYSDATE;
    END IF;
    v := REPLACE(TRIM(P_ISO), ' ', 'T');
    BEGIN
      v_ts := TO_TIMESTAMP_TZ(REPLACE(v, 'Z', '+00:00'), 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM');
      RETURN CAST(v_ts AT TIME ZONE SESSIONTIMEZONE AS DATE);
    EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          v_ts := TO_TIMESTAMP_TZ(REPLACE(v, 'Z', '+00:00'), 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH');
          RETURN CAST(v_ts AT TIME ZONE SESSIONTIMEZONE AS DATE);
        EXCEPTION
          WHEN OTHERS THEN
            RETURN TO_DATE(REPLACE(RTRIM(P_ISO, 'Z'), 'T', ' '), 'YYYY-MM-DD HH24:MI:SS');
        END;
    END;
  END FECHA_DESDE_ISO;

  ------------------------------------------------------------------------------
  FUNCTION MAP_NO_ARTI(P_SERVICIO IN VARCHAR2) RETURN VARCHAR2 IS
    v VARCHAR2(4000);
  BEGIN
    IF P_SERVICIO IS NULL THEN
      RETURN NULL;
    END IF;
    v := TRIM(P_SERVICIO);
    IF LENGTH(v) <= 15 THEN
      RETURN v;
    END IF;
    RETURN SUBSTR(v, 1, 15);
  END MAP_NO_ARTI;

  ---------------------------------------------------------------------------  
  FUNCTION VALOR_SERVICIO_LINEA(P_JO IN json_object_t) RETURN VARCHAR2 IS
  BEGIN
    IF P_JO.has('servicio') THEN
      RETURN P_JO.get_string('servicio');
    END IF;
    RETURN NULL;
  END VALOR_SERVICIO_LINEA;

  ------------------------------------------------------------------------------
  PROCEDURE SOLICITUD(P_IN    IN     CLOB,
                      P_OUT      OUT CLOB,
                      P_ERROR IN OUT VARCHAR2) IS
    v_step             VARCHAR2(200) := 'INICIO';
    ji                 json_object_t;
    ja                 json_array_t;
    jo                 json_object_t;
    v_id_json          VARCHAR2(4000);
    v_id_sol           VARCHAR2(40);
    v_nuevo            BOOLEAN;
    v_usuario          NUMBER;
    v_direccion        NUMBER;
    v_fecha            DATE;
    v_desc             VARCHAR2(2000);
    v_empresa          VARCHAR2(200);
    v_subtotal         NUMBER;
    v_total            NUMBER;
    v_descuento        NUMBER := 0;
    v_impuesto         NUMBER := 0;
    v_cotizacion       VARCHAR2(50);
    v_factura_serv     VARCHAR2(50);
    v_factura_cab      VARCHAR2(100);
    v_tipo             VARCHAR2(36);
    v_estado           VARCHAR2(36);
    v_sum_lineas       NUMBER := 0;
    n                  PLS_INTEGER;
    v_no_arti          VARCHAR2(15);
    v_precio           NUMBER;
    v_cant             NUMBER;
    v_cat_linea        VARCHAR2(36);
    v_err              VARCHAR2(4000);
    v_dummy            NUMBER;
    v_sp_hecho         BOOLEAN := FALSE;
  BEGIN
    P_ERROR := NULL;
    v_step  := 'JSON';
    ji      := json_object_t(P_IN);

    v_step := 'PARSE-ID';
    IF ji.has('id') THEN
      v_id_json := ji.get_string('id');
    ELSE
      v_id_json := NULL;
    END IF;
    v_id_sol := NORMALIZAR_ID_SOLICITUD(v_id_json);
    v_nuevo  := (v_id_sol IS NULL);

    v_step := 'PARSE-USUARIO-DIR';
    IF ji.has('usuario') THEN
      v_usuario := EXTRAER_NUMERO_FINAL(ji.get_string('usuario'));
    ELSE
      RAISE_APPLICATION_ERROR(-20001, 'usuario obligatorio');
    END IF;
    IF v_usuario IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'usuario inválido');
    END IF;

    IF ji.has('direccion') THEN
      v_direccion := EXTRAER_NUMERO_FINAL(ji.get_string('direccion'));
    ELSE
      RAISE_APPLICATION_ERROR(-20001, 'direccion obligatoria');
    END IF;
    IF v_direccion IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'direccion inválida');
    END IF;

    v_step := 'SEL-USUARIO';
    BEGIN
      SELECT 1 INTO v_dummy FROM cz_mi.armius u WHERE u.id = v_usuario;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'usuario no existe en cz_mi.armius');
    END;

    v_step := 'SEL-DIRECCION';
    BEGIN
      SELECT 1 INTO v_dummy FROM cz_mi.armidi d WHERE d.id = v_direccion;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'direccion no existe en cz_mi.armidi');
    END;

    v_step := 'PARSE-CABECERA';
    IF ji.has('fecha') THEN
      v_fecha := FECHA_DESDE_ISO(ji.get_string('fecha'));
    ELSE
      v_fecha := SYSDATE;
    END IF;

    IF NOT ji.has('descripcion') THEN
      RAISE_APPLICATION_ERROR(-20001, 'descripcion obligatoria');
    END IF;
    v_desc := ji.get_string('descripcion');

    IF ji.has('empresa') THEN
      v_empresa := ji.get_string('empresa');
    ELSE
      v_empresa := NULL;
    END IF;

    IF ji.has('subtotal') THEN
      v_subtotal := ji.get_number('subtotal');
    ELSE
      v_subtotal := NULL;
    END IF;

    IF ji.has('total') THEN
      v_total := ji.get_number('total');
    ELSE
      v_total := NULL;
    END IF;

    IF ji.has('descuento') THEN
      v_descuento := NVL(ji.get_number('descuento'), 0);
    ELSE
      v_descuento := 0;
    END IF;

    IF ji.has('impuesto') THEN
      v_impuesto := NVL(ji.get_number('impuesto'), 0);
    ELSE
      v_impuesto := 0;
    END IF;

    IF ji.has('cotizacion') THEN 
      v_cotizacion := ji.get_string('cotizacion');
    ELSE
      v_cotizacion := NULL;
    END IF;

    IF ji.has('factura') THEN 
      v_factura_cab := ji.get_string('factura');
    ELSE
      v_factura_cab := NULL;
    END IF;

    IF ji.has('cotizacion_factura') AND
       LENGTH(TRIM(NVL(ji.get_string('cotizacion_factura'), ''))) > 0 THEN
      v_factura_serv := SUBSTR(TRIM(ji.get_string('cotizacion_factura')), 1, 50);
    ELSE
      v_factura_serv := NULL;
    END IF;
-----------------------------------------------------------
--En esta parte del procedimiento, tipo y estado no vienen en el JSON de entrada, por lo que se definen por defecto. Consultar cuales serian los valores por defecto.
    IF ji.has('tipo_solicitud') THEN
      v_tipo := NVL(NULLIF(TRIM(ji.get_string('tipo_solicitud')), ''), 'S');
    ELSE
      v_tipo := 'S';
    END IF;
    IF ji.has('estado_solicitud') THEN
      v_estado := NVL(NULLIF(TRIM(ji.get_string('estado_solicitud')), ''), 'P');
    ELSE
      v_estado := 'P';
    END IF;
----------------------------------------------------------
    SAVEPOINT sp_skmi_solicitud;
    v_sp_hecho := TRUE;

    IF v_nuevo THEN
      v_step := 'INS-ARMISO';

      INSERT INTO cz_mi.armiso (
        usuario,
        direccion,
        fecha,
        tipo,
        estado,
        descripcion,
        factura,
        empresa,
        subtotal,
        descuento,
        impuesto,
        total,
        cotizacion_servicio,
        factura_servicio
      )
      VALUES (
        v_usuario,
        v_direccion,
        v_fecha,
        v_tipo,
        v_estado,
        v_desc,
        v_factura_cab,
        v_empresa,
        v_subtotal,
        v_descuento,
        v_impuesto,
        v_total,
        v_cotizacion,
        SUBSTR(v_factura_serv, 1, 50)
      )
      RETURNING id INTO v_id_sol;
    ELSE
      v_step := 'EXISTE-SOL';
      BEGIN
        SELECT s.id
          INTO v_id_sol
          FROM cz_mi.armiso s
         WHERE s.id = v_id_sol;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20001, 'Solicitud no existe: ' || v_id_sol);
      END;

      v_step := 'UPD-ARMISO';

      UPDATE cz_mi.armiso s
         SET s.usuario             = v_usuario,
             s.direccion           = v_direccion,
             s.fecha               = v_fecha,
             s.tipo                = v_tipo,
             s.estado              = v_estado,
             s.descripcion         = v_desc,
             s.factura             = v_factura_cab,
             s.empresa             = v_empresa,
             s.subtotal            = v_subtotal,
             s.descuento           = v_descuento,
             s.impuesto            = v_impuesto,
             s.total               = v_total,
             s.cotizacion_servicio = v_cotizacion,
             s.factura_servicio    = SUBSTR(v_factura_serv, 1, 50)
       WHERE s.id = v_id_sol;

      IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo actualizar la solicitud');
      END IF;

      v_step := 'DEL-ARMISOS'; --Consultar si es necesario eliminar las lineas de servicio de la solicitud.
      DELETE FROM cz_mi.armisos x WHERE x.solicitud = v_id_sol;
    END IF;

    v_step := 'INS-ARMISOS';
    IF ji.has('servicios') THEN
      ja := ji.get_array('servicios');
    ELSE
      ja := json_array_t.parse('[]');
    END IF;
    n := ja.get_size - 1;

    FOR i IN 0 .. n LOOP
      jo := json_object_t(ja.get(i));
      v_no_arti := MAP_NO_ARTI(VALOR_SERVICIO_LINEA(jo));
      v_precio := jo.get_number('precio');
      v_cant   := 1;
      IF NOT jo.has('categoria') OR
         LENGTH(TRIM(NVL(jo.get_string('categoria'), ''))) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'categoria obligatoria en cada servicio');
      END IF;
      v_cat_linea := TRIM(jo.get_string('categoria'));

      INSERT INTO cz_mi.armisos (
        solicitud,
        categoria,
        no_arti,
        precio,
        cantidad
      )
      VALUES (
        v_id_sol,
        v_cat_linea,
        v_no_arti,
        v_precio,
        v_cant
      );
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
    IF NOT ji.has('solicitud') THEN
      RAISE_APPLICATION_ERROR(-20001, 'solicitud obligatoria');
    END IF;
    v_id_sol := NORMALIZAR_ID_SOLICITUD(ji.get_string('solicitud'));
    IF v_id_sol IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'solicitud invalida');
    END IF;

    v_step := 'SEL-SOLICITUD';
    SELECT JSON_OBJECT(
             'solicitud' VALUE JSON_OBJECT(
               'id' VALUE s.id,
               'usuario' VALUE s.usuario,
               'direccion' VALUE s.direccion,
               'fecha' VALUE (CASE
                                WHEN s.fecha IS NULL THEN ''
                                ELSE TO_CHAR(s.fecha,
                                             'YYYY-MM-DD"T"HH24:MI:SS') || 'Z'
                              END),
               'descripcion' VALUE s.descripcion,
               'empresa' VALUE s.empresa,
               'factura' VALUE s.factura,
               'tipo' VALUE NVL(tt.nombre, s.tipo),
               'impuesto' VALUE s.impuesto,
               'descuento' VALUE s.descuento,
               'subtotal' VALUE s.subtotal,
               'total' VALUE s.total,
               'cotizacion_servicio' VALUE s.cotizacion_servicio,
               'factura_servicio' VALUE s.factura_servicio,
               'servicios' VALUE (
                 SELECT COALESCE(
                          JSON_ARRAYAGG(
                            JSON_OBJECT(
                              'categoria' VALUE x.categoria,
                              'no_arti' VALUE x.no_arti,
                              'servicio' VALUE x.no_arti,
                              'precio' VALUE x.precio,
                              'cantidad' VALUE NVL(x.cantidad, 0))
                            ORDER BY x.id
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armisos x
                  WHERE x.solicitud = s.id
               ),
               'citas' VALUE (
                 SELECT COALESCE(
                          JSON_ARRAYAGG(
                            JSON_OBJECT(
                              'id' VALUE c.id,
                              'servicio' VALUE os.no_arti,
                              'estado' VALUE ec.nombre,
                              'tecnico' VALUE NVL(
                                TRIM(tc.nombre || ' ' || tc.apellido),
                                ''),
                              'fecha_programada_inicio' VALUE (CASE
                                WHEN c.fecha_programada_inicio IS NULL THEN ''
                                ELSE TO_CHAR(c.fecha_programada_inicio,
                                             'YYYY-MM-DD"T"HH24:MI:SS') || 'Z'
                              END),
                              'fecha_programada_fin' VALUE (CASE
                                WHEN c.fecha_programada_fin IS NULL THEN ''
                                ELSE TO_CHAR(c.fecha_programada_fin,
                                             'YYYY-MM-DD"T"HH24:MI:SS') || 'Z'
                              END))
                            ORDER BY c.id
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armici c
                   JOIN cz_mi.armisos os ON os.id = c.servicio
                   JOIN cz_mi.armicie ec ON ec.id = c.estado
                   LEFT JOIN cz_mi.armitc tc ON tc.no_prove = c.no_prove
                                              AND tc.identificacion =
                                                  c.identificacion
                                              AND tc.tipo_identificacion =
                                                  c.tipo_identificacion
                  WHERE c.solicitud = s.id
               )
               RETURNING CLOB),
             'error' VALUE ''
             RETURNING CLOB)
      INTO P_OUT
      FROM cz_mi.armiso s
      LEFT JOIN cz_mi.armisot tt ON tt.id = s.tipo
     WHERE s.id = v_id_sol;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      P_ERROR := SUBSTR(v_step || ':Solicitud no existe: ' || v_id_sol,
                        1,
                        4000);
      SELECT JSON_OBJECT(
               'solicitud' VALUE JSON_OBJECT('id' VALUE ''),
               'error' VALUE P_ERROR
               RETURNING CLOB)
        INTO P_OUT
        FROM DUAL;
    WHEN OTHERS THEN
      v_err := SUBSTR(v_step || ':' || SQLERRM, 1, 4000);
      P_ERROR := v_err;
      SELECT JSON_OBJECT(
               'solicitud' VALUE JSON_OBJECT('id' VALUE ''),
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
                            JSON_OBJECT('id' VALUE t.id, 'nombre' VALUE t.nombre)
                            ORDER BY t.id
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armisot t
               ),
               'estado_solicitud' VALUE (
                 SELECT COALESCE(
                          JSON_ARRAYAGG(
                            JSON_OBJECT('id' VALUE e.id, 'nombre' VALUE e.nombre)
                            ORDER BY e.id
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armisoe e
               ),
               'estado_cita' VALUE (
                 SELECT COALESCE(
                          JSON_ARRAYAGG(
                            JSON_OBJECT('id' VALUE c.id, 'nombre' VALUE c.nombre)
                            ORDER BY c.id
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armicie c
               ),
               'tipo_telefono' VALUE (
                 SELECT COALESCE(
                          JSON_ARRAYAGG(
                            JSON_OBJECT('id' VALUE f.id, 'tipo' VALUE f.tipo)
                            ORDER BY f.id
                            RETURNING CLOB),
                          TO_CLOB('[]'))
                   FROM cz_mi.armitti f
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
                 'estado_solicitud' VALUE TO_CLOB('[]'),
                 'estado_cita' VALUE TO_CLOB('[]'),
                 'tipo_telefono' VALUE TO_CLOB('[]')
               ),
               'error' VALUE P_ERROR
               RETURNING CLOB)
        INTO P_OUT
        FROM DUAL;
  END CATALOGOS;

END SKMI;
/
