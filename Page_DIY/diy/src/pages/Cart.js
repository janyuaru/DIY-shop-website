import Header from "../components/Header";
import React, { useState } from "react";
import "../components/Cart.css";
import Control from "../components/Control";
import ButtonOrder from "../components/ButtonOrder";

const Cart = () => {
  const [quantities, setQuantities] = useState({
    item1: 1,
    item2: 1,
  });
  const [selectedItems, setSelectedItems] = useState({
    item1: false,
    item2: false,
  });

  const pricePerItem = 500;

  // ฟังก์ชันสำหรับเพิ่มจำนวนสินค้าตาม ID ของสินค้า
  const handleIncrease = (itemId) => {
    setQuantities((prevQuantities) => ({
      ...prevQuantities,
      [itemId]: prevQuantities[itemId] + 1,
    }));
  };

  // ฟังก์ชันสำหรับลดจำนวนสินค้าตาม ID ของสินค้า
  const handleDecrease = (itemId) => {
    setQuantities((prevQuantities) => ({
      ...prevQuantities,
      [itemId]: Math.max(prevQuantities[itemId] - 1, 1),
    }));
  };

  // ฟังก์ชันสำหรับเลือก/ยกเลิกการเลือกสินค้าตาม ID
  const handleSelectItem = (itemId) => {
    setSelectedItems((prevSelected) => ({
      ...prevSelected,
      [itemId]: !prevSelected[itemId],
    }));
  };

  // ฟังก์ชันสำหรับเลือกหรือยกเลิกการเลือกสินค้าทั้งหมด
  const handleSelectAll = () => {
    const allSelected = Object.values(selectedItems).every(
      (isSelected) => isSelected
    );
    const newSelectionState = Object.keys(selectedItems).reduce(
      (acc, itemId) => {
        acc[itemId] = !allSelected;
        return acc;
      },
      {}
    );
    setSelectedItems(newSelectionState);
  };

  // คำนวณราคารวมจากสินค้าที่ถูกเลือกเท่านั้น
  const totalPrice = Object.keys(quantities)
    .filter((itemId) => selectedItems[itemId]) // เลือกเฉพาะสินค้าที่ถูกเลือก
    .reduce((acc, itemId) => acc + quantities[itemId] * pricePerItem, 0);

  // คำนวณจำนวนสินค้าที่ถูกเลือก
  const selectedItemCount = Object.keys(quantities)
    .filter((itemId) => selectedItems[itemId])
    .reduce((acc, itemId) => acc + quantities[itemId], 0);

  return (
    <div>
      <Header />
      <div className="Container">
        <div className="table-con">
          <table>
            <thead>
              <tr>
                <th className="col-select">
                  <input
                    type="checkbox"
                    onChange={handleSelectAll}
                    checked={Object.values(selectedItems).every(Boolean)}
                  />
                </th>
                <th className="col-product">สินค้า</th>
                <th className="col-price">ราคาต่อชิ้น</th>
                <th className="col-quantity">จำนวน</th>
                <th className="col-total">ราคารวม</th>
                <th className="col-action">แอคชั่น</th>
              </tr>
            </thead>
          </table>
        </div>

        <div className="table-shop">
          {/* สินค้าชิ้นที่ 1 */}
          <div className="list">
            <table>
              <tr>
                <td className="col-goods">
                  <input
                    type="checkbox"
                    checked={selectedItems.item1}
                    onChange={() => handleSelectItem("item1")}
                  />
                </td>
                <td className="product-item">
                  <img
                    className="product-img"
                    src="https://down-th.img.susercontent.com/file/th-11134207-7rasb-m1r84xaeox6f90.webp"
                    alt="สินค้า 1"
                    width="100"
                    height="100"
                  />
                </td>
                <td className="product">หมวกไหมพรม</td>
                <td className="price">฿{pricePerItem}</td>
                <td className="amount">
                  <Control
                    quantity={quantities.item1}
                    onIncrease={() => handleIncrease("item1")}
                    onDecrease={() => handleDecrease("item1")}
                  />
                </td>
                <td className="total">฿{quantities.item1 * pricePerItem}</td>
                <td className="action">
                  <button className="btn-delete">ลบ</button>
                </td>
              </tr>
            </table>
          </div>

          {/* สินค้าชิ้นที่ 2 */}
          <div className="list">
            <table>
              <tr>
                <td className="col-goods">
                  <input
                    type="checkbox"
                    checked={selectedItems.item2}
                    onChange={() => handleSelectItem("item2")}
                  />
                </td>
                <td className="product-item">
                  <img
                    className="product-img"
                    src="https://down-th.img.susercontent.com/file/th-11134207-7rasb-m1r84xaeox6f90.webp"
                    alt="สินค้า 2"
                    width="100"
                    height="100"
                  />
                </td>
                <td className="product">สร้อยข้อมือ</td>
                <td className="price">฿{pricePerItem}</td>
                <td className="amount">
                  <Control
                    quantity={quantities.item2}
                    onIncrease={() => handleIncrease("item2")}
                    onDecrease={() => handleDecrease("item2")}
                  />
                </td>
                <td className="total">฿{quantities.item2 * pricePerItem}</td>
                <td className="action">
                  <button className="btn-delete">ลบ</button>
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div className="total-product">
          <input
            type="checkbox"
            onChange={handleSelectAll}
            checked={Object.values(selectedItems).every(Boolean)}
          />
          เลือกสินค้าทั้งหมด (<span id="total-items">2</span>)
          <div className="total-price">
            ราคา ({selectedItemCount} รายการสินค้า):{" "}
            <span className="price-highlight">฿{totalPrice}</span>
          </div>
          <div className="colprice">
            <ButtonOrder />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Cart;
