---
config:
  layout: elk
  theme: redux-dark-color
---

erDiagram

    usuario {
        number id
        varchar correo
        varchar nombre
        varchar apellido
        varchar tipo
        varchar identificacion
        varchar activo
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    telefono_tipo {
        varchar id
        varchar tipo
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    telefono {
        number id
        varchar usuario
        varchar tipo
        number codigo_pais
        varchar telefono
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    direccion {
        number id
        varchar usuario
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
        varchar tiene_ascensor
        varchar es_predeterminada
        varchar es_edificio
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    solicitud_tipo {
        varchar id
        varchar nombre
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    solicitud_estado {
        varchar id
        varchar sku
        varchar categoria_id
        varchar nombre
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    solicitud {
        varchar id
        varchar usuario
        varchar direccion
        date fecha
        varchar tipo
        varchar estado
        varchar descripcion
        varchar factura
        varchar empresa
        number subtotal
        number descuento
        number impuesto
        number total
        varchar cotizacion_servicio
        varchar factura_servicio
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    solicitud_servicio {
        number id
        varchar no_arti
        varchar solicitud
        varchar categoria
        number precio
        number cantidad
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    cita_estado {
        varchar id
        varchar nombre
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    tecnico {
        number id
        number no_prove
        varchar identificacion
        varchar tipo_identificacion
        varchar nombre
        varchar apellido
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    cita {
        number id
        varchar solicitud
        varchar servicio
        varchar estado
        number no_prove
        varchar identificacion
        varchar tipo_identificacion
        date fecha_programada_inicio
        date fecha_programada_fin
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    notificacion {
        number id
        varchar solicitud
        varchar asunto
        varchar cuerpo
        date fecha_emision
        varchar enviado
        date fecha_envio
        date fecha_crea
        date fecha_modifica
        varchar usuario_crea
        varchar usuario_modifica
    }

    usuario ||--o{ telefono : usuario
    telefono_tipo ||--o{ telefono : tipo

    usuario ||--o{ direccion : usuario

    usuario ||--o{ solicitud : usuario
    direccion ||--o{ solicitud : direccion
    solicitud_tipo ||--o{ solicitud : tipo
    solicitud_estado ||--o{ solicitud : estado

    solicitud ||--o{ solicitud_servicio : solicitud

    solicitud ||--o{ cita : solicitud
    solicitud_servicio ||--o{ cita : servicio
    cita_estado ||--o{ cita : estado
    tecnico ||--o{ cita : tecnico

    solicitud ||--o{ notificacion : solicitud
