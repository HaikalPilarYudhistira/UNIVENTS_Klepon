-- ================================================
--  UNIVENTS - Sistem Informasi Event Kampus
--  Database Schema untuk MariaDB
-- ================================================

CREATE DATABASE IF NOT EXISTS univents CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE univents;

-- Tabel pengguna (Admin + Mahasiswa)
CREATE TABLE IF NOT EXISTS users (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nama        VARCHAR(100) NOT NULL,
  nim         VARCHAR(20)  UNIQUE,               -- NULL kalau admin
  email       VARCHAR(100) NOT NULL UNIQUE,
  password    VARCHAR(255) NOT NULL,             -- bcrypt hash
  role        ENUM('admin','mahasiswa') NOT NULL DEFAULT 'mahasiswa',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabel event kampus
CREATE TABLE IF NOT EXISTS events (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  judul       VARCHAR(200) NOT NULL,
  deskripsi   TEXT,
  lokasi      VARCHAR(200),
  tanggal     DATE         NOT NULL,
  waktu       TIME         NOT NULL,
  kuota       INT          NOT NULL DEFAULT 100,
  poster      VARCHAR(300),                      -- path file poster
  kategori    ENUM('akademik','non-akademik','olahraga','seni','lainnya') DEFAULT 'lainnya',
  status      ENUM('aktif','selesai','batal')    DEFAULT 'aktif',
  admin_id    INT,
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Tabel pendaftaran event (Mahasiswa daftar event)
CREATE TABLE IF NOT EXISTS pendaftaran (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  event_id    INT NOT NULL,
  user_id     INT NOT NULL,
  status      ENUM('terdaftar','hadir','batal')  DEFAULT 'terdaftar',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_event_user (event_id, user_id),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE
);

-- Tabel notifikasi
CREATE TABLE IF NOT EXISTS notifikasi (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  pesan       TEXT NOT NULL,
  dibaca      TINYINT(1) DEFAULT 0,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ================================================
--  Data awal (Seed)
-- ================================================

-- Admin default: password = "admin123" (di-hash bcrypt; ganti saat produksi)
INSERT IGNORE INTO users (nama, email, password, role)
VALUES ('Administrator', 'admin@univents.ac.id',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin');

-- Contoh mahasiswa: password = "mhs123"
INSERT IGNORE INTO users (nama, nim, email, password, role)
VALUES ('Budi Santoso', '2024001', 'budi@mhs.ac.id',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'mahasiswa');

-- Contoh event
INSERT IGNORE INTO events (judul, deskripsi, lokasi, tanggal, waktu, kuota, kategori, admin_id)
VALUES
  ('Seminar Nasional AI 2025', 'Seminar tentang perkembangan Artificial Intelligence dan dampaknya bagi dunia pendidikan.', 'Aula Utama Gedung A', '2025-08-15', '08:00:00', 200, 'akademik', 1),
  ('Workshop UI/UX Design', 'Belajar dasar desain antarmuka bersama praktisi industri.', 'Lab Komputer 301', '2025-08-22', '09:00:00', 40, 'akademik', 1),
  ('Lomba Futsal Antar Prodi', 'Turnamen futsal persahabatan untuk mempererat kebersamaan mahasiswa.', 'Lapangan Olahraga Kampus', '2025-09-01', '07:30:00', 120, 'olahraga', 1);
