using Class_Project_Database_Portion.ViewModels;
using System.Threading.Tasks;

namespace Class_Project_Database_Portion.Services
{
    public interface IUserService
    {
        Task<UserDashboardViewModel> GetUserDashboardAsync(int userId);
    }
}
