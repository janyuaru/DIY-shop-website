import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useParams, Link } from 'react-router-dom';
import { Card, Col, Container, Row } from 'react-bootstrap';
import './Products.css';
import Sort from './Sort';

const ProductsShop = () => {
  const { shopId } = useParams();
  const [products, setProducts] = useState([]);
  const [error, setError] = useState(null);

  const [sortOption, setSortOption] = useState('option1');

  const placeholderImage = '../images/placeholder.jpg';

  const fetchProductshop = (id, sort = 'price', order = 'asc') => {
    if (id) {
      axios
        .get(`/api/v1/products?shop_id=${id}&sort=${sort}&order=${order}`)
        .then((response) => {
          if (response.data.items) {
            setProducts(response.data.items);
            setError(null);
          }else if (response.data.error) {
            setError(response.data.error);
            setProducts([]);
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
    console.log('Fetching products for shop ID:', shopId);
    fetchProductshop(shopId, 'price', order );
  }, [shopId, sortOption]);

  const handleSortChange = (option) => {
    setSortOption(option); // อัปเดตค่าการเรียงลำดับ
};

  return (
    <Container className="my-5">
      <Sort onSortChange={handleSortChange}/>
      <div className="table-ps">
        <th className="col-ps">
          <h4>สินค้าในร้าน</h4>
        </th>
      </div>
      <Row className="d-flex flex-wrap justify-content-center">

        {error ? (
          <p className="text-center">{error}</p>
        ) : products.length > 0 ? (
        products.map((product) => {
          const primaryImage = product.images.find((img) => img.is_primary)?.image_url || placeholderImage;

          return (
            <Col key={product.id} className="d-flex justify-content-center productshop-card">
              <Card className="mb-4 productshop-hover" style={{ width: '100%', height: 'auto' }}>
              <Link to={`/product/detail/${product.id}`} style={{ textDecoration: 'none' }}>
                <Card.Img
                  variant="top"
                  src={primaryImage}
                  alt={product.name}
                  style={{ width: '100%', height: '200px', objectFit: 'cover' }}
                  onError={(e) => {
                    e.target.onerror = null;
                    e.target.src = placeholderImage;
                  }}
                />
                <Card.Body className="d-flex flex-column justify-content-between">
                  <div>
                    <Card.Title className="text-truncate" style={{ fontSize: '20px', color: 'black' }}>
                      {product.name}
                    </Card.Title>
                    <Card.Text className="text-truncate" style={{ fontSize: '16px', color: 'black' }}>
                      ราคา: {product.price} บาท
                    </Card.Text>
                  </div>
                  <div className="mt-2">
                    <Card.Text style={{ fontSize: '14px', color: 'black' }}>
                      ร้าน: {product.shops[0].shopname}
                    </Card.Text>
                  </div>
                </Card.Body>
                </Link>
              </Card>
            </Col>
          );
        })
      ) : (
        <p className="text-center">ไม่พบสินค้าที่ค้นหา</p>
      )}
      </Row>
    </Container>
  );
};

export default ProductsShop;
