# Datawarehouse de ventas con ETL en SSIS y tablero en Power BI

Trabajo práctico final de **Bases de Datos 2** de la Tecnicatura Universitaria en Inteligencia Artificial (UNR). Diseñé e implementé un datawarehouse para una empresa ficticia de bebidas (*The Drinking Company*), con un proceso ETL en **SQL Server Integration Services (SSIS)** que integra fuentes de distinto tipo, y un tablero en **Power BI** para responder preguntas de las gerencias.

## El caso

La empresa vende bebidas (colas, cervezas, gaseosas, jugos y energizantes) a clientes minoristas y mayoristas en cuatro regiones de Estados Unidos. Sus datos estaban repartidos en sistemas distintos, y el objetivo era unificarlos en un datawarehouse para analizar ventas, clientes, empleados y stock a lo largo del tiempo.

## Fuentes de datos integradas

| Área | Fuente | Formato |
|---|---|---|
| Ventas históricas (hasta 2008) | Base de datos SQL Server | Base relacional |
| Ventas actuales (desde 2009) | Base de datos MySQL, con tablas de precios y descuentos | Base relacional (vía ODBC) |
| Clientes minoristas y mayoristas | Servicio web | XML |
| Empleados y feriados | Recursos Humanos | Archivos planos |
| Productos, stock y regiones | Producción y Comercialización | Archivos planos |

Los datos pertenecen a la cátedra y **no se incluyen en este repositorio**.

## Modelo dimensional

Esquema en estrella para las ventas, más una segunda tabla de hechos para el inventario (modelo tipo constelación):

- **Hechos:** `FactSales` (cantidad, litros vendidos, precio unitario, descuento e importe de la venta) y `FactInventory` (movimientos de stock).
- **Dimensiones:** `DimDate` (calendario generado por script, con marca de fin de semana y feriados), `DimProduct`, `DimCustomer`, `DimEmployee` y `DimRegion`. El inventario usa sus propias `DimDate2` y `DimProduct2`.
- **Staging:** tablas intermedias (`StageSales`, `StageCustomer`, `StageEmployee`, `StageInventory`, `StageHoliday`, `StageDiscounts`) donde se cargan las fuentes antes de transformarlas.
- Las ventas sin zona identificable se asignan a un registro `Unknown` en `DimRegion`, para no perder filas en la carga.

## Proceso ETL (SSIS)

El proyecto está en `etl-ssis/` y se ejecuta en dos etapas:

**1. Staging (`Stage*.dtsx`):** cargan las fuentes a tablas intermedias.
- `StageSales`: junta las ventas históricas (SQL Server) y las actuales (MySQL por ODBC), y luego una tarea SQL calcula el descuento de cada factura según su monto total y la vigencia del descuento.
- `StageCustomerR` y `StageCustomerW`: leen los XML de clientes minoristas y mayoristas.
- `StageEmployee`, `StageInventory`, `StageDiscounts`: cargan empleados, movimientos de stock y descuentos.
- `StageHoliday`: carga los feriados y marca en `DimDate` los días que lo son, interpretando fechas escritas como día y mes abreviado.

**2. Carga del datawarehouse (`1Load_` a `7Load_`):** transforman y cargan dimensiones y hechos.
- `DimProduct`, `DimProduct2`, `DimRegion`, `DimEmployee`, `DimCustomer`: limpieza de registros vacíos, conversión de fechas y tipos de datos.
- `6Load_FactInventory`: resuelve las claves de fecha y producto con transformaciones *Lookup*.
- `7Load_FactSales`: resuelve las cinco claves de dimensión con *Lookup*, convierte tipos de datos y calcula con columnas derivadas los **litros vendidos** (cantidad × litros por unidad) y el **importe de la venta** (cantidad × precio × (1 − descuento)).

## Estructura del repositorio

```
.
├── README.md
├── sql/
│   └── 01_crear_dw_y_tablas.sql   # base DW_TDC, dimensiones, hechos, staging y calendario
└── etl-ssis/                      # proyecto de Visual Studio (SSIS)
    ├── Stage*.dtsx                # paquetes de staging
    ├── 1Load_ ... 7Load_*.dtsx    # paquetes de carga de dimensiones y hechos
    └── ETL_DW_TDC.dtproj
```

## Cómo reproducirlo

1. Ejecutar `sql/01_crear_dw_y_tablas.sql` en SQL Server para crear la base `DW_TDC`.
2. Abrir `etl-ssis/ETL_DW_TDC.slnx` en Visual Studio con las extensiones de SSIS.
3. Ajustar las conexiones (servidor, rutas de los archivos fuente y DSN ODBC de MySQL) a tu entorno. Las rutas del proyecto quedaron genéricas (`localhost`, `C:\TDC\Fuentes`).
4. Ejecutar primero los paquetes `Stage*` (`StageDiscounts` antes que `StageSales`) y después los `1Load_` a `7Load_` en orden numérico.

## Herramientas

`SQL Server` · `T-SQL` · `SSIS` · `Visual Studio` · `MySQL (ODBC)` · `Power BI` · `Modelado dimensional`

## Autor

Fernando Tulian, estudiante de Ingeniería Industrial y de la Tecnicatura en IA (UNR).
