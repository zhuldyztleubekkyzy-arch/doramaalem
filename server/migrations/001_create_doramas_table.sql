-- Create doramas table
CREATE TABLE IF NOT EXISTS doramas (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    genre VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    rating DECIMAL(3, 1) DEFAULT 0.0,
    episode_count INTEGER DEFAULT 0,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster searches
CREATE INDEX IF NOT EXISTS idx_doramas_title ON doramas(title);
CREATE INDEX IF NOT EXISTS idx_doramas_genre ON doramas(genre);
CREATE INDEX IF NOT EXISTS idx_doramas_country ON doramas(country);
CREATE INDEX IF NOT EXISTS idx_doramas_rating ON doramas(rating DESC);

-- Insert sample data
INSERT INTO doramas (title, description, image_url, genre, year, rating, episode_count, country) VALUES
('Crash Landing on You', 'Оңтүстік Корея бизнесвумені қателікпен Солтүстік Кореяға құлап, ол жерде офицермен танысады.', 'https://example.com/crash-landing.jpg', 'Романтика, Драма', 2019, 9.0, 16, 'Корея'),
('Goblin', 'Ұзақ өмір сүрген гоблин мен оның қызметшісінің тарихы.', 'https://example.com/goblin.jpg', 'Фантастика, Романтика', 2016, 8.8, 16, 'Корея'),
('Descendants of the Sun', 'Әскери офицер мен дәрігердің махаббаты.', 'https://example.com/descendants.jpg', 'Романтика, Драма', 2016, 8.7, 16, 'Корея'),
('Itaewon Class', 'Жас кәсіпкердің табысқа жету жолы.', 'https://example.com/itaewon.jpg', 'Драма, Бизнес', 2020, 8.5, 16, 'Корея'),
('The World of the Married', 'Некедегі алдау мен кек туралы драма.', 'https://example.com/married.jpg', 'Драма, Триллер', 2020, 8.9, 16, 'Корея')
ON CONFLICT DO NOTHING;

