CREATE TABLE [dbo].[date](
	[fecha] [datetime] NULL,
	[año] [int] NULL,
	[mes] [int] NULL,
	[dia_semana] [int] NULL,
	[mes_texto] [nvarchar](30) NULL,
	[is_weekend] [varchar](5) NOT NULL,
	[año_fiscal] [int] NULL,
	[año_fical_texto] [varchar](22) NULL,
	[trimestre_fiscal] [int] NULL,
	[trimestre_fical_texto] [varchar](21) NULL
) 
