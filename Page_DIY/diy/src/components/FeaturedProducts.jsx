import { useEffect, useState } from 'react';
import axios from 'axios';
import { Card, Col, Container, Row } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import './ProductRecommend.css';

const product_featured_api = '/api/v1/products?sort=created_at&is_featured=true&order=desc&limit=3';

const FeaturedProducts = () => {

  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  const placeholderImage = '/path/to/placeholder.jpg'; // กำหนดเส้นทางรูปภาพ


  useEffect(() => {
    axios
      .get(product_featured_api)
      .then((response) => {
        setProducts(response.data.items);
        setLoading(false);
      })
      .catch((error) => {
        console.error('Error fetching the products:', error);
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading...</p>;

  return (
    <Container className="my-5">
      <div className="table-re">
        <th className="col-re">
          <h4>สินค้าแนะนำ</h4>
        </th>
      </div>
      <Row className="justify-content-center">
        {products.map((product) => {
          const primaryImage = product.images.find((img) => img.is_primary)?.image_url || placeholderImage;

          return (
            <Col xs={12} sm={6} md={3} lg={3} key={product.id} className="d-flex justify-content-center">
              <Card className="mb-4 featuredproducts-card" style={{ width: '300px', height: 'auto' }}>
                <Link to={`product/detail/${product.id}`} style={{ textDecoration: 'none' }}>
                  <Card.Img
                    variant="top"
                    src={primaryImage}
                    alt={product.name}
                    style={{ height: '250px', objectFit: 'cover' }}
                    onError={(e) => {
                      e.target.onerror = null;
                      e.target.src = placeholderImage;
                    }}
                  />
                  <Card.Body className="d-flex flex-column justify-content-between">
                    <div>
                      <Card.Title className="text-truncate" style={{ fontSize: '20px', color: 'black' }}>{product.name}</Card.Title>
                      {/* <Card.Text className="text-truncate" style={{ fontSize: '0.8rem', color: 'black' }}>{product.description}</Card.Text> */}
                    </div>
                    <div>
                      <Card.Text style={{ fontSize: '0.9rem', color: 'black' }}>
                        <strong>฿{product.price}.00</strong>
                      </Card.Text>
                    </div>
                    <div className="d-flex align-items-center">
                      {product.price && (
                        <span className="badge bg-danger me-2">Hot</span>
                      )}
                    </div>
                  </Card.Body>
                </Link>
              </Card>
            </Col>

          );
        })}
      </Row>
    </Container>
  );
};

export default FeaturedProducts;
