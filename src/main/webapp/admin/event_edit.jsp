<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%@ include file="/WEB-INF/auth_admin.jsp" %>
<%
  int id = 0;
  try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
  if (id == 0) { response.sendRedirect("event_list.jsp"); return; }

  String msg = "", msgType = "";
  String judul="", deskripsi="", lokasi="", tanggal="", waktu="", kategori="", status="";
  int kuota = 0;

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    try (Connection con = getConnection()) {
      PreparedStatement ps = con.prepareStatement(
        "UPDATE events SET judul=?,deskripsi=?,lokasi=?,tanggal=?,waktu=?,kuota=?,kategori=?,status=? WHERE id=?");
      ps.setString(1, request.getParameter("judul"));
      ps.setString(2, request.getParameter("deskripsi"));
      ps.setString(3, request.getParameter("lokasi"));
      ps.setString(4, request.getParameter("tanggal"));
      ps.setString(5, request.getParameter("waktu"));
      ps.setInt(6,    Integer.parseInt(request.getParameter("kuota")));
      ps.setString(7, request.getParameter("kategori"));
      ps.setString(8, request.getParameter("status"));
      ps.setInt(9, id);
      ps.executeUpdate();
      msg = "Event berhasil diperbarui!"; msgType = "success";
    } catch (Exception ex) { msg = "Gagal: " + ex.getMessage(); msgType = "error"; }
  }

  // Load existing data
  try (Connection con = getConnection()) {
    PreparedStatement ps = con.prepareStatement("SELECT * FROM events WHERE id=?");
    ps.setInt(1, id);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      judul     = rs.getString("judul");
      deskripsi = rs.getString("deskripsi") != null ? rs.getString("deskripsi") : "";
      lokasi    = rs.getString("lokasi");
      tanggal   = rs.getDate("tanggal").toString();
      waktu     = rs.getString("waktu").substring(0,5);
      kategori  = rs.getString("kategori");
      status    = rs.getString("status");
      kuota     = rs.getInt("kuota");
    }
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Edit Event — UNIVENTS</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar">
  <a href="../landing/index.jsp" class="navbar-brand">🎓 UNI<span>VENTS</span></a>
  <div class="navbar-links">
    <a href="event_list.jsp">← Daftar Event</a>
    <a href="../mahasiswa/logout.jsp" class="btn btn-outline btn-sm">Keluar</a>
  </div>
</nav>

<div class="admin-layout">
  <aside class="sidebar">
    <ul class="sidebar-menu">
      <li><a href="dashboard.jsp">📊 Dashboard</a></li>
      <li><a href="event_list.jsp" class="active">📅 Kelola Event</a></li>
      <li><a href="event_add.jsp">➕ Tambah Event</a></li>
      <li><a href="users.jsp">👥 Mahasiswa</a></li>
      <li><a href="../mahasiswa/logout.jsp">🚪 Keluar</a></li>
    </ul>
  </aside>

  <main class="main-content">
    <div style="max-width:600px">
      <h1 style="font-size:1.4rem;font-weight:800;margin-bottom:1.5rem">✏️ Edit Event</h1>

      <% if (!msg.isEmpty()) { %>
        <div class="alert alert-<%=msgType.equals("success")?"success":"error"%>"><%=msg%></div>
      <% } %>

      <div style="background:var(--white);border:1px solid var(--border);border-radius:var(--radius);padding:2rem;">
        <form method="POST">
          <div class="form-group">
            <label>Judul Event *</label>
            <input type="text" name="judul" value="<%=judul%>" required>
          </div>
          <div class="form-group">
            <label>Deskripsi</label>
            <textarea name="deskripsi" rows="4"><%=deskripsi%></textarea>
          </div>
          <div class="form-group">
            <label>Lokasi *</label>
            <input type="text" name="lokasi" value="<%=lokasi%>" required>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Tanggal *</label>
              <input type="date" name="tanggal" value="<%=tanggal%>" required>
            </div>
            <div class="form-group">
              <label>Waktu *</label>
              <input type="time" name="waktu" value="<%=waktu%>" required>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Kuota *</label>
              <input type="number" name="kuota" value="<%=kuota%>" min="1" required>
            </div>
            <div class="form-group">
              <label>Kategori</label>
              <select name="kategori">
                <option value="akademik"     <%="akademik".equals(kategori)?"selected":""%>>Akademik</option>
                <option value="non-akademik" <%="non-akademik".equals(kategori)?"selected":""%>>Non-Akademik</option>
                <option value="olahraga"     <%="olahraga".equals(kategori)?"selected":""%>>Olahraga</option>
                <option value="seni"         <%="seni".equals(kategori)?"selected":""%>>Seni</option>
                <option value="lainnya"      <%="lainnya".equals(kategori)?"selected":""%>>Lainnya</option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label>Status</label>
            <select name="status">
              <option value="aktif"   <%="aktif".equals(status)?"selected":""%>>Aktif</option>
              <option value="selesai" <%="selesai".equals(status)?"selected":""%>>Selesai</option>
              <option value="batal"   <%="batal".equals(status)?"selected":""%>>Batal</option>
            </select>
          </div>
          <div style="display:flex;gap:1rem;">
            <button type="submit" class="btn btn-primary">💾 Simpan Perubahan</button>
            <a href="event_list.jsp" class="btn btn-outline">Batal</a>
          </div>
        </form>
      </div>
    </div>
  </main>
</div>
</body>
</html>
