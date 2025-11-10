using Class_Project_Database_Portion.Models;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Class_Project_Database_Portion.Services
{
    public class TaskHubService
    {
        private readonly string _connectionString;

        public TaskHubService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("TaskHubDbConnection")!;
        }

        // -----------------------------------
        // Debugging internal DB connection
        // -----------------------------------
        public async Task<string> TestConnectionAsync_01()
        {
            try
            {
                using (var conn = new SqlConnection(_connectionString))
                {
                    await conn.OpenAsync();
                    return "Database connection successful!";
                }
            }
            catch (Exception ex)
            {
                return $"Database connection failed: {ex.Message}";
            }
        }

        // ----------------------------------
        // Debugging DB connection for View
        // ----------------------------------
        public async System.Threading.Tasks.Task TestConnectionAsync_02()
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                Console.WriteLine("Connected successfully!");
                conn.Close();
            }
        }

        // ------------------------------------------
        // Gets messages for a given owner and type.
        // ------------------------------------------

        public async Task<List<Message>> GetMessagesByOwnerAndTypeAsync(int ownerId, int type)
        {
            var messages = new List<Message>();

            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand("GetMessagesByOwnerAndType", connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@OwnerId", ownerId);
                command.Parameters.AddWithValue("@Type", type);

                await connection.OpenAsync();

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        messages.Add(new Message
                        {
                            ID = reader.GetInt32(reader.GetOrdinal("ID")),
                            MessageText = reader.GetString(reader.GetOrdinal("Message")),
                            AuthorUserId = reader.GetInt32(reader.GetOrdinal("AuthorUserId")),
                            AuthorUsername = reader.GetString(reader.GetOrdinal("AuthorUsername")),
                            CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                            Type = reader.GetInt32(reader.GetOrdinal("Type")),
                            OwnerId = reader.GetInt32(reader.GetOrdinal("OwnerId"))
                        });
                    }
                }
            }

            return messages;
        }

        // -----------------------------
        // Get Child Tasks by Parent Task
        // -----------------------------
        public async Task<List<ChildTask>> GetChildTasksByTaskIdAsync(int taskId)
        {
            var childTasks = new List<ChildTask>();
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("GetChildTasksByTaskId", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@TaskId", taskId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                childTasks.Add(new ChildTask
                {
                    ID = reader.GetInt32("ID"),
                    ParentTaskID = reader.GetInt32("ParentTaskID"),
                    Name = reader.GetString("Name"),
                    Contents = reader.GetString("Contents"),
                    TaskStatus = reader.GetInt32("TaskStatus")
                });
            }

            return childTasks;
        }

        // -----------------------------
        // Register User
        // -----------------------------
        public async Task<(int Result, int? UserID)> RegisterUserAsync(string username, string password, string email)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("RegisterUser", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@Username", username);
            command.Parameters.AddWithValue("@Password", password);
            command.Parameters.AddWithValue("@Email", email);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                int result = reader.GetInt32("Result");
                int? userId = reader.IsDBNull("UserID") ? null : reader.GetInt32("UserID");
                return (result, userId);
            }
            return (-1, null);
        }

        // -----------------------------
        // Authenticate User
        // -----------------------------
        public async Task<User?> AuthenticateUserAsync(string username, string password)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("AuthenticateUser", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@Username", username);
            command.Parameters.AddWithValue("@Password", password);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new User
                {
                    ID = reader.GetInt32("ID"),
                    Username = reader.GetString("Username"),
                    Email = reader.GetString("Email"),
                    AccountCreated = reader.GetDateTime("AccountCreated")
                };
            }
            return null;
        }

        // -----------------------------
        // Get Workspace Tasks
        // -----------------------------
        public async Task<List<int>> GetWorkspaceTasksAsync(int workspaceId)
        {
            var tasks = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("GetWorkspaceTasks", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@WorkspaceID", workspaceId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                tasks.Add(reader.GetInt32("TaskID"));
            }
            return tasks;
        }

        // -----------------------------
        // Get Group Workspaces
        // -----------------------------
        public async Task<List<int>> GetGroupWorkspacesAsync(int groupId)
        {
            var workspaces = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("GetGroupWorkspaces", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@GroupID", groupId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                workspaces.Add(reader.GetInt32("ID"));
            }
            return workspaces;
        }

        // -----------------------------
        // Get User Groups
        // -----------------------------
        public async Task<List<int>> GetUserGroupsAsync(int userId)
        {
            var groups = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("GetUserGroups", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@UserID", userId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                groups.Add(reader.GetInt32("ID"));
            }
            return groups;
        }

        // -----------------------------
        // Get User Workspaces
        // -----------------------------
        public async Task<List<int>> GetUserWorkspacesAsync(int userId)
        {
            var workspaces = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("GetUserWorkspaces", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@UserID", userId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                workspaces.Add(reader.GetInt32("ID"));
            }
            return workspaces;
        }

        // -----------------------------
        // Get User Tasks
        // -----------------------------
        public async Task<List<int>> GetUserTasksAsync(int userId)
        {
            var tasks = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("GetUserTasks", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@UserID", userId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                tasks.Add(reader.GetInt32("TaskID"));
            }
            return tasks;
        }

        // -----------------------------
        // Get User Workspace Memberships
        // -----------------------------
        public async Task<List<int>> GetUserWorkspaceMembershipsAsync(int userId)
        {
            var memberships = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("GetUserWorkspaceMemberships", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@UserID", userId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                memberships.Add(reader.GetInt32("WorkspaceID"));
            }
            return memberships;
        }
    }

}
