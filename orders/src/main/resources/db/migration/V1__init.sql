DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  shipping_address VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS line_items;

CREATE TABLE line_items (
  id SERIAL PRIMARY KEY,
  order_id INT NOT NULL REFERENCES orders (id),
  product_id INT NOT NULL,
  amount INT NOT NULL,
  price_per_unit INT NOT NULL
);

