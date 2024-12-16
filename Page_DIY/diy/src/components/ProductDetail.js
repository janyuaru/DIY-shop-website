import React from 'react';
import { Button, Card, Col, Container, Row } from 'react-bootstrap';
import './ProductDetail.css';

const ProductDetail = () => {
    return (
        <Container className="my-5">
            <Row className="justify-content-center">
                <Col xs={12} md={11}>
                    <Card className="p-3 border-light-subtle">
                        <Row className="align-items-center">
                            {/* คอลัมน์ด้านซ้ายสำหรับรูปไอคอน */}
                            <Col xs={3} className="d-flex align-items-center justify-content-center">
                                <img
                                    src="https://i.pinimg.com/736x/50/2f/0e/502f0e1dd8df3b04a780262ab3996126.jpg"
                                    alt="Shop Logo"
                                    className="rounded-circle"
                                    style={{ width: '100px', height: '100px', cursor: 'pointer' }}
                                />
                            </Col>

                            {/* คอลัมน์ด้านขวาสำหรับข้อมูลร้านค้าและปุ่ม */}
                            <Col xs={9} className="d-flex flex-column">
                                <div className="d-flex justify-content-between align-items-center mb-2">
                                    <div>
                                        <h5>กรรไกรขายผ้าไหมช็อป</h5>
                                        <p className="mb-0">Joined: 12 months ago</p>
                                    </div>
                                    <div>
                                        <Button variant="danger" className="me-2">Chat Now</Button>
                                        <Button variant="outline-secondary">View Shop</Button>
                                    </div>
                                </div>
                            </Col>
                        </Row>
                    </Card>
                </Col>
            </Row>

            <section class="detail">
                <div class="container">
                    <div class="detail-main">
                        <h2>ข้อมูลจำเพาะของสินค้า</h2>
                    </div>
                </div>
            </section>
        </Container>
    );
};

export default ProductDetail;
