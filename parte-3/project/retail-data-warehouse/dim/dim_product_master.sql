CREATE TABLE [dbo].[product_master](
	[id_producto] INT IDENTITY(1,1) NOT NULL,
	[codigo_producto] [varchar](255) NOT NULL,
	[nombre] [varchar](255) NULL,
	[categoria] [varchar](255) NULL,
	[subcategoria] [varchar](255) NULL,
	[subsubcategoria] [varchar](255) NULL,
	[material] [varchar](255) NULL,
	[color] [varchar](255) NULL,
	[origen] [varchar](255) NULL,
	[ean] [bigint] NULL,
	[is_active] [varchar](10) NULL,
	[has_bluetooth] [varchar](10) NULL,
	[talle] [varchar](255) NULL,
	[marca] [varchar](50) NULL,
	PRIMARY KEY CLUSTERED ([id_producto])	
)
