import React from 'react';
import { Container } from 'react-bootstrap';

const Footer = () => {
  return (
    <footer className="py-4" style={{background:"#fff4b3"}}>
      <Container className="text-center" style={{background:"#fff4b3", color:"#737373"}}>
        <p className="mb-0">© 2024 by Do It Yourself.</p>
      </Container>
    </footer>
  );
};

export default Footer;