using Class_Project_Database_Portion.Models;
using Class_Project_Database_Portion.Services;
using Class_Project_Database_Portion.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace Class_Project_Database_Portion.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly TaskHubService _taskHubService;
        private readonly IUserService _userService;

        public HomeController(
            TaskHubService taskHubService,
            IUserService userService,
            ILogger<HomeController> logger)
        {
            _taskHubService = taskHubService;
            _userService = userService;
            _logger = logger;
        }

        // Index - Dashboard
        public async Task<IActionResult> Index(int userId = 1)
        {
            var dashboard = await _userService.GetUserDashboardAsync(userId);
            return View(dashboard);
        }


        // Stored-procedure endpoints
        public async Task<IActionResult> Messages(int ownerId, int type)
        {
            var messages = await _taskHubService.GetMessagesByOwnerAndTypeAsync(ownerId, type);
            return View(messages);
        }

        public async Task<IActionResult> ChildTasks(int taskId)
        {
            var childTasks = await _taskHubService.GetChildTasksByTaskIdAsync(taskId);
            return View(childTasks);
        }

        public async Task<IActionResult> UserTasks(int userId)
        {
            var tasks = await _taskHubService.GetUserTasksAsync(userId);
            return View(tasks);
        }

        public async Task<IActionResult> UserGroups(int userId)
        {
            var groups = await _taskHubService.GetUserGroupsAsync(userId);
            return View(groups);
        }

        public async Task<IActionResult> UserWorkspaces(int userId)
        {
            var workspaces = await _taskHubService.GetUserWorkspacesAsync(userId);
            return View(workspaces);
        }

        public async Task<IActionResult> GroupWorkspaces(int groupId)
        {
            var workspaces = await _taskHubService.GetGroupWorkspacesAsync(groupId);
            return View(workspaces);
        }

        public async Task<IActionResult> WorkspaceTasks(int workspaceId)
        {
            var tasks = await _taskHubService.GetWorkspaceTasksAsync(workspaceId);
            return View(tasks);
        }

        public async Task<IActionResult> WorkspaceMemberships(int userId)
        {
            var memberships = await _taskHubService.GetUserWorkspaceMembershipsAsync(userId);
            return View(memberships);
        }


        // Register user
        [HttpPost]
        public async Task<IActionResult> RegisterUser(string username, string password, string email)
        {
            var (result, userId) = await _taskHubService.RegisterUserAsync(username, password, email);
            return Json(new { result, userId });
        }

        // Login user
        [HttpPost]
        public async Task<IActionResult> AuthenticateUser(string username, string password)
        {
            var user = await _taskHubService.AuthenticateUserAsync(username, password);

            if (user == null)
                return Unauthorized();

            return Json(user);
        }
    }
}
