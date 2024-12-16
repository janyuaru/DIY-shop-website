import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useParams } from 'react-router-dom';
import '../components/DIYdetail.css';
import { Button } from 'react-bootstrap';
import QuantityControl from '../components/QuantityControl';
// import AddToCartButton from '../components/AddToCartButton';
import { Link } from 'react-router-dom';
import Header from "../components/Header";
import Footer from '../components/Footer';


const DIYdetail = () => {

  const { productId } = useParams();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [hoveredProductId, setHoveredProductId] = useState(null);

  const placeholderImage = '/path/to/placeholder.jpg';

  const fetchProductDetails = (id) => {
    axios
      .get(`/api/v1/products/${id}`)
      .then((response) => {
        console.log(response.data);
        setProduct(response.data);
        setLoading(false);
      })
      .catch((error) => {
        console.error('Error fetching product details:', error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchProductDetails(productId);
  }, [productId]);

  useEffect(() => {
    console.log(product?.shops);
  }, [product]);

  if (loading) return <p>Loading...</p>;

  if (!product) return <p>No product found</p>;

  return (
    <div>
      <Header />

      <section class="product">
        <div class="container">
          <div className="product-detail-container">
            <div className="image-container">
              <img
                src={product?.images?.find((img) => img.is_primary)?.image_url || placeholderImage}
                alt={product?.name || 'Product image'}
              />
            </div>
            <div className="info-container">
              <h2>{product.name}</h2>
              <p><strong>ราคา:</strong> {product.price ? `${product.price}฿` : 'ราคาไม่ระบุ'}</p>
              {product.options && product.options.map((option, index) => (
                <p key={index}>
                  <strong>{option.name}:</strong> {Array.isArray(option.values) ? option.values.join(', ') : option.values || 'ข้อมูลไม่ระบุ'}
                </p>
              ))}
              <p><strong>จำนวน</strong></p>
              <QuantityControl />
              <br></br>
              <p><strong>สินค้าคงเหลือ:</strong> {product.inventory?.quantity || 'ข้อมูลไม่ระบุ'}</p>
              {/* <AddToCartButton /> */}
            </div>
          </div>
        </div>
      </section>


      <section class="detail">
        <div class="container">
          <div class="detail-main-shop">
            <div className="shop-detail-container">
              <div className="shop-detail-content">
                <div className="shop-logo">
                  <Link to={`/shop/${product?.shops?.[0]?.shop_id}`}>
                    <img
                      src={product?.shops?.[0]?.image_url || placeholderImage}
                      alt="Shop Logo"
                      className="rounded-circle"
                      style={{ width: '100px', height: '100px', cursor: 'pointer' }}
                    />
                  </Link>
                </div>

                <div className="shop-info">
                  <h5>{product?.shops?.[0]?.shopname}</h5>
                  <p className="mb-0">{product?.shops?.[0]?.province}</p>
                </div>
                <div className="shop-buttons">
                  <Link to={`/shop/${product?.shops?.[0]?.shop_id}`}>
                    <Button style={{
                      color: hoveredProductId === product?.shops?.[0]?.shop_id ? "#ffffff" : "#2b70e0",
                      border: `2px solid ${hoveredProductId === product?.shops?.[0]?.shop_id ? "#2b70e0" : "#4a90e2"}`,
                      backgroundColor: hoveredProductId === product?.shops?.[0]?.shop_id ? "#2b70e0" : "transparent",
                    }}
                      onMouseEnter={() => setHoveredProductId(product?.shops?.[0]?.shop_id)} // เมื่อเมาส์เข้า
                      onMouseLeave={() => setHoveredProductId(null)}>
                      View Shop</Button> </Link>
                </div>
              </div>
            </div>
          </div>


          <div class="detail-main">
            <h2>ข้อมูลจำเพาะของสินค้า</h2>
          </div>
          <div class="detail-border">
            <div class="detail-info">
              {product.options && product.options.map((option, index) => (
                <p key={index}>
                  <strong>{option.name}:</strong> {Array.isArray(option.values) ? option.values.join(', ') : option.values || 'ข้อมูลไม่ระบุ'}
                </p>
              ))}
            </div>
          </div>
          <div class="detail-main">
            <h2>รายละเอียดสินค้า</h2>
          </div>
          <div class="detail-border">
            <div class="detail-info">
              <p>{product.description}</p>
            </div>
          </div>
        </div>
      </section>
      <Footer />
    </div>
  );
};

export default DIYdetail;