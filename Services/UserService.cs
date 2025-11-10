using Class_Project_Database_Portion.ViewModels;
using Dapper;
using System.Data;
using Microsoft.Data.SqlClient;

namespace Class_Project_Database_Portion.Services
{
    public class UserService : IUserService
    {
        private readonly string _connectionString;

        public UserService(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("TaskHubDbConnection"); 

        }

        private IDbConnection CreateConnection()
        { 
            var conn = new SqlConnection(_connectionString);

            return conn;

        }

        public async Task<UserDashboardViewModel> GetUserDashboardAsync(int userId)
        {

            using var _db = CreateConnection();

            // USER
            var user = await _db.QuerySingleOrDefaultAsync<UserDashboardViewModel>(
                 "SELECT ID AS UserId, Username FROM Users WHERE ID = @Id",
                 new { Id = userId });

            // GROUPS OWNED
            user.GroupsOwned = (await _db.QueryAsync<GroupViewModel>(
                @"SELECT g.ID AS GroupId, g.Name, g.Description, u.Username AS OwnerUsername
                  FROM Groups g
                  JOIN Users u ON g.OwnerID = u.ID
                  WHERE g.OwnerID = @Id",
                new { Id = userId })).ToList();

            // WORKSPACES OWNED
            var workspaces = await _db.QueryAsync<WorkspaceViewModel>(
                @"SELECT w.ID AS WorkspaceId, w.Name, w.Description, 
                         u.Username AS OwnerUsername, g.Name AS GroupName
                  FROM Workspaces w
                  JOIN Users u ON w.OwnerID = u.ID
                  LEFT JOIN Groups g ON w.GroupID = g.ID
                  WHERE w.OwnerID = @Id",
                new { Id = userId });

            user.WorkspacesOwned = workspaces.ToList();

            // TASKS (BY OWNED WORKSPACES)
            var tasks = await _db.QueryAsync<TaskViewModel>(
                @"SELECT t.TaskID AS TaskId, t.TaskName, t.Assignee, t.TaskStatus
                  FROM Tasks t
                  INNER JOIN Workspaces w ON t.WorkspaceID = w.ID
                  WHERE w.OwnerID = @Id",
                new { Id = userId });

            var taskList = tasks.ToList();

            // CHILD TASKS PER TASK
            foreach (var task in taskList)
            {
                var childTasks = await _db.QueryAsync<ChildTaskViewModel>(
                    @"SELECT ID, Name, Contents, TaskStatus 
                      FROM ChildTasks 
                      WHERE ParentTaskID = @Id",
                    new { Id = task.TaskId });

                task.ChildTasks = childTasks.ToList();
            }

            user.TasksAssigned = taskList;

            // MESSAGES
            user.UserMessages = (await _db.QueryAsync<MessageViewModel>(
                @"SELECT m.ID, m.Message AS MessageContent, u.Username AS AuthorUsername, m.CreatedAt, m.Type, u.Username AS OwnerUsername
                FROM Messages m
                JOIN Users u ON m.AuthorUserId = u.ID
                WHERE m.OwnerID = @Id",
                new { Id = userId }
            )).ToList();

            return user;
        }
    }
}
