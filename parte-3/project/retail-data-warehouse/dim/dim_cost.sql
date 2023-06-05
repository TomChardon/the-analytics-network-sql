CREATE TABLE [dbo].[cost](
	[id_codigo_producto] int IDENTITY (1,1) NOT NULL,
	[codigo_producto] [varchar](255) NOT NULL,
	[costo_promedio_usd] [float] NULL,
	CONSTRAINT FK_cost_producto FOREIGN KEY ([codigo_producto]) REFERENCES store_master ([codigo_producto]),
	PRIMARY KEY CLUSTERED ([id_codigo_producto])
)
