import React, { useState } from 'react';
import "../components/Sort.css";

const Sort = ({ onSortChange }) => {
    const [selectedOption, setSelectedOption] = useState('option1');

    const handleOptionChange = (e) => {
        const value = e.target.value;
        setSelectedOption(e.target.value);
        onSortChange(value);
    };

    return (
        <div className="container">
            <div className="table-shop">
                <table>
                    <tr>
                        <th className="sort-label">
                            เรียงตามราคาสินค้า
                            <select
                                className="form-select"
                                value={selectedOption}
                                onChange={handleOptionChange}
                            >
                                <option value="" disabled hidden>ราคาสินค้า</option>
                                <option value="option1">น้อยไปมาก</option>
                                <option value="option2">มากไปน้อย</option>
                            </select>
                        </th>

                    </tr>
                </table>
            </div>
        </div>
    );
};

export default Sort;
