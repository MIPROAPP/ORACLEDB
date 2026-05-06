---
config:
  theme: dark
---
erDiagram

%%solicitud
ARMISO {
string solicitud
string cliente
string direccion
string tipo
string estado
string descripcion
string factura
string empresa
number subtotal
number descuento
number impuesto
number total
number tecnico
date inicio
date fin
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

ARMISO||--|| ARMCCL:""
ARMISO||--|| ARMCCLD:""
ARMISO ||--|| ARMISOE:""
ARMISO ||--|{ ARMISOS:""
ARMISO||--|{ARMIFA:""
ARMISO||--|{ARMISR:""
ARMISO||--|{ARMISOT:""
ARMISO||--||ARMITC:""

%%estado solicitud
ARMISOE {
string estado
string nombre
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%tipo solicitud
ARMISOT {
string tipo
string nombre
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%facturas de la solicitud
ARMIFA{
  string key_docu
  string solicitud
  date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

ARMIFA||--||ARFAFE:""

%%solicitudes relacionadas
ARMISR{
  string solicitud
  string solicitud_ref
}

ARMISR||--||ARMISO:""

%%servicios
ARMISOS {
string solicitud
number linea
string no_arti
number precio
number cantidad
number subtotal
number descuento
number impuesto
number total
number tecnico
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

ARMISOS||--|| ARINDA:""
ARMISOS ||--|{ ARMISOSM:""
ARMISOS ||--|{ ARMISOSA:""

%%imagenes adjuntas
ARMISOSM {
string media
string solicitud
number linea
string descipcion
string url
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

%%atributos del servicio
ARMISOSA{
string atributo
string solicitud
number linea
string valor
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

ARMISOSA||--|| ARINCA:""

%%tecnico
ARMITC {
number tecnico
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

ARMITC ||--|| ARINMP:""

%%notificacion
ARMINO {
number notificacion
string titulo
string mensaje
string tipo
date fecha_emision
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}

ARMINO ||--|| ARMINOT:""

%%tipo notificacion
ARMINOT{
string tipo
string nombre
date fecha_emision
date fecha_crea
date fecha_modifica
string usuario_crea
string usuario_modifica
}