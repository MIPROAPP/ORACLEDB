---
config:
  layout: elk
  theme: redux-dark-color
---

erDiagram

    usuario {
        varchar id
        varchar correo
        varchar nombre
        varchar apellido
        varchar tipo
        varchar identificacion
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion

    }

    telefono{
        varchar id
        varchar usuario_id
        number codigo_pais
        number telefono
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    direccion {
        varchar id
        varchar usuario_id
        varchar nombre
        varchar detalle
        varchar latitud
        varchar longitud
        varchar corregimiento
        varchar distrito
        varchar provincia
        varchar calle
        varchar piso
        varchar numero_casa
        varchar barrio
        boolean tiene_ascensor
        boolean es_predeterminada
        boolean es_edificio
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    servicio_categoria {
        varchar id
        varchar nombre
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    servicio {
        varchar id
        varchar sku
        varchar categoria_id
        varchar nombre
        varchar descripcion
        boolean requiere_inspeccion
        number precio
        boolean habilitado
        varchar url_imagen
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    solicitud_tipo{
        varchar id
        varchar nombre
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    solicitud {
        varchar id
        varchar usuario_id
        varchar direccion_id
        datetime fecha
        varchar solicitud_tipo_id
        varchar descripcion
        varchar factura
        varchar empresa
        number subtotal
        number total
        varchar solicitud_estado_id
        varchar cotizacion_servicio
        varchar factura_servicio
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    solicitud_servicio {
        varchar id
        varchar solicitud_id
        varchar categoria_id
        varchar no_arti
        number precio
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    solicitud_estado{
        varchar id
        varchar nombre
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    cita_estado{
        varchar id
        varchar nombre
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    tecnico_empresa{
        varchar id
        varchar nombre
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    tecnico {
        varchar id
        varchar tecnico_empresa_id
        varchar nombre
        varchar apellido
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    cita {
        number id
        varchar solicitud_id
        varchar solicitud_servicio_id
        varchar cita_estado_id
        varchar fecha_programada_inicio
        varchar fecha_programada_fin
        varchar tecnico_id
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    notificacion {
        varchar id
        varchar solicitud_id
        varchar asunto
        varchar cuerpo
        datetime fecha_emision
        boolean enviado
        datetime fecha_envio
        datetime fecha_creacion
        datetime fecha_modificacion
        varchar usuario_creacion
        varchar usuario_modificacion
    }

    usuario ||--|{ telefono:-
    usuario ||--|{ direccion:-
    usuario ||--|{ solicitud:-
    usuario||--|{notificacion:-

    servicio_categoria ||--|{ servicio:-

    solicitud_tipo ||--|{ solicitud:-
    solicitud_estado ||--|{ solicitud: -
    solicitud ||--|{ solicitud_servicio:-
    solicitud ||--|{ cita:-
    solicitud ||--|{ direccion:-
    solicitud ||--|{ notificacion:-

    cita ||--|{ servicio:-
    cita_estado ||--|{ cita:-
    tecnico ||--|{ cita:-
    tecnico_empresa ||--|{tecnico:-
