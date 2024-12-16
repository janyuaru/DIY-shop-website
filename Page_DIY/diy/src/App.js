import React from 'react';
import { Route, BrowserRouter as Router, Routes } from 'react-router-dom';
import Home from './pages/Home';
import DIYdetail from './pages/DIYdetail';
import Shop from './pages/Shop';
import ProdShop from './pages/productsh';
import Searchdetail from './pages/searchdetail';
import Prodbycategory from './pages/Prodbycategory';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/product/detail/:productId" element={<DIYdetail/>} />
        <Route path="/shop/:shopId" element={<Shop />} />
        <Route path="/prodshop" element={<ProdShop/>} />
        <Route path="/search" element={<Searchdetail/>} />
        <Route path="/categories/:categoryId" element={<Prodbycategory />} />
      </Routes>
    </Router>
  );
}

export default App;
