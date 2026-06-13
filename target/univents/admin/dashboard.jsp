<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%@ include file="/WEB-INF/auth_admin.jsp" %>
<%
  int cntEvent=0, cntAktif=0, cntUser=0, cntPendaftar=0;
  StringBuilder recentEvents = new StringBuilder();
  try (Connection con = getConnection()) {
    cntEvent     = ((ResultSet)con.createStatement().executeQuery("SELECT COUNT(*) FROM events")).next() ? 0 : 0;
    ResultSet r1 = con.createStatement().executeQuery("SELECT COUNT(*) FROM events");         if(r1.next()) cntEvent=r1.getInt(1);
    ResultSet r2 = con.createStatement().executeQuery("SELECT COUNT(*) FROM events WHERE status='aktif'"); if(r2.next()) cntAktif=r2.getInt(1);
    ResultSet r3 = con.createStatement().executeQuery("SELECT COUNT(*) FROM users WHERE role='mahasiswa'"); if(r3.next()) cntUser=r3.getInt(1);
    ResultSet r4 = con.createStatement().executeQuery("SELECT COUNT(*) FROM pendaftaran");    if(r4.next()) cntPendaftar=r4.getInt(1);

    PreparedStatement ps = con.prepareStatement(
      "SELECT e.id,e.judul,e.tanggal,e.status,e.kuota," +
      "(SELECT COUNT(*) FROM pendaftaran p WHERE p.event_id=e.id) as peserta " +
      "FROM events e ORDER BY e.created_at DESC LIMIT 8");
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      String st = rs.getString("status");
      String stBadge = "aktif".equals(st)?"badge-green":"selesai".equals(st)?"badge-yellow":"badge-red";
      recentEvents.append("<tr>")
        .append("<td>").append(rs.getString("judul")).append("</td>")
        .append("<td>").append(rs.getDate("tanggal")).append("</td>")
        .append("<td>").append(rs.getInt("peserta")).append(" / ").append(rs.getInt("kuota")).append("</td>")
        .append("<td><span class='badge ").append(stBadge).append("'>").append(st).append("</span></td>")
        .append("<td style='display:flex;gap:.4rem;'>")
        .append("<a href='event_edit.jsp?id=").append(rs.getInt("id")).append("' class='btn btn-outline btn-sm'>Edit</a>")
        .append("<a href='event_delete.jsp?id=").append(rs.getInt("id")).append("' class='btn btn-danger btn-sm' onclick=\"return confirm('Hapus event ini?')\">Hapus</a>")
        .append("<a href='peserta.jsp?id=").append(rs.getInt("id")).append("' class='btn btn-success btn-sm'>Peserta</a>")
        .append("</td></tr>");
    }
  } catch (Exception ex) {
    recentEvents.append("<tr><td colspan='5' style='color:red'>Error: ").append(ex.getMessage()).append("</td></tr>");
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Dashboard Admin — UNIVENTS</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar">
  <a href="../landing/index.jsp" class="navbar-brand">🎓 UNI<span>VENTS</span></a>
  <div class="navbar-links">
    <span style="font-size:.875rem;color:var(--text-muted)">Admin: <%=_adminName%></span>
    <a href="../mahasiswa/logout.jsp" class="btn btn-outline btn-sm">Keluar</a>
  </div>
</nav>

<div class="admin-layout">
  <!-- Sidebar -->
  <aside class="sidebar">
    <ul class="sidebar-menu">
      <li><a href="dashboard.jsp" class="active">📊 Dashboard</a></li>
      <li><a href="event_list.jsp">📅 Kelola Event</a></li>
      <li><a href="event_add.jsp">➕ Tambah Event</a></li>
      <li><a href="users.jsp">👥 Mahasiswa</a></li>
      <li><a href="../mahasiswa/logout.jsp">🚪 Keluar</a></li>
    </ul>
  </aside>

  <!-- Main -->
  <main class="main-content">
    <h1 style="font-size:1.4rem;font-weight:800;margin-bottom:1.5rem">📊 Dashboard Admin</h1>

    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-num"><%=cntEvent%></div>
        <div class="stat-label">Total Event</div>
      </div>
      <div class="stat-card">
        <div class="stat-num" style="color:var(--success)"><%=cntAktif%></div>
        <div class="stat-label">Event Aktif</div>
      </div>
      <div class="stat-card">
        <div class="stat-num"><%=cntUser%></div>
        <div class="stat-label">Mahasiswa Terdaftar</div>
      </div>
      <div class="stat-card">
        <div class="stat-num" style="color:var(--accent)"><%=cntPendaftar%></div>
        <div class="stat-label">Total Pendaftaran</div>
      </div>
    </div>

    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;flex-wrap:wrap;gap:.5rem;">
      <h2 style="font-size:1.1rem;font-weight:700">Event Terbaru</h2>
      <a href="event_add.jsp" class="btn btn-primary btn-sm">➕ Tambah Event</a>
    </div>

    <div class="table-wrap">
      <table>
        <thead>
          <tr><th>Judul Event</th><th>Tanggal</th><th>Peserta</th><th>Status</th><th>Aksi</th></tr>
        </thead>
        <tbody><%=recentEvents%></tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
