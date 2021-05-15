using QuanLyQuanCafe.DTO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyQuanCafe.DAO
{
    public class AccountDAO
    {
        private static AccountDAO instance;

        public static AccountDAO Instance
        {
            get => instance == null ? instance = new AccountDAO() : instance;
            private set => instance = value;
        }

        private AccountDAO() { }

        public bool Login(string userName, string password)
        {
            string query = $"USP_Login @userName , @passWord";
            
            DataTable result = DataProvider.Instance.ExecuteQuery(query, new object[] {userName, password});

            return result.Rows.Count > 0;
        }

        public Account GetAccountByUserName(string userName)
        {
            string query = "SELECT * FROM Account WHERE userName = '" + userName +"'";
            DataTable data = DataProvider.Instance.ExecuteQuery(query);

            foreach (DataRow item in data.Rows)
            {
                return new Account(item);
            }
            return null;
        }

        public bool UpdateAccount(string userName, string displayName, string pass, string newPass)
        {
            string query = "EXEC USP_UpdateAccount @userName , @displayName , @password , @newPassword";
            int result = DataProvider.Instance.ExecuteNonQuery(query, new object[] { userName, displayName, pass, newPass});

            return result > 0;
        }
    }
}
