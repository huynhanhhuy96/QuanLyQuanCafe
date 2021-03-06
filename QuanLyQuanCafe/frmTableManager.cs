using QuanLyQuanCafe.DAO;
using QuanLyQuanCafe.DTO;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using static QuanLyQuanCafe.frmAccountProfile;

namespace QuanLyQuanCafe //Assembly
{
    public partial class frmTableManager : Form
    {
        private Account loginAccount;

        public Account LoginAccount
        {
            get => loginAccount;
            set
            {
                loginAccount = value;
                ChangeAccount(loginAccount.Type);
            }
        }

        public frmTableManager(Account acc)
        {
            InitializeComponent();

            this.LoginAccount = acc;

            LoadTable();
            LoadCategory();
            LoadComboboxTable(cbSwitchTable);
        }

        #region Method

        void ChangeAccount(int type)
        {
            adminToolStripMenuItem.Enabled = type == 1;
            thôngTinTàiKhoảnToolStripMenuItem.Text += $" ({LoginAccount.DisplayName})";
        }

        void LoadCategory()
        {
            List<Category> listCategory = CategoryDAO.Instance.GetListCategory();
            cbCategory.DataSource = listCategory;
            cbCategory.DisplayMember = "Name";
        }

        void LoadListFoodByCategooryID(int id)
        {
            List<Food> listFood = FoodDAO.Instance.GetFoodByCategoryID(id);
            cbFood.DataSource = listFood;
            cbFood.DisplayMember = "Name";
        }

        void LoadTable()
        {
            fpnTable.Controls.Clear();
            List<Table> tableList = TableDAO.Instance.LoadTableList();
            foreach (Table item in tableList)
            {
                Button btn = new Button() { Width = TableDAO.TableWidth, Height = TableDAO.TableHeight };

                btn.Text = item.Name + Environment.NewLine + item.Status;
                btn.Click += Btn_Click;
                btn.Tag = item;

                switch (item.Status)
                {
                    case "Trống":
                        btn.BackColor = Color.Aqua;
                        break;
                    default:
                        btn.BackColor = Color.LightPink;
                        break;
                }

                fpnTable.Controls.Add(btn);
            }
        }

        void ShowBill(int id)
        {
            lstvBill.Items.Clear();

            List<DTO.Menu> listBillInfo = MenuDAO.Instance.GetListMenuByTable(id);

            float totalPrice = 0;

            foreach (DTO.Menu item in listBillInfo)
            {
                ListViewItem lsvItem = new ListViewItem(item.FoodName.ToString());
                lsvItem.SubItems.Add(item.Count.ToString());
                lsvItem.SubItems.Add(item.Price.ToString());
                lsvItem.SubItems.Add(item.TotalPrice.ToString());
                totalPrice += item.TotalPrice;

                lstvBill.Items.Add(lsvItem);
            }
            CultureInfo culture = new CultureInfo("vi-VN");

            //Thread.CurrentThread.CurrentCulture = culture;

            txtTotalPrice.Text = totalPrice.ToString("c", culture);
        }

        void LoadComboboxTable(ComboBox cb)
        {
            cb.DataSource = TableDAO.Instance.LoadTableList();
            cb.DisplayMember = "Name";
        }

        #endregion

        #region Events

        private void Btn_Click(object sender, EventArgs e)
        {
            int tableID = ((sender as Button).Tag as Table).ID;
            lstvBill.Tag = (sender as Button).Tag;
            ShowBill(tableID);
        }

        private void đăngXuấtToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void thôngTinCáNhânToolStripMenuItem_Click(object sender, EventArgs e)
        {
            frmAccountProfile frmAP = new frmAccountProfile(loginAccount);
            frmAP.UpdateAccountEvent += frmAP_UpdateAccountEvent;
            frmAP.ShowDialog();
        }

        void frmAP_UpdateAccountEvent(object sender, AccountEvent e)
        {
            thôngTinTàiKhoảnToolStripMenuItem.Text = $"Thông tin tài khoản ({e.Acc.DisplayName})";
        }

