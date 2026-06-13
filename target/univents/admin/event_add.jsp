<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%@ include file="/WEB-INF/auth_admin.jsp" %>
<%
  String msg = "", msgType = "";
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String judul    = request.getParameter("judul");
    String deskripsi= request.getParameter("deskripsi");
    String lokasi   = request.getParameter("lokasi");
    String tanggal  = request.getParameter("tanggal");
    String waktu    = request.getParameter("waktu");
    String kuota    = request.getParameter("kuota");
    String kategori = request.getParameter("kategori");
    try (Connection con = getConnection()) {
      PreparedStatement ps = con.prepareStatement(
        "INSERT INTO events (judul,deskripsi,lokasi,tanggal,waktu,kuota,kategori,admin_id) VALUES (?,?,?,?,?,?,?,?)");
      ps.setString(1, judul);
      ps.setString(2, deskripsi);
      ps.setString(3, lokasi);
      ps.setString(4, tanggal);
      ps.setString(5, waktu);
      ps.setInt(6, Integer.parseInt(kuota));
      ps.setString(7, kategori);
      ps.setInt(8, _adminId);
      ps.executeUpdate();

      // Kirim notifikasi ke semua mahasiswa
      con.createStatement().execute(
        "INSERT INTO notifikasi (user_id, pesan) " +
        "SELECT id, CONCAT('Event baru tersedia: " + judul + "') FROM users WHERE role='mahasiswa'");

      msg = "Event berhasil ditambahkan!"; msgType = "success";
    } catch (Exception ex) {
      msg = "Gagal: " + ex.getMessage(); msgType = "error";
    }
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tambah Event — UNIVENTS</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar">
  <a href="../landing/index.jsp" class="navbar-brand">🎓 UNI<span>VENTS</span></a>
  <div class="navbar-links">
    <a href="dashboard.jsp">← Dashboard</a>
    <a href="../mahasiswa/logout.jsp" class="btn btn-outline btn-sm">Keluar</a>
  </div>
</nav>

<div class="admin-layout">
  <aside class="sidebar">
    <ul class="sidebar-menu">
      <li><a href="dashboard.jsp">📊 Dashboard</a></li>
      <li><a href="event_list.jsp">📅 Kelola Event</a></li>
      <li><a href="event_add.jsp" class="active">➕ Tambah Event</a></li>
      <li><a href="users.jsp">👥 Mahasiswa</a></li>
      <li><a href="../mahasiswa/logout.jsp">🚪 Keluar</a></li>
    </ul>
  </aside>

  <main class="main-content">
    <div style="max-width:600px">
      <h1 style="font-size:1.4rem;font-weight:800;margin-bottom:1.5rem">➕ Tambah Event Baru</h1>

      <% if (!msg.isEmpty()) { %>
        <div class="alert alert-<%=msgType.equals("success")?"success":"error"%>"><%=msg%>
          <% if (msgType.equals("success")) { %> <a href="event_list.jsp" style="font-weight:700">Lihat Daftar Event →</a><% } %>
        </div>
      <% } %>

      <div style="background:var(--white);border:1px solid var(--border);border-radius:var(--radius);padding:2rem;">
        <form method="POST">
          <div class="form-group">
            <label>Judul Event *</label>
            <input type="text" name="judul" placeholder="Contoh: Seminar Nasional AI 2025" required>
          </div>
          <div class="form-group">
            <label>Deskripsi</label>
            <textarea name="deskripsi" rows="4" placeholder="Deskripsikan event ini..."></textarea>
          </div>
          <div class="form-group">
            <label>Lokasi *</label>
            <input type="text" name="lokasi" placeholder="Aula Utama, Gedung A Lt.3" required>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Tanggal *</label>
              <input type="date" name="tanggal" required>
            </div>
            <div class="form-group">
              <label>Waktu *</label>
              <input type="time" name="waktu" required>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Kuota Peserta *</label>
              <input type="number" name="kuota" min="1" value="100" required>
            </div>
            <div class="form-group">
              <label>Kategori *</label>
              <select name="kategori" required>
                <option value="akademik">Akademik</option>
                <option value="non-akademik">Non-Akademik</option>
                <option value="olahraga">Olahraga</option>
                <option value="seni">Seni</option>
                <option value="lainnya">Lainnya</option>
              </select>
            </div>
          </div>
          <div style="display:flex;gap:1rem;margin-top:.5rem;">
            <button type="submit" class="btn btn-primary">💾 Simpan Event</button>
            <a href="event_list.jsp" class="btn btn-outline">Batal</a>
          </div>
        </form>
      </div>
    </div>
  </main>
</div>
</body>
</html>
