
CREATE TABLE [dbo].[order_line_sale](
	[orden] [varchar](10) NULL,
	[producto] [varchar](10) NULL,
	[tienda] [smallint] NULL,
	[fecha] [date] NULL,
	[cantidad] [int] NULL,
	[venta] [decimal](18, 5) NULL,
	[descuento] [decimal](18, 5) NULL,
	[impuestos] [decimal](18, 5) NULL,
	[creditos] [decimal](18, 5) NULL,
	[moneda] [varchar](3) NULL,
	[pos] [smallint] NULL,
	[is_walkout] [varchar](10) NULL
) 
