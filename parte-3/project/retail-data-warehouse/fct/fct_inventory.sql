CREATE TABLE [dbo].[inventory](
	[id_sku_fecha] INT IDENTITY (1,1) NOT NULL,
	[tienda] INT NOT NULL, 
	[sku] [varchar](10) NULL,
	[fecha] [date] NULL,
	[inicial] [smallint] NULL,
	[final] [smallint] NULL,
	CONSTRAINT FK_inventory_tienda FOREIGN KEY ([tienda]) REFERENCES store_master ([codigo_tienda]),
	PRIMARY KEY CLUSTERED ([id_sku_fecha])
) 
