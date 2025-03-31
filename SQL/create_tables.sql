--Codigo para la creacción de las tablas

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY IDENTITY,
    email NVARCHAR(100) UNIQUE NOT NULL,
    nombre NVARCHAR(50),
    apellido NVARCHAR(50),
    sexo NVARCHAR(10),
    direccion TEXT,
    fecha_nacimiento DATE,
    telefono NVARCHAR(20),
	es_vendedor BIT NOT NULL 
);

CREATE TABLE Category (
    category_id INT PRIMARY KEY IDENTITY,
    nombre NVARCHAR(100) NOT NULL,
    cat_path TEXT
);

CREATE TABLE Item (
    item_id INT PRIMARY KEY IDENTITY,
    nombre NVARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    estado NVARCHAR(50),
    fecha_baja DATE,
    category_id INT,
    seller_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    FOREIGN KEY (seller_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY IDENTITY,
    fecha DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    buyer_id INT,
    item_id INT,
    cantidad INT NOT NULL,
    FOREIGN KEY (buyer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);