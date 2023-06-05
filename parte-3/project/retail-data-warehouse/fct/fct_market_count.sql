CREATE TABLE [dbo].[market_count](
	[id_tienda] INT IDENTITY (1,1) NOT NULL,
	[tienda] INT NOT NULL,
	[fecha] [int] NULL,
	[conteo] [smallint] NULL,
	CONSTRAINT FK_marketcount_tienda FOREIGN KEY ([tienda]) REFERENCES store_master ([codigo_tienda]),
	PRIMARY KEY CLUSTERED ([id_tienda])
)
