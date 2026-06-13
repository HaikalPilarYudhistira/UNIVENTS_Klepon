# 🎓 UNIVENTS — Sistem Informasi Event Kampus
> Kelompok Klepon · Program Studi Teknik Informatika

---

## 📁 Struktur Folder

```
UNIVENTS/
├── pom.xml                              ← Maven build file
└── src/main/webapp/
    ├── WEB-INF/
    │   ├── web.xml                      ← Konfigurasi Tomcat (PENTING!)
    │   ├── db.jsp                       ← Konfigurasi koneksi MariaDB
    │   ├── auth_admin.jsp               ← Guard autentikasi admin
    │   └── schema.sql                   ← Script database MariaDB
    ├── css/
    │   └── style.css                    ← Stylesheet global
    ├── landing/
    │   └── index.jsp                    ← Halaman beranda publik
    ├── mahasiswa/
    │   ├── login.jsp                    ← Login mahasiswa & admin
    │   ├── register.jsp                 ← Pendaftaran akun mahasiswa
    │   ├── events.jsp                   ← Daftar event (dengan search/filter)
    │   ├── detail.jsp                   ← Detail event + tombol daftar
    │   ├── notifikasi.jsp               ← Notifikasi mahasiswa
    │   └── logout.jsp                   ← Logout
    └── admin/
        ├── dashboard.jsp                ← Dashboard admin (statistik)
        ├── event_list.jsp               ← Kelola semua event
        ├── event_add.jsp                ← Tambah event baru
        ├── event_edit.jsp               ← Edit event
        ├── event_delete.jsp             ← Hapus event
        ├── peserta.jsp                  ← Daftar peserta per event
        └── users.jsp                    ← Daftar semua pengguna
```

---

## 🚀 Langkah Deploy

### 1. Setup MariaDB

```sql
-- Buat database & user
CREATE DATABASE univents CHARACTER SET utf8mb4;
CREATE USER 'univents_user'@'localhost' IDENTIFIED BY 'univents_pass';
GRANT ALL PRIVILEGES ON univents.* TO 'univents_user'@'localhost';
FLUSH PRIVILEGES;

-- Import schema
USE univents;
SOURCE src/main/webapp/WEB-INF/schema.sql;
```

### 2. Sesuaikan Konfigurasi DB

Edit file `src/main/webapp/WEB-INF/db.jsp`:

```java
static final String DB_URL  = "jdbc:mariadb://localhost:3306/univents";
static final String DB_USER = "univents_user";
static final String DB_PASS = "univents_pass";
```

### 3. Build WAR dengan Maven

```bash
cd UNIVENTS
mvn clean package
# Output: target/univents.war
```

### 4. Deploy ke Tomcat

```bash
# Copy WAR ke webapps Tomcat
cp target/univents.war /opt/tomcat/webapps/

# Tomcat akan auto-deploy; akses di:
# http://localhost:8080/univents/
```

> **Catatan Tomcat 10+:** Gunakan `jakarta.*` bukan `javax.*` (sudah dikonfigurasi di pom.xml).

---

## 🔐 Akun Default

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@univents.ac.id | admin123 |
| Mahasiswa | budi@mhs.ac.id | mhs123 |

> ⚠️ **Ganti password default sebelum deploy ke produksi!**

---

## 📌 Use Case yang Diimplementasi

| Use Case | Status |
|----------|--------|
| Login (Admin & Mahasiswa) | ✅ |
| Tambah Event | ✅ |
| Edit Event | ✅ |
| Hapus Event | ✅ |
| Lihat Daftar Peserta | ✅ |
| Lihat Daftar & Detail Event | ✅ |
| Daftar Event | ✅ |
| Terima Notifikasi | ✅ |

---

## ⚠️ Catatan untuk Produksi

1. **BCrypt password hashing** — tambahkan dependency `org.mindrot:jbcrypt` dan ganti plain text password dengan `BCrypt.hashpw()`
2. **Validasi input** — tambahkan server-side validation lebih ketat
3. **Upload poster** — implementasi file upload untuk gambar event
4. **HTTPS** — konfigurasi SSL di Tomcat atau gunakan reverse proxy (Nginx)
5. **Connection Pool** — gunakan Tomcat JNDI DataSource untuk production
