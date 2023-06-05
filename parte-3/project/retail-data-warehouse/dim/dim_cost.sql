CREATE TABLE [dbo].[cost](
	[id_codigo_producto] int IDENTITY (1,1) NOT NULL,
	[codigo_producto] [varchar](255) FOREIGN KEY REFERENCES product_master ([codigo_producto]),
	[costo_promedio_usd] [float] NULL,
	PRIMARY KEY CLUSTERED ([id_codigo_producto])
)
