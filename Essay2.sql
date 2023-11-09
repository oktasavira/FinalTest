-- Create dim_user table
CREATE TABLE dim_user (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    country VARCHAR(50)
);

-- Insert data into dim_user table
INSERT INTO dim_user (user_id, user_name, country)
SELECT DISTINCT user_id, user_name, country
FROM raw_users;

-- Create dim_post table
CREATE TABLE dim_post (
    post_id INT PRIMARY KEY,
    post_text VARCHAR(500),
    post_date DATE,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id)
);

-- Insert data into dim_post table
INSERT INTO dim_post (post_id, post_text, post_date, user_id)
SELECT DISTINCT post_id, post_text, post_date, user_id
FROM raw_posts;

-- Create dim_date table
CREATE TABLE dim_date (
    date_id DATE PRIMARY KEY
);

-- Insert data into dim_date table
INSERT INTO dim_date (date_id)
SELECT DISTINCT post_date
FROM raw_posts;


-- Create fact_post_performance table
CREATE TABLE fact_post_performance (
    post_id INT,
    post_date DATE,
    views INT,
    likes INT,
    FOREIGN KEY (post_id) REFERENCES raw_posts(post_id),
    FOREIGN KEY (post_date) REFERENCES raw_posts(post_date)
);

-- Insert data into fact_post_performance table
INSERT INTO fact_post_performance (post_id, post_date, views, likes)
SELECT rp.post_id, rp.post_date, COUNT(DISTINCT rv.user_id) AS views, COUNT(DISTINCT rl.user_id) AS likes
FROM raw_posts rp
LEFT JOIN raw_likes rl ON rp.post_id = rl.post_id
LEFT JOIN raw_views rv ON rp.post_id = rv.post_id AND rp.post_date = rv.view_date
GROUP BY rp.post_id, rp.post_date;


-- Create fact_daily_posts table
CREATE TABLE fact_daily_posts (
    post_date DATE,
    user_id INT,
    num_posts INT,
    FOREIGN KEY (user_id) REFERENCES raw_users(user_id),
    FOREIGN KEY (post_date) REFERENCES raw_posts(post_date)
);

-- Insert data into fact_daily_posts table
INSERT INTO fact_daily_posts (post_date, user_id, num_posts)
SELECT post_date, user_id, COUNT(*) AS num_posts
FROM raw_posts
GROUP BY post_date, user_id;