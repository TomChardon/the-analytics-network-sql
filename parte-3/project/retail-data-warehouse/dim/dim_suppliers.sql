CREATE TABLE [dbo].[suppliers](
	[id] INT IDENTITY(1,1) NOT NULL,
	[codigo_producto] [varchar](255),
	[nombre] [nvarchar](255) NULL,
	[is_primary] [nvarchar](255) NULL,
	CONSTRAINT id_suppliers_producto FOREIGN KEY ([codigo_producto]) REFERENCES product_master ([codigo_producto]),
	PRIMARY KEY CLUSTERED ([id])
)
