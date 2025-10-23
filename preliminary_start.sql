USE [master];
GO

IF DB_ID(N'TaskHubDb') IS NOT NULL
BEGIN
    ALTER DATABASE [TaskHubDb] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [TaskHubDb];
END;
GO

CREATE DATABASE [TaskHubDb]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TaskHubDb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\TaskHubDb.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'TaskHubDb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\TaskHubDb_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF;
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
    EXEC [TaskHubDb].[dbo].[sp_fulltext_database] @action = 'enable';
GO

ALTER DATABASE [TaskHubDb] SET ANSI_NULL_DEFAULT OFF;
ALTER DATABASE [TaskHubDb] SET ANSI_NULLS OFF;
ALTER DATABASE [TaskHubDb] SET ANSI_PADDING OFF;
ALTER DATABASE [TaskHubDb] SET ANSI_WARNINGS OFF;
ALTER DATABASE [TaskHubDb] SET ARITHABORT OFF;
ALTER DATABASE [TaskHubDb] SET AUTO_CLOSE ON;
ALTER DATABASE [TaskHubDb] SET AUTO_SHRINK OFF;
ALTER DATABASE [TaskHubDb] SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE [TaskHubDb] SET CURSOR_CLOSE_ON_COMMIT OFF;
ALTER DATABASE [TaskHubDb] SET CURSOR_DEFAULT GLOBAL;
ALTER DATABASE [TaskHubDb] SET CONCAT_NULL_YIELDS_NULL OFF;
ALTER DATABASE [TaskHubDb] SET NUMERIC_ROUNDABORT OFF;
ALTER DATABASE [TaskHubDb] SET QUOTED_IDENTIFIER OFF;
ALTER DATABASE [TaskHubDb] SET RECURSIVE_TRIGGERS OFF;
ALTER DATABASE [TaskHubDb] SET ENABLE_BROKER;
ALTER DATABASE [TaskHubDb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF;
ALTER DATABASE [TaskHubDb] SET DATE_CORRELATION_OPTIMIZATION OFF;
ALTER DATABASE [TaskHubDb] SET TRUSTWORTHY OFF;
ALTER DATABASE [TaskHubDb] SET ALLOW_SNAPSHOT_ISOLATION OFF;
ALTER DATABASE [TaskHubDb] SET PARAMETERIZATION SIMPLE;
ALTER DATABASE [TaskHubDb] SET READ_COMMITTED_SNAPSHOT OFF;
ALTER DATABASE [TaskHubDb] SET HONOR_BROKER_PRIORITY OFF;
ALTER DATABASE [TaskHubDb] SET RECOVERY SIMPLE;
ALTER DATABASE [TaskHubDb] SET MULTI_USER;
ALTER DATABASE [TaskHubDb] SET PAGE_VERIFY CHECKSUM;
ALTER DATABASE [TaskHubDb] SET DB_CHAINING OFF;
ALTER DATABASE [TaskHubDb] SET FILESTREAM ( NON_TRANSACTED_ACCESS = OFF );
ALTER DATABASE [TaskHubDb] SET TARGET_RECOVERY_TIME = 60 SECONDS;
ALTER DATABASE [TaskHubDb] SET DELAYED_DURABILITY = DISABLED;
ALTER DATABASE [TaskHubDb] SET ACCELERATED_DATABASE_RECOVERY = OFF;
ALTER DATABASE [TaskHubDb] SET QUERY_STORE = ON;
ALTER DATABASE [TaskHubDb] SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO,
    MAX_PLANS_PER_QUERY = 200,
    WAIT_STATS_CAPTURE_MODE = ON
);
ALTER DATABASE [TaskHubDb] SET READ_WRITE;
GO

