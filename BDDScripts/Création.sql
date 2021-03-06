
/****** Object:  Table [dbo].[Alerte]    Script Date: 30/06/2016 14:35:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypeAlerte](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NomType] [nvarchar](50) NOT NULL,
	CONSTRAINT [PK_TypeAlerte] PRIMARY KEY CLUSTERED ([ID])
) 

CREATE TABLE [dbo].[Etat](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [nvarchar](50) NOT NULL,
	[Icone] [nvarchar](50) NULL,
	[ClasseCSS] [nvarchar](255) NULL,
	CONSTRAINT [PK_Etat] PRIMARY KEY CLUSTERED ([ID])
) 

CREATE TABLE [dbo].[Transition](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [nvarchar](50) NOT NULL,
	[Icone] [nvarchar](50) NULL,
	[Comportement] [tinyint] NULL,
	[Fk_Etat_Arrive] [int] NOT NULL,
	CONSTRAINT [PK_Transition] PRIMARY KEY CLUSTERED ([ID])
) 

ALTER TABLE [dbo].[Transition]  ADD  CONSTRAINT [Fk_Transition_Etat] FOREIGN KEY([Fk_Etat_Arrive])
REFERENCES [dbo].[Etat] ([ID])




CREATE TABLE [dbo].[Alerte](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Fk_TypeAlerte] [int] NOT NULL,
	[Nom] [nvarchar](50) NOT NULL,
	[Comportement] [tinyint] NULL,
	[fk_Application] INT  NULL,
	[ObjetConcerne] [varchar](255) NULL,
	[Icone] [nvarchar](50) NULL,
	[Niveau] [int] NULL,
	[Requete] [nvarchar](max) NULL,
	[URL] [nvarchar](max) NOT NULL,
	[RequeteCorrection] [nvarchar](max) NULL,
	[Texte] [nvarchar](max) NULL,
	CONSTRAINT [PK_Alerte] PRIMARY KEY CLUSTERED ([ID] ASC)
) 
GO

ALTER TABLE [dbo].[Alerte]  ADD  CONSTRAINT [FK_Alerte_TypeAlerte] FOREIGN KEY([Fk_TypeAlerte]) REFERENCES [dbo].[TypeAlerte] ([ID])


CREATE TABLE [dbo].[Ocurrence_Alerte](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Fk_Alerte] [int] NOT NULL,
	TextMessage varchar(max) NULL,
	[DateOccurence] [datetime] NULL,
	CONSTRAINT [PK_Occurence_Alerte] PRIMARY KEY CLUSTERED ([ID])
) 

ALTER TABLE [dbo].[Ocurrence_Alerte]   ADD  CONSTRAINT [Fk_Alerte_Ocurrence] FOREIGN KEY([Fk_Alerte]) REFERENCES [dbo].[Alerte] ([ID])

CREATE TABLE [dbo].[Ocurrence_Alerte_IDs](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Fk_Ocurrence_Alerte] [int] NOT NULL,
	[ValeurID] varchar(255) NOT NULL,
	ValeurMessage VARCHAR(MAX) NULL,
	CONSTRAINT [PK_Ocurrence_Alerte_IDs] PRIMARY KEY CLUSTERED ([ID])
) 

ALTER TABLE [dbo].[Ocurrence_Alerte_IDs]   ADD  CONSTRAINT [Fk_Ocurrence_Alerte_IDs_Ocurrence_Alerte] FOREIGN KEY([Fk_Ocurrence_Alerte]) REFERENCES [Ocurrence_Alerte] ([ID])



/****** Object:  Table [dbo].[Alerte_Etat_Historique]    Script Date: 30/06/2016 14:35:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Alerte_Etat_Historique](
	[Fk_Ocurrence_Alerte] [int] NOT NULL,
	[DateEtat] [datetime] NOT NULL,
	[Fk_Etat] [int] NOT NULL,
	[Fk_Transition] [int] NOT NULL,
	[Utilisateurs] [nvarchar](50) NULL,
	CONSTRAINT [PK_Alerte_Etat_Historique] PRIMARY KEY CLUSTERED ([Fk_Ocurrence_Alerte] ,[DateEtat]	)
)
ALTER TABLE [dbo].[Alerte_Etat_Historique]   ADD  CONSTRAINT [Fk_Etat_Historique] FOREIGN KEY([Fk_Etat])
REFERENCES [dbo].[Etat] ([ID])

ALTER TABLE [dbo].[Alerte_Etat_Historique] ADD  CONSTRAINT [Fk_Ocurrence_Alerte] FOREIGN KEY([Fk_Ocurrence_Alerte])
REFERENCES [dbo].[Ocurrence_Alerte] ([ID])


ALTER TABLE [dbo].[Alerte_Etat_Historique]  WITH CHECK ADD  CONSTRAINT [Fk_Transition_Historique] FOREIGN KEY([Fk_Transition])
REFERENCES [dbo].[Transition] ([ID])

GO
CREATE TABLE [dbo].[Etat_Depart_Transition](
	[Fk_Etat] [int] NOT NULL,
	[Fk_Transition] [int] NOT NULL,
	[Fk_TypeAlerte] [int] NULL
) 

GO

ALTER TABLE [dbo].[Etat_Depart_Transition]   ADD  CONSTRAINT [Fk_Etat_Depart] FOREIGN KEY([Fk_Etat]) REFERENCES [dbo].[Etat] ([ID])
GO
ALTER TABLE [dbo].[Etat_Depart_Transition]   ADD  CONSTRAINT [Fk_Etat_Transition] FOREIGN KEY([Fk_Transition]) REFERENCES [dbo].[Transition] ([ID])
GO
ALTER TABLE [dbo].[Etat_Depart_Transition]  ADD  CONSTRAINT [Fk_Etat_TypeAlerte] FOREIGN KEY([Fk_TypeAlerte]) REFERENCES [dbo].[TypeAlerte] ([ID])

CREATE VIEW ListApplication AS
SELECT [TApp_PK_ID] ID ,[TApp_Name] AppName, 'reneco ' + CASE WHEN TApp_Name in ('TRACK','TRACK Dev') THEN 'reneco-trackbird' WHEN TApp_Name in ('ecoRelevé') THEN 'reneco-releve' ELSE 'reneco-trackbird' END AppIcone
FROM SECURITE.DBO.TApplications A


create View [dbo].[Alerte_Etat]
as
select * from Alerte_Etat_Historique H
WHERE not exists (select * from Alerte_Etat_Historique H2 where h2.Fk_Ocurrence_Alerte=h.Fk_Ocurrence_Alerte and h2.[Dateetat] > H.dateetat)


create view [dbo].[liste_transitions] as
select Tr.ID, Tr.Nom, edt.Fk_Etat,Tr.Icone IconeEtat,edt.Fk_TypeAlerte
From Transition Tr 
JOIN Etat_Depart_Transition edt ON edt.Fk_Transition = Tr.ID 