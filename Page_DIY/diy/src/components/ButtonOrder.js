import React from "react";
import { useNavigate } from "react-router-dom";
import "./ButtonOrder.css";

const ButtonOrder = () => {
  const navigate = useNavigate();


  const handleBuyNow = () => {
    navigate("/cart"); // ลิ้งค์ไปหน้ารถเข็น
  };

  return (
    <div>
      <button onClick={handleBuyNow} className="buy-now-btn">
        ซื้อสินค้า
      </button>
    </div>
  );
};

export default ButtonOrder;
