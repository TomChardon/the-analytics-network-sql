CREATE TABLE [dbo].[market_count](
	[id_tienda] INT IDENTITY (1,1) NOT NULL,
	[tienda] INT FOREIGN KEY REFERENCES store_master ([codigo_tienda]),
	[fecha] [int] NULL,
	[conteo] [smallint] NULL,
	PRIMARY KEY CLUSTERED ([id_tienda])
)
