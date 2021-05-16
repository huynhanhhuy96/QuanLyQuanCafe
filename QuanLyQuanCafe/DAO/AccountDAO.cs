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

        public DataTable GetListAccount()
        {
            string query = "SELECT UserName, DisplayName, Type FROM dbo.Account";
            return DataProvider.Instance.ExecuteQuery(query);
        }

        public bool InsertAccount(string name, string displayName, int type)
        {
            string query = $"INSERT dbo.Account ( UserName, DisplayName, Type) VALUES (N'{name}', N'{displayName}', {type})";
            int result = DataProvider.Instance.ExecuteNonQuery(query);

            return result > 0;
        }

        public bool UptdateAccount(string name, string displayName, int type)
        {
            string query = $"UPDATE dbo.Account SET DisplayName = N'{displayName}', Type = {type} WHERE UserName = N'{name}'";
            int result = DataProvider.Instance.ExecuteNonQuery(query);

            return result > 0;
        }

        public bool DeleteAccount(string userName)
        {
            string query = $"DELETE Account WHERE UserName = N'{userName}'";
            int result = DataProvider.Instance.ExecuteNonQuery(query);

            return result > 0;
        }

        public bool ResetPass(string userName)
        {
            string query = $"UPDATE Account SET PassWord = N'0' WHERE UserName = N'{userName}'";
            int result = DataProvider.Instance.ExecuteNonQuery(query);

            return result > 0;
        }
    }
}
