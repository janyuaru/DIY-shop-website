import React, { useEffect, useState } from 'react';
import axios from 'axios';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import { useParams } from 'react-router-dom';
import "../components/Shop.css";
import "../components/ProductShop.css";
import ProductShop from "../components/ProductShop";
import Header from "../components/Header";
import Footer from '../components/Footer';


const Shop = () => {
  const { shopId } = useParams();
  const [products, setShop] = useState(null);
  const [error, setError] = useState(null);

  const placeholderImage = '../images/placeholder.jpg';

  const fetchShopData = (id) => {
    if (id) {
      axios
        .get(`/api/v1/products?shop_id=${id}`)
        .then((response) => {
          if (response.data.items) {
            console.log(response.data.items);
            setShop(response.data.items);
            setError(null);
          } else if (response.data.error) {
            setError(response.data.error);
            setShop(null);
          }
        })
        .catch((error) => {
          console.error('Error fetching the products:', error);
          setError('ไม่สามารถดึงข้อมูลร้านค้ามาได้');
          setShop(null);
        });
    } else {
      setShop([]);
    }

  };

  useEffect(() => {
    console.log('Shop ID:', shopId);
    fetchShopData(shopId);
  }, [shopId]);

  if (error) {
    return <div className="text-center">{error}</div>;
  }

  if (!products) {
    return <div className="text-center">กำลังโหลดข้อมูลร้านค้า...</div>;
  }

  console.log(products?.[0]?.shops?.[0]?.image_url);
  // console.log(products.shops?.[0].shopname);
  console.log(products?.items?.size || 0);

  return (

    <div>
      <Header />
      <div className="Container table-con">
        <div className="row bord-row">
          <div className="col bord-col logo-cont">
            <div className="logo-circle">
              <img
                src={products?.[0]?.shops?.[0]?.image_url || placeholderImage}
                alt={products?.[0]?.shops?.[0]?.shopname}
                className="logo shop"
              />
            </div>
            <div className="shop-info">
              <h5 className="shop-name">{products?.[0].shops?.[0].shopname}</h5>
              <p>{products?.[0].shops?.[0].province}</p>
            </div>

          </div>
          <div className="col bord-col">
            <div className="dtshop-th">
              <ul class="list-group">
                <li class="list-group-item"><i className="bi bi-telephone"></i> {products?.[0]?.shops?.[0]?.phone || 'Not provided'}</li>
                <li class="list-group-item"><i className="bi bi-envelope-heart"></i> {products?.[0]?.shops?.[0]?.email || 'Not provided'}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
      <div className="Container details-section">
        <p>{products?.[0]?.shops?.[0]?.description}</p>
      </div>
      <ProductShop products={products} />
      <Footer />
    </div>
  );
};


export default Shop;
