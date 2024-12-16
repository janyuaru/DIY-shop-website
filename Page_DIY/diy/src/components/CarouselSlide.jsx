import { useEffect, useState } from 'react'; 
import axios from 'axios';
import React from 'react';
import { Carousel } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';

const image_api = '/api/v1/products';

const CarouselSlide = () => {

  const [images, setImages] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    axios.get(image_api)
      .then((response) => {
        const fetchedImages = response.data.items || [];
        fetchedImages.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        setImages(fetchedImages.slice(0, 5));
        setLoading(false);
      })
      .catch((error) => {
        console.error('Error fetching the image:', error);
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading...</p>;
  if (!images || images.length === 0) return <p>No images to display</p>;

  const handleImageClick = (productId) => {
    navigate(`/product/detail/${productId}`); // ใช้ navigate เพื่อเปลี่ยนหน้า
  };

  return (
    <div style={{ maxWidth: '700px', margin: 'auto' }}>
      <Carousel>
        {images.map((image, index) => (
          <Carousel.Item key = {index} style={{ height: '280px' }}>
          <img
            className="d-block w-100"
            src={image.images.find((img) => img.is_primary)?.image_url}
            alt={`Slide ${index + 1}`}
            style={{
              objectFit: 'cover', // หรือ 'contain' หากต้องการให้ภาพคงสัดส่วน
              objectPosition: 'center',
              height: '280px',
              width: '700px',
            }}
            onClick={() => handleImageClick(image.id)}
          />
          <Carousel.Caption>
          </Carousel.Caption>
        </Carousel.Item>
        ))}
      </Carousel>
    </div>
  );
};

export default CarouselSlide;
