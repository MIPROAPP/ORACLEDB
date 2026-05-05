erDiagram

%%Tecnicos
ARMITC {
number id PK
number no_prove
string identificacion
string tipo_identificacion
string nombre
string apellido
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%Solicitud
ARMISO {
string id PK
string usuario
string direccion
date fecha
string tipo
string estado
string descripcion
string factura
string empresa
number subtotal
number descuento
number impuesto
number total
string cotizacion_servicio
string factura_servicio
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%Solicitud - servicio
ARMISOS {
number id PK
string no_arti
string solicitud
string categoria
number precio
number cantidad
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%Estado solicitud
ARMISOE {
string id PK
string nombre
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%Tipo solicitud
ARMISOT {
string id PK
string nombre
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%Imagenes servicios
ARMISOSI {
string ID PK
string servicio
string solicitud
string url
}

%%Solicitud cita
ARMISOC {
number id PK
string solicitud
string servicio
string estado
number tecnico
date inicio
date fin
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%% Relacion cita servicio
ARMISOSC {
string id
string servicio
string cita
}

%%Estado de la cita
ARMISOCE {
string id PK
string nombre
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%Notificaciones
ARMINO {
number id PK
string solicitud
string asunto
string cuerpo
date fecha_emision
string enviado
date fecha_envio
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%Notificaciones de las citas
ARMINOSOC{
string notificacion
string cita
}

%%Notificaciones de la solicitud
ARMINOSO{
string notificacion
string solicitud
}

%%Notificacion de los clientes
ARMINOCL{
string notificacion
string cliente
}

ARINMP ||--|{ ARMITC : "importa"
ARMITC ||--|{ ARMISOC : "contiene"
ARMISO ||--|{ ARMISOS : ""
ARMISO ||--|{ ARMISOC : "relaciona"
ARMISO ||--|| ARMISOT : ""  
ARMISOS ||--|| ARMISOSI : "master"
ARMISOC ||--|{ ARMISOSC : "lineas"
ARMISOC ||--|| ARMISOCE : ""
ARMISOS ||--|| ARINDA : "articulo"
ARMINOSOC ||--|{ ARMINO : ""
ARMISO ||--|{ ARMINO : ""
ARMINOSO ||--|{ ARMINO : ""
ARMINO ||--|{ ARMINOCL : ""
ARMISOE ||--|| ARMISO : ""
ARMISOS ||--|{ ARMISOSC : ""
ARMCCL ||--|{ ARMISO : ""
