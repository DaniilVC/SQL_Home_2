-- Килимджьян Даниил Владимирович
-- Вариант 19
/*
Выберите автомобили (все поля таблицы), зарегистрированные в московском регионе.
Выберите для каждого автомобиля (госномер) число заказов, в которых он участвовал, 
кроме автомобилей с нулевым числом заказов.
*/

/* Комментарий для проверяющего:
В предыдущей работе вынесены ошибки:
"Работа зачтена. Баллы сняты за возможность назначить одному водителю заказы на разных машинах и записать отрицательный километраж оплаты. Закрепите машину за водителем и добавьте проверку километража."
В этой работе ошибки учтены и исправлены.

В таблице cars сделал ID водителя уникальным
В paycheck в километраже добавил проверку на отрицательное число
*/

DROP SCHEMA IF EXISTS taxi_company CASCADE;

CREATE SCHEMA taxi_company;

-- водитель
CREATE TABLE taxi_company.drivers (
	id SERIAL PRIMARY KEY,
	birthday date NOT NULL,
	first_name varchar(64) NOT NULL,
	last_name varchar(64) NOT NULL,
	second_name varchar(64),
	inn char(12) NOT NULL UNIQUE,
	serial_passport char(4) NOT NULL,
	number_passport char(6) NOT NULL,

	UNIQUE(serial_passport, number_passport)
);

-- авто
CREATE TABLE taxi_company.cars (
	id SERIAL PRIMARY KEY,
	brand varchar(32) NOT NULL,
	driver_id integer NOT NULL UNIQUE,
	car_class varchar(8) NOT NULL CHECK(car_class = 'economy' OR car_class = 'business'),
	color varchar(20) NOT NULL,
	plate varchar(9) NOT NULL UNIQUE,
	year_release smallint NOT NULL,
	
	FOREIGN KEY(driver_id) REFERENCES taxi_company.drivers(id)
);

-- тарифы
CREATE TABLE taxi_company.tariffs (
	id SERIAL PRIMARY KEY,
	tariff_name varchar(30) NOT NULL,
	day_time varchar(5) NOT NULL CHECK(day_time = 'day' or day_time = 'night'),
	distance varchar(8) NOT NULL CHECK(distance IN ('MKAD', 'out_MKAD', 'region')),
	price_dist int NOT NULL CHECK(price_dist > 0)
);

-- заказы
CREATE TABLE taxi_company.orders (
	id SERIAL PRIMARY KEY,
	order_date date NOT NULL,
	order_time time NOT NULL,
	car_id integer NOT NULL,
	pickup_address varchar(128) NOT NULL,
	dropoff_address varchar(128) NOT NULL,
	passenger_count smallint NOT NULL CHECK(passenger_count > 0),
	way_kilometer integer NOT NULL CHECK(way_kilometer > 0),

	FOREIGN KEY(car_id) REFERENCES taxi_company.cars(id)
);

-- инфо об оплате
CREATE TABLE taxi_company.paycheck (
	id SERIAL PRIMARY KEY,
	order_id integer NOT NULL,
	tariff_id integer NOT NULL,
	total_way integer NOT NULL CHECK(total_way > 0),
	price integer NOT NULL CHECK(price > 0),
	is_paid boolean NOT NULL DEFAULT FALSE, -- в описании кейса не было сказано про статус, но на всякий случай добавлю 

	UNIQUE(order_id, tariff_id), -- защита от дублирования записи

	FOREIGN KEY(order_id) REFERENCES taxi_company.orders(id),
	FOREIGN KEY(tariff_id) REFERENCES taxi_company.tariffs(id)
);

/*
Заполнение данными
*/

