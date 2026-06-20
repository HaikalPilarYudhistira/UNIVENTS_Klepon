<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%@ include file="/WEB-INF/auth_admin.jsp" %>
<%
  int id = 0;
  try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
  if (id == 0) { response.sendRedirect("event_list.jsp"); return; }

  String eventJudul = "", eventTanggal = "";
  int kuota = 0, jumlahPeserta = 0;
  StringBuilder rows = new StringBuilder();

  try (Connection con = getConnection()) {
    PreparedStatement pse = con.prepareStatement("SELECT judul,tanggal,kuota FROM events WHERE id=?");
    pse.setInt(1, id);
    ResultSet rse = pse.executeQuery();
    if (rse.next()) {
      eventJudul   = rse.getString("judul");
      eventTanggal = rse.getDate("tanggal").toString();
      kuota        = rse.getInt("kuota");
    }

    PreparedStatement ps = con.prepareStatement(
      "SELECT u.nama,u.nim,u.email,p.status,p.created_at " +
      "FROM pendaftaran p JOIN users u ON u.id=p.user_id " +
      "WHERE p.event_id=? ORDER BY p.created_at ASC");
    ps.setInt(1, id);
    ResultSet rs = ps.executeQuery();
    int no = 1;
    while (rs.next()) {
      jumlahPeserta++;
      String st = rs.getString("status");
      String stBadge = "terdaftar".equals(st)?"badge-green":"hadir".equals(st)?"":"badge-red";
      rows.append("<tr>")
        .append("<td>").append(no++).append("</td>")
        .append("<td>").append(rs.getString("nama")).append("</td>")
        .append("<td>").append(rs.getString("nim") != null ? rs.getString("nim") : "-").append("</td>")
        .append("<td>").append(rs.getString("email")).append("</td>")
        .append("<td><span class='badge ").append(stBadge).append("'>").append(st).append("</span></td>")
        .append("<td>").append(rs.getTimestamp("created_at")).append("</td>")
        .append("</tr>");
    }
    if (jumlahPeserta == 0) rows.append("<tr><td colspan='6' style='text-align:center;padding:2rem;color:var(--text-muted)'>Belum ada peserta terdaftar.</td></tr>");
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Peserta — UNIVENTS</title>
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
    <h1 style="font-size:1.4rem;font-weight:800;margin-bottom:.5rem">👥 Daftar Peserta</h1>
    <p style="color:var(--text-muted);margin-bottom:1.5rem;font-size:.9rem">
      <strong><%=eventJudul%></strong> · <%=eventTanggal%> · <%=jumlahPeserta%>/<%=kuota%> peserta
    </p>

    <!-- Progress kuota -->
    <div style="margin-bottom:1.5rem">
      <div style="font-size:.8rem;color:var(--text-muted);margin-bottom:.4rem">Kapasitas terisi: <%=kuota>0?jumlahPeserta*100/kuota:0%>%</div>
      <div style="background:var(--border);border-radius:99px;height:8px;overflow:hidden">
        <div style="width:<%=kuota>0?jumlahPeserta*100/kuota:0%>%;background:var(--primary);height:100%;border-radius:99px;transition:width .5s"></div>
      </div>
    </div>

    <div class="table-wrap">
      <table>
        <thead>
          <tr><th>#</th><th>Nama</th><th>NIM</th><th>Email</th><th>Status</th><th>Waktu Daftar</th></tr>
        </thead>
        <tbody><%=rows%></tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
