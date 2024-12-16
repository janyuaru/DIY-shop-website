import React, { useState } from "react";

const QuantityControl = () => {
  const [quantity, setQuantity] = useState(1);

  const increaseQuantity = () => {
    setQuantity(quantity + 1);
  };

  const decreaseQuantity = () => {
    if (quantity > 1) {
      setQuantity(quantity - 1);
    }
  };

  return (
    <div
      className="d-flex align-items-center border"
      style={{
        borderColor: "#2b70e0",
        width: "100px",
      }}
    >
      <button
        className="btn"
        onClick={decreaseQuantity}
        style={{
          color: "#2b70e0",
          border: "none",
          backgroundColor: "transparent",
          width: "33%",
          fontSize: "20px",
        }}
        onMouseEnter={(e) => {
          e.target.style.backgroundColor = "#2b70e0";
          e.target.style.color = "#ffffff";
          e.target.style.borderRadius = "0px";
        }}
        onMouseLeave={(e) => {
          e.target.style.backgroundColor = "transparent";
          e.target.style.color = "#2b70e0";
          e.target.style.borderRadius = "0";
        }}
      >
        -
      </button>
      <span
        className="text-center"
        style={{
          width: "34%",
          fontSize: "20px",
          color: "#000",
          height: "100%",
        }}
      >
        {quantity}
      </span>
      <button
        className="btn"
        onClick={increaseQuantity}
        style={{
          color: "#2b70e0",
          border: "none",
          backgroundColor: "transparent",
          width: "33%",
          fontSize: "20px",
        }}
        onMouseEnter={(e) => {
          e.target.style.backgroundColor = "#2b70e0";
          e.target.style.color = "#ffffff";
          e.target.style.borderRadius = "0px";
        }}
        onMouseLeave={(e) => {
          e.target.style.backgroundColor = "transparent";
          e.target.style.color = "#2b70e0";
          e.target.style.borderRadius = "0px";
        }}
      >
        +
      </button>
    </div>
  );
};

export default QuantityControl;
