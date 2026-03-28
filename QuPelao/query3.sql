use SCP_AMINISTIA;select @@version


drop table dbo.mco_cabeceraorden
go
CREATE TABLE [dbo].[mco_cabeceraorden](
	[num_id] [int] PRIMARY KEY NOT NULL,
	[txt_anoproceso] [varchar](4) NULL,
	[cod_mes] [varchar](2) NULL,
	[txt_numeroorden] [varchar](10) NULL,
	[fec_orden] [date] NULL,
	[cod_filial] [varchar](2) NULL,
	[cod_responsable] [varchar](10) NULL,
	[txt_motivo] [varchar](100) NULL,
	[cod_tipomoneda] [char](2) NULL,
	[cod_destino] [varchar](11) NULL,
	[cod_tipoasiento] [varchar](2) NULL,
	[cod_idcuentabanco] [int] NULL,
	[txt_observacion] [varchar](100) NULL,
	[cod_estado] [char](1) NULL,
	[fec_fregistro] [datetime] NULL default(dateadd(hh, -5, getutcdate())),
	[cod_uregistro] [varchar](15) NULL,
	[fec_factualiza] [datetime] NULL default(dateadd(hh, -5, getutcdate())),
	[cod_uactualiza] [varchar](15) NULL
) ON [PRIMARY]

--- FUNCTION 1

if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_general_generaIdentity','fn'))
drop function dbo.udf_general_generaIdentity
go
create function dbo.udf_general_generaIdentity()returns int begin return(select isnull(max(isnull(num_id, 0)), 0) + 1 from dbo.mco_cabeceraorden) end;
go
alter table dbo.mco_cabeceraorden add constraint def_generaIdentity default(dbo.udf_general_generaIdentity()) for num_id;




DROP TABLE dbo.mco_detalleorden
go
CREATE TABLE [dbo].[mco_detalleorden](
	[num_iddetalle] [int] NOT NULL,
	[num_id] [int] NOT NULL,
	[num_nroitem] [int] NULL,
	[txt_concepto] [varchar](150) NULL,
	[cod_comprobantedepago] [varchar](2) NULL,
	[txt_serie] [varchar](4) NULL,
	[txt_nrodocumento] [varchar](20) NULL,
	[fec_documento] [date] NULL,
	[cod_tipogasto] [varchar](2) NULL,
	[flg_impuesto] [char](1) NULL,
    [por_igv] [decimal](10, 2) NULL,
	[num_tipocambio] [decimal](8, 5) NULL,
	[num_costounitario] [decimal](10, 2) NULL,
	[num_cantidad] [int] NULL,
    [num_igv] [decimal](10, 2) NULL,
    [num_otroimpto] [decimal](10, 2) NULL,
	[num_monto] [decimal](10, 2) NULL,
    [num_tasadetraccion] [decimal](10, 2) NULL,
    [num_montodetraccion] [decimal](10, 2) NULL,
    [txt_item] [varchar](MAX) NULL,
	[fec_fregistro] [datetime] NULL default(dateadd(hh, -5, getutcdate())),
	[cod_uregistro] [varchar](15) NULL,
	[fec_factualiza] [datetime] NULL default(dateadd(hh, -5, getutcdate())),
	[cod_uactualiza] [varchar](15) NULL,
    constraint PK_001_detalleorden001 PRIMARY KEY(
        num_iddetalle ASC,
        num_id ASC
    )
) ON [PRIMARY]


--- FUNCTION 2

if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_general_generaDetalleIdentity','fn'))
drop function dbo.udf_general_generaDetalleIdentity
go
create function dbo.udf_general_generaDetalleIdentity()returns int begin return(select isnull(max(isnull(num_iddetalle, 0)), 0) + 1 from dbo.mco_detalleorden) end;
go
alter table dbo.mco_detalleorden add constraint def_generaIdentityDetalle default(dbo.udf_general_generaDetalleIdentity()) for num_iddetalle;


--- FUNCTION 3

if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_general_generaMasivoDetalleIdentity','if'))
drop function dbo.udf_general_generaMasivoDetalleIdentity
go
create function dbo.udf_general_generaMasivoDetalleIdentity(
    @item int
)returns table as return(
    select isnull(max(isnull(num_iddetalle, 0)), 0) + @item num_iddetalle from dbo.mco_detalleorden
)
go

