import React, { useState } from 'react';
import { FaSearch } from 'react-icons/fa'; // นำเข้าไอคอน FaSearch
import "../components/Sort.css";

const Sort = () => {
    const [searchTerm, setSearchTerm] = useState('');
    const [orderButtonHover, setOrderButtonHover] = useState(false);
    const [selectedOption, setSelectedOption] = useState('');

    const handleSearchSubmit = (e) => {
        e.preventDefault();
        console.log('Searching for:', searchTerm);
    };

    const handleOptionChange = (e) => {
        setSelectedOption(e.target.value);
    };

    return (
        <div>
            <div className="Container">
                <div className="table-shop">
                    <table>
                        <tr>
                            <th>เรียงสินค้าโดย</th>
                            <th className="col-shop">
                                <div className="btn-group">
                                    <form onSubmit={handleSearchSubmit} className="d-flex" style={{ width: "100%" }}>
                                    <select
                                            className="form-select"
                                            value={selectedOption}
                                            onChange={handleOptionChange}
                                            style={{
                                                marginLeft: "10px",
                                                padding: "6px 12px",
                                                borderColor: "#4a90e2",
                                                color: "#2b70e0"
                                            }}
                                        >
                                             <option value="" disabled hidden>ราคาสินค้า</option>
                                            <option value="option1">น้อยไปมาก</option>
                                            <option value="option2">มากไปน้อย</option>
                                        </select>
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
                                                color: orderButtonHover ? "#ffffff" : "#2b70e0",
                                                border: `2px solid ${orderButtonHover ? "#2b70e0" : "#4a90e2"}`,
                                                backgroundColor: orderButtonHover ? "#2b70e0" : "transparent",
                                                marginRight: "10px"
                                            }}
                                            onMouseEnter={() => setOrderButtonHover(true)}
                                            onMouseLeave={() => setOrderButtonHover(false)}
                                        >
                                            <FaSearch />
                                        </button>
                                      
                                    </form>
                                </div>
                            </th>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default Sort;
