using QuanLyQuanCafe.DTO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyQuanCafe.DAO
{
    public class BillDAO
    {
        private static BillDAO instance;

        public static BillDAO Instance
        {
            get => instance == null ? instance = new BillDAO() : instance;
            private set => instance = value;
        }

        private BillDAO() { }

        /// <summary>
        /// Thành công: bill ID
        /// Thất bại: -1
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public int GetUncheckBillIdByTableID(int id)
        {
            DataTable data = DataProvider.Instance.ExecuteQuery("SELECT * FROM dbo.Bill WHERE idTable = " + id + " AND status = 0");

            if (data.Rows.Count > 0)
            {
                Bill bill = new Bill(data.Rows[0]);
                return bill.ID;
            }
            return -1;
        }

        public void InsertBill(int id)
        {
            DataProvider.Instance.ExecuteNonQuery("EXEC USP_InsertBill @idTable", new object[] { id });
        }

        public int GetMaxIdBill()
        {
            try
            {
                return (int)DataProvider.Instance.ExecuteScalar("SELECT MAX(id) FROM dbo.Bill");
            }
            catch
            {
                return 1;
            }
        }

        public void CheckOut(int id, int discount, float totalPrice)
        {
            string query = "UPDATE dbo.Bill SET dateCheckOut = GETDATE(), status = 1, discount = " + discount + ", totalPrice = " + totalPrice +" WHERE id = " + id;
            DataProvider.Instance.ExecuteQuery(query);
        }

        public DataTable GetBillListByDate(DateTime checkIn, DateTime checkOut)
        {
            string query = "EXEC USP_GetListBillByDate @checkIn , @checkOut";
            return DataProvider.Instance.ExecuteQuery(query, new object[] { checkIn, checkOut });
        }

        public DataTable GetBillListByDateAndPage(DateTime checkIn, DateTime checkOut, int pageNum)
        {
            string query = "EXEC USP_GetListBillByDateAndPage @checkIn , @checkOut , @pgae";
            return DataProvider.Instance.ExecuteQuery(query, new object[] { checkIn, checkOut, pageNum });
        }

        public int GetNumBillListByDate(DateTime checkIn, DateTime checkOut)
        {
            string query = "EXEC USP_GetNumBillByDate @checkIn , @checkOut";
            return (int)DataProvider.Instance.ExecuteScalar(query, new object[] { checkIn, checkOut });
        }
    }
}
