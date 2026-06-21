<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%
  String eventRows = "";
  int totalEvents  = 0;
  int totalUsers   = 0;
  
  Connection con = null;
  try {
      // PAKSA langsung pakai driver MySQL/MariaDB universal yang disukai Railway
      Class.forName("com.mysql.cj.jdbc.Driver"); 
      String directUrl = "jdbc:mysql://yamanote.proxy.rlwy.net:44958/railway";
      con = DriverManager.getConnection(directUrl, "root", "olTcJGZUeBVIIuSfQjuAvzbzYoHMBwnk");
  } catch (Exception e) {
      try {
          // Cadangan jika server Railway memakai driver MariaDB asli
          Class.forName("org.mariadb.jdbc.Driver");
          String directUrl = "jdbc:mariadb://yamanote.proxy.rlwy.net:44958/railway";
          con = DriverManager.getConnection(directUrl, "root", "olTcJGZUeBVIIuSfQjuAvzbzYoHMBwnk");
      } catch (Exception ex) {
          con = null;
      }
  }

  // FIX MASALAH 1: Baris duplikat if (con != null) { menggantung yang salah telah dihapus di sini.
  if (con != null) {
      try {
          ResultSet rs1 = con.createStatement().executeQuery("SELECT COUNT(*) FROM events WHERE status='aktif'");
          if (rs1.next()) totalEvents = rs1.getInt(1);
          ResultSet rs2 = con.createStatement().executeQuery("SELECT COUNT(*) FROM users WHERE role='mahasiswa'");
          if (rs2.next()) totalUsers = rs2.getInt(1);

          PreparedStatement ps = con.prepareStatement(
            "SELECT id,judul,deskripsi,lokasi,tanggal,waktu,kuota,kategori, " +
            "(SELECT COUNT(*) FROM pendaftaran p WHERE p.event_id=e.id) as peserta " +
            "FROM events e WHERE status='aktif' ORDER BY tanggal ASC LIMIT 6");
          ResultSet rs = ps.executeQuery();
          StringBuilder sb = new StringBuilder();
          while (rs.next()) {
            String kategori = rs.getString("kategori");
            String icon = kategori.equals("akademik") ? "🎓" :
                          kategori.equals("olahraga")  ? "⚽" :
                          kategori.equals("seni")       ? "🎨" : "📅";
            int kuota   = rs.getInt("kuota");
            int peserta = rs.getInt("peserta");
            int sisa    = kuota - peserta;
            String badgeSisa = sisa > 20 ? "badge-green" : sisa > 0 ? "badge-yellow" : "badge-red";
            String sisat = sisa > 0 ? sisa + " sisa" : "Penuh";
            sb.append("<div class='card'>")
              .append("<div class='card-poster'>").append(icon).append("</div>")
              .append("<div class='card-body'>")
              .append("<div class='card-meta'>")
              .append("<span><span class='badge'>").append(kategori).append("</span></span>")
              .append("<span class='badge ").append(badgeSisa).append("'>").append(sisat).append("</span>")
              .append("</div>")
              .append("<div class='card-title'>").append(rs.getString("judul")).append("</div>")
              .append("<div class='card-meta'>")
              .append("<span>📍 ").append(rs.getString("lokasi")).append("</span>")
              .append("<span>📅 ").append(rs.getDate("tanggal")).append("</span>")
              .append("</div>")
              .append("<div class='card-desc'>").append(rs.getString("deskripsi") != null ? rs.getString("deskripsi").substring(0, Math.min(90, rs.getString("deskripsi").length())) + "…" : "").append("</div>")
              .append("<a href='").append(request.getContextPath()).append("/mahasiswa/detail.jsp?id=").append(rs.getInt("id")).append("' class='btn btn-primary btn-sm'>Lihat Detail</a>")
              .append("</div></div>");
          }
          eventRows = sb.toString();
          if (eventRows.isEmpty()) eventRows = "<p style='color:var(--text-muted);grid-column:1/-1;text-align:center;padding:3rem 0'>Belum ada event yang tersedia.</p>";
      } catch (Exception ex) {
          eventRows = "<p style='color:red;grid-column:1/-1;text-align:center;padding:2rem'>Gagal memuat event: " + ex.getMessage() + "</p>";
      } finally {
          try { con.close(); } catch (Exception e) {}
      }
  } else {
      eventRows = "<p style='color:red;grid-column:1/-1;text-align:center;padding:2rem'>Gagal memuat koneksi ke database pusat Railway.</p>";
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>UNIVENTS — Sistem Informasi Event Kampus</title>
  
  <!-- Menggunakan parameter v=1.2 untuk memaksa penyegaran CSS -->
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css?v=1.2">

  <!-- FIX: Menggunakan ekstensi .png untuk gambar latar belakang hero -->
  <style>
    header.hero {
      background: linear-gradient(rgba(10, 37, 64, 0.65), rgba(10, 37, 64, 0.75)), 
                  url('<%=request.getContextPath()%>/css/hero-bg.png?v=1.5') no-repeat center center/cover;
      padding: 7rem 0;
    }
    header.hero h1, header.hero p {
      color: #ffffff !important;
      text-shadow: 0 2px 6px rgba(0, 0, 0, 0.7);
    }
  </style>
</head> <!-- FIX MASALAH 3: Tag penutup head sekarang sudah ditambahkan sebelum body -->
<body>

<!-- NAVBAR -->
<nav class="navbar">
  <div class="navbar-brand">🎓 UNI<span>VENTS</span></div>
  <div class="navbar-links">
    <a href="<%=request.getContextPath()%>/landing/index.jsp" class="active">Beranda</a>
    <a href="<%=request.getContextPath()%>/mahasiswa/events.jsp">Event</a>
    <a href="<%=request.getContextPath()%>/mahasiswa/login.jsp" class="btn btn-outline">Masuk</a>
    <a href="<%=request.getContextPath()%>/mahasiswa/register.jsp" class="btn btn-primary">Daftar</a>
  </div>
</nav>

<!-- HERO SECTION BANNER -->
<header class="hero">
  <div class="container">
    <h1>Satu Tempat,<br>Semua Event Kampus</h1>
    <p>UNIVENTS memudahkan mahasiswa menemukan dan mendaftar event kampus — seminar, workshop, lomba, dan lainnya — dalam satu platform terpusat.</p>
    <div class="hero-actions">
      <a href="<%=request.getContextPath()%>/mahasiswa/events.jsp" class="btn btn-primary" style="background:#fff;color:var(--primary)">Jelajahi Event</a>
      <a href="<%=request.getContextPath()%>/mahasiswa/register.jsp" class="btn btn-outline" style="border-color:#fff;color:#fff">Buat Akun Gratis</a>
    </div>
  </div>
</header>

<!-- STATS -->
<section style="background:#fff;border-bottom:1px solid var(--border);padding:1.5rem 0;">
  <div class="container" style="display:flex;gap:3rem;justify-content:center;flex-wrap:wrap;text-align:center;">
    <div><div style="font-size:2rem;font-weight:800;color:var(--primary)"><%=totalEvents%></div><div style="font-size:.85rem;color:var(--text-muted)">Event Aktif</div></div>
    <div><div style="font-size:2rem;font-weight:800;color:var(--primary)"><%=totalUsers%></div><div style="font-size:.85rem;color:var(--text-muted)">Mahasiswa Terdaftar</div></div>
    <div><div style="font-size:2rem;font-weight:800;color:var(--primary)">∞</div><div style="font-size:.85rem;color:var(--text-muted)">Informasi Terpusat</div></div>
  </div>
</section>

<!-- EVENT LIST -->
<section class="section">
  <div class="container">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;flex-wrap:wrap;gap:.75rem;">
      <h2 style="font-size:1.4rem;font-weight:800">Event Mendatang</h2>
      <a href="<%=request.getContextPath()%>/mahasiswa/events.jsp" class="btn btn-outline btn-sm">Lihat Semua →</a>
    </div>
    <div class="card-grid">
      <%=eventRows%>
    </div>
  </div>
</section>

<!-- FOOTER -->
<footer style="background:var(--text);color:#fff;padding:2rem;text-align:center;font-size:.85rem;opacity:.9;margin-top:2rem;">
  © 2025 UNIVENTS — Sistem Informasi Event Kampus · Kelompok Klepon · Program Studi Teknik Informatika
</footer>

</body>
</html>
