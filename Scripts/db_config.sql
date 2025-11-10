-- =========================================
-- TaskHubDb: Create DB, Tables, Relationships, Seed Data
-- Shouldn't overwrite existing data
-- =========================================

-- -----------------------------
--  Create Database if not exists
-- -----------------------------
IF DB_ID(N'TaskHubDb') IS NULL
BEGIN
    CREATE DATABASE [TaskHubDb];
END

USE [TaskHubDb];

ALTER DATABASE [TaskHubDb] SET RECOVERY SIMPLE;
ALTER DATABASE [TaskHubDb] SET MULTI_USER;

-- -----------------------------
-- Create Tables if not exists
-- -----------------------------
IF OBJECT_ID('dbo.Users', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Users](
        [ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Username] NVARCHAR(MAX) NOT NULL,
        [Password] NVARCHAR(MAX) NOT NULL,
        [Email] NVARCHAR(MAX) NOT NULL,
        [AccountCreated] DATETIME2(7) NOT NULL
    );
END

IF OBJECT_ID('dbo.Groups', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Groups](
        [ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [OwnerID] INT NULL,
        [Name] NVARCHAR(MAX) NOT NULL,
        [Description] NVARCHAR(MAX) NOT NULL
    );
END

IF OBJECT_ID('dbo.Workspaces', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Workspaces](
        [ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [OwnerID] INT NOT NULL,
        [GroupID] INT NULL,
        [Name] NVARCHAR(MAX) NOT NULL,
        [Description] NVARCHAR(MAX) NOT NULL
    );
END

IF OBJECT_ID('dbo.Tasks', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Tasks](
        [TaskID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [GroupID] INT NULL,
        [WorkspaceID] INT NOT NULL,
        [Assignee] NVARCHAR(MAX) NULL,
        [TaskStatus] INT NOT NULL,
        [TaskContents] NVARCHAR(MAX) NOT NULL,
        [TaskName] NVARCHAR(MAX) NOT NULL
    );
END

IF OBJECT_ID('dbo.ChildTasks', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ChildTasks](
        [ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Name] NVARCHAR(MAX) NOT NULL,
        [Contents] NVARCHAR(MAX) NOT NULL,
        [TaskStatus] INT NOT NULL,
        [ParentTaskID] INT NOT NULL
    );
END

IF OBJECT_ID('dbo.Messages', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Messages](
        [ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Message] NVARCHAR(MAX) NOT NULL,
        [AuthorUserId] INT NOT NULL,
        [AuthorUsername] NVARCHAR(MAX) NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL,
        [Type] INT NOT NULL,
        [OwnerId] INT NOT NULL
    );
END

IF OBJECT_ID('dbo.GroupWorkspaces', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[GroupWorkspaces](
        [GroupID] INT NOT NULL,
        [WorkspaceID] INT NOT NULL
    );
END

IF OBJECT_ID('dbo.UserWorkspaces', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UserWorkspaces](
        [UserID] INT NOT NULL,
        [WorkspaceID] INT NOT NULL
    );
END


-- -----------------------------
--  Stored Procedures
-- -----------------------------

-- GetMessagesByOwnerAndType
IF OBJECT_ID('dbo.GetMessagesByOwnerAndType', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetMessagesByOwnerAndType]
        @OwnerId INT,
        @Type INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT [ID],[Message],[AuthorUserId],[AuthorUsername],[CreatedAt],[Type],[OwnerId]
        FROM [dbo].[Messages]
        WHERE [OwnerId] = @OwnerId AND [Type] = @Type
        ORDER BY [CreatedAt] DESC, [ID] DESC;
    END')
END;

-- GetChildTasksByTaskId
IF OBJECT_ID('dbo.GetChildTasksByTaskId', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetChildTasksByTaskId]
        @TaskId INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT [ID],[ParentTaskID],[Name],[Contents],[TaskStatus]
        FROM [dbo].[ChildTasks]
        WHERE [ParentTaskID] = @TaskId
        ORDER BY [ID] DESC;
    END')
END;

-- RegisterUser
IF OBJECT_ID('dbo.RegisterUser', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[RegisterUser]
        @Username NVARCHAR(MAX),
        @Password NVARCHAR(MAX),
        @Email NVARCHAR(MAX),
        @AccountCreated DATETIME2(7) = NULL
    AS
    BEGIN
        SET NOCOUNT ON;
        IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [Username] = @Username)
        BEGIN
            SELECT CAST(-1 AS INT) AS [Result], NULL AS [UserID];
            RETURN;
        END
        IF @AccountCreated IS NULL
            SET @AccountCreated = SYSUTCDATETIME();
        INSERT INTO [dbo].[Users] ([Username],[Password],[Email],[AccountCreated])
        VALUES (@Username,@Password,@Email,@AccountCreated);
        SELECT CAST(1 AS INT) AS [Result], SCOPE_IDENTITY() AS [UserID];
    END')
END;

-- AuthenticateUser
IF OBJECT_ID('dbo.AuthenticateUser', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[AuthenticateUser]
        @Username NVARCHAR(MAX),
        @Password NVARCHAR(MAX)
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT TOP (1) [ID],[Username],[Email],[AccountCreated]
        FROM [dbo].[Users]
        WHERE [Username] = @Username AND [Password] = @Password;
    END')
END;

-- GetWorkspaceTasks
IF OBJECT_ID('dbo.GetWorkspaceTasks', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetWorkspaceTasks]
        @WorkspaceID INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT [TaskID]
        FROM [dbo].[Tasks]
        WHERE [WorkspaceID] = @WorkspaceID;
    END')
END;

-- GetGroupWorkspaces
IF OBJECT_ID('dbo.GetGroupWorkspaces', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetGroupWorkspaces]
        @GroupID INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT [ID]
        FROM [dbo].[Workspaces]
        WHERE [GroupID] = @GroupID;
    END')
END;

-- GetUserGroups
IF OBJECT_ID('dbo.GetUserGroups', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetUserGroups]
        @UserID INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT [ID]
        FROM [dbo].[Groups]
        WHERE [OwnerID] = @UserID;
    END')
END;

-- GetUserWorkspaces
IF OBJECT_ID('dbo.GetUserWorkspaces', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetUserWorkspaces]
        @UserID INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT [ID]
        FROM [dbo].[Workspaces]
        WHERE [OwnerID] = @UserID;
    END')
END;

-- GetUserTasks
IF OBJECT_ID('dbo.GetUserTasks', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetUserTasks]
        @UserID INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT t.[TaskID]
        FROM [dbo].[Tasks] AS t
        INNER JOIN [dbo].[Workspaces] AS w ON t.[WorkspaceID] = w.[ID]
        WHERE w.[OwnerID] = @UserID;
    END')
END;

-- GetUserWorkspaceMemberships
IF OBJECT_ID('dbo.GetUserWorkspaceMemberships', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[GetUserWorkspaceMemberships]
        @UserID INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT [WorkspaceID]
        FROM [dbo].[UserWorkspaces]
        WHERE [UserID] = @UserID;
    END')
END;



-- -----------------------------
-- Foreign Key Constraints
-- -----------------------------
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Groups_OwnerID')
BEGIN
    ALTER TABLE [dbo].[Groups] ADD CONSTRAINT FK_Groups_OwnerID FOREIGN KEY (OwnerID) REFERENCES [dbo].[Users](ID);
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Workspaces_GroupID')
BEGIN
    ALTER TABLE [dbo].[Workspaces] ADD CONSTRAINT FK_Workspaces_GroupID FOREIGN KEY (GroupID) REFERENCES [dbo].[Groups](ID);
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Workspaces_OwnerID')
BEGIN
    ALTER TABLE [dbo].[Workspaces] ADD CONSTRAINT FK_Workspaces_OwnerID FOREIGN KEY (OwnerID) REFERENCES [dbo].[Users](ID);
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Tasks_GroupID')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD CONSTRAINT FK_Tasks_GroupID FOREIGN KEY (GroupID) REFERENCES [dbo].[Groups](ID);
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Tasks_WorkspaceID')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD CONSTRAINT FK_Tasks_WorkspaceID FOREIGN KEY (WorkspaceID) REFERENCES [dbo].[Workspaces](ID);
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ChildTasks_ParentTaskID')
BEGIN
    ALTER TABLE [dbo].[ChildTasks] ADD CONSTRAINT FK_ChildTasks_ParentTaskID FOREIGN KEY (ParentTaskID) REFERENCES [dbo].[Tasks](TaskID);
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Messages_AuthorUserID')
BEGIN
    ALTER TABLE [dbo].[Messages] ADD CONSTRAINT FK_Messages_AuthorUserID FOREIGN KEY (AuthorUserId) REFERENCES [dbo].[Users](ID);
END

-- -----------------------------
-- Seed Data (INSERT if not exists)
-- -----------------------------


-- Users
INSERT INTO Users (Username, Password, Email, AccountCreated)
SELECT * FROM (VALUES
('alice','Pass123!','alice@company.com',SYSUTCDATETIME()),
('bob','Pass123!','bob@company.com',SYSUTCDATETIME()),
('charlie','Pass123!','charlie@company.com',SYSUTCDATETIME()),
('diana','Pass123!','diana@company.com',SYSUTCDATETIME()),
('edward','Pass123!','edward@company.com',SYSUTCDATETIME()),
('frank','Pass123!','frank@company.com',SYSUTCDATETIME()),
('grace','Pass123!','grace@company.com',SYSUTCDATETIME()),
('helen','Pass123!','helen@company.com',SYSUTCDATETIME()),
('ian','Pass123!','ian@company.com',SYSUTCDATETIME()),
('julia','Pass123!','julia@company.com',SYSUTCDATETIME())
) AS temp(Username,Password,Email,AccountCreated)
WHERE NOT EXISTS(SELECT 1 FROM Users u WHERE u.Username = temp.Username);

-- -----------------------------
-- Groups
-- -----------------------------
INSERT INTO Groups (OwnerID, Name, Description)
SELECT * FROM (VALUES
(1, 'Network Team', 'Handles all network infrastructure'),
(2, 'Software Devs', 'Develops internal and external apps'),
(3, 'IT Support', 'Handles tickets and user issues'),
(4, 'Security Team', 'Handles cybersecurity and audits'),
(5, 'Database Admins', 'Manages database servers'),
(6, 'QA Team', 'Quality assurance for applications'),
(7, 'SysAdmins', 'Manages servers and cloud infrastructure'),
(8, 'DevOps', 'Builds CI/CD pipelines'),
(9, 'Helpdesk', 'First-line support for employees'),
(10, 'Project Management', 'Manages projects and resources')
) AS temp(OwnerID, Name, Description)
WHERE NOT EXISTS(SELECT 1 FROM Groups g WHERE g.Name = temp.Name);

-- -----------------------------
-- Workspaces
-- -----------------------------
INSERT INTO Workspaces (OwnerID, GroupID, Name, Description)
SELECT * FROM (VALUES
(1, 1, 'Server Upgrade', 'Upgrade servers to latest OS'),
(2, 2, 'App Deployment', 'Deploy new version of internal app'),
(3, 3, 'Support Tickets', 'Manage support tickets and requests'),
(4, 4, 'Security Audit', 'Conduct quarterly security audits'),
(5, 5, 'Database Migration', 'Migrate old DB to new server'),
(6, 6, 'Testing Environment', 'QA team test deployments'),
(7, 7, 'Cloud Setup', 'Setup cloud infrastructure for project'),
(8, 8, 'CI/CD Pipeline', 'Automate builds and deployments'),
(9, 9, 'Helpdesk Requests', 'Track all incoming user requests'),
(10, 10, 'Project Planning', 'Organize project tasks and deadlines')
) AS temp(OwnerID, GroupID, Name, Description)
WHERE NOT EXISTS(SELECT 1 FROM Workspaces w WHERE w.Name = temp.Name);

-- -----------------------------
-- Tasks
-- -----------------------------
INSERT INTO Tasks (GroupID, WorkspaceID, Assignee, TaskStatus, TaskContents, TaskName)
SELECT * FROM (VALUES
(1, 1, 'alice', 0, 'Upgrade all production servers to Windows Server 2022', 'Server Upgrade Task 1'),
(1, 1, 'bob', 1, 'Patch network switches with latest firmware', 'Switch Firmware Update'),
(2, 2, 'charlie', 0, 'Deploy v1.2 to production environment', 'App Deployment Task 1'),
(2, 2, 'diana', 1, 'Fix login bug on mobile app', 'Bug Fix Task'),
(3, 3, 'edward', 0, 'Resolve ticket #101', 'Support Ticket 101'),
(3, 3, 'frank', 1, 'Respond to ticket #102', 'Support Ticket 102'),
(4, 4, 'grace', 0, 'Check firewall configurations', 'Security Firewall Audit'),
(4, 4, 'helen', 1, 'Update antivirus definitions', 'Antivirus Update'),
(5, 5, 'ian', 0, 'Migrate customer DB to new SQL Server', 'DB Migration Task'),
(5, 5, 'julia', 1, 'Backup existing database before migration', 'DB Backup Task')
) AS temp(GroupID, WorkspaceID, Assignee, TaskStatus, TaskContents, TaskName)
WHERE NOT EXISTS(SELECT 1 FROM Tasks t WHERE t.TaskName = temp.TaskName);

-- -----------------------------
-- ChildTasks
-- -----------------------------
INSERT INTO ChildTasks (Name, Contents, TaskStatus, ParentTaskID)
SELECT * FROM (VALUES
('Reboot Server', 'Reboot all servers after upgrade', 0, 1),
('Check Network', 'Ensure all switches are operational', 1, 2),
('Deploy Mobile Build', 'Deploy mobile app version', 0, 3),
('Test Login', 'Verify login bug fix on staging', 1, 4),
('Assign Ticket', 'Assign ticket to proper technician', 0, 5),
('Close Ticket', 'Mark ticket as resolved', 1, 6),
('Firewall Scan', 'Perform detailed firewall scan', 0, 7),
('Update Signatures', 'Update antivirus signatures', 1, 8),
('Backup DB', 'Perform pre-migration backup', 0, 9),
('Verify Migration', 'Check migrated data integrity', 1, 10)
) AS temp(Name, Contents, TaskStatus, ParentTaskID)
WHERE NOT EXISTS(SELECT 1 FROM ChildTasks ct WHERE ct.Name = temp.Name AND ct.ParentTaskID = temp.ParentTaskID);

-- -----------------------------
-- Messages
-- -----------------------------
INSERT INTO Messages (Message, AuthorUserId, AuthorUsername, CreatedAt, Type, OwnerId)
SELECT * FROM (VALUES
('Server upgrade scheduled', 1, 'alice', SYSUTCDATETIME(), 0, 1),
('Firmware update completed', 2, 'bob', SYSUTCDATETIME(), 0, 1),
('Deployment started', 3, 'charlie', SYSUTCDATETIME(), 1, 2),
('Login bug fixed', 4, 'diana', SYSUTCDATETIME(), 1, 2),
('Ticket #101 assigned', 5, 'edward', SYSUTCDATETIME(), 2, 3),
('Ticket #102 resolved', 6, 'frank', SYSUTCDATETIME(), 2, 3),
('Firewall audit initiated', 7, 'grace', SYSUTCDATETIME(), 3, 4),
('Antivirus updated', 8, 'helen', SYSUTCDATETIME(), 3, 4),
('DB backup completed', 9, 'ian', SYSUTCDATETIME(), 4, 5),
('DB migration verified', 10, 'julia', SYSUTCDATETIME(), 4, 5)
) AS temp(Message, AuthorUserId, AuthorUsername, CreatedAt, Type, OwnerId)
WHERE NOT EXISTS(SELECT 1 FROM Messages m WHERE m.Message = temp.Message AND m.OwnerId = temp.OwnerId);

-- -----------------------------
-- GroupWorkspaces
-- -----------------------------
INSERT INTO GroupWorkspaces (GroupID, WorkspaceID)
SELECT * FROM (VALUES
(1,1),(1,2),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10)
) AS temp(GroupID, WorkspaceID)
WHERE NOT EXISTS(SELECT 1 FROM GroupWorkspaces gw WHERE gw.GroupID = temp.GroupID AND gw.WorkspaceID = temp.WorkspaceID);

-- -----------------------------
-- UserWorkspaces
-- -----------------------------
INSERT INTO UserWorkspaces (UserID, WorkspaceID)
SELECT * FROM (VALUES
(1,1),(2,1),(3,2),(4,2),(5,3),(6,3),(7,4),(8,4),(9,5),(10,5)
) AS temp(UserID, WorkspaceID)
WHERE NOT EXISTS(SELECT 1 FROM UserWorkspaces uw WHERE uw.UserID = temp.UserID AND uw.WorkspaceID = temp.WorkspaceID);