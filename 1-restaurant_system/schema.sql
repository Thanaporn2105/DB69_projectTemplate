-- ============================================================
--  schema.sql — ระบบร้านอาหาร (นิสิตออกแบบและเขียนเอง)
--  กติกา: 1 ออเดอร์มีหลายเมนู (M:N: order × menu_item ผ่าน order_item),
--         เมนูชุด combo = M:N (menu_item × menu_item)
--  ต้องมี: PK ทุกตาราง, FK ครบ, ชื่อตรงกับ db.py, sample data
-- ============================================================
CREATE TABLE tier_config(
    tier_name VARCHAR(20) PRIMARY KEY,
    min_visit INT NOT NULL DEFAULT 0 CHECK(min_visit >= 0), -- จำนวนครั้งที่ต้องมาใช้บริการขั้นต่ำ
    discount_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 CHECK (discount_rate BETWEEN 0.00 AND 100.00) -- ส่วนลดเป็น %
);

CREATE TABLE customer (
    cust_id INT AUTO_INCREMENT PRIMARY KEY ,
    cust_name   VARCHAR(100)    NOT NULL,
    cust_phone  VARCHAR(20)     NOT NULL UNIQUE, -- เบอร์โทรศัพท์ต้องไม่ซ้ำกัน
    member_tier VARCHAR(20)     DEFAULT 'silver',
    visit_count INT             NOT NULL DEFAULT 0 CHECK(visit_count >= 0), --นับจำนวนครั้งที่มากิน
    FOREIGN KEY (member_tier) REFERENCES tier_config(tier_name) ON UPDATE CASCADE 
    -- TODO: name, phone, member_tier
);
CREATE TABLE menu_item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name   VARCHAR(100) NOT NULL, -- ชื่อเมนูอาหาร
    category    VARCHAR(50) NOT NULL, -- ประเภทอาหาร
    price       DECIMAL(10,2) NOT NULL CHECK(price >= 0), -- ราคา
    is_available VARCHAR(20) NOT NULL DEFAULT 'ขายปกติ' CHECK (is_available IN ('ขายปกติ', 'หมด', 'ยกเลิกถาวร')) -- เช็คว่ามีขายมั้ย
    -- TODO: name, category, price, is_available
);
CREATE TABLE dining_table (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    seats INT NOT NULL CHECK(seats > 0), -- จำนวนที่นั่ง
    table_zone VARCHAR(50) NOT NULL -- โซนของโต๊ะ 
    -- TODO: seats, zone
);
CREATE TABLE food_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT NOT NULL,
    table_id INT NOT NULL,
    order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- เวลาที่สั่งอาหาร DEFAULT CURRENT_TIMESTAMP ถ้าไม่มีการส่งค่าเวลามา ให้ดึงเวลาปัจจุบันของเครื่อง Server ณ วินาทีนั้นใส่
    order_status VARCHAR(20) NOT NULL DEFAULT 'pending', 
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id) ON UPDATE CASCADE,
    FOREIGN KEY (table_id) REFERENCES dining_table(table_id) ON UPDATE CASCADE
    -- TODO: cust_id (FK), table_id (FK), order_time, status
);
CREATE TABLE order_item (   
    -- M:N: food_order × menu_item
    -- TODO: order_id (FK), item_id (FK), qty, note ; PRIMARY KEY (order_id, item_id)
    order_id INT NOT NULL, 
    item_id INT NOT NULL,
    qty INT NOT NULL DEFAULT 1 CHECK(qty > 0), -- จำนวนที่สั่ง
    note VARCHAR(200) DEFAULT NULL, -- หมายเหตุเพิ่มเติม
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES food_order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES menu_item(item_id) ON DELETE CASCADE
);
CREATE TABLE combo (              
    -- M:N: menu_item × menu_item
    combo_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    sub_item_id INT NOT NULL,
    amount INT NOT NULL DEFAULT 1 CHECK(amount > 0), -- จำนวนที่อยู่ใน combo
    FOREIGN KEY (item_id) REFERENCES menu_item(item_id) ON DELETE CASCADE,
    FOREIGN KEY (sub_item_id) REFERENCES menu_item(item_id) ON DELETE CASCADE,
    UNIQUE KEY (item_id, sub_item_id) -- ป้องกันการใส่ combo ซ้ำ
    -- TODO: item_id (FK -> menu_item), sub_item_id (FK -> menu_item), amount
);
-- TODO: INSERT ข้อมูลตัวอย่างทุกตาราง

INSERT INTO tier_config (
    tier_name,
    min_visit,
    discount_rate
) 
VALUES
    ('silver',0,0.00),
    ('gold',20,5.0);
    
INSERT INTO customer(
    cust_name,
    cust_phone,
    member_tier,
    visit_count
)
VALUES
    ('Doraemon','0812244112','silver',0),
    ('Mickey Mouse','0891928119','gold',25),
    ('Conan Edogawa','0924860141','silver',11),
    ('Goku','0839997788','silver',2),
    ('Shin Chan','0955551234','gold',25),
    ('Pikachu','0860250025','silver',1);

INSERT INTO menu_item(
    item_name,
    category,
    price
)
VALUES
    ('Grilled Salmon Steak with Garlic Butter','Main Course',350),
    ('Pad Thai with fresh Prawns','Main Course',150),
    ('Crispy Truffle Fries','Appetizer',120),
    ('Mango Sticky Rice','Dessert',95),
    ('Iced Thai Milk Tea','Beverage',50);

INSERT INTO dining_table(
    seats,
    table_zone
)
VALUES
    (4,'Indoor'),
    (6,'Indoor'),
    (2,'Outdoor');

INSERT INTO food_order(
    cust_id,
    table_id
)
VALUES
    (1,3),
    (2,2),
    (3,1);

INSERT INTO order_item(
    order_id,
    item_id,
    note
)
VALUES
    (1, 1, 'แซลม่อนไม่ต้องสุกมาก'),
    (2, 2, NULL);

INSERT INTO combo(
    item_id,
    sub_item_id,
    amount
)
VALUES
    (3, 1, 1),
    (3, 5, 1);