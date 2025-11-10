using Class_Project_Database_Portion.Services;
using Microsoft.Data.SqlClient;
using System.IO;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<TaskHubService>();
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Run DB creation and full setup:
using (var scope = app.Services.CreateScope())
{
    var configuration = scope.ServiceProvider.GetRequiredService<IConfiguration>();

    // Get connection string from config
    var connectionString = configuration.GetConnectionString("TaskHubDbConnection");

    // Parse DB name and create connection string to 'master'
    var builderCS = new SqlConnectionStringBuilder(connectionString);
    string databaseName = builderCS.InitialCatalog;

    // Connect to master DB first
    builderCS.InitialCatalog = "master";
    using var masterConnection = new SqlConnection(builderCS.ConnectionString);
    masterConnection.Open();

    // Check if DB exists, create if not
    string createDbSql = $@"
        IF DB_ID(N'{databaseName}') IS NULL
        BEGIN
            CREATE DATABASE [{databaseName}];
        END";
    using (var command = new SqlCommand(createDbSql, masterConnection))
    {
        command.ExecuteNonQuery();
        Console.WriteLine($"Database '{databaseName}' checked/created.");
    }
    masterConnection.Close();

    // Now connect to the target DB
    builderCS.InitialCatalog = databaseName;
    using var dbConnection = new SqlConnection(builderCS.ConnectionString);
    dbConnection.Open();

    // Load db_config.sql script
    string fullScript = File.ReadAllText("Scripts/db_config.sql");

    // Split script by "GO" on its own line
    // This script was originally created for SQL Server Management Studio
    string[] batches = fullScript.Split(new string[] { "\r\nGO\r\n", "\nGO\n", "\r\nGO\n", "\nGO\r\n" }, StringSplitOptions.RemoveEmptyEntries);

    foreach (var batch in batches)
    {
        if (string.IsNullOrWhiteSpace(batch)) continue;

        using var cmd = new SqlCommand(batch, dbConnection);
        cmd.ExecuteNonQuery();
    }

    Console.WriteLine("Database setup (tables, constraints, procedures) executed successfully.");
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
