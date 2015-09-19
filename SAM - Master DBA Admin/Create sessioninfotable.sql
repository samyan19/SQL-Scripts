USE [DBA_Admin]
GO

/****** Object:  Table [dbo].[sessioninfotable_int]    Script Date: 05/28/2013 13:39:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[sessioninfotable_int](
	[session_id] [smallint] NOT NULL,
	[complete text] [nvarchar](max) NULL,
	[Running statement] [nvarchar](max) NULL,
	[plan_handle] [varbinary](64) NULL,
	[database_id] [smallint] NOT NULL,
	[blocking_session_id] [smallint] NULL,
	[wait_type] [nvarchar](60) NULL,
	[host_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[host_process_id] [int] NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[ElapseTime mins] [int] NULL,
	[command] [nvarchar](16) NOT NULL,
	[query_plan] [xml] NULL,
	[cdt] [datetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


