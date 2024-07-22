-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 22 Jul 2024 pada 14.21
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sewa_laptop`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_laptop` (`p_laptop_id` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    DELETE FROM LaptopKategori WHERE laptop_id = p_laptop_id;
    DELETE FROM SewaLaptop WHERE laptop_id = p_laptop_id;
    DELETE FROM Laptop WHERE laptop_id = p_laptop_id;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_sewa` (`p_sewa_id` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    DELETE FROM SewaLaptop WHERE sewa_id = p_sewa_id;
    DELETE FROM Pengembalian WHERE sewa_id = p_sewa_id;
    DELETE FROM Sewa WHERE sewa_id = p_sewa_id;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showOngoingRentals` ()   BEGIN
    SELECT * FROM Sewa WHERE status = 'Berlangsung';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateLaptopStock` (IN `id_laptop` INT, IN `new_stock` INT)   BEGIN
    IF (SELECT COUNT(*) FROM Laptop WHERE laptop_id = id_laptop) = 1 THEN
        UPDATE Laptop
        SET stok = new_stock
        WHERE laptop_id = id_laptop;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Laptop not found or multiple entries detected';
    END IF;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `calculateRentalCost` (`laptop_id` INT, `days` INT) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE rental_cost DECIMAL(10, 2);
    SELECT harga_sewa_per_hari INTO rental_cost
    FROM Laptop
    WHERE laptop_id = laptop_id
    LIMIT 1;
    RETURN rental_cost * days;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getTotalAvailableLaptops` () RETURNS INT(11)  BEGIN
    DECLARE total INT;
    SELECT SUM(stok) INTO total FROM Laptop;
    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `admin`
--

CREATE TABLE `admin` (
  `admin_id` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `admin`
--

INSERT INTO `admin` (`admin_id`, `nama`, `username`, `password`) VALUES
(1, 'Admin1', 'admin1', 'password1'),
(2, 'Admin2', 'admin2', 'password2'),
(3, 'Admin3', 'admin3', 'password3'),
(4, 'Admin4', 'admin4', 'password4'),
(5, 'Admin5', 'admin5', 'password5');

-- --------------------------------------------------------

--
-- Struktur dari tabel `detailpelanggan`
--

CREATE TABLE `detailpelanggan` (
  `detail_id` int(11) NOT NULL,
  `pelanggan_id` int(11) DEFAULT NULL,
  `no_telepon` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `detailpelanggan`
--

INSERT INTO `detailpelanggan` (`detail_id`, `pelanggan_id`, `no_telepon`, `email`) VALUES
(1, 1, '0811111111', 'pelanggan1@example.com'),
(2, 2, '0812222222', 'pelanggan2@example.com'),
(3, 3, '0813333333', 'pelanggan3@example.com'),
(4, 4, '0814444444', 'pelanggan4@example.com'),
(5, 5, '0815555555', 'pelanggan5@example.com');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kategorilaptop`
--

CREATE TABLE `kategorilaptop` (
  `kategori_id` int(11) NOT NULL,
  `nama_kategori` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kategorilaptop`
--

INSERT INTO `kategorilaptop` (`kategori_id`, `nama_kategori`) VALUES
(1, 'Ultrabook'),
(2, 'Gaming'),
(3, 'Business'),
(4, 'Convertible'),
(5, 'Budget');

-- --------------------------------------------------------

--
-- Struktur dari tabel `laptop`
--

CREATE TABLE `laptop` (
  `laptop_id` int(11) NOT NULL,
  `merek` varchar(100) DEFAULT NULL,
  `model` varchar(100) DEFAULT NULL,
  `nomor_seri` varchar(50) DEFAULT NULL,
  `harga_sewa_per_hari` decimal(10,2) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `laptop`
--

INSERT INTO `laptop` (`laptop_id`, `merek`, `model`, `nomor_seri`, `harga_sewa_per_hari`, `stok`) VALUES
(1, 'Dell', 'XPS 13', 'ABC123456', 100000.00, 15),
(2, 'HP', 'Spectre x360', 'DEF789012', 120000.00, 8),
(3, 'Apple', 'MacBook Air', 'GHI345678', 150000.00, 5),
(4, 'Asus', 'ZenBook 14', 'JKL901234', 110000.00, 7),
(5, 'Lenovo', 'ThinkPad X1', 'MNO567890', 130000.00, 6);

--
-- Trigger `laptop`
--
DELIMITER $$
CREATE TRIGGER `after_delete_laptop` AFTER DELETE ON `laptop` FOR EACH ROW BEGIN
    INSERT INTO LogLaptop (laptop_id, action, old_value) 
    VALUES (OLD.laptop_id, 'DELETE', CONCAT('Merek: ', OLD.merek, ', Model: ', OLD.model, ', Nomor Seri: ', OLD.nomor_seri, ', Harga Sewa per Hari: ', OLD.harga_sewa_per_hari, ', Stok: ', OLD.stok));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_laptop` AFTER INSERT ON `laptop` FOR EACH ROW BEGIN
    INSERT INTO LogLaptop (laptop_id, action, new_value) 
    VALUES (NEW.laptop_id, 'INSERT', CONCAT('Merek: ', NEW.merek, ', Model: ', NEW.model, ', Nomor Seri: ', NEW.nomor_seri, ', Harga Sewa per Hari: ', NEW.harga_sewa_per_hari, ', Stok: ', NEW.stok));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_laptop` BEFORE UPDATE ON `laptop` FOR EACH ROW BEGIN
    IF NEW.stok < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok tidak boleh negatif';
    ELSEIF NEW.stok != OLD.stok THEN
        INSERT INTO LogLaptop (laptop_id, action, old_value, new_value) 
        VALUES (OLD.laptop_id, 'UPDATE', CONCAT('Stok: ', OLD.stok), CONCAT('Stok: ', NEW.stok));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `laptopkategori`
--

CREATE TABLE `laptopkategori` (
  `laptop_id` int(11) NOT NULL,
  `kategori_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `laptopkategori`
--

INSERT INTO `laptopkategori` (`laptop_id`, `kategori_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- --------------------------------------------------------

--
-- Struktur dari tabel `laptopsewa`
--

CREATE TABLE `laptopsewa` (
  `sewa_id` int(11) NOT NULL,
  `laptop_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `loglaptop`
--

CREATE TABLE `loglaptop` (
  `log_id` int(11) NOT NULL,
  `laptop_id` int(11) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `change_date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `loglaptop`
--

INSERT INTO `loglaptop` (`log_id`, `laptop_id`, `action`, `old_value`, `new_value`, `change_date`) VALUES
(1, 1, 'UPDATE', 'Stok: 10', 'Stok: 15', '2024-07-22 19:19:30');

-- --------------------------------------------------------

--
-- Struktur dari tabel `logpelanggan`
--

CREATE TABLE `logpelanggan` (
  `log_id` int(11) NOT NULL,
  `pelanggan_id` int(11) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `change_date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `logsewa`
--

CREATE TABLE `logsewa` (
  `log_id` int(11) NOT NULL,
  `sewa_id` int(11) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `change_date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pelanggan`
--

CREATE TABLE `pelanggan` (
  `pelanggan_id` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `jenis_kelamin` enum('L','P') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pelanggan`
--

INSERT INTO `pelanggan` (`pelanggan_id`, `nama`, `alamat`, `jenis_kelamin`) VALUES
(1, 'Pelanggan1', 'Alamat1', 'L'),
(2, 'Pelanggan2', 'Alamat2', 'P'),
(3, 'Pelanggan3', 'Alamat3', 'L'),
(4, 'Pelanggan4', 'Alamat4', 'P'),
(5, 'Pelanggan5', 'Alamat5', 'L');

--
-- Trigger `pelanggan`
--
DELIMITER $$
CREATE TRIGGER `after_update_pelanggan` AFTER UPDATE ON `pelanggan` FOR EACH ROW BEGIN
    INSERT INTO LogPelanggan (pelanggan_id, action, old_value, new_value) 
    VALUES (OLD.pelanggan_id, 'UPDATE', 
            CONCAT('Nama: ', OLD.nama, ', Alamat: ', OLD.alamat, ', Jenis Kelamin: ', OLD.jenis_kelamin), 
            CONCAT('Nama: ', NEW.nama, ', Alamat: ', NEW.alamat, ', Jenis Kelamin: ', NEW.jenis_kelamin));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_pelanggan` BEFORE INSERT ON `pelanggan` FOR EACH ROW BEGIN
    IF (SELECT COUNT(*) FROM Pelanggan WHERE nama = NEW.nama) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nama pelanggan sudah ada';
    ELSE
        INSERT INTO LogPelanggan (pelanggan_id, action, new_value) 
        VALUES (NEW.pelanggan_id, 'INSERT', CONCAT('Nama: ', NEW.nama, ', Alamat: ', NEW.alamat, ', Jenis Kelamin: ', NEW.jenis_kelamin));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pengembalian`
--

CREATE TABLE `pengembalian` (
  `pengembalian_id` int(11) NOT NULL,
  `sewa_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `tanggal_pengembalian` date DEFAULT NULL,
  `kondisi` varchar(255) DEFAULT NULL,
  `biaya_tambahan` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pengembalian`
--

INSERT INTO `pengembalian` (`pengembalian_id`, `sewa_id`, `admin_id`, `tanggal_pengembalian`, `kondisi`, `biaya_tambahan`) VALUES
(1, 1, 1, '2024-07-10', 'Baik', 0.00),
(2, 2, 2, '2024-07-12', 'Baik', 0.00),
(3, 3, 3, '2024-07-13', 'Baik', 0.00),
(4, 4, 4, '2024-07-14', 'Baik', 0.00),
(5, 5, 5, '2024-07-15', 'Baik', 0.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `sewa`
--

CREATE TABLE `sewa` (
  `sewa_id` int(11) NOT NULL,
  `pelanggan_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `tanggal_sewa` date DEFAULT NULL,
  `tanggal_kembali` date DEFAULT NULL,
  `total_biaya` decimal(10,2) DEFAULT NULL,
  `status` enum('Selesai','Berlangsung','Dibatalkan') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `sewa`
--

INSERT INTO `sewa` (`sewa_id`, `pelanggan_id`, `admin_id`, `tanggal_sewa`, `tanggal_kembali`, `total_biaya`, `status`) VALUES
(1, 1, 1, '2024-07-01', '2024-07-10', 500000.00, 'Selesai'),
(2, 2, 2, '2024-07-02', '2024-07-12', 600000.00, 'Selesai'),
(3, 3, 3, '2024-07-03', '2024-07-13', 700000.00, 'Berlangsung'),
(4, 4, 4, '2024-07-04', '2024-07-14', 800000.00, 'Berlangsung'),
(5, 5, 5, '2024-07-05', '2024-07-15', 900000.00, 'Dibatalkan');

--
-- Trigger `sewa`
--
DELIMITER $$
CREATE TRIGGER `before_delete_sewa` BEFORE DELETE ON `sewa` FOR EACH ROW BEGIN
    IF OLD.status != 'Dibatalkan' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hanya penyewaan yang dibatalkan yang bisa dihapus';
    ELSE
        INSERT INTO LogSewa (sewa_id, action, old_value) 
        VALUES (OLD.sewa_id, 'DELETE', CONCAT('Pelanggan ID: ', OLD.pelanggan_id, ', Admin ID: ', OLD.admin_id, ', Tanggal Sewa: ', OLD.tanggal_sewa, ', Tanggal Kembali: ', OLD.tanggal_kembali, ', Total Biaya: ', OLD.total_biaya, ', Status: ', OLD.status));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `sewalaptop`
--

CREATE TABLE `sewalaptop` (
  `sewa_id` int(11) NOT NULL,
  `laptop_id` int(11) NOT NULL,
  `jumlah` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `sewalaptop`
--

INSERT INTO `sewalaptop` (`sewa_id`, `laptop_id`, `jumlah`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_ongoing_rentals`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_ongoing_rentals` (
`sewa_id` int(11)
,`pelanggan_id` int(11)
,`admin_id` int(11)
,`total_biaya` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_pelanggan_horizontal`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_pelanggan_horizontal` (
`pelanggan_id` int(11)
,`nama` varchar(100)
,`jenis_kelamin` enum('L','P')
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_sewa_vertical`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_sewa_vertical` (
`sewa_id` int(11)
,`pelanggan_id` int(11)
,`admin_id` int(11)
,`tanggal_sewa` date
,`tanggal_kembali` date
,`total_biaya` decimal(10,2)
,`status` enum('Selesai','Berlangsung','Dibatalkan')
);

-- --------------------------------------------------------

--
-- Struktur untuk view `view_ongoing_rentals`
--
DROP TABLE IF EXISTS `view_ongoing_rentals`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_ongoing_rentals`  AS SELECT `sewa`.`sewa_id` AS `sewa_id`, `sewa`.`pelanggan_id` AS `pelanggan_id`, `sewa`.`admin_id` AS `admin_id`, `sewa`.`total_biaya` AS `total_biaya` FROM `sewa` WHERE `sewa`.`status` = 'Berlangsung'WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_pelanggan_horizontal`
--
DROP TABLE IF EXISTS `view_pelanggan_horizontal`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_pelanggan_horizontal`  AS SELECT `pelanggan`.`pelanggan_id` AS `pelanggan_id`, `pelanggan`.`nama` AS `nama`, `pelanggan`.`jenis_kelamin` AS `jenis_kelamin` FROM `pelanggan` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_sewa_vertical`
--
DROP TABLE IF EXISTS `view_sewa_vertical`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_sewa_vertical`  AS SELECT `sewa`.`sewa_id` AS `sewa_id`, `sewa`.`pelanggan_id` AS `pelanggan_id`, `sewa`.`admin_id` AS `admin_id`, `sewa`.`tanggal_sewa` AS `tanggal_sewa`, `sewa`.`tanggal_kembali` AS `tanggal_kembali`, `sewa`.`total_biaya` AS `total_biaya`, `sewa`.`status` AS `status` FROM `sewa` WHERE `sewa`.`status` = 'Selesai' ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indeks untuk tabel `detailpelanggan`
--
ALTER TABLE `detailpelanggan`
  ADD PRIMARY KEY (`detail_id`),
  ADD UNIQUE KEY `pelanggan_id` (`pelanggan_id`);

--
-- Indeks untuk tabel `kategorilaptop`
--
ALTER TABLE `kategorilaptop`
  ADD PRIMARY KEY (`kategori_id`);

--
-- Indeks untuk tabel `laptop`
--
ALTER TABLE `laptop`
  ADD PRIMARY KEY (`laptop_id`);

--
-- Indeks untuk tabel `laptopkategori`
--
ALTER TABLE `laptopkategori`
  ADD PRIMARY KEY (`laptop_id`,`kategori_id`),
  ADD KEY `kategori_id` (`kategori_id`);

--
-- Indeks untuk tabel `laptopsewa`
--
ALTER TABLE `laptopsewa`
  ADD PRIMARY KEY (`sewa_id`,`laptop_id`),
  ADD KEY `idx_sewa_laptop` (`sewa_id`,`laptop_id`);

--
-- Indeks untuk tabel `loglaptop`
--
ALTER TABLE `loglaptop`
  ADD PRIMARY KEY (`log_id`);

--
-- Indeks untuk tabel `logpelanggan`
--
ALTER TABLE `logpelanggan`
  ADD PRIMARY KEY (`log_id`);

--
-- Indeks untuk tabel `logsewa`
--
ALTER TABLE `logsewa`
  ADD PRIMARY KEY (`log_id`);

--
-- Indeks untuk tabel `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`pelanggan_id`),
  ADD KEY `idx_pelanggan` (`nama`,`alamat`);

--
-- Indeks untuk tabel `pengembalian`
--
ALTER TABLE `pengembalian`
  ADD PRIMARY KEY (`pengembalian_id`),
  ADD KEY `sewa_id` (`sewa_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indeks untuk tabel `sewa`
--
ALTER TABLE `sewa`
  ADD PRIMARY KEY (`sewa_id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `idx_sewa_status` (`pelanggan_id`,`status`);

--
-- Indeks untuk tabel `sewalaptop`
--
ALTER TABLE `sewalaptop`
  ADD PRIMARY KEY (`sewa_id`,`laptop_id`),
  ADD KEY `laptop_id` (`laptop_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `admin`
--
ALTER TABLE `admin`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `detailpelanggan`
--
ALTER TABLE `detailpelanggan`
  MODIFY `detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `kategorilaptop`
--
ALTER TABLE `kategorilaptop`
  MODIFY `kategori_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `laptop`
--
ALTER TABLE `laptop`
  MODIFY `laptop_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `loglaptop`
--
ALTER TABLE `loglaptop`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `logpelanggan`
--
ALTER TABLE `logpelanggan`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `logsewa`
--
ALTER TABLE `logsewa`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pelanggan`
--
ALTER TABLE `pelanggan`
  MODIFY `pelanggan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `pengembalian`
--
ALTER TABLE `pengembalian`
  MODIFY `pengembalian_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `sewa`
--
ALTER TABLE `sewa`
  MODIFY `sewa_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `detailpelanggan`
--
ALTER TABLE `detailpelanggan`
  ADD CONSTRAINT `detailpelanggan_ibfk_1` FOREIGN KEY (`pelanggan_id`) REFERENCES `pelanggan` (`pelanggan_id`);

--
-- Ketidakleluasaan untuk tabel `laptopkategori`
--
ALTER TABLE `laptopkategori`
  ADD CONSTRAINT `laptopkategori_ibfk_1` FOREIGN KEY (`laptop_id`) REFERENCES `laptop` (`laptop_id`),
  ADD CONSTRAINT `laptopkategori_ibfk_2` FOREIGN KEY (`kategori_id`) REFERENCES `kategorilaptop` (`kategori_id`);

--
-- Ketidakleluasaan untuk tabel `pengembalian`
--
ALTER TABLE `pengembalian`
  ADD CONSTRAINT `pengembalian_ibfk_1` FOREIGN KEY (`sewa_id`) REFERENCES `sewa` (`sewa_id`),
  ADD CONSTRAINT `pengembalian_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`);

--
-- Ketidakleluasaan untuk tabel `sewa`
--
ALTER TABLE `sewa`
  ADD CONSTRAINT `sewa_ibfk_1` FOREIGN KEY (`pelanggan_id`) REFERENCES `pelanggan` (`pelanggan_id`),
  ADD CONSTRAINT `sewa_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`);

--
-- Ketidakleluasaan untuk tabel `sewalaptop`
--
ALTER TABLE `sewalaptop`
  ADD CONSTRAINT `sewalaptop_ibfk_1` FOREIGN KEY (`sewa_id`) REFERENCES `sewa` (`sewa_id`),
  ADD CONSTRAINT `sewalaptop_ibfk_2` FOREIGN KEY (`laptop_id`) REFERENCES `laptop` (`laptop_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
