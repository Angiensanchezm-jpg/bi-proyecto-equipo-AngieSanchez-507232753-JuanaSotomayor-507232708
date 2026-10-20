# Proyecto de Business Intelligence: BPO Alfa Colombia

## Caso
En este proyecto vamos a analizar cómo se gestionan las liquidaciones y la devolución de activos de las personas que se retiran de BPO Alfa Colombia, nombre ficticio usado en este trabajo. Queremos revisar qué casos se cierran dentro de los diez días calendario y cuáles quedan pendientes, tienen descuentos o requieren reliquidación. Actualmente, cuatro personas hacen seguimiento a las recolecciones y consultan archivos de Excel, Cubic y mensajes de WhatsApp. Analizaremos los datos de 2025 y los disponibles hasta septiembre de 2026 para proponer indicadores y un tablero de seguimiento. Cada retiro se distinguirá por su ID de contrato; un código anonimizado permitirá reconocer si hubo una recontratación.

## Equipo
- Angie Natali Sánchez Muñoz — código 507232753
- Juana Valentina Sotomayor Niño — 507232708

## Herramientas y fuentes previstas
- Excel para revisar y preparar los archivos.
- Archivos CSV exportados de Cubic y DIVIPOLA.
- draw.io para los diagramas.
- GitHub para organizar y documentar el proyecto.

## Estructura
- `datos/`: fuentes, muestras de 20 filas, diccionarios y pasos para obtener los datos.
- `docs/`: PDF de las entregas y diagramas en PNG y formato editable.
- `dw/`: scripts para crear tablas y consultas de conciliación.
- `etl/`: transformaciones, trabajos y sus instrucciones de ejecución.
- `dashboard/`: archivo o enlace del tablero y capturas.
- `modelo/`: notebooks de Python para el modelo predictivo.

## Cómo reproducir el análisis

En esta primera entrega se documentan el caso, las fuentes y el diseño de la solución. El proceso de integración y el tablero todavía no están implementados.

Cuando estén disponibles los archivos autorizados y anonimizados:

1. Consultar `datos/descarga.md` para conocer la procedencia de las fuentes y cómo obtenerlas.
2. Revisar las muestras y los diccionarios en `datos/muestras/` y `datos/diccionarios/`.
3. Seguir las instrucciones de `etl/README.md` para preparar e integrar los datos.
4. Usar los archivos de `dw/` para crear y revisar las tablas.
5. Consultar el tablero y los demás resultados guardados en sus carpetas correspondientes.

No se incluyen datos originales de la empresa en este repositorio.
