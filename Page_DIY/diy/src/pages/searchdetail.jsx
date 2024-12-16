import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Container, Row, Col, Card, Button } from 'react-bootstrap';
import { useSearchParams, Link } from 'react-router-dom';
import Header from '../components/Header';
import Footer from '../components/Footer';
import Sort from '../components/Sort';


const placeholderImage = '../assets/images/placeholder.jpg';

const Searchdetail = () => {

  const [products, setProducts] = useState([]);
  const [searchParams] = useSearchParams();
  const [error, setError] = useState(null);
  const [sortOption, setSortOption] = useState('option1');
  const [hoveredProductId, setHoveredProductId] = useState(null);

  const searchQuery = searchParams.get('q');

  const fetchProducts = (query, sort = 'price', order = 'asc') => {
    if (query) {
      axios
        .get(`/api/v1/products?search=${query}&sort=${sort}&order=${order}`)
        .then((response) => {
          if (response.data.items) {
            setProducts(response.data.items); // ตั้งค่า products ด้วยข้อมูลจาก API
            setError(null); // ล้าง error หากมีข้อมูล
          } else if (response.data.error) {
            setError(response.data.error); // เก็บข้อความข้อผิดพลาด
            setProducts([]); // ล้างรายการ products
          }
        })
        .catch((error) => {
          console.error('Error fetching the products:', error);
          setError('ไม่สามารถดึงข้อมูลสินค้ามาได้'); // เก็บข้อความข้อผิดพลาด
        });
    } else {
      setProducts([]);
    }
  };
  useEffect(() => {
    const order = sortOption === 'option1' ? 'asc' : 'desc';
    fetchProducts(searchQuery, 'price', order);
  }, [searchQuery, sortOption]);

  const handleSortChange = (option) => {
    setSortOption(option); // อัปเดตค่าการเรียงลำดับ
  };

  return (
    <div>
      <Header />

      <Container className="my-5">
        <h2 className="text-center mb-4">ผลการค้นหาสำหรับ "{searchQuery}"</h2>
        <Sort onSortChange={handleSortChange} />
        <Row>
          {error ? (
            <p className="text-center">{error}</p> // แสดงข้อความข้อผิดพลาด
          ) : products.length > 0 ? (
            products.map((product) => {
              const primaryImage = product.images.find((img) => img.is_primary)?.image_url || placeholderImage;

              return (
                <Col md={12} key={product.id}>
                  <Card className="mb-4 p-3" style={{ border: '1px solid #e5e5e5' }}>
                    <Row>
                      <Col md={3}>
                        <Link to={`/product/detail/${product.id}`}>
                          <Card.Img
                            src={primaryImage}
                            onError={(e) => {
                              e.target.onerror = null;
                              e.target.src = placeholderImage;
                            }}
                            style={{ maxHeight: '150px', objectFit: 'contain' }}
                          />
                        </Link>
                      </Col>
                      <Col md={6}>
                        <Card.Body>
                          <Card.Title style={{ fontSize: '1.5rem', color: '#007bff' }}>
                            {product.name}
                          </Card.Title>
                          <div style={{ fontSize: '1.2rem', color: '#ff6600' }}>
                            <strong>{product.price ? `฿${product.price}` : 'ราคาไม่ระบุ'}</strong>
                          </div>
                          <Card.Text>
                            {product.description ? product.description : 'ไม่มีคำอธิบายสินค้า'}
                          </Card.Text>
                        </Card.Body>
                      </Col>
                      <Col md={3} className="d-flex align-items-center justify-content-center">
                        <div>
                          {/* <Button variant="primary" className="me-2">
                                เพิ่มลงในตะกร้า
                              </Button> */}
                          <Link to={`/product/detail/${product.id}`}>
                            <Button style={{
                              color: hoveredProductId === product.id ? "#ffffff" : "#2b70e0",
                              border: `2px solid ${hoveredProductId === product.id ? "#2b70e0" : "#4a90e2"}`,
                              backgroundColor: hoveredProductId === product.id ? "#2b70e0" : "transparent",
                            }}
                              onMouseEnter={() => setHoveredProductId(product.id)} // เมื่อเมาส์เข้า
                              onMouseLeave={() => setHoveredProductId(null)}>
                              ดูรายละเอียด
                            </Button>
                          </Link>
                        </div>
                      </Col>
                    </Row>
                  </Card>
                </Col>
              );
            })
          ) : (
            <p className="text-center">ไม่พบสินค้าที่ค้นหา</p>
          )}
        </Row>
      </Container>
      <Footer />
    </div>
  );
};

export default Searchdetail;
