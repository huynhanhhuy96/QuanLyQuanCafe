using QuanLyQuanCafe.DTO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyQuanCafe.DAO
{
    public class TableDAO
    {
        private static TableDAO instance;

        public static TableDAO Instance
        {
            get => instance == null ? instance = new TableDAO() : instance;
            private set => instance = value;
        }

        private TableDAO() { }

        public static int TableWidth = 65;
        public static int TableHeight = 65;

        public List<Table> LoadTableList()
        {
            List<Table> tableList = new List<Table>();

            DataTable data = DataProvider.Instance.ExecuteQuery("EXEC USP_GetTableList");

            foreach (DataRow item in data.Rows)
            {
                Table table = new Table(item);
                tableList.Add(table);
            }

            return tableList;
        }

        public void SwitchTable(int id1, int id2)
        {
            string query = "USP_SwitchTable @idTable1 , @idTable2";
            DataProvider.Instance.ExecuteQuery(query, new object[] { id1, id2 });
        }
    }
}
