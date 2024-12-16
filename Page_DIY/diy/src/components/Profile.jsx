import axios from 'axios';
import React, { useEffect, useState } from 'react';
import { Col, Container, Row } from 'react-bootstrap';

const Profile = () => {
  const [userProfile, setUserProfile] = useState(null); // เก็บข้อมูลผู้ใช้
  const [error, setError] = useState(null); // เก็บข้อผิดพลาด (ถ้ามี)

  useEffect(() => {
    const fetchUserProfile = async () => {
      try {
        const accessToken = sessionStorage.getItem('accessToken'); // ดึง access token จาก sessionStorage

        if (!accessToken) {
          console.error('No access token found.');
          return;
        }

        console.log('Access token:', accessToken); // ตรวจสอบว่าดึง access token มาถูกต้องไหม

        const response = await axios.get('http://localhost:8086/api/v1/users/me', {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
          withCredentials: true, // ส่ง cookies ไปด้วย
        });

        console.log('API Response:', response.data); // ตรวจสอบ response จาก API
        setUserProfile(response.data);
      } catch (error) {
        console.error('Error fetching profile:', error);
        setError('Failed to fetch profile'); // กำหนด error message
      }
    };

    fetchUserProfile(); // เรียกใช้ฟังก์ชันเมื่อ component โหลด
  }, []);

  if (error) {
    return <div>{error}</div>; // แสดงข้อความ error ถ้ามี
  }

  if (!userProfile) {
    return <div>Loading...</div>; // แสดง Loading ระหว่างดึงข้อมูล
  }

  return (
    <Container className="my-5">
      <Row>
        <Col md={4}>
          <img src={userProfile.picture} alt="User profile" style={{ borderRadius: '50%', width: '100%' }} />
        </Col>
        <Col md={8}>
          <h2>{userProfile.name}</h2>
          <p>Email: {userProfile.email}</p>
        </Col>
      </Row>
    </Container>
  );
};

export default Profile;