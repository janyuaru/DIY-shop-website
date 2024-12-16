import React from 'react';
import CarouselSlide from '../components/CarouselSlide';
import FeaturedProducts from '../components/FeaturedProducts';
import Footer from "../components/Footer";
import Header from "../components/Header";
import NewProducts from '../components/NewProducts';
import Products from '../components/Products';


const Home = () => {
  return (
    <div>
      <Header />
      <CarouselSlide />
      <FeaturedProducts />
      <NewProducts />
      <Products />
      <Footer />
    </div>
  );
};

export default Home;