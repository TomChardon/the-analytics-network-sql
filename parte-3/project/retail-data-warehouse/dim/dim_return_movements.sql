CREATE TABLE [dbo].[return_movements](
    [id_orden_item] INT IDENTITY (1,1) NOT NULL,
	[orden_venta] [nvarchar](255) NULL,
	[envio] [nvarchar](255) NULL,
	[item] [varchar](255) NOT NULL,
	[cantidad] [float] NULL,
	[id_movimiento] [float] NULL,
	[desde] [nvarchar](255) NULL,
	[hasta] [nvarchar](255) NULL,
	[recibido_por] [nvarchar](255) NULL,
	[fecha] [nvarchar](255) NULL,
	CONSTRAINT FK_returnmovements_producto FOREIGN KEY ([item]) REFERENCES product_master ([codigo_producto]),
	PRIMARY KEY CLUSTERED ([id_orden_item])
) 
