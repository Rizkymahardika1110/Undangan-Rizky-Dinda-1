-- Database untuk Undangan Pernikahan Rizky & Dinda
CREATE DATABASE IF NOT EXISTS wedding_invitation;
USE wedding_invitation;

-- =====================================================
-- TABEL TAMU
-- =====================================================
CREATE TABLE IF NOT EXISTS guests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    category ENUM('family', 'friend', 'colleague', 'neighbor', 'other') DEFAULT 'friend',
    is_vip BOOLEAN DEFAULT FALSE,
    invitation_sent BOOLEAN DEFAULT FALSE,
    invitation_sent_date TIMESTAMP NULL,
    unique_code VARCHAR(50) UNIQUE, -- Kode unik untuk akses tamu
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABEL RSVP (KONFIRMASI KEHADIRAN)
-- =====================================================
CREATE TABLE IF NOT EXISTS rsvp (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    attendance_status ENUM('yes', 'no', 'pending') DEFAULT 'pending',
    number_of_guests INT DEFAULT 1,
    dietary_restrictions TEXT,
    message TEXT,
    response_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    check_in_time TIMESTAMP NULL,
    qr_code VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABEL KOMENTAR
-- =====================================================
CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NULL,
    name VARCHAR(100) NOT NULL,
    comment TEXT NOT NULL,
    date DATE,
    is_approved BOOLEAN DEFAULT TRUE,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABEL PENGINGAT
-- =====================================================
CREATE TABLE IF NOT EXISTS reminders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    reminder_type ENUM('whatsapp', 'email', 'sms') DEFAULT 'whatsapp',
    sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('sent', 'failed', 'read') DEFAULT 'sent',
    notes TEXT,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABEL DONASI
-- =====================================================
CREATE TABLE IF NOT EXISTS donations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NULL,
    name VARCHAR(100) NOT NULL,
    amount DECIMAL(15,2),
    payment_method ENUM('gopay', 'bca', 'cash', 'other') DEFAULT 'other',
    payment_date TIMESTAMP NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABEL LOG AKTIVITAS
-- =====================================================
CREATE TABLE IF NOT EXISTS activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NULL,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INDEX UNTUK OPTIMASI
-- =====================================================
CREATE INDEX idx_guest_category ON guests(category);
CREATE INDEX idx_guest_is_vip ON guests(is_vip);
CREATE INDEX idx_guest_invitation ON guests(invitation_sent);
CREATE INDEX idx_guest_code ON guests(unique_code);
CREATE INDEX idx_rsvp_status ON rsvp(attendance_status);
CREATE INDEX idx_rsvp_guest ON rsvp(guest_id);
CREATE INDEX idx_rsvp_date ON rsvp(response_date);
CREATE INDEX idx_comments_guest ON comments(guest_id);
CREATE INDEX idx_comments_date ON comments(created_at);
CREATE INDEX idx_comments_approved ON comments(is_approved);
CREATE INDEX idx_donations_guest ON donations(guest_id);
CREATE INDEX idx_logs_guest ON activity_logs(guest_id);
CREATE INDEX idx_logs_action ON activity_logs(action);
CREATE INDEX idx_logs_date ON activity_logs(created_at);

-- =====================================================
-- SAMPLE DATA
-- =====================================================
-- Memasukkan data keluarga inti
INSERT INTO guests (name, phone, category, is_vip, notes) VALUES
('Bapak Sobar & Ibu Dewi', '081234567890', 'family', TRUE, 'Orang tua mempelai pria'),
('Bapak Edi Setiawan & Ibu Lina Rostini', '081234567891', 'family', TRUE, 'Orang tua mempelai wanita');

-- Memasukkan data tamu undangan
INSERT INTO guests (name, phone, category, notes) VALUES
('Bpk. Kades Banyusari', '081234567892', 'neighbor', 'Kepala Desa Banyusari'),
('Bpk. Pipin Aripin', '081234567893', 'neighbor', 'Kadus 4'),
('Bpk. Udjun', NULL, 'family', 'Alm.'),
('Kel. Besar Bpk. Momo Rahmat', NULL, 'family', 'Alm.'),
('Bpk. Uyu Suparyu & Ibu Nining Warningsih', NULL, 'family', 'Alm.'),
('Bpk. Ayong Sudrajat & Ibu Ai Tatih', NULL, 'family', 'Alm.'),
('Bpk. Ema Amajun', '081234567894', 'family', 'Jakarta'),
('Bpk. Dadang & Bpk. Yusup', '081234567895', 'friend', NULL),
('Ibu Titin', '081234567896', 'friend', NULL),
('Bpk. Tedy & Popi', '081234567897', 'friend', NULL),
('Bapak Indra & Rani', '081234567898', 'friend', NULL);

-- Memasukkan sample komentar
INSERT INTO comments (name, comment, date) VALUES
('Teman 1', 'Selamat menempuh hidup baru, semoga langgeng selalu!', CURDATE()),
('Teman 2', 'Barakallah, semoga menjadi keluarga yang sakinah mawaddah warahmah', CURDATE());

-- =====================================================
-- STORED PROCEDURE
-- =====================================================
DELIMITER //

-- Menghitung statistik kehadiran
CREATE PROCEDURE GetAttendanceStats()
BEGIN
    SELECT 
        SUM(CASE WHEN attendance_status = 'yes' THEN number_of_guests ELSE 0 END) AS total_hadir,
        SUM(CASE WHEN attendance_status = 'no' THEN 1 ELSE 0 END) AS total_tidak_hadir,
        SUM(CASE WHEN attendance_status = 'pending' THEN 1 ELSE 0 END) AS total_belum_konfirmasi,
        COUNT(DISTINCT guest_id) AS total_tamu_merespons,
        (SELECT COUNT(*) FROM guests) AS total_tamu_keseluruhan
    FROM rsvp;
END //

-- Mendapatkan daftar tamu yang belum konfirmasi
CREATE PROCEDURE GetUnconfirmedGuests()
BEGIN
    SELECT g.* 
    FROM guests g
    LEFT JOIN rsvp r ON g.id = r.guest_id
    WHERE (r.attendance_status IS NULL OR r.attendance_status = 'pending')
    AND g.invitation_sent = TRUE;
END //

-- Mendapatkan komentar terbaru yang sudah disetujui
CREATE PROCEDURE GetRecentComments(IN limit_count INT)
BEGIN
    SELECT c.name, c.comment, DATE_FORMAT(c.created_at, '%d/%m/%Y') AS tanggal
    FROM comments c
    WHERE c.is_approved = TRUE 
    ORDER BY c.created_at DESC 
    LIMIT limit_count;
END //

DELIMITER ;

-- =====================================================
-- TRIGGER
-- =====================================================
DELIMITER //

-- Trigger untuk mencatat log saat tamu melakukan RSVP
CREATE TRIGGER after_rsvp_insert
AFTER INSERT ON rsvp
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (guest_id, action, details)
    VALUES (NEW.guest_id, 'RSVP', CONCAT('Status: ', NEW.attendance_status, ', Jumlah: ', NEW.number_of_guests));
END //

-- Trigger untuk mencatat log saat komentar ditambahkan
CREATE TRIGGER after_comment_insert
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (guest_id, action, details, ip_address)
    VALUES (NEW.guest_id, 'COMMENT', NEW.comment, NEW.ip_address);
END //

DELIMITER ;

-- =====================================================
-- VIEW
-- =====================================================
-- View untuk melihat daftar tamu VIP yang hadir
CREATE VIEW vw_vip_guests_attending AS
SELECT g.name, g.phone, r.number_of_guests, r.message
FROM guests g
JOIN rsvp r ON g.id = r.guest_id
WHERE g.is_vip = TRUE AND r.attendance_status = 'yes'
ORDER BY g.name;

-- View untuk statistik harian RSVP
CREATE VIEW vw_daily_rsvp_stats AS
SELECT 
    DATE(response_date) AS tanggal,
    COUNT(*) AS total_rsvp,
    SUM(CASE WHEN attendance_status = 'yes' THEN 1 ELSE 0 END) AS hadir,
    SUM(CASE WHEN attendance_status = 'no' THEN 1 ELSE 0 END) AS tidak_hadir
FROM rsvp
GROUP BY DATE(response_date)
ORDER BY tanggal DESC;

-- =====================================================
-- EVENT SCHEDULER (Otomatis mengirim pengingat)
-- =====================================================
-- Aktifkan event scheduler
SET GLOBAL event_scheduler = ON;

-- Event untuk mengirim pengingat otomatis 3 hari sebelum acara
CREATE EVENT IF NOT EXISTS send_reminders_3_days_before
ON SCHEDULE AT '2026-04-09 09:00:00' -- 3 hari sebelum 12 April 2026
DO
BEGIN
    INSERT INTO reminders (guest_id, reminder_type, notes)
    SELECT g.id, 'whatsapp', 'Pengingat otomatis 3 hari sebelum acara'
    FROM guests g
    LEFT JOIN rsvp r ON g.id = r.guest_id
    WHERE (r.attendance_status IS NULL OR r.attendance_status = 'pending')
    AND g.phone IS NOT NULL;
END //

DELIMITER ;

-- Tampilkan pesan sukses
SELECT 'Database wedding_invitation berhasil dibuat dengan semua tabel, index, dan prosedur!' AS MESSAGE;