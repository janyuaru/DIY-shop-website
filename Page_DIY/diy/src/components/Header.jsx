import React, { useState } from "react";
// import { Button, Dropdown, Modal } from 'react-bootstrap'; // เพิ่ม Dropdown จาก react-bootstrap
import { FaSearch } from "react-icons/fa";
import { Link, useNavigate } from "react-router-dom"; // ใช้ useNavigate สำหรับเปลี่ยนเส้นทาง
// import GoogleAuth from './GoogleAuth';

const Header = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const navigate = useNavigate();
  const [searchButtonHover, setSearchButtonHover] = useState(false); // State สำหรับปุ่มค้นหา
  // const [cartButtonHover, setCartButtonHover] = useState(false);
  // const [showLogin, setShowLogin] = useState(false)
  // const [user, setUser] = useState(null); // เก็บข้อมูลผู้ใช้
  // const [loginButtonHover, setLoginBottonHover] = useState(false);

  // ใช้ useEffect เพื่อตรวจสอบว่า sessionStorage มีข้อมูลผู้ใช้หรือไม่
  // useEffect(() => {
  //   const storedUser = sessionStorage.getItem('user');
  //   if (storedUser) {
  //     setUser(JSON.parse(storedUser)); // กำหนดข้อมูลผู้ใช้ใน state
  //   }
  // }, []); // ทำงานแค่ครั้งเดียวตอนที่ component ถูก mount

  // ฟังก์ชันสำหรับจัดการการค้นหา
  const handleSearchSubmit = (e) => {
    e.preventDefault();
    console.log("Search term:", searchTerm);
    navigate(`/search?q=${searchTerm}`);
  };

  // const handleShow = () => setShowLogin(true);
  // const handleClose = () => setShowLogin(false);

  // const handleLogout = () => {
  //   sessionStorage.removeItem('user');
  //   setUser(null); // รีเซ็ต state
  //   navigate('/'); // เปลี่ยนเส้นทางกลับไปที่หน้าหลัก
  // };

  return (
    <header style={{ backgroundColor: "#fff4b3" }}>
      <div className="d-flex flex-column align-items-start">
        <div className="d-flex w-100">
          <Link className="navbar-brand" to="/">
          <img
            src="/images/LOGO.png"
            alt="Logo"
            width="105"
            height="90"
            style={{ marginLeft: "25px", marginTop: "5px" }}
          />
          </Link>

          <div className="headNav mt-3 mx-4 w-100">
            <div className="search w-100 d-flex align-items-center">
              <form onSubmit={handleSearchSubmit} className="d-flex" style={{ width: "100%" }}>
                <input
                  className="form-control me-2 w-100"
                  type="search"
                  placeholder="ค้นหาสินค้า"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  aria-label="Search"
                  style={{ flexGrow: 1, marginLeft: "10px" }}
                />
                <button
                  className="btn"
                  type="submit"
                  style={{
                    color: searchButtonHover ? "#ffffff" : "#2b70e0",
                    border: `2px solid ${searchButtonHover ? "#2b70e0" : "#4a90e2"}`,
                    backgroundColor: searchButtonHover ? "#2b70e0" : "transparent",
                  }}
                  onMouseEnter={() => setSearchButtonHover(true)} // เมื่อเมาส์เข้า
                  onMouseLeave={() => setSearchButtonHover(false)} // เมื่อเมาส์ออก
                >
                  <FaSearch />
                </button>
              </form>

              
              {/* <Link
                className="btn ms-2"
                to="/cart"
                style={{
                  color: cartButtonHover ? "#ffffff" : "#2b70e0",
                  border: `2px solid ${cartButtonHover ? "#2b70e0" : "#4a90e2"}`,
                  backgroundColor: cartButtonHover ? "#2b70e0" : "transparent",
                }}
                onMouseEnter={() => setCartButtonHover(true)} // เมื่อเมาส์เข้า
                onMouseLeave={() => setCartButtonHover(false)} // เมื่อเมาส์ออก
              >
                <FaShoppingCart /> <span className="badge bg-danger">2</span>
              </Link>

              {user ? (
                <Dropdown>
                  <Dropdown.Toggle variant="light" id="dropdown-basic" className="d-flex align-items-center">
                    <img
                      src={user.picture} // รูปภาพจาก Google
                      alt="user-profile"
                      style={{ borderRadius: '50%', width: '40px' }}
                      referrerPolicy="no-referrer"
                    />
                  </Dropdown.Toggle>

                  <Dropdown.Menu>
                    <Dropdown.Item as={Link} to="/profile">My Profile</Dropdown.Item>
                    <Dropdown.Item onClick={handleLogout}>Logout</Dropdown.Item>
                  </Dropdown.Menu>
                </Dropdown>
              ) : (
                <Button
                  className="ms-2"
                  onClick={handleShow}
                  style={{
                    color: loginButtonHover ? "#ffffff" : "#2b70e0",
                    border: `2px solid ${loginButtonHover ? "#2b70e0" : "#4a90e2"}`,
                    backgroundColor: loginButtonHover ? "#2b70e0" : "transparent",
                  }}
                  onMouseEnter={() => setLoginBottonHover(true)} // เมื่อเมาส์เข้า
                  onMouseLeave={() => setLoginBottonHover(false)} // เมื่อเมาส์ออก
                >
                  <FaUser /> เข้าสู่ระบบ
                </Button>
              )}

              {/* Modal สำหรับเข้าสู่ระบบ */}
              {/* <Modal show={showLogin} onHide={handleClose} centered>
                <Modal.Header closeButton>
                  <Modal.Title>เข้าสู่ระบบ</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                  <GoogleAuth
                    setUser={(user) => {
                      setUser(user);
                      sessionStorage.setItem('user', JSON.stringify(user)); // เก็บข้อมูลผู้ใช้ใน sessionStorage
                    }}
                    handleClose={handleClose}
                  />
                </Modal.Body>
              </Modal> */} 
            </div>

            <nav className="navbar navbar-expand-lg">
              <div className="container-fluid">
                <div className="collapse navbar-collapse" id="navbarSupportedContent">
                  <ul className="nav nav-underline">
                  <li className="nav-item">
                      <Link className="nav-link" to={`/`} style={{ color: "#2b70e0", fontSize: "15px" }}>หน้าหลัก</Link>
                    </li>
                    <li className="nav-item">
                      <Link className="nav-link" to={`/categories/1`} style={{ color: "#2b70e0", fontSize: "15px" }}>เครื่องประดับ</Link>
                    </li>
                    <li className="nav-item">
                      <Link className="nav-link" to={`/categories/2`} style={{ color: "#2b70e0", fontSize: "15px" }}>กำไล</Link>
                    </li>
                    <li className="nav-item">
                      <Link className="nav-link" to={`/categories/4`} style={{ color: "#2b70e0", fontSize: "15px" }}>กระเป๋า</Link>
                    </li>
                    <li className="nav-item">
                      <Link className="nav-link" to={`/categories/5`} style={{ color: "#2b70e0", fontSize: "15px" }}>พวงกุญแจ</Link>
                    </li>
                    <li className="nav-item">
                      <Link className="nav-link" to={`/categories/8`} style={{ color: "#2b70e0", fontSize: "15px" }}>สร้อยข้อมือ</Link>
                    </li>
                    <li className="nav-item">
                      <Link className="nav-link" to={`/categories/9`} style={{ color: "#2b70e0", fontSize: "15px" }}>หมวก</Link>
                    </li>
                    <li className="nav-item">
                      <Link className="nav-link" to={`/categories/10`} style={{ color: "#2b70e0", fontSize: "15px" }}>จี้และเครื่องประดับเสริม</Link>
                    </li>

                  </ul>
                </div>
              </div>
            </nav>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