-- Водители
INSERT INTO taxi_company.drivers (birthday, first_name, last_name, second_name, inn, serial_passport, number_passport) VALUES
('1985-04-12', 'Алексей', 'Смирнов', 'Игоревич', '771548291034', '4510', '892341'),
('1990-09-23', 'Дмитрий', 'Кузнецов', 'Андреевич', '502419384712', '4614', '341902'),
('1982-11-05', 'Сергей', 'Попов', 'Викторович', '772891045623', '4508', '712045'),
('1994-02-18', 'Руслан', 'Ахмедов', NULL, '773104928175', '4518', '559183'),
('1988-07-30', 'Михаил', 'Волков', 'Сергеевич', '500192837465', '4612', '604819');

-- Машины
INSERT INTO taxi_company.cars (brand, driver_id, car_class, color, plate, year_release) VALUES
('Kia Rio', 1, 'economy', 'Белый', 'А123ВС777', 2021),
('Hyundai Solaris', 2, 'economy', 'Жёлтый', 'О456МН799', 2022),
('Toyota Camry', 3, 'business', 'Чёрный', 'Е777КХ23', 2023),
('Skoda Octavia', 4, 'economy', 'Серый', 'К890РА750', 2020),
('Mercedes-Benz E200', 5, 'business', 'Чёрный', 'М001АА78', 2023);

-- Тарифы
INSERT INTO taxi_company.tariffs (tariff_name, day_time, distance, price_dist) VALUES
('Эконом День (МКАД)', 'day', 'MKAD', 25),
('Эконом День (За МКАД)', 'day', 'out_MKAD', 35),
('Эконом Ночь (МКАД)', 'night', 'MKAD', 30),
('Бизнес День (МКАД)', 'day', 'MKAD', 55),
('Бизнес День (Подмосковье)', 'day', 'region', 75),
('Бизнес Ночь (За МКАД)', 'night', 'out_MKAD', 70);

-- Заказы
INSERT INTO taxi_company.orders (order_date, order_time, car_id, pickup_address, dropoff_address, passenger_count, way_kilometer) VALUES
('2026-11-10', '09:15:00', 1, 'г. Москва, ул. Тверская, д. 12', 'г. Москва, Ленинградский проспект, д. 37', 1, 8),
('2026-11-10', '14:40:00', 3, 'г. Москва, Пресненская наб., д. 12 (Москва-Сити)', 'Московская обл., г. Одинцово, ул. Маршала Жукова, д. 28', 2, 24),
('2026-11-11', '01:20:00', 2, 'г. Москва, Комсомольская пл., д. 2 (Ленинградский вокзал)', 'г. Москва, ул. Профсоюзная, д. 56', 3, 19),
('2026-11-11', '18:05:00', 1, 'г. Москва, ул. Арбат, д. 24', 'Московская обл., г. Химки, ул. Московская, д. 14', 2, 22),
('2026-11-12', '23:50:00', 5, 'г. Москва, Кутузовский проспект, д. 32', 'г. Москва, аэропорт Шереметьево, Терминал B', 1, 34),
('2026-11-13', '11:30:00', 3, 'г. Москва, ул. Петровка, д. 2', 'г. Москва, ул. Большая Якиманка, д. 26', 1, 5);

-- Инфо об оплате
INSERT INTO taxi_company.paycheck (order_id, tariff_id, total_way, price, is_paid) VALUES
(1, 1, 8, 200, TRUE),
(2, 4, 10, 550, TRUE),
(2, 5, 14, 1050, TRUE),
(3, 3, 19, 570, TRUE),
(4, 1, 12, 300, TRUE),
(4, 2, 10, 350, FALSE),
(5, 6, 34, 2380, TRUE),
(6, 4, 5, 275, TRUE);

/*
Запросы
*/

-- Авто, зарегистрированные в московском регионе
SELECT * FROM taxi_company.cars
WHERE CASE 
        WHEN plate LIKE '%77' OR plate LIKE '%97' OR plate LIKE '%99' THEN 1
        WHEN plate LIKE '%50' OR plate LIKE '%90' THEN 1
        ELSE 0
		END = 1;

-- Число заказов для авто, за исключением нулевого
SELECT car_id, COUNT(DISTINCT id) AS orders_count
FROM taxi_company.orders
GROUP BY car_id
HAVING COUNT(DISTINCT id) > 0;