        private void adminToolStripMenuItem_Click(object sender, EventArgs e)
        {
            frmAdmin frmAM = new frmAdmin();
            frmAM.loginAccount = LoginAccount;
            frmAM.InsertFoodEvent += frmAM_InsertFood;
            frmAM.DeleteFoodEvent += frmAM_DeleteFood;
            frmAM.UpdateFoodEvent += frmAM_UpdateFood;
            frmAM.ShowDialog();
        }

        private void frmAM_UpdateFood(object sender, EventArgs e)
        {
            LoadListFoodByCategooryID((cbCategory.SelectedItem as Category).ID);
            if (lstvBill.Tag != null)
                ShowBill((lstvBill.Tag as Table).ID);
        }

        private void frmAM_DeleteFood(object sender, EventArgs e)
        {
            LoadListFoodByCategooryID((cbCategory.SelectedItem as Category).ID);
            if (lstvBill.Tag != null)
                ShowBill((lstvBill.Tag as Table).ID);
            LoadTable();
        }

        private void frmAM_InsertFood(object sender, EventArgs e)
        {
            LoadListFoodByCategooryID((cbCategory.SelectedItem as Category).ID);
            if (lstvBill.Tag != null)
                ShowBill((lstvBill.Tag as Table).ID);
        }

        private void cbCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = 0;

            ComboBox cb = sender as ComboBox;

            if (cb.SelectedItem == null)
                return;

            Category selected = cb.SelectedItem as Category;
            id = selected.ID;

            LoadListFoodByCategooryID(id);
        }

        private void btnAddFood_Click(object sender, EventArgs e)
        {
            Table table = lstvBill.Tag as Table;

            if (table == null)
            {
                MessageBox.Show("Hãy chọn bàn");
                return;
            }

            int idBill = BillDAO.Instance.GetUncheckBillIdByTableID(table.ID);
            int idFood = (cbFood.SelectedItem as Food).ID;
            int count = (int)nudFoodCount.Value;

            if (idBill == -1)
            {
                BillDAO.Instance.InsertBill(table.ID);
                BillInfoDAO.Instance.InsertBillInfo(BillDAO.Instance.GetMaxIdBill(), idFood, count);
            }
            else
            {
                BillInfoDAO.Instance.InsertBillInfo(idBill, idFood, count);
            }
            ShowBill(table.ID);

            LoadTable();
        }

        private void btnCheckOut_Click(object sender, EventArgs e)
        {
            Table table = lstvBill.Tag as Table;

            int idBill = BillDAO.Instance.GetUncheckBillIdByTableID(table.ID);
            int discount = (int)nudDiscount.Value;

            CultureInfo culture = new CultureInfo("vi");

            double totalPrice = double.Parse(txtTotalPrice.Text.Split(',')[0], culture);
            double fnTotalPrice = totalPrice - (totalPrice / 100) * discount;

            if (idBill != -1)
            {
                if (MessageBox.Show($"Bạn có chắc thanh toán hóa đơn cho {table.Name} \n Tổng tiền - (Tổng tiền / 100) x Giảm giá \n => {totalPrice} - ({totalPrice} / 100) x {discount} = {fnTotalPrice}", "Thông báo", MessageBoxButtons.OKCancel) == DialogResult.OK)
                {
                    BillDAO.Instance.CheckOut(idBill, discount, (float)fnTotalPrice);
                    ShowBill(table.ID);

                    LoadTable();
                }
            }
        }

        private void btnSwitchTable_Click(object sender, EventArgs e)
        {
            int id1 = (lstvBill.Tag as Table).ID;
            int id2 = (cbSwitchTable.SelectedItem as Table).ID;

            if (MessageBox.Show($"Bạn có thật sự muốn chuyển bàn {(lstvBill.Tag as Table).Name} quan bàn {(cbSwitchTable.SelectedItem as Table).Name} ?", "Thông báo", MessageBoxButtons.OKCancel) == DialogResult.OK)
            {
                TableDAO.Instance.SwitchTable(id1, id2);

                LoadTable();
            }
        }

        private void thanhToánToolStripMenuItem_Click(object sender, EventArgs e)
        {
            btnCheckOut_Click(this, new EventArgs());   // Gọi event btn_Click
        }

        private void thêmMónToolStripMenuItem_Click(object sender, EventArgs e)
        {
            btnAddFood_Click(this, new EventArgs());
        }

        #endregion
    }
}
