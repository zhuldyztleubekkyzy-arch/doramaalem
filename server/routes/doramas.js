const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { verifyToken } = require('../config/firebase');

// Get all doramas
router.get('/', verifyToken, async (req, res) => {
  try {
    const { search, genre, country, limit = 50, offset = 0 } = req.query;
    
    let query = 'SELECT * FROM doramas WHERE 1=1';
    const params = [];
    let paramCount = 0;

    if (search) {
      paramCount++;
      query += ` AND (title ILIKE $${paramCount} OR description ILIKE $${paramCount})`;
      params.push(`%${search}%`);
    }

    if (genre) {
      paramCount++;
      query += ` AND genre = $${paramCount}`;
      params.push(genre);
    }

    if (country) {
      paramCount++;
      query += ` AND country = $${paramCount}`;
      params.push(country);
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await pool.query(query, params);
    
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching doramas:', error);
    res.status(500).json({ error: 'Дорамаларды алу қатесі' });
  }
});

// Search doramas
router.get('/search', verifyToken, async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q) {
      return res.status(400).json({ error: 'Іздеу сөзі қажет' });
    }

    const query = `
      SELECT * FROM doramas 
      WHERE title ILIKE $1 OR description ILIKE $1 OR genre ILIKE $1
      ORDER BY rating DESC
      LIMIT 50
    `;
    
    const result = await pool.query(query, [`%${q}%`]);
    
    res.json(result.rows);
  } catch (error) {
    console.error('Error searching doramas:', error);
    res.status(500).json({ error: 'Іздеу қатесі' });
  }
});

// Get dorama by ID
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    
    const query = 'SELECT * FROM doramas WHERE id = $1';
    const result = await pool.query(query, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Дорама табылмады' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching dorama:', error);
    res.status(500).json({ error: 'Дораманы алу қатесі' });
  }
});

// Create new dorama (admin only - add admin check if needed)
router.post('/', verifyToken, async (req, res) => {
  try {
    const {
      title,
      description,
      image_url,
      genre,
      year,
      rating,
      episode_count,
      country,
    } = req.body;

    if (!title || !description || !image_url || !genre || !year || !country) {
      return res.status(400).json({ error: 'Барлық міндетті өрістерді толтырыңыз' });
    }

    const query = `
      INSERT INTO doramas (
        title, description, image_url, genre, year, 
        rating, episode_count, country, created_at, updated_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())
      RETURNING *
    `;

    const values = [
      title,
      description,
      image_url,
      genre,
      parseInt(year),
      rating ? parseFloat(rating) : 0.0,
      episode_count ? parseInt(episode_count) : 0,
      country,
    ];

    const result = await pool.query(query, values);
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating dorama:', error);
    res.status(500).json({ error: 'Дораманы құру қатесі' });
  }
});

// Update dorama (admin only)
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const {
      title,
      description,
      image_url,
      genre,
      year,
      rating,
      episode_count,
      country,
    } = req.body;

    const query = `
      UPDATE doramas
      SET 
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        image_url = COALESCE($3, image_url),
        genre = COALESCE($4, genre),
        year = COALESCE($5, year),
        rating = COALESCE($6, rating),
        episode_count = COALESCE($7, episode_count),
        country = COALESCE($8, country),
        updated_at = NOW()
      WHERE id = $9
      RETURNING *
    `;

    const values = [
      title || null,
      description || null,
      image_url || null,
      genre || null,
      year ? parseInt(year) : null,
      rating ? parseFloat(rating) : null,
      episode_count ? parseInt(episode_count) : null,
      country || null,
      id,
    ];

    const result = await pool.query(query, values);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Дорама табылмады' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating dorama:', error);
    res.status(500).json({ error: 'Дораманы жаңарту қатесі' });
  }
});

// Delete dorama (admin only)
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    
    const query = 'DELETE FROM doramas WHERE id = $1 RETURNING *';
    const result = await pool.query(query, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Дорама табылмады' });
    }
    
    res.json({ message: 'Дорама сәтті жойылды' });
  } catch (error) {
    console.error('Error deleting dorama:', error);
    res.status(500).json({ error: 'Дораманы жою қатесі' });
  }
});

module.exports = router;

