CREATE TABLE [dbo].[store_master](
	[codigo_tienda] INT IDENTITY(1,1) NOT NULL,
	[pais] [varchar](100) NULL,
	[provincia] [varchar](100) NULL,
	[ciudad] [varchar](100) NULL,
	[direccion] [varchar](255) NULL,
	[nombre] [varchar](255) NULL,
	[tipo] [varchar](100) NULL,
	[fecha_apertura] [date] NULL,
	[latitud] [decimal](10, 8) NULL,
	[longitud] [decimal](11, 8) NULL,
	PRIMARY KEY CLUSTERED ([codigo_tienda])
)
