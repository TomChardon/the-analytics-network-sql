CREATE TABLE [dbo].[market_count](
	[id] INT IDENTITY (1,1) NOT NULL,
	[tienda] INT NOT NULL,
	[fecha] [int] NULL,
	[conteo] [smallint] NULL,
	CONSTRAINT id_marketcount_tienda FOREIGN KEY ([tienda]) REFERENCES store_master ([codigo_tienda]),
	PRIMARY KEY CLUSTERED ([id])
)
