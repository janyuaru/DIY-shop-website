CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL NOT NULL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS shops (
    shop_id VARCHAR(255) NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    address VARCHAR(255),
    province VARCHAR(255),
    zipcode VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    contact_info TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE product_type AS ENUM ('components', 'handmades');

CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(255) NOT NULL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    shop_id VARCHAR(255) NOT NULL,
    category_id INTEGER NOT NULL,
    product_type product_type NOT NULL, -- materials, handmades
    is_featured BOOLEAN DEFAULT FALSE,
    sku VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(shop_id) REFERENCES shops(shop_id) ON DELETE CASCADE,
    FOREIGN KEY(category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS components (
	component_id VARCHAR(255) NOT NULL PRIMARY KEY,
	product_id VARCHAR(255) NOT NULL,
	material VARCHAR(255), -- เช่น 'อะคริลิค' ,'โลหะผสม', 'แก้ว', 'เพชรเทียม', 'พลาสติก ABS', 'ไหมพรม', 'เรซิน', 'เชือกเทียน'
	piece_of_package INTEGER NOT NULL CHECK (piece_of_package > 0),
	FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS handmades (
	handmade_id VARCHAR(255) NOT NULL PRIMARY KEY,
	product_id VARCHAR(255) NOT NULL,
    material VARCHAR(255),
	style VARCHAR(255), -- เช่น 'กำไลเชือก', 'หมวกไหมพรม', 'กระเป๋าไหมพรม', 'กระเป๋าผ้า', 'กำไลหิน', 'สร้อยคอลูกปัด', 'พวงกุญแจถักไหมพรม'
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE product_options (
    option_id VARCHAR(255) NOT NULL PRIMARY KEY,
    product_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    values TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS inventory (
    product_id VARCHAR(255) NOT NULL PRIMARY KEY,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');

CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    google_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    profile_picture_url VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    status user_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carts (
    cart_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    added_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(255) DEFAULT 'active',
    total_price NUMERIC(10, 2) NOT NULL CHECK (total_price >= 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS product_images (
    image_id VARCHAR(255) NOT NULL PRIMARY KEY,
    product_id VARCHAR(255) NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    uploaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER update_shops_modtime
BEFORE UPDATE ON shops
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_products_modtime
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_product_options_modtime
BEFORE UPDATE ON product_options
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_users_modtime
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_product_images_modtime
BEFORE UPDATE ON product_images
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_inventory_modtime
BEFORE UPDATE ON inventory
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE INDEX idx_shops_name ON shops(name);

-- Insert sample data into the categories table
INSERT INTO categories (category_name, description)
VALUES
    ('เครื่องประดับ', 'เครื่องประดับที่สวมใส่ได้'), -- 1
    ('กำไล', 'เครื่องประดับที่สวมใส่ที่ข้อมือ'),   -- 2
    ('สร้อยคอ', 'เครื่องประดับที่สวมใส่ที่คอ'),  -- 3
    ('กระเป๋า', 'ผลิตภัณฑ์ที่ใช้สำหรับใส่ของส่วนตัว'),  --4
    ('พวงกุญแจ', 'ของประดับที่ใช้แขวนกับกุญแจ'),   --5
    ('ของที่ระลึก', 'สินค้าที่มอบให้เป็นของขวัญหรือระลึกถึงสถานที่หรือเหตุการณ์ต่างๆ'),    --6
    ('กระเป๋าสตางค์', 'ผลิตภัณฑ์ที่ใช้สำหรับใส่เงินและบัตรต่างๆ'),    --7
    ('สร้อยข้อมือ', 'เครื่องประดับที่สวมใส่ที่ข้อมือ'),  --8
    ('หมวก', 'ผลิตภัณฑ์ที่ใช้สำหรับปิดหัว'),  --9
    ('จี้และเครื่องประดับเสริม', 'เครื่องประดับชิ้นเล็กๆ หรือชิ้นส่วนเสริม');    --10


INSERT INTO shops (shop_id, name, description, address, province, zipcode, phone, email, contact_info, image_url)
VALUES 
    ('d1eebc999c0b4ef8bb6d6bb9bd380a44', 'YongForYou Official Store', 'ร้านขายเครื่องประดับและวัสดุเครื่องประดับ เส้นเชือก จี้ ลูกปัดหินธรรมชาติ สร้อยคอ เครื่องประดับพื้นฐาน', '123 ซอยงานฝีมือ ถนนพัฒนาการ', 'กรุงเทพมหานคร', '10250', '02-123-4567', 'yongforyou@example.com', 'Facebook: YongForYou Official Store', 'https://down-aka-th.img.susercontent.com/ce179ffdb297d3103251f6985ee16e66_tn.webp'),
    ('e2eebc999c0b4ef8bb6d6bb9bd380a55', 'Moon Official', 'ขายสินค้างานไหมพรม กระเป๋าถัก หมวกถัก น่ารักสไตล์มินิมอล งานแฮนด์เมด 100%', '456 ถนนลาดพร้าว แขวงจอมพล เขตจตุจักร', 'กรุงเทพมหานคร', '10900', '02-765-4321', 'moon@example.com', 'Line: MoonOfficial', 'https://down-aka-th.img.susercontent.com/th-11134233-7r992-lxvaqzt5rjdb92_tn.webp'),
    ('f3eebc999c0b4ef8bb6d6bb9bd380a66', 'STITCHERY BOOM', 'ร้านขายพวกกุญแจไหมพรม เคสยาดม ตามลายต่างๆ น่ารักตุ๊มุ ทางร้านถักเองทุกชิ้น', '789 ซอยทองหล่อ 15 ถนนสุขุมวิท 55', 'กรุงเทพมหานคร', '10110', '02-321-0987', 'stitchery@example.com', 'Instagram: Stitchery.Boom', 'https://down-aka-th.img.susercontent.com/th-11134233-7ras9-m0kdbq189rrs60_tn.webp'),
    ('g4eebc999c0b4ef8bb6d6bb9bd380a77', 'Mutelu cnx', 'ร้านขายกำไลข้อมือเชือกถัก งานแฮนด์เมดทุกชิ้น ทำมือและออกแบบเอง ใช้เวลาทำประมาณ 3-5 วัน', '321 ถนนสุขุมวิท 71 แขวงพระโขนงเหนือ เขตวัฒนา', 'กรุงเทพมหานคร', '10110', '02-987-6543', 'Mutelucnx@example.com', 'Facebook: Mutelu cnx', 'https://down-aka-th.img.susercontent.com/th-11134233-7r98o-ll0qt65blfxo50_tn.webp'),
    ('h5eebc999c0b4ef8bb6d6bb9bd380a88', 'MOMSIRI CROCHET', 'ร้านถักไหมพรม หมวก เสื้อ เครื่องประดับ กระเป้า งาน handmade 300%', '654 ถนนราชดำริ แขวงลุมพินี เขตปทุมวัน', 'กรุงเทพมหานคร', '10330', '02-543-2167', 'momsiricrochet@example.com', 'Line: momsiricrochet', 'https://down-aka-th.img.susercontent.com/th-11134216-7r98v-lydhbyrcfusp47_tn.webp');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES 
    ('550e8400e29b41d4a716446655440003', 'CROCHET CAT BUCKET HAT หมวกไหมพรม', 'CROCHET CAT BUCKET HAT หมวกบัคเกตหูแมว ขนาด Freesize 22-26 นิ้ว/สูง 7-8 นิ้ว น้อนน่ารักแบบตะโกนนนน ใส่ได้ทั้งผู้หญิงและผู้ชาย', 890, 'h5eebc999c0b4ef8bb6d6bb9bd380a88', 9, 'handmades', FALSE, 'POD004'),
    ('550e8400e29b41d4a716446655440014', 'กระเป๋าสะพาย ถักเชือกฟอก สีม่วง', 'กระเป๋า ถักเชือกฟอก น่ารักกุ๊กกิ๊ก (งาน Handmade 100%) จ้า ตัดรอบ 23:59 น. จัดส่งวันถัดไปค่ะ', 130, 'e2eebc999c0b4ef8bb6d6bb9bd380a55', 4, 'handmades', FALSE, 'POD015'),
    ('550e8400e29b41d4a716446655440005', 'ลูกปัดหินเทียม อะคริลิค สําหรับทําสร้อยคอ สร้อยข้อมือ DIY', 'ลูกปัดหินเทียม จำนวน 50 ชิ้น/เซ็ต ขนาด 6 มม. วัสดุ อคริลิค เหมาะสำหรับทำสร้อยข้อมือ ข้อเท้า', 10, 'd1eebc999c0b4ef8bb6d6bb9bd380a44', 10, 'components', FALSE, 'POD006'),
    ('550e8400e29b41d4a716446655440016', 'เคสยาดมไหมพรม หงษ์ไทย ลายมอนสเตอร์', 'เคสยาดมไหมพรม Handmade (ภาพถ่ายจากสินค้าจริง) เคสยาดมแก๊งมอนสเตอร์อิ้ง ลายไมค์ ขนาด 25 กรัม (กว้าง 3.9 cm. * สูง 5.6 cm.)', 119, 'f3eebc999c0b4ef8bb6d6bb9bd380a66', 1, 'handmades', FALSE, 'POD017'),
    ('550e8400e29b41d4a716446655440018', 'พวงกุญแจกระเป๋านุบนิบ ห้อยกระเป๋า | MINI CHUBBY BAG', 'MINI CHUBBY BAG | พวงกุญแจกระเป๋านุบนิบ งาน Handmade Crochet ระเบิดความน่ารักกับมินิกระเป๋า สำหรับห้อยกระเป๋าหรือใส่เหรียญ น้องขนาดจิ๋วแต่น่ารักเท่าโลกเลย สี pineapple ขนาด 7*7 cm.', 69, 'f3eebc999c0b4ef8bb6d6bb9bd380a66', 5, 'handmades', FALSE, 'POD019');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES 
    ('550e8400e29b41d4a716446655440019', 'เคสยาดมไหมพรม หงษ์ไทย ลายการ์ตูนนุบนิบ', 'เคสยาดมไหมพรม Handmade (ภาพถ่ายจากสินค้าจริง) เคสยาดมยาดมไหมพรม ลายการ์ตูนน่ารัก ขนาด 25 กรัม (กว้าง 3.9 cm. * สูง 5.6 cm.)', 119, 'f3eebc999c0b4ef8bb6d6bb9bd380a66', 1, 'handmades', FALSE, 'POD020'),
    ('550e8400e29b41d4a716446655440009', 'ชิ้นสร้อยคอโลหะผสมจี้ง่ายโซ่ DIY', 'สร้อยคอโซ่โลหะผสม ขนาด 48 cm. ใช้ทำ DIY สร้อยคอ สำหรับผู้ชายและผู้หญิง', 8, 'd1eebc999c0b4ef8bb6d6bb9bd380a44', 10, 'components', FALSE, 'POD010'),
    ('550e8400e29b41d4a716446655440017', 'พวงกุญแจไหมพรม น้อนบล็อกโคลี่', 'พวงกุญแจไหมพรม น้อนบล็อกโคลี่ สีเขียว ทำจากไหมสังเคราะห์', 79, 'f3eebc999c0b4ef8bb6d6bb9bd380a66', 5, 'handmades', FALSE, 'POD018'),
    ('550e8400e29b41d4a716446655440023', 'กำไลข้อมือมุกน้ำจืด อะไหล่สแตนเลส จี้ดอกไม้ถัก', 'กำไลข้อมือมุกน้ำจืดทั้งเส้น ห้อยจี้ดอกไม้ถัก อะไหล่สแตนเลสโดนน้ำได้ ความยาว 15cm.', 300, 'g4eebc999c0b4ef8bb6d6bb9bd380a77', 2, 'handmades', FALSE, 'POD024'),
    ('550e8400e29b41d4a716446655440020', 'กำไลข้อมือเชือกเทียนถัก handmade (ข้างกาย)', 'กำไลข้อมืองานเชือกเทียนถัก ธีมข้างกาย วัสดุ เชือกเทียน หิน ลูกปัด ความยาว freesize (15-25cm.) ปรับรูดได้', 150,  'g4eebc999c0b4ef8bb6d6bb9bd380a77', 2, 'handmades', TRUE, 'POD021');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES 
    ('550e8400e29b41d4a716446655440010', 'กระเป๋าถักไหมพรม รูปอมยิ้ม', 'กระเป๋าใส่เงินถักไหมพรม (งาน Handmade 100%) จ้า ตัดรอบ 23:59 น. จัดส่งวันถัดไปค่ะ', 79, 'e2eebc999c0b4ef8bb6d6bb9bd380a55', 7, 'handmades', FALSE, 'POD011'),
    ('550e8400e29b41d4a716446655440012', 'พวงกุญแจรถ ถักเชือกฟอก หมีน้อย', 'พวงกุญแจรถไหมพรม ลายหมี (งาน Handmade 100%) จ้า ตัดรอบ 23:59 น. จัดส่งวันถัดไปค่ะ', 79, 'e2eebc999c0b4ef8bb6d6bb9bd380a55', 5, 'handmades', TRUE, 'POD013'),
    ('550e8400e29b41d4a716446655440011', 'กิ๊บไหมพรมทานตะวัน', 'กิ๊บไหมพรม รูปทานตะวัน น่ารัก มินิมอล (งาน Handmade 100%) จ้า ตัดรอบ 23:59 น. จัดส่งวันถัดไปค่ะ', 49, 'e2eebc999c0b4ef8bb6d6bb9bd380a55', 1, 'handmades', FALSE, 'POD012'),
    ('550e8400e29b41d4a716446655440001', 'กระเป๋าไหมพรม CROCHET FLOWER FIELD BAG', 'CROCHET FLOWER FIELD BAG ขนาด 10*6.5 นิ้ว/สายยาว 50+นิ้ว ไม่รวมตัวกระเป๋า สายปรับความยาวได้ ใช้วัสดุไหมพรม ทำเป็นลายท้องฟ้า', 580, 'h5eebc999c0b4ef8bb6d6bb9bd380a88', 4, 'handmades', FALSE, 'POD002'),
    ('550e8400e29b41d4a716446655440006', 'สายพวงกุญแจ สายคล้องกุญแจรถ diy เครื่องประดับแฟชั่น', 'เชือกโพลิเอสเตอร์ จำนวน 20 ชิ้น/ถุง ปริมาณ 5 กรัม ขนาด 46 มม. เหมาะสำหรับ เชือกเส้นเล็กและสร้อยข้อมือแฮนด์เมด หมวด พวงกุญแจ', 20, 'd1eebc999c0b4ef8bb6d6bb9bd380a44', 10, 'components', FALSE, 'POD007');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES 
    ('550e8400e29b41d4a716446655440008', 'จี้ตัวอักษรสีขาว สําหรับทําเครื่องประดับ สร้อยคอ สร้อยข้อมือ DIY', 'จี้ตัวอักษรสีขาว จำนวน 5 ชิ้น ขนาด 12*15 มม. ทำจากโลหะผสมคุณภาพสูงและฝีมือดี เหมาะสำหรับทำสร้อยคอ สร้อยข้อมือ กำไล', 4, 'd1eebc999c0b4ef8bb6d6bb9bd380a44', 10, 'components', FALSE, 'POD009'),
    ('550e8400e29b41d4a716446655440004', 'CROCHET CAT BEANIE หมวกไหมพรมหูแมว พร้อมส่ง', 'CROCHET CAT BEANIE รอบหัว 22-24 นิ้ว / สูง 7-8 นิ้ว ตัดรอบส่ง12:50', 580, 'h5eebc999c0b4ef8bb6d6bb9bd380a88', 9, 'handmades', FALSE, 'POD005'),
    ('550e8400e29b41d4a716446655440013', 'กระเป๋าใส่แก้ว ถักเชือกฟอก', 'กระเป๋าใส่แก้ว ถักเชือกฟอก (งาน Handmade 100%) จ้า ตัดรอบ 23:59 น. จัดส่งวันถัดไปค่ะ', 79, 'e2eebc999c0b4ef8bb6d6bb9bd380a55', 4, 'handmades', FALSE, 'POD014'),
    ('550e8400e29b41d4a716446655440021', 'กำไลข้อมือเชือกเทียนแบบพรีเมี่ยม handmade (Vanilla Sky)', 'กำไลช้อมือเทียนถัก วัสดุ เชือกเทียนโพลีเอสเทอร์พรีเมี่ยม ขนาด 15 cm. ปรับรูดได้ถึง 25cm.', 200, 'g4eebc999c0b4ef8bb6d6bb9bd380a77', 2, 'handmades', FALSE, 'POD022'),
    ('550e8400e29b41d4a716446655440022', 'กำไลข้อมือเชือกถัก handmade (Amethyst set)', 'ชุดเซ็ตกำไลข้อมือ กำไลข้อเท้า สร้อยคอ งานเชือกเทียนถัก Handmade 100%', 399, 'g4eebc999c0b4ef8bb6d6bb9bd380a77', 1, 'handmades', FALSE, 'POD023');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES
    ('550e8400e29b41d4a716446655440000', 'หมวกไหมพรมน้อนกระต่าย CROCHET BUNNY HAT', 'CROCHET BUNNY HAT หูกระต่ายถอดได้ รอบหัว 22-23 นิ้ว/สูง 8 นิ้ว ใช้วัสดุไหมพรม ขนแกะ Handmade 300%', 990, 'h5eebc999c0b4ef8bb6d6bb9bd380a88', 9, 'handmades', FALSE, 'POD001');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES
    ('550e8400e29b41d4a716446655440002', 'กิ๊ฟไหมพรม สุดคิ้วซึ', 'กิ๊ฟไหมพรม ลายน่ารัก ใบโคลเวอร์ ผีเสื้อ ขนาด 4-4.5 cm. เป็นงาน Handmade 300%', 29, 'h5eebc999c0b4ef8bb6d6bb9bd380a88', 1, 'handmades', TRUE, 'POD003');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES
    ('550e8400e29b41d4a716446655440024', 'กำไลข้อมือเชือกเทียนถัก handmade (Pastel sky)', 'กำไลข้อมือเทียนถัก สไตล์ลูกคุณหนู ความยาว 15 cm. ปรับรูดได้ถึง 25 cm.', 200, 'g4eebc999c0b4ef8bb6d6bb9bd380a77', 2, 'handmades', FALSE, 'POD025');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES
    ('550e8400e29b41d4a716446655440015', 'พวงกุญแจผีน้อยนุบนิบ Halloween Party | Baby Boo', 'Baby Boo Halloween Party | พวงกุญแจผีน้อยนุบนิบ น้อนเบบี้บูววววว | Baby Boo!! ใช้วัสดุ Cottom Milk ขนาด 5*5 cm.', 69, 'f3eebc999c0b4ef8bb6d6bb9bd380a66', 5, 'handmades', FALSE, 'POD016');

INSERT INTO products (product_id, product_name, description, price, shop_id, category_id, product_type, is_featured, sku)
VALUES
    ('550e8400e29b41d4a716446655440007', 'สร้อยข้อมือลูกปัด DIY กล่องของขวัญของขวัญของขวัญคริสต์มาสวันเกิด', 'สินค้า DIY ทำเอง สำหรับทำสร้อยข้อมือลูกปัด ประกอบไปด้วยจี้หินในธีมคริสต์มาสวันเกิด และเชือกร้อย เหมาะสำหรับเป็นของขวัญให้คนรู้ใจได้', 183, 'd1eebc999c0b4ef8bb6d6bb9bd380a44', 8, 'handmades', TRUE, 'POD008');

INSERT INTO inventory (product_id, quantity)
VALUES 
    -- MOMSIRI CROCHET
    ('550e8400e29b41d4a716446655440000', 6),
    ('550e8400e29b41d4a716446655440001', 10),
    ('550e8400e29b41d4a716446655440002', 15),
    ('550e8400e29b41d4a716446655440003', 3),
    ('550e8400e29b41d4a716446655440004', 5);

INSERT INTO inventory (product_id, quantity)
VALUES 
    -- ร้าน  YongForYou Official Store
    ('550e8400e29b41d4a716446655440005', 6),
    ('550e8400e29b41d4a716446655440006', 10),
    ('550e8400e29b41d4a716446655440007', 15),
    ('550e8400e29b41d4a716446655440008', 3),
    ('550e8400e29b41d4a716446655440009', 5);

INSERT INTO inventory (product_id, quantity)
VALUES 
    -- Moon Official
    ('550e8400e29b41d4a716446655440010', 6),
    ('550e8400e29b41d4a716446655440011', 10),
    ('550e8400e29b41d4a716446655440012', 15),
    ('550e8400e29b41d4a716446655440013', 3),
    ('550e8400e29b41d4a716446655440014', 5);

INSERT INTO inventory (product_id, quantity)
VALUES 
    -- STITCHERY BOOM
    ('550e8400e29b41d4a716446655440015', 6),
    ('550e8400e29b41d4a716446655440016', 10),
    ('550e8400e29b41d4a716446655440017', 15),
    ('550e8400e29b41d4a716446655440018', 3),
    ('550e8400e29b41d4a716446655440019', 5);

INSERT INTO inventory (product_id, quantity)
VALUES 
    -- Mutelu cnx
    ('550e8400e29b41d4a716446655440020', 6),
    ('550e8400e29b41d4a716446655440021', 10),
    ('550e8400e29b41d4a716446655440022', 15),
    ('550e8400e29b41d4a716446655440023', 3),
    ('550e8400e29b41d4a716446655440024', 5);

INSERT INTO product_images (image_id, product_id, image_url, alt_text, is_primary, sort_order)
VALUES 
    ('4abf350794394f74a447ffdd16a8c84b', '550e8400e29b41d4a716446655440000', 'https://down-th.img.susercontent.com/file/th-11134207-7rasb-m1r84xaeox6f90.webp', 'หมวกไหมพรมน้อนกระต่าย', TRUE, 1),
    ('9424a92d6ba14b38bba21a5e390ed136', '550e8400e29b41d4a716446655440001', 'https://down-th.img.susercontent.com/file/th-11134207-7r98u-lyqbaf9slcbt17.webp', 'กระเป๋าไหมพรม', TRUE, 1),
    ('3990392ad2564a7cbef339c58b523c7b', '550e8400e29b41d4a716446655440002', 'https://down-th.img.susercontent.com/file/th-11134207-7rasg-m11iioy6hhd40e.webp', 'กิ๊ฟไหมพรม', TRUE, 1),
    ('0249a676c5fe4e47af2b7c82b9a6d754', '550e8400e29b41d4a716446655440003', 'https://down-th.img.susercontent.com/file/th-11134207-7r98u-lydji82vpls151.webp', 'หมวกไหมพรมสีชมพูขาว', TRUE, 1),
    ('5450a7ada0b84e77be3663628f0f36a6', '550e8400e29b41d4a716446655440004', 'https://down-th.img.susercontent.com/file/th-11134207-7rash-m25f8ce51lup03.webp', 'หมวกไหมพรมหูแมว', TRUE, 1),

    ('1f0852000ca44addb16fe109e6c1c74d', '550e8400e29b41d4a716446655440005', 'https://down-th.img.susercontent.com/file/2a7afcdf39756c47c6a13bfc0004d7cf.webp', 'ลูกปัดหินเทียมสีเขียวทะเลสาบ', TRUE, 1),
    ('463921ca25ca446a9708dc10018c919a', '550e8400e29b41d4a716446655440006', 'https://down-th.img.susercontent.com/file/cn-11134207-7r98o-lolyux6xnntmc9.webp', 'สายพวงกุญแจสีกาแฟ', TRUE, 1),
    ('38ddd0a91fa641769cd720eca725d28d', '550e8400e29b41d4a716446655440007', 'https://down-th.img.susercontent.com/file/sg-11134201-22110-cig1emp4kejve8.webp', 'สร้อยข้อมือลูกปัดสีแดง', TRUE, 1),
    ('03dc78a7d62e4cc894097d4b6d06c69b', '550e8400e29b41d4a716446655440008', 'https://down-th.img.susercontent.com/file/21f164f435134dab42ed2fea6f767c3d.webp', 'จี้ตัวอักษรภาษาอังกฤษสีขาว', TRUE, 1),
    ('41d54c2789e74168bc04ef66571a2dc6', '550e8400e29b41d4a716446655440009', 'https://down-th.img.susercontent.com/file/sg-11134201-22110-mn5rcm12scjv75.webp', 'สร้อยคอโลหะผสม', TRUE, 1),

    ('690e10d1f8a74ccda48e918ec5c9a48c', '550e8400e29b41d4a716446655440010', 'https://down-th.img.susercontent.com/file/th-11134207-7rasi-m1oalaz6ut7t2f.webp', 'กะรเป๋าถักไหมพรมรูปอมยิ้ม', TRUE, 1),
    ('58e7ac30010c4d499ce187878e22ca5e', '550e8400e29b41d4a716446655440011', 'https://down-th.img.susercontent.com/file/th-11134207-7r98x-lzw131mlnq95e5.webp', 'กิ๊บไหมพรมรูปทานตะวัน', TRUE, 1),
    ('52fdde32690a488aa913e79067692628', '550e8400e29b41d4a716446655440012', 'https://down-th.img.susercontent.com/file/th-11134207-7rasl-m1u2njp4lu5zbd.webp', 'พวงกุญแจรถรูปหมีน้อย', TRUE, 1),
    ('29696f10474149e8b95c51ae4d847bca', '550e8400e29b41d4a716446655440013', 'https://down-th.img.susercontent.com/file/th-11134207-7r98z-lyugh469qow1aa.webp', 'กระเป๋าใส่แก้วเยติ', TRUE, 1),
    ('5850b86c64ea4ec0b7950b675fb259ea', '550e8400e29b41d4a716446655440014', 'https://down-th.img.susercontent.com/file/th-11134207-7r98t-lyugs35rq6bl7c.webp', 'กระเป๋าสะพายสีม่วง', TRUE, 1),

    ('c18ebc74b3d14a3793161c8caf3a1985', '550e8400e29b41d4a716446655440015', 'https://down-th.img.susercontent.com/file/th-11134207-7rasg-m1y6zdnlhk957f.webp', 'พวงกุญแจผีน้อย', TRUE, 1),
    ('3b224c3937a847b9b8a793d1c43b0c90', '550e8400e29b41d4a716446655440016', 'https://down-th.img.susercontent.com/file/th-11134207-7ras8-m1y61h37mzt56d.webp', 'เคสยาดมลายไมค์', TRUE, 1),
    ('974940480d61491dbe1d22791b84b2d1', '550e8400e29b41d4a716446655440017', 'https://down-th.img.susercontent.com/file/th-11134207-7r98q-lw2xncriqjm715.webp', 'พวงกุญแจน้อนบล็อกโคลี่', TRUE, 1),
    ('8c1aaaa118b345f2ba8ded4dbe9d0942', '550e8400e29b41d4a716446655440018', 'https://down-th.img.susercontent.com/file/th-11134207-7rash-m1y7n05svj6e3f.webp', 'พวงกุญแกห้อยกระเป๋าสีสับปะรด', TRUE, 1),
    ('de016e8256e34c9bb75c454804f074c0', '550e8400e29b41d4a716446655440019', 'https://down-th.img.susercontent.com/file/th-11134207-7rasd-m1y69wipls5ydf.webp', 'เคสยาดมลายการ์ตูน', TRUE, 1),

    ('ae5ba5e73fa249788e1af806b624f0dd', '550e8400e29b41d4a716446655440020', 'https://down-th.img.susercontent.com/file/th-11134207-7r98p-lun90lyvu2qd6f.webp', 'กำไลข้อมือเชือกเทียนถัก', TRUE, 1),
    ('72b70197632448e9bc84d82e8fdb50e3', '550e8400e29b41d4a716446655440021', 'https://down-th.img.susercontent.com/file/th-11134207-7r98t-lstnef5h3r2528.webp', 'กำไลข้อมือเชือกเทียนพรีเมี่ยม', TRUE, 1),
    ('98628105e9654bf0bc80445c7ed5dbff', '550e8400e29b41d4a716446655440022', 'https://down-th.img.susercontent.com/file/th-11134207-7r98v-lous9jrqfcjh29.webp', 'เซ็ตกำไลข้อมือเชือกเทียนถัก', TRUE, 1),
    ('519475a4526846d69ff7c7c4978d5a11', '550e8400e29b41d4a716446655440023', 'https://down-th.img.susercontent.com/file/th-11134207-7r98q-ls6suobewipp9a.webp', 'กำไลข้อมือมุกน้ำจืด', TRUE, 1),
    ('b73b45daafde43c7a493fa21d63eeaa7', '550e8400e29b41d4a716446655440024', 'https://down-th.img.susercontent.com/file/th-11134207-7r991-lviv0ndyb16i9d.webp', 'กำไลข้อมือเชือกเทียนถักสีพาสเทล', TRUE, 1);

INSERT INTO components (component_id, product_id, material, piece_of_package)
VALUES
    -- เช่น 'อะคริลิค' ,'โลหะผสม', 'แก้ว', 'เพชรเทียม', 'พลาสติก ABS', 'ไหมพรม', 'เรซิน', 'เชือกเทียน'
    ('2e718c93a2a541f0b03f27afec1d19d2', '550e8400e29b41d4a716446655440005', 'อะคริลิค', '50'),
    ('ca45f038ff8e4dc8b1c5e77c0a8d5699', '550e8400e29b41d4a716446655440006', 'เชือกเทียน', '20'),
    ('c8bbeb8fdfbe426cb85c07df80f4a238', '550e8400e29b41d4a716446655440008', 'โลหะผสม', '5'),
    ('60cfed7355e549c39ad7c91ab52fd0d1', '550e8400e29b41d4a716446655440009', 'โลหะผสม', '1');
    
INSERT INTO handmades (handmade_id, product_id, material, style)
VALUES
    -- เช่น 'อะคริลิค' ,'โลหะผสม', 'แก้ว', 'เพชรเทียม', 'Cotton Milk', 'ไหมพรม', 'เรซิน', 'เชือกเทียน', 'เชือกฟอก'
    -- เช่น 'กำไลเชือก', 'หมวกไหมพรม', 'กระเป๋าไหมพรม', 'กระเป๋าผ้า', 'กำไลหิน', 'สร้อยคอลูกปัด', 'พวงกุญแจถักไหมพรม'
    ('e321b3f3b3a440099dc1b56b7f171d1a', '550e8400e29b41d4a716446655440000', 'ไหมพรม', 'หมวกไหมพรม'),
    ('9dc5b930e5a74e3a991ae2e4b8a2b13b', '550e8400e29b41d4a716446655440001', 'ไหมพรม', 'กระเป๋าไหมพรม'),
    ('3a88c17b9d0d4111a2746e74cc648fbb', '550e8400e29b41d4a716446655440002', 'ไหมพรม', 'กิ๊บไหมพรม'),
    ('15a2b9adbdff4d45b23a0f441a50cbbb', '550e8400e29b41d4a716446655440003', 'ไหมพรม', 'หมวกไหมพรม'),
    ('53b6c0e5f8c347f49d87f2fb305b1e04', '550e8400e29b41d4a716446655440004', 'ไหมพรม', 'หมวกไหมพรม'),
    ('da4c905582f84fbb81b7d95cc50d7f5b', '550e8400e29b41d4a716446655440007', 'ลูกปัด', 'สร้อยคอมือลูกปัด'),
    ('21de54b0b11f4bb1bcf1f0a1f1f1a5cf', '550e8400e29b41d4a716446655440010', 'ไหมพรม', 'กระเป๋าไหมพรม'),
    ('7f6c43f4be1449b9a9b3d4a9f60d9727', '550e8400e29b41d4a716446655440011', 'ไหมพรม', 'กิ๊บไหมพรม'),
    ('c81e2eaf7b5e45edbd76b77117b53fcf', '550e8400e29b41d4a716446655440012', 'เชือกฟอก', 'พวงกุญแจถักเชือกฟอก'),
    ('89af90b6a2c94748b1db4e0b4b32ef88', '550e8400e29b41d4a716446655440013', 'เชือกฟอก', 'กระเป๋าแก้ว'),
    ('a8be836feefc4090ad45c8cbf4b89b62', '550e8400e29b41d4a716446655440014', 'เชือกฟอก', 'กระเป๋าสะพาย'),
    ('3067de76e0c543329c9c1f1a4fb0a1a3', '550e8400e29b41d4a716446655440015', 'Cotton Milk', 'พวงกุญแจถัก'),
    ('d6b0f3c76b9947bda50d3209a1be18d9', '550e8400e29b41d4a716446655440016', 'ไหมพรม', 'เคสยาดม'),
    ('4573bf4c7ad449bca99b143dba3fe6bb', '550e8400e29b41d4a716446655440017', 'ไหมพรม', 'พวงกุญแจถักไหมพรม'),
    ('12f5d748a3a34721b78d6d91c61ae6b1', '550e8400e29b41d4a716446655440018', 'Cotton Milk', 'พวงกุญแจถัก'),
    ('672fce5b3fb44e94abdc6e9a69d8a012', '550e8400e29b41d4a716446655440019', 'ไหมพรม', 'เคสยาดม'),
    ('2b9129a558094b3a8892a6f58d2e61c4', '550e8400e29b41d4a716446655440020', 'เชือกเทียน', 'กำไลหิน'),
    ('d68c5305a7854d46aab8d8c5bf64d857', '550e8400e29b41d4a716446655440021', 'เชือกเทียน', 'กำไลลูกปัด'),
    ('53fa0fcd8c714f31aefb5e5e1c8d7b59', '550e8400e29b41d4a716446655440022', 'เชือกเทียน', 'กำไลข้อมือ'),
    ('cfa97b8b526c46c5aeb4a3a8fbf9f2c2', '550e8400e29b41d4a716446655440023', 'ลูกปัด', 'กำไลลูกปัด'),
    ('fc2d6b2df3c244c9a5be6cbac7934e7a', '550e8400e29b41d4a716446655440024', 'เชือกเทียน', 'กำไลหิน');

INSERT INTO product_options (option_id, product_id, name, values)
VALUES
    ('1e9c96bc1d7f4907a1a0f0456a2f2b9f', '550e8400e29b41d4a716446655440000', 'ขนาด', '22-23 นิ้ว / สูง 8 นิ้ว'),
    ('f8a0d3e33a4f4fa3b1b0bc5b3c4f6e5c', '550e8400e29b41d4a716446655440000', 'ลาย', 'หูกระต่าย'),
    ('a4e317cf12d94e94b62fd35cdb6ea6d9', '550e8400e29b41d4a716446655440000', 'วัสดุ', 
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440000')),
    ('f2d8c5b7a3e4c9d1f6b8a2e3c7f1b4d9', '550e8400e29b41d4a716446655440000', 'สไตล์', 
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440000')),
    
    ('5c9de7c5bfb74a94b3d07b894d89f5f4', '550e8400e29b41d4a716446655440001', 'ขนาด', '10*6.5 นิ้ว'),
    ('93b12cf5e7d94431a915c8f1c7f6079e', '550e8400e29b41d4a716446655440001', 'ลาย', 'ท้องฟ้า'),
    ('c612e8b67f7b42e9b1a8f5d4e7cfaadb', '550e8400e29b41d4a716446655440001', 'วัสดุ', 
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440001')),
    ('7e9b3c2d5f4a8e1c6b7d3f9a2b5c4e8a', '550e8400e29b41d4a716446655440001', 'สไตล์', 
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440001')),

    ('d5a1c9b34cdb44b1ad9a5b3e1e6d4f8e', '550e8400e29b41d4a716446655440002', 'ขนาด', '4-4.5 cm.'),
    ('bca6f8e2d3a74e68a4d3f1c5b7d6e8a2', '550e8400e29b41d4a716446655440002', 'ลาย', 'ผีเสื้อสีม่วง'),
    ('6b3f9d2c5b7a41b58d6c9e2f3a1d7f6b', '550e8400e29b41d4a716446655440002', 'วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440002')),
    ('a5d9b3e2f7c4a1b6e8f9d3c7b2a8d1c6', '550e8400e29b41d4a716446655440002', 'สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440002')),
    
    ('f4a6b8e3c2d94f62b1a9d3c7f8e1b5a3', '550e8400e29b41d4a716446655440003', 'ขนาด', 'Freesize 22-26 นิ้ว / สูง 7-8 นิ้ว'),
    ('5d1c3b2e7f9a4e8b1d6c4a9f2e7b3a5f', '550e8400e29b41d4a716446655440003', 'ลาย', 'แมว'),
    ('a3b5d6f8c9e2e1b7f4a8b1c3d9e5a7c6', '550e8400e29b41d4a716446655440003', 'วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440003')),
    ('c1e4b9d8f3a7c6d5b2e1f4a9c3e7b5a2', '550e8400e29b41d4a716446655440003', 'สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440003')),
        
    ('f1c8e6b9d3a4b5f7a9c2d8e3f5b7c1d4','550e8400e29b41d4a716446655440004','ขนาด','22-24 นิ้ว / สูง 7-8 นิ้ว'),
    ('4b3a9d2e6f8b7c5a1d9f4c6e2a5b8f3d','550e8400e29b41d4a716446655440004','ลาย','แมว'),
    ('d2f5a1c7b9e4f6a3c9e8d7b2f1a6c3e9','550e8400e29b41d4a716446655440004','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440004')),
    ('f8d4b1a7e6c2b3f9d5a8c3e7b2f6a9d1','550e8400e29b41d4a716446655440004','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440004')),

    ('3c5f7d1e8a2b9c6f4d3a1e7b5c8f2a9e','550e8400e29b41d4a716446655440007','สี','แดง'),
    ('c9d6f1b4e3a7c8d2f5a9e1b7c3f6d4a5','550e8400e29b41d4a716446655440007','รูปแบบ','คริสต์มาส วันเกิด'),
    ('d3e1b8f5a7c2d9e4b3f6a1c7d5f2b9a8','550e8400e29b41d4a716446655440007','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440007')),
    ('a1f9c4e2b5d3a7c6f8d1b9a5e4f2b3c7','550e8400e29b41d4a716446655440007','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440007')),

    ('e8a3f1d6b9c5e7a4d3f2b1a9d8c2f5a6','550e8400e29b41d4a716446655440010','สี','ส้ม'),
    ('5f4b2d7c9e3a48f2b1d7c8a4e6f9d2a3','550e8400e29b41d4a716446655440010','ลาย','อมยิ้ม'),
    ('c7a4b1e6d8f5c2a9d3e7b9f1a3c5e2d4','550e8400e29b41d4a716446655440010','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440010')),
    ('f3e9a1d6b2c7f8a4d5b3e2c9f7a6d1b8','550e8400e29b41d4a716446655440010','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440010')),
    
    ('d9f2b7a1c4e6b5a3d8f1e3c9b2f5a7d6','550e8400e29b41d4a716446655440011','จำนวน','2 ชิ้น'),
    ('a1b6f9c3e8d5b2a4c7e1f2b3d9a6e4f5','550e8400e29b41d4a716446655440011','ลาย','ทานตะวัน'),
    ('e2f5a9c4b1d7e6f3b9c8a2d3f4b5a7c1','550e8400e29b41d4a716446655440011','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440011')),
    ('c3e9b7a5d4f8b1e6a2f3c7d9a5f4b2e1','550e8400e29b41d4a716446655440011','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440011')),

    ('d8a6f1b9c3e4a7d5f2b6e9c8a1f3d2b5','550e8400e29b41d4a716446655440012','สี','น้ำตาล'),
    ('b9f3c1a7e5d2b4f8a6d9e3c7a5f2d1e6','550e8400e29b41d4a716446655440012','ลาย','หมี'),
    ('a7d5e1f3b9c2d8a4b6f9c5a1e2f7b3d4','550e8400e29b41d4a716446655440012','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440012')),
    ('e4b3f7c1a9d5e2b8a6f3c9d1e7a5b2f6','550e8400e29b41d4a716446655440012','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440012')),

    ('f6a1c3d9e8b4f2a7d5e1c9b3a5d7f4e2','550e8400e29b41d4a716446655440013','สี','ชมพู'),
    ('c1a8e6f9b2d7c5a3f4e1b9d3a7c2f5b8','550e8400e29b41d4a716446655440013','ขนาด','รัศมี 14.5 cm. / สูง 21 cm.'),
    ('d4b7e3f2a6c9d1b5f8a3e7c1d9b2f6a4','550e8400e29b41d4a716446655440013','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440013')),
    ('b5a3e9d1c7f2a8b6e4f3d9c1a5b7e2f4','550e8400e29b41d4a716446655440013','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440013')),

    ('f9e4a1d7c2b8a5f3e6d9c4a7b1f2e8d3','550e8400e29b41d4a716446655440014','สี','ม่วง'),
    ('a6f1c8b3e7d9f4a2c5e1b9d6a3f8b2e5','550e8400e29b41d4a716446655440014','ขนาด','กว้าง 18 cm. / ยาว 22 cm.'),
    ('d5e1b4a9f7c3d8a2b6f1c9a5e7d3f4b8','550e8400e29b41d4a716446655440014','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440014')),
    ('c8f3b7a1e5d4a9c2f6e3b1d9a7f2c5e4','550e8400e29b41d4a716446655440014','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440014')),

    ('a4f5d8c1b3e9f7a2d6b5e1c3a9f4b7d2','550e8400e29b41d4a716446655440015','สี','ขาว'),
    ('e7c2a5b9f4d1e8a3c6f2b7d9a1e3f5b4','550e8400e29b41d4a716446655440015','ลาย','ผี Baby Boo Halloween'),
    ('a3e9b5f1d7c2a4e6b9f3d8a5f7c1d2b6','550e8400e29b41d4a716446655440015','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440015')),
    ('f1d5c3e8b7a2f4e9c6b1d3a7f5e2b9c4','550e8400e29b41d4a716446655440015','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440015')),

    ('e2f8a1c9b4d7e3f5a6c8d1b9f7a4e3d5','550e8400e29b41d4a716446655440016','สี','ฟ้า'),
    ('a9d1f4c7b3e5f8a6d2c9e1b7f5a3e8d6','550e8400e29b41d4a716446655440016','ลาย','แก๊งมอนสเตอร์ ไมค์'),
    ('b3f6d7a1e8c9b2d5f4a7c1e3f9b8d2a6','550e8400e29b41d4a716446655440016','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440016')),
    ('e4a5f3c9b1d7f8a6d2c5e9a3b7f1d6b4','550e8400e29b41d4a716446655440016','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440016')),

    ('c1a8f5b4e7d3a9c2f6e1d8b5a7f4e9c3','550e8400e29b41d4a716446655440017','สี','เขียว'),
    ('d9b2e6f3a5c1d8f7b4a2e5c9a3d6f1b7','550e8400e29b41d4a716446655440017','ลาย','บล็อกโคลี่'),
    ('a1f4c8d5e3b9a7f2c6e1d4b8f5a9c7d3','550e8400e29b41d4a716446655440017','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440017')),
    ('f6d3a5e9b1c4f8a7d2c5e1b9f3a6d8e2','550e8400e29b41d4a716446655440017','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440017')),

    ('b1a7e4f9c2d6a3f5b8e1d7c4a9f3d2e5','550e8400e29b41d4a716446655440018','สี','สับปะรด'),
    ('c9e5b1a8f7d3c2e9a4f6d1b3a7f8d5e4','550e8400e29b41d4a716446655440018','ขนาด','7*7 cm.'),
    ('a3f2d8b7e4c1a9f6d3b5e7a1f9c4d2e8','550e8400e29b41d4a716446655440018','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440018')),
    ('d4c3b9a5f8e1d6c2a9f7b4e3a8f5d1b7','550e8400e29b41d4a716446655440018','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440018')),

    ('e1b8f6a4c7d9e2f3b5a1d4f9c6a7e3b2','550e8400e29b41d4a716446655440019','ขนาด','25 กรัม (กว้าง 3.9 cm. * สูง 5.6 cm.)'),
    ('f5d1a9c6b3e7f4d2a8e5b9c1a6f3d8b4','550e8400e29b41d4a716446655440019','ลาย','การ์ตูน'),
    ('a7c9e1b3f4d6a8f5c2e7b1d9f3a5c4e6','550e8400e29b41d4a716446655440019','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440019')),
    ('d2f7a9e4c1b8a3f6d9e2b5a7f1c3e8b4','550e8400e29b41d4a716446655440019','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440019')),

    ('b4f3a6d9e1c8b5f7a2e4c9d3a1f8e7b6','550e8400e29b41d4a716446655440020','ธีม','ข้างกาย'),
    ('f9a4d7b5e1c2f6d3a8b9e4a1c7f5d8e3','550e8400e29b41d4a716446655440020','ความยาว','Freesize 15-25 cm. ปรับรูดได้'),
    ('c3e7a1f8b5d2a9c6e4b1f3d7a8e9f5d1','550e8400e29b41d4a716446655440020','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440020')),
    ('b2a9f3e6c4d1a7f8e2b9d5c3a6f4e1b7','550e8400e29b41d4a716446655440020','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440020')),

    ('f1b3a7d9c2e8f4a5d3b9c1e7a6f2d4e8','550e8400e29b41d4a716446655440021','ลาย','พรีเมี่ยม'),
    ('d5e1f3b9a4c7f6d8b2a9e5f1c3b7d4e6','550e8400e29b41d4a716446655440021','ขนาด','15 cm. ปรับรูดได้ถึง 25 cm.'),
    ('a9c2e8f3d4b1a5f7e6c9d2b8f4a1d5e3','550e8400e29b41d4a716446655440021','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440021')),
    ('f8a1b4e9c5d7f2a6b3e8c1d9f5a4b7d2','550e8400e29b41d4a716446655440021','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440021')),

    ('d6b3a9e5f1c4a8f2e7b9d3c5a6f4e1b8','550e8400e29b41d4a716446655440022','จำนวน','3 ชิ้น/ เซ็ต'),
    ('e3f9a5b2d8c1f4a7d9e6b3c5a8f1d7e4','550e8400e29b41d4a716446655440022','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440022')),
    ('b9e1a4f5c2d7b3f8a9e4c1f6d5a7b2e3','550e8400e29b41d4a716446655440022','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440022')),

    ('f8c3b7a1d4e9f5c2a6d7e3b1a9f4c5d8','550e8400e29b41d4a716446655440023','ลาย','ดอกไม้'),
    ('a5f7c9e1d2b6f3a4c8e5b7d1a9f2c6e3','550e8400e29b41d4a716446655440023','ความยาว','15 cm.'),
    ('d2a8f9b1e4c5f6a7d3e1b8c9f5a3d7e4','550e8400e29b41d4a716446655440023','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440023')),
    ('e6f4a1c8b3d9a7f2c5e9b1d4a8f3c7e5','550e8400e29b41d4a716446655440023','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440023')),

    ('b3d8f5a7e1c4f6a9b2d5e7c1a4f9d6e3','550e8400e29b41d4a716446655440024','สไตล์','ลูกคุณหนู'),
    ('c1e7b4f3d9a8f5c2b9d6e3a1f7c4b5a2','550e8400e29b41d4a716446655440024','ความยาว','15 cm. ปรับรูดได้ถึง 25 cm.'),
    ('f5a4d8e2b1c9f7a3e6d5b4c1f9a7e3d2','550e8400e29b41d4a716446655440024','วัสดุ',
        (select h.material from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440024')),
    ('e1b9f6a3d8c2a5f4b7e9c1a6f3d5b8e4','550e8400e29b41d4a716446655440024','สไตล์',
        (select h.style from products p join handmades h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440024')),

    ('a9f5d3c7e2b4a6f9d1e5c8b3a7f2e9d6','550e8400e29b41d4a716446655440005','จำนวน','50 ชิ้น/เซ็ต'),
    ('d8c4a1f6e3b7f9d5a2c8e1a3f4b9d6e7','550e8400e29b41d4a716446655440005','ขนาด','6 มม.'),
    ('e9f1b7c5d3a8f6e2b4a9d7c3f5e1a8d2','550e8400e29b41d4a716446655440005','วัสดุ',
        (select h.material from products p join components h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440005')),

    ('a2f6d9b3e1c5f4a7d8e3c9f1b6d4a5e7','550e8400e29b41d4a716446655440006','จำนวน','20 ชิ้น/ถุง 5 กรัม'),
    ('f3e9a7d2c6b8f1a4d5e7c2b3f9a5d1e6','550e8400e29b41d4a716446655440006','ขนาด','46 มม.'),
    ('b6a3f8d9e1c4f7a5d3e2b9f6c1a8d5e7','550e8400e29b41d4a716446655440006','วัสดุ',
        (select h.material from products p join components h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440006')),

    ('d7c1e4f9b2a8f3d6b5a1e7f2c9d4b8a3','550e8400e29b41d4a716446655440008','จำนวน','5 ชิ้น'),
    ('a1f5b7c2d4e9f3a6b8d1c5e7f9a3d6b4','550e8400e29b41d4a716446655440008','ขนาด','12*15 มม.'),
    ('e3a6f4b9c7d1a8f5e2b3c9f7a1d6e4d8','550e8400e29b41d4a716446655440008','วัสดุ',
        (select h.material from products p join components h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440008')),

    ('c5e1f8a3b7d6a9c4f2e7d1b3f6a5c8e9','550e8400e29b41d4a716446655440009','จำนวน','1 ชิ้น'),
    ('b4f2d9a7e1c3f8d5a9e6b1f3c4a7d8e5','550e8400e29b41d4a716446655440009','ขนาด','48 cm.'),
    ('a7c3f6e9d1b5f4a8c2e3d7f9a5b1d6e4','550e8400e29b41d4a716446655440009','วัสดุ',
        (select h.material from products p join components h on p.product_id = h.product_id where p.product_id = '550e8400e29b41d4a716446655440009'));  
    