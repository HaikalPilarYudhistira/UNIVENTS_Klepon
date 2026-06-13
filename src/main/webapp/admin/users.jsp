<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%@ include file="/WEB-INF/auth_admin.jsp" %>
<%
  StringBuilder rows = new StringBuilder();
  int total = 0;
  try (Connection con = getConnection()) {
    ResultSet rs = con.createStatement().executeQuery(
      "SELECT u.id,u.nama,u.nim,u.email,u.role,u.created_at," +
      "(SELECT COUNT(*) FROM pendaftaran p WHERE p.user_id=u.id) as jml_event " +
      "FROM users u ORDER BY u.created_at DESC");
    while (rs.next()) {
      total++;
      String role = rs.getString("role");
      rows.append("<tr>")
        .append("<td>").append(rs.getString("nama")).append("</td>")
        .append("<td>").append(rs.getString("nim") != null ? rs.getString("nim") : "-").append("</td>")
        .append("<td>").append(rs.getString("email")).append("</td>")
        .append("<td><span class='badge ").append("admin".equals(role)?"badge-yellow":"").append("'>").append(role).append("</span></td>")
        .append("<td>").append(rs.getInt("jml_event")).append(" event</td>")
        .append("<td style='font-size:.8rem;color:var(--text-muted)'>").append(rs.getTimestamp("created_at")).append("</td>")
        .append("</tr>");
    }
    if (total == 0) rows.append("<tr><td colspan='6' style='text-align:center;padding:2rem;color:var(--text-muted)'>Belum ada pengguna.</td></tr>");
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mahasiswa — UNIVENTS</title>
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
      <li><a href="event_list.jsp">📅 Kelola Event</a></li>
      <li><a href="event_add.jsp">➕ Tambah Event</a></li>
      <li><a href="users.jsp" class="active">👥 Mahasiswa</a></li>
      <li><a href="../mahasiswa/logout.jsp">🚪 Keluar</a></li>
    </ul>
  </aside>

  <main class="main-content">
    <h1 style="font-size:1.4rem;font-weight:800;margin-bottom:1.5rem">👥 Daftar Pengguna (<%=total%>)</h1>
    <div class="table-wrap">
      <table>
        <thead>
          <tr><th>Nama</th><th>NIM</th><th>Email</th><th>Role</th><th>Event Diikuti</th><th>Bergabung</th></tr>
        </thead>
        <tbody><%=rows%></tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
