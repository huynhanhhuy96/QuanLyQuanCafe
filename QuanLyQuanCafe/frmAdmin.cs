using QuanLyQuanCafe.DAO;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QuanLyQuanCafe
{
    public partial class frmAdmin : Form
    {
        public frmAdmin()
        {
            InitializeComponent();
            LoadDateTimePickerBill();
            LoadListViewByDate(dtpFromDate.Value, dtpToDate.Value);
            LoadAccountList();
        }

        #region methods

        void LoadAccountList()
        {
            string query = "Exec dbo.USP_GetAccountByUserName @userName";

            dgvAccount.DataSource = DataProvider.Instance.ExecuteQuery(query, new object[] { "K9" });
        }

        void LoadListViewByDate(DateTime checkIn, DateTime checkOut)
        {
            dgvBill.DataSource = BillDAO.Instance.GetBillListByDate(checkIn, checkOut);
        }

        void LoadDateTimePickerBill()
        {
            DateTime today = DateTime.Now;
            dtpFromDate.Value = new DateTime(today.Year, today.Month, 1);
            dtpToDate.Value = dtpFromDate.Value.AddMonths(1).AddDays(-1);
        }

        #endregion

        #region events

        private void btnViewBill_Click(object sender, EventArgs e)
        {
            LoadListViewByDate(dtpFromDate.Value, dtpToDate.Value);
        }

        #endregion
    }
}
