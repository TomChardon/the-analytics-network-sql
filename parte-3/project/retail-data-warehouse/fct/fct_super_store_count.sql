CREATE TABLE [dbo].[super_store_count](
	[id] INT IDENTITY (1,1) NOT NULL,
	[tienda] INT NOT NULL,
	[fecha] [date] NULL,
	[conteo] [smallint] NULL,
	CONSTRAINT id_superstorecount_tienda FOREIGN KEY ([tienda]) REFERENCES store_master ([codigo_tienda]),
	PRIMARY KEY CLUSTERED ([id])
)
