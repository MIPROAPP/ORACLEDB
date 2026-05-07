create or replace PACKAGE BODY       SKFA
IS
  ------------------------------------------------------------------------------
  PROCEDURE DIGITALIZACION(P_IN  IN     CLOB,
                           P_OUT    OUT CLOB,P_ERROR IN OUT VARCHAR2)
  IS
    v_step    VARCHAR2(200) := 'INICIO';
    v_id      NUMBER;
    v_estado  VARCHAR2(1);
    v_error   VARCHAR2(4000);
    ji        json_object_t;
    ja        json_object_t;
    jl        json_array_t;
    v_id_docu arfafe.id_docu%TYPE;
    v_tipo    arfafeut.etiqueta%TYPE;
    r_feu     arfafeu%ROWTYPE;
  BEGIN
    r_feu.id               := 0;
    r_feu.usuario_crea     := USER;
    r_feu.fecha_crea       := SYSDATE;
    r_feu.usuario_modifica := USER;
    r_feu.fecha_modifica   := SYSDATE;

    v_step := 'LLAVE';

    ji        := json_object_t(P_IN);
    v_id      := ji.get_string('id');
    jl        := ji.get_array('data');
    ja        := json_object_t(jl.get(0)).get_object('Data').get_object('Payload');
    v_id_docu := ja.get_string('InternalCode');
    v_tipo    := ja.get_string('DocumentType');
    r_feu.url := ja.get_string('FileUrl');

    v_step := 'SEL-FE';

    BEGIN
      SELECT a.key_docu
        INTO r_feu.key_docu
        FROM arfafe a
       WHERE a.id_docu = v_id_docu;
    EXCEPTION
      WHEN no_data_found THEN
        v_estado := 'P';
        v_error  := 'El documento no existe';
        RAISE no_data_found;
    END;

    v_step := 'SEL-FEUT';

    SELECT a.tipo
      INTO r_feu.tipo
      FROM arfafeut a
     WHERE a.etiqueta = v_tipo;

    v_step := 'INS-FEU';

    BEGIN
      INSERT INTO arfafeu VALUES r_feu;
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
    END;

    v_step := 'OUT';

    v_estado := 'A';
    SELECT json_object(
             'id'     VALUE v_id,
             'estado' VALUE v_estado,
             'error'  VALUE v_error
             RETURNING CLOB)
        INTO P_OUT
        FROM dual;
  EXCEPTION
    WHEN OTHERS THEN
      v_error  := nvl(v_error,v_step||':'||SQLERRM);
      v_estado := nvl(v_estado,'E');
      SELECT json_object(
               'id'     VALUE v_id,
               'estado' VALUE v_estado,
               'error'  VALUE v_error
               RETURNING CLOB)
        INTO P_OUT
        FROM dual;
  END;
  ------------------------------------------------------------------------------
  -- Privado de FA
  PROCEDURE CREA_FX(P_ERROR IN OUT VARCHAR2,
                    P_FE    IN     arfafe%ROWTYPE,
                    P_FLAG  IN     VARCHAR2 := 'NA')
  IS
    v_step  VARCHAR2(100) := 'INICIO';
    r_fx    arfafx%ROWTYPE;
    r_fet   arfafet%ROWTYPE;
    r_feto  arfafeto%ROWTYPE;
    v_da    arfafx.total%TYPE;
    v_df    arfafx.total%TYPE;
    r_si    arfasi%ROWTYPE;
    v_pw    tmfacw.pedido_web%TYPE;
    -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
    PROCEDURE INSERTAR
    IS
    BEGIN

      v_step := 'INS:'||r_fx.tipo||':'||r_fx.sistema||':'||r_fx.id_subdocu;

      INSERT INTO arfafx VALUES r_fx;

      /** /-- para qa --

      IF r_fx.sistema = 'ado' THEN
        r_fx.sistema := 'adt';
        INSERT INTO arfafx VALUES r_fx;
        r_fx.sistema := 'ado';
      END IF;

      -- para qa --/ **/

    EXCEPTION
      WHEN dup_val_on_index THEN
        IF P_FLAG NOT LIKE '%IgnoraDuplicado%' THEN
          RAISE dup_val_on_index;
        END IF;
    END;
    -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
  BEGIN
    r_fx.usuario_crea     := '1';
    r_fx.fecha_crea       := SYSDATE;
    r_fx.usuario_modifica := '1';
    r_fx.fecha_modifica   := SYSDATE;
    r_fx.key_docu         := P_FE.key_docu;
    r_fx.referencia       := r_fx.key_docu;
    r_fx.total            := P_FE.total;
    r_fx.key_docu_sistema := P_FE.sistema;

    v_step :='SEL-FET:'||P_FE.tipo;

    SELECT a.*
      INTO r_fet
      FROM arfafet a
     WHERE a.tipo = P_FE.tipo;

    v_step := 'SEL-SI:'||P_FE.sistema;

    SELECT a.*
      INTO r_si
      FROM arfasi a
     WHERE a.sistema = P_FE.sistema;

    v_step := P_FE.tipo||'_'||P_FE.origen;

    IF P_FE.origen IN ('AD','AL','ER') THEN

      v_step := 'ORIGINAL';

      r_fx.sistema       := P_FE.sistema;
      IF P_FE.origen = 'ER' THEN
        IF r_fet.clase = 'I' THEN
          r_fx.tipo      := 'IN';
        ELSIF r_fet.clase = 'R' THEN
          r_fx.tipo      := 'RC';
        ELSE
          RAISE no_data_found;
        END IF;
      ELSE
        r_fx.tipo        := P_FE.tipo;
      END IF;
      r_fx.id_subdocu    := P_FE.id_docu;
      r_fx.id_externo    := r_fx.id_subdocu;
      r_fx.estado        := 'A';
      IF r_si.prefijo_key = 'S' THEN
        r_fx.key_externo := substr(r_fx.key_docu,5);
      ELSE
        r_fx.key_externo := r_fx.key_docu;
      END IF;
      INSERTAR;

      v_step := 'DESTINO';

      IF P_FE.origen = 'ER' THEN
        IF r_fx.tipo = 'RC' THEN
          BEGIN

            v_step := 'SEL-TMCW:'||P_FE.no_cia||','||P_FE.cliente;

            SELECT v_step
              INTO v_step
              FROM tmfacw a
             WHERE a.cliente = P_FE.cliente
               AND a.no_cia  = P_FE.no_cia;
            r_fx.sistema := 'ado';
          EXCEPTION
            WHEN no_data_found THEN
              r_fx.sistema := NULL;
          END;
        ELSIF r_fx.tipo = 'IN' THEN
          r_fx.sistema := NULL;
        ELSE
          RAISE no_data_found;
        END IF;
      ELSIF P_FE.origen = 'AD' THEN
        IF P_FE.tipo = 'OV' THEN
          r_fx.sistema := 'alu';
        ELSIF P_FE.tipo = '50' THEN
          r_fx.sistema := 'ivd';
        ELSE
          RAISE no_data_found;
        END IF;
      ELSIF P_FE.origen = 'AL' THEN
        IF P_FE.tipo = 'SD' THEN
          r_fx.sistema := 'ado';
          r_fx.tipo    := 'DP';
        ELSE
          RAISE no_data_found;
        END IF;
      END IF;
      IF r_fx.sistema IS NOT NULL THEN
        r_fx.estado      := 'P';
        r_fx.key_externo := r_fx.id_subdocu;
        INSERTAR;
      END IF;
    ELSIF P_FE.origen IN ('IC','ID') THEN

      v_step :='SEL-FETO:'||P_FE.tipo;

      SELECT a.*
        INTO r_feto
        FROM arfafeto a
      WHERE a.tipo = P_FE.tipo
        AND ROWNUM = 1; -- las configuraciones de todas las variantes deben ser iguales

      v_step := 'IVD';

      r_fx.tipo        := CASE r_fet.clase
                            WHEN 'R' THEN 'RC'
                            ELSE
                              CASE r_fet.tipo_origen
                                WHEN 'V' THEN 'DV'
                                WHEN 'N' THEN 'FC'
                              END
                          END;
      r_fx.sistema     := 'ivd';
      r_fx.id_subdocu  := P_FE.id_docu;
      r_fx.id_externo  := r_fx.id_subdocu;
      r_fx.key_externo := r_fx.key_docu;
      r_fx.estado      := 'A';
      INSERTAR;
      r_fx.estado      := 'P';
      IF r_fet.clase = 'F' THEN

        v_step := 'SWB';

        r_fx.sistema     := 'swb';
        r_fx.id_subdocu  := P_FE.id_docu;
        r_fx.id_externo  := r_fx.id_subdocu;
        r_fx.key_externo := r_fx.id_subdocu;
        INSERTAR;

        v_step := 'ALU';

        r_fx.sistema     := 'alu';
        r_fx.id_subdocu  := P_FE.id_docu;
        r_fx.id_externo  := r_fx.id_subdocu;
        r_fx.key_externo := r_fx.id_subdocu;
        INSERTAR;
      END IF;

      v_step := 'ADO';

      BEGIN
        IF P_FE.pago = 'C' OR r_fet.credito = 1 THEN
          BEGIN

            v_step := 'SEL-TMCW:'||P_FE.no_cia||','||P_FE.cliente;

            SELECT v_step
              INTO v_step
              FROM tmfacw a
             WHERE to_char(a.no_cliente) = P_FE.cliente
               AND a.no_cia              = P_FE.no_cia;
          EXCEPTION
            WHEN invalid_number THEN

              v_step := 'SEL-TMCW2:'||P_FE.no_cia||','||P_FE.key_docu;

              SELECT v_step
                INTO v_step
                FROM arfafp p,
                     tmfacw a
               WHERE p.key_docu = P_FE.key_docu
                 AND a.cliente  = p.girador
                 AND a.no_cia   = P_FE.no_cia;
          END;
        ELSIF r_fet.clase = 'F' THEN

          v_step := 'SEL-TMCW3:'||P_FE.cliente;

          SELECT a.pedido_web
            INTO v_pw
            FROM tmfacw a
           WHERE a.cliente = P_FE.cliente;
          IF v_pw = 1 THEN

            v_step := 'SEL-TMCW4:'||P_FE.key_docu;

            SELECT v_step
              INTO v_step
              FROM (
                    SELECT f.tipo
                      FROM arfafe e,
                           arfafr r,
                           arfafe f
                     WHERE r.key_docu (+)= e.key_docu
                       AND f.key_docu (+)= r.key_refe
                     START
                      WITH e.key_docu = P_FE.key_docu
                   CONNECT
                        BY r.key_docu = PRIOR r.key_refe
                   ) a
             WHERE a.tipo ='OV';
          END IF;
        ELSE
          RAISE no_data_found;
        END IF;
        r_fx.sistema     := 'ado';
        r_fx.id_subdocu  := P_FE.id_docu;
        r_fx.id_externo  := r_fx.id_subdocu;
        r_fx.key_externo := r_fx.id_subdocu;
        INSERTAR;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      IF r_feto.factura_credito IN ('F','V') THEN

        v_step := 'OFU';

        r_fx.sistema     := 'ofu';
        r_fx.tipo        := CASE r_feto.factura_credito
                              WHEN 'F' THEN 'FC'
                              WHEN 'V' THEN 'DV'
                            END;
        r_fx.id_subdocu  := P_FE.id_docu;
        r_fx.id_externo  := r_fx.id_subdocu;
        r_fx.key_externo := r_fx.id_subdocu;
        INSERTAR;
      END IF;

      v_step := 'OFU-PAGO';

      v_da := 0;
      v_df := 0;
      FOR r IN (
                SELECT a.referencia,
                       a.total,
                       a.dev_fact,
                       a.dev_misc,
                       a.dev_apply,
                       a.recibo_credito,
                       'P'||a.recibo_credito               tipo,
                       decode(
                          a.recibo_credito,
                          'R',a.id_subdocu,
                          decode(
                            sign(length(a.id_subdocu)-20),
                            1,substr(a.id_subdocu,-20),
                            a.id_subdocu))                 id_subdocu
                  FROM (
                        SELECT a.externo                       referencia,
                               a.monto                         total,
                               nvl(b.dev_fact,c.dev_fact)      dev_fact,
                               nvl(b.dev_apply,c.dev_apply)    dev_apply,
                               nvl(b.dev_misc,c.dev_misc)      dev_misc,
                               nvl(b.recibo_credito,
                                   c.recibo_credito)           recibo_credito,
                               substr(P_FE.no_cia,2,1)
                               ||P_FE.centro
                               ||nvl(b.abreviatura,
                                     c.abreviatura)
                               ||P_FE.id_docu
                               ||decode(
                                   a.tipo_pago_inst,
                                   1,'',
                                   '_'
                                   ||to_char(a.tipo_pago_inst,
                                             'FM999'))         id_subdocu
                          FROM arfafp  a,
                               arfatpo b,
                               arfatpo c
                         WHERE a.key_docu     = P_FE.key_docu
                           AND b.tipo_pago (+)= a.tipo_pago
                           AND b.tipo      (+)= a.tipo
                           AND c.tipo_pago (+)= a.tipo_pago
                           AND c.tipo      (+)= '*'
                       ) a
                 WHERE a.recibo_credito != 'N'
                 ORDER
                    BY a.id_subdocu
               )
      LOOP

        v_step := 'FI/APPLY';

        IF r_feto.factura_credito = 'V' THEN
          IF r.dev_fact = 'S' THEN
            v_df := v_df + r.total;
          END IF;
          IF r.dev_apply ='S' THEN
            v_da := v_da + r.total;
          END IF;
        END IF;

        v_step := 'OFU-PAGO';

        IF (r_feto.factura_credito  = 'M'                                        ) OR
           (r_feto.factura_credito  = 'V'       AND r.dev_misc        = 'S'      ) OR
           (r_feto.factura_credito IN ('F','R') AND r.recibo_credito IN ('R','C')) THEN
          r_fx.sistema     := 'ofu';
          r_fx.tipo        := r.tipo;
          r_fx.id_subdocu  := r.id_subdocu;
          r_fx.id_externo  := r_fx.id_subdocu;
          r_fx.key_externo := r_fx.id_subdocu;
          r_fx.referencia  := r.referencia;
          r_fx.total       := r.total;
          INSERTAR;

          v_step := 'OFU-PG-APLIC';

          IF (r_feto.factura_credito IN ('F','R') AND r_feto.aplica_recibo = 1) THEN
            r_fx.tipo        := 'A'||r.recibo_credito;
            r_fx.id_subdocu  := 'a'||r.id_subdocu;
            r_fx.id_externo  := r_fx.id_subdocu;
            r_fx.key_externo := r_fx.id_subdocu;
            INSERTAR;
          END IF;
        END IF;
      END LOOP;

      v_step := 'OFU-FI';

      IF v_df != 0 THEN
        r_fx.sistema     := 'ofu';
        r_fx.tipo        := 'FI';
        r_fx.id_subdocu  := r_fx.tipo||P_FE.id_docu;
        r_fx.id_externo  := r_fx.id_subdocu;
        r_fx.key_externo := r_fx.id_subdocu;
        r_fx.referencia  := P_FE.key_docu;
        r_fx.total       := v_df;
        INSERTAR;
      END IF;

      v_step := 'OFU-DV-APLIC';

      IF v_da != 0 THEN
        r_fx.sistema     := 'ofu';
        r_fx.tipo        := 'AV';
        r_fx.id_subdocu  := 'a'||P_FE.id_docu;
        r_fx.id_externo  := r_fx.id_subdocu;
        r_fx.key_externo := r_fx.id_subdocu;
        r_fx.referencia  := P_FE.key_docu;
        r_fx.total       := v_da;
        INSERTAR;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR := nvl(P_ERROR,v_step||':'||SQLERRM);
  END;
  ------------------------------------------------------------------------------
  PROCEDURE FA(P_IN  IN     CLOB,
               P_OUT    OUT CLOB)
  IS
    j json_object_t;
  BEGIN
    j := json_object_t(P_IN);
    FA(j);
    P_OUT := j.to_clob;
  END;
  ------------------------------------------------------------------------------
  PROCEDURE FA(P_JSON IN OUT json_object_t)
  IS
    v_step   VARCHAR2(100) := 'INICIO';
    v_error  VARCHAR2(4000);
    v_code   PLS_INTEGER;
    v_accion VARCHAR2(100);
    r_cw     tmfacw%ROWTYPE;
    r_fe     arfafe%ROWTYPE;
    r_fet    arfafet%ROWTYPE;
    r_fl     arfafl%ROWTYPE;
    r_fr     arfafr%ROWTYPE;
    r_fp     arfafp%ROWTYPE;
    r_tp     arfatp%ROWTYPE;
    r_tr     arfatr%ROWTYPE;
    r_ff     arfaff%ROWTYPE;
    r_ffd    arfaffd%ROWTYPE;
    r_fg     arfafg%ROWTYPE;
    r_fa     arfafa%ROWTYPE;
    r_fpa    arfafpa%ROWTYPE;
    r_fax    arfafaax%ROWTYPE;
    r_fx     arfafx%ROWTYPE;
    r_fm     arfafm%ROWTYPE;
    r_flx    arfaflx%ROWTYPE;
    jr       json_object_t;
    js       json_object_t;
    jt       json_object_t;
    jl       json_array_t;
    jm       json_array_t;
    v_dup    PLS_INTEGER := 0;
    c        CLOB;
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
    PROCEDURE EXTERNO2KEY(P_J IN json_object_t,P_E IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
      r_fx.sistema     := P_J.get_string('sistema');
      r_fx.key_externo := P_J.get_string('columna');
      r_fx.id_externo  := P_J.get_string('llave');

      v_step := 'SEL-FX_D:'||r_fx.sistema||':'||r_fx.key_externo||':'||r_fx.id_externo;

      IF r_fx.key_externo = 'TransactionId' THEN
        IF P_E IS NULL THEN
          SELECT x.key_docu
            INTO r_fx.key_docu
            FROM arfafx x
           WHERE x.sistema    = r_fx.sistema
             AND x.id_externo = r_fx.id_externo;
        ELSE
          SELECT x.key_docu
            INTO r_fx.key_docu
            FROM arfafx x
           WHERE x.sistema    = r_fx.sistema
             AND x.id_externo = r_fx.id_externo
             AND x.estado     = P_E;
        END IF;
      ELSIF r_fx.key_externo = 'TransactionKey' THEN
        IF P_E IS NULL THEN
          SELECT x.key_docu
            INTO r_fx.key_docu
            FROM arfafx x
           WHERE x.sistema     = r_fx.sistema
             AND x.key_externo = r_fx.id_externo;
        ELSE
          SELECT x.key_docu
            INTO r_fx.key_docu
            FROM arfafx x
           WHERE x.sistema     = r_fx.sistema
             AND x.key_externo = r_fx.id_externo
             AND x.estado      = P_E;
        END IF;
      ELSE
        RAISE no_data_found;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        r_fx.key_docu := NULL;
      WHEN too_many_rows THEN
        r_fx.key_docu := NULL;
        RAISE too_many_rows;
    END;
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
    PROCEDURE EXTERNO2KEY(P_L IN json_array_t,P_E IN VARCHAR2 DEFAULT NULL)
    IS
      j json_object_t;
      i PLS_INTEGER := 0;
      n PLS_INTEGER := P_L.get_size-1;
    BEGIN
      LOOP
        EXIT WHEN i > n;
        j := json_object_t(P_L.get(i));
        BEGIN
          EXTERNO2KEY(j,P_E);
          EXIT;
        EXCEPTION
          WHEN too_many_rows THEN
            -- adobe tiene secuencias semejantes con KEY en varios tipos de documentos
            -- en ese caso el loop debe procesar el ID
            NULL;
        END;
        i := i+1;
      END LOOP;
    END;
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
    PROCEDURE FA_ELECTRONICA(P_JSON IN OUT json_object_t)
    IS
    BEGIN
      IF P_JSON.has('electronica') THEN
        js        := P_JSON.get_object('electronica');
        r_fe.cufe := js.get_string('cufe');
        -- este dato no es necesario
        IF r_fe.cufe IS NOT NULL THEN
          --r_fe.cufe_path    := replace(js.get_string('urlCufe'),r_fe.cufe,'');
          r_fe.cufe_path := 'https://dgi-fep.mef.gob.pa/Consultas/FacturasPorCUFE?CUFE=FE';
        END IF;
      END IF;
    END;
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
    PROCEDURE FA_CUFE(P_JSON IN OUT json_object_t)
    IS
      e_cufe EXCEPTION;
    BEGIN
      IF g_Trigger = 0 THEN
        SAVEPOINT sp_fa_cufe;
      END IF;
      v_dup := nvl(P_JSON.get_number('id'),0);

      v_step := 'KEY_DOCU';

      js:= json_object_t(P_JSON.get_array('externo').get(0));
      EXTERNO2KEY(js);
      /**/-- aqui se puede usar EXTERNO2KEY(P_JSON.get_array('externo'));
      IF r_fx.key_docu IS NULL THEN
        RAISE no_data_found;
      END IF;
      r_fe.key_docu := r_fx.key_docu;

      v_step := 'CUFE';

      FA_ELECTRONICA(P_JSON);
      IF r_fe.cufe IS NULL THEN
        RAISE no_data_found;
      END IF;

      v_step := 'UPD-FE';

      UPDATE arfafe e
         SET e.cufe      = r_fe.cufe,
             e.cufe_path = r_fe.cufe_path
       WHERE e.key_docu = r_fe.key_docu;
      IF SQL%rowcount = 0 THEN
        RAISE no_data_found;
      END IF;
      IF v_dup != 0 THEN

        v_step := 'MARK';

        js := json_object_t(json_object(
                'id'      VALUE v_dup,
                'estado'  VALUE 'A',
                'error'   VALUE ''));
        CZ_MS.SKMS.WS_MARK_(js);
        IF js.get_object('resultado').get_number('codigo') != 0 THEN
          v_error := js.get_object('resultado').get_string('mensaje');
          RAISE e_cufe;
        END IF;
      END IF;
    EXCEPTION
      WHEN e_cufe THEN
        RAISE no_data_found;
      WHEN OTHERS THEN
        v_error := substr(v_step||':'||nvl(v_error,SQLERRM),1,4000);
        IF g_Trigger = 0 THEN
          ROLLBACK TO sp_fa_cufe;
        END IF;
        IF v_dup = 0 THEN
          RAISE no_data_found;
        END IF;

        v_step := 'MARK-E';

        js := json_object_t(json_object(
                'id'       VALUE v_dup,
                'estado'   VALUE 'I',
                'diferido' VALUE to_char(SYSDATE+1/24,'YYYY-MM-DD HH24:MI:SS'),
                'error'    VALUE v_error));
        v_error := NULL;
        CZ_MS.SKMS.WS_MARK_(js);
        IF js.get_object('resultado').get_number('codigo') != 0 THEN
          v_error := js.get_object('resultado').get_string('mensaje');
          RAISE no_data_found;
        END IF;
    END;
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
    PROCEDURE FA_FFPLAN
    IS
    BEGIN
      jl := jr.get_array('planes_de_entrega');
      r_ff.key_docu          := r_fe.key_docu;
      r_ff.usuario_crea      := USER;
      r_ff.fecha_crea        := SYSDATE;
      r_ff.usuario_modifica  := USER;
      r_ff.fecha_modifica    := SYSDATE;
      r_ffd.key_docu         := r_fe.key_docu;
      r_ffd.usuario_crea     := USER;
      r_ffd.fecha_crea       := SYSDATE;
      r_ffd.usuario_modifica := USER;
      r_ffd.fecha_modifica   := SYSDATE;
      FOR i IN 0 .. jl.get_size - 1 LOOP

        v_step := 'FF:'||r_ff.ffplan;

        js := json_object_t(jl.get(i));
        r_ff.secuencia := i+1;
        r_ff.ffplan    := js.get_string('plan_de_entrega');
        IF r_ff.ffplan IS NULL THEN
          r_ff.ffplan  := js.get_object('tipo_de_entrega')
                            .get_string('llave');

          v_step := 'SEL-FFT:'||r_ff.ffplan;

          SELECT a.ffplan
            INTO r_ff.ffplan
            FROM arfafft a
           WHERE a.canal       = r_ff.ffplan
             AND a.por_defecto = 'S';
        END IF;
        r_ff.no_cia    := js.get_string('no_cia');
        r_ff.centro    := js.get_string('centro');
        r_ff.promesa   := to_date(
                            js.get_string('fecha_promesa'),
                            'YYYY-MM-DD');
        r_ff.direccion := js.get_string('direccion');

        v_step := 'INS-FF:'||r_ff.ffplan;

        INSERT INTO arfaff VALUES r_ff;

        v_step := 'FFPLAND';

        jm := js.get_array('articulos');
        FOR j IN 0 .. jm.get_size -1 LOOP

          v_step := 'FFD:'||j;

          jt := json_object_t(jm.get(j));
          r_ffd.secuencia    := r_ff.secuencia;
          r_ffd.linea        := j+1;
          r_ffd.no_arti      := jt.get_object('no_arti')
                                  .get_string('llave');
          r_ffd.promesa      := to_date(
                                jt.get_string('fecha_promesa'),
                                'YYYY-MM-DD');
          r_ffd.cantidad     := jt.get_number('cantidad');
          IF jt.has('externo_arti') THEN
            r_ffd.externo      := jt.get_object('externo_arti')
                                    .get_string('llave');

            v_step := 'SEL-FFORIGEN:'||r_ffd.key_docu||':'||r_ffd.externo;

            SELECT a.linea
              INTO r_ffd.linea_origen
              FROM arfafl a
             WHERE a.key_docu = r_ffd.key_docu
               AND a.externo  = r_ffd.externo;
          ELSIf jt.has('linea_origen') THEN
            r_ffd.linea_origen := jt.get_number('linea_origen');
          ELSE
            r_ffd.linea_origen := 0;
          END IF;

          v_step := 'FFD.EXTERNO';

          r_ffd.externo      := jt.get_object('externo')
                                  .get_string('llave');


          v_step := 'FFUoM:'||r_ffd.no_arti||':'||r_ffd.externo;

          IF jt.has('uom') THEN
            r_ffd.uom          := jt.get_string('uom');
            r_ffd.cantidad_uom := jt.get_number('cantidad_uom');
          ELSE
            IF r_fx.key_docu IS NULL THEN
              RAISE no_data_found;
            END IF;
            SELECT a.uom,
                   r_ffd.cantidad * a.cantidad_uom / a.cantidad
              INTO r_ffd.uom,
                   r_ffd.cantidad_uom
              FROM arfaffd a
             WHERE a.key_docu = r_fx.key_docu
               AND a.externo  = r_ffd.externo;
          END IF;

          v_step := 'INS-FFD:'||r_ffd.no_arti;

          INSERT INTO arfaffd VALUES r_ffd;
        END LOOP;
      END LOOP;
    END;
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
    FUNCTION GET_ESTADO(P_TIPO IN VARCHAR2,
                        P_JSON IN json_object_t)
    RETURN VARCHAR2
    IS
      v_objeto VARCHAR2(4000);
      v_estado VARCHAR2(2);
    BEGIN
      IF NOT P_JSON.has('estado') THEN
        v_estado := 'P';
      ELSIF P_JSON.get_type('estado') = 'SCALAR' THEN
        v_estado := P_JSON.get_string('estado');
      ELSE
        v_objeto := P_JSON.get_object('estado').to_string;
        WITH objeto
          AS (
              SELECT *
                 FROM JSON_TABLE(v_objeto,'$'
                                  COLUMNS (
                                           SISTEMA VARCHAR2(3)  PATH '$.sistema',
                                           LLAVE   VARCHAR2(50) PATH '$.llave'))
             )
        SELECT decode(
                 a.sistema,
                 'bus',a.llave,
                 (
                  SELECT b.estado
                    FROM arfafeex b
                   WHERE b.tipo        = P_TIPO
                     AND b.sistema     = a.sistema
                     AND b.key_externo = a.llave
                 )
               )
          INTO v_estado
          FROM objeto a;
      END IF;
      RETURN v_estado;
    END;
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
  BEGIN
    IF g_Trigger = 0 THEN
      SAVEPOINT skfa_fa_sp;
    END IF;
    v_accion := P_JSON.get_string('accion');

    v_step := v_accion;

    IF v_accion = 'APLICACION' THEN
      r_fr.usuario_crea     := USER;
      r_fr.fecha_crea       := SYSDATE;
      r_fr.usuario_modifica := USER;
      r_fr.fecha_modifica   := SYSDATE;
      r_fr.tipo_refe        := 'S';

      v_step := 'DOCU';

      js := json_object_t(P_JSON.get_array('externo').get(0));
      EXTERNO2KEY(js);
      /**/-- aqui se puede usar EXTERNO2KEY(P_JSON.get_array('externo'));
      IF r_fx.key_docu IS NULL THEN
        RAISE no_data_found;
      END IF;

      v_step := 'SEL-FET:'||r_fr.key_docu;

      SELECT e.id_docu,
             t.afecta_saldo,
             t.descripcion
        INTO r_fr.id_refe,
             r_fet.afecta_saldo,
             r_fet.descripcion
        FROM arfafe  e,
             arfafet t
       WHERE e.key_docu = r_fx.key_docu
         AND t.tipo     = e.tipo;
      IF r_fet.afecta_saldo = -1 THEN
        r_fr.key_docu := r_fx.key_docu;
      ELSE
        r_fr.key_refe := r_fx.key_docu;
      END IF;

      v_step := 'LOO-REFE';

      jl := P_JSON.get_array('aplicaciones');
      FOR i IN 0 .. jl.get_size - 1 LOOP

        v_step := 'REFE:'||i;

        js := json_object_t(jl.get(i));
        r_fr.monto  := js.get_number('monto');
        r_fr.fecha  := to_date(
                       js.get_string('fecha'),
                       'YYYY-MM-DD');
        r_fr.codigo := js.get_object('externo')
                         .get_string('llave');
        js := js.get_object('documento');
        EXTERNO2KEY(js);
      /**/-- aqui se puede usar EXTERNO2KEY(js.get_object('documento'));
          -- pero hay que revisar que este js no se usa más abajo
        IF r_fx.key_docu IS NULL THEN
          RAISE no_data_found;
        END IF;

        v_step := 'SEL-FE:'||r_fx.key_docu;

        SELECT decode(r_fet.afecta_saldo,-1,e.id_docu,r_fr.id_refe),
               decode(r_fet.afecta_saldo,t.afecta_saldo,
                      'No puede referenciar un documento '||t.descripcion
                      ||' a un documento '||r_fet.descripcion)
          INTO r_fr.id_refe,
               v_error
          FROM arfafe  e,
               arfafet t
         WHERE e.key_docu = r_fx.key_docu
           AND t.tipo     = e.tipo;
        IF v_error IS NOT NULL THEN
          RAISE no_data_found;
        END IF;
        IF r_fet.afecta_saldo = -1 THEN
          r_fr.key_refe := r_fx.key_docu;
        ELSE
          r_fr.key_docu := r_fx.key_docu;
        END IF;

        v_step := 'INS-FR:'
                  ||r_fr.key_docu||','||r_fr.key_refe||','||r_fr.tipo_refe;

        BEGIN
          r_fr.secuencia := 1;
          r_fr.id        := 0;
          INSERT INTO arfafr VALUES r_fr;
        EXCEPTION
          WHEN dup_val_on_index THEN

            v_step := 'UPD-FR:'
                      ||r_fr.codigo||','
                      ||r_fr.key_docu||','||r_fr.key_refe||','||r_fr.tipo_refe;

            UPDATE arfafr r
               SET r.monto = r_fr.monto,
                   r.fecha = r_fr.fecha
             WHERE r.codigo    = r_fr.codigo
               AND r.key_docu  = r_fr.key_docu
               AND r.tipo_refe = r_fr.tipo_refe
               AND r.key_refe  = r_fr.key_refe
            RETURN r.secuencia
              INTO r_fr.secuencia;
            IF SQL%rowcount = 0 THEN

              v_step := 'SEL-FR_SECUENCIA:'
                        ||r_fr.key_docu||':'||r_fr.key_refe||','||r_fr.tipo_refe;

              SELECT MAX(a.secuencia)+1
                INTO r_fr.secuencia
                FROM arfafr a
               WHERE a.key_docu  = r_fr.key_docu
                 AND a.key_refe  = r_fr.key_refe
                 AND a.tipo_refe = r_fr.tipo_refe;

              v_step := 'INS-FR2:'
                        ||r_fr.key_docu||','||r_fr.key_refe||','||r_fr.tipo_refe;

              INSERT INTO arfafr VALUES r_fr;
            END IF;
        END;
      END LOOP;
      IF v_step = 'LOO-REFE' THEN
        RAISE no_data_found;
      END IF;
    ELSIF v_accion = 'INVDO' THEN
      DECLARE
        parent_key_not_found EXCEPTION;
        PRAGMA EXCEPTION_INIT(parent_key_not_found, -02291);
      BEGIN
        IF P_JSON.has('id_docu') THEN
          r_fe.id_docu         := P_JSON.get_string('id_docu'    );

          v_step := 'SEL-FE:'||r_fe.id_docu;

          SELECT e.key_docu
            INTO r_flx.key_docu
            FROM arfafe e
           WHERE e.id_docu = r_fe.id_docu
             AND e.tipo    = 'PS';
        ELSE
          r_flx.key_docu       := P_JSON.get_string('key_docu'   );
        END IF;
        r_flx.linea            := P_JSON.get_string('linea'      );
        r_flx.sistema          := P_JSON.get_string('sistema'    );
        r_flx.id_externo       := P_JSON.get_string('id_externo' );
        r_flx.key_externo      := P_JSON.get_string('key_externo');
        r_flx.usuario_crea     := USER;
        r_flx.fecha_crea       := SYSDATE;
        r_flx.usuario_modifica := r_flx.usuario_crea;
        r_flx.fecha_modifica   := r_flx.fecha_crea;
        IF r_flx.key_externo IS NULL THEN
          r_flx.key_externo := r_flx.id_externo;

          v_step := 'INS-FLX:'||r_flx.key_docu||':'||r_flx.linea;

          BEGIN
            INSERT INTO arfaflx VALUES r_flx;
          EXCEPTION
            WHEN dup_val_on_index THEN
              NULL;
          END;
        ELSE

          v_step := 'UPD-FLX:'||r_flx.key_docu||':'||r_flx.linea;

          UPDATE arfaflx a
             SET a.key_externo = r_flx.key_externo
           WHERE a.key_docu = r_flx.key_docu
             AND a.linea    = r_flx.linea
             AND a.sistema  = r_flx.sistema;
          IF SQL%rowcount = 0 THEN

            v_step := 'INS-FLX2:'||r_flx.key_docu||':'||r_flx.linea;

            INSERT INTO arfaflx VALUES r_flx;
          END IF;
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          v_code  := 641;
          v_error := v_step||':pick slip perdido';
          RAISE no_data_found;
        WHEN parent_key_not_found THEN
          v_code  := 641;
          v_error := v_step||':línea de pick slip perdida';
          RAISE no_data_found;
      END;
    ELSIF v_accion = 'BEEEF' THEN
      r_fe.id_docu   := P_JSON.get_string('id_docu');
      r_fe.direccion := P_JSON.get_string('llave'  );
      r_fe.sistema   := P_JSON.get_string('sistema');
      BEGIN

        v_step := 'SEL-FE:'||r_fe.id_docu;

        SELECT e.no_cia,
               e.cliente,
               e.key_docu
          INTO r_fe.no_cia,
               r_fe.cliente,
               r_fe.key_docu
          FROM arfafe e
         WHERE e.id_docu = r_fe.id_docu;
      EXCEPTION
        WHEN no_data_found THEN
          v_code  := 641;
          v_error := 'Factura no existe';
          RAISE no_data_found;
      END;
      BEGIN

        v_step := 'SEL-CW:'||r_fe.cliente;

        SELECT w.pedido_web
          INTO r_cw.pedido_web
          FROM tmfacw w
         WHERE w.cliente      = r_fe.cliente
           AND r_fe.no_cia LIKE w.no_cia;
        IF r_cw.pedido_web = 1 THEN

          v_step := 'SEL-FR:'||r_fe.key_docu;

          SELECT v_step
            INTO v_step
            FROM (
                  SELECT f.tipo
                    FROM arfafr r,
                         arfafe f
                   WHERE f.key_docu = r.key_refe
                   START
                    WITH r.key_docu = r_fe.key_docu
                 CONNECT
                      BY r.key_docu = PRIOR r.key_refe
                 ) a
           WHERE a.tipo ='OV';
        END IF;

        v_step := 'COLA:'||r_fe.sistema||':'||r_fe.direccion;

        CZ_MS.SKMS.ENCOLA('cz_routes_dispatch',r_fe.direccion,r_fe.sistema,'S');
      EXCEPTION
        WHEN no_data_found THEN
          v_code  := 999; -- Se descarta el registro de la pre-cola
          v_error := 'Factura no existe';
          RAISE no_data_found;
      END;
    ELSIF v_accion IN ('B2B','B2C') THEN
      r_cw.cliente          := P_JSON.get_string('no_cliente');
      IF v_accion = 'B2C' THEN
        r_cw.no_cia         := '%';
        r_cw.pedido_web     := nvl(P_JSON.get_string('pedido_web'),'0');
      ELSE
        r_cw.no_cia         := P_JSON.get_string('no_cia'    );
        r_cw.no_cliente     := r_cw.cliente;
        r_cw.pedido_web     := '0';
      END IF;
      r_fe.sistema          := P_JSON.get_string('sistema'   );
      r_cw.usuario_crea     := USER;
      r_cw.fecha_crea       := SYSDATE;
      r_cw.usuario_modifica := r_cw.usuario_crea;
      r_cw.fecha_modifica   := r_cw.fecha_crea;

      v_step := 'INS-CW:'||r_cw.no_cia||':'||r_cw.cliente;

      INSERT INTO tmfacw VALUES r_cw;

      r_fe.direccion := 'IgnoraDuplicado,IgnoraCuenta:'
                        ||r_cw.no_cia||':'||r_cw.cliente;

      v_step := 'LOOP:'||r_cw.no_cia||':'||r_cw.cliente;

      FOR e IN (
                SELECT e.*
                  FROM arfafe e
                 WHERE e.cliente   = r_cw.cliente
                   AND e.no_cia LIKE r_cw.no_cia
               )
      LOOP

        v_step := 'CREA_FX:'||e.id_docu;

        CREA_FX(v_error,e,r_fe.direccion);
        IF v_error IS NOT NULL THEN
          RAISE no_data_found;
        END IF;

        v_step := 'LOOP-FX:'||e.id_docu;

        FOR x IN (
                  SELECT x.*
                    FROM arfafx x
                   WHERE x.key_docu = e.key_docu
                     AND x.sistema  = 'ado'
                 )
        LOOP
          IF x.tipo = 'DP' THEN

            v_step := 'ENCOLA-DP:'||e.id_docu;

            CZ_MS.SKMS.ENCOLA('despachoweb',x.referencia,x.sistema,'S');
          ELSIF x.tipo IN ('RC','DV','FC') THEN

            v_step := 'ENCOLA:'||e.id_docu;

            CZ_MS.SKMS.ENCOLA('facturaweb',x.referencia,x.sistema,'S');

            v_step := 'LOOP-FR:'||e.id_docu;

            FOR r IN (
                      SELECT a.id
                        FROM arfafr a
                       WHERE a.key_docu  = e.key_docu
                         AND a.tipo_refe = 'S'
                     )
            LOOP

              v_step := 'ENCOLA-FR:'||e.id_docu||':'||r.id;

              CZ_MS.SKMS.ENCOLA('aplicacionweb',r.id,x.sistema,'S');
            END LOOP;

            v_step := 'LOOP-BE:'||e.id_docu;

            FOR r IN (
                      SELECT a.account_name||'|'||a.guide||'|' llave
                        FROM JSON_TABLE(
                               CZ_BEE.SK_BEE.FACTURA(
                                 json_object(
                                   'factura' VALUE e.id_docu)),
                               '$[*]' COLUMNS (
                               ACCOUNT_NAME VARCHAR2(150) PATH '$.account_name',
                               GUIDE        VARCHAR2( 50) PATH '$.guide',
                               FACTURA      VARCHAR2( 50) PATH '$.factura',
                               PLAN         VARCHAR2( 50) PATH '$.plan'
                               )
                             ) a
                     )
            LOOP

              v_step := 'ENCOLA-BE:'||e.id_docu||':'||r.llave;

              CZ_MS.SKMS.ENCOLA('cz_routes_dispatch',r.llave,x.sistema,'S');
            END LOOP;
          END IF;
        END LOOP;
      END LOOP;
    ELSIF v_accion = 'BORRAR' THEN

      v_step := 'DOCU';

      js := json_object_t(P_JSON.get_array('externo').get(0));
      EXTERNO2KEY(js);
      /**/-- aqui se puede usar EXTERNO2KEY(P_JSON.get_array('externo'));
      IF r_fx.key_docu IS NOT NULL THEN
        r_fe.key_docu := r_fx.key_docu;

        v_step := 'DEL-FLX:'||r_fe.key_docu;

        DELETE
          FROM arfaflx a
         WHERE a.key_docu = r_fe.key_docu;

        v_step := 'DEL-FL:'||r_fe.key_docu;

        DELETE
          FROM arfafl a
         WHERE a.key_docu = r_fe.key_docu;

        v_step := 'DEL-FR:'||r_fe.key_docu;

        DELETE
          FROM arfafr a
         WHERE a.key_docu = r_fe.key_docu;

        v_step := 'DEL-FX:'||r_fe.key_docu;

        DELETE
          FROM arfafx a
         WHERE a.key_docu = r_fe.key_docu;

        v_step := 'DEL-FE:'||r_fe.key_docu;

        DELETE
          FROM arfafe a
         WHERE a.key_docu = r_fe.key_docu;
        IF SQL%rowcount = 0 THEN
          RAISE no_data_found;
        END IF;
      END IF;
    ELSIF v_accion = 'CUFE' THEN
      FA_CUFE(P_JSON);
    ELSIF v_accion = 'CUFES' THEN
      jl := P_JSON.get_array('cufes');
      FOR i IN 0 .. jl.get_size - 1 LOOP
        jr := json_object_t(jl.get(i));
        FA_CUFE(jr);
        jl.put(i,jr,true);
      END LOOP;
    ELSIF v_accion IN ('ESTADO','ESTADO_DESPACHO') THEN
      r_fe.sistema := P_JSON.get_object('estado')
                            .get_string('sistema');
      r_fe.id_docu := P_JSON.get_object('estado')
                            .get_string('llave');

      v_step := 'EXTERNO';

      EXTERNO2KEY(P_JSON.get_array('externo'),'A');
      IF r_fx.key_docu IS NULL THEN
        RAISE no_data_found;
      END IF;

      v_step := 'SEL-FEEX:'||r_fx.key_docu||':'||r_fe.sistema||':'||r_fe.id_docu;

      SELECT a.estado
        INTO r_fe.estado
        FROM arfafe   e,
             arfafeex a
       WHERE e.key_docu   = r_fx.key_docu
         AND a.tipo       = e.tipo
         AND a.sistema    = r_fe.sistema
         AND a.id_externo = r_fe.id_docu;

      v_step := 'UPD-FE:'||r_fx.key_docu;

      IF v_accion = 'ESTADO' THEN
        UPDATE arfafe e
           SET e.estado = r_fe.estado
         WHERE e.key_docu = r_fx.key_docu;
      ELSE
        UPDATE arfafe e
           SET e.estado_despacho = r_fe.estado
         WHERE e.key_docu = r_fx.key_docu;
      END IF;
      IF SQL%rowcount = 0 THEN
        RAISE no_data_found;
      END IF;
    ELSIF v_accion = 'EXTERNO' THEN
      r_fe.sistema := P_JSON.get_string('sistema');
      c := P_JSON.to_clob;
      FOR r IN (
                SELECT a.sistema,
                       json_arrayagg(
                         json_object(
                           'sistema' VALUE a.sistema,
                           'columna' VALUE a.columna,
                           'llave'   VALUE a.llave
                         )
                         ORDER BY a.columna
                         RETURNING CLOB
                       ) payload,
                       MAX(decode(a.columna,'TransactionKey',a.llave)) key_docu,
                       MAX(decode(a.columna,'TransactionId' ,a.llave)) id_docu
                  FROM JSON_TABLE(c,
                         '$.externo[*]'
                         COLUMNS (
                           SISTEMA VARCHAR2(3)  PATH '$.sistema',
                           COLUMNA VARCHAR2(50) PATH '$.columna',
                           LLAVE   VARCHAR2(50) PATH '$.llave')) a
                 GROUP
                    BY a.sistema
                 ORDER
                    BY decode(a.sistema,r_fe.sistema,1,2)
               )
      LOOP
        IF r.sistema = r_fe.sistema THEN

          v_step := 'EXTERNOKEY';

/** /
          js := json_object_t(r.payload);
          EXTERNO2KEY(js);
/ **/
          EXTERNO2KEY(json_array_t(r.payload));
          IF r_fx.key_docu IS NULL THEN
            RAISE no_data_found;
          END IF;

          v_step := 'SEL-FE:'||r_fx.key_docu;

          SELECT e.id_docu
            INTO r_fx.id_subdocu
            FROM arfafe e
           WHERE e.key_docu = r_fx.key_docu;
        ELSE
          r_fx.sistema := r.sistema;

          v_step := 'UPD-FX:'||r_fx.sistema||':'||r_fx.id_subdocu;

          UPDATE arfafx a
             SET a.id_externo  = r.id_docu,
                 a.key_externo = r.key_docu,
                 a.estado      = 'A'
           WHERE a.id_subdocu = r_fx.id_subdocu
             AND a.sistema    = r_fx.sistema
             AND a.estado    != 'A';
          IF SQL%rowcount = 0 THEN
            RAISE no_data_found;
          END IF;
        END IF;
      END LOOP;
      IF v_step = 'EXTERNO' THEN
        RAISE no_data_found;
      END IF;
    ELSIF v_accion IN ('RECIBO','FACTURA','SDESPACHO','FFPLAN') THEN

      v_step := 'EXTERNO';

      jl := P_JSON.get_array('externo');
      FOR i IN 0 .. jl.get_size - 1 LOOP
        js := json_object_t(jl.get(i));
        CASE js.get_string('columna')
          WHEN 'TransactionKey' THEN
            r_fe.key_docu := js.get_string('llave');
          WHEN 'TransactionId' THEN
            r_fe.id_docu  := js.get_string('llave');
        END CASE;
      END LOOP;

      v_step := 'CABEZA';

      r_fe.usuario_crea     := USER;
      r_fe.fecha_crea       := SYSDATE;
      r_fe.usuario_modifica := USER;
      r_fe.fecha_modifica   := SYSDATE;
      r_fe.sobregiro        := 0;
      r_fe.cantidad         := 0;
      r_fe.devuelta         := 0;
      r_fe.entregada        := 0;
      r_fe.despachada       := 0;
      r_fe.confirmada       := 0;
      r_fe.picada           := 0;
      r_fe.estado_despacho  := 'D0';
      r_fe.sistema          := nvl(P_JSON.get_string('sistema'),'ivd');
      r_fe.canal            := nvl(P_JSON.get_string('canal'),'TDA');
      r_fe.origen           := nvl(P_JSON.get_string('fuentE'),'IC');
      r_fe.no_cia           := P_JSON.get_string('no_cia');
      r_fe.centro           := P_JSON.get_string('centro');
      r_fe.tipo             := P_JSON.get_string('tipo_doc');
      r_fe.fecha            := to_date(P_JSON.get_string('fecha2'),
                                       'YYYY-MM-DD');
      r_fe.hora             := to_date(substr(P_JSON.get_string('fechahora'),1,18),
                                       'YYYY-MM-DD HH24:MI:SS');
      --r_fe.promesa          := r_fe.fecha; no se puede usar un valor por defecto porque daña el cálculo
      r_fe.observacion      := P_JSON.get_string('observacion');

      v_step := 'SEL-SI/FEO:'||r_fe.sistema||' '||r_fe.origen;

      SELECT decode(a.prefijo_key,'S',a.sistema||'-')||r_fe.key_docu
        INTO r_fe.key_docu
        FROM arfasi  a,
             arfafeo b
       WHERE a.sistema = r_fe.sistema
         AND b.origen  = r_fe.origen
         AND b.sistema = a.sistema;

      v_step :='SEL-FET:'||r_fe.tipo;

      SELECT a.*
        INTO r_fet
        FROM arfafet a
       WHERE a.tipo = r_fe.tipo;

      v_step := 'ESTADO';

      r_fe.estado := GET_ESTADO(r_fe.tipo,P_JSON);

      v_step := 'INVENTARIO';

      IF r_fet.clase IN ('S') THEN
        r_fe.total   := 0;
        r_fe.subtipo := 'N';
        r_fe.pago    := 'D';
      ELSIF r_fet.clase IN ('I') THEN
        r_fe.total   := 0;
        r_fe.subtipo := P_JSON.get_string('tipo_factura');
        r_fe.pago    := 'D';
      ELSE
        r_fe.total   := round(P_JSON.get_number('total'),2);
        r_fe.subtipo := P_JSON.get_string('tipo_factura');
        r_fe.pago    := P_JSON.get_string('tipo_pago');
      END IF;

      v_step := 'DOC_ORI';

      r_fx.key_docu  := NULL;
      r_fr.tipo_refe := NULL;
      IF r_fet.tipo_origen = 'P' THEN
        r_fr.tipo_refe := 'S';
        js             := json_object_t(P_JSON.get_array('COD').get(0));
        r_fr.monto     := js.get_number('monto');
        js             := js.get_object('factura');
      ELSIF (r_fet.tipo_origen = 'V')                                  OR
            (r_fet.tipo_origen = 'N' AND P_JSON.has('cotizacion_ori')) THEN
        r_fr.tipo_refe := 'O';
        js             := P_JSON.get_object('cotizacion_ori');
      END IF;

      v_step := 'DOC_ORI:'||r_fr.tipo_refe||':'||js.get_string('llave');

      IF r_fr.tipo_refe IS NOT NULL THEN
        EXTERNO2KEY(js);
      END IF;
      IF r_fx.key_docu IS NOT NULL THEN

        v_step := 'SEL-ORI:'||r_fx.key_docu;

        SELECT e.canal,
               e.key_docu,
               e.id_docu,
               e.cliente,
               e.proyecto,
               e.cajero,
               e.vendedor
          INTO r_fe.canal,
               r_fr.key_refe,
               r_fr.id_refe,
               r_fe.cliente,
               r_fe.proyecto,
               r_fe.cajero,
               r_fe.vendedor
          FROM arfafe e
         WHERE e.key_docu = r_fx.key_docu;
      ELSIF r_fet.tipo_origen IN ('V','P') THEN
        RAISE no_data_found;
      ELSIF r_fet.clase = 'I' THEN

        v_step := 'DOC_ORI:'||r_fr.tipo_refe||':'||js.get_string('llave')
                       ||':'||r_fe.tipo||':'||r_fe.subtipo;

        BEGIN
          SELECT 4
            INTO v_dup
            FROM arfafes e
           WHERE e.tipo       = r_fe.tipo
             AND e.subtipo    = r_fe.subtipo
             AND e.integrable = 'N';
        EXCEPTION
          WHEN no_data_found THEN
            v_code  := 645;
            v_error := v_step||':falta el documento origen';
            RAISE no_data_found;
        END;
      END IF;
      IF r_fet.clase NOT IN ('I') THEN

        v_step := 'CLIENTE/PROYECTO';

        r_fe.cliente       := P_JSON.get_object('no_cliente')
                                    .get_string('llave');
        r_fe.proyecto      := P_JSON.get_string('proyecto');
        r_fe.nombre        := P_JSON.get_string('nombre');
        r_fe.correo        := P_JSON.get_string('correo');
        r_fe.direccion     := P_JSON.get_string('direccion');
        r_fe.ordendecompra := P_JSON.get_string('numero_orden');

        v_step := 'CAJERO/VENDEDOR';

        r_fe.cajero := P_JSON.get_object('cajero')
                             .get_string('llave');
        IF P_JSON.has('usuariovendedor') THEN
          r_fe.vendedor := P_JSON.get_object('usuariovendedor')
                                       .get_string('llave');
        ELSE
          r_fe.vendedor := r_fe.cajero;
        END IF;
      END IF;

      v_step := 'TOTALES';

      IF r_fet.clase IN ('F','O') THEN
        r_fe.subtotal  := round(P_JSON.get_number('sub_total'),2);
        r_fe.impuesto  := round(P_JSON.get_number('impuesto' ),2);
        r_fe.descuento := round(P_JSON.get_number('descuento'),2);
      ELSE
        r_fe.subtotal  := r_fe.total;
        r_fe.impuesto  := 0;
        r_fe.descuento := 0;
      END IF;

      v_step := 'ELECTRONICA';

      IF r_fet.clase = 'F' THEN
        FA_ELECTRONICA(P_JSON);
      END IF;

      v_step := 'SIGNO';

      IF r_fet.fix_signo != 1 THEN
        r_fe.total     := r_fet.fix_signo * r_fe.total;
        r_fe.subtotal  := r_fet.fix_signo * r_fe.subtotal;
        r_fe.impuesto  := r_fet.fix_signo * r_fe.impuesto;
        r_fe.descuento := r_fet.fix_signo * r_fe.descuento;
      END IF;

      v_step := 'SALDO';

      IF r_fet.saldo = 'T' THEN
        r_fe.saldo := r_fe.total;
      ELSE
        r_fe.saldo := 0;
      END IF;
  /*
  no se puede poner en producción porque el cliente que viene del girador esta en el pago y el pago es hijo de la factura
      IF r_fet.credito = 1 THEN
        v_error := 'Se requiere un cliente para este tipo de documento';
        RAISE no_data_found;
      END IF;
  */
      IF v_dup = 4 THEN
        NULL;
      ELSIF v_accion = 'FFPLAN' THEN
        IF nvl(P_JSON.get_string('forzar'),'N') = 'S' THEN

          v_step := 'DEL-FFD_FFPLAN:'||r_fe.key_docu;

          DELETE
            FROM cz_fa.arfaffd a
           WHERE a.key_docu = r_fe.key_docu;

          v_step := 'DEL-FF_FFPLAN:'||r_fe.key_docu;

          DELETE
            FROM cz_fa.arfaff a
           WHERE a.key_docu = r_fe.key_docu;
        ELSE

          v_step := 'SEL-FF-CNT:'||r_fe.key_docu;

          SELECT decode(COUNT(1),0,3,1)
            INTO v_dup
            FROM arfaff f
           WHERE f.key_docu = r_fe.key_docu;
        END IF;
      ELSE

        v_step := 'INS-FE';

        BEGIN
          v_dup := 0;
          INSERT INTO arfafe VALUES r_fe;
        EXCEPTION
          WHEN dup_val_on_index THEN
            IF r_fet.clase IN ('I') THEN

              v_step := 'UPD-FE_DUP:'||r_fe.id_docu||','||r_fe.sistema;

              UPDATE arfafe e
                 SET e.no_cia        = r_fe.no_cia,
                     e.centro        = r_fe.centro,
                     e.tipo          = r_fe.tipo,
                     e.subtipo       = r_fe.subtipo,
                     e.pago          = r_fe.pago,
                     e.fecha         = r_fe.fecha,
                     e.hora          = r_fe.hora,
                     e.total         = r_fe.total,
                     e.subtotal      = r_fe.subtotal,
                     e.impuesto      = r_fe.impuesto,
                     e.descuento     = r_fe.descuento,
                     e.saldo         = r_fe.saldo,
                     e.sistema       = r_fe.sistema,
                     e.canal         = r_fe.canal,
                     e.origen        = r_fe.origen,
                     e.nombre        = r_fe.nombre,
                     e.direccion     = r_fe.direccion,
                     e.cliente       = r_fe.cliente,
                     e.proyecto      = r_fe.proyecto,
                     e.cajero        = r_fe.cajero,
                     e.vendedor      = r_fe.vendedor,
                     e.ordendecompra = r_fe.ordendecompra,
                     e.observacion   = r_fe.observacion,
                     e.data          = r_fe.data,
                     e.estado        = r_fe.estado,
                     e.cufe          = r_fe.cufe,
                     e.cufe_path     = r_fe.cufe_path,
                     e.correo        = r_fe.correo
               WHERE e.key_docu = r_fe.key_docu
                 AND e.id_docu  = r_fe.id_docu;
              IF SQL%rowcount = 0 THEN
                RAISE no_data_found;
              END IF;

              v_step := 'UPD-FL_X:'||r_fe.key_docu;

              UPDATE arfafl a
                 SET a.externo = 'x'
               WHERE a.key_docu = r_fe.key_docu;
              v_dup := 2;
            ELSE

              v_step := 'SEL-FE_DUP:'||r_fe.id_docu||','||r_fe.sistema;

              SELECT a.*
                INTO r_fe
                FROM arfafe a
               WHERE a.id_docu = r_fe.id_docu
                 AND a.sistema = r_fe.sistema;
              IF r_fe.fecha_modifica > (SYSDATE-10/1440) THEN
                v_code  := 525;
                v_error := 'Reintento: '
                           ||to_char(SYSDATE,'MM-DD HH24:MI:SS')
                           ||' Actualización: '
                           ||to_char(r_fe.fecha_modifica,'MM-DD HH24:MI:SS');
                RAISE dup_val_on_index;
              END IF;
              v_dup := 1;
            END IF;
        END;
      END IF;
      IF v_dup = 0 THEN

        v_step := 'FR';

        r_fr.usuario_crea     := USER;
        r_fr.fecha_crea       := SYSDATE;
        r_fr.usuario_modifica := USER;
        r_fr.fecha_modifica   := SYSDATE;
        r_fr.key_docu         := r_fe.key_docu;
        r_fr.monto            := nvl(r_fr.monto,r_fe.total);
        r_fr.fecha            := r_fe.fecha;

        v_step := 'INS-FRO:'||r_fr.key_refe;

        IF r_fx.key_docu IS NOT NULL THEN
          r_fr.secuencia := 1;
          r_fr.id        := 0;
            INSERT INTO arfafr VALUES r_fr;
        END IF;
        r_fr.monto := r_fe.total;

        v_step := 'REFERENCIAS';

        IF P_JSON.has('referencias') THEN
          jl := P_JSON.get_array('referencias');
          r_fr.tipo_refe := 'R';
          FOR i IN 0 .. jl.get_size - 1 LOOP

            v_step := 'REFER:'||i;

            js := json_object_t(jl.get(i));
            r_fr.key_refe := js.get_string('llave');
            IF r_fr.key_refe IS NOT NULL THEN

              v_step := 'SEL-REFER:'||r_fr.key_refe;

              SELECT a.id_docu
                INTO r_fr.id_refe
                FROM arfafe a
               WHERE a.key_docu = r_fr.key_refe;

              v_step := 'INS-FRR:'||r_fr.key_refe;

              r_fr.secuencia := 1;
              r_fr.id        := 0;
              INSERT INTO arfafr VALUES r_fr;
            END IF;
          END LOOP;
        END IF;

        v_step := 'ANULA';

        IF P_JSON.has('anula') THEN
          js := P_JSON.get_object('anula');
          r_fr.tipo_refe := 'A';
          r_fr.key_refe  := js.get_string('llave');
          IF r_fr.key_refe IS NOT NULL THEN

            v_step := 'SEL-REFEA:'||r_fr.key_refe;

            SELECT a.id_docu
              INTO r_fr.id_refe
              FROM arfafe a
             WHERE a.key_docu = r_fr.key_refe;

            v_step := 'INS-FRA:'||r_fr.key_refe;

            r_fr.secuencia := 1;
            r_fr.id        := 0;
            INSERT INTO arfafr VALUES r_fr;
          END IF;
        END IF;

        v_step := 'REMESA';

        IF P_JSON.has('remesa') THEN
          js := P_JSON.get_object('remesa');
          r_fr.tipo_refe := 'M';
          r_fr.key_refe  := js.get_string('llave');
          r_fr.codigo    := js.get_string('Id');
          IF r_fr.key_refe IS NOT NULL THEN

            v_step := 'SEL-REFEM:'||r_fr.key_refe;

            SELECT a.id_docu
              INTO r_fr.id_refe
              FROM arfafe a
             WHERE a.key_docu = r_fr.key_refe;

            v_step := 'INS-FRM:'||r_fr.key_refe;

            r_fr.secuencia := 1;
            r_fr.id        := 0;
            INSERT INTO arfafr VALUES r_fr;
          END IF;
        END IF;
      END IF;
      IF v_dup = 4 THEN
        NULL;
      ELSIF v_dup = 3 THEN
        jr := P_JSON.get_object('data');
        FA_FFPLAN;
      ELSIF v_dup IN (0,2) THEN

        v_step := 'CERTIFICADOS';

        IF P_JSON.has('certificados') THEN
          jl := P_JSON.get_array('certificados');
          r_tr.usuario_crea     := USER;
          r_tr.fecha_crea       := SYSDATE;
          r_tr.usuario_modifica := USER;
          r_tr.fecha_modifica   := SYSDATE;
          r_tr.key_docu         := r_fe.key_docu;
          FOR i IN 0 .. jl.get_size - 1 LOOP

            v_step := 'TR:'||i;

            js := json_object_t(jl.get(i));
            r_tr.secuencia := i+1;
            r_tr.correo    := js.get_string('correo');
            r_tr.nombre    := js.get_string('nombre');
            r_tr.mensaje   := js.get_string('mensaje');
            r_tr.numero    := js.get_string('numero');
            r_tr.imagen    := js.get_string('imagen');
            r_tr.pin       := js.get_string('pin');
            r_tr.monto     := js.get_number('monto');

            v_step := 'INS-TR:'||r_tr.numero;

            INSERT INTO arfatr VALUES r_tr;
          END LOOP;
        END IF;

        v_step := 'ARTICULOS';

        IF r_fet.clase IN ('F','O','S','I') THEN
          jl := P_JSON.get_array('articulos');
          r_fl.usuario_crea     := USER;
          r_fl.fecha_crea       := SYSDATE;
          r_fl.usuario_modifica := USER;
          r_fl.fecha_modifica   := SYSDATE;
          r_fl.confirmada       := 0;
          r_fl.despachada       := 0;
          r_fl.entregada_dv     := 0;
          r_fl.picada           := 0;
          r_fl.key_docu         := r_fe.key_docu;

          v_step := 'LOO-FL';

          FOR i IN 0 .. jl.get_size - 1 LOOP

            v_step := 'ARTI:'||i;

            js := json_object_t(jl.get(i));
            IF r_fet.clase IN ('I') THEN
              r_fl.linea      := js.get_number('linea');
            ELSE
              r_fl.linea      := i+1;
            END IF;
            r_fl.no_arti      := js.get_object('no_arti')
                                   .get_string('llave');
            r_fl.linea_origen := 0;
            IF js.has('externo_arti') THEN
              r_fl.externo    := js.get_object('externo_arti')
                                   .get_string('llave');

              v_step := 'SEL-ORIGEN:'||r_fx.key_docu||':'||r_fl.externo;

              IF r_fl.externo IS NULL THEN
                CZ_MS.SKMS.LOG(P_JSON.to_clob,to_clob(NULL),'SKFA','FA',v_step);
              ELSE
                SELECT a.linea
                  INTO r_fl.linea_origen
                  FROM arfafl a
                 WHERE a.key_docu = r_fx.key_docu
                   AND a.externo  = r_fl.externo;
              END IF;
            ELSIF js.has('externo_ffd') THEN
              r_fl.externo    := js.get_object('externo_ffd')
                                   .get_string('llave');

              v_step := 'SEL-ORIGEN2:'||r_fx.key_docu||':'||r_fl.externo;

              IF r_fl.externo IS NULL THEN
                CZ_MS.SKMS.LOG(P_JSON.to_clob,to_clob(NULL),'SKFA','FA',v_step);
              ELSE
                BEGIN
                  SELECT a.linea_origen
                    INTO r_fl.linea_origen
                    FROM arfaffd a
                   WHERE a.key_docu = r_fx.key_docu
                     AND a.externo  = r_fl.externo;
                EXCEPTION
                  WHEN no_data_found THEN
                    IF r_fl.externo != r_fl.no_arti THEN
                      RAISE no_data_found;
                    END IF;
                END;
              END IF;
            ELSIF js.has('linea_origen') THEN
              r_fl.linea_origen := js.get_number('linea_origen');
            END IF;
            IF r_fx.key_docu     IS NOT NULL AND
               r_fl.linea_origen  = 0        THEN

              v_step := 'SEL-ORIGEN3:'||r_fx.key_docu||':'||r_fl.externo
                                                     ||':'||r_fl.no_arti;

              BEGIN
                SELECT a.linea
                  INTO r_fl.linea_origen
                  FROM arfafl a
                 WHERE a.key_docu = r_fx.key_docu
                   AND a.no_arti  = r_fl.no_arti;
              EXCEPTION
                WHEN no_data_found THEN
                  IF js.has('externo_arti') OR
                     js.has('externo_ffd' ) THEN
                    RAISE no_data_found;
                  END IF;
                WHEN too_many_rows THEN
                  IF js.has('externo_arti') OR
                     js.has('externo_ffd' ) THEN
                    RAISE too_many_rows;
                  END IF;
              END;
            END IF;

            v_step := 'ARTId:'||i;

            r_fl.externo      := json_object_t(json_array_t(
                                   js.get_array('externo'))
                                     .get(0))
                                     .get_string('llave');
            r_fl.cantidad     := js.get_number('cantidad');
            r_fl.devuelta     := 0;
            r_fl.devuelta_uom := 0;
            r_fl.descripcion  := nvl(js.get_string('descripcion'),r_fl.no_arti||' s/d'); /**/-- no debe existir un producto sin descripción, cargarla del nuevo arinda
            IF js.has('data') THEN
              IF nvl(js.get_type('data'),'SCALAR') = 'SCALAR' THEN
                r_fl.data := js.get_string('data');
              ELSE
                r_fl.data := js.get_object('data').to_clob;
              END IF;
            END IF;
            IF r_fet.clase IN ('S') THEN

              v_step := 'UoM:'||r_fl.no_arti||':'||r_fl.externo;

              IF js.has('uom') THEN
                r_fl.uom            := js.get_string('uom');
                r_fl.cantidad_uom   := js.get_number('cantidad_uom');
              ELSE
                IF r_fx.key_docu IS NULL THEN
                  RAISE no_data_found;
                END IF;
                SELECT a.uom,
                       r_fl.cantidad * a.cantidad_uom / a.cantidad
                  INTO r_fl.uom,
                       r_fl.cantidad_uom
                  FROM arfafl a
                 WHERE a.key_docu = r_fx.key_docu
                   AND a.externo  = r_fl.externo;
              END IF;
              r_fl.lista_precio  := '00';
              r_fl.precio        := 0;
              r_fl.precio_uom    := 0;
              r_fl.costo         := 0;
              r_fl.subtotal      := 0;
              r_fl.descuento     := 0;
              r_fl.impuesto      := 0;
              r_fl.tasa          := 0;
              r_fl.entregada     := 0;
              r_fl.entregada_uom := 0;
            ELSE
              r_fl.uom           := js.get_string('uom');
              r_fl.cantidad_uom  := js.get_number('cantidad_uom');
              r_fl.lista_precio  := nvl(js.get_string('lista_precio'),'00');
              r_fl.precio        := js.get_number('precio');
              r_fl.precio_uom    := js.get_number('precio_uom');
              r_fl.costo         := js.get_number('costo'); -- se actualiza con el de entrega directa
              r_fl.subtotal      := js.get_number('total');
              r_fl.descuento     := js.get_number('descuento');
              r_fl.impuesto      := js.get_number('impuesto');
              r_fl.tasa          := js.get_number('iva');
              r_fl.entregada     := js.get_number('entregada');
              r_fl.entregada_uom := js.get_number('entregada_uom');
            END IF;
            r_fl.estado := GET_ESTADO(r_fe.tipo,js);

            v_step := 'INS-FL';

            BEGIN
              INSERT INTO arfafl VALUES r_fl;
            EXCEPTION
              WHEN dup_val_on_index THEN
                IF r_fet.clase NOT IN ('I') THEN
                  RAISE dup_val_on_index;
                END IF;

                v_step := 'UPD-FL:'||r_fl.key_docu||':'||r_fl.linea;

                r_fl.devuelta     := r_fl.cantidad    -r_fl.entregada;
                r_fl.devuelta_uom := r_fl.cantidad_uom-r_fl.entregada_uom;
                UPDATE arfafl a
                   SET /*
                       a.no_arti       = r_fl.no_arti,
                       a.descripcion   = r_fl.descripcion,
                       a.uom           = r_fl.uom,
                       a.precio        = r_fl.precio,
                       a.precio_uom    = r_fl.precio_uom,
                       a.costo         = r_fl.costo,
                       a.subtotal      = r_fl.subtotal,
                       a.descuento     = r_fl.descuento,
                       a.impuesto      = r_fl.impuesto,
                       a.tasa          = r_fl.tasa,
                       a.lista_precio  = r_fl.lista_precio,
                       a.data          = r_fl.data,
                       */
                       a.linea_origen  = r_fl.linea_origen,
                       a.cantidad      = r_fl.cantidad,
                       a.cantidad_uom  = r_fl.cantidad_uom,
                       a.externo       = r_fl.externo,
                       a.entregada     = r_fl.entregada,
                       a.entregada_uom = r_fl.entregada_uom,
                       a.devuelta      = decode(a.devuelta,0,0,r_fl.devuelta),
                       a.devuelta_uom  = decode(a.devuelta,0,0,r_fl.devuelta_uom),
                       a.estado        = r_fl.estado
                 WHERE a.key_docu = r_fl.key_docu
                   AND a.linea    = r_fl.linea;
                IF SQL%rowcount=0 THEN
                  RAISE no_data_found;
                END IF;
            END;
          END LOOP;
          IF v_step = 'ARTICULOS' THEN
            RAISE no_data_found;
          END IF;
          IF r_fet.clase IN ('I') THEN

            v_step := 'DEL-FLX_UPD';

            DELETE
              FROM arfaflx b
             WHERE (b.key_docu,
                    b.linea   )  IN (
                                     SELECT a.key_docu,
                                            a.linea
                                       FROM arfafl a
                                      WHERE a.key_docu = r_fe.key_docu
                                        AND a.externo  = 'x'
                                    )
               AND b.sistema = 'ivd';

            v_step := 'LOOP-DEL-FL_UPD:'||r_fe.key_docu;

            FOR r IN (
                      SELECT a.linea,
                             a.ROWID id
                        FROM arfafl a
                       WHERE a.key_docu = r_fe.key_docu
                         AND a.externo  = 'x'
                     )
            LOOP

              v_step := 'DEL-FL_UPD:'||r_fe.key_docu||':'||r.linea;

              DELETE
                FROM arfafl a
               WHERE a.ROWID = r.id;
              IF SQL%rowcount=0 THEN
                RAISE no_data_found;
              END IF;
            END LOOP;
          END IF;
        END IF;

        v_step := 'sATRIBS';

        r_fa.key_docu          := r_fe.key_docu;
        r_fa.usuario_crea      := USER;
        r_fa.fecha_crea        := SYSDATE;
        r_fa.usuario_modifica  := USER;
        r_fa.fecha_modifica    := SYSDATE;
        IF P_JSON.has('atributos') THEN
          c := P_JSON.get_array('atributos').to_clob;
          FOR r IN (
                    SELECT nvl(e.padre,e.atributo)           atributo,
                           LISTAGG(a.valor,' ')
                             WITHIN GROUP (ORDER BY e.orden) valor
                      FROM JSON_TABLE(
                             c, '$[*]'
                             COLUMNS (
                               SISTEMA     VARCHAR2(3)    PATH '$.atributo.sistema',
                               ID_EXTERNO  VARCHAR2(50)   PATH '$.atributo.id',
                               KEY_EXTERNO VARCHAR2(50)   PATH '$.atributo.key',
                               VALOR       VARCHAR2(4000) PATH '$.valor')
                           )        a,
                           arfafaax b,
                           arfafaax d,
                           arfafaa  e
                     WHERE nvl(upper(trim(a.valor)),'N/A') NOT IN ('S/D','N/A')
                       AND b.sistema     (+)= a.sistema
                       AND b.id_externo  (+)= a.id_externo
                       AND d.sistema     (+)= a.sistema
                       AND d.key_externo (+)= a.key_externo
                       AND e.atributo       = nvl(b.atributo,d.atributo)
                       AND e.guardar        = 1
                     GROUP
                        BY nvl(e.padre,e.atributo)
                   )
          LOOP

            v_step := 'INS-FA:'||r_fa.atributo;

            r_fa.atributo := r.atributo;
            r_fa.valor    := r.valor;
            INSERT INTO arfafa VALUES r_fa;
          END LOOP;
        END IF;
        IF P_JSON.has('entrega') THEN

          v_step := 'ENTREGA';

          js := P_JSON.get_object('entrega');

          v_step := 'INS-FA_CN';

          r_fa.valor := js.get_string('contacto');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'CN';
            INSERT INTO arfafa VALUES r_fa;
          END IF;

          v_step := 'INS-FA_CT';

          r_fa.valor := js.get_number('telefono');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'CT';
            INSERT INTO arfafa VALUES r_fa;
          END IF;

          v_step := 'INS-FA_AN';

          r_fa.valor := js.get_string('instrucciones');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'AN';
            INSERT INTO arfafa VALUES r_fa;
          END IF;

          v_step := 'INS-FA_LA';

          r_fa.valor := js.get_number('latitud');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'LA';
            INSERT INTO arfafa VALUES r_fa;
          END IF;

          v_step := 'INS-FA_LO';

          r_fa.valor := js.get_number('longitud');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'LO';
            INSERT INTO arfafa VALUES r_fa;
          END IF;

          v_step := 'INS-FA_AU';

          r_fa.valor := js.get_string('corregimiento');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'AU';
            INSERT INTO arfafa VALUES r_fa;
          END IF;

          v_step := 'INS-FA_AA';

          r_fa.valor := js.get_string('alias');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'AA';
            INSERT INTO arfafa VALUES r_fa;
          END IF;
        END IF;
        IF P_JSON.has('data') THEN

          v_step := 'DATA';

          jr := P_JSON.get_object('data');

          v_step := 'INS-FA_RN';

          r_fa.valor := jr.get_string('numero');
          jr.remove('numero');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'RN';
            INSERT INTO arfafa VALUES r_fa;
          END IF;

          v_step := 'INS-FA_RA';

          r_fa.valor := jr.get_string('autorizacion');
          jr.remove('autorizacion');
          IF nvl(upper(trim(r_fa.valor)),'N/A') NOT IN ('S/D','N/A') THEN
            r_fa.atributo := 'RA';
            INSERT INTO arfafa VALUES r_fa;
          END IF;

          v_step := 'MUNI';

          IF jr.has('municiones') THEN
            jl := jr.get_array('municiones');
            jr.remove('municiones');
            IF jl.get_size > 0 THEN
              js := json_object_t(jl.get(0));

              v_step := 'INS-FA_MC';

              r_fa.atributo := 'MC';
              r_fa.valor    := js.get_string('cedula');
              INSERT INTO arfafa VALUES r_fa;

              v_step := 'INS-FA_MT';

              r_fa.atributo := 'MT';
              r_fa.valor    := js.get_string('telefono');
              INSERT INTO arfafa VALUES r_fa;

              v_step := 'INS-FA_MP';

              r_fa.atributo := 'MP';
              r_fa.valor    := js.get_string('permiso');
              INSERT INTO arfafa VALUES r_fa;
            END IF;
          END IF;

          v_step := 'EDIRECTA';

          IF jr.has('entregadirecta') THEN
            js := jr.get_object('entregadirecta');
            jr.remove('entregadirecta');
            IF js.has('proveedor') THEN

              v_step := 'INS-FA_MP';

              r_fa.atributo := 'DP';
              r_fa.valor := js.get_object('proveedor')
                              .get_string('llave');
              INSERT INTO arfafa VALUES r_fa;

              v_step := 'COSTO';

              jl := js.get_array('articulos');
              FOR i IN 0 .. jl.get_size - 1 LOOP

                v_step := 'ED:'||i;

                jt := json_object_t(jl.get(i));
                r_fl.costo   := jt.get_number('costo');
                r_fl.no_arti := jt.get_object('no_arti')
                                  .get_string('llave');

                v_step := 'UPD-FL_ED:'||r_fl.key_docu||':'||r_fl.no_arti;

                UPDATE arfafl l
                   SET l.costo = r_fl.costo
                 WHERE l.key_docu = r_fl.key_docu
                   AND l.no_arti  = r_fl.no_arti;
                IF SQL%rowcount = 0 THEN
                  RAISE no_data_found;
                END IF;
              END LOOP;
            END IF;
          END IF;

          v_step := 'GEXTENDIDA';

          IF jr.has('garantias') THEN
            jl := jr.get_array('garantias');
            jr.remove('garantias');
            r_fg.key_docu          := r_fe.key_docu;
            r_fg.usuario_crea      := USER;
            r_fg.fecha_crea        := SYSDATE;
            r_fg.usuario_modifica  := USER;
            r_fg.fecha_modifica    := SYSDATE;
            FOR i IN 0 .. jl.get_size - 1 LOOP

              v_step := 'FG:'||i;

              js := json_object_t(jl.get(i));
              r_fg.secuencia := i+1;
              r_fg.no_arti   := js.get_object('no_arti')
                                  .get_string('llave');
              r_fg.monto     := js.get_object('ge')
                                  .get_number('v');
              r_fg.meses     := js.get_object('ge')
                                  .get_number('m');
              r_fg.serie     := js.get_object('ge')
                                  .get_string('s');

              v_step := 'INS-FG:'||r_fg.no_arti;

              INSERT INTO arfafg VALUES r_fg;
            END LOOP;
          END IF;

          v_step := 'REMESA';

          IF jr.has('remesa') THEN
            js := jr.get_object('remesa');
            jr.remove('remesa');
            IF js.has('monto') THEN
              r_fm.key_docu          := r_fe.key_docu;
              r_fm.usuario_crea      := USER;
              r_fm.fecha_crea        := SYSDATE;
              r_fm.usuario_modifica  := USER;
              r_fm.fecha_modifica    := SYSDATE;
              r_fm.tipo_di_envio     := js.get_string('tipo_di_snd');
              r_fm.di_envio          := js.get_string('cedula_snd');
              r_fm.nombre_envio      := js.get_string('nombre_snd');
              r_fm.no_cia_recibo     := js.get_string('no_cia_destino');
              r_fm.centro_recibo     := js.get_string('centro_destino');
              r_fm.tipo_di_recibo    := js.get_string('tipo_di_rcp');
              r_fm.di_recibo         := js.get_string('cedula_rcp');
              r_fm.nombre_recibo     := js.get_string('nombre_rcp');
              r_fm.parentesco        := js.get_string('parentesco');
              r_fm.monto             := js.get_number('monto');
              r_fm.motivo            := js.get_string('motivo');
              IF r_fm.di_envio IS NOT NULL THEN

                v_step := 'INS-FM:'||r_fm.key_docu;

                INSERT INTO arfafm VALUES r_fm;
              END IF;
            END IF;
          END IF;

          v_step := 'FFPLAN';

          IF jr.has('planes_de_entrega') THEN
            IF v_dup = 0 THEN
              FA_FFPLAN;
            END IF;
            jr.remove('planes_de_entrega');
          END IF;
          r_fe.data := jr.to_clob;
        END IF;

        v_step := 'PAGOS';

        IF r_fet.clase IN ('F','O','R') THEN
          jl := P_JSON.get_array('pagos');
          r_fp.usuario_crea     := USER;
          r_fp.fecha_crea       := SYSDATE;
          r_fp.usuario_modifica := USER;
          r_fp.fecha_modifica   := SYSDATE;
          FOR i IN 0 .. jl.get_size - 1 LOOP

            v_step := 'PAGO:'||i;

            js := json_object_t(jl.get(i));
            r_fp.secuencia        := i+1;
            r_fp.tipo_pago_inst   := 1;
            r_fp.key_docu         := r_fe.key_docu;
            r_fp.numero           := js.get_string('numero');
            r_fp.girador          := js.get_string('girador');
            r_fp.tipo             := js.get_string('tipo');
            r_fp.autorizacion     := js.get_string('autorizacion');
            r_fp.cuenta           := js.get_string('cuenta');
            r_fp.tx               := js.get_string('tx');
            r_fp.tk               := js.get_string('tk');
            r_fp.cantidad         := js.get_number('cantidad');
            IF js.has('banco') THEN
              r_fp.banco          := js.get_object('banco')
                                       .get_string('llave');
            END IF;
            r_fp.fecha_vence      := to_date(js.get_string('fecha_vence'),
                                             'DD/MM/YYYY');
            r_fp.externo          := json_object_t(json_array_t(
                                       js.get_array('externo'))
                                         .get(0))
                                         .get_string('llave');
            r_fp.monto            := round(js.get_number('monto'),2);
            IF r_fet.fix_signo != 1 THEN
              r_fp.monto := r_fet.fix_signo * r_fp.monto;
            END IF;
            IF nvl(js.get_type('data'),'SCALAR') = 'SCALAR' THEN
              r_fl.data := js.get_string('data');
            ELSE
              r_fl.data := js.get_object('data').to_clob;
            END IF;
            r_fp.tipo_pago        := js.get_object('tipo_pago')
                                       .get_string('llave');

            v_step := 'SEL-TP:'||r_fp.tipo_pago;

            SELECT a.*
              INTO r_tp
              FROM arfatp a
             WHERE a.tipo_pago = r_fp.tipo_pago;

            v_step := 'SEL-TPD1:'||r_fe.tipo||' '||r_fp.tipo_pago;

            IF r_tp.restringido = 1 OR r_fet.restringido = 1 THEN
              BEGIN
                SELECT v_step
                  INTO v_step
                  FROM arfatpd a
                 WHERE a.tipo_pago = r_fp.tipo_pago
                   AND a.tipo      = r_fe.tipo;
              EXCEPTION
                WHEN no_data_found THEN
                  v_error := 'Combinación DOCUMENTO-PAGO no permitida '
                             ||r_fe.tipo||' '||r_fp.tipo_pago;
                  RAISE no_data_found;
              END;
            END IF;

            v_step := 'SEL-TPD2:'||r_fe.tipo||' '||r_fp.tipo_pago;

            IF r_tp.restringido = 2 OR r_fet.restringido = 2 THEN
              BEGIN
                SELECT v_step
                  INTO v_step
                  FROM arfatpd a
                 WHERE a.tipo_pago = r_fp.tipo_pago
                   AND a.tipo      = r_fe.tipo;
                v_error := 'Combinación DOCUMENTO-PAGO no permitida '
                           ||r_fe.tipo||' '||r_fp.tipo_pago;
                RAISE dup_val_on_index;
              EXCEPTION
                WHEN no_data_found THEN
                  NULL;
              END;
            END IF;

            v_step := 'SALDO:'||r_fp.tipo_pago;

            IF r_tp.saldo = 'S' THEN
              IF r_fet.saldo = 'T' THEN
                v_error := 'El tipo de documento y la forma de pago afectan el saldo. Revisar';
                RAISE no_data_found;
              ELSIF r_fet.saldo = 'S' THEN
                r_fe.saldo := r_fe.saldo + r_fp.monto;
              END IF;
            END IF;

            v_step := 'INS-FP:'||r_fp.externo;

            INSERT INTO arfafp VALUES r_fp;

            v_step :='pATRIBS:'||r_fp.externo;

            IF js.has('atributos') THEN
              c := js.get_array('atributos').to_clob;
              r_fpa.key_docu          := r_fp.key_docu;
              r_fpa.secuencia         := r_fp.secuencia;
              r_fpa.usuario_crea      := USER;
              r_fpa.fecha_crea        := SYSDATE;
              r_fpa.usuario_modifica  := USER;
              r_fpa.fecha_modifica    := SYSDATE;
              r_fp.usuario_modifica   := NULL;
              FOR r IN (
                        SELECT decode(e.dato,
                                 NULL,nvl(e.padre,e.atributo))   atributo,
                               e.dato,
                               LISTAGG(a.valor,' ')
                                 WITHIN GROUP (ORDER BY e.orden) valor
                          FROM JSON_TABLE(
                                 c, '$[*]'
                                 COLUMNS (
                                   SISTEMA     VARCHAR2(3)    PATH '$.atributo.sistema',
                                   ID_EXTERNO  VARCHAR2(50)   PATH '$.atributo.id',
                                   KEY_EXTERNO VARCHAR2(50)   PATH '$.atributo.key',
                                   VALOR       VARCHAR2(4000) PATH '$.valor')
                               )        a,
                               arfafaax b,
                               arfafaax d,
                               arfafaa  e
                         WHERE nvl(upper(trim(a.valor)),'N/A') NOT IN ('S/D','N/A')
                           AND b.sistema     (+)= a.sistema
                           AND b.id_externo  (+)= a.id_externo||'@'||r_fp.tipo_pago
                           AND d.sistema     (+)= a.sistema
                           AND d.key_externo (+)= a.key_externo
                           AND e.atributo       = nvl(b.atributo,d.atributo)
                           AND e.guardar        = 1
                         GROUP
                            BY decode(e.dato,
                                 NULL,nvl(e.padre,e.atributo)),
                               e.dato
                       )
              LOOP

                v_step := 'INS-FPA:'||r_fp.tipo_pago||','||r.atributo;

                IF r.atributo IS NOT NULL THEN
                  r_fpa.atributo := r.atributo;
                  r_fpa.valor    := r.valor;
                  INSERT INTO arfafpa VALUES r_fpa;
                END IF;

                v_step := 'CASE-FPA:'||r_fp.tipo_pago||','||r.atributo||','||r.dato;

                IF r.dato IS NOT NULL THEN
                  r_fp.usuario_modifica := USER;
                  CASE
                    WHEN r.dato = 'autorizacion' THEN r_fp.autorizacion := r.valor;
                    WHEN r.dato = 'banco'        THEN r_fp.banco        := r.valor;
                    WHEN r.dato = 'cantidad'     THEN r_fp.cantidad     := to_number(r.valor);
                    WHEN r.dato = 'cuenta'       THEN r_fp.cuenta       := r.valor;
                    WHEN r.dato = 'fecha_vence'  THEN r_fp.fecha_vence  := to_date(r.valor,'DD/MM/YYYY');
                    WHEN r.dato = 'girador'      THEN r_fp.girador      := r.valor;
                    WHEN r.dato = 'numero'       THEN r_fp.numero       := r.valor;
                    WHEN r.dato = 'tipo'         THEN r_fp.tipo         := r.valor;
                    WHEN r.dato = 'tk'           THEN r_fp.tk           := r.valor;
                    WHEN r.dato = 'tx'           THEN r_fp.tx           := r.valor;
                    ELSE RAISE no_data_found;
                  END CASE;
                END IF;
              END LOOP;

              v_step := 'UPD-FP:'||r_fp.key_docu||','||r_fp.secuencia;

              IF r_fp.usuario_modifica IS NOT NULL THEN
                UPDATE arfafp a
                   SET a.numero       = r_fp.numero,
                       a.girador      = r_fp.girador,
                       a.tipo         = r_fp.tipo,
                       a.autorizacion = r_fp.autorizacion,
                       a.cuenta       = r_fp.cuenta,
                       a.tx           = r_fp.tx,
                       a.tk           = r_fp.tk,
                       a.cantidad     = r_fp.cantidad,
                       a.banco        = r_fp.banco,
                       a.fecha_vence  = r_fp.fecha_vence
                 WHERE a.key_docu  = r_fp.key_docu
                   AND a.secuencia = r_fp.secuencia;
                IF SQL%rowcount = 0 THEN
                  RAISE no_data_found;
                END IF;
              END IF;
            END IF;
            IF r_tp.girador = 'R' AND r_fp.girador IS NULL THEN
              v_error := 'El GIRADOR es requerido';
              RAISE no_data_found;
            END IF;
            IF r_tp.autorizacion = 'R' AND r_fp.autorizacion IS NULL THEN
              IF r_fe.sistema != 'ofu' THEN
                v_error := 'La AUTORIZACION es requerida';
                RAISE no_data_found;
              END IF;

              v_step := 'UPD-FP_ERA:'||r_fp.key_docu||','||r_fp.secuencia;

              UPDATE arfafp a
                 SET a.autorizacion = 'DeERPsinAut'
               WHERE a.key_docu  = r_fp.key_docu
                 AND a.secuencia = r_fp.secuencia;
              IF SQL%rowcount = 0 THEN
                RAISE no_data_found;
              END IF;
            END IF;
          END LOOP;
          IF v_step = 'PAGOS' AND r_fe.total != 0 THEN
            RAISE no_data_found;
          END IF;

          v_step := 'LOO-FP_INST';

          FOR r IN (
                    SELECT a.*
                      FROM (
                            SELECT a.tipo_pago,
                                   a.ROWID rowid_,
                                   ROW_NUMBER()
                                   OVER (PARTITION BY a.tipo_pago
                                         ORDER BY a.externo) tipo_pago_inst
                              FROM arfafp a
                             WHERE a.key_docu = r_fe.key_docu
                           ) a
                     WHERE a.tipo_pago_inst > 1
                   )
          LOOP

            v_step := 'UPD-FP_INST:'||r.tipo_pago||' '||r.tipo_pago_inst;

            UPDATE arfafp a
               SET a.tipo_pago_inst = r.tipo_pago_inst
             WHERE a.ROWID = r.rowid_;
            IF SQL%rowcount = 0 THEN
              RAISE no_data_found;
            END IF;
          END LOOP;
        END IF;

        v_step := 'UPD-FE';

        UPDATE arfafe e
           SET e.data  = r_fe.data,
               e.saldo = r_fe.saldo
         WHERE e.key_docu = r_fe.key_docu;
        IF SQL%rowcount = 0 THEN
          RAISE no_data_found;
        END IF;

  /*
  -- hay que definir donde va --
        IF r_fet.credito = 1 THEN
          IF r_fe.cliente IS NULL THEN
            v_error := 'No indicó el cliente';
            RAISE no_data_found;
          END IF;
        END IF;
  */
        v_step := 'CREA_FX:'||r_fe.id_docu;

        IF v_dup = 2 THEN
          CREA_FX(v_error,r_fe,'IgnoraDuplicado');
        ELSE
          CREA_FX(v_error,r_fe);
        END If;
        IF v_error IS NOT NULL THEN
          RAISE no_data_found;
        END IF;
      ELSE

        v_step := 'CREA_FX_DUP:'||r_fe.id_docu;

        CREA_FX(v_error,r_fe,'IgnoraDuplicado');
        IF v_error IS NOT NULL THEN
          RAISE no_data_found;
        END IF;
      END IF;
    ELSE
      v_error := 'unknown action';
      RAISE no_data_found;
    END IF;

    v_step := 'OUT';

    P_JSON.put('resultado', json_object_t(json_object(
                              'codigo'  VALUE 0   ,
                              'mensaje' VALUE 'Ok',
                              'warning' VALUE ''  )));
  EXCEPTION
    WHEN OTHERS THEN
      v_code  := nvl(v_code,99);
      v_error := 'SKFA.FA:'||nvl(v_error,v_step||':'||SQLERRM);
      IF g_Trigger = 0 THEN
        ROLLBACK TO skfa_fa_sp;
      END IF;
      P_JSON.put('resultado', json_object_t(json_object(
                                'codigo'  VALUE v_code ,
                                'mensaje' VALUE v_error,
                                'warning' VALUE ''     )));
  END;
  ------------------------------------------------------------------------------
  PROCEDURE FX(P_IN  IN     CLOB,
               P_OUT    OUT CLOB)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_step  VARCHAR2(100) := 'INICIO';
    v_error VARCHAR2(4000);
    r_fx    arfafx%ROWTYPE;
    i       PLS_INTEGER;
    jr      json_object_t := json_object_t(P_IN);
    js      json_object_t;
    jl      json_array_t;
  BEGIN

    v_step := 'ARRAY';

    jl := jr.get_array('documentos');
    FOR i IN 0 .. jl.get_size - 1 LOOP
      js := json_object_t(jl.get(i));
      BEGIN
        SAVEPOINT sp_fx;

        v_step := 'DATA';

        r_fx.id_subdocu  := js.get_string('id_subdocu' );
        r_fx.sistema     := js.get_string('sistema'    );
        r_fx.id_externo  := js.get_string('id_externo' );
        r_fx.key_externo := js.get_string('key_externo');
        r_fx.estado      := js.get_string('estado'     );
        r_fx.comentario  := js.get_string('comentario' );
        r_fx.total       := js.get_number('total'      );

        v_step := 'UPD:'||r_fx.sistema||':'||r_fx.id_subdocu;

        UPDATE arfafx a
           SET a.id_externo  = nvl(r_fx.id_externo ,a.id_externo ),
               a.key_externo = nvl(r_fx.key_externo,a.key_externo),
               a.estado      = nvl(r_fx.estado     ,a.estado     ),
               a.total       = nvl(r_fx.total      ,a.total      ),
               a.comentario  = r_fx.comentario
         WHERE a.id_subdocu = r_fx.id_subdocu
           AND a.sistema    = r_fx.sistema
        RETURN a.key_docu,
               a.tipo
          INTO r_fx.key_docu,
               r_fx.tipo;
        IF SQL%rowcount = 0 THEN
          IF substr(r_fx.id_subdocu,1,1) != 'a' THEN -- aplicaciones de DVs
            RAISE no_data_found;
          END IF;
        END IF;

        v_step := 'AJUSTE_TOTAL';

        IF r_fx.sistema = 'ofu'    AND
           r_fx.estado  = 'A'      AND
           r_fx.total  IS NOT NULL THEN
          FOR r IN (
                    SELECT a.id_subdocu,
                           a.sistema,
                           a.total,
                           b.id_subdocu_a,
                           b.id_subdocu_ori
                      FROM (
                            SELECT a.id_subdocu,
                                   a.sistema,
                                   a.total
                              FROM arfafx a
                             WHERE a.key_docu = r_fx.key_docu
                               AND a.sistema  = r_fx.sistema
                               AND a.tipo    IN ('PC','PR')
                           ) a,
                           (
                            SELECT a.id_subdocu           id_subdocu_a,
                                   a.sistema,
                                   a.total,
                                   substr(a.id_subdocu,2) id_subdocu_ori
                              FROM arfafx a
                             WHERE a.key_docu = r_fx.key_docu
                               AND a.sistema  = r_fx.sistema
                               AND a.tipo    IN ('AC','AR')
                           ) b
                     WHERE b.id_subdocu_ori (+)= a.id_subdocu
                     ORDER
                        BY a.id_subdocu
                   )
          LOOP
            r.total    := least(r_fx.total,r.total);
            r_fx.total := r_fx.total - r.total;

            v_step := 'UPD-FX-R:'||r.sistema||':'||r.id_subdocu;

            UPDATE arfafx a
               SET a.total = r.total
             WHERE a.id_subdocu = r.id_subdocu
               AND a.sistema    = r.sistema;
            IF SQL%rowcount = 0 THEN
              RAISE no_data_found;
            END IF;

            v_step := 'UPD-FX-A:'||r.sistema||':'||r.id_subdocu_a;

            IF r.id_subdocu_a IS NOT NULL THEN
              UPDATE arfafx a
                 SET a.total = r.total
               WHERE a.id_subdocu = r.id_subdocu_a
                 AND a.sistema    = r.sistema;
              IF SQL%rowcount = 0 THEN
                RAISE no_data_found;
              END IF;
            END IF;
          END LOOP;
          IF r_fx.total > 0 THEN
            NULL; -- el monto del documento es mayor que los pagos
          END IF;
          IF r_fx.tipo != 'DV' THEN

            v_step := 'SEL-FE:'||r_fx.key_docu;

            SELECT a.id_docu,
                   'ivd'
              INTO r_fx.id_subdocu,
                   r_fx.sistema
              FROM arfafe a
             WHERE a.key_docu = r_fx.key_docu;

            v_step := 'UPD-CCMR';

            UPDATE arccmr a
               SET a.estado = 'A'
             WHERE a.sistema   = r_fx.sistema
               AND a.documento = r_fx.id_subdocu
               AND a.estado    = 'P';
          END IF;
        END IF;

        v_step := 'OUT';

        js.put('resultado', json_object_t(json_object(
                              'codigo'  VALUE 0   ,
                              'mensaje' VALUE 'Ok',
                              'warning' VALUE ''  )));
      EXCEPTION
        WHEN OTHERS THEN
          v_error := nvl(v_error,v_step||':'||SQLERRM);
          ROLLBACK TO sp_fx;
          js.put('resultado', json_object_t(json_object(
                                'codigo'  VALUE 99     ,
                                'mensaje' VALUE v_error,
                                'warning' VALUE ''     )));
          CZ_MS.SKMS.LOG(P_IN,js.to_clob,'SKFA','FX',v_step);
          v_error := NULL;
      END;
      jl.put(i,js,true);
    END LOOP;
    jr.put('documentos',jl);

    v_step := 'COMMIT';

    COMMIT;

    v_step := 'OUT';

    jr.put('resultado', json_object_t(json_object(
                              'codigo'  VALUE 0   ,
                              'mensaje' VALUE 'Ok',
                              'warning' VALUE ''  )));
    P_OUT := jr.to_clob;
  EXCEPTION
    WHEN OTHERS THEN
      v_error := 'SKFA.FX:'||nvl(v_error,v_step||':'||SQLERRM);
      ROLLBACK;
      jr.put('resultado', json_object_t(json_object(
                                'codigo'  VALUE 99     ,
                                'mensaje' VALUE v_error,
                                'warning' VALUE ''     )));
      P_OUT := jr.to_clob;
  END;
  ------------------------------------------------------------------------------
END;