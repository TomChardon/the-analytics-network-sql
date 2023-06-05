CREATE TABLE [dbo].[monthly_average_fx_rate](
	[id_año_mes] INT IDENTITY (1,1) NOT NULL,
	[mes] [date] NULL,
	[cotizacion_usd_peso] [decimal](18, 0) NULL,
	[cotizacion_usd_eur] [decimal](18, 0) NULL,
	[cotizacion_usd_uru] [decimal](18, 0) NULL,
	PRIMARY KEY CLUSTERED ([id_año_mes])
)
