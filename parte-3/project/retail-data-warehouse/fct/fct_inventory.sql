CREATE TABLE [dbo].[inventory](
	[id] INT IDENTITY (1,1) NOT NULL,
	[tienda] INT NOT NULL, 
	[sku] [varchar](10) NULL,
	[fecha] [date] NULL,
	[inicial] [smallint] NULL,
	[final] [smallint] NULL,
	CONSTRAINT id_inventory_tienda FOREIGN KEY ([tienda]) REFERENCES store_master ([codigo_tienda]),
	PRIMARY KEY CLUSTERED ([id])
) 
