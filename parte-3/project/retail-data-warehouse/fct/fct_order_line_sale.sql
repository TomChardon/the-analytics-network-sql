CREATE TABLE [dbo].[order_line_sale](
	[id_orden_producto] INT IDENTITY (1,1),
	[orden] [varchar](10) NULL,
	[producto] [varchar](10) NULL,
	[tienda] INT NOT NULL,    
	[fecha] [date] NULL,
	[cantidad] [int] NULL,
	[venta] [decimal](18, 5) NULL,
	[descuento] [decimal](18, 5) NULL,
	[impuestos] [decimal](18, 5) NULL,
	[creditos] [decimal](18, 5) NULL,
	[moneda] [varchar](3) NULL,
	[pos] [smallint] NULL,
	[is_walkout] [varchar](10) NULL,
	CONSTRAINT FK_orderlinesale_tienda FOREIGN KEY ([tienda]) REFERENCES store_master ([codigo_tienda]),
	PRIMARY KEY CLUSTERED ([id_orden_producto])	
)