USE [TaskHubDb];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
CREATE TABLE [dbo].[Users](
    [ID]        INT IDENTITY(1,1) NOT NULL,
    [Username]  TEXT NOT NULL,
    [Password]  TEXT NOT NULL,
    [Email]     TEXT NOT NULL,
    [AccountCreated] DATETIME2(7) NOT NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([ID] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A table that stores the user credentials.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Users';
GO

CREATE TABLE [dbo].[Groups](
    [ID]          INT IDENTITY(1,1) NOT NULL,
    [OwnerID]     INT NULL,
    [Name]        TEXT NOT NULL,
    [Description] TEXT NOT NULL,
    CONSTRAINT [PK_Groups] PRIMARY KEY CLUSTERED ([ID] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores active groups.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Groups';
GO

CREATE TABLE [dbo].[Workspaces](
    [ID]          INT IDENTITY(1,1) NOT NULL,
    [OwnerID]     INT NOT NULL,
    [GroupID]     INT NULL,
    [Name]        TEXT NOT NULL,
    [Description] TEXT NOT NULL,
    CONSTRAINT [PK_Workspaces] PRIMARY KEY CLUSTERED ([ID] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores the workspaces.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Workspaces';
GO

CREATE TABLE [dbo].[Tasks](
    [TaskID]        INT IDENTITY(1,1) NOT NULL,
    [GroupID]       INT NULL,
    [WorkspaceID]   INT NOT NULL,
    [Assignee]      TEXT NULL,
    [TaskStatus]    INT NOT NULL,
    [TaskContents]  TEXT NOT NULL,
    [TaskName]      TEXT NOT NULL,
    CONSTRAINT [PK_Tasks] PRIMARY KEY CLUSTERED ([TaskID] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores all tasks.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tasks';
GO

CREATE TABLE [dbo].[GroupWorkspaces](
    [GroupID]     INT NOT NULL,
    [WorkspaceID] INT NOT NULL
) ON [PRIMARY];
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Returns relationships between groups and workspaces.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GroupWorkspaces';
GO

CREATE TABLE [dbo].[UserWorkspaces](
    [UserID]      INT NOT NULL,
    [WorkspaceID] INT NOT NULL
) ON [PRIMARY];
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Returns relationships between users and workspaces.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserWorkspaces';
GO

CREATE TABLE [dbo].[Messages](
    [ID]             INT IDENTITY(1,1) NOT NULL,
    [Message]        TEXT NOT NULL,
    [AuthorUserId]   INT NOT NULL,
    [AuthorUsername] TEXT NOT NULL,
    [CreatedAt]      DATETIME2(7) NOT NULL,
    [Type]           INT NOT NULL,
    [OwnerId]        INT NOT NULL,
    CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED ([ID] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores task comments and workspace chat messages.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Messages';
GO

CREATE TABLE [dbo].[ChildTasks](
    [ID]            INT IDENTITY(1,1) NOT NULL,
    [Name]          TEXT NOT NULL,
    [Contents]      TEXT NOT NULL,
    [TaskStatus]    INT NOT NULL,
    [ParentTaskID]  INT NOT NULL,
    CONSTRAINT [PK_ChildTasks] PRIMARY KEY CLUSTERED ([ID] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores child tasks that belong to parent tasks.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ChildTasks';
GO

-------- setup foreign keys ------
ALTER TABLE [dbo].[Groups] WITH CHECK
    ADD CONSTRAINT [OwnerID_FK] FOREIGN KEY ([OwnerID]) REFERENCES [dbo].[Users]([ID]);
ALTER TABLE [dbo].[Groups] CHECK CONSTRAINT [OwnerID_FK];
GO

ALTER TABLE [dbo].[Workspaces] WITH CHECK
    ADD CONSTRAINT [Workspace_to_GroupID] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[Groups]([ID]);
ALTER TABLE [dbo].[Workspaces] CHECK CONSTRAINT [Workspace_to_GroupID];
GO

ALTER TABLE [dbo].[Workspaces] WITH CHECK
    ADD CONSTRAINT [Workspace_to_OwnerID] FOREIGN KEY ([OwnerID]) REFERENCES [dbo].[Users]([ID]);
ALTER TABLE [dbo].[Workspaces] CHECK CONSTRAINT [Workspace_to_OwnerID];
GO

ALTER TABLE [dbo].[Tasks] WITH CHECK
    ADD CONSTRAINT [Task_to_GroupID] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[Groups]([ID]);
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [Task_to_GroupID];
GO

ALTER TABLE [dbo].[Tasks] WITH CHECK
    ADD CONSTRAINT [Task_to_WorkspaceID] FOREIGN KEY ([WorkspaceID]) REFERENCES [dbo].[Workspaces]([ID]);
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [Task_to_WorkspaceID];
GO

ALTER TABLE [dbo].[GroupWorkspaces] WITH CHECK
    ADD CONSTRAINT [GroupWorkspaces_GroupID] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[Groups]([ID]);
ALTER TABLE [dbo].[GroupWorkspaces] CHECK CONSTRAINT [GroupWorkspaces_GroupID];
GO

ALTER TABLE [dbo].[GroupWorkspaces] WITH CHECK
    ADD CONSTRAINT [GroupWorkspaces_WorkspaceID] FOREIGN KEY ([WorkspaceID]) REFERENCES [dbo].[Workspaces]([ID]);
ALTER TABLE [dbo].[GroupWorkspaces] CHECK CONSTRAINT [GroupWorkspaces_WorkspaceID];
GO

ALTER TABLE [dbo].[UserWorkspaces] WITH CHECK
    ADD CONSTRAINT [UserWorkspaces_UserID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users]([ID]);
ALTER TABLE [dbo].[UserWorkspaces] CHECK CONSTRAINT [UserWorkspaces_UserID];
GO

ALTER TABLE [dbo].[UserWorkspaces] WITH CHECK
    ADD CONSTRAINT [UserWorkspaces_WorkspaceID] FOREIGN KEY ([WorkspaceID]) REFERENCES [dbo].[Workspaces]([ID]);
ALTER TABLE [dbo].[UserWorkspaces] CHECK CONSTRAINT [UserWorkspaces_WorkspaceID];
GO

ALTER TABLE [dbo].[Messages] WITH CHECK
    ADD CONSTRAINT [Messages_AuthorUserID] FOREIGN KEY ([AuthorUserId]) REFERENCES [dbo].[Users]([ID]);
ALTER TABLE [dbo].[Messages] CHECK CONSTRAINT [Messages_AuthorUserID];
GO

ALTER TABLE [dbo].[ChildTasks] WITH CHECK
    ADD CONSTRAINT [ChildTasks_ParentTaskID] FOREIGN KEY ([ParentTaskID]) REFERENCES [dbo].[Tasks]([TaskID]);
ALTER TABLE [dbo].[ChildTasks] CHECK CONSTRAINT [ChildTasks_ParentTaskID];
GO

---- setup stored procedures -----

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[GetMessagesByOwnerAndType]
        @OwnerId INT,
        @Type INT
AS
BEGIN
        SET NOCOUNT ON;

        SELECT [ID],
                     [Message],
                     [AuthorUserId],
                     [AuthorUsername],
                     [CreatedAt],
                     [Type],
                     [OwnerId]
        FROM [dbo].[Messages]
        WHERE [OwnerId] = @OwnerId
            AND [Type] = @Type
        ORDER BY [CreatedAt] DESC, [ID] DESC;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[GetChildTasksByTaskId]
    @TaskId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [ID],
           [ParentTaskID],
           [Name],
           [Contents],
           [TaskStatus]
    FROM [dbo].[ChildTasks]
    WHERE [ParentTaskID] = @TaskId
    ORDER BY [ID] DESC;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[RegisterUser]
    @Username NVARCHAR(256),
    @Password NVARCHAR(512),
    @Email NVARCHAR(512),
    @AccountCreated DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [Username] = @Username)
    BEGIN
        SELECT CAST(-1 AS INT) AS [Result], NULL AS [UserID];
        RETURN;
    END;

    IF @AccountCreated IS NULL
        SET @AccountCreated = SYSUTCDATETIME();

    INSERT INTO [dbo].[Users] ([Username], [Password], [Email], [AccountCreated])
    VALUES (@Username, @Password, @Email, @AccountCreated);

    SELECT CAST(1 AS INT) AS [Result], SCOPE_IDENTITY() AS [UserID];
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[AuthenticateUser]
    @Username NVARCHAR(256),
    @Password NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           [ID],
           [Username],
           [Email],
           [AccountCreated]
    FROM [dbo].[Users]
    WHERE [Username] = @Username
      AND [Password] = @Password;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[GetWorkspaceTasks]
    @WorkspaceID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [TaskID]
    FROM [dbo].[Tasks]
    WHERE [WorkspaceID] = @WorkspaceID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[GetGroupWorkspaces]
    @GroupID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [ID]
    FROM [dbo].[Workspaces]
    WHERE [GroupID] = @GroupID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[GetUserGroups]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [ID]
    FROM [dbo].[Groups]
    WHERE [OwnerID] = @UserID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[GetUserWorkspaces]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [ID]
    FROM [dbo].[Workspaces]
    WHERE [OwnerID] = @UserID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[GetUserTasks]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.[TaskID]
    FROM [dbo].[Tasks] AS t
    INNER JOIN [dbo].[Workspaces] AS w ON t.[WorkspaceID] = w.[ID]
    WHERE w.[OwnerID] = @UserID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[GetUserWorkspaceMemberships]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [WorkspaceID]
    FROM [dbo].[UserWorkspaces]
    WHERE [UserID] = @UserID;
END;
GO
