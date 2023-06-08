CREATE TABLE [dbo].[cost](
	[id] int IDENTITY (1,1) NOT NULL,
	[codigo_producto] [varchar](255) NOT NULL,
	[costo_promedio_usd] [float] NULL,
	CONSTRAINT id_cost_producto FOREIGN KEY ([codigo_producto]) REFERENCES product_master ([codigo_producto]),
	PRIMARY KEY CLUSTERED ([id])
)
