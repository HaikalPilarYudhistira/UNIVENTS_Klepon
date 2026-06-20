<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%@ include file="/WEB-INF/auth_admin.jsp" %>
<%
  StringBuilder rows = new StringBuilder();
  try (Connection con = getConnection()) {
    ResultSet rs = con.createStatement().executeQuery(
      "SELECT e.id,e.judul,e.tanggal,e.lokasi,e.kuota,e.status,e.kategori," +
      "(SELECT COUNT(*) FROM pendaftaran p WHERE p.event_id=e.id) as peserta " +
      "FROM events e ORDER BY e.created_at DESC");
    boolean any = false;
    while (rs.next()) {
      any = true;
      String st = rs.getString("status");
      String stBadge = "aktif".equals(st)?"badge-green":"selesai".equals(st)?"badge-yellow":"badge-red";
      rows.append("<tr>")
        .append("<td><strong>").append(rs.getString("judul")).append("</strong><br><small style='color:var(--text-muted)'>").append(rs.getString("kategori")).append("</small></td>")
        .append("<td>").append(rs.getDate("tanggal")).append("</td>")
        .append("<td>").append(rs.getString("lokasi")).append("</td>")
        .append("<td>").append(rs.getInt("peserta")).append(" / ").append(rs.getInt("kuota")).append("</td>")
        .append("<td><span class='badge ").append(stBadge).append("'>").append(st).append("</span></td>")
        .append("<td><div style='display:flex;gap:.4rem;flex-wrap:wrap'>")
        .append("<a href='event_edit.jsp?id=").append(rs.getInt("id")).append("' class='btn btn-outline btn-sm'>✏️ Edit</a>")
        .append("<a href='peserta.jsp?id=").append(rs.getInt("id")).append("' class='btn btn-success btn-sm'>👥 Peserta</a>")
        .append("<a href='event_delete.jsp?id=").append(rs.getInt("id")).append("' class='btn btn-danger btn-sm' onclick=\"return confirm('Hapus event ini?')\">🗑 Hapus</a>")
        .append("</div></td></tr>");
    }
    if (!any) rows.append("<tr><td colspan='6' style='text-align:center;padding:2rem;color:var(--text-muted)'>Belum ada event.</td></tr>");
  } catch (Exception ex) {
    rows.append("<tr><td colspan='6' style='color:red'>Error: ").append(ex.getMessage()).append("</td></tr>");
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Kelola Event — UNIVENTS</title>
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
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;flex-wrap:wrap;gap:.5rem;">
      <h1 style="font-size:1.4rem;font-weight:800">📅 Kelola Event</h1>
      <a href="event_add.jsp" class="btn btn-primary">➕ Tambah Event</a>
    </div>

    <div class="table-wrap">
      <table>
        <thead>
          <tr><th>Event</th><th>Tanggal</th><th>Lokasi</th><th>Peserta</th><th>Status</th><th>Aksi</th></tr>
        </thead>
        <tbody><%=rows%></tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
