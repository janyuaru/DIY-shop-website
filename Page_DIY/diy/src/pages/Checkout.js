import "./Checkout.css";
// import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import { check } from "../data/Checkoutdata"

const Checkout = () => {

  const checklist = check.find((c) => c.id === parseInt(1));

  if (!checklist) {
    return <p>Not found product detail</p>;
  }

  return (
    <body>
      <div className="container-main">
        <div className="container">
          {/* ที่อยู่ในการจัดส่ง */}
          <div className="address-container">
            <div className="address-header">
              <img
                src="images/location.png"
                alt="Location Icon"
                className="location-icon"
              />
              <h5>ที่อยู่ในการจัดส่ง</h5>
            </div>
            <div className="address-content">
              <div className="address-info">
                <p><strong>{checklist.name}</strong> {checklist.phone}</p>
                <p>{checklist.address}</p>
              </div>
              <button className="change-btn">เปลี่ยน</button>
            </div>
          </div>
        </div>
      </div>

      <div className="container-main">
        <div className="container">
          <div className="address-container">
            <Row className="justify-content-md-center row-spacing">
              <Col>สั่งซื้อสินค้าแล้ว</Col>
              <Col xs lg="2" className="text-right text-color">ราคาต่อหน่วย</Col>
              <Col xs lg="2" className="text-right text-color">จำนวน</Col>
              <Col xs lg="2" className="text-right text-color">รายการย่อย</Col>
            </Row>
            <Row className="justify-content-md-center row-spacing">
              <Col>Handmade1788</Col>
            </Row>
            <Row className="justify-content-md-center row-spacing">
              <Col className="product-info">
                <img src="images/bluesweater.png" alt="" className="product-image" />
                เสื้อไหมพรมสีดำ
              </Col>
              <Col xs lg="2" className="text-right">฿250</Col>
              <Col xs lg="2" className="text-right">1</Col>
              <Col xs lg="2" className="text-right">฿250</Col>
            </Row>
            <hr className="divider" />
            <Row className="justify-content-md-center row-spacing">
              <Col className="text-right">Shipping Option: ส่งแบบธรรมดา</Col>
              <Col xs lg="2" className="text-right">฿38</Col>
            </Row>
            <hr className="divider" />
            <Row className="justify-content-md-center row-spacing">
              <Col className="text-right">คำสั่งซื้อทั้งหมด (1 ชิ้น)</Col>
              <Col xs lg="2" className="text-right">฿288</Col>
            </Row>
          </div>
        </div>
      </div>

      <div className="container-main">
        <div className="container">
          <div className="address-container">
            <Row className="justify-content-md-center row-spacing">
              <div class="payment-options">
                <label>วิธีการชำระเงิน</label>
                <div class="option-group">
                  <button class="payment-option">QR Promptpay</button>
                  <button class="payment-option">เก็บเงินปลายทาง</button>
                  <button class="payment-option">Mobile Banking</button>
                </div>
              </div>
            </Row>
            <hr className="divider" />
            <Row className="justify-content-md-center row-spacing">
              <Col className="text-right">รวมการสั่งซื้อ</Col>
              <Col xs lg="2" className="text-right">฿250</Col>
            </Row>
            <Row className="justify-content-md-center row-spacing">
              <Col className="text-right">การจัดส่ง</Col>
              <Col xs lg="2" className="text-right">฿38</Col>
            </Row>
            <Row className="justify-content-md-center row-spacing">
              <Col className="text-right">ยอดชำระเงินทั้งหมด</Col>
              <Col xs lg="2" className="text-right">฿288</Col>
            </Row>
            <hr className="divider" />
            <div class="button-container">
              <button class="order-checkout-btn">สั่งสินค้า</button>
            </div>
          </div>
        </div>
      </div>

    </body>
  );
};

export default Checkout;
