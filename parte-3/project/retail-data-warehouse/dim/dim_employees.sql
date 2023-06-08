CREATE TABLE [dbo].[employees](
	[id] INT IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) NULL,
	[apellido] [varchar](50) NULL,
	[fecha_entrada] [date] NULL,
	[fecha_salida] [date] NULL,
	[telefono] [varchar](50) NULL,
	[pais] [varchar](20) NULL,
	[provincia] [varchar](50) NULL,
	[codigo_tienda] [varchar](20) NULL,
	[posicion] [varchar](50) NULL,
	PRIMARY KEY CLUSTERED ([id])
)
