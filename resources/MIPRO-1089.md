Se debe crear un SP para la consulta de solicitud

json entrada:

{
"solicitud":"sol-22222"
}

json salida:

{"solciitud":{
"id":"sol-22222",
"usuario": "usr-88234",
"direccion": "dir-55421",
"fecha": "2026-04-22T16:45:00Z",
"descripcion": "Mantenimiento preventivo de aire acondicionado",
"destino": "Residencial Los Olivos, Casa 4B",
"empresa": "Servicios Tech S.A.",
"factura":"asdasd",
"tipo":"inspeccion",
"impuesto":0,
"descuento":0,
"subtotal": 85.00,
"total": 95.20,
"cotizacion_servicio": "COT-2026-001",
"factura_servicio": "dsad",
"servicios": [
{
"categoria":"3",
"no_arti": "srv-101",
 "servicio": "limpieza"
"precio": 45.00,
"cantidad": 1
}
],
"citas":[
{
"id":1,
"servicio":"limpieza",
"estado":"en proceso",
"tecnico":"Jim Carrey",
"fecha_programada_inicio":"",
"fecha_programada_fin":""
}
]
}
"error":""
}
