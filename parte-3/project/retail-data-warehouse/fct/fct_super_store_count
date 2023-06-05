CREATE TABLE [dbo].[super_store_count](
	[id_tienda] INT IDENTITY (1,1) NOT NULL,
	[tienda] INT NOT NULL,
	[fecha] [int] NULL,
	[conteo] [smallint] NULL,
	CONSTRAINT FK_superstorecount_tienda FOREIGN KEY ([tienda]) REFERENCES store_master ([codigo_tienda]),
	PRIMARY KEY CLUSTERED ([id_tienda])
)
