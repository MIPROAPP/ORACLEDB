Descripcion:
En el paquete principal se debe crear un SP que consulte todos los catalogos relacionados al app:

--> tipo solicitud

--> estado solicitud

--> estado cita

-->tipo identificacion

--> tipo telefono

No requiere payload de entrada.

--> el json de salida:

{
"catalogos":{
"tipo_solicitud":[{"id":"A","nombre":"saas"}],
"estado_solicitud":[{"id":"A","nombre":"saas"}],
"estado_cita":[{"id":"A","nombre":"saas"}],
"tecnico":[{"id":"A","nombre":"saas"}],
"empresa":[{"id":"A","nombre":"saas"}]
},
"error":""
}